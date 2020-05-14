import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:quiver/async.dart';

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
  final String phone, from;

  CheckOTP({this.phone, this.from});

  @override
  _CheckOTPState createState() => _CheckOTPState();
}

class _CheckOTPState extends BaseState<CheckOTP> {
  bool progress = false, time = true, resend = false, errorMsg = false;
  int _start = 30, _current = 30;
  CountdownTimer countDownTimer;

  void _checkOTP(String pin, BuildContext context) async {
    if (pin == null || pin.isEmpty || pin.length != 4) {
      widget.showInSnackBar(
          PlunesStrings.invalidOtp, PlunesColors.BLACKCOLOR, scaffoldKey);
      return;
    }
    var result = await UserBloc().getVerifyOtp(widget.phone, pin);
    if (result is RequestSuccess) {
      VerifyOtpResponse verifyOtpResponse = result.response;
      if (verifyOtpResponse != null &&
          verifyOtpResponse.success != null &&
          verifyOtpResponse.success) {
        if (widget.from == plunesStrings.forgotPasswordTitle)
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangePassword(
                      phone: widget.phone,
                      from: plunesStrings.createPassword)));
        else
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Registration(phone: widget.phone)));
      } else {
        widget.showInSnackBar(
            PlunesStrings.invalidOtp, PlunesColors.BLACKCOLOR, scaffoldKey);
      }
    } else if (result is RequestFailed) {
      widget.showInSnackBar(
          result.failureCause, PlunesColors.BLACKCOLOR, scaffoldKey);
    }
  }

  void send_otp() async {
    /* var rng = new Random();
    var code = rng.nextInt(9000) + 1000;
    print(code);
    Config.OTP = code.toString();

    String url = "https://control.msg91.com/api/sendotp.php" +
        "?authkey=" +
        config.Config.otp_auth_key +
        "&mobile=91" +
        widget.phone +
        "&sender=" +
        config.Config.sender_id +
        "&otp=" +
        code.toString();
    startTimer();
    Post p = await sendotp(url);
    print("data getting ## =====" + p.type);*/
    var requestState = await UserBloc().getGenerateOtp(widget.phone);
    if (requestState is RequestSuccess) {
      _start = 30;
      _current = 30;
      countDownTimer?.cancel();
      startTimer();
    } else if (requestState is RequestFailed) {
      widget.showInSnackBar(
          requestState.failureCause, PlunesColors.BLACKCOLOR, scaffoldKey);
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countDownTimer = new CountdownTimer(
      Duration(seconds: _start),
      Duration(seconds: 1),
    );
    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        resend = false;
        time = true;
        _current = _start - duration.elapsed.inSeconds;
        if (_current == 0) {
          resend = true;
          time = false;
        }
      });
    });
    sub.onDone(() {
      sub.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
    countDownTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;

    final form = Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: widget.createTextViews(plunesStrings.enterYourOTPMsg, 22,
                colorsFile.black0, TextAlign.center, FontWeight.normal),
          ),
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 60.0, right: 20, top: 70, bottom: 80),
              child: Center(
                child: PinPut(
                  fieldsCount: 4,
                  autoFocus: true,
                  spaceBetween: 20,
                  textStyle: TextStyle(
                    color: Color(
                        CommonMethods.getColorHexFromStr(colorsFile.black0)),
                    fontSize: 22,
                  ),
                  onSubmit: (String pin) => _checkOTP(pin, context),
                  keyboardType: TextInputType.phone,
                  inputDecoration: InputDecoration(
                    counterText: "",
                    contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      borderSide: BorderSide(
                          color: Color(hexColorCode.defaultGreen), width: 3.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      borderSide: BorderSide(
                          color: Color(hexColorCode.defaultGreen), width: 3.0),
                    ),
                  ),
                  clearButtonIcon: Icon(Icons.clear, color: Colors.transparent),
                  pasteButtonIcon:
                      Icon(Icons.content_paste, color: Colors.transparent),
                ),
              ),
            ),
          ),
//          Container(
//            margin: EdgeInsets.only(bottom: 30),
//            child: Visibility(
//                visible: errorMsg,
//                child: Center(
//                    child: widget.createTextViews(plunesStrings.wrongOTPError, 12,
//                        colorsFile.red, TextAlign.center, FontWeight.normal))),
//          ),
          Visibility(
            visible: time,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RichText(
                      text: new TextSpan(
                        children: <TextSpan>[
                          new TextSpan(
                              text: plunesStrings.resendCodeIn,
                              style: new TextStyle(
                                  fontSize: 16,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      colorsFile.black0)))),
                          new TextSpan(
                              text: '00:$_current',
                              style: new TextStyle(
                                  fontSize: 16,
                                  color: Color(hexColorCode.defaultGreen))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: resend,
            child: Center(
                child: Container(
                    alignment: FractionalOffset.center,
                    child: InkWell(
                        onTap: send_otp,
                        child: widget.createTextViews(
                            plunesStrings.resendCode,
                            16,
                            colorsFile.defaultGreen,
                            TextAlign.center,
                            FontWeight.w500)))),
          ),
        ],
      ),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        appBar: widget.getAppBar(context, plunesStrings.checkOTP, true),
        body: GestureDetector(
          onTap: () {
            CommonMethods.hideSoftKeyboard();
          },
          child: form,
        ));
  }
}
