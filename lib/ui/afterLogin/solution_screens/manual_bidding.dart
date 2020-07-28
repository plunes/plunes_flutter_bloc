import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';

// ignore: must_be_immutable
class ManualBidding extends BaseActivity {
  @override
  _ManualBiddingState createState() => _ManualBiddingState();
}

class _ManualBiddingState extends BaseState<ManualBidding> {
  TextEditingController _textEditingController, _searchController;
  List<MoreFacility> _catalogues, _selectedItemList;
  StreamController _streamController,
      _selectUnselectController,
      _queryStreamController;
  int pageIndex = SearchSolutionBloc.initialIndex;
  bool _endReached;
  String _failureCause;
  SearchSolutionBloc _searchSolutionBloc;
  Timer _debounce;
  LatLng _selectedLoc;
  String _location = PlunesStrings.enterYourLocation;

  User _userObj;

  @override
  void initState() {
    _userObj = UserManager().getUserDetails();
    _getRegion();
    _searchSolutionBloc = SearchSolutionBloc();
    _catalogues = [];
    _selectedItemList = [];
    _searchController = TextEditingController()..addListener(_onSearch);
    _textEditingController = TextEditingController();
    _streamController = StreamController.broadcast();
    _queryStreamController = StreamController.broadcast();
    _selectUnselectController = StreamController.broadcast();
    _endReached = false;
    _getMoreFacilities();
    super.initState();
  }

