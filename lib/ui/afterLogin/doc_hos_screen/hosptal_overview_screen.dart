import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/event_bus.dart';
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
                              return Card(
                                elevation: 2.0,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: AppConfig.verticalBlockSize * 2,
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      PatientServiceInfo(
                                          patientName: _realTimeInsightsResponse
                                              .data[itemIndex].userName,
                                          serviceName: "is looking for " +
                                              "${_realTimeInsightsResponse.data[itemIndex].serviceName?.toUpperCase() ?? _getNaString()}",
                                          remainingTime:
                                              (_realTimeInsightsResponse.data[
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
                                                      .createdAt,
                                          centreLocation:
                                              _realTimeInsightsResponse
                                                  .data[itemIndex]
                                                  .centerLocation,
                                          imageUrl: _realTimeInsightsResponse
                                              .data[itemIndex].imageUrl,
                                          getRealTimeInsights: () =>
                                              _getRealTimeInsights()),
                                      ((_realTimeInsightsResponse
                                                          .data[itemIndex] !=
                                                      null &&
                                                  _realTimeInsightsResponse
                                                          .data[itemIndex]
                                                          .expired !=
                                                      null &&
                                                  _realTimeInsightsResponse
                                                      .data[itemIndex]
                                                      .expired) ||
                                              (_realTimeInsightsResponse
                                                          .data[itemIndex] !=
                                                      null &&
                                                  _realTimeInsightsResponse
                                                          .data[itemIndex]
                                                          .booked !=
                                                      null &&
                                                  _realTimeInsightsResponse
                                                      .data[itemIndex].booked))
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  left: (AppConfig
                                                              .horizontalBlockSize *
                                                          2) +
                                                      45,
                                                  top: AppConfig
                                                          .verticalBlockSize *
                                                      2),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Text(
                                                      "${_realTimeInsightsResponse.data[itemIndex].expirationMessage ?? PlunesStrings.NA}" +
                                                          " ",
                                                      style: TextStyle(
                                                          fontSize: AppConfig
                                                              .smallFont,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors
                                                              .deepOrangeAccent),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Image.asset(
                                                    PlunesImages
                                                        .bookingLostEmoji,
                                                    height: AppConfig
                                                            .verticalBlockSize *
                                                        2.6,
                                                    width: AppConfig
                                                            .horizontalBlockSize *
                                                        8,
                                                  )
                                                ],
                                              ),
                                            )
                                          : Row(
                                              children: <Widget>[
                                                FlatButtonLinks(
                                                    PlunesStrings
                                                        .kindlyUpdateYourPrice,
                                                    AppConfig.smallFont + 2,
                                                    null,
                                                    AppConfig.horizontalBlockSize *
                                                            2 +
                                                        45,
                                                    true,
                                                    () => _openRealTimeInsightPriceUpdateWidget(
                                                        _realTimeInsightsResponse
                                                            .data[itemIndex])),
                                                InkWell(
                                                  onTap: () =>
                                                      _openRealTimeInsightPriceUpdateWidget(
                                                          _realTimeInsightsResponse
                                                              .data[itemIndex]),
                                                  highlightColor: Colors.white,
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 1.0,
                                                        right: 6.0,
                                                        top: 6.0,
                                                        bottom: 6.0),
                                                    child: Icon(
                                                      Icons.arrow_forward,
                                                      color: PlunesColors
                                                          .GREENCOLOR,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                      StreamBuilder<Object>(
                                          stream: _timeUpdater.stream,
                                          builder: (context, snapshot) {
                                            return Container(
                                              margin: EdgeInsets.only(
                                                  left: (AppConfig
                                                              .horizontalBlockSize *
                                                          2) +
                                                      45,
                                                  top: (_realTimeInsightsResponse
                                                                      .data[
                                                                  itemIndex] !=
                                                              null &&
                                                          _realTimeInsightsResponse
                                                                  .data[
                                                                      itemIndex]
                                                                  .expired !=
                                                              null &&
                                                          _realTimeInsightsResponse
                                                              .data[itemIndex]
                                                              .expired)
                                                      ? AppConfig
                                                              .verticalBlockSize *
                                                          1
                                                      : 0),
                                              child: Text(
                                                DateUtil.getDuration(
                                                    _realTimeInsightsResponse
                                                            .data[itemIndex]
                                                            ?.createdAt ??
                                                        0),
                                                style: TextStyle(
                                                    fontSize:
                                                        AppConfig.smallFont,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(CommonMethods
                                                        .getColorHexFromStr(
                                                            "#171717"))),
                                              ),
                                            );
                                          })
                                    ],
                                  ),
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
                                    Text('Business Lost',
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
                                                      "${_actionableInsightResponse?.data[itemIndex]?.serviceName?.toUpperCase() ?? _getNaString()}",
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

  _openRealTimeInsightPriceUpdateWidget(RealInsight realInsight) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomWidgets().updatePricePopUp(
            docHosMainInsightBloc: _docHosMainInsightBloc,
            realInsight: realInsight)).then((value) {
      if (value != null && value) {
        _showSnackBar(PlunesStrings.priceUpdateSuccessMessage);
      }
      _getRealTimeInsights();
    });
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
//                  Container(
//                    width: double.infinity,
//                    child: Card(
//                      elevation: 2.0,
//                      child: Padding(
//                        padding: const EdgeInsets.all(5.0),
//                        child: Row(
//                          children: <Widget>[
//                            Container(
//                              child: Image.asset(PlunesImages.labMapImage),
//                              height: AppConfig.verticalBlockSize * 4,
//                              width: AppConfig.horizontalBlockSize * 14,
//                            ),
//                            Flexible(
//                              child: Padding(
//                                padding: EdgeInsets.only(
//                                    left: AppConfig.horizontalBlockSize * 2),
//                                child: Text(
//                                  CommonMethods.getStringInCamelCase(
//                                          _user?.name) ??
//                                      _getNaString(),
//                                  maxLines: 1,
//                                  overflow: TextOverflow.clip,
//                                  style: TextStyle(
//                                      fontSize: 18,
//                                      fontWeight: FontWeight.w500),
//                                ),
//                              ),
//                            ),
//                          ],
//                        ),
//                      ),
//                    ),
//                  ),
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
//                        if (_realTimeInsightsResponse != null &&
//                            _realTimeInsightsResponse.timer !=
//                                null) {
                        return (_realTimeInsightsResponse == null ||
                                _realTimeInsightsResponse.data == null ||
                                _realTimeInsightsResponse.data.isEmpty)
                            ? Container()
                            : Text(
                                'Preferred Time : ${_realTimeInsightsResponse?.timer} Min',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: PlunesColors.GREYCOLOR
                                        .withOpacity(0.65)),
                              );
