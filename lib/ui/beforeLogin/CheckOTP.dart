import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/Utils/CommonMethods.dart';
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


class CheckOTP extends BaseActivity {
  static const tag = '/checkOTP';
  final String phone, from;

  CheckOTP({this.phone, this.from});

  @override
  _CheckOTPState createState() => _CheckOTPState();
}

class _CheckOTPState extends State<CheckOTP> {
  bool progress = false, time = true, resend = false, errorMsg = false;
  int _start = 30, _current = 30;
  CountdownTimer countDownTimer;

  void _checkOTP(String pin, BuildContext context) async {
    setState(() {
      if (pin == Constants.OTP) {
        if(widget.from==stringsFile.forgotPasswordTitle)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChangePassword(phone:widget.phone, from: stringsFile.createPassword)));
        else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Registration(phone:widget.phone)));
      } else {
        errorMsg = true;
      }
    });
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
    countDownTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;

    final form = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: widget.createTextViews(stringsFile.enterYourOTPMsg, 22, colorsFile.black0, TextAlign.center, FontWeight.normal),
          ),
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 60.0, right: 20, top: 50, bottom: 20),
              child: Center(
                child: PinPut(
                  fieldsCount: 4,
                  autoFocus: true,
                  spaceBetween: 20,
                  textStyle: TextStyle(
                    color: Color(CommonMethods.getColorHexFromStr(colorsFile.black0)),
                    fontSize: 22,
                  ),
                  onSubmit: (String pin) => _checkOTP(pin, context),
                  inputDecoration: InputDecoration(
                    counterText: "",
                    contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      borderSide: BorderSide(
                          color: Color(hexColorCode.defaultGreen), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      borderSide: BorderSide(
                          color: Color(hexColorCode.defaultGreen), width: 1.0),
                    ),
                  ),
                  clearButtonIcon: Icon(Icons.clear, color: Colors.transparent),
                  pasteButtonIcon: Icon(Icons.content_paste, color: Colors.transparent),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: Visibility(
                visible: errorMsg,
                child: Center(
                    child: widget.createTextViews(stringsFile.wrongOTPError, 12,
                        colorsFile.red, TextAlign.center, FontWeight.normal))),
          ),
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
                              text: stringsFile.resendCodeIn,
                              style: new TextStyle(
                                  fontSize: 16,
                                  color: Color(CommonMethods.getColorHexFromStr(colorsFile.black0)))),
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
                            stringsFile.resendCode,
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
        appBar: widget.getAppBar(context, stringsFile.checkOTP, true),
        body: GestureDetector(
          onTap: () {
            CommonMethods.hideSoftKeyboard();
          },
          child: form,
        ));
  }
}
