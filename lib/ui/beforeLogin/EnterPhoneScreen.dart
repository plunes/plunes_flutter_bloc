import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/FontFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/resources/network/Urls.dart';

import 'CheckOTP.dart';
import 'Login.dart';
import 'Registration.dart';

/*
 * Created by  -   Plunes Technologies .
 * Developer   -   Manvendra Kumar Singh
 * Description -   EnterPhoneScreen class is used for check user existence in the database using enter mobile number
 *                 it'll check that user is already registered or not if yes then it'll go for login into the application
 *                 or if No then it'll go for registration.
 */

class EnterPhoneScreen extends BaseActivity {
  static const tag = 'enter_phonescreen';
  String from;

  EnterPhoneScreen({Key key, this.from}) : super(key: key);

  @override
  _EnterPhoneScreenState createState() => _EnterPhoneScreenState();
}

class _EnterPhoneScreenState extends State<EnterPhoneScreen>
    implements DialogCallBack {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final phoneNumberController = new TextEditingController();
  bool progress = false, isValidNumber = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  Widget getEnterPhoneNumberRow() {
    return Container(
      height: 45,
      padding: EdgeInsets.only(left: 10, right: 10),
//      decoration: widget.myBoxDecoration(),
      margin: EdgeInsets.only(left: 10),
      child: Center(
        child: TextField(
          cursorColor: Color(hexColorCode.defaultGreen),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          style: TextStyle(
              fontSize: 18,
              color: Color(CommonMethods.getColorHexFromStr(colorsFile.black0)),
              fontFamily: fontFile.appDefaultFont),
          onChanged: (text) {
            setState(() {
              validation(text);
            });
          },
          decoration: InputDecoration(
              hintText: plunesStrings.enterNumber,
              hintStyle: TextStyle(
                  fontSize: 18,
                  color: Color(
                      CommonMethods.getColorHexFromStr(colorsFile.black0)),
                  fontFamily: fontFile.appDefaultFont)),
          controller: phoneNumberController,
        ),
      ),
    );
  }

  bool validation(text) {
    if (CommonMethods.checkIfNumber(text)) {
      if (text.length == 10 || text.length == 0) {
        isValidNumber = false;
        return false;
      } else {
        isValidNumber = true;
        return true;
      }
    } else {
      isValidNumber = true;
      return true;
    }
  }

  void submitForOTP() async {
    if (!isValidNumber && phoneNumberController.text != '') {
      if (CommonMethods.checkOTPVerification) {
        progress = true;
        bloc.checkUserExistence(context, this, phoneNumberController.text);
        bloc.isUserExist.listen((data) {
          getUserExistenceData(data);
        }, onDone: () {
          bloc.dispose();
        });
      } else {
        progress = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Registration(phone: phoneNumberController.text)));
      }
    } else
      widget.showInSnackBar(
          plunesStrings.enterValidNumber, Colors.red, _scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;

    return Scaffold(
        key: _scaffoldKey,
        appBar: widget.from == plunesStrings.login
            ? widget.getAppBar(context, '', true)
            : null,
        body: GestureDetector(
          onTap: () {
            CommonMethods.hideSoftKeyboard();
          },
          child: Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: widget
                        .getAssetImageWidget(assetsImageFile.firstUserImage),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                          child: widget.createTextViews(
                              plunesStrings.enterANewEra,
                              23,
                              colorsFile.darkBrown,
                              TextAlign.center,
                              FontWeight.normal)),
                      Container(
                          margin: EdgeInsets.only(top: 50),
                          child: widget.createTextViews(
                              plunesStrings.phoneNumber,
                              20,
                              colorsFile.darkGrey1,
                              TextAlign.start,
                              FontWeight.normal)),
                      Container(
                          margin: EdgeInsets.only(top: 20, bottom: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              widget.getCountryBox(),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  getEnterPhoneNumberRow(),
                                  Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: Visibility(
                                          visible: isValidNumber,
                                          child: widget.createTextViews(
                                              plunesStrings.enterValidNumber,
                                              14,
                                              colorsFile.redColor,
                                              TextAlign.start,
                                              FontWeight.normal)))
                                ],
                              ))
                            ],
                          )),
                      Center(
                        child: progress
                            ? SpinKitThreeBounce(
                                color: Color(hexColorCode.defaultGreen),
                                size: 30.0,
                              )
                            : widget.getDefaultButton(
                                plunesStrings.enter, 130.0, 42, submitForOTP),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  dialogCallBackFunction(String action) {}

  void getUserExistenceData(data) async {
    Constants.OTP = CommonMethods.getRandomOTP();
    if (data != null && data['success'] != null && !data['success']) {
      bloc.sendOTP(
          context,
          this,
          (urls.sendOTPUrl +
              phoneNumberController.text.trim() +
              urls.otpConfig));
      bloc.userOTP.listen((data) {
        if (data['type'] != null && data['type'] == 'success') {
          progress = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CheckOTP(phone: phoneNumberController.text, from: '')));
        }
      }, onDone: () {
        bloc.dispose();
      });
    } else {
      progress = false;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Login(phone: phoneNumberController.text)));
    }
  }
}
