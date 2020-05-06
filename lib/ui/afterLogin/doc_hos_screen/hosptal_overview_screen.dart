import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
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
    extends BaseState<HospitalDoctorOverviewScreen> {
  User _user;
  DocHosMainInsightBloc _docHosMainInsightBloc;
  RealTimeInsightsResponse _realTimeInsightsResponse;
  ActionableInsightResponseModel _actionableInsightResponse;
  TotalBusinessEarnedModel _totalBusinessEarnedResponse;
  String _reaTimeInsightFailureCause,
      _actionableInsightFailureCause,
      _businessFailurecause,
      selectedDay;
  int days = 1;
  List<String> daysCount = ['today', 'week', 'month', 'year'];
  List<String> daysInput;

  // String

  @override
  void initState() {
    _user = UserManager().getUserDetails();
    _docHosMainInsightBloc = DocHosMainInsightBloc();
    _getRealTimeInsights();
    _getActionableInsights();
    _getTotalBusinessData(days);
    daysInput = [];
    super.initState();
  }

  _getRealTimeInsights() {
    _docHosMainInsightBloc.getRealTimeInsights();
  }

  _getActionableInsights() {
    _docHosMainInsightBloc.getActionableInsights();
  }

  _getTotalBusinessData(int days) {
    _docHosMainInsightBloc.getTotalBusinessData(days);
    _setState();
  }

  @override
  void dispose() {
    _docHosMainInsightBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Column(
            children: <Widget>[
              Container(
                // margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                width: double.infinity,
                child: Card(
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
              _getRealTimeInsightView(),
              _getTotalBusinessWidget(),
              _getActionableInsightWidget(),
            ],
          ),
        ),
      ),
    );
  }

  String _getNaString() {
    return PlunesStrings.NA;
  }

  Widget _getRealTimeInsightView() {
    return Card(
      margin: EdgeInsets.only(top: 3, left: 5, right: 5),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
            vertical: AppConfig.verticalBlockSize * 2,
            horizontal: AppConfig.horizontalBlockSize * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    height: AppConfig.verticalBlockSize * 5,
                    width: AppConfig.horizontalBlockSize * 8,
                    margin: EdgeInsets.only(
                        right: AppConfig.horizontalBlockSize * 3),
                    child: Image.asset(
                      PlunesImages.realTimeInsightIcon,
//                      width: AppConfig.horizontalBlockSize*7,
//                      height:AppConfig.horizontalBlockSize*7,
                    )),
                Expanded(
                  child: Text(
                    PlunesStrings.realTimeInsights,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  flex: 3,
                ),
                Expanded(
                  child: Text(
                    'Maximum time limit 10 Min',
                    style: TextStyle(
                        fontSize: AppConfig.mediumFont,
                        color: PlunesColors.GREYCOLOR),
                  ),
                  flex: 2,
                )
              ],
            ),
            Divider(),
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
                            print(
                                "data is ${_realTimeInsightsResponse.data[itemIndex]}");
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                PatientServiceInfo(
                                  patientName: _realTimeInsightsResponse
                                      .data[itemIndex].userName,
                                  serviceName: "is looking for " +
                                      "${_realTimeInsightsResponse.data[itemIndex].serviceName?.toUpperCase() ?? _getNaString()}",
                                  remainingTime: _realTimeInsightsResponse
                                      .data[itemIndex].createdAt,
                                ),
                                FlatButtonLinks(
                                    PlunesStrings.kindlyUpdateYourPrice,
                                    15,
                                    null,
                                    AppConfig.horizontalBlockSize * 12,
                                    true,
                                    () => _openRealTimeInsightPriceUpdateWidget(
                                        _realTimeInsightsResponse
                                            .data[itemIndex])),
                                Divider(),
                              ],
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

  Widget _getTotalBusinessWidget() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                trailing: _selectDayDropDown(),
                //Text('drop down here'),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: StreamBuilder<RequestState>(
                  builder: (context, snapShot) {
                    if (snapShot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    }
                    if (snapShot.data is RequestSuccess) {
                      RequestSuccess _requestSuccess = snapShot.data;
                      _totalBusinessEarnedResponse = _requestSuccess.response;
                      if (_totalBusinessEarnedResponse == null) {
                        _businessFailurecause =
                            PlunesStrings.noBusinessDataFound;
                      }
                      _docHosMainInsightBloc.addStateInBusinessStream(null);
                    }
                    if (snapShot.data is RequestFailed) {
                      RequestFailed _requestFailed = snapShot.data;
                      _businessFailurecause = _requestFailed.failureCause;
                      _docHosMainInsightBloc.addStateInBusinessStream(null);
                    }
                    return (_totalBusinessEarnedResponse == null)
                        ? Center(
                            child: Text(_businessFailurecause ??
                                PlunesStrings.noBusinessDataFound),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '\u20B9 ${_totalBusinessEarnedResponse.businessGained.toString()}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Business Earned',
                                      style: TextStyle(color: Colors.black54),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '\u20B9 ${_totalBusinessEarnedResponse.businessLost.toString()}',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Business Lost',
                                      style: TextStyle(color: Colors.black54),
                                    ),
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
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                      'Please take action real time Insights to increase your business')),
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Image.asset(
                  PlunesImages.actionableInsightIcon,
                  width: AppConfig.horizontalBlockSize * 10,
                  height: AppConfig.horizontalBlockSize * 10,
                ),
                title: Text(
                  'Actionable Insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
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
                                                fontSize: 15,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      "${_actionableInsightResponse?.data[itemIndex]?.serviceName?.toUpperCase() ?? _getNaString()}",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: PlunesColors
                                                          .BLACKCOLOR,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              TextSpan(
                                                text: " is ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              TextSpan(
                                                  text:
                                                      "${_actionableInsightResponse?.data[itemIndex]?.percent?.toStringAsFixed(0) ?? _getNaString()}%",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: PlunesColors
                                                          .BLACKCOLOR,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              TextSpan(
                                                text:
                                                    " higher than the booked price.",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ]),
                                      )),
                                  FlatButtonLinks(
                                      'Update here',
                                      15,
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
        _getActionableInsights();
      }
    });
  }

  _openRealTimeInsightPriceUpdateWidget(RealInsight realInsight) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomWidgets().UpdatePricePopUp(
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
    List<DropdownMenuItem<String>> _varianceDropDownItems = new List();
    for (String daysCount in daysCount) {
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
        width: AppConfig.horizontalBlockSize * 23,
        child: ListView.builder(
          itemBuilder: (context, itemIndex) {
            daysInput.add(daysCount.first);
            return Column(
              children: <Widget>[
                DropdownButtonFormField(
                  items: _varianceDropDownItems,
                  onChanged: (value) {
                    daysInput[itemIndex] = value;
                    print(
                      'valuee ${value}',
                    );
                    if (value == 'today') {
                      _getTotalBusinessData(1);
                    } else if (value == 'week') {
                      _getTotalBusinessData(7);
                    } else if (value == 'month') {
                      _getTotalBusinessData(30);
                    } else {
                      _getTotalBusinessData(365);
                    }
                    _setState();
                  },
                  value: daysInput[itemIndex],
                  decoration: InputDecoration.collapsed(
                      hintText: "", border: InputBorder.none),
                ),
              ],
            );
          },
          itemCount: 1,
        ));
  }

  void _setState() {
    if (mounted) setState(() {});
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
              fontSize: fontSize,
              color: Colors.green,
              decoration:
                  isUnderline ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
          onPressed: () => onTap()),
    );
  }
}

