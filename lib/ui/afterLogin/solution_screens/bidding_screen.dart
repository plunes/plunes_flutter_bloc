import 'dart:async';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/consultations.dart';
import 'package:plunes/ui/afterLogin/solution_screens/manual_bidding.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/testNproceduresMainScreen.dart';

// ignore: must_be_immutable
class SolutionBiddingScreen extends BaseActivity {
  final String searchQuery;

  SolutionBiddingScreen({this.searchQuery});

  @override
  _SolutionBiddingScreenState createState() => _SolutionBiddingScreenState();
}

class _SolutionBiddingScreenState extends BaseState<SolutionBiddingScreen>
    with TickerProviderStateMixin {
  List<CatalogueData> _catalogues;
  Function onViewMoreTap;
  TextEditingController _facilitySearchController, _locationSearchController;
  Timer _debounce;
  SearchSolutionBloc _searchSolutionBloc;
  int pageIndex = SearchSolutionBloc.initialIndex;
  StreamController _streamController;
  bool _endReached, _isHospitalSelected;
  FocusNode _facilityFocusNode, _locationFocusNode;
  int _selectedIndex = 0;
  List<Widget> _tabs = [
    ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      child: Container(
          child: Text(
        'Hospital',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
    ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      child: Container(
          child: Text(
        "Treatment",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
  ];

  @override
  void initState() {
    _catalogues = [];
    _endReached = false;
    _selectedIndex = 0;
    _isHospitalSelected = false;
    _facilityFocusNode = FocusNode();
    _locationFocusNode = FocusNode();
    _searchSolutionBloc = SearchSolutionBloc();
    _streamController = StreamController.broadcast();
    _locationSearchController = TextEditingController();
    _facilitySearchController = TextEditingController()..addListener(_onSearch);
    if (widget.searchQuery != null && widget.searchQuery.trim().isNotEmpty) {
      _facilitySearchController.text = widget.searchQuery;
    }
    super.initState();
  }

  @override
  void dispose() {
    _facilitySearchController?.removeListener(_onSearch);
    _facilitySearchController?.dispose();
    _locationSearchController?.dispose();
    _debounce?.cancel();
    _searchSolutionBloc?.dispose();
    _streamController?.close();
    _locationFocusNode?.dispose();
    _facilityFocusNode?.dispose();
    super.dispose();
  }

  _unFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: WillPopScope(
        onWillPop: () async {
          _unFocus();
          return true;
        },
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: PlunesColors.WHITECOLOR,
          appBar: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              brightness: Brightness.light,
              iconTheme: IconThemeData(color: Colors.black),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  _unFocus();
                  Future.delayed(Duration(milliseconds: 5)).then((value) {
                    Navigator.pop(context, false);
                  });
                },
              ),
              title: widget.createTextViews(PlunesStrings.solutionSearched, 18,
                  colorsFile.black, TextAlign.center, FontWeight.w500)),
          body: Builder(builder: (context) {
            return Container(
              color: Color(CommonMethods.getColorHexFromStr("#FAFAFA")),
              padding: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 3),
              width: double.infinity,
              child: _showBody(),
            );
          }),
        ),
      ),
    );
  }

  Widget _showBody() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              color: Color(CommonMethods.getColorHexFromStr("#FAFAFA")),
              child: Column(
                children: [
                  _getToggleForHospitalAndService(),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 3),
                    child: _getLocationSearchBar(
                        searchController: _locationSearchController,
                        hintText: "Search location",
                        focusNode: _locationFocusNode,
                        isRounded: false),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3),
                    child: StreamBuilder(
                      builder: (context, snapShot) {
                        return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 3),
                            child: _facilitySearchBar(
                                hintText: _isHospitalSelected
                                    ? "Search Hospitals, Doctors & Labs"
                                    : "Search Disease, Test or Medical Procedure",
                                hasFocus: true,
                                focusNode: _facilityFocusNode,
                                searchController: _facilitySearchController));
                      },
                      stream: _streamController.stream,
                    ),
                  )
                ],
              ),
            ),
            (_locationFocusNode != null && _locationFocusNode.hasFocus)
                ? Expanded(child: _getLocationSearchBarAndRelatedResults())
                : Expanded(
                    child: StreamBuilder<Object>(
                        stream: _streamController.stream,
                        builder: (context, snapshot) {
                          return _getFacilitySearchBarAndRelatedResult();
                        }))
          ],
        ),
        // Positioned(
        //   child: StreamBuilder<Object>(
        //       stream: _streamController.stream,
        //       builder: (context, snapshot) {
        //         if ((_facilitySearchController != null &&
        //             _facilitySearchController.text != null &&
        //             _facilitySearchController.text.trim().isNotEmpty &&
        //             _catalogues != null &&
        //             _catalogues.isNotEmpty)) {
        //           return _getManualBiddingWidget();
        //         }
        //         return Container();
        //       }),
        //   bottom: 0.0,
        //   right: 0,
        //   left: 0,
        // )
      ],
    );
  }

  _onSolutionItemTap(int index) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var nowTime = DateTime.now();
    if (_catalogues[index].solutionExpiredAt != null &&
        _catalogues[index].solutionExpiredAt != 0) {
      var solExpireTime = DateTime.fromMillisecondsSinceEpoch(
          _catalogues[index].solutionExpiredAt);
      var diff = nowTime.difference(solExpireTime);
      if (diff.inSeconds < 5) {
        ///when price discovered and solution is active
        if (_catalogues[index].priceDiscovered != null &&
            _catalogues[index].priceDiscovered) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SolutionShowPriceScreen(
                      catalogueData: _catalogues[index], searchQuery: "")));
          return;
        } else {
          ///when price not discovered but solution is active
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewSolutionsScreen(
                      catalogueData: _catalogues[index], searchQuery: "")));
          return;
        }
      }
    }
    if (!UserManager().getIsUserInServiceLocation()) {
      await showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets().fetchLocationPopUp(context);
          },
          barrierDismissible: false);
      if (!UserManager().getIsUserInServiceLocation()) {
        return;
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterAdditionalUserDetailScr(
                _catalogues[index], _facilitySearchController.text.trim())));
  }

  _onViewMoreTap(int solution) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
        catalogueData: _catalogues[solution],
      ),
    );
  }

  _onSearch() {
    _streamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_facilitySearchController != null &&
          _facilitySearchController.text != null &&
          _facilitySearchController.text.trim().isNotEmpty) {
        _searchSolutionBloc.addIntoStream(RequestInProgress());
        _searchSolutionBloc.getSearchedSolution(
            searchedString: _facilitySearchController.text.trim().toString(),
            index: 0);
      } else {
        _catalogues = [];
        _searchSolutionBloc.addState(null);
      }
    });
  }

  Widget _showSearchedItems() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollState) {
        if (scrollState is ScrollEndNotification &&
            scrollState.metrics.extentAfter == 0 &&
            _facilitySearchController.text.trim().isNotEmpty &&
            !_endReached) {
          _searchSolutionBloc.addIntoStream(RequestInProgress());
          _searchSolutionBloc.getSearchedSolution(
              searchedString: _facilitySearchController.text.trim().toString(),
              index: pageIndex);
        }
        return;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (_catalogues.length == index) {
            return _getManualBiddingWidget();
          }
          TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
            ..onTap = () => _onViewMoreTap(index);
          return CustomWidgets().getSolutionRow(_catalogues, index,
              onButtonTap: () => _onSolutionItemTap(index),
              onViewMoreTap: tapRecognizer);
        },
        shrinkWrap: true,
        itemCount: _catalogues.length + 1,
      ),
    );
  }

  Widget _getDefaultWidget(AsyncSnapshot<RequestState> snapshot) {
    return snapshot.data is RequestInProgress
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SpinKitThreeBounce(
                  color: Color(hexColorCode.defaultGreen), size: 30.0),
              Expanded(child: Container())
            ],
          )
        : ((_catalogues == null || _catalogues.isEmpty) &&
                _facilitySearchController.text.trim().isNotEmpty)
            ? _getManualBiddingWidget()
            : Text(PlunesStrings.searchSolutions);
  }

  Widget _getManualBiddingWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                PlunesStrings.couldNotFindText,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 17.5,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ),
            color: Color(CommonMethods.getColorHexFromStr("#D8F1E2")),
            padding: EdgeInsets.all(10),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManualBidding()));
            },
            child: Container(
              child: Center(
                child: Text(
                  PlunesStrings.negotiateManually,
                  style: TextStyle(
                      color: PlunesColors.SPARKLINGGREEN,
                      fontSize: 17.5,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
              color: PlunesColors.WHITECOLOR,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLocationSearchBarAndRelatedResults() {
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin:
                    EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2.8),
                child: Container(
                    color: Colors.white, child: _getPopularCitiesListWidget()),
              ),
              Container(
                height: 3,
                width: double.infinity,
                color: Color(CommonMethods.getColorHexFromStr("#7070701F")),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: AppConfig.horizontalBlockSize * 2.8, top: 10),
                child: _getOtherLocationListWidget(),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget _facilitySearchBar(
      {@required final TextEditingController searchController,
      @required final String hintText,
      bool hasFocus = false,
      FocusNode focusNode,
      double searchBarHeight = 6}) {
    return StatefulBuilder(builder: (context, newState) {
      return Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: (focusNode != null && focusNode.hasFocus)
                    ? Color(CommonMethods.getColorHexFromStr("#1492E6"))
                    : Color(CommonMethods.getColorHexFromStr("#CCCCCC")),
                width: 1)),
        child: Container(
          height: AppConfig.verticalBlockSize * searchBarHeight,
          padding: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 4,
              right: AppConfig.horizontalBlockSize * 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.only(right: AppConfig.horizontalBlockSize * 4),
                child: Image.asset(
                  PlunesImages.searchIcon,
                  color: (focusNode != null && focusNode.hasFocus)
                      ? Color(CommonMethods.getColorHexFromStr("#1492E6"))
                      : Color(CommonMethods.getColorHexFromStr("#CCCCCC")),
                  width: AppConfig.verticalBlockSize * 2.0,
                  height: AppConfig.verticalBlockSize * 2.0,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  focusNode: focusNode,
                  autofocus: hasFocus,
                  onTap: () {
                    _locationFocusNode?.unfocus();
                    if (focusNode != null && !focusNode.hasFocus) {
                      FocusScope.of(context).requestFocus(focusNode);
                      _setState();
                    }
                  },
                  maxLines: 1,
                  style: TextStyle(
                      color: PlunesColors.BLACKCOLOR,
                      fontSize: AppConfig.mediumFont),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#B1B1B1")),
                          fontSize: 13)),
                ),
              ),
              searchController.text.trim().isEmpty
                  ? Container()
                  : InkWell(
                      onTap: () {
                        searchController.text = "";
                        newState(() {});
                      },
                      child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.clear,
                            color: Colors.green,
                          )),
                    )
            ],
          ),
        ),
      );
    });
  }

  Future<RequestState> _getLocationStatusForTop() async {
    RequestState _requestState;
    var user = UserManager().getUserDetails();
    if (user?.latitude != null &&
        user?.longitude != null &&
        user.latitude.isNotEmpty &&
        user.longitude.isNotEmpty &&
        user.latitude != "0.0" &&
        user.latitude != "0" &&
        user.longitude != "0.0" &&
        user.longitude != "0") {
      String address = await LocationUtil()
          .getAddressFromLatLong(user.latitude, user.longitude);
      _requestState = RequestSuccess(
          response: LocationAppBarModel(
              address: (address != null &&
                      address == PlunesStrings.enterYourLocation)
                  ? "Search location"
                  : address,
              hasLocation: (address != null &&
                      address == PlunesStrings.enterYourLocation)
                  ? false
                  : true));
    } else {
      _requestState = RequestSuccess(
          response: LocationAppBarModel(
              address: "Search location", hasLocation: false));
    }
    return _requestState;
  }

  Widget _getLocationSearchBar(
      {@required final TextEditingController searchController,
      @required final String hintText,
      bool hasFocus = false,
      isRounded = true,
      FocusNode focusNode,
      double searchBarHeight = 6}) {
    return FutureBuilder<RequestState>(
      builder: (context, snapshot) {
        LocationAppBarModel locationModel;
        if (snapshot.data is RequestSuccess) {
          RequestSuccess reqSuccess = snapshot.data;
          locationModel = reqSuccess.response;
        }
        return Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color: (focusNode != null && focusNode.hasFocus)
                      ? Color(CommonMethods.getColorHexFromStr("#1492E6"))
                      : Color(CommonMethods.getColorHexFromStr("#CCCCCC")),
                  width: 1)),
          child: Container(
            height: AppConfig.verticalBlockSize * searchBarHeight,
            padding: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 4,
                right: AppConfig.horizontalBlockSize * 4),
            child: InkWell(
              onTap: () {
                _facilityFocusNode?.unfocus();
                if (focusNode != null && !focusNode.hasFocus) {
                  FocusScope.of(context).requestFocus(focusNode);
                  _setState();
                } else if (focusNode != null && focusNode.hasFocus) {
                  _getLocationFromUtil();
                  return;
                }
              },
              onDoubleTap: () {},
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.add_location_rounded,
                      color: (focusNode != null && focusNode.hasFocus)
                          ? Color(CommonMethods.getColorHexFromStr("#1492E6"))
                          : Color(CommonMethods.getColorHexFromStr("#CCCCCC")),
                    ),
                    width: AppConfig.verticalBlockSize * 2.0,
                    height: AppConfig.verticalBlockSize * 2.0,
                    margin: EdgeInsets.only(
                        right: AppConfig.horizontalBlockSize * 4),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      ignoring: true,
                      child: TextField(
                        controller: searchController,
                        focusNode: focusNode,
                        autofocus: hasFocus,
                        maxLines: 1,
                        readOnly: true,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: AppConfig.mediumFont),
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                        decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: locationModel?.address ?? hintText,
                            hintStyle: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#B1B1B1")),
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      future: _getLocationStatusForTop(),
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getFacilitySearchBarAndRelatedResult() {
    return _facilitySearchController.text.trim().isEmpty
        ? _getFacilitySuggestionWidget()
        : _getSearchedResultWidget();
  }

  Widget _getPopularCitiesListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            "Popular cities",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
          ),
        ),
        Container(
          height: 110,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {},
                  onDoubleTap: () {},
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Container(
                          height: 60,
                          width: 95,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            child: CustomWidgets().getImageFromUrl(
                                "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
                                boxFit: BoxFit.fill),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                          "Location",
                          style: TextStyle(
                              fontSize: 16, color: PlunesColors.BLACKCOLOR),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: 5,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _getPopularServicesWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            "Popular services",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
          ),
        ),
        Container(
          height: 110,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {},
                  onDoubleTap: () {},
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Container(
                          height: 60,
                          width: 95,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            child: CustomWidgets().getImageFromUrl(
                                "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
                                boxFit: BoxFit.fill),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                          "Service",
                          style: TextStyle(
                              fontSize: 16, color: PlunesColors.BLACKCOLOR),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: 5,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _getOtherLocationListWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Other locations",
          style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
        ),
        Flexible(
            child: Container(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _onLocationSelection();
                  return;
                },
                onDoubleTap: () {},
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  margin: EdgeInsets.only(bottom: 2, top: index == 0 ? 5 : 0),
                  child: Text(
                    "City name",
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
                  ),
                ),
              );
            },
            itemCount: 30,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
        ))
      ],
    );
  }

  Widget _getOtherServicesListWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Other services",
          style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
        ),
        Flexible(
            child: Container(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _onServiceSelection();
                  return;
                },
                onDoubleTap: () {},
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  margin: EdgeInsets.only(bottom: 2, top: index == 0 ? 5 : 0),
                  child: Text(
                    "service name",
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
                  ),
                ),
              );
            },
            itemCount: 30,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
        ))
      ],
    );
  }

  void _onLocationSelection() {}

  Widget _getSearchedResultWidget() {
    return Container(
      child: Column(
        children: [
          widget.getSpacer(
              AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
          widget.getSpacer(
              AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
          Expanded(
              child: StreamBuilder<RequestState>(
            builder: (context, snapShot) {
              _streamController?.add(null);
              if (snapShot.data is RequestSuccess) {
                RequestSuccess _requestSuccessObject = snapShot.data;
                if (_requestSuccessObject.requestCode ==
                    SearchSolutionBloc.initialIndex) {
                  pageIndex = SearchSolutionBloc.initialIndex;
                  _catalogues = [];
                }
                if (_requestSuccessObject.requestCode !=
                        SearchSolutionBloc.initialIndex &&
                    _requestSuccessObject.response.isEmpty) {
                  _endReached = true;
                } else {
                  _endReached = false;
                  Set _allItems = _catalogues.toSet();
                  _allItems.addAll(_requestSuccessObject.response);
                  _catalogues = _allItems.toList(growable: true);
                }
                pageIndex++;
              } else if (snapShot.data is RequestFailed) {
                pageIndex = SearchSolutionBloc.initialIndex;
              }
              return _catalogues == null || _catalogues.isEmpty
                  ? _getDefaultWidget(snapShot)
                  : Column(
                      children: <Widget>[
                        Expanded(
                          child: _showSearchedItems(),
                          flex: 4,
                        ),
                        (snapShot.data is RequestInProgress &&
                                (_catalogues != null && _catalogues.isNotEmpty))
                            ? Expanded(
                                child: CustomWidgets().getProgressIndicator(),
                                flex: 1)
                            : Container()
                      ],
                    );
            },
            stream: _searchSolutionBloc.baseStream,
          ))
        ],
      ),
    );
  }

  Widget _getFacilitySuggestionWidget() {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2.8),
          child: Container(
              color: Colors.white, child: _getPopularServicesWidget()),
        ),
        Container(
          height: 3,
          width: double.infinity,
          color: Color(CommonMethods.getColorHexFromStr("#7070701F")),
        ),
        Container(
          margin: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 2.8, top: 10),
          child: _getOtherServicesListWidget(),
        ),
      ],
    );
  }

  void _onServiceSelection() {}

  void _getLocationFromUtil() async {
    showDialog(
            context: context,
            builder: (context) {
              return CustomWidgets()
                  .fetchLocationPopUp(context, isCalledFromHomeScreen: true);
            },
            barrierDismissible: false)
        .then((value) {
      _setState();
      if (UserManager().getIsUserInServiceLocation()) {
        _locationFocusNode?.unfocus();
        if (_facilityFocusNode != null && !_facilityFocusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_facilityFocusNode);
          _setState();
        }
      }
    });
  }

  Widget _getToggleForHospitalAndService() {
    return Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 15),
        child: Card(
          margin: EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(7)),
                border: Border.all(
                    color: CommonMethods.getColorForSpecifiedCode("#289486"),
                    width: 1)),
            alignment: Alignment.center,
            child: TabBar(
              unselectedLabelColor: Colors.black,
              isScrollable: false,
              labelColor: Colors.white,
              labelPadding: EdgeInsets.symmetric(vertical: 8),
              controller: TabController(
                length: 2,
                vsync: this,
                initialIndex: _selectedIndex,
              ),
              indicator: new BubbleTabIndicator(
                indicatorHeight: 35.0,
                indicatorRadius: 7,
                indicatorColor:
                    CommonMethods.getColorForSpecifiedCode("#289486"),
                tabBarIndicatorSize: TabBarIndicatorSize.label,
              ),
              onTap: (i) {
                _selectedIndex = i;
                if (_selectedIndex == 0) {
                  _isHospitalSelected = true;
                } else {
                  _isHospitalSelected = false;
                }
                _setState();
              },
              tabs: _tabs,
            ),
          ),
        ));
  }
}
