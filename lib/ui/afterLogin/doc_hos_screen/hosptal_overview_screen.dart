import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/models/Models.dart';
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
  String _reaTimeInsightFailureCause;

  @override
  void initState() {
    _user = UserManager().getUserDetails();
    _docHosMainInsightBloc = DocHosMainInsightBloc();
    super.initState();
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
            _getActionableInsights(),
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
                                  patientName: "Sonika",
                                  serviceName: "Servic",
                                ),
                                FlatButtonLinks('Kindly Update your price', 15,
                                    null, 78, true),
                                Divider(),
                              ],
                            );
                          },
                          itemCount: 5,
                        );
                },
                initialData: _realTimeInsightsResponse == null
                    ? RequestInProgress()
                    : null,
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

  Widget _getActionableInsights() {
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
                  margin: EdgeInsets.only(right: 20, left: 20, top: 10),
                  child: Text(
                      'Please take action real time Insights to increase your business',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500))),
              FlatButtonLinks('Update here', 15, null, 0, true),
              Divider(color: Colors.black38),
              Container(
                  margin: EdgeInsets.only(right: 20, left: 20, top: 10),
                  child: Text(
                      'Please take action real time Insights to increase your business',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500))),
              FlatButtonLinks('Update here', 15, null, 0, true),
              Divider(color: Colors.black38),
              Container(
                  margin: EdgeInsets.only(right: 20, left: 20, top: 10),
                  child: Text(
                      'Please take action real time Insights to increase your business',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500))),
              FlatButtonLinks('Update here', 15, null, 0, true),
              FlatButtonLinks('View More', 18, null, 0, false),
            ],
          ),
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

  FlatButtonLinks(this.linkName, this.fontSize, this.onTapFunc, this.leftMargin,
      this.isUnderline);

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
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                CustomWidgets().UpdatePricePopUp(),
          );
        },
      ),
    );
  }
}

class PatientServiceInfo extends StatelessWidget {
  final String patientName;
  final String serviceName;
  final String imageUrl;

  PatientServiceInfo({this.patientName, this.serviceName, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
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
        title: Text(
          patientName,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          serviceName,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.timelapse),
          onPressed: () {},
        ));
  }
}

class ListOfPatients extends StatelessWidget {
  final String patientName;
  final Function onTapFun;
  final Color backGColor;

  ListOfPatients(this.patientName, this.backGColor, this.onTapFun);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: backGColor,
          child: Icon(
            Icons.person,
            size: 40,
          ),
        ),
        title: Text(
          patientName,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.timelapse),
          onPressed: () {
            onTapFun();
          },
        ));
  }
}