class PatientServiceInfo extends StatefulWidget {
  final String patientName;
  final String serviceName;
  final String imageUrl;
  final int remainingTime;

  PatientServiceInfo(
      {this.patientName, this.serviceName, this.imageUrl, this.remainingTime});

  @override
  _PatientServiceInfoState createState() => _PatientServiceInfoState();
}

class _PatientServiceInfoState extends State<PatientServiceInfo> {
  Timer _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    print(widget.remainingTime);
    _timer = Timer.periodic(Duration(seconds: 1), (_timer) {
      _startTimer(_timer);
    });

    super.initState();
  }

  _startTimer(Timer timer) {
    if (!isShowWidget()) {
      _setState();
    } else {
      if (timer != null && timer.isActive) {
        timer?.cancel();
      }
    }
  }

  bool isShowWidget() {
    print(widget.remainingTime);
    return (widget.remainingTime == null ||
            widget.remainingTime == 0 ||
            DateTime.now()
                    .difference(DateTime.fromMillisecondsSinceEpoch(
                        widget.remainingTime))
                    .inMinutes >
                40) ??
        true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          child: Container(
              height: AppConfig.horizontalBlockSize * 14,
              width: AppConfig.horizontalBlockSize * 14,
              child: Image.asset(PlunesImages.inactiveProfileIcon)),
          radius: AppConfig.horizontalBlockSize * 7,
        ),
        Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.patientName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: 16,
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
    String timeValue = DateUtil.getDuration(widget.remainingTime);
    List list = timeValue.split(" ");
    String firstVal = PlunesStrings.NA;
    if (list != null && list.length >= 2) {
      firstVal = list[0];
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
                    firstVal,
                    style: TextStyle(
                        color: PlunesColors.GREENCOLOR, fontSize: 16.0),
                  ),
                ),
              ),
              Text(
                'Min',
                style: TextStyle(fontSize: 14.0),
              )
            ],
          )
        : Container();
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