  _getMoreFacilities() {
    _searchSolutionBloc.getFacilitiesForManualBidding(
        searchQuery: _searchController.text.trim().toString(),
        pageIndex: pageIndex,
        latLng: _selectedLoc);
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _searchController?.dispose();
    _streamController?.close();
    _queryStreamController?.close();
    _searchSolutionBloc?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: _getAppBar(),
        body: Builder(builder: (context) {
          return StreamBuilder<RequestState>(
              stream: _searchSolutionBloc.getManualBiddingAdditionStream(),
              builder: (context, snapshot) {
                if (snapshot.data is RequestInProgress) {
                  return CustomWidgets().getProgressIndicator();
                } else if (snapshot.data is RequestSuccess) {
                  Future.delayed(Duration(milliseconds: 10)).then((value) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CustomWidgets()
                              .getManualBiddingSuccessWidget(scaffoldKey);
                        }).then((value) {
                      Navigator.pop(context);
                    });
                  });
                } else if (snapshot.data is RequestFailed) {
                  RequestFailed requestFailed = snapshot.data;
                  Future.delayed(Duration(milliseconds: 10)).then((value) {
                    _showInSnackBar(requestFailed?.failureCause ??
                        plunesStrings.somethingWentWrong);
                  });
                  _searchSolutionBloc
                      .addStateInManualBiddingAdditionStream(null);
                }
                return _getBody();
              });
        }),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget _getBody() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black12.withOpacity(0.000001),
          image: DecorationImage(
              image: ExactAssetImage(PlunesImages.userLandingImage),
              fit: BoxFit.fill,
              alignment: Alignment.center)),
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 4),
        child: Stack(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                _getTextFiledWidget(),
                Container(
                  margin: EdgeInsets.only(
                    top: AppConfig.verticalBlockSize * 2.5,
                    left: AppConfig.verticalBlockSize * 3,
                    right: AppConfig.verticalBlockSize * 3,
                    bottom: AppConfig.verticalBlockSize * 2,
                  ),
                  child: Center(
                    child: Text(
                      PlunesStrings.chooseUptoText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontWeight: FontWeight.normal,
                          fontSize: 18),
                    ),
                  ),
                ),
                StreamBuilder<Object>(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      return _getSearchBar();
                    }),
                _getSelectedItems(),
                StreamBuilder<RequestState>(
                    stream: _searchSolutionBloc.getManualBiddingStream(),
                    initialData: (_catalogues == null || _catalogues.isEmpty)
                        ? RequestInProgress()
                        : null,
                    builder: (context, snapShot) {
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
                        _selectedItemList.forEach((selectedItem) {
                          if (_catalogues.contains(selectedItem)) {
                            _catalogues.remove(selectedItem);
                          }
                        });
                        pageIndex++;
                        _searchSolutionBloc.addStateInManualBiddingStream(null);
                      } else if (snapShot.data is RequestFailed) {
                        RequestFailed _requestFailed = snapShot.data;
                        pageIndex = SearchSolutionBloc.initialIndex;
                        _failureCause = _requestFailed.failureCause;
                        _searchSolutionBloc.addStateInManualBiddingStream(null);
                      }
                      return (_catalogues == null || _catalogues.isEmpty)
                          ? _getDefaultWidget(snapShot)
                          : _showResultsFromBackend(snapShot);
                    }),
              ],
            ),
            Positioned(
              child: _getSubmitButton(),
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
            )
          ],
        ),
      ),
    );
  }

  Widget _getTextFiledWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
                minHeight: AppConfig.verticalBlockSize * 3,
                maxHeight: AppConfig.verticalBlockSize * 44,
                minWidth: double.infinity,
                maxWidth: double.infinity),
            child: Row(
              children: <Widget>[
                Flexible(
                    child: TextField(
                  controller: _textEditingController,
                  onChanged: (data) {
                    _queryStreamController.add(null);
                  },
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: PlunesColors.BLACKCOLOR),
                  decoration: InputDecoration(
                    labelText: PlunesStrings.enterProcedureAndTestDetails,
                    hintText: PlunesStrings.enterProcedureAndTestDetails,
                    hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: PlunesColors.GREYCOLOR),
                  ),
                  maxLines: null,
                  maxLength: 400,
                ))
              ],
            ),
          ),
          Container(
            margin:
                EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1),
            child: Center(
              child: Text(
                PlunesStrings.makeSureTheDetailsText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return CustomWidgets().searchBar(
        searchController: _searchController,
        hintText: PlunesStrings.searchFacilities,
        onTextClear: () => _onTextClear());
  }

  Widget _showResultsFromBackend(AsyncSnapshot<RequestState> snapShot) {
    return Container(
        constraints: BoxConstraints(
            minHeight: AppConfig.verticalBlockSize * 30,
            minWidth: double.infinity,
            maxWidth: double.infinity,
            maxHeight: AppConfig.verticalBlockSize * 65),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                PlunesStrings.chooseFacilities,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollState) {
                  if (scrollState is ScrollEndNotification &&
                      scrollState.metrics.extentAfter == 0 &&
                      !_endReached) {
                    _getMoreFacilities();
                  }
                  return;
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                          bottom: (_catalogues != null &&
                                  _catalogues.isNotEmpty &&
                                  (index == _catalogues.length - 1))
                              ? AppConfig.verticalBlockSize * 16
                              : 0),
                      child: CustomWidgets().getMoreFacilityWidget(
                          _catalogues, index,
                          onTap: () => _addRemoveFacilities(_catalogues[index],
                              shouldAdd: true),
                          onProfileTap: () => _viewProfile(_catalogues[index])),
                    );
                  },
                  shrinkWrap: true,
                  itemCount: _catalogues?.length ?? 0,
                ),
              ),
            ),
            (snapShot.data is RequestInProgress &&
                    (_catalogues != null && _catalogues.isNotEmpty))
                ? CustomWidgets().getProgressIndicator()
                : Container()
          ],
        ));
  }

  _onTextClear() {
    _catalogues = [];
    pageIndex = SearchSolutionBloc.initialIndex;
    _getMoreFacilities();
  }

  _viewProfile(MoreFacility service) {
    if (service.userType != null && service.professionalId != null) {
      Widget route;
      if (service.userType.toLowerCase() ==
          Constants.doctor.toString().toLowerCase()) {
        route = DocProfile(userId: service.professionalId);
      } else {
        route = HospitalProfile(userID: service.professionalId);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    }
  }

  _addRemoveFacilities(MoreFacility facility, {bool shouldAdd = false}) {
    if (shouldAdd &&
        _selectedItemList != null &&
        _selectedItemList.length >= 5) {
      _showInSnackBar("Can't select more than 5 facilities");
      return;
    }
//    if (_selectedItemList.contains(facility) && shouldAdd) {
//      _showInSnackBar("Facility already selected");
//      return;
//    }
    if (_selectedItemList.contains(facility)) {
      _selectedItemList.remove(facility);
      if (_catalogues != null &&
          _catalogues.isNotEmpty &&
          _searchController.text.trim().isEmpty) {
        _catalogues.insert(0, facility);
      }
    } else {
      _selectedItemList.add(facility);
      _catalogues.remove(facility);
    }
    _selectUnselectController.add(null);
    _searchSolutionBloc.addStateInManualBiddingStream(null);
  }

  void _showInSnackBar(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }

  Widget _getDefaultWidget(AsyncSnapshot<RequestState> snapShot) {
    return Container(
      constraints: BoxConstraints(
          minHeight: AppConfig.verticalBlockSize * 30,
          minWidth: double.infinity,
          maxWidth: double.infinity,
          maxHeight: AppConfig.verticalBlockSize * 55),
      child: Column(
        children: <Widget>[
          (snapShot.data is RequestInProgress &&
                  (_catalogues == null || _catalogues.isEmpty))
              ? Expanded(
                  child: CustomWidgets().getProgressIndicator(),
                )
              : Expanded(
                  child: CustomWidgets()
                      .errorWidget(_failureCause ?? "Facilities not available"))
        ],
      ),
    );
  }

  Widget _getSelectedItems() {
    return StreamBuilder<Object>(
        stream: _selectUnselectController.stream,
        builder: (context, snapshot) {
          if (_selectedItemList == null || _selectedItemList.isEmpty) {
            return Container();
          }
          return Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    minHeight: AppConfig.verticalBlockSize * 5,
                    minWidth: double.infinity,
                    maxWidth: double.infinity,
                    maxHeight: AppConfig.verticalBlockSize * 100),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CustomWidgets().getMoreFacilityWidget(
                        _selectedItemList, index,
                        isSelected: true,
                        onTap: () =>
                            _addRemoveFacilities(_selectedItemList[index]),
                        onProfileTap: () => _viewProfile(_catalogues[index]));
                  },
                  shrinkWrap: true,
                  itemCount: _selectedItemList?.length ?? 0,
                ),
              ),
            ],
          );
        });
  }

  _onSearch() {
    _streamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController != null &&
          _searchController.text != null &&
          _searchController.text.trim().isNotEmpty) {
        _catalogues = [];
        _searchSolutionBloc.getFacilitiesForManualBidding(
            searchQuery: _searchController.text.trim().toString(),
            pageIndex: SearchSolutionBloc.initialIndex,
            latLng: _selectedLoc);
      } else {
        _onTextClear();
      }
    });
  }

  Widget _getSubmitButton() {
    return StreamBuilder<Object>(
        stream: _queryStreamController.stream,
        builder: (context, snapshot) {
          return Container(
            child: StreamBuilder<Object>(
                stream: _selectUnselectController.stream,
                builder: (context, snapshot) {
                  if (_textEditingController != null &&
                      _textEditingController.text.trim().isNotEmpty &&
                      _selectedItemList != null &&
                      _selectedItemList.isNotEmpty) {
                    return InkWell(
                      onTap: () {
                        _searchSolutionBloc.saveManualBiddingData(
                            _textEditingController.text.trim(),
                            _selectedItemList);
                        return;
                      },
                      child: Container(
                        color:
                            Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            plunesStrings.submit,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: PlunesColors.SPARKLINGGREEN,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    );
                  }
                  return Container();
                }),
          );
        });
  }

  _getLocation() {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LocationFetch(shouldSaveLocation: false)))
        .then((val) {
      if (val != null) {
        var addressControllerList = new List();
        addressControllerList = val.toString().split(":");
        String addr = addressControllerList[0] +
            ' ' +
            addressControllerList[1] +
            ' ' +
            addressControllerList[2];
//                          print("addr is $addr");
        var _latitude = addressControllerList[3];
        var _longitude = addressControllerList[4];
        String region = addr;
        if (addressControllerList.length == 6 &&
            addressControllerList[5] != null) {
          region = addressControllerList[5];
        }
        _location = region;
        _setState();
        _selectedLoc =
            LatLng(double.tryParse(_latitude), double.tryParse(_longitude));
//        print("_latitude $_latitude");
//        print("_longitude $_longitude");
        pageIndex = SearchSolutionBloc.initialIndex;
        _catalogues = [];
        _getMoreFacilities();
      }
    });
  }

  _getAppBar() {
    return PreferredSize(
        child: Card(
            color: Colors.white,
            elevation: 3.0,
            margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(AppConfig.verticalBlockSize * 0.5),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                        return;
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: PlunesColors.BLACKCOLOR,
                      ),
                    )),
                Text(
                  PlunesStrings.negotiateManually,
                  textAlign: TextAlign.start,
                  style:
                      TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
                ),
                Flexible(
                  child: InkWell(
                    onTap: () => _getLocation(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 2.0, right: 3.0, top: 2.0, bottom: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(2),
                            child: Image.asset(plunesImages.locationIcon),
                            height: AppConfig.verticalBlockSize * 3.5,
                            width: AppConfig.horizontalBlockSize * 6,
                          ),
                          Flexible(
                              child: FittedBox(
                            child: Text(
                              _location ?? PlunesStrings.enterYourLocation,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                                decorationThickness: 2.0,
                              ),
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
        preferredSize: Size(double.infinity, AppConfig.verticalBlockSize * 10));
  }

  _setState() {
    if (mounted) setState(() {});
  }

  void _getRegion() {
    if (_userObj.latitude == null ||
        _userObj.longitude == null ||
        _userObj.latitude.isEmpty ||
        _userObj.longitude.isEmpty ||
        _userObj.latitude == '0.0' ||
        _userObj.longitude == '0.0') {
      _location = PlunesStrings.enterYourLocation;
      _setState();
    } else {
      LocationUtil()
          .getAddressFromLatLong(_userObj.latitude, _userObj.longitude)
          .then((value) {
        _location = value;
        _setState();
      });
    }
  }
}
