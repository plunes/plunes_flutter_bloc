import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/choose_more_facilities_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_map_screen.dart';
import '../../widgets/dialogPopScreen.dart';

// ignore: must_be_immutable
class SolutionReceivedScreen extends BaseActivity {
  final CatalogueData catalogueData;
  final String searchQuery;
  final SearchedDocResults searchedDocResults;

  SolutionReceivedScreen(
      {this.catalogueData, this.searchQuery, this.searchedDocResults});

  @override
  _SolutionReceivedScreenState createState() => _SolutionReceivedScreenState();
}

class _SolutionReceivedScreenState extends BaseState<SolutionReceivedScreen> {
  Timer _timer, _timerToUpdateSolutionReceivedTime, _discountCalculationTimer;
  SearchSolutionBloc _searchSolutionBloc;
  SearchedDocResults _searchedDocResults;
  DocHosSolution _solution;
  BuildContext _buildContext;
  bool _isFetchingInitialData;
  String _failureCause;
  int _solutionReceivedTime = 0;
  bool _shouldStartTimer, _isCrossClicked;
  StreamController _streamForTimer,
      _docExpandCollapseController,
      _totalDiscountController;
  TextEditingController _searchController;
  FocusNode _focusNode;
  final double lat = 28.4594965, long = 77.0266383;
  Set<Services> _services = {};
  num _gainedDiscount = 0;

