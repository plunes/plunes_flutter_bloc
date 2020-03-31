import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

class HealthSolutionNear extends BaseActivity {
  static const tag = 'near_you';

  @override
  _HealthSolutionNearState createState() => _HealthSolutionNearState();
}

class _HealthSolutionNearState extends State<HealthSolutionNear> {
  List<dynamic> healthSolDataList = new List();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    return Scaffold(
      appBar: widget.getAppBar(context, plunesStrings.availUpTo, true),
      backgroundColor: Colors.white,
      body: Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: healthSolDataList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(width: 0.5, color: Colors.grey)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        widget.getAssetIconWidget(
                            healthSolDataList[index]['Image'],
                            70,
                            70,
                            BoxFit.contain),
                        SizedBox(height: 10),
                        widget.createTextViews(
                            healthSolDataList[index]['Specialist'],
                            16,
                            colorsFile.black0,
                            TextAlign.center,
                            FontWeight.w600),
                        SizedBox(height: 10),
                        Text(healthSolDataList[index]['Info'],
                            maxLines: 4,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13)),
                        Expanded(
                            child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (
                                BuildContext context,
                              ) =>
                                  _showDialog(
                                      context,
                                      healthSolDataList[index]['Procedure'],
                                      healthSolDataList[index]['Info'],
                                      healthSolDataList[index]['Image']),
                            );
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.createTextViews(
                                  plunesStrings.viewMore,
                                  13,
                                  colorsFile.defaultGreen,
                                  TextAlign.center,
                                  FontWeight.normal)),
                        ))
                      ],
                    ),
                  ),
                );
              },
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.0 / 1.4))),
    );
  }

  Widget _showDialog(
      BuildContext context, String name, String info, String image) {
    return new CupertinoAlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              child: Icon(Icons.close),
              alignment: Alignment.topRight,
            ),
          ),
          Center(child: widget.getAssetImageWidget(image)),
          widget.getSpacer(0, 20.0),
          Text(
            '$name Procedures as',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          widget.getSpacer(0, 20.0),
          Center(
            child: Text(info,
                maxLines: 6,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100)),
          ),
          Center(
            child: Text("& many more",
                maxLines: 6,
                style: TextStyle(
                    color: Color(0xff01d35a),
                    fontSize: 16,
                    fontWeight: FontWeight.w100)),
          ),
          widget.getSpacer(0, 20.0),
          widget.getDefaultButton(plunesStrings.ok, 150.0, 42, onBackPressed),
        ],
      ),
    );
  }

  onBackPressed() {
    Navigator.of(context).pop();
  }

  void getData() {
    for (int i = 0; i < 9; i++) {
      Map map = new Map();
      map['Image'] = assetsImageFile.healthSolNearImageArray[i];
      map['Info'] = plunesStrings.healthSolInfoArray[i];
      map['Specialist'] = plunesStrings.healthSolSpecialistArray[i];
      map['Procedure'] = plunesStrings.healthSolProcedureArray[i];
      healthSolDataList.add(map);
    }
  }
}
