import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/commonView/UploadPrescriptionDialog.dart';
import 'package:share/share.dart';

/// New 28/02/2020 - 03:30PM
// ignore: must_be_immutable
class PlockrMainScreen extends BaseActivity {
  static const tag = '/plockrmainscreen';

  @override
  _PlockrMainScreenState createState() => _PlockrMainScreenState();
}

class _PlockrMainScreenState extends State<PlockrMainScreen>
    with TickerProviderStateMixin, ImagePickerListener
    implements DialogCallBack {
  bool cross = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final searchController = new TextEditingController();
  final Map<String, IconData> _data =
      Map.fromIterables(['Share'], [Icons.filter_1]);
  AnimationController _animationController;
  ImagePickerHandler imagePicker;
  var globalHeight, globalWidth;
  Preferences _preferences;
  bool progress = false;
  String _userType = '';
  File _image;

  List<dynamic> reportsList = new List();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  initialize() {
    _preferences = Preferences();
    _userType = _preferences.getPreferenceString(Constants.PREF_USER_TYPE);
    initializeForImageFetching();
  }

  initializeForImageFetching() {
    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {});
    imagePicker = new ImagePickerHandler(this, _animationController, false);
    imagePicker.init();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: getBodyView(),
    );
  }

  Widget getBodyView() {
    return Container(
      child: Column(
        children: <Widget>[
          getUploadReportRow(),
          getSearchRow(),
          getListItemRowView()
        ],
      ),
    );
  }

  Widget getUploadReportRow() {
    return InkWell(
      onTap: () {
        imagePicker.showDialog(context);
      },
      child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 20),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: widget.createTextViews(
                        plunesStrings.uploadReports,
                        16,
                        colorsFile.darkGrey1,
                        TextAlign.start,
                        FontWeight.normal)),
                widget.getAssetIconWidget(
                    plunesImages.uploadIcon, 20, 20, BoxFit.cover)
              ],
            ),
            widget.getSpacer(0.0, 20),
            widget.getDividerRow(context, 0.0, 0.0, 0.0)
          ])),
    );
  }

  Widget getSearchRow() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Card(
          semanticContainer: true,
          elevation: 8,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            height: 55,
            child: Container(
              padding: EdgeInsets.only(left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      cursorColor: Color(CommonMethods.getColorHexFromStr(
                          colorsFile.defaultGreen)),
                      controller: searchController,
                      decoration: InputDecoration.collapsed(
                          hintText: plunesStrings.search),
                      onChanged: (text) {
                        setState(() {
                          if (text.length > 0) {
                            cross = true;
                          } else {
                            cross = false;
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: cross
                          ? InkWell(
                              child: Icon(Icons.close, color: Colors.grey),
                              onTap: () {
                                setState(() {
                                  cross = false;
                                  searchController.text = '';
                                });
                              },
                            )
                          : Icon(Icons.search, color: Colors.grey)),
                ],
              ),
            ),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Color(0xff01d35a)),
                borderRadius: BorderRadius.all(Radius.circular(12))),
          )),
    );
  }

  Widget getListItemRowView() {
    return Expanded(
        child:
            /*reportsList.length == 0? Center(
        child: widget.createTextViews(stringsFile.noRecordsFound, 16, colorsFile.lightGrey1, TextAlign.center, FontWeight.normal),
      ): */
            ListView.builder(
      shrinkWrap: true,
      itemCount: 10 /*reportsList.length*/,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 0),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  /*      showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                   */ /*     ShowImageDetails(
                            data: filter_personel,
                            position: index
                        ),*/ /*
                  );*/
                },
                child: Container(
//                  padding: const EdgeInsets.only(top:8.0,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      getItemImageView(),
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'X-ray FH001111',
                              maxLines: 3,
                              style: TextStyle(
                                  color: Color(0xff5D5D5D),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            Text(
                              '2 days ago',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff5D5D5D)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                'Dr. Anita Joshi HOD, \n Gynecology 10yrs experience \n Fortis Hospital, Gurugram',
                                style: TextStyle(
                                    color: Color(0xff5D5D5D), fontSize: 13)),
//                            Text(filter_personel[index].remarks, maxLines: 1, style: TextStyle(color: Color(0xff5D5D5D), fontSize: 13)),
                          ],
                        ),
                      )),
                      getMenuPopup(index),
                    ],
                  ),
                ),
              ),
              index != 9
                  ? Container(
                      height: 0.3,
                      color: Colors.grey,
                      margin: EdgeInsets.only(top: 20, bottom: 20))
                  : Container(margin: EdgeInsets.only(bottom: 20))
            ],
          ),
        );
      },
    ));
  }

  @override
  fetchImageCallBack(File _image) {
    if (_image != null) {
      // print("image==" + base64Encode(_image.readAsBytesSync()).toString());
      this._image = _image;
      showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  UploadPrescriptionDialog(imageUrl: _image.path.toString()))
          .then((value) {
        if (value != null &&
            value.runtimeType is String &&
            value.toString().trim().isNotEmpty) {
          widget.showInSnackBar(value, PlunesColors.BLACKCOLOR, _scaffoldKey);
        }
      });
    }
  }

  Widget getItemImageView() {
    return Container(
      width: 120,
      height: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Container(
          decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(plunesImages.pdfIcon1)),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      )),
      alignment: Alignment.center,
    );
  }

  Widget getMenuPopup(int index) {
    return Container(
      child: PopupMenuButton<String>(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 5, bottom: 10),
          child: Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
        ),
        padding: EdgeInsets.zero,
        onSelected: (value) {
          showMenuSelection(value, index);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Delete',
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                ),
                Text('Delete')
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Share',
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    Icons.share,
                    color: Colors.grey,
                  ),
                ),
                Text('Share')
              ],
            ),
          ),
        ],
      ),
    );
  }

  showMenuSelection(String value, int index) {
    if (value == 'Delete') {
      CommonMethods.confirmationDialog(
          context, plunesStrings.deleteReportMsg, this);
    } else if (value == "Share") {
      Share.share('www.google.com');
    }
  }

  @override
  dialogCallBackFunction(String action) {
    if (action != null && action == 'DONE') deleteReport();
  }

  void deleteReport() {
    print('Delete');
  }
}
