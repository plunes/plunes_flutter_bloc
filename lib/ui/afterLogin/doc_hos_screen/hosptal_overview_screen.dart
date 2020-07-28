import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _centresList = [];
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
        body: _isProcessing
            ? CustomWidgets().getProgressIndicator()
            : _failureCause != null
                ? CustomWidgets().errorWidget(_failureCause)
                : _getBody());
  }

  String _getNaString() {
    return PlunesStrings.NA;
  }

  Widget _getRealTimeInsightView() {
    return Container(
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: AppConfig.verticalBlockSize * 35,
              width: double.infinity,
              child: StreamBuilder<RequestState>(
                builder: (context, snapShot) {
                  if (snapShot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  if (snapShot.data is RequestSuccess) {
                    RequestSuccess _requestSuccess = snapShot.data;
                    _realTimeInsightsResponse = _requestSuccess.response;
                    if (_realTimeInsightsResponse?.data != null &&
                        _realTimeInsightsResponse.data.isEmpty) {
                      _reaTimeInsightFailureCause =
                          PlunesStrings.noRealTimeInsights;
                    }
                    _docHosMainInsightBloc
                        .addStateInRealTimeInsightStream(null);
                  }
                  if (snapShot.data is RequestFailed) {
                    RequestFailed _requestFailed = snapShot.data;
                    _reaTimeInsightFailureCause = _requestFailed.failureCause;
                    _docHosMainInsightBloc
                        .addStateInRealTimeInsightStream(null);
                  }
                  return (_realTimeInsightsResponse == null ||
                          _realTimeInsightsResponse.data.isEmpty)
                      ? Center(
                          child: Text(_reaTimeInsightFailureCause ??
                              PlunesStrings.noRealTimeInsights),
                        )
                      : ListView.builder(
                          padding: null,
                          itemBuilder: (context, itemIndex) {
                            return Card(
                              elevation: 2.0,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: AppConfig.verticalBlockSize * 2,
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    PatientServiceInfo(
                                        patientName: _realTimeInsightsResponse
                                            .data[itemIndex].userName,
                                        serviceName: "is looking for " +
                                            "${_realTimeInsightsResponse.data[itemIndex].serviceName?.toUpperCase() ?? _getNaString()}",
                                        remainingTime: _realTimeInsightsResponse
                                            .data[itemIndex].createdAt,
                                        centreLocation:
                                            _realTimeInsightsResponse
                                                .data[itemIndex].centerLocation,
                                        getRealTimeInsights: () =>
                                            _getRealTimeInsights()),
                                    (_realTimeInsightsResponse
                                                    .data[itemIndex] !=
                                                null &&
                                            _realTimeInsightsResponse
                                                    .data[itemIndex].expired !=
                                                null &&
                                            _realTimeInsightsResponse
                                                .data[itemIndex].expired)
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                left: (AppConfig
                                                            .horizontalBlockSize *
                                                        12) +
                                                    15,
                                                top: AppConfig
                                                        .verticalBlockSize *
                                                    2),
                                            child: Row(
                                              children: <Widget>[
                                                Flexible(
                                                  child: Text(
                                                    "${_realTimeInsightsResponse.data[itemIndex].expirationMessage ?? PlunesStrings.NA}" +
                                                        " ",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors
                                                            .deepOrangeAccent),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Image.asset(
                                                  PlunesImages.bookingLostEmoji,
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
                                                  15,
                                                  null,
                                                  AppConfig
                                                          .horizontalBlockSize *
                                                      12,
                                                  true,
                                                  () => _openRealTimeInsightPriceUpdateWidget(
                                                      _realTimeInsightsResponse
                                                          .data[itemIndex])),
                                              InkWell(
                                                onTap: () =>
                                                    _openRealTimeInsightPriceUpdateWidget(
                                                        _realTimeInsightsResponse
                                                            .data[itemIndex]),
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 1.0,
                                                      right: 6.0,
                                                      top: 6.0,
                                                      bottom: 6.0),
                                                  child: Icon(
                                                    Icons.arrow_forward,
                                                    color:
                                                        PlunesColors.GREENCOLOR,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount:
                              _realTimeInsightsResponse.data?.length ?? 0,
                        );
                },
                initialData: _realTimeInsightsResponse == null
                    ? RequestInProgress()
                    : null,
                stream: _docHosMainInsightBloc.realTimeInsightStream,
              ),
            )
          ],
        ),
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
                leading: Image.asset(
                  PlunesImages.totalBusinessIcon,
                  width: AppConfig.horizontalBlockSize * 10,
                  height: AppConfig.horizontalBlockSize * 7,
                ),
                title: Text(
                  'Total Business',
                  style: TextStyle(
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: (_user.isAdmin &&
                        UserManager().centreData != null &&
                        UserManager().centreData.len != null &&
                        UserManager().centreData.len != 0)
                    ? _businessCentresDropDown()
                    : _selectDayDropDown(),
                //Text('drop down here'),
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
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '\u20B9 ${_totalBusinessEarnedResponse.businessGained?.toStringAsFixed(2) ?? PlunesStrings.NA}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: AppConfig.largeFont,
                                        fontWeight: FontWeight.bold,
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
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '\u20B9 ${_totalBusinessEarnedResponse.businessLost?.toStringAsFixed(2) ?? PlunesStrings.NA}',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: AppConfig.largeFont,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Business Lost',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: AppConfig.verySmallFont)),
                                  ],
                                )
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
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: AppConfig.verySmallFont))),
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
              ListTile(
                leading: Image.asset(
                  PlunesImages.actionableInsightIcon,
                  width: AppConfig.horizontalBlockSize * 10,
                  height: AppConfig.horizontalBlockSize * 8,
                ),
                title: Text(
                  'Actionable Insights',
                  style: TextStyle(
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: (_user.isAdmin &&
                        _centresList != null &&
                        _centresList.isNotEmpty)
                    ? _actionableDropDown()
                    : null,
              ),
              Divider(color: Colors.black38),
              Container(
                height: AppConfig.verticalBlockSize * 35,
                width: double.infinity,
                child: StreamBuilder<RequestState>(
                  builder: (context, snapShot) {
                    if (snapShot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
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
                        ? Center(
                            child: Text(_actionableInsightFailureCause ??
                                PlunesStrings.noActionableInsightAvailable),
                          )
                        : ListView.builder(
                            padding: null,
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
                                                fontWeight: FontWeight.w500),
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
                                                          FontWeight.w500)),
                                              TextSpan(
                                                text: " is ",
                                                style: TextStyle(
                                                    fontSize: AppConfig
                                                            .verySmallFont +
                                                        1,
                                                    color: Colors.black54,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                                          FontWeight.w500)),
                                              TextSpan(
                                                text:
                                                    " higher than the booked price.",
                                                style: TextStyle(
                                                    fontSize: AppConfig
                                                            .verySmallFont +
                                                        1,
                                                    color: Colors.black54,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ]),
                                      )),
                                  FlatButtonLinks(
                                      'Update here',
                                      AppConfig.verySmallFont + 1,
                                      null,
                                      0,
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
                          );
                  },
                  initialData: _actionableInsightResponse == null
                      ? RequestInProgress()
                      : null,
                  stream: _docHosMainInsightBloc.actionableStream,
                ),
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
                actionableInsight: actionableInsight)).then((value) {
      if (value != null && value) {
        widget.showInSnackBar(PlunesStrings.priceUpdateSuccessMessage,
            PlunesColors.BLACKCOLOR, scaffoldKey);
        if (_user.isAdmin && _centresList != null && _centresList.isNotEmpty) {
          _getActionableInsights(
              userId: _selectedUserIdForActionableInsightDropDown);
        } else {
          _getActionableInsights();
        }
      }
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
        widget.showInSnackBar(PlunesStrings.priceUpdateSuccessMessage,
            PlunesColors.BLACKCOLOR, scaffoldKey);
        _getRealTimeInsights();
      }
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
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: new Text(
            daysCount,
            style: TextStyle(
              fontSize: AppConfig.mediumFont,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
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
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 5, left: 5, right: 5),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _user?.name ?? _getNaString(),
                    style: TextStyle(
                        fontSize: AppConfig.smallFont,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 2.0,
              margin: EdgeInsets.only(top: 3, left: 5, right: 5),
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 2,
                    horizontal: AppConfig.horizontalBlockSize * 4),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            PlunesStrings.realTimeInsights,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                            height: AppConfig.verticalBlockSize * 3,
                            width: AppConfig.horizontalBlockSize * 6.5,
                            margin: EdgeInsets.only(
                                right: AppConfig.horizontalBlockSize * 3),
                            child: Image.asset(
                              PlunesImages.informativeIcon,
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
                        style: TextStyle(
                            color: PlunesColors.GREYCOLOR, fontSize: 15),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: StreamBuilder<Object>(
                              stream:
                                  _docHosMainInsightBloc.realTimeInsightStream,
                              builder: (context, snapshot) {
                                if (_realTimeInsightsResponse != null &&
                                    _realTimeInsightsResponse.timer != null) {
                                  return Text(
                                    'Preferred Time : ${_realTimeInsightsResponse.timer} Min',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: PlunesColors.GREYCOLOR
                                            .withOpacity(0.65)),
                                  );
                                }
                                return Container();
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
                                  color:
                                      PlunesColors.GREYCOLOR.withOpacity(0.65)),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            _getRealTimeInsightView(),
            _getTotalBusinessWidgetForNonAdmin(),
            _getActionableInsightWidget(),
          ],
        ),
      ),
    );
  }

  _getCentresData() async {
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
            fontWeight: FontWeight.bold,
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
      child: FlatButton(
          child: Text(
            linkName,
            style: TextStyle(
              fontSize: AppConfig.smallFont,
              color: Colors.green,
            ),
          ),
          onPressed: () => onTap()),
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
  int _countDownValue = 14, _prevMinValue;

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
//    print(widget.remainingTime);
    if (widget.timer != null) {
      _countDownValue = widget.timer - 1;
    }
    _runSolutionExpireTimer();
    if (!isShowWidget()) {
      _timer = Timer.periodic(Duration(seconds: 1), (_timer) {
        _startTimer(_timer);
      });
    }
    super.initState();
  }

  _startTimer(Timer timer) {
    if (!isShowWidget()) {
      _setState();
    } else {
      if (timer != null && timer.isActive) {
        timer?.cancel();
//        widget.getRealTimeInsights();
      }
    }
  }

  bool isShowWidget() {
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
        CustomWidgets().getBackImageView(widget.patientName ?? PlunesStrings.NA,
            width: 45, height: 45),
//        CircleAvatar(
//          backgroundColor: Color.fromRGBO(255, 232, 232, 1),
//          child: Container(
//              height: AppConfig.horizontalBlockSize * 8,
//              width: AppConfig.horizontalBlockSize * 9,
//              child: Image.asset(PlunesImages.userProfileIcon)),
//          radius: AppConfig.horizontalBlockSize * 7,
//        ),
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
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          children: (widget.centreLocation != null &&
                                  widget.centreLocation.isNotEmpty)
                              ? [
                                  TextSpan(
                                    text: " ${widget.centreLocation}",
                                    style: TextStyle(
                                      fontSize: AppConfig.smallFont + 2,
                                      color: PlunesColors.GREENCOLOR,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ]
                              : null)),
                  Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: AppConfig.verySmallFont + 1,
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
    String timeValue = PlunesStrings.NA;
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
          _secondVal = _secFixVal;
        }
        _secondVal--;
        timeValue = val.toString();
        if (timeValue != null && timeValue.length == 1) {
          timeValue = "0$timeValue";
        }
        if (_secondVal != null) {
          var _sec = _secondVal.toString();
          if (_sec.length == 1) {
            _sec = "0$_sec";
          }
          timeValue = timeValue + ':' + _sec;
        }
      }
    }
    return !isShowWidget()
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
                    timeValue,
                    style: TextStyle(
                        color: PlunesColors.GREENCOLOR,
                        fontSize: AppConfig.verySmallFont + 2),
                  ),
                ),
              ),
              Text(
                'Min',
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
                'Min',
                style: TextStyle(fontSize: AppConfig.verySmallFont),
              )
            ],
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
