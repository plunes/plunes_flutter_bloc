import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/FontFile.dart';
import 'package:plunes/res/Http_constants.dart';
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
  bool progress = false, isValidNumber = true;
  UserBloc _userBloc;
  final String _dummyUserId = "PL-1WQPS-S7PN";

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

  bool _isNumber() {
    return (phoneNumberController.text.trim().isNotEmpty &&
        phoneNumberController.text.trim().length >= 1 &&
        (phoneNumberController.text.trim().codeUnitAt(0) >= 48 &&
            phoneNumberController.text.trim().codeUnitAt(0) <= 57));
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
          maxLength: _isNumber() ? 10 : null,
          inputFormatters:
              _isNumber() ? [WhitelistingTextInputFormatter.digitsOnly] : null,
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
    if (text.toString().trim().isEmpty) {
      isValidNumber = false;
      return isValidNumber;
    }
    if (text.toString().trim().length >= 2 &&
        text.toString().trim().substring(0, 2) == "PL") {
//      if (text.toString().trim().length >= _dummyUserId.length) {
      isValidNumber = true;
      return isValidNumber;
//      } else {
//        isValidNumber = false;
//        return isValidNumber;
//      }
    }
    if (CommonMethods.checkIfNumber(text.toString().trim())) {
      if (text.toString().length >= 10) {
        isValidNumber = true;
        return isValidNumber;
      } else {
        isValidNumber = false;
        return isValidNumber;
      }
    } else {
      isValidNumber = false;
      return isValidNumber;
    }
  }

  _setState() {
    if (mounted) setState(() {});
  }

  void submitForOTP() async {
    if (isValidNumber && phoneNumberController.text != '') {
      if (CommonMethods.checkOTPVerification) {
        progress = true;
        _setState();
        await Future.delayed(Duration(milliseconds: 200));
        var result = await _userBloc
            .checkUserExistence(phoneNumberController.text.trim());
        if (result is RequestSuccess) {
          getUserExistenceData(result.response);
        } else if (result is RequestFailed) {
          if (result.requestCode != null &&
              result.requestCode == HttpResponseCode.NOT_FOUND) {
            _sendOtp();
            return;
          }
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
          (_isNumber() && phoneNumberController.text.trim().length != 10)
              ? "Please fill a valid Phone Number"
              : (!_isNumber() && phoneNumberController.text.trim().isNotEmpty)
                  ? "Please fill a valid User Id"
                  : PlunesStrings
                      .usernameCantBeEmpty, //plunesStrings.enterValidNumber,
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
//                      Container(
//                          margin: EdgeInsets.only(top: 50),
//                          child: widget.createTextViews(
//                              PlunesStrings.userName,
//                              20,
//                              colorsFile.darkGrey1,
//                              TextAlign.start,
//                              FontWeight.normal)),
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
                                          visible: !isValidNumber,
                                          child: widget.createTextViews(
                                              (_isNumber() &&
                                                      phoneNumberController.text
                                                              .trim()
                                                              .length !=
                                                          10)
                                                  ? "Please fill a valid Phone Number"
                                                  : (!_isNumber() &&
                                                          phoneNumberController
                                                              .text
                                                              .trim()
                                                              .isNotEmpty)
                                                      ? "Please fill a valid User ID"
                                                      : PlunesStrings
                                                          .usernameCantBeEmpty,
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
                            : Container(
                                margin: EdgeInsets.only(
                                    left: AppConfig.horizontalBlockSize * 30,
                                    right: AppConfig.horizontalBlockSize * 30),
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  onTap: submitForOTP,
                                  child: CustomWidgets().getRoundedButton(
                                      plunesStrings.enter,
                                      AppConfig.horizontalBlockSize * 8,
                                      PlunesColors.GREENCOLOR,
                                      AppConfig.horizontalBlockSize * 0,
                                      AppConfig.verticalBlockSize * 1.2,
                                      PlunesColors.WHITECOLOR),
                                ),
                              ),
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
      if (!CommonMethods.checkIfNumber(phoneNumberController.text.trim())) {
        progress = false;
        _setState();
        widget.showInSnackBar(
            "User ID doesn't exist!", PlunesColors.BLACKCOLOR, _scaffoldKey);
        return;
      }
      _sendOtp();
    } else {
      progress = false;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Login(phone: phoneNumberController.text)));
    }
  }

  void _sendOtp() async {
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
  }
}
