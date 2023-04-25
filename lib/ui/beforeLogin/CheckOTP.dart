import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';

// import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pinput.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// import 'package:quiver/async.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import '../../Utils/custom_widgets.dart';
import 'ChangePassword.dart';
import 'Registration.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - CheckOTP class is used for OTP verification by entering the four digit otp code.
 */

// ignore: must_be_immutable
class CheckOTP extends BaseActivity {
  static const tag = '/checkOTP';
  final String? phone, from;
  bool? isProfessional;

  CheckOTP({this.phone, this.from, this.isProfessional});

  @override
  _CheckOTPState createState() => _CheckOTPState();
}

class _CheckOTPState extends State<CheckOTP> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool progress = false, time = true, resend = false, errorMsg = false;
  int _start = 60, _current = 60;
  TextEditingController textEditingController = TextEditingController(text: "");
  CountdownTimerController? controller;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;

  void onEnd() {
    print("resend____:-----true is sending");
    set_State(true);
  }

  UserBloc? _userBloc;

  void _checkOTP(String pin, BuildContext context) async {
    print("------entering____otp=$pin");

    if (pin == null || pin.isEmpty || pin.length != 4) {
      widget.showInSnackBar(
          PlunesStrings.invalidOtp, PlunesColors.BLACKCOLOR, scaffoldKey!);
      return;
    }
    var result = await _userBloc!.getVerifyOtp(widget.phone, pin,
        iFromForgotPassword: widget.from == plunesStrings.forgotPasswordTitle,
        isProfessional: widget.isProfessional ?? false);
    if (result is RequestSuccess) {
      VerifyOtpResponse? verifyOtpResponse = result.response;
      if (verifyOtpResponse != null &&
          verifyOtpResponse.success != null &&
          verifyOtpResponse.success!) {
        if (widget.from == plunesStrings.forgotPasswordTitle)
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangePassword(
                      phone: widget.phone,
                      from: plunesStrings.createPassword,
                      otp: pin)));
        else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Registration(phone: widget.phone)));
        }
      } else {
        widget.showInSnackBar(
            PlunesStrings.invalidOtp, PlunesColors.BLACKCOLOR, scaffoldKey!);
      }
    } else if (result is RequestFailed) {
      widget.showInSnackBar(
          result.failureCause, PlunesColors.BLACKCOLOR, scaffoldKey!);
    }
  }

  void sendOtp() async {
    String? signature = await AppConfig.getAppSignature();
    var requestState = await _userBloc!.getGenerateOtp(widget.phone,
        iFromForgotPassword: widget.from == plunesStrings.forgotPasswordTitle,
        signature: signature);
    if (requestState is RequestSuccess) {
      _start = 60;
      _current = 60;
      textEditingController.text = "";
    } else if (requestState is RequestFailed) {
      widget.showInSnackBar(
          requestState.failureCause, PlunesColors.BLACKCOLOR, scaffoldKey!);
    }
    print("resend____:-----false is sending");
    controller!.start();
    set_State(false);
  }

  set_State(var resendChange) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {
        resend = resendChange;
        print("resend____:$resend");
      });
    });
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  void initState() {
    _userBloc = UserBloc();
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    super.initState();
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Theme.of(context).primaryColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    controller?.dispose();
    super.dispose();
  }

  double _height = 0;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    CommonMethods.globalContext = context;
    return WillPopScope(
      onWillPop: () async {
        CommonMethods.hideSoftKeyboard();
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          key: scaffoldKey,
          appBar: widget.getAppBar(context, plunesStrings.checkOTP, true,
                  func: () => CommonMethods.hideSoftKeyboard())
              as PreferredSizeWidget?,
          body: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(),
            child: _body(),
          )),
    );
  }

  _body() {
    return Container(
      height: _height,
      alignment: Alignment.center,
      child: ListView(
        // mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 100,
            alignment: Alignment.center,
            child: widget.createTextViews(plunesStrings.enterYourOTPMsg, 22,
                colorsFile.black0, TextAlign.center, FontWeight.normal),
          ),
          Container(
            padding: EdgeInsets.only(
                left: Platform.isAndroid ? 30 : 60.0,
                right: 20, top: 30, bottom: 0),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            height: 100,
            child: Center(
              child: Platform.isAndroid
                  ? TextFieldPin(
                      textController: textEditingController,
                      autoFocus: true,
                      codeLength: 4,
                      alignment: MainAxisAlignment.center,
                      defaultBoxSize: 46.0,
                      margin: 10,
                      selectedBoxSize: 46.0,
                      textStyle: const TextStyle(fontSize: 16),
                      defaultDecoration: _pinPutDecoration.copyWith(
                          border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6))),
                      selectedDecoration: _pinPutDecoration,
                      onChange: (code) {
                        _onOtpCallBack(code, false);
                        setState(() {

                        });
                      })
                  : Pinput(
                      onChanged: (value) {
                        _checkOTP(value, context);
                      },
                      defaultPinTheme: defaultPinTheme,
                      // submittedPinTheme: submittedPinTheme(),
                      // focusedPinTheme: focusedPinTheme(),
                      // fieldsCount: 4,
                      // autoFocus: true,
                      // spaceBetween: 20,
                      // textStyle: TextStyle(
                      //   color: Color(CommonMethods.getColorHexFromStr(
                      //       colorsFile.black0)),
                      //   fontSize: 22,
                      // ),
                      // onSubmit: (String pin) => _checkOTP(pin, context),
                      keyboardType: TextInputType.phone,
                      // inputDecoration: InputDecoration(
                      //   counterText: "",
                      //   contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                      //   focusedBorder: UnderlineInputBorder(
                      //     borderRadius: const BorderRadius.all(
                      //       const Radius.circular(10.0),
                      //     ),
                      //     borderSide: BorderSide(
                      //         color: Color(hexColorCode.defaultGreen),
                      //         width: 3.0),
                      //   ),
                      //   enabledBorder: UnderlineInputBorder(
                      //     borderRadius: const BorderRadius.all(
                      //       const Radius.circular(10.0),
                      //     ),
                      //     borderSide: BorderSide(
                      //         color: Color(hexColorCode.defaultGreen),
                      //         width: 3.0),
                      //   ),
                      // ),
                      // clearButtonIcon:
                      //     Icon(Icons.clear, color: Colors.transparent),
                      // pasteButtonIcon: Icon(Icons.content_paste,
                      //     color: Colors.transparent),
                    ),
            ),
          ),
          !resend
              ? Container(
                  height: 50,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(plunesStrings.resendCodeIn,
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    colorsFile.black0)))),
                        CountdownTimer(
                          endWidget: const Text(""),
                          textStyle: TextStyle(
                              fontSize: 16,
                              color: Color(hexColorCode.defaultGreen)),
                          controller: controller,
                          onEnd: onEnd,
                          endTime: endTime,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 50,
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 30,
                      right: AppConfig.horizontalBlockSize * 30),
                  child: Center(
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      onTap: sendOtp,
                      child: CustomWidgets().getRoundedButton(
                          plunesStrings.resendCode,
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
    );
  }

  _onOtpCallBack(String otpCode, bool isAutofill) {
    if (otpCode != null && otpCode.length == 4) {
      _checkOTP(otpCode, context);
    }
  }
}
