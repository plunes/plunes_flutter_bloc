import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';

import 'CheckOTP.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - ForgetPassword class is for create the new password using Phone or mobile Number.
 */

// ignore: must_be_immutable
class ForgetPassword extends BaseActivity {
  static const tag = '/forget_password';

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword>
    implements DialogCallBack {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final phoneNumberController = new TextEditingController();
  bool progress = false, isValidNumber = true, _isProfessional = false;
  var globalHeight, globalWidth;
  UserBloc? _userBloc;

  @override
  void initState() {
    _userBloc = UserBloc();
    _isProfessional = false;
    super.initState();
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar:
            widget.getAppBar(context, plunesStrings.forgotPasswordTitle, true) as PreferredSizeWidget?,
        body: GestureDetector(
          onTap: () => CommonMethods.hideSoftKeyboard(),
          child: getBodyView(),
        ));
  }

  Widget getBodyView() {
    return Container(
      margin: EdgeInsets.only(left: 25, right: 25, bottom: 10),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: widget.createTextViews(
                    plunesStrings.enterEmailOrPhone,
                    25,
                    colorsFile.darkBrown,
                    TextAlign.start,
                    FontWeight.normal)),
            widget.getSpacer(0.0, 30.0),
            createTextField(
                phoneNumberController,
                plunesStrings.MobileNumber,
                TextInputType.number,
                TextCapitalization.none,
                isValidNumber,
                plunesStrings.enterValidNumber),
            widget.getSpacer(0.0, 30.0),
            progress
                ? SpinKitThreeBounce(
                    color: Color(hexColorCode.defaultGreen), size: 30.0)
                : Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 30,
                        right: AppConfig.horizontalBlockSize * 30),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      onTap: _submitForOTP,
                      child: CustomWidgets().getRoundedButton(
                          plunesStrings.ok,
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 0,
                          AppConfig.verticalBlockSize * 1.2,
                          PlunesColors.WHITECOLOR),
                    ),
                  ),
            widget.getSpacer(0.0, 30.0),
            Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 30,
                  right: AppConfig.horizontalBlockSize * 30),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onTap: onBackPressed,
                child: CustomWidgets().getRoundedButton(
                    plunesStrings.cancel,
                    AppConfig.horizontalBlockSize * 8,
                    PlunesColors.WHITECOLOR,
                    AppConfig.horizontalBlockSize * 0,
                    AppConfig.verticalBlockSize * 1.2,
                    PlunesColors.BLACKCOLOR,
                    hasBorder: true),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget createTextField(
      TextEditingController controller,
      String placeHolder,
      TextInputType inputType,
      TextCapitalization textCapitalization,
      bool fieldFlag,
      String errorMsg) {
    return Container(
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width,
        child: TextField(
            maxLines: 1,
            textCapitalization: textCapitalization,
            keyboardType: inputType,
            maxLength: 10,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (text) {
              setState(() {
                if (controller == phoneNumberController) {
                  validation(text);
                }
              });
            },
            controller: controller,
            cursorColor: Color(
                CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
            style: TextStyle(
              fontSize: 15.0,
            ),
            decoration: widget.myInputBoxDecoration(
                colorsFile.defaultGreen,
                colorsFile.lightGrey1,
                placeHolder,
                errorMsg,
                fieldFlag,
                controller)));
  }

  bool validation(text) {
    if (text.length >= 10 || text.length == 0) {
      isValidNumber = true;
      return true;
    } else {
      isValidNumber = false;
      return false;
    }
  }

  _submitForOTP() async {
    if (isValidNumber && phoneNumberController.text != '') {
      progress = true;
      _setState();
      await Future.delayed(Duration(milliseconds: 200));
      var result = await _userBloc!.checkUserExistence(phoneNumberController.text.trim());
      debugPrint("forgetPassword->${result.toString()}");
      // progress = false;
      // _setState();
      if (result is RequestSuccess) {
        debugPrint("forgetPassword-if>${result.toString()}");

        _getUserExistenceData(result.response);
      } else if (result is RequestFailed) {
        debugPrint("forgetPassword-else>${result.toString()}");

        progress = false;
        _setState();
        await Future.delayed(Duration(milliseconds: 200));
        widget.showInSnackBar(
            result.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    } else
      widget.showInSnackBar(plunesStrings.enterValidNumber,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
  }

  onBackPressed() {
    Navigator.pop(context);
  }

  _getUserExistenceData(data) async {
    String? signature = await AppConfig.getAppSignature();
    if (data['success'] != null && data['success']) {
      debugPrint("forgetPassword----iiiihgfh");
      debugPrint("forgetPassword----$signature");
      debugPrint("forgetPassword----$_isProfessional");

      var requestState = await _userBloc!.getGenerateOtp(
          phoneNumberController.text.trim(),
          iFromForgotPassword: true,
          isProfessional: _isProfessional,
          signature: signature);
      progress = false;
      _setState();
      await Future.delayed(Duration(milliseconds: 200));
      debugPrint("forgetPassword---->${requestState.toString()}");

      if (requestState is RequestSuccess) {
        debugPrint("forgetPassword-1--->${requestState.toString()}");

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckOTP(
                    phone: phoneNumberController.text,
                    from: plunesStrings.forgotPasswordTitle)));
      } else if (requestState is RequestFailed) {
        debugPrint("forgetPassword---2->${requestState.toString()}");
        debugPrint("forgetPassword---2->${requestState.failureCause.toString()}");

        widget.showInSnackBar(
            requestState.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    } else if (!data['success']) {
      debugPrint("forgetPassword---3->67");

      progress = false;
      _setState();
      await Future.delayed(Duration(milliseconds: 200));
      widget.showInSnackBar(
          PlunesStrings.numberNotExist, PlunesColors.BLACKCOLOR, _scaffoldKey);
    }
  }

  @override
  dialogCallBackFunction(String action) {}

  void _setState() {
    if (mounted) setState(() {});
  }
}
