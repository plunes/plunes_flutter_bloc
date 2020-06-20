import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/FontFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';

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

// ignore: must_be_immutable
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
  UserBloc _userBloc;

  @override
  void initState() {
    _userBloc = UserBloc();
    super.initState();
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    super.dispose();
  }

  Widget getEnterPhoneNumberRow() {
    return Container(
      height: 45,
      padding: EdgeInsets.only(left: 10, right: 10),
      margin: EdgeInsets.only(left: 10),
      child: Center(
        child: TextField(
          cursorColor: Color(hexColorCode.defaultGreen),
//          keyboardType: TextInputType.number,
//          maxLength: 10,
//          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
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
              hintText: PlunesStrings.userName,
              counterText: "",
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
    isValidNumber = false;
    return true;
//    if (text.length >= 10 || text.length == 0) {
//      isValidNumber = false;
//      return false;
//    } else {
//      isValidNumber = true;
//      return true;
//    }
  }

  _setState() {
    if (mounted) setState(() {});
  }

  void submitForOTP() async {
    if (!isValidNumber && phoneNumberController.text != '') {
      if (CommonMethods.checkOTPVerification) {
        progress = true;
        _setState();
        await Future.delayed(Duration(milliseconds: 200));
        var result = await _userBloc
            .checkUserExistence(phoneNumberController.text.trim());
        if (result is RequestSuccess) {
          getUserExistenceData(result.response);
        } else if (result is RequestFailed) {
          progress = false;
          _setState();
          await Future.delayed(Duration(milliseconds: 200));
          widget.showInSnackBar(
              result.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
        }
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
          PlunesStrings.usernameCantBeEmpty, //plunesStrings.enterValidNumber,
          PlunesColors.BLACKCOLOR,
          _scaffoldKey);
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
                    child:
                        widget.getAssetImageWidget(plunesImages.firstUserImage),
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
                              PlunesStrings.userName,
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
//                              widget.getCountryBox(),
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
    if (data != null && data['success'] != null && !data['success']) {
      var requestState =
          await _userBloc.getGenerateOtp(phoneNumberController.text.trim());
      progress = false;
      _setState();
      await Future.delayed(Duration(milliseconds: 200));
      if (requestState is RequestSuccess) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CheckOTP(phone: phoneNumberController.text, from: '')));
      } else if (requestState is RequestFailed) {
        widget.showInSnackBar(
            requestState.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    } else {
      progress = false;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Login(phone: phoneNumberController.text)));
    }
  }
}
