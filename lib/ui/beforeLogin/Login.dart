/// Created by Manvendra Kumar Singh

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
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

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.phone;
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
                    plunesStrings.phoneNo,
                    TextInputType.number,
                    TextCapitalization.none,
                    isValidNumber,
                    plunesStrings.enterValidNumber),
                widget.getSpacer(0.0, 20.0),
                getPasswordRow(plunesStrings.password.toString().substring(
                    0, plunesStrings.password.toString().length - 1)),
                widget.getSpacer(0.0, 40.0),
                progress
                    ? SpinKitThreeBounce(
                        color: Color(hexColorCode.defaultGreen), size: 30.0)
                    : widget.getDefaultButton(
                        plunesStrings.login, globalWidth - 40, 42, submitLogin),
                widget.getSpacer(0.0, 20.0),
                getForgotPasswordButton(),
                getSignUpViewButton()
              ]))
        ],
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
    if (CommonMethods.checkIfNumber(text)) {
      if (text.length == 10 || text.length == 0) {
        isValidNumber = true;
        return true;
      } else {
        isValidNumber = false;
        return false;
      }
    } else {
      isValidNumber = false;
      return false;
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
                    ? Icon(Icons.visibility_off)
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
      onTap: () {
        Navigator.pushNamed(context, ForgetPassword.tag);
      },
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

  submitLogin() {
    if (!isValidNumber || phoneController.text.isEmpty)
      widget.showInSnackBar(
          plunesStrings.enterValidNumber, Colors.red, _scaffoldKey);
    else if (!isValidPassword || passwordController.text.isEmpty)
      widget.showInSnackBar(
          plunesStrings.errorMsgPassword, Colors.red, _scaffoldKey);
    else
      userLoginRequest();
  }

  userLoginRequest() {
    progress = true;
    bloc.loginRequest(
        context, this, phoneController.text, passwordController.text);
    bloc.loginData.listen((data) async {
      progress = false;
      if (data.success) {
        await bloc.saveDataInPreferences(data, context, plunesStrings.login);
        widget.showInSnackBar(
            plunesStrings.success, Colors.green, _scaffoldKey);
      } else
        widget.showInSnackBar(
            plunesStrings.somethingWentWrong, Colors.red, _scaffoldKey);
    });
  }

  @override
  dialogCallBackFunction(String action) {}
}
