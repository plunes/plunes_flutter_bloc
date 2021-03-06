import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';

import 'Login.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - ChangePassword class is used for Create/Change the password.
 */

class ChangePassword extends BaseActivity {
  static const tag = '/changePassword';

   String phone, from;
  ChangePassword({Key key, this.phone, this.from}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> implements DialogCallBack{

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  FocusNode passwordFocusNode = new FocusNode(), newPasswordFocusNode = new FocusNode(), oldPasswordFocusNode = new FocusNode();
  bool _isValidPassword =true, _isValidOldPassword = true, _isValidNewPassword =true;
  var globalHeight, globalWidth;
  bool progress = false;

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }
  @override
  void initState() {
    getSharedPreferenceData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    CommonMethods.globalContext = context;

    return Scaffold(
        key: _scaffoldKey,
        appBar: widget.getAppBar(context,widget.from == stringsFile.createPassword? stringsFile.createPassword:stringsFile.changePassword, false),
        backgroundColor: Colors.white,
        body: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(),
            child: getBodyView()
        ));
  }
  Widget getBodyView(){
    return Container(
      margin: EdgeInsets.only(left: 25, right: 25,bottom: 50),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: <Widget>[
          widget.getSpacer(0.0, widget.from == stringsFile.createPassword? 100:80.0),
          widget.createTextViews(widget.from == stringsFile.createPassword? stringsFile.createPasswordMsg:stringsFile.changePasswordMsg , 25, colorsFile.darkBrown, TextAlign.start, FontWeight.normal),
          widget.getSpacer(0.0, 30.0),
          widget.from !=stringsFile.createPassword? createTextField(oldPasswordController, stringsFile.currentPassword, TextInputType.text, TextCapitalization.none, _isValidOldPassword, stringsFile.errorMsgPassword): Container(),
          widget.getSpacer(0.0, widget.from !=stringsFile.createPassword? 20.0:0.0),
          createTextField(passwordController, stringsFile.newPassword, TextInputType.text, TextCapitalization.none, _isValidPassword, stringsFile.errorMsgPassword),
          widget.getSpacer(0.0, 20.0),
          createTextField(newPasswordController, stringsFile.reEnterPassword, TextInputType.text, TextCapitalization.none, _isValidNewPassword, stringsFile.errorMsgPassword),
          widget.getSpacer(0.0, 30.0),
          progress ? SpinKitThreeBounce(color: Color(hexColorCode.defaultGreen), size: 30.0) : widget.getDefaultButton(widget.from !=stringsFile.createPassword?stringsFile.change: stringsFile.create, globalWidth,42, changePassword),
          widget.getSpacer(0.0, 20.0),
          widget.getBorderButton(stringsFile.cancel, globalWidth, onBackPressed)

        ],
      ),

    );
  }
  Widget createTextField(TextEditingController controller, String placeHolder, TextInputType inputType, TextCapitalization textCapitalization, bool fieldFlag, String errorMsg) {
    return Container(
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width,
        child: TextField(
            maxLines: 1,
            textCapitalization: textCapitalization,
            keyboardType: inputType,
            controller: controller,
            onSubmitted: (String value) {
              setFocus(controller).unfocus();
              if(controller!=newPasswordController)
              FocusScope.of(context).requestFocus(setTargetFocus(controller));
            },
            onChanged: (text) {
              setState(() {
                if (controller == oldPasswordController)
                 _isValidOldPassword = text.length > 7 ? true : text.length == 0? true: false;
                else if (controller == passwordController)
                  _isValidPassword = text.length > 7 ? true : text.length == 0? true: false;
                else if (controller == newPasswordController)
                  _isValidNewPassword = text.length > 7 ? true : text.length == 0? true: false;
              });
            },
            obscureText: true,
            focusNode: setFocus(controller),
            textInputAction: controller == newPasswordController ? TextInputAction.done : TextInputAction.next,
            cursorColor: Color(CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
            style: TextStyle(
              fontSize: 15.0,
            ),
            decoration: widget.myInputBoxDecoration(colorsFile.defaultGreen, colorsFile.lightGrey1, placeHolder, errorMsg, fieldFlag, controller)));
  }
  FocusNode setFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == oldPasswordController)
      focusNode = oldPasswordFocusNode;
    else if (controller == passwordController)
      focusNode = passwordFocusNode;
    else if (controller == newPasswordController)
      focusNode = newPasswordFocusNode;
    return focusNode;
  }
  FocusNode setTargetFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == oldPasswordController)
      focusNode = passwordFocusNode;
    if (controller == passwordController)
      focusNode = newPasswordFocusNode;
    return focusNode;
  }

  @override
  dialogCallBackFunction(String action) {
  }
  onBackPressed() {
    Navigator.pop(context);
  }
  changePassword() async {
    if(widget.from!=stringsFile.createPassword && _isValidOldPassword && oldPasswordController.text.isEmpty)
      widget.showInSnackBar(stringsFile.emptyOldPasswordError, Colors.red, _scaffoldKey);
    else if(_isValidPassword && passwordController.text.isEmpty)
      widget.showInSnackBar(stringsFile.emptyNewPasswordError, Colors.red, _scaffoldKey);
    else if(_isValidPassword && _isValidNewPassword && newPasswordController.text.isEmpty)
      widget.showInSnackBar(stringsFile.emptyConfirmPasswordError, Colors.red, _scaffoldKey);
    else if(_isValidOldPassword && _isValidPassword && _isValidNewPassword){
      if(newPasswordController.text!=passwordController.text)
        widget.showInSnackBar(stringsFile.passwordMismatchError, Colors.red, _scaffoldKey);
      else{
        progress = true;
        bloc.changePassword(context, this, widget.phone, passwordController.text);
        bloc.changePasswordResult.listen((result) {
          delay(result);
        }, onDone: () {
          bloc.dispose();
        });
      }
    }
  }
  Future delay(result) async {
    progress = false;
    if (result['success']!=null && result['success']) {
      widget.showInSnackBar(stringsFile.success, Colors.green, _scaffoldKey);
     if(widget.from==stringsFile.createPassword)
      await Future.delayed(new Duration(milliseconds: 2000), () {
        Navigator.pushNamed(context, Login.tag);
      });
    }else
      widget.showInSnackBar(stringsFile.somethingWentWrong, Colors.red, _scaffoldKey);

    }

  getSharedPreferenceData() {
    Preferences preferences = Preferences();
    if(widget.phone==null)
    widget.phone = preferences.getPreferenceString(Constants.PREF_USER_PHONE_NUMBER);
  }
}
