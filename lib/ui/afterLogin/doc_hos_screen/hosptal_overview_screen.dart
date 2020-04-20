import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/doc_hos_models/common_models/actionable_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
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
  String _reaTimeInsightFailureCause, _actionableInsightFailureCause;

  @override
  void initState() {
    _user = UserManager().getUserDetails();
    _docHosMainInsightBloc = DocHosMainInsightBloc();
    _getRealTimeInsights();
    _getActionableInsights();
    super.initState();
  }

  _getRealTimeInsights() {
    _docHosMainInsightBloc.getRealTimeInsights();
  }

  _getActionableInsights() {
    _docHosMainInsightBloc.getActionableInsights();
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
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 5, left: 5, right: 5),
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _user?.name ?? _getNaString(),
                    style: TextStyle(fontSize: 15),
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
    );
  }

  String _getNaString() {
    return PlunesStrings.NA;
  }

  Widget _getRealTimeInsightView() {
    return Card(
      margin: EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    height: AppConfig.verticalBlockSize * 3.5,
                    width: AppConfig.horizontalBlockSize * 8,
                    margin: EdgeInsets.only(
                        right: AppConfig.horizontalBlockSize * 3),
                    child: Image.asset(PlunesImages.userLandingGoogleIcon)),
                Expanded(
                  child: Text(
                    'Real Time Insights',
                    style: TextStyle(
                      fontSize: 20,
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                PatientServiceInfo(
                                  imageUrl: 'https://i.imgur.com/BoN9kdC.png',
                                  patientName: _realTimeInsightsResponse
                                      .data[itemIndex].userName,
                                  serviceName: "is looking for " +
                                      "${_realTimeInsightsResponse.data[itemIndex].serviceName?.toUpperCase() ?? _getNaString()}",
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
                leading: IconButton(
                  icon: Icon(
                    Icons.attach_money,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                title: Text(
                  'Total Business',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                trailing: Text('add drop down here'),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            '\u20B9 4500',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Business Earned',
                            style: TextStyle(color: Colors.black54),
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            '\u20B9 6424',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Business Lost',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      )
                    ]),
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
                leading: IconButton(
                  icon: Icon(
                    Icons.attach_money,
                    size: 40,
                    color: Colors.green,
                  ),
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
                                      () => _openActionableUpdatePriceWidget()),
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

  _openActionableUpdatePriceWidget() {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) => CustomWidgets().UpdatePricePopUp());
  }

  _openRealTimeInsightPriceUpdateWidget(RealInsight realInsight) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomWidgets().UpdatePricePopUp(
            docHosMainInsightBloc: _docHosMainInsightBloc,
            realInsight: realInsight));
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

class PatientServiceInfo extends StatelessWidget {
  final String patientName;
  final String serviceName;
  final String imageUrl;
  final int remainingTime;

  PatientServiceInfo(
      {this.patientName, this.serviceName, this.imageUrl, this.remainingTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          child: Container(
            height: AppConfig.horizontalBlockSize * 14,
            width: AppConfig.horizontalBlockSize * 14,
            child: ClipOval(
              child: CustomWidgets()
                  .getImageFromUrl(imageUrl, boxFit: BoxFit.fill),
            ),
          ),
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
                    patientName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    serviceName,
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
    return remainingTime != null
        ? Container()
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
                    "10.00",
                    style: TextStyle(
                        color: PlunesColors.GREENCOLOR, fontSize: 16.0),
                  ),
                ),
              ),
              Text(
                "Mins",
                style: TextStyle(fontSize: 14.0),
              )
            ],
          );
  }
}
