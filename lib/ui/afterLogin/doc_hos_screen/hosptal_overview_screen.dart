import 'dart:async';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/socket_io_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/doc_hos_models/common_models/actionable_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/total_business_earnedLoss_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/afterLogin/hos_popup_scr/real_insight_popup_scr.dart';
import '../../../Utils/custom_widgets.dart';
import 'package:showcaseview/showcaseview.dart';

// ignore: must_be_immutable
class HospitalDoctorOverviewScreen extends BaseActivity {
  @override
  _HospitalOverviewScreenState createState() => _HospitalOverviewScreenState();
}

class _HospitalOverviewScreenState
    extends BaseState<HospitalDoctorOverviewScreen>
    with WidgetsBindingObserver {
  User _user;
  DocHosMainInsightBloc _docHosMainInsightBloc;
  List<CentreData> _centresList = [];
  RealTimeInsightsResponse _realTimeInsightsResponse;
  ActionableInsightResponseModel _actionableInsightResponse;
  TotalBusinessEarnedModel _totalBusinessEarnedResponse;
  String _reaTimeInsightFailureCause,
      _actionableInsightFailureCause,
      _businessFailureCause,
      _failureCause,
      selectedDay,
      _selectedUserIdForBusinessDropDown = "",
      _selectedUserIdForActionableInsightDropDown = "",
      _selectedDay = 'Today';
  int days = 1, initialDayForAdminUser = 1;
  List<String> _daysCount = ['Today', 'Week', 'Month', 'Year'];
  List<int> duration = [1, 7, 30, 365];
  bool _isProcessing;
  bool _scrollParent = false;
  StreamController _timeUpdater;
  Timer _timer;
  ScrollController _scrollController;
  BuildContext _context;
  GlobalKey _realTimeInsightKey = GlobalKey();
  SocketIoUtil _socketIoUtil;

  @override
  void initState() {
    _highlightWidgets();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    _timeUpdater = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timer = timer;
      _timeUpdater.add(null);
    });
    _centresList = [];
    _scrollParent = false;
    _isProcessing = false;
    _user = UserManager().getUserDetails();
    _socketIoUtil = SocketIoUtil();
    _socketIoUtil.initSocket();
    _docHosMainInsightBloc = DocHosMainInsightBloc();
    if (_user.isAdmin && (UserManager().centreData == null)) {
      _getCentresData();
    } else if (_user.isAdmin && UserManager().centreData != null) {
      _setDataIntoList();
      _getAllData();
    } else {
      _getAllData();
    }
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == FirebaseNotification.insightScreen &&
          mounted) {
        _getRealTimeInsights();
      }
    });
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == SocketIoUtil.insightTopic &&
          mounted) {
//        print("getting insight");
        _getRealTimeInsights();
      }
    });
    super.initState();
  }

  _getRealTimeInsights() {
    _docHosMainInsightBloc.getRealTimeInsights();
  }

  _getActionableInsights({String userId}) {
    _docHosMainInsightBloc.getActionableInsights(userId: userId);
  }

  _getTotalBusinessData(int days, {String userId}) {
    _docHosMainInsightBloc.getTotalBusinessData(days, userId: userId);
    _setState();
  }

  @override
  void dispose() {
    _timeUpdater?.close();
    _timer?.cancel();
    _socketIoUtil?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _docHosMainInsightBloc?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setState();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: ShowCaseWidget(
          builder: Builder(builder: (context) {
            _context = context;
            return _isProcessing
                ? CustomWidgets().getProgressIndicator()
                : _failureCause != null
                    ? CustomWidgets().errorWidget(_failureCause,
                        onTap: () => _getCentresData())
                    : _getBody();
          }),
        ));
  }

  String _getNaString() {
    return PlunesStrings.NA;
  }

  Widget _getRealTimeInsightView() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<RequestState>(
            builder: (context, snapShot) {
              if (snapShot.data is RequestInProgress) {
                return Container(
                    height: AppConfig.verticalBlockSize * 30,
                    child: CustomWidgets().getProgressIndicator());
              }
              if (snapShot.data is RequestSuccess) {
                RequestSuccess _requestSuccess = snapShot.data;
                _realTimeInsightsResponse = _requestSuccess.response;
                if (_realTimeInsightsResponse?.data != null &&
                    _realTimeInsightsResponse.data.isEmpty) {
                  _reaTimeInsightFailureCause =
                      PlunesStrings.noRealTimeInsights;
                }
                _docHosMainInsightBloc.addStateInRealTimeInsightStream(null);
              }
              if (snapShot.data is RequestFailed) {
                RequestFailed _requestFailed = snapShot.data;
                _reaTimeInsightFailureCause = _requestFailed.failureCause;
                _docHosMainInsightBloc.addStateInRealTimeInsightStream(null);
              }
              return (_realTimeInsightsResponse == null ||
                      _realTimeInsightsResponse.data.isEmpty)
                  ? Container(
                      height: AppConfig.verticalBlockSize * 42,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _returnCard(),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 7.5),
                              child: Image.asset(
                                PlunesImages.noRealTimeInsightIcon,
                                height: AppConfig.verticalBlockSize * 6.5,
                                width: AppConfig.horizontalBlockSize * 25,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 1.5),
                              child: Text(
                                _reaTimeInsightFailureCause ??
                                    PlunesStrings.noRealTimeInsights,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#676767"))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      constraints: BoxConstraints(
                        minHeight: AppConfig.verticalBlockSize * 20,
                        maxHeight: AppConfig.verticalBlockSize * 70,
                        minWidth: double.infinity,
                        maxWidth: double.infinity,
                      ),
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 0.5),
                      child: NotificationListener<OverscrollNotification>(
                        onNotification: (OverscrollNotification value) {
                          _scrollParent = true;
                          _setState();
                          Future.delayed(Duration(seconds: 1)).then((value) {
                            _scrollParent = false;
                            _setState();
                          });
                          return;
                        },
                        child: IgnorePointer(
                          ignoring: _scrollParent,
                          child: ListView.builder(
                            padding: null,
                            shrinkWrap: true,
                            itemBuilder: (context, itemIndex) {
                              if (itemIndex == 0) {
                                return _returnCard();
                              }
                              itemIndex--;
                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: AppConfig.verticalBlockSize * 1),
                                child: Stack(
                                  children: [
                                    _realTimeInsightsResponse
                                            .data[itemIndex].isCardOpened
                                        ? Container()
                                        : Positioned(
                                            bottom: 0.0,
                                            left: 0.0,
                                            right: 0.0,
                                            child: _getCardOpenButton(
                                                _realTimeInsightsResponse
                                                    .data[itemIndex]),
                                          ),
                                    Card(
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      margin: EdgeInsets.only(
                                          top: 5,
                                          left: 5,
                                          right: 5,
                                          bottom: _realTimeInsightsResponse
                                                  .data[itemIndex].isCardOpened
                                              ? 0.0
                                              : AppConfig.verticalBlockSize *
                                                  4.2),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical:
                                                AppConfig.verticalBlockSize * 2,
                                            horizontal:
                                                AppConfig.horizontalBlockSize *
                                                    4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            PatientServiceInfo(
                                              patientName:
                                                  _realTimeInsightsResponse
                                                      .data[itemIndex].userName,
                                              serviceName: "is looking for " +
                                                  "${_realTimeInsightsResponse.data[itemIndex].serviceName ?? _getNaString()}",
                                              remainingTime: (_realTimeInsightsResponse
                                                                  .data[
                                                              itemIndex] !=
                                                          null &&
                                                      _realTimeInsightsResponse
                                                              .data[itemIndex]
                                                              .booked !=
                                                          null &&
                                                      _realTimeInsightsResponse
                                                          .data[itemIndex]
                                                          .booked)
                                                  ? 0
                                                  : _realTimeInsightsResponse
                                                      .data[itemIndex]
                                                      .expirationTimer,
                                              centreLocation:
                                                  _realTimeInsightsResponse
                                                      .data[itemIndex]
                                                      .centerLocation,
                                              imageUrl:
                                                  _realTimeInsightsResponse
                                                      .data[itemIndex].imageUrl,
                                              getRealTimeInsights: () =>
                                                  _getRealTimeInsights(),
                                              realInsight:
                                                  _realTimeInsightsResponse
                                                      .data[itemIndex],
                                              openInsightPopup: () =>
                                                  _openRealTimeInsightPriceUpdateWidget(
                                                      _realTimeInsightsResponse
                                                          .data[itemIndex]),
                                            ),
                                            (_realTimeInsightsResponse
                                                            .data[itemIndex]
                                                            .suggested !=
                                                        null &&
                                                    _realTimeInsightsResponse
                                                        .data[itemIndex]
                                                        .suggested)
                                                ? Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            margin: EdgeInsets.only(
                                                                left: AppConfig
                                                                            .horizontalBlockSize *
                                                                        2 +
                                                                    45,
                                                                top: 3),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            3)),
                                                                border: Border.all(
                                                                    color: Color(
                                                                        CommonMethods.getColorHexFromStr(
                                                                            "#1473E6")))),
                                                            child: InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return CustomWidgets().turnOffNotificationPopup(
                                                                          scaffoldKey,
                                                                          _realTimeInsightsResponse
                                                                              .data[itemIndex],
                                                                          _docHosMainInsightBloc);
                                                                    }).then((value) {
                                                                  _docHosMainInsightBloc
                                                                      .addStateInDoNotDisturbStream(
                                                                          null);
                                                                  _getRealTimeInsights();
                                                                });
                                                                return;
                                                              },
                                                              splashColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        AppConfig.horizontalBlockSize *
                                                                            1.2,
                                                                    vertical:
                                                                        AppConfig.verticalBlockSize *
                                                                            0.6),
                                                                color: Color(
                                                                    CommonMethods
                                                                        .getColorHexFromStr(
                                                                            "#D7E7FB")),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Image.asset(
                                                                      PlunesImages
                                                                          .serviceNotAvail,
                                                                      height:
                                                                          AppConfig.verticalBlockSize *
                                                                              2.6,
                                                                      width:
                                                                          AppConfig.horizontalBlockSize *
                                                                              8,
                                                                    ),
                                                                    Flexible(
                                                                        child:
                                                                            Text(
                                                                      PlunesStrings
                                                                          .serviceNotAvailableText,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            CommonMethods.getColorHexFromStr("#1473E6")),
                                                                        fontSize:
                                                                            AppConfig.smallFont -
                                                                                2,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                    ))
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )),
                                                      Expanded(
                                                          child: Container())
                                                    ],
                                                  )
                                                : Container(),
                                            _getViewMoreWidgetForRealInsight(
                                                _realTimeInsightsResponse
                                                    .data[itemIndex])
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: (_realTimeInsightsResponse.data ==
                                        null ||
                                    _realTimeInsightsResponse.data.isEmpty)
                                ? 0
                                : (_realTimeInsightsResponse.data.length + 1),
                          ),
                        ),
                      ),
                    );
            },
            initialData:
                _realTimeInsightsResponse == null ? RequestInProgress() : null,
            stream: _docHosMainInsightBloc.realTimeInsightStream,
          )
        ],
      ),
    );
  }

  Widget _getTotalBusinessWidgetForNonAdmin() {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 0.5),
      width: double.infinity,
      child: Card(
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Total Business',
                  style: TextStyle(
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                dense: false,
                trailing: (_user.isAdmin &&
                        UserManager().centreData != null &&
                        UserManager().centreData.len != null &&
                        UserManager().centreData.len != 0)
                    ? _businessCentresDropDown()
                    : _selectDayDropDown(),
                //Text('drop down here'),
              ),
              Container(
                color: PlunesColors.GREYCOLOR,
                width: double.infinity,
                height: 0.3,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 10,
                    vertical: AppConfig.verticalBlockSize * 1.5),
                child: StreamBuilder<RequestState>(
                  builder: (context, snapShot) {
                    if (snapShot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    }
                    if (snapShot.data is RequestSuccess) {
                      RequestSuccess _requestSuccess = snapShot.data;
                      _totalBusinessEarnedResponse = _requestSuccess.response;
                      if (_totalBusinessEarnedResponse == null) {
                        _businessFailureCause =
                            PlunesStrings.noBusinessDataFound;
                      }
                      _docHosMainInsightBloc.addStateInBusinessStream(null);
                    }
                    if (snapShot.data is RequestFailed) {
                      RequestFailed _requestFailed = snapShot.data;
                      _businessFailureCause = _requestFailed.failureCause;
                      _docHosMainInsightBloc.addStateInBusinessStream(null);
                    }
                    return (_totalBusinessEarnedResponse == null)
                        ? Center(
                            child: Text(_businessFailureCause ??
                                PlunesStrings.noBusinessDataFound),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Flexible(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        '\u20B9 ${_totalBusinessEarnedResponse.businessGained?.toStringAsFixed(2) ?? "0"}',
                                        style: TextStyle(
                                          color: PlunesColors.GREENCOLOR,
                                          fontSize: AppConfig.largeFont,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        'Business Earned',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: AppConfig.verySmallFont),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                    child: Column(
                                  children: <Widget>[
                                    Text(
                                      '\u20B9 ${_totalBusinessEarnedResponse.businessLost?.toStringAsFixed(2) ?? "0"}',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: AppConfig.largeFont,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Text('Potential Business',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: AppConfig.verySmallFont)),
                                  ],
                                ))
                              ]);
                  },
                  initialData: _totalBusinessEarnedResponse == null
                      ? RequestInProgress()
                      : null,
                  stream: _docHosMainInsightBloc.businessDataStream,
                ),
              ),
              (_user.isAdmin &&
                      UserManager().centreData != null &&
                      UserManager().centreData.len != null &&
                      UserManager().centreData.len != 0)
                  ? Container(
                      alignment: Alignment.center,
                      child: _selectDayDropDown(),
                    )
                  : Container(),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                      'Please take action on real time insights to increase your business',
                      style: TextStyle(fontSize: AppConfig.verySmallFont))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getActionableInsightWidget() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      width: double.infinity,
      child: Card(
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  right: 20,
                  left: 20,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Actionable Insights ',
                      style: TextStyle(
                        fontSize: AppConfig.mediumFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                        height: AppConfig.verticalBlockSize * 2.5,
                        width: AppConfig.horizontalBlockSize * 5.5,
                        margin: EdgeInsets.only(
                            right: AppConfig.horizontalBlockSize * 3),
                        child: InkWell(
                          onTap: () {
                            CommonMethods.showLongToast(
                                PlunesStrings.actionAbleMessage,
                                bgColor: PlunesColors.LIGHTGREENCOLOR,
                                centerGravity: true);
                          },
                          onDoubleTap: () {},
                          child: Image.asset(
                            PlunesImages.informativeIcon,
                          ),
                        )),
                    Expanded(
                      child: Container(),
                      flex: 1,
                    ),
                    (_user.isAdmin &&
                            _centresList != null &&
                            _centresList.isNotEmpty)
                        ? Expanded(
                            child: _actionableDropDown(),
                            flex: 10,
                          )
                        : Container(),
                  ],
                ),
              ),
              Divider(color: Colors.black38),
              StreamBuilder<RequestState>(
                builder: (context, snapShot) {
                  if (snapShot.data is RequestInProgress) {
                    return Container(
                      child: CustomWidgets().getProgressIndicator(),
                      width: double.infinity,
                      height: AppConfig.verticalBlockSize * 35,
                    );
                  }
                  if (snapShot.data is RequestSuccess) {
                    RequestSuccess _requestSuccess = snapShot.data;
                    _actionableInsightResponse = _requestSuccess.response;
                    if (_actionableInsightResponse?.data != null &&
                        _actionableInsightResponse.data.isEmpty) {
                      _actionableInsightFailureCause =
                          PlunesStrings.noActionableInsightAvailable;
                    }
                    _docHosMainInsightBloc
                        .addStateInActionableInsightStream(null);
                  }
                  if (snapShot.data is RequestFailed) {
                    RequestFailed _requestFailed = snapShot.data;
                    _actionableInsightFailureCause =
                        _requestFailed.failureCause;
                    _docHosMainInsightBloc
                        .addStateInActionableInsightStream(null);
                  }
                  return (_actionableInsightResponse == null ||
                          _actionableInsightResponse.data.isEmpty)
                      ? Container(
                          width: double.infinity,
                          height: AppConfig.verticalBlockSize * 35,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  PlunesImages.noActionableInsightIcon,
                                  height: AppConfig.verticalBlockSize * 6.5,
                                  width: AppConfig.horizontalBlockSize * 25,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1.5),
                                  child: Text(
                                      _actionableInsightFailureCause ??
                                          PlunesStrings
                                              .noActionableInsightAvailable,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#676767")))),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          constraints: BoxConstraints(
                              minWidth: double.infinity,
                              maxWidth: double.infinity,
                              minHeight: AppConfig.verticalBlockSize * 20,
                              maxHeight: AppConfig.verticalBlockSize * 45),
                          child: ListView.builder(
                            padding: null,
                            shrinkWrap: true,
                            itemBuilder: (context, itemIndex) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(
                                          right: 20, left: 20, top: 10),
                                      child: RichText(
                                        text: TextSpan(
                                            text: "Your price for ",
                                            style: TextStyle(
                                                fontSize: AppConfig.smallFont,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.normal),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      "${_actionableInsightResponse?.data[itemIndex]?.serviceName ?? _getNaString()}",
                                                  style: TextStyle(
                                                      fontSize: AppConfig
                                                              .verySmallFont +
                                                          1,
                                                      color: PlunesColors
                                                          .BLACKCOLOR,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              TextSpan(
                                                text: " is ",
                                                style: TextStyle(
                                                    fontSize: AppConfig
                                                            .verySmallFont +
                                                        1,
                                                    color: Colors.black54,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              TextSpan(
                                                  text:
                                                      "${_actionableInsightResponse?.data[itemIndex]?.percent?.toStringAsFixed(0) ?? _getNaString()}%",
                                                  style: TextStyle(
                                                      fontSize: AppConfig
                                                              .verySmallFont +
                                                          1,
                                                      color: PlunesColors
                                                          .BLACKCOLOR,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              TextSpan(
                                                text:
                                                    " higher than the booked price.",
                                                style: TextStyle(
                                                    fontSize: AppConfig
                                                            .verySmallFont +
                                                        1,
                                                    color: Colors.black54,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )
                                            ]),
                                      )),
                                  FlatButtonLinks(
                                      'Update here',
                                      AppConfig.smallFont + 2,
                                      null,
                                      20,
                                      true,
                                      () => _openActionableUpdatePriceWidget(
                                          _actionableInsightResponse
                                              .data[itemIndex])),
                                  Divider(color: Colors.black38)
                                ],
                              );
                            },
                            itemCount:
                                _actionableInsightResponse?.data?.length ?? 0,
                          ),
                        );
                },
                initialData: _actionableInsightResponse == null
                    ? RequestInProgress()
                    : null,
                stream: _docHosMainInsightBloc.actionableStream,
              )
            ],
          ),
        ),
      ),
    );
  }

  _openActionableUpdatePriceWidget(ActionableInsight actionableInsight) {
    showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CustomWidgets()
                .UpdatePricePopUpForActionableInsight(
                    docHosMainInsightBloc: _docHosMainInsightBloc,
                    actionableInsight: actionableInsight,
                    centreId: _selectedUserIdForActionableInsightDropDown))
        .then((value) {
      if (value != null && value) {
        _showSnackBar(PlunesStrings.priceUpdateSuccessMessage);
        if (_user.isAdmin && _centresList != null && _centresList.isNotEmpty) {
          _getActionableInsights(
              userId: _selectedUserIdForActionableInsightDropDown);
        } else {
          _getActionableInsights();
        }
      }
    });
  }

  _showSnackBar(String message) {
    if (mounted)
      showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets()
                .getInformativePopup(globalKey: scaffoldKey, message: message);
          });
  }

  _openRealTimeInsightPriceUpdateWidget(final RealInsight realInsight) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RealInsightPopup(
                docHosMainInsightBloc: _docHosMainInsightBloc,
                realInsight: realInsight))).then((value) {
      if (value != null && value) {
        if (realInsight.suggested != null && realInsight.suggested) {
          showDialog(
              context: context,
              builder: (context) {
                return CustomWidgets().savePriceInCatalogue(
                    realInsight, scaffoldKey, _docHosMainInsightBloc);
              }).then((value) {
            _docHosMainInsightBloc.addStatePriceUpdationInCatalogueStream(null);
            _getRealTimeInsights();
          });
        } else {
          _showSnackBar(PlunesStrings.priceUpdateSuccessMessage);
          _getRealTimeInsights();
        }
      }
    });
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) => Dialog(
    //         insetPadding: EdgeInsets.symmetric(horizontal: 0),
    //         child: RealInsightPopup(
    //             docHosMainInsightBloc: _docHosMainInsightBloc,
    //             realInsight: realInsight))).then((value) {
    //   if (value != null && value) {
    //     if (realInsight.suggested != null && realInsight.suggested) {
    //       showDialog(
    //           context: context,
    //           builder: (context) {
    //             return CustomWidgets().savePriceInCatalogue(
    //                 realInsight, scaffoldKey, _docHosMainInsightBloc);
    //           }).then((value) {
    //         _docHosMainInsightBloc.addStatePriceUpdationInCatalogueStream(null);
    //         _getRealTimeInsights();
    //       });
    //     } else {
    //       _showSnackBar(PlunesStrings.priceUpdateSuccessMessage);
    //       _getRealTimeInsights();
    //     }
    //   }
    // });
  }

  Widget _selectDayDropDown() {
    if (_selectedDay == null) {
      _selectedDay = _daysCount.first;
    }
    List<DropdownMenuItem<String>> _varianceDropDownItems = new List();
    for (String daysCount in _daysCount) {
      _varianceDropDownItems.add(new DropdownMenuItem(
        value: daysCount,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              daysCount,
              style: TextStyle(
                fontSize: AppConfig.mediumFont,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: PlunesColors.GREYCOLOR,
            )
          ],
        ),
      ));
    }
    return Container(
        width: AppConfig.horizontalBlockSize * 25,
        child: Column(
          children: <Widget>[
            DropdownButtonFormField(
              items: _varianceDropDownItems,
              onChanged: (value) {
                _selectedDay = value;
                if (_user.isAdmin &&
                    _centresList != null &&
                    _centresList.isNotEmpty) {
                  _getTotalBusinessData(
                      duration[_daysCount.indexOf(_selectedDay)],
                      userId: _selectedUserIdForBusinessDropDown);
                  return;
                }
                _getTotalBusinessData(
                    duration[_daysCount.indexOf(_selectedDay)]);
              },
              isExpanded: true,
              isDense: false,
              value: _selectedDay,
              decoration: InputDecoration.collapsed(
                  hintText: "", border: InputBorder.none),
            ),
          ],
        ));
  }

  Widget _actionableDropDown() {
    if (_selectedUserIdForActionableInsightDropDown == null) {
      _selectedUserIdForActionableInsightDropDown = _centresList.first.sId;
    }
    List<DropdownMenuItem<String>> _varianceDropDownItems = new List();
    for (CentreData centreData in _centresList) {
      _varianceDropDownItems.add(new DropdownMenuItem(
        value: centreData.sId,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              centreData.centerLocation ?? PlunesStrings.NA,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: AppConfig.mediumFont,
                color: Colors.black,
              ),
              textAlign: TextAlign.start,
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: PlunesColors.GREYCOLOR,
            )
          ],
        ),
      ));
    }
    return Container(
        width: AppConfig.horizontalBlockSize * 32,
        child: Row(
          children: <Widget>[
            Flexible(
              child: DropdownButtonFormField(
                items: _varianceDropDownItems,
                onChanged: (value) {
                  _selectedUserIdForActionableInsightDropDown = value;
                  _actionableInsightResponse = null;
                  _getActionableInsights(
                      userId: _selectedUserIdForActionableInsightDropDown);
                  _setState();
                },
                value: _selectedUserIdForActionableInsightDropDown,
                isExpanded: true,
                isDense: false,
                decoration: InputDecoration.collapsed(
                    hintText: "", border: InputBorder.none),
              ),
            ),
          ],
        ));
  }

  Widget _businessCentresDropDown() {
    if (_selectedUserIdForBusinessDropDown == null) {
      _selectedUserIdForBusinessDropDown = _centresList.first.sId;
    }
    List<DropdownMenuItem<String>> _varianceDropDownItems = new List();
    for (CentreData centreData in _centresList) {
      _varianceDropDownItems.add(DropdownMenuItem(
          value: centreData.sId,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                centreData.centerLocation ?? PlunesStrings.NA,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                    fontSize: AppConfig.mediumFont, color: Colors.black),
                textAlign: TextAlign.start,
              ),
              Container(
                height: 0.5,
                width: double.infinity,
                color: PlunesColors.GREYCOLOR,
              )
            ],
          )));
    }
    return Container(
        width: AppConfig.horizontalBlockSize * 32,
        child: Row(
          children: <Widget>[
            Flexible(
              child: DropdownButtonFormField(
                items: _varianceDropDownItems,
                onChanged: (value) {
                  _selectedUserIdForBusinessDropDown = value;
                  _totalBusinessEarnedResponse = null;
                  _getTotalBusinessData(
                      duration[_daysCount.indexOf(_selectedDay)],
                      userId: _selectedUserIdForBusinessDropDown);
                },
                value: _selectedUserIdForBusinessDropDown,
                isExpanded: true,
                isDense: false,
                decoration: InputDecoration.collapsed(
                    hintText: "", border: InputBorder.none),
              ),
            ),
          ],
        ));
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getBody() {
    return Theme(
      data: ThemeData(
          brightness: Brightness.light,
          highlightColor: PlunesColors.GREENCOLOR),
      child: Scrollbar(
        controller: _scrollController,
        isAlwaysShown: true,
        child: RefreshIndicator(
          onRefresh: () async {
            _docHosMainInsightBloc
                .addStateInRealTimeInsightStream(RequestInProgress());
            _getRealTimeInsights();
            return await Future.delayed(Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              margin: EdgeInsets.only(top: 5, left: 5, right: 5),
              child: Column(
                children: <Widget>[
                  _getRealTimeInsightView(),
                  _getTotalBusinessWidgetForNonAdmin(),
                  _getActionableInsightWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getCentresData() async {
    _failureCause = null;
    _isProcessing = true;
    _setState();
    var result = await UserManager().getAdminSpecificData();
    if (result is RequestSuccess) {
      if (UserManager().centreData == null) {
        _failureCause = "Centres data not found";
      } else {
        _setDataIntoList();
        _getAllData();
      }
    } else if (result is RequestFailed) {
      _failureCause = result.failureCause;
    }
    _isProcessing = false;
    _setState();
  }

  void _getAllData() {
    _getRealTimeInsights();
    (_user.isAdmin &&
            UserManager().centreData != null &&
            UserManager().centreData.len != 0)
        ? _getActionableInsights(userId: "")
        : _getActionableInsights();
    (_user.isAdmin &&
            UserManager().centreData != null &&
            UserManager().centreData.len != 0)
        ? _getTotalBusinessData(initialDayForAdminUser, userId: "")
        : _getTotalBusinessData(days);
  }

  void _setDataIntoList() {
    if (UserManager().centreData != null &&
        UserManager().centreData.len != null &&
        UserManager().centreData.len != 0) {
      UserManager().centreData.data.forEach((element) {
        _centresList.add(element);
      });
      _centresList.insert(
          0,
          CentreData(
              isAdmin: true, centerLocation: _user.name ?? "Myself", sId: ""));
    }
  }

  void _highlightWidgets() {
    if (!UserManager().getWidgetShownStatus(Constants.INSIGHT_MAIN_SCREEN)) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            ShowCaseWidget.of(_context).startShowCase([_realTimeInsightKey]));
        Future.delayed(Duration(seconds: 1)).then((value) {
          UserManager().setWidgetShownStatus(Constants.INSIGHT_MAIN_SCREEN);
        });
      });
    }
  }

  Widget _returnCard() {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.only(
          top: AppConfig.verticalBlockSize * 1,
          left: 5,
          right: 5,
          bottom: AppConfig.verticalBlockSize * 1),
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: AppConfig.verticalBlockSize * 2,
            horizontal: AppConfig.horizontalBlockSize * 4),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: CustomWidgets().getShowCase(
                    _realTimeInsightKey,
                    title: PlunesStrings.realTimeInsights,
                    description: PlunesStrings.realTimeDesc,
                    child: Text(
                      PlunesStrings.realTimeInsights,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(
                    height: AppConfig.verticalBlockSize * 2.5,
                    width: AppConfig.horizontalBlockSize * 5.5,
                    margin: EdgeInsets.only(
                        right: AppConfig.horizontalBlockSize * 3),
                    child: InkWell(
                      onTap: () {
                        CommonMethods.showLongToast(
                            PlunesStrings.realTimeMessage,
                            bgColor: PlunesColors.LIGHTGREENCOLOR,
                            centerGravity: true);
                      },
                      onDoubleTap: () {},
                      child: Image.asset(
                        PlunesImages.informativeIcon,
                      ),
                    )),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 0.8),
              child: Text(
                PlunesStrings.makeSureToUpdatePrice,
                textAlign: TextAlign.left,
                maxLines: 2,
                style: TextStyle(color: PlunesColors.GREYCOLOR, fontSize: 15),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<Object>(
                      stream: _docHosMainInsightBloc.realTimeInsightStream,
                      builder: (context, snapshot) {
                        return (_realTimeInsightsResponse == null ||
                                _realTimeInsightsResponse.data == null ||
                                _realTimeInsightsResponse.data.isEmpty)
                            ? Container()
                            : Text(
                                'Preferred Time : ${_realTimeInsightsResponse?.timer} Mins',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: PlunesColors.GREYCOLOR
                                        .withOpacity(0.65)),
                              );
                      }),
                  flex: 2,
                ),
                Expanded(
                    flex: 2,
                    child: Text(
                      'Maximum Time : 1 hour',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 13,
                          color: PlunesColors.GREYCOLOR.withOpacity(0.65)),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _getViewMoreWidgetForRealInsight(RealInsight data) {
    return data.isCardOpened
        ? Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 4,
                right: AppConfig.horizontalBlockSize * 3),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2.8),
                  child: DottedLine(
                    dashColor:
                        Color(CommonMethods.getColorHexFromStr("#70707038")),
                  ),
                ),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (data.userReport != null &&
                              data.userReport.additionalDetails != null &&
                              data.userReport.additionalDetails
                                  .trim()
                                  .isNotEmpty)
                          ? Expanded(
                              child: Container(
                              margin: EdgeInsets.only(right: 4),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Additional Details of the service",
                                      maxLines: 3,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 18),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 12),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                          Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#FEFEFE")),
                                          Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#F6F6F6")),
                                        ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter)),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      data.userReport?.additionalDetails ?? "",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#4E4E4E"))),
                                    ),
                                  )
                                ],
                              ),
                            ))
                          : Container(),
                      (data.userReport != null &&
                              data.userReport.description != null &&
                              data.userReport.description.trim().isNotEmpty)
                          ? Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Previous Treatment Detail's",
                                        maxLines: 3,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: PlunesColors.BLACKCOLOR,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 12),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                            Color(CommonMethods
                                                .getColorHexFromStr("#FEFEFE")),
                                            Color(CommonMethods
                                                .getColorHexFromStr("#F6F6F6")),
                                          ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter)),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        data.userReport?.description ?? "",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr(
                                                    "#4E4E4E"))),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                _getMediaWidget(data),
                InkWell(
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.only(
                        top: AppConfig.verticalBlockSize * 2.4,
                        bottom: AppConfig.verticalBlockSize * 0.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "View Less ",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#01D35A"))),
                        ),
                        Icon(Icons.keyboard_arrow_up,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#01D35A")),
                            size: 15)
                      ],
                    ),
                  ),
                  onTap: () {
                    data.isCardOpened = !data.isCardOpened;
                    _setState();
                  },
                  onDoubleTap: () {},
                ),
              ],
            ))
        : Container();
  }

  Widget _getCardOpenButton(RealInsight data) {
    return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        margin: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 10,
            right: AppConfig.horizontalBlockSize * 10),
        child: InkWell(
          focusColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            data.isCardOpened = !data.isCardOpened;
            _setState();
          },
          onDoubleTap: () {},
          child: Container(
            height: AppConfig.verticalBlockSize * 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "View More ",
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          Color(CommonMethods.getColorHexFromStr("#01D35A"))),
                ),
                Icon(Icons.keyboard_arrow_down,
                    color: Color(CommonMethods.getColorHexFromStr("#01D35A")),
                    size: 15)
              ],
            ),
          ),
        ));
  }

  Widget _getMediaWidget(RealInsight data) {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
      child: Row(
        children: [
          (data.userReport != null &&
                  data.userReport.videoUrl != null &&
                  data.userReport.videoUrl.isNotEmpty)
              ? Expanded(child: _getVideoWidget(data))
              : Container(),
          (data.userReport != null &&
                  data.userReport.imageUrl != null &&
                  data.userReport.imageUrl.isNotEmpty)
              ? Expanded(child: _getPhotosWidget(data))
              : Container(),
          (data.userReport != null &&
                  data.userReport.reportUrl != null &&
                  data.userReport.reportUrl.isNotEmpty)
              ? Expanded(child: _getDocumentWidget(data))
              : Container()
        ],
      ),
    );
  }

  _launch(String url) {
    LauncherUtil.launchUrl(url);
  }

  Widget _getVideoWidget(RealInsight data) {
    // print("data?.userReport?.videoUrl?.first?.thumbnail ${data?.userReport?.videoUrl?.first?.thumbnail}");
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (data.userReport.videoUrl.first.url != null) {
          _launch(data.userReport.videoUrl.first.url);
        }
      },
      onDoubleTap: () {},
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Video",
              textAlign: TextAlign.left,
              style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
            height: AppConfig.verticalBlockSize * 12,
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  width: AppConfig.horizontalBlockSize * 30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: SizedBox.expand(
                      child: CustomWidgets().getImageFromUrl(
                          data?.userReport?.videoUrl?.first?.thumbnail ?? "",
                          boxFit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPhotosWidget(RealInsight data) {
    return Container(
      margin: EdgeInsets.only(left: 4),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          List<Photo> photos = [];
          data.userReport.imageUrl.forEach((element) {
            if (element == null ||
                element.isEmpty ||
                !(element.contains("http"))) {
            } else {
              photos.add(Photo(assetName: element));
            }
          });
          if (photos != null && photos.isNotEmpty) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PageSlider(photos, 0)));
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                "Photos",
                textAlign: TextAlign.left,
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
              height: AppConfig.verticalBlockSize * 12,
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    width: AppConfig.horizontalBlockSize * 30,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: SizedBox.expand(
                        child: CustomWidgets().getImageFromUrl(
                            data.userReport?.imageUrl?.first ?? '',
                            boxFit: BoxFit.cover),
                      ),
                    ),
                  ),
                  data.userReport.imageUrl.length > 1
                      ? Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "+${data.userReport.imageUrl.length}",
                              style: TextStyle(
                                  color: PlunesColors.GREYCOLOR, fontSize: 60),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDocumentWidget(RealInsight data) {
    return Container(
      margin: EdgeInsets.only(left: 4),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          if (data.userReport.reportUrl.first != null) {
            _launch(data.userReport.reportUrl.first);
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                "Report",
                textAlign: TextAlign.left,
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
              height: AppConfig.verticalBlockSize * 12,
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    width: AppConfig.horizontalBlockSize * 30,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: SizedBox.expand(
                        child: Image.asset(
                          plunesImages.pdfIcon1,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  // data.userReport.reportUrl.length > 1
                  //     ? Positioned.fill(
                  //         child: Container(
                  //           alignment: Alignment.center,
                  //           child: Text(
                  //             "+${data.userReport.reportUrl.length}",
                  //             style: TextStyle(
                  //                 color: PlunesColors.GREYCOLOR, fontSize: 60),
                  //           ),
                  //         ),
                  //       )
                  //     : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RealTimeInsightsWIdget extends StatelessWidget {
  const RealTimeInsightsWIdget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(),
        Text(
          'Real Time Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.underline,
          ),
        ),
        Text(
          'Maximum time limit 10 Min',
          style: TextStyle(
            fontSize: 10,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class FlatButtonLinks extends StatelessWidget {
  final String linkName;
  final String onTapFunc;
  double leftMargin;
  bool isUnderline;
  double fontSize;
  Function onTap;

  FlatButtonLinks(this.linkName, this.fontSize, this.onTapFunc, this.leftMargin,
      this.isUnderline, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: leftMargin),
      child: InkWell(
        onTap: () => onTap(),
        highlightColor: Colors.white,
        onDoubleTap: () {},
        child: Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 10),
            child: Text(
              linkName,
              style: TextStyle(
                fontSize: AppConfig.smallFont,
                fontWeight: FontWeight.normal,
                color: PlunesColors.GREENCOLOR,
              ),
            )),
      ),
    );
  }
}

class PatientServiceInfo extends StatefulWidget {
  final String patientName, centreLocation;
  final String serviceName;
  final String imageUrl;
  final int remainingTime;
  final Function getRealTimeInsights, openInsightPopup;
  final int timer;
  final RealInsight realInsight;

  PatientServiceInfo(
      {this.patientName,
      this.serviceName,
      this.imageUrl,
      this.remainingTime,
      this.centreLocation,
      this.getRealTimeInsights,
      this.timer,
      this.realInsight,
      this.openInsightPopup});

  @override
  _PatientServiceInfoState createState() => _PatientServiceInfoState();
}

class _PatientServiceInfoState extends State<PatientServiceInfo> {
  Timer _timer, _timerForSolutionExpire;
  int _secondVal = 60;
  int _countDownValue = 59, _prevMinValue;
  String _timeValue = "00:00";
  RealInsight _realInsight;

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer?.cancel();
    }
    if (_timerForSolutionExpire != null && _timerForSolutionExpire.isActive) {
      _timerForSolutionExpire?.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    _realInsight = widget.realInsight;
    print("\n ${widget.realInsight?.toString()}");
    _timeValue = "00:00";
    if (widget.timer != null) {
      _countDownValue = widget.timer - 1;
    }
    if (!showShowWidget()) {
      _runSolutionExpireTimer();
      _timer = Timer.periodic(Duration(seconds: 1), (_timer) {
        _startTimer(_timer);
      });
    }
    super.initState();
  }

  _startTimer(Timer timer) {
    if (!showShowWidget()) {
      _setState();
    } else {
      if (timer != null && timer.isActive) {
        timer?.cancel();
      }
    }
  }

  bool showShowWidget() {
    return (widget.remainingTime == null ||
            widget.remainingTime == 0 ||
            DateTime.now()
                    .difference(DateTime.fromMillisecondsSinceEpoch(
                        widget.remainingTime))
                    .inMinutes >
                _countDownValue) ??
        true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        (widget.imageUrl != null &&
                widget.imageUrl.isNotEmpty &&
                widget.imageUrl.contains("http"))
            ? CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Container(
                  height: 45,
                  width: 45,
                  child: ClipOval(
                      child: CustomWidgets().getImageFromUrl(widget.imageUrl,
                          boxFit: BoxFit.fill,
                          placeHolderPath: PlunesImages.userProfileIcon)),
                ),
                radius: 23.5,
              )
            : CustomWidgets().getBackImageView(
                widget.patientName ?? PlunesStrings.NA,
                width: 45,
                height: 45),
        Expanded(
          flex: 5,
          child: Container(
            padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                    text: TextSpan(
                        text: widget.patientName,
                        style: TextStyle(
                          fontSize: AppConfig.smallFont + 2,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ))),
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    fontSize: AppConfig.verySmallFont + 1,
                    color: PlunesColors.BLACKCOLOR,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                (widget.centreLocation != null &&
                        widget.centreLocation.isNotEmpty)
                    ? Text(
                        "${widget.centreLocation}",
                        style: TextStyle(
                          fontSize: AppConfig.smallFont + 2,
                          color: PlunesColors.GREYCOLOR.withOpacity(0.9),
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    : Container(),
                Container(
                  margin: EdgeInsets.only(
                      right: AppConfig.horizontalBlockSize * 8, top: 5),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => widget.openInsightPopup(),
                    onDoubleTap: () {},
                    child: CustomWidgets().getRoundedButton(
                        PlunesStrings.kindlyUpdateYourPrice,
                        AppConfig.horizontalBlockSize * 8,
                        PlunesColors.WHITECOLOR,
                        AppConfig.horizontalBlockSize * 1,
                        AppConfig.verticalBlockSize * 1,
                        Color(CommonMethods.getColorHexFromStr("#01D35A")),
                        borderColor:
                            Color(CommonMethods.getColorHexFromStr("#01D35A")),
                        hasBorder: true),
                  ),
                ),
                ((_realInsight != null &&
                            _realInsight.expired != null &&
                            _realInsight.expired) ||
                        (_realInsight != null &&
                            _realInsight.booked != null &&
                            _realInsight.booked) ||
                        showShowWidget())
                    ? Container()
                    : (_realInsight.compRate != null &&
                            _realInsight.compRate > 0)
                        ? Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Text(
                                  "${_realInsight.compRate?.toStringAsFixed(1)}%",
                                  style: TextStyle(
                                      color: PlunesColors.RED,
                                      fontSize: AppConfig.smallFont),
                                ),
                              ),
                              Image.asset(
                                PlunesImages.priceHighIcon,
                                height: AppConfig.smallFont,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "high",
                                  style: TextStyle(
                                      color: PlunesColors.RED,
                                      fontSize: AppConfig.smallFont),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                ((_realInsight != null &&
                            _realInsight.expired != null &&
                            _realInsight.expired) ||
                        (_realInsight != null &&
                            _realInsight.booked != null &&
                            _realInsight.booked) ||
                        !showShowWidget())
                    ? Container(
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                "${_realInsight.expirationMessage ?? PlunesStrings.NA}",
                                style: TextStyle(
                                    fontSize: AppConfig.smallFont,
                                    fontWeight: FontWeight.normal,
                                    color: (_realInsight.professionalBooked !=
                                                null &&
                                            _realInsight.professionalBooked)
                                        ? PlunesColors.GREENCOLOR
                                        : PlunesColors.ORANGE),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              Image.asset(
                PlunesImages.darkMap,
                fit: BoxFit.contain,
                height: AppConfig.verticalBlockSize * 5,
                alignment: Alignment.center,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.perm_identity,
                      size: AppConfig.verySmallFont,
                      color: PlunesColors.BLACKCOLOR,
                    ),
                    Text(
                      "${_realInsight.distance?.toStringAsFixed(0) ?? 0} Km",
                      style: TextStyle(
                          fontSize: AppConfig.verySmallFont - 2,
                          fontWeight: FontWeight.w600,
                          color: PlunesColors.BLACKCOLOR),
                    )
                  ],
                ),
              ),
              _getTimeWidget()
            ],
          ),
        )
      ],
    );
  }

  Widget _getTimeWidget() {
    if (widget.remainingTime != null && widget.remainingTime != 0) {
      var duration = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(widget.remainingTime));
      if (duration != null && duration.inMinutes != null) {
        int val = _countDownValue - duration.inMinutes;
        if (_prevMinValue == null) {
          _prevMinValue = val;
        }
        if (_prevMinValue != val) {
          _prevMinValue = val;
        }
        _timeValue = val.toString();
        if (_timeValue != null && _timeValue.length == 1) {
          _timeValue = "0$_timeValue";
        }
        _secondVal = 60 - (duration.inSeconds % 60);
        if (_secondVal != null) {
          var _sec = _secondVal.toString();
          if (_sec.length == 1) {
            _sec = "0$_sec";
          }
          _timeValue = _timeValue + ':' + _sec;
        }
      }
    }
    return Container(
      padding: EdgeInsets.only(left: 2, top: AppConfig.verticalBlockSize * 1.6),
      child: !showShowWidget()
          ? Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 0.5,
                      horizontal: AppConfig.horizontalBlockSize * 0.6),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border:
                          Border.all(color: PlunesColors.GREYCOLOR, width: 0.5),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Center(
                    child: Text(
                      showShowWidget() ? "00:00 Mins" : _timeValue + " Mins",
                      style: TextStyle(
                          color: PlunesColors.GREENCOLOR,
                          fontSize: AppConfig.verySmallFont),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 0.5,
                      horizontal: AppConfig.horizontalBlockSize * 0.6),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border:
                          Border.all(color: PlunesColors.GREYCOLOR, width: 0.5),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Center(
                    child: Text(
                      "00:00 Mins",
                      style: TextStyle(
                          color: PlunesColors.GREENCOLOR,
                          fontSize: AppConfig.verySmallFont),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _runSolutionExpireTimer() {
    _timerForSolutionExpire = Timer.periodic(Duration(seconds: 1), (timer) {
//      print("hello ${widget.serviceName} ${widget.remainingTime}");
      _timerForSolutionExpire = timer;
      if (widget.remainingTime == null || widget.remainingTime == 0) {
//        print("timer cancelled ${widget.serviceName} ${widget.remainingTime}");
        timer.cancel();
        _setState();
      } else if (DateTime.now()
              .difference(
                  DateTime.fromMillisecondsSinceEpoch(widget.remainingTime))
              .inMinutes >=
          60) {
//        print("refreshing insights now ${widget.serviceName}");
        widget.getRealTimeInsights();
        timer.cancel();
      }
//      print("kuch nhi chala ${widget.serviceName}");
      return;
    });
  }
}
