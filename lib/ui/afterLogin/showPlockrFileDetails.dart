import 'package:flutter/material.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/plockr_web_view.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/plockr_model/plockr_response_model.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowImageDetails extends BaseActivity {
  final UploadedReports uploadedReport;

  ShowImageDetails(this.uploadedReport);

  @override
  _ShowImageDetailsState createState() =>
      _ShowImageDetailsState(uploadedReport);
}

class _ShowImageDetailsState extends BaseState<ShowImageDetails> {
  final UploadedReports uploadedReport;

  _ShowImageDetailsState(this.uploadedReport);

  final Map<String, IconData> _data =
      Map.fromIterables(['Share'], [Icons.filter_1]);

  //// Other Details
  bool reasons = false;
  bool consumption = false;
  bool avoid = false;
  bool precaution = false;
  bool medicine = false;
  bool remarks = false;
  bool test = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Container()),
                  Container(
                    child: GestureDetector(
                      child: Container(
                        child: Icon(Icons.clear),
                        alignment: Alignment.topRight,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
                onTap: () async {
                  String url = uploadedReport.reportUrl;

                  if (url == null || url.isEmpty) {
                    widget.showInSnackBar(PlunesStrings.unableToOpen,
                        PlunesColors.BLACKCOLOR, scaffoldKey);
                    return;
                  }
                  if (uploadedReport.fileType != null &&
                      uploadedReport.fileType == UploadedReports.dicomFile) {
                    String plockrUrl =
                        "https://www.plunes.com/dicom_viewer?fileId=$url";
                    print(plockrUrl);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PlockrWebViewContainer(plockrUrl)));
                  } else {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  }
                },
                //onTap: () {},
//                  if (!data[position].reportUrl.contains(".pdf")) {
//                    showDialog(
//                      context: context,
//                      builder: (
//                        BuildContext context,
//                      ) =>
//                          ProfileImage(
//                        image_url: data[position].reportUrl,
//                        text: " ",
//                      ),
//                    );
//                  }
                //               },
//                child: data[position].reportUrl.contains(".pdf")
//                    ?
////                InkWell(
////                        child: Container(
////                          width: double.infinity,
////                          height: 250.0,
////                          decoration: BoxDecoration(color: Colors.grey),
////                          child: Stack(
////                            children: <Widget>[
////                              Stack(
////                                children: <Widget>[
////                                  Center(
////                                      child: Image.asset(
////                                    'assets/images/plockr/pdf.png',
////                                    width: 180,
////                                    height: 160,
////                                  )),
////                                  Center(
////                                    child: Container(
////                                      width: double.infinity,
////                                      color: Colors.grey,
////                                      child: Container(
////                                          width: double.infinity,
////                                          height: 250.0,
////                                          decoration: BoxDecoration(
////                                              image: DecorationImage(
////                                                  fit: BoxFit.cover,
////                                                  image: NetworkImage(
////                                                      data[position].reportUrl +
////                                                          '.thumbnail.png'))))
////
//////                          FadeInImage(image: NetworkImage(data[position].reportUrl+ '.thumbnail.png'), placeholder: AssetImage('assets/images/plockr/pdf.png'))
////                                      ,
////                                    ),
////                                  ),
////                                ],
////                              ),
////                              Container(
////                                height: 250,
////                                decoration:
////                                    BoxDecoration(color: Color(0xff60000000)),
////                              ),
////                              Center(
////                                  child: Text("Tap to view file",
////                                      style: TextStyle(
////                                          color: Colors.white, fontSize: 20)))
////                            ],
////                          ),
////                          alignment: Alignment.center,
////                        ),
////                        onTap: () async {
////                          String url = data[position].reportUrl;
////
////                          if (await canLaunch(url)) {
////                            await launch(url);
////                          } else {
////                            throw 'Could not launch $url';
////                          }
////                        },
////                      )
//                    : data[position].reportUrl.contains(".doc")
//                        ?
//                        InkWell(
//                            child: Container(
//                              width: double.infinity,
//                              height: 250.0,
//                              decoration: BoxDecoration(
//                                  borderRadius:
//                                      BorderRadius.all(Radius.circular(8.0)),
//                                  color: Colors.grey),
//                              child: Text("Tap to view file",
//                                  style: TextStyle(
//                                      color: Colors.white, fontSize: 20)),
//                              alignment: Alignment.center,
//                            ),
//                            onTap: () async {
//                              String url = data[position].reportUrl;
//
//                              if (await canLaunch(url)) {
//                                await launch(url);
//                              } else {
//                                throw 'Could not launch $url';
//                              }
//                            },
//                          )
//                        : data[position].reportUrl.contains(".docx")
//                            ? InkWell(
//                                child: Container(
//                                  width: double.infinity,
//                                  height: 250.0,
//                                  decoration: BoxDecoration(
//                                      borderRadius: BorderRadius.all(
//                                          Radius.circular(8.0)),
//                                      color: Colors.grey),
//                                  child: Text("Tap to view file",
//                                      style: TextStyle(
//                                          color: Colors.white, fontSize: 20)),
//                                  alignment: Alignment.center,
//                                ),
//                                onTap: () async {
//                                  String url = data[position].reportUrl;
//
//                                  if (await canLaunch(url)) {
//                                    await launch(url);
//                                  } else {
//                                    throw 'Could not launch $url';
//                                  }
//                                },
//                              )
//                            :
                child: Container(
                  width: double.infinity,
                  height: 250.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(uploadedReport.reportThumbnail)),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            color: Color(0xff90000000)),
                      ),
                      Center(
                          child: Text("Tap to view file",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)))
                    ],
                  ),
                  alignment: Alignment.center,
                )),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    uploadedReport.reportName.trimLeft(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    DateUtil.getDuration(uploadedReport.createdTime),
                    style: TextStyle(fontSize: 12),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text("Report Created By:",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        uploadedReport.userName,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        reasons = !reasons;
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Diagnosis",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          reasons
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Visibility(
                    child: Text(
                        uploadedReport.reasonDiagnosis ?? PlunesStrings.NA),
                    visible: reasons,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        medicine = !medicine;
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Medicine",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          medicine
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Visibility(
                    child: Text(uploadedReport.medicines ?? PlunesStrings.NA),
                    visible: medicine,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        test = !test;
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Test",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          test
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Visibility(
                    child: Text(uploadedReport.test ?? PlunesStrings.NA),
                    visible: test,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        consumption = !consumption;
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Consumption (Diet)",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          consumption
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Visibility(
                      child: Text(
                          uploadedReport.consumptionDiet ?? PlunesStrings.NA),
                      visible: consumption),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        avoid = !avoid;
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Avoid (Diet)",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          avoid
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Visibility(
                    child: Text(uploadedReport.avoidDiet ?? PlunesStrings.NA),
                    visible: avoid,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        precaution = !precaution;
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Precautions",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          precaution
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Visibility(
                    child: Text(uploadedReport.precautions ?? PlunesStrings.NA),
                    visible: precaution,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        remarks = !remarks;
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Remarks",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          remarks
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Visibility(
                    child: Text(uploadedReport.remarks ?? PlunesStrings.NA),
                    visible: remarks,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
