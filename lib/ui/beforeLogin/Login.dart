/// Created by Manvendra Kumar Singh

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/analytics.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'EnterPhoneScreen.dart';
import 'ForgotPassword.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - Login class is for sign in into the application for all User Type: General User, Doctor and Hospital.
 */

// ignore: must_be_immutable
class Login extends BaseActivity {
  static const tag = '/login';
  String phone;

  Login({Key key, this.phone}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> implements DialogCallBack {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode passwordFocusNode = new FocusNode(),
      phoneFocusNode = new FocusNode();
  bool isFirst = true,
      _passwordVisible = true,
      progress = false,
      isValidPassword = true,
      isValidNumber = true;
  String title = '', body = '';
  var globalHeight, globalWidth;
  UserBloc _userBloc;
  final String _dummyUserId = "PL-1WQPS-S7PN";

  @override
  void dispose() {
    _userBloc?.dispose();
    phoneController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _userBloc = UserBloc();
    phoneController.text = widget.phone;
    super.initState();
  }

  Widget build(BuildContext context) {
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    CommonMethods.globalContext = context;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: widget.getAppBar(context, plunesStrings.login, false),
          backgroundColor: Colors.white,
          body: GestureDetector(
              onTap: () => CommonMethods.hideSoftKeyboard(),
              child: bodyView())),
    );
  }

