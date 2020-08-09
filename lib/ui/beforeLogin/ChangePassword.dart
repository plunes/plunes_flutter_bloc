import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'Login.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - ChangePassword class is used for Create/Change the password.
 */

// ignore: must_be_immutable
class ChangePassword extends BaseActivity {
  static const tag = '/changePassword';

  String phone, from, otp;

  ChangePassword({Key key, this.phone, this.from, this.otp}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>
    implements DialogCallBack {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  FocusNode passwordFocusNode = new FocusNode(),
      newPasswordFocusNode = new FocusNode(),
      oldPasswordFocusNode = new FocusNode();
  bool _isValidPassword = true,
      _isValidOldPassword = true,
      _isValidNewPassword = true;
  var globalHeight, globalWidth;
  bool progress = false;
  UserBloc _userBloc;

  @override
  void dispose() {
    _userBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _userBloc = UserBloc();
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
        appBar: widget.getAppBar(
            context,
            widget.from == plunesStrings.createPassword
                ? plunesStrings.createPassword
                : plunesStrings.changePassword,
            false),
        backgroundColor: Colors.white,
        body: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(),
            child: getBodyView()));
  }

  Widget getBodyView() {
    return Container(
        padding:
            EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 12),
        margin: EdgeInsets.only(left: 25, right: 25),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: <Widget>[
                  widget.getSpacer(0.0,
                      widget.from == plunesStrings.createPassword ? 100 : 80.0),
                  widget.createTextViews(
                      widget.from == plunesStrings.createPassword
                          ? plunesStrings.createPasswordMsg
                          : plunesStrings.changePasswordMsg,
                      25,
                      colorsFile.darkBrown,
                      TextAlign.start,
                      FontWeight.normal),
                  widget.getSpacer(0.0, 30.0),
                  widget.from != plunesStrings.createPassword
                      ? createTextField(
                          oldPasswordController,
                          plunesStrings.currentPassword,
                          TextInputType.text,
                          TextCapitalization.none,
                          _isValidOldPassword,
                          plunesStrings.errorMsgPassword)
                      : Container(),
                  widget.getSpacer(0.0,
                      widget.from != plunesStrings.createPassword ? 20.0 : 0.0),
                  createTextField(
                      passwordController,
                      plunesStrings.newPassword,
                      TextInputType.text,
                      TextCapitalization.none,
                      _isValidPassword,
                      plunesStrings.errorMsgPassword),
                  widget.getSpacer(0.0, 20.0),
                  createTextField(
                      newPasswordController,
                      plunesStrings.reEnterPassword,
                      TextInputType.text,
                      TextCapitalization.none,
                      _isValidNewPassword,
                      plunesStrings.errorMsgPassword),
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
                            onTap: changePassword,
                            child: CustomWidgets().getRoundedButton(
                                widget.from != plunesStrings.createPassword
                                    ? plunesStrings.reset
                                    : plunesStrings.create,
                                AppConfig.horizontalBlockSize * 8,
                                PlunesColors.GREENCOLOR,
                                AppConfig.horizontalBlockSize * 0,
                                AppConfig.verticalBlockSize * 1.2,
                                PlunesColors.WHITECOLOR),
                          ),
                        ),
                  widget.getSpacer(0.0, 20.0),
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
          ],
        ));
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
            controller: controller,
            onSubmitted: (String value) {
              setFocus(controller).unfocus();
              if (controller != newPasswordController)
                FocusScope.of(context).requestFocus(setTargetFocus(controller));
            },
            onChanged: (text) {
              setState(() {
                if (controller == oldPasswordController)
                  _isValidOldPassword =
                      text.length > 7 ? true : text.length == 0 ? true : false;
                else if (controller == passwordController)
                  _isValidPassword =
                      text.length > 7 ? true : text.length == 0 ? true : false;
                else if (controller == newPasswordController)
                  _isValidNewPassword =
                      text.length > 7 ? true : text.length == 0 ? true : false;
              });
            },
            obscureText: true,
            focusNode: setFocus(controller),
            textInputAction: controller == newPasswordController
                ? TextInputAction.done
                : TextInputAction.next,
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
    if (controller == oldPasswordController) focusNode = passwordFocusNode;
    if (controller == passwordController) focusNode = newPasswordFocusNode;
    return focusNode;
  }

  @override
  dialogCallBackFunction(String action) {}

  onBackPressed() {
    Navigator.pop(context);
  }

  changePassword() async {
    if (widget.from != plunesStrings.createPassword &&
        _isValidOldPassword &&
        oldPasswordController.text.isEmpty)
      widget.showInSnackBar(plunesStrings.emptyOldPasswordError,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
    else if (_isValidPassword && passwordController.text.isEmpty)
      widget.showInSnackBar(plunesStrings.emptyNewPasswordError,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
    else if (_isValidPassword &&
        _isValidNewPassword &&
        newPasswordController.text.isEmpty)
      widget.showInSnackBar(plunesStrings.emptyConfirmPasswordError,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
    else if (_isValidOldPassword && _isValidPassword && _isValidNewPassword) {
      if (newPasswordController.text != passwordController.text)
        widget.showInSnackBar(plunesStrings.passwordMismatchError,
            PlunesColors.BLACKCOLOR, _scaffoldKey);
      else {
        progress = true;
        _setState();
        await Future.delayed(Duration(milliseconds: 200));
        if (widget.from == plunesStrings.createPassword) {
          _resetPassword();
        } else {
          _changePassword();
        }
      }
    }
  }

  Future delay(RequestState result) async {
    progress = false;
    _setState();
    await Future.delayed(Duration(milliseconds: 200));
    if (result is RequestSuccess) {
      widget.showInSnackBar(plunesStrings.success, Colors.green, _scaffoldKey);
      await Future.delayed(new Duration(milliseconds: 2000));
      if (widget.from == plunesStrings.createPassword) {
        Navigator.pushNamed(context, Login.tag);
      } else {
        Navigator.pop(context);
      }
    } else if (result is RequestFailed) {
      widget.showInSnackBar(
          result.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
    } else
      widget.showInSnackBar(plunesStrings.somethingWentWrong,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
  }

  getSharedPreferenceData() {
    Preferences preferences = Preferences();
    if (widget.phone == null)
      widget.phone =
          preferences.getPreferenceString(Constants.PREF_USER_PHONE_NUMBER);
  }

  void _resetPassword() async {
    var result = await _userBloc.resetPassword(
        widget.phone?.trim(), widget.otp, passwordController.text.trim());
    delay(result);
  }

  void _changePassword() async {
    var result = await _userBloc.changePassword(
        oldPasswordController.text.trim(), passwordController.text.trim());
    delay(result);
  }

  void _setState() {
    if (mounted) setState(() {});
  }
}
