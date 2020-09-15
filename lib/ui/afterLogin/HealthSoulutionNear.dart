import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
      body: _renderTestAndProcedures(),
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
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 20),
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: CustomWidgets().getImageFromUrl(
                              "https://specialities.s3.ap-south-1.amazonaws.com/${_testAndProcedures[index].sId}.png",
                              boxFit: BoxFit.contain),
                        ),
                        Expanded(
                          flex: 2,
                          child: widget.createTextViews(
                              _testAndProcedures[index].sId,
                              16,
                              colorsFile.black0,
                              TextAlign.center,
                              FontWeight.w600),
                        ),
//                        Expanded(
//                          flex: 2,
//                          child: Text("healthSolDataList[index]['Info']",
//                              maxLines: 4,
//                              textAlign: TextAlign.center,
//                              style: TextStyle(fontSize: 13)),
//                        ),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: widget.createTextViews(
                                    plunesStrings.viewMore,
                                    13,
                                    colorsFile.defaultGreen,
                                    TextAlign.center,
                                    FontWeight.normal)))
                      ],
                    ),
                  ),
                ),
              );
            },
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.0 / 1.0)));
  }
}