  Widget bodyView() {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
              height: (globalHeight / 2) - 80,
              color: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.lightGrey4)),
              child: Center(
                  child:
                      widget.getAssetImageWidget(plunesImages.loginLogoImage))),
          Container(
              margin: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(children: <Widget>[
                createTextField(
                    phoneController,
                    PlunesStrings.userName,
                    TextInputType.text,
                    TextCapitalization.none,
                    isValidNumber,
                    (!isValidNumber && phoneController.text.trim().isEmpty)
                        ? PlunesStrings.usernameCantBeEmpty
                        : _isNumber()
                            ? "Please fill a valid Phone Number"
                            : "Please fill a valid User ID"),
                widget.getSpacer(0.0, 20.0),
                getPasswordRow(plunesStrings.password.toString().substring(
                    0, plunesStrings.password.toString().length - 1)),
                widget.getSpacer(0.0, 40.0),
                progress
                    ? SpinKitThreeBounce(
                        color: Color(hexColorCode.defaultGreen), size: 30.0)
                    : Container(
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 30,
                            right: AppConfig.horizontalBlockSize * 30),
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: _submitLogin,
                          child: CustomWidgets().getRoundedButton(
                              plunesStrings.login,
                              AppConfig.horizontalBlockSize * 8,
                              PlunesColors.GREENCOLOR,
                              AppConfig.horizontalBlockSize * 0,
                              AppConfig.verticalBlockSize * 1.2,
                              PlunesColors.WHITECOLOR),
                        ),
                      ),
                widget.getSpacer(0.0, 20.0),
                getForgotPasswordButton(),
                getSignUpViewButton()
              ]))
        ],
      ),
    );
  }

  bool _isNumber() {
    return (phoneController.text.trim().isNotEmpty &&
        phoneController.text.trim().length >= 1 &&
        (phoneController.text.trim().codeUnitAt(0) >= 48 &&
            phoneController.text.trim().codeUnitAt(0) <= 57));
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
            obscureText:
                (controller == passwordController ? _passwordVisible : false),
            keyboardType: inputType,
            textInputAction: controller == passwordController
                ? TextInputAction.done
                : TextInputAction.next,
            onSubmitted: (String value) {
              setFocus(controller).unfocus();
              FocusScope.of(context).requestFocus(setTargetFocus(controller));
            },
            onChanged: (text) {
              setState(() {
                if (controller == passwordController)
                  isValidPassword =
                      text.length > 7 ? true : text.length == 0 ? true : false;
                else if (controller == phoneController) {
                  validation(text);
                }
              });
            },
            inputFormatters: (controller == phoneController && _isNumber())
                ? [WhitelistingTextInputFormatter.digitsOnly]
                : null,
            maxLength:
                (controller == phoneController && _isNumber()) ? 10 : null,
//                : (controller != passwordController)
//                    ? _dummyUserId.length
//                    : null,
            controller: controller,
            cursorColor: Color(
                CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
            focusNode: setFocus(controller),
            style: TextStyle(
              fontSize: 15.0,
            ),
            decoration: widget.myInputBoxDecoration(
                colorsFile.defaultGreen,
                colorsFile.lightGrey1,
                placeHolder,
                errorMsg,
                fieldFlag,
                controller,
                passwordController)));
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

  Widget getPasswordRow(title) {
    return Stack(
      children: <Widget>[
        createTextField(
            passwordController,
            title,
            TextInputType.text,
            TextCapitalization.none,
            isValidPassword,
            plunesStrings.errorMsgPassword),
        Container(
          margin: EdgeInsets.only(right: 10, top: 10),
          child: Align(
              alignment: FractionalOffset.centerRight,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                child: _passwordVisible
                    ? Image.asset(
                        "assets/images/eye-with-a-diagonal-line3x.png",
                        width: 24,
                        height: 24,
                      )
                    : Icon(Icons.visibility),
              )),
        ),
      ],
    );
  }

  FocusNode setFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == phoneController)
      focusNode = phoneFocusNode;
    else if (controller == passwordController) focusNode = passwordFocusNode;
    return focusNode;
  }

  FocusNode setTargetFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == phoneController) focusNode = passwordFocusNode;
    return focusNode;
  }

  Widget getForgotPasswordButton() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, ForgetPassword.tag),
      child: Container(
        padding: EdgeInsets.all(10),
        child: widget.createTextViews(plunesStrings.forgotPassword, 16,
            colorsFile.defaultGreen, TextAlign.center, FontWeight.normal),
      ),
    );
  }

  Widget getSignUpViewButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EnterPhoneScreen(from: plunesStrings.login)));
      },
      child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
          child: RichText(
            text: new TextSpan(
              children: <TextSpan>[
                new TextSpan(
                    text: plunesStrings.dontHaveAccount,
                    style: new TextStyle(
                        fontSize: 16,
                        color: Color(CommonMethods.getColorHexFromStr(
                            colorsFile.grey1)))),
                new TextSpan(
                    text: plunesStrings.signUp,
                    style: new TextStyle(
                        fontSize: 16, color: Color(hexColorCode.defaultGreen))),
              ],
            ),
          )),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new CupertinoAlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => SystemNavigator.pop(),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  _submitLogin() {
    if (!isValidNumber || phoneController.text.isEmpty)
      widget.showInSnackBar(
          (_isNumber() && phoneController.text.trim().length != 10)
              ? "Please fill a valid Phone Number"
              : (!_isNumber() && phoneController.text.trim().isNotEmpty)
                  ? "Please fill a valid User Id"
                  : PlunesStrings
                      .usernameCantBeEmpty, //plunesStrings.enterValidNumber,
          PlunesColors.BLACKCOLOR,
          _scaffoldKey);
    else if (!isValidPassword || passwordController.text.isEmpty)
      widget.showInSnackBar(plunesStrings.errorMsgPassword,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
    else
      _userLoginRequest();
  }

  _userLoginRequest() async {
    progress = true;
    _setState();
    await Future.delayed(Duration(milliseconds: 100));
    var result = await _userBloc.login(
        phoneController.text.trim(), passwordController.text.trim());
    progress = false;
    _setState();
    await Future.delayed(Duration(milliseconds: 100));
    if (result is RequestSuccess) {
      LoginPost data = result.response;
      if (data.success) {
        AnalyticsProvider().registerEvent(AnalyticsKeys.loginKey);
        await bloc.saveDataInPreferences(data, context, plunesStrings.login);
        widget.showInSnackBar(
            plunesStrings.success, PlunesColors.GREENCOLOR, _scaffoldKey);
      } else {
        widget.showInSnackBar(PlunesStrings.invalidCredentials,
            PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    } else if (result is RequestFailed) {
      widget.showInSnackBar(
          result?.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
    }
  }

  _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  dialogCallBackFunction(String action) {}
}