//                        }
//                        return Container();
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
  final Function getRealTimeInsights;
  final int timer;

  PatientServiceInfo(
      {this.patientName,
      this.serviceName,
      this.imageUrl,
      this.remainingTime,
      this.centreLocation,
      this.getRealTimeInsights,
      this.timer});

  @override
  _PatientServiceInfoState createState() => _PatientServiceInfoState();
}

class _PatientServiceInfoState extends State<PatientServiceInfo> {
  Timer _timer, _timerForSolutionExpire;
  int _secondVal = 60, _secFixVal = 60;
  int _countDownValue = 59, _prevMinValue;
  String _timeValue = "00:00";

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
    _timeValue = "00:00";
    if (widget.timer != null) {
      _countDownValue = widget.timer - 1;
    }
    _runSolutionExpireTimer();
    if (!showShowWidget()) {
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                      text: TextSpan(
                          text: widget.patientName,
                          style: TextStyle(
                            fontSize: AppConfig.smallFont + 2,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          children: (widget.centreLocation != null &&
                                  widget.centreLocation.isNotEmpty)
                              ? [
                                  TextSpan(
                                    text: " ${widget.centreLocation}",
                                    style: TextStyle(
                                      fontSize: AppConfig.smallFont + 2,
                                      color: PlunesColors.GREENCOLOR,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                ]
                              : null)),
                  Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: AppConfig.verySmallFont + 1,
                      color: PlunesColors.GREYCOLOR.withOpacity(0.9),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )),
        Expanded(
          child: _getTimeWidget(),
          flex: 1,
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
      padding: EdgeInsets.only(left: 2),
      child: !showShowWidget()
          ? Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 0.5),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border:
                          Border.all(color: PlunesColors.GREYCOLOR, width: 0.5),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Center(
                    child: Text(
                      _timeValue,
                      style: TextStyle(
                          color: PlunesColors.GREENCOLOR,
                          fontSize: AppConfig.verySmallFont + 2),
                    ),
                  ),
                ),
                Text(
                  'Mins',
                  style: TextStyle(fontSize: AppConfig.verySmallFont),
                )
              ],
            )
          : Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 0.5),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border:
                          Border.all(color: PlunesColors.GREYCOLOR, width: 0.5),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Center(
                    child: Text(
                      "00:00",
                      style: TextStyle(
                          color: PlunesColors.GREENCOLOR,
                          fontSize: AppConfig.verySmallFont + 2),
                    ),
                  ),
                ),
                Text(
                  'Mins',
                  style: TextStyle(fontSize: AppConfig.verySmallFont),
                )
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
    _timerForSolutionExpire = Timer.periodic(Duration(seconds: 30), (timer) {
      _timerForSolutionExpire = timer;
      if ((widget.remainingTime == null ||
          widget.remainingTime == 0 ||
          DateTime.now()
                  .difference(
                      DateTime.fromMillisecondsSinceEpoch(widget.remainingTime))
                  .inHours >
              1)) {
        widget.getRealTimeInsights();
        timer.cancel();
      }
      return;
    });
  }
}
