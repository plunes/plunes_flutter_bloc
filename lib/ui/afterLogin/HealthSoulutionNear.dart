import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/consultation_tests_procedure_bloc.dart';
import 'package:plunes/models/solution_models/test_and_procedure_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/test_procedure_sub_screen.dart';

// ignore: must_be_immutable
class HealthSolutionNear extends BaseActivity {
  static const tag = 'near_you';

  @override
  _HealthSolutionNearState createState() => _HealthSolutionNearState();
}

class _HealthSolutionNearState extends BaseState<HealthSolutionNear> {
  List<dynamic> healthSolDataList = new List();
  ConsultationTestProcedureBloc _consultationTestProcedureBloc;
  List<TestAndProcedureResponseModel> _testAndProcedures;
  String _failureCause;

  final _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);
  final _hospImgUrl = [
    CustomWidgets().getImageFromUrl(
        "https://www.polarishospitals.com/wp-content/uploads/2019/12/Polaris-Logo_2-1.png",
        boxFit: BoxFit.contain),
    CustomWidgets().getImageFromUrl(
        "https://www.neelkanthhospital.com/images/logo.png",
        boxFit: BoxFit.fill),
    CustomWidgets().getImageFromUrl(
        "https://lh3.googleusercontent.com/proxy/qJRCgwv_Z0oGUbm8m6Ei4woYuwcIclMjlUhXldGnWpgXzRiHVHUoODC7rf9raFJqxTYkwvBTfnLbEnwE9pMyYVz6j_jNiUnPzSTMD8hNQi2aKPYjNBruNc1r0C8eZ1COgnoiAFAu5Qu75i9ojLxjuwUyRupMItFPWf1pw7K6e5LADFpJY3t8",
        boxFit: BoxFit.fill)
  ];

  final _labsImgUrl = [
    CustomWidgets().getImageFromUrl(
        "https://lims.maxlab.co.in/Maxlab_web/App_Themes/WinXP_Silver/Images/Max_Lab_Logo.png",
        boxFit: BoxFit.contain),
    CustomWidgets().getImageFromUrl(
        "https://assets.lybrate.com/q_auto,f_auto,w_400,h_300,c_fill,g_auto/imgs/ps/cl/8f56b6ebcb0dac350b4ff23918154fc7/deb1f81ba89f012ddd7714163b0c4da2/Kaya-Skin-Clinic-C.G.Road-Ahmedabad-62faa8.jpg",
        boxFit: BoxFit.contain),
    CustomWidgets().getImageFromUrl(
        "https://img4.nbstatic.in/tr:w-500/5f2bd3a4c9e77c000b0e1479.jpg",
        boxFit: BoxFit.contain),
  ];

  @override
  void initState() {
    _testAndProcedures = [];
    _consultationTestProcedureBloc = ConsultationTestProcedureBloc();
    _getDetails();
    super.initState();
//    getData();
  }

  @override
  void dispose() {
    _consultationTestProcedureBloc?.dispose();
    super.dispose();
  }

  _getDetails() {
    _consultationTestProcedureBloc.getDetails(true);
  }

  onTap(TestAndProcedureResponseModel testAndProcedure) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestProcedureCatalogueScreen(
                  isProcedure: true,
                  specialityId: testAndProcedure.specialityId,
                  title: testAndProcedure.sId,
                )));
  }

  Widget _renderTestAndProcedures() {
    return StreamBuilder<RequestState>(
      builder: (context, snapShot) {
        if (snapShot.data is RequestInProgress) {
          return CustomWidgets().getProgressIndicator();
        }
        if (snapShot.data is RequestSuccess) {
          RequestSuccess _requestSuccessObject = snapShot.data;
          _testAndProcedures = [];
          _testAndProcedures = _requestSuccessObject.response;
          if (_testAndProcedures.isEmpty) {
            _failureCause = PlunesStrings.proceduresNotAvailable;
          }
        } else if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailed = snapShot.data;
          _failureCause = _requestFailed.failureCause;
        }
        return _testAndProcedures == null || _testAndProcedures.isEmpty
            ? CustomWidgets().errorWidget(_failureCause,
                onTap: () => _getDetails(), isSizeLess: true)
            : _showItems();
      },
      stream: _consultationTestProcedureBloc.baseStream,
      initialData: RequestInProgress(),
    );
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    return Scaffold(
      key: scaffoldKey,
      appBar: widget.getAppBar(context, plunesStrings.availUpTo, true),
      backgroundColor: PlunesColors.WHITECOLOR,
      body: _getBody(),
    );
  }

  _getBody() {
    return SingleChildScrollView(
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 3),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 3),
              child: Text(
                "Our Partners",
                style: TextStyle(
                  fontSize: AppConfig.extraLargeFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _hospitaList(),
            _labsList(),
            _doctorsList(),
            _mostBookedServices(),
            _renderTestAndProcedures(),
          ],
        ),
      ),
    );
  }

  _hospitaList() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "Hospitals",
                style: TextStyle(fontSize: AppConfig.largeFont),
              ),
              SizedBox(
                width: AppConfig.horizontalBlockSize * 23,
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding:
                      EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
                  child: Text(
                    "See all",
                    style: TextStyle(
                      color: PlunesColors.SPARKLINGGREEN,
                      fontSize: AppConfig.smallFont,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          height: AppConfig.verticalBlockSize * 10,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hospImgUrl.length,
            itemBuilder: (context, itemIndex) {
              return InkWell(
                onTap: () {},
                child: Container(
                  width: AppConfig.horizontalBlockSize * 28.2,
                  decoration: ShapeDecoration(
//                            color: PlunesColors.GREYCOLOR,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 1.0,
                          style: BorderStyle.solid,
                          color: PlunesColors.BLACKCOLOR.withOpacity(.2)),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 1),
                  child: _hospImgUrl[itemIndex],
                  padding: EdgeInsets.all(5),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _labsList() {
    return Column(
      children: <Widget>[
        Container(
          height: 0.5,
          width: double.infinity,
          color: PlunesColors.GREYCOLOR,
          margin:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
        ),
        Container(
          margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "Diagnostic Labs",
                style: TextStyle(fontSize: AppConfig.largeFont),
              ),
              SizedBox(
                width: AppConfig.horizontalBlockSize * 15,
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding:
                      EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
                  child: Text(
                    "See all",
                    style: TextStyle(
                      color: PlunesColors.SPARKLINGGREEN,
                      fontSize: AppConfig.smallFont,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          height: AppConfig.verticalBlockSize * 10,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _labsImgUrl.length,
            itemBuilder: (context, itemIndex) {
              return InkWell(
                onTap: () {},
                child: Container(
                  width: AppConfig.horizontalBlockSize * 28.2,
                  decoration: ShapeDecoration(
//                            color: PlunesColors.GREYCOLOR,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 1.0,
                          style: BorderStyle.solid,
                          color: PlunesColors.BLACKCOLOR.withOpacity(.2)),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 1),
                  padding: EdgeInsets.all(5),
                  child: _labsImgUrl[itemIndex],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _doctorsList() {
    return Column(
      children: <Widget>[
        Container(
          height: 0.5,
          width: double.infinity,
          color: PlunesColors.GREYCOLOR,
          margin:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
        ),
        Container(
          margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "Doctors",
                style: TextStyle(fontSize: AppConfig.largeFont),
              ),
              SizedBox(
                width: AppConfig.horizontalBlockSize * 25,
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding:
                      EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
                  child: Text(
                    "See all",
                    style: TextStyle(
                      color: PlunesColors.SPARKLINGGREEN,
                      fontSize: AppConfig.smallFont,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          height: AppConfig.verticalBlockSize * 15,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, itemIndex) {
              return InkWell(
                onTap: () {},
                child: Container(
                  width: AppConfig.horizontalBlockSize * 28.2,
                  decoration: ShapeDecoration(
//                            color: PlunesColors.GREYCOLOR,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 1.0,
                          style: BorderStyle.solid,
                          color: PlunesColors.BLACKCOLOR.withOpacity(.2)),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 1),
                  padding: EdgeInsets.all(5),
                ),
              );
            },
          ),
        ),
        Container(
          height: 0.5,
          width: double.infinity,
          color: PlunesColors.GREYCOLOR,
          margin:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
        ),
      ],
    );
  }

  _mostBookedServices() {
    return Column(
      children: <Widget>[_pageBookedServices(), _pageCircleIndicator()],
    );
  }

  _pageBookedServices() {
    return Container(
      margin: EdgeInsets.only(
          left: 8,
          right: 8,
          top: AppConfig.verticalBlockSize * 4,
          bottom: AppConfig.verticalBlockSize * .5),
      height: AppConfig.verticalBlockSize * 20,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {},
            child: Container(
              decoration: ShapeDecoration(
//                            color: PlunesColors.GREYCOLOR,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: PlunesColors.BLACKCOLOR.withOpacity(.2)),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 1),
              padding: EdgeInsets.all(5),
            ),
          );
        },
        onPageChanged: (int index) {
          _currentPageNotifier.value = index;
        },
      ),
    );
  }

  _pageCircleIndicator() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CirclePageIndicator(
          dotColor: PlunesColors.GREYCOLOR,
          selectedDotColor: PlunesColors.SPARKLINGGREEN,
          itemCount: 3,
          currentPageNotifier: _currentPageNotifier,
        ),
      ),
    );
  }

//  Widget _showDialog(
//      BuildContext context, String name, String info, String image) {
//    return new CupertinoAlertDialog(
//      content: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          GestureDetector(
//            onTap: () {
//              Navigator.pop(context);
//            },
//            child: Container(
//              child: Icon(Icons.close),
//              alignment: Alignment.topRight,
//            ),
//          ),
//          Center(child: widget.getAssetImageWidget(image)),
//          widget.getSpacer(0, 20.0),
//          Text(
//            '$name Procedures as',
//            textAlign: TextAlign.center,
//            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//          ),
//          widget.getSpacer(0, 20.0),
//          Center(
//            child: Text(info,
//                maxLines: 6,
//                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100)),
//          ),
//          Center(
//            child: Text("& many more",
//                maxLines: 6,
//                style: TextStyle(
//                    color: Color(0xff01d35a),
//                    fontSize: 16,
//                    fontWeight: FontWeight.w100)),
//          ),
//          widget.getSpacer(0, 20.0),
//          widget.getDefaultButton(plunesStrings.ok, 150.0, 42, onBackPressed),
//        ],
//      ),
//    );
//  }

  onBackPressed() {
    Navigator.of(context).pop();
  }

  void getData() {
    for (int i = 0; i < 9; i++) {
      Map map = new Map();
      map['Image'] = plunesImages.healthSolNearImageArray[i];
      map['Info'] = plunesStrings.healthSolInfoArray[i];
      map['Specialist'] = plunesStrings.healthSolSpecialistArray[i];
      map['Procedure'] = plunesStrings.healthSolProcedureArray[i];
      healthSolDataList.add(map);
    }
  }

  Widget _showItems() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              top: AppConfig.verticalBlockSize * 4,
              bottom: AppConfig.verticalBlockSize * 1),
          child: Text(
            "Explore More",
            style: TextStyle(
              fontSize: AppConfig.largeFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
          child: Text(
            PlunesStrings.exploreSpecialities,
            style: TextStyle(
                fontSize: AppConfig.mediumFont, color: PlunesColors.GREYCOLOR),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _testAndProcedures?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: PlunesColors.WHITECOLOR,
                    margin: EdgeInsets.all(8),
                    child: InkWell(
                      onTap: () => onTap(_testAndProcedures[index]),
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(width: 0.5, color: Colors.grey)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: CustomWidgets().getImageFromUrl(
                                  "https://specialities.s3.ap-south-1.amazonaws.com/${_testAndProcedures[index].sId}.png",
                                  boxFit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: widget.createTextViews(
                                  _testAndProcedures[index].sId,
                                  AppConfig.smallFont,
                                  colorsFile.black0,
                                  TextAlign.center,
                                  FontWeight.w500),
                            ),
//                        Expanded(
//                          flex: 2,
//                          child: Text("healthSolDataList[index]['Info']",
//                              maxLines: 4,
//                              textAlign: TextAlign.center,
//                              style: TextStyle(fontSize: 13)),
//                        ),
//                             Expanded(
//                                 flex: 1,
//                                 child: Padding(
//                                     padding: const EdgeInsets.only(top: 1.0),
//                                     child: widget.createTextViews(
//                                         plunesStrings.viewMore,
//                                         AppConfig.verySmallFont - 1,
//                                         colorsFile.defaultGreen,
//                                         TextAlign.center,
//                                         FontWeight.normal)))
                          ],
                        ),
                      ),
                    ),
                  );
                },
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.2))),
      ],
    );
  }
}