  @override
  void initState() {
    _isCrossClicked = false;
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          Navigator.pop(context, true);
        }
      });
    _searchController = TextEditingController();
    _shouldStartTimer = false;
    _streamForTimer = StreamController.broadcast();
    _docExpandCollapseController = StreamController.broadcast();
    _totalDiscountController = StreamController.broadcast();
    _timerToUpdateSolutionReceivedTime =
        Timer.periodic(Duration(seconds: 1), (timer) {
      _timerToUpdateSolutionReceivedTime = timer;
      _streamForTimer.add(null);
    });
    _discountCalculationTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      _discountCalculationTimer = timer;
      _getDiscountAsync();
    });
    _solutionReceivedTime = DateTime.now().millisecondsSinceEpoch;
    _isFetchingInitialData = true;
    _searchSolutionBloc = SearchSolutionBloc();
    if (widget.searchedDocResults != null) {
      _searchedDocResults = widget.searchedDocResults;
    }
    if (_searchedDocResults != null &&
        _searchedDocResults.solution != null &&
        _searchedDocResults.solution.services != null &&
        _searchedDocResults.solution.services.isNotEmpty) {
      _isFetchingInitialData = false;
      _checkShouldTimerRun();
    } else if (_searchedDocResults != null &&
        _searchedDocResults.msg != null &&
        _searchedDocResults.msg.isNotEmpty) {
      _failureCause = _searchedDocResults.msg;
    }
    _fetchResultAndStartTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamForTimer?.close();
    _timerToUpdateSolutionReceivedTime?.cancel();
    _searchController?.dispose();
    _focusNode?.dispose();
    _searchSolutionBloc?.dispose();
    _docExpandCollapseController?.close();
    _totalDiscountController?.close();
    _discountCalculationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
              child: Card(
                  color: Colors.white,
                  elevation: 3.0,
                  margin: EdgeInsets.only(
                      top: AppConfig.getMediaQuery().padding.top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          padding:
                              EdgeInsets.all(AppConfig.verticalBlockSize * 2),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            PlunesStrings.negotiatedSolutions,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 16),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                PlunesImages.validForOneHourOnlyWatch,
                                scale: 3,
                              ),
                              Padding(
                                child: Text(
                                  PlunesStrings.validForOneHour,
                                  style: TextStyle(
                                      color: PlunesColors.GREYCOLOR,
                                      fontSize: 16),
                                ),
                                padding: EdgeInsets.only(left: 4.0),
                              )
                            ],
                          )
                        ],
                      ),
                      Container(),
                      Container(),
                      Container(),
                    ],
                  )),
              preferredSize:
                  Size(double.infinity, AppConfig.verticalBlockSize * 8)),
          body: Builder(builder: (context) {
            _buildContext = context;
            return _isFetchingInitialData
                ? CustomWidgets().getProgressIndicator()
                : _searchedDocResults == null ||
                        _searchedDocResults.solution == null ||
                        _searchedDocResults.solution.services == null ||
                        _searchedDocResults.solution.services.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 8),
                        child: CustomWidgets().errorWidget(_failureCause))
                    : _showBody();
          }),
        ));
  }

  Widget _showContent() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          if (_searchedDocResults.solution.showAdditionalFacilities != null &&
              _searchedDocResults.solution.showAdditionalFacilities &&
              (_searchedDocResults.solution.services != null ||
                  _searchedDocResults.solution.services.isNotEmpty) &&
              index == _searchedDocResults.solution.services.length) {
            return _getViewMoreFacilityWidget();
          } else if (_searchedDocResults.solution.services[index].doctors !=
                  null &&
              _searchedDocResults.solution.services[index].doctors.isNotEmpty) {
            return _showHosDocCards(
                _searchedDocResults.solution.services[index]);
          }
          return CustomWidgets().getDocDetailWidget(
              _searchedDocResults.solution?.services ?? [],
              index,
              () => _checkAvailability(index),
              () => _onBookingTap(
                  _searchedDocResults.solution.services[index], index),
              _searchedDocResults.catalogueData,
              _buildContext,
              () =>
                  _viewProfile(_searchedDocResults.solution?.services[index]));
        },
        itemCount: _searchedDocResults.solution == null
            ? 0
            : _searchedDocResults.solution.services == null ||
                    _searchedDocResults.solution.services.isEmpty
                ? 0
                : (_searchedDocResults.solution.showAdditionalFacilities !=
                            null &&
                        _searchedDocResults.solution.showAdditionalFacilities)
                    ? (_searchedDocResults.solution.services.length + 1)
                    : _searchedDocResults.solution.services.length);
  }

  Widget _getViewMoreFacilityWidget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: AppConfig.horizontalBlockSize * 12,
        vertical: AppConfig.verticalBlockSize * 1,
      ),
      child: InkWell(
        onTap: () {
          if (!_canGoAhead()) {
            _showSnackBar(PlunesStrings.cantNegotiateWithMoreFacilities);
            return;
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MoreFacilityScreen(
                        searchSolutionBloc: _searchSolutionBloc,
                        docHosSolution: _searchedDocResults?.solution,
                        catalogueData: _searchedDocResults?.catalogueData,
                      ))).then((value) {
            if (value != null && value) {
              _isCrossClicked = false;
              _shouldStartTimer = true;
              _fetchResultAndStartTimer().then((value) {
                Future.delayed(Duration(seconds: 1)).then((value) {
                  _setState();
                });
              });
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Negotiate with more facilities",
                style: TextStyle(
                    color: PlunesColors.GREENCOLOR,
                    fontSize: 15,
                    fontWeight: FontWeight.normal),
              ),
              Icon(
                Icons.chevron_right,
                color: PlunesColors.GREENCOLOR,
              )
            ],
          ),
        ),
      ),
    );
  }

  _checkAvailability(int selectedIndex) {
    showDialog(
        context: context,
        builder: (BuildContext context) => DialogWidgets().buildProfileDialog(
            catalogueData: _searchedDocResults.catalogueData,
            solutions: _searchedDocResults.solution.services[selectedIndex],
            context: _buildContext));
  }

  _onBookingTap(Services service, int index) {
    if (!_canGoAhead()) {
      _showSnackBar(PlunesStrings.cantBookPriceExpired);
      return;
    }
    _solution = _searchedDocResults.solution;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingMainScreen(
                  price: service.newPrice[0].toString(),
                  profId: service.professionalId,
                  searchedSolutionServiceId: service.sId,
                  timeSlots: service.timeSlots,
                  docHosSolution: _solution,
                  bookInPrice: service.bookIn,
                  serviceIndex: 0,
                  service: service,
                ))).then((value) {
      if (value != null &&
          value.runtimeType == "pop".runtimeType &&
          value.toString() == "pop") {
        Navigator.pop(context);
      }
    });
  }

  Future<RequestState> _negotiate() async {
    var result = await _searchSolutionBloc.getDocHosSolution(
        widget.catalogueData,
        searchQuery: widget.searchQuery);
    if (_searchedDocResults != null &&
        _searchedDocResults.solution != null &&
        _searchedDocResults.solution.services != null &&
        _searchedDocResults.solution.services.isNotEmpty) {
      return result;
    }
    if (result is RequestSuccess) {
      _searchedDocResults = result.response;
      if (_searchedDocResults.solution?.services == null ||
          _searchedDocResults.solution.services.isEmpty) {
        _failureCause = PlunesStrings.oopsServiceNotAvailable;
        if (_searchedDocResults != null &&
            _searchedDocResults.msg != null &&
            _searchedDocResults.msg.isNotEmpty) {
          _failureCause = _searchedDocResults.msg;
        }
      } else {
        _checkShouldTimerRun();
      }
    } else if (result is RequestFailed) {
      _failureCause = result.failureCause;
      _timer?.cancel();
    }
    _isFetchingInitialData = false;
    _setState();
    return result;
  }

  _setState() async {
    await Future.delayed(Duration(milliseconds: 15));
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _negotiate();
    });
  }

  Widget _showBody() {
    return Container(
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              (_timer != null && _timer.isActive && !(_isCrossClicked))
                  ? _getHoldOnPopup()
                  : _getNegotiatedPriceTotalView(),
              Card(
                elevation: 4.0,
                margin: EdgeInsets.only(
                    left: AppConfig.horizontalBlockSize * 4,
                    right: AppConfig.horizontalBlockSize * 4,
                    top: AppConfig.verticalBlockSize * 1.5),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 4,
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () => _viewDetails(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.catalogueData.service ??
                                    _searchedDocResults
                                        ?.catalogueData?.service ??
                                    PlunesStrings.NA,
                                style: TextStyle(
                                    fontSize: AppConfig.mediumFont,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 1),
                                child: Text(
                                  PlunesStrings.viewDetails,
                                  style: TextStyle(
                                      fontSize: AppConfig.smallFont,
                                      color: PlunesColors.GREENCOLOR),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            alignment: Alignment.topRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                _solutionReceivedTime == null ||
                                        _solutionReceivedTime == 0
                                    ? Container()
                                    : StreamBuilder(
                                        builder: (context, snapShot) {
                                          return Text(
                                            DateUtil.getDuration(
                                                    _solutionReceivedTime) ??
                                                PlunesStrings.NA,
                                            style: TextStyle(
                                                fontSize: AppConfig.smallFont),
                                          );
                                        },
                                        stream: _streamForTimer.stream,
                                      ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SolutionMap(
                                                _searchedDocResults,
                                                widget.catalogueData))).then(
                                        (value) {
                                      if (value != null && value) {
                                        Navigator.pop(context, true);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 1),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 2,
                                          child: Container(
                                            child: Image.asset(
                                                plunesImages.locationIcon),
                                            height:
                                                AppConfig.verticalBlockSize * 3,
                                            width:
                                                AppConfig.horizontalBlockSize *
                                                    8,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 10,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 2),
                                            child: Text(
                                              PlunesStrings.viewOnMap,
                                              textAlign: TextAlign.right,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: AppConfig.smallFont,
                                                  color:
                                                      PlunesColors.GREENCOLOR),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
                color: PlunesColors.WHITECOLOR,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 4,
                      right: AppConfig.horizontalBlockSize * 4,
                      top: AppConfig.verticalBlockSize * 1.5),
                  child: StreamBuilder<RequestState>(
                    builder: (context, snapShot) {
                      if (snapShot.data is RequestSuccess) {
                        RequestSuccess _successObject = snapShot.data;
                        _searchedDocResults = _successObject.response;
                        _checkExpandedSolutions();
                        _searchSolutionBloc.addIntoDocHosStream(null);
                        _checkShouldTimerRun();
                      } else if (snapShot.data is RequestFailed) {
                        RequestFailed _failedObject = snapShot.data;
                        _failureCause = _failedObject.failureCause;
                        _searchSolutionBloc.addIntoDocHosStream(null);
                        _cancelNegotiationTimer();
                      }
                      return _showContent();
                    },
                    stream: _searchSolutionBloc.getDocHosStream(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

//  Widget _showBody() {
//    return SlidingUpPanel(
//      body: Container(
//        color: PlunesColors.WHITECOLOR,
//        padding: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
//        child: Stack(
//          children: <Widget>[
//            Column(
//              children: <Widget>[
//                (widget.catalogueData != null &&
//                        widget.catalogueData.isFromNotification != null &&
//                        widget.catalogueData.isFromNotification)
//                    ? Container()
//                    : Container(
//                        margin: EdgeInsets.symmetric(
//                            horizontal: AppConfig.horizontalBlockSize * 3,
//                            vertical: AppConfig.verticalBlockSize * 1),
//                        child: CustomWidgets().searchBar(
//                            searchController: _searchController,
//                            hintText: PlunesStrings.chooseLocation,
//                            focusNode: _focusNode,
//                            searchBarHeight: 5.5),
//                      ),
//              ],
//            ),
//          ],
//        ),
//      ),
//      maxHeight: (widget.catalogueData != null &&
//              widget.catalogueData.isFromNotification != null &&
//              widget.catalogueData.isFromNotification)
//          ? AppConfig.verticalBlockSize * 90
//          : AppConfig.verticalBlockSize * 79,
//      minHeight: (widget.catalogueData != null &&
//              widget.catalogueData.isFromNotification != null &&
//              widget.catalogueData.isFromNotification)
//          ? AppConfig.verticalBlockSize * 90
//          : AppConfig.verticalBlockSize * 79,
//      panelBuilder: (sc) {
//        return Stack(
//          children: <Widget>[
//            Column(
//              children: <Widget>[
//                Card(
//                  elevation: 4.0,
//                  margin: EdgeInsets.all(AppConfig.horizontalBlockSize * 4),
//                  child: Container(
//                    margin: EdgeInsets.symmetric(
//                        horizontal: AppConfig.horizontalBlockSize * 4,
//                        vertical: AppConfig.verticalBlockSize * 2),
//                    child: Row(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                      children: <Widget>[
//                        Expanded(
//                          flex: 2,
//                          child: InkWell(
//                            onTap: () => _viewDetails(),
//                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Text(
//                                  widget.catalogueData.service ??
//                                      _searchedDocResults
//                                          ?.catalogueData?.service ??
//                                      PlunesStrings.NA,
//                                  style: TextStyle(
//                                      fontSize: AppConfig.mediumFont,
//                                      color: PlunesColors.BLACKCOLOR,
//                                      fontWeight: FontWeight.bold),
//                                ),
//                                Padding(
//                                  padding: EdgeInsets.only(
//                                      top: AppConfig.verticalBlockSize * 1),
//                                  child: Text(
//                                    PlunesStrings.viewDetails,
//                                    style: TextStyle(
//                                        fontSize: AppConfig.smallFont,
//                                        color: PlunesColors.GREENCOLOR,
//                                        decoration: TextDecoration.underline),
//                                  ),
//                                )
//                              ],
//                            ),
//                          ),
//                        ),
//                        Expanded(
//                          child: Container(
//                              alignment: Alignment.topRight,
//                              child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.end,
//                                children: <Widget>[
//                                  _solutionReceivedTime == null ||
//                                          _solutionReceivedTime == 0
//                                      ? Container()
//                                      : StreamBuilder(
//                                          builder: (context, snapShot) {
//                                            return Text(
//                                              DateUtil.getDuration(
//                                                      _solutionReceivedTime) ??
//                                                  PlunesStrings.NA,
//                                              style: TextStyle(
//                                                  fontSize:
//                                                      AppConfig.smallFont),
//                                            );
//                                          },
//                                          stream: _streamForTimer.stream,
//                                        ),
//                                  InkWell(
//                                    onTap: () {
//                                      Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                              builder: (context) => SolutionMap(
//                                                  _searchedDocResults,
//                                                  widget.catalogueData))).then(
//                                          (value) {
//                                        if (value != null && value) {
//                                          Navigator.pop(context, true);
//                                        }
//                                      });
//                                    },
//                                    child: Padding(
//                                      padding: EdgeInsets.only(
//                                          top: AppConfig.verticalBlockSize * 1),
//                                      child: Row(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.end,
//                                        children: <Widget>[
//                                          Flexible(
//                                            flex: 2,
//                                            child: Container(
//                                              child: Image.asset(
//                                                  plunesImages.locationIcon),
//                                              height:
//                                                  AppConfig.verticalBlockSize *
//                                                      3,
//                                              width: AppConfig
//                                                      .horizontalBlockSize *
//                                                  8,
//                                            ),
//                                          ),
//                                          Flexible(
//                                            flex: 10,
//                                            child: Padding(
//                                              padding: const EdgeInsets.only(
//                                                  left: 2),
//                                              child: Text(
//                                                PlunesStrings.viewOnMap,
//                                                textAlign: TextAlign.right,
//                                                maxLines: 1,
//                                                style: TextStyle(
//                                                    fontSize:
//                                                        AppConfig.smallFont,
//                                                    color:
//                                                        PlunesColors.GREENCOLOR,
//                                                    decoration: TextDecoration
//                                                        .underline),
//                                              ),
//                                            ),
//                                          ),
//                                        ],
//                                      ),
//                                    ),
//                                  )
//                                ],
//                              )),
//                        )
//                      ],
//                    ),
//                  ),
//                  color: PlunesColors.WHITECOLOR,
//                ),
//                Expanded(
//                  child: Container(
//                    margin: EdgeInsets.symmetric(
//                        horizontal: AppConfig.horizontalBlockSize * 4,
//                        vertical: AppConfig.verticalBlockSize * 2),
//                    child: StreamBuilder<RequestState>(
//                      builder: (context, snapShot) {
//                        if (snapShot.data is RequestSuccess) {
//                          RequestSuccess _successObject = snapShot.data;
//                          _searchedDocResults = _successObject.response;
//                          _searchSolutionBloc.addIntoDocHosStream(null);
//                          _checkShouldTimerRun();
//                        } else if (snapShot.data is RequestFailed) {
//                          RequestFailed _failedObject = snapShot.data;
//                          _failureCause = _failedObject.failureCause;
//                          _searchSolutionBloc.addIntoDocHosStream(null);
//                          _cancelNegotiationTimer();
//                        }
//                        return _showContent(sc);
//                      },
//                      stream: _searchSolutionBloc.getDocHosStream(),
//                    ),
//                  ),
//                ),
//              ],
//            ),
//            (_timer != null && _timer.isActive && !(_isCrossClicked))
//                ? _getHoldOnPopup()
//                : Container(),
//          ],
//        );
//      },
//      boxShadow: null,
//    );
//  }

  _viewDetails() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
            catalogueData: _searchedDocResults?.catalogueData));
  }

  Widget _getHoldOnPopup() {
    return Container(
      margin: EdgeInsets.only(
          left: AppConfig.horizontalBlockSize * 4,
          right: AppConfig.horizontalBlockSize * 4,
          top: AppConfig.verticalBlockSize * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: PlunesColors.SPARKLINGGREEN),
              padding: EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SpinKitCircle(
                        color: Colors.white,
                        size: 50.0,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Hold on",
                                          style: TextStyle(
                                              fontSize: AppConfig.smallFont,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      Expanded(child: Container()),
                                      InkWell(
                                          onTap: () {
                                            _isCrossClicked = true;
                                            _setState();
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: PlunesColors.WHITECOLOR,
                                          ))
                                    ],
                                  )),
                                ],
                              ),
                              Container(
                                child: Text(
                                  "We are negotiating the best fee for you."
                                  "It may take upto 15 mins, we'll update you.",
                                  style: TextStyle(
                                      fontSize: AppConfig.smallFont,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _fetchResultAndStartTimer() async {
    await _negotiate();
    if (_shouldStartTimer) {
      _startTimer();
    }
    return null;
  }

  _cancelNegotiationTimer() {
    if (_searchedDocResults.solution?.services != null ||
        _searchedDocResults.solution.services.isNotEmpty) {
      _searchedDocResults.solution.services.forEach((service) {
        if (service.negotiating != null && service.negotiating) {
          service.negotiating = false;
          if (service.doctors != null && service.doctors.isNotEmpty) {
            service.doctors.forEach((doc) {
              if (doc.negotiating != null && doc.negotiating) {
                doc.negotiating = false;
              }
            });
          }
        }
      });
    }
    if (_timer != null && _timer.isActive) {
      _timer?.cancel();
    }
    _setState();
  }

  _checkShouldTimerRun() {
    if (_searchedDocResults.solution?.services == null ||
        _searchedDocResults.solution.services.isEmpty) {
      if (_timer != null && _timer.isActive) {
        _cancelNegotiationTimer();
      }
      return;
    }
    bool shouldNegotiate = false;
    _solutionReceivedTime = _searchedDocResults.solution?.createdTime ?? 0;
    _searchedDocResults.solution.services.forEach((service) {
      if (service.negotiating != null && service.negotiating) {
        shouldNegotiate = true;
      }
    });
    if (shouldNegotiate) {
      _shouldStartTimer = true;
    } else {
      if (_timer != null && _timer.isActive) {
        _cancelNegotiationTimer();
      }
    }
  }

  _viewProfile(Services service) {
    if (service.userType != null && service.professionalId != null) {
      Widget route;
      if (service.userType.toLowerCase() ==
          Constants.doctor.toString().toLowerCase()) {
        route = DocProfile(
            userId: service.professionalId,
            rating: service.rating.toStringAsFixed(1));
      } else {
        route = HospitalProfile(
          userID: service.professionalId,
          rating: service.rating.toStringAsFixed(1),
          timeSlots: service.timeSlots,
        );
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    }
  }

  Widget _showHosDocCards(Services service) {
    return Card(
      elevation: 2.5,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 1,
                  horizontal: AppConfig.horizontalBlockSize * 2.5),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Image.asset(PlunesImages.labMapImage),
                    height: AppConfig.verticalBlockSize * 6,
                    width: AppConfig.horizontalBlockSize * 12,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 3)),
                  Expanded(
                    child: Text(
                      CommonMethods.getStringInCamelCase(service?.name) ??
                          PlunesStrings.NA,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          color: PlunesColors.BLACKCOLOR,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          height: AppConfig.verticalBlockSize * 3,
                          width: AppConfig.horizontalBlockSize * 5,
                          child: Image.asset(plunesImages.locationIcon)),
                      Text(
                        "${service.distance?.toStringAsFixed(1) ?? PlunesStrings.NA}kms",
                        style: TextStyle(
                            color: PlunesColors.GREYCOLOR, fontSize: 10),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: PlunesColors.GREYCOLOR,
            ),
            StreamBuilder<Object>(
                stream: _docExpandCollapseController.stream,
                builder: (context, snapshot) {
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _hosDoc(service, index);
                    },
                    itemCount:
                        (service.isExpanded) ? service.doctors.length : 1,
                  );
                })
          ],
        ),
      ),
    );
  }

  Widget _hosDoc(Services service, int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: AppConfig.verticalBlockSize * 1.8,
          horizontal: AppConfig.horizontalBlockSize * 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _viewProfile(service);
                    },
                    onDoubleTap: () {},
                    child: (service.doctors[index].imageUrl != null &&
                            service.doctors[index].imageUrl.isNotEmpty &&
                            service.doctors[index].imageUrl.contains("http"))
                        ? CircleAvatar(
                            child: Container(
                              height: AppConfig.horizontalBlockSize * 14,
                              width: AppConfig.horizontalBlockSize * 14,
                              child: ClipOval(
                                  child: CustomWidgets().getImageFromUrl(
                                      service.doctors[index].imageUrl,
                                      boxFit: BoxFit.fill)),
                            ),
                            radius: AppConfig.horizontalBlockSize * 7,
                          )
                        : CustomWidgets().getProfileIconWithName(
                            service.doctors[index].name,
                            14,
                            14,
                          ),
                  ),
                  Container(
                    width: AppConfig.horizontalBlockSize * 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: PlunesColors.GREENCOLOR,
                        ),
                        Text(
                          service.doctors[index].rating?.toStringAsFixed(1) ??
                              PlunesStrings.NA,
                          style: TextStyle(
                              color: PlunesColors.GREYCOLOR, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: Padding(
                padding:
                    EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => _viewProfile(service),
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * .5),
                              child: Text(
                                CommonMethods.getStringInCamelCase(
                                        service.doctors[index]?.name) ??
                                    PlunesStrings.NA,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                left: AppConfig.horizontalBlockSize * 2)),
                        service.doctors[index].negotiating ?? false
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    PlunesStrings.negotiating,
                                    style: TextStyle(
                                        fontSize: AppConfig.mediumFont,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  CustomWidgets().getLinearIndicator()
                                ],
                              )
                            : InkWell(
                                onTap: () {
                                  if (!_canGoAhead()) {
                                    _showSnackBar(
                                        PlunesStrings.cantBookPriceExpired);
                                    return;
                                  }
                                  _solution = _searchedDocResults.solution;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BookingMainScreen(
                                                price: service
                                                    .doctors[index].newPrice[0]
                                                    .toString(),
                                                profId: service.professionalId,
                                                docId: service.doctors[index]
                                                    .professionalId,
                                                searchedSolutionServiceId:
                                                    service.sId,
                                                timeSlots: service
                                                    .doctors[index].timeSlots,
                                                docHosSolution: _solution,
                                                bookInPrice: service
                                                    .doctors[index].bookIn,
                                                serviceIndex: 0,
                                                service: Services(
                                                    price: service
                                                        .doctors[index].price,
                                                    newPrice: service
                                                        .doctors[index]
                                                        .newPrice,
                                                    paymentOptions:
                                                        service.paymentOptions),
                                              ))).then((value) {
                                    if (value != null &&
                                        value.runtimeType ==
                                            "pop".runtimeType &&
                                        value.toString() == "pop") {
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                                child: CustomWidgets().getRoundedButton(
                                    service.doctors[index].bookIn == null
                                        ? PlunesStrings.book
                                        : "${PlunesStrings.bookIn} ${service.doctors[index].bookIn}",
                                    AppConfig.horizontalBlockSize * 8,
                                    PlunesColors.SPARKLINGGREEN,
                                    AppConfig.horizontalBlockSize * 3,
                                    AppConfig.verticalBlockSize * 1,
                                    PlunesColors.WHITECOLOR))
                      ],
                    ),
                    Container(
                        width: double.infinity,
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                            top: AppConfig.horizontalBlockSize * 1),
                        child: (service.doctors[index] != null &&
                                service.doctors[index].experience != null &&
                                service.doctors[index].experience > 0)
                            ? Text(
                                "${service.doctors[index].experience} ${PlunesStrings.yrExp}",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: PlunesColors.GREYCOLOR,
                                ),
                              )
                            : Container()),
                    Container(
                        width: double.infinity,
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                            top: AppConfig.horizontalBlockSize * 1),
                        child: (service.doctors[index].homeCollection != null &&
                                service.doctors[index].homeCollection)
                            ? Text(
                                PlunesStrings.homeCollectionAvailable,
                                style: TextStyle(
                                  color: PlunesColors.GREYCOLOR,
                                  fontSize: 13.5,
                                ),
                              )
                            : Container()),
                    service.doctors[index].negotiating ?? false
                        ? Container()
                        : Container(
                            padding: EdgeInsets.only(
                                top: AppConfig.horizontalBlockSize * 1),
                            child: Row(
                              children: <Widget>[
                                RichText(
                                    text: TextSpan(
                                        text: (service
                                                    .doctors[index]?.price[0] ==
                                                service.doctors[index]
                                                    ?.newPrice[0])
                                            ? ""
                                            : "\u20B9${service.doctors[index].price[0]?.toStringAsFixed(0) ?? PlunesStrings.NA} ",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: PlunesColors.GREYCOLOR,
                                            decoration:
                                                TextDecoration.lineThrough),
                                        children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            " \u20B9${service.doctors[index].newPrice[0]?.toStringAsFixed(2) ?? PlunesStrings.NA}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: PlunesColors.BLACKCOLOR,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.none),
                                      )
                                    ])),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            AppConfig.horizontalBlockSize * 1)),
                                (service.doctors[index].price[0] ==
                                        service.doctors[index].newPrice[0])
                                    ? Container()
                                    : Text(
                                        (service.doctors[index].discount ==
                                                    null ||
                                                service.doctors[index]
                                                        .discount ==
                                                    0)
                                            ? ""
                                            : " ${PlunesStrings.save} \u20B9 ${(service.doctors[index].price[0] - service.doctors[index].newPrice[0])?.toStringAsFixed(0)}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: PlunesColors.GREENCOLOR),
                                      )
                              ],
                            ))
                  ],
                ),
              )),
            ],
          ),
          (service.doctors.length == 1)
              ? Container()
              : (service.isExpanded && (index == (service.doctors.length - 1)))
                  ? Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 0.5),
                      child: InkWell(
                        onTap: () {
                          service.isExpanded = !service.isExpanded;
                          if (_services.contains(service)) {
                            _services.remove(service);
                            _services.add(service);
                          }
                          _doExpandCollapse();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            "View less Doctors",
                            style: TextStyle(
                                color: PlunesColors.GREENCOLOR,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    )
                  : (!(service.isExpanded) && index == 0)
                      ? Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 0.5),
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              service.isExpanded = !service.isExpanded;
                              if (_services.contains(service)) {
                                _services.remove(service);
                                _services.add(service);
                              } else {
                                _services.add(service);
                              }
                              _doExpandCollapse();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "View more Doctors",
                                style: TextStyle(
                                    color: PlunesColors.GREENCOLOR,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 2),
                          height: 0.5,
                          width: double.infinity,
                          color: PlunesColors.GREYCOLOR,
                        ),
        ],
      ),
    );
  }

  _doExpandCollapse() {
    _docExpandCollapseController?.add(null);
  }

  void _checkExpandedSolutions() {
    if (_services == null || _services.isEmpty) {
      return;
    }
    if (_searchedDocResults != null &&
        _searchedDocResults.solution != null &&
        _searchedDocResults.solution.services != null &&
        _searchedDocResults.solution.services.isNotEmpty) {
      _searchedDocResults.solution.services.forEach((service) {
        if (service.doctors != null && service.doctors.isNotEmpty) {
          _services?.forEach((processedService) {
            if (service == processedService &&
                processedService.isExpanded != null &&
                processedService.isExpanded) {
              service.isExpanded = processedService.isExpanded;
            }
          });
        }
      });
    }
  }

  Widget _getNegotiatedPriceTotalView() {
    return StreamBuilder(
      builder: (context, data) {
        if (_gainedDiscount == null || _gainedDiscount == 0) {
          return Container();
        }
        String time = "NA";
        var duration = DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(_solutionReceivedTime));
        if (duration.inHours >= 1) {
          time = "${duration.inHours} hour";
        } else if (duration.inMinutes < 1) {
          time = "${duration.inSeconds} secs";
        } else {
          time = "${duration.inMinutes} mins";
        }
        return Card(
          elevation: 2.5,
          margin: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 4,
              right: AppConfig.horizontalBlockSize * 4,
              top: AppConfig.verticalBlockSize * 2),
          child: Container(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.asset(PlunesImages.savedMoneyImage),
                    height: AppConfig.verticalBlockSize * 4,
                    width: AppConfig.horizontalBlockSize * 10,
                  ),
                  Padding(padding: EdgeInsets.only(left: 15.0)),
                  Expanded(
                      child: RichText(
                          text: TextSpan(
                              text: "We managed to save ",
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16),
                              children: [
                        TextSpan(
                            text: "${_gainedDiscount?.toStringAsFixed(0)} INR ",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        TextSpan(
                            text: "For you in the last ",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 16)),
                        TextSpan(
                            text: "$time !",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.w800,
                                fontSize: 16))
                      ])))
                ],
              )),
        );
      },
      stream: _totalDiscountController.stream,
      initialData: _gainedDiscount,
    );
  }

  Future<num> _getDiscountAsync() async {
    return _getTotalDiscount();
  }

  num _getTotalDiscount() {
    num totalDiscount = 0;
    try {
      if (_searchedDocResults != null &&
          _searchedDocResults.solution != null &&
          _searchedDocResults.solution.services != null &&
          _searchedDocResults.solution.services.isNotEmpty) {
        _searchedDocResults.solution.services.forEach((service) {
          if (service.doctors != null && service.doctors.isNotEmpty) {
            service.doctors.forEach((element) {
              if (element.discount != null && element.discount > 0) {
                totalDiscount =
                    totalDiscount + (element.price[0] - element.newPrice[0]);
              }
            });
          } else {
            if (service.discount != null && service.discount > 0) {
              totalDiscount =
                  totalDiscount + (service.price[0] - service.newPrice[0]);
            }
          }
        });
      }
    } catch (e) {
//      print("error in _getTotalDiscount ${e.toString()}");
      totalDiscount = 0;
    }
    _gainedDiscount = totalDiscount;
    _totalDiscountController.add(null);
    return totalDiscount;
  }

  bool _canGoAhead() {
    bool _canGoAhead = true;
    var duration = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(_solutionReceivedTime));
    if (duration.inHours >= 1) {
      _canGoAhead = false;
    }
    return _canGoAhead;
  }

  void _showSnackBar(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }
}
