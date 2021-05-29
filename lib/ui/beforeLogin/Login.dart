/// Created by Manvendra Kumar Singh

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
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
      isValidNumber = true,
      _isProfessional = false;
  String title = '', body = '';
  var globalHeight, globalWidth;
  UserBloc _userBloc;
  String _userType;
  List<DropdownMenuItem<String>> _dropDownMenuItems;

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
    _dropDownMenuItems = widget.getDropDownMenuItems();
    _userType = _dropDownMenuItems[0].value;
    _isProfessional = false;
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
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 4,
                  vertical: AppConfig.verticalBlockSize * 1.5),
              child: Column(children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(bottom: 20, left: 8),
                  child: Text(
                    "Enter a new Era of Healthcare",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color:
                            CommonMethods.getColorForSpecifiedCode("#141414")),
                  ),
                ),
                Container(
                  child: _getDropDown(),
                  margin: EdgeInsets.only(bottom: 20),
                ),
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
                getForgotPasswordButton(),
                widget.getSpacer(0.0, 30.0),
                progress
                    ? SpinKitThreeBounce(
                        color:
                            CommonMethods.getColorForSpecifiedCode("#107C6F"),
                        size: 30.0)
                    : Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: _submitLogin,
                          child: CustomWidgets().getRoundedButton(
                              plunesStrings.login.toString().toUpperCase(),
                              5,
                              CommonMethods.getColorForSpecifiedCode("#107C6F"),
                              0,
                              AppConfig.verticalBlockSize * 1.5,
                              PlunesColors.WHITECOLOR),
                        ),
                      ),
                widget.getSpacer(0.0, 15.0),
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
                  isValidPassword = text.length > 7
                      ? true
                      : text.length == 0
                          ? true
                          : false;
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
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(10),
          child: Text(
            "Forgot your password",
            textAlign: TextAlign.left,
            overflow: TextOverflow.clip,
            style: TextStyle(
                fontSize: 16,
                decorationThickness: 2,
                decorationColor:
                    Color(CommonMethods.getColorHexFromStr("545454")),
                decoration: TextDecoration.underline,
                color: Color(CommonMethods.getColorHexFromStr("545454")),
                fontWeight: FontWeight.normal),
          ),
        ));
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
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: RichText(
            text: new TextSpan(
              children: <TextSpan>[
                new TextSpan(
                    text: plunesStrings.dontHaveAccount,
                    style:
                        new TextStyle(fontSize: 16, color: Color(0xff107C6F))),
                // new TextSpan(
                //     text: plunesStrings.signUp,
                //     style:
                //         new TextStyle(fontSize: 16, color: Color(0xff107C6F))),
              ],
            ),
          )),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            elevation: 0.0,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 5,
                        right: AppConfig.horizontalBlockSize * 5,
                        top: AppConfig.verticalBlockSize * 2.5),
                    child: Center(
                      child: Text(
                        'Are you sure ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: AppConfig.mediumFont,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 5,
                        right: AppConfig.horizontalBlockSize * 5,
                        bottom: AppConfig.verticalBlockSize * 2.5),
                    child: Center(
                      child: Text(
                        'Do you want to exit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: AppConfig.mediumFont - 2,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  Container(
                    height: 0.5,
                    width: double.infinity,
                    color: PlunesColors.GREYCOLOR,
                  ),
                  Container(
                    height: AppConfig.verticalBlockSize * 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                splashColor:
                                    PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                                focusColor: Colors.transparent,
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Container(
                                    width: double.infinity,
                                    height: AppConfig.verticalBlockSize * 6,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont,
                                          color: PlunesColors.SPARKLINGGREEN),
                                    ))),
                          ),
                          Container(
                            height: AppConfig.verticalBlockSize * 6,
                            color: PlunesColors.GREYCOLOR,
                            width: 0.5,
                          ),
                          Expanded(
                            child: FlatButton(
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                splashColor:
                                    PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                                focusColor: Colors.transparent,
                                onPressed: () => SystemNavigator.pop(),
                                child: Container(
                                    width: double.infinity,
                                    height: AppConfig.verticalBlockSize * 6,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Yes',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont,
                                          color: PlunesColors.SPARKLINGGREEN),
                                    ))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // title: new Text('Are you sure?'),
            // content: new Text('Do you want to exit'),
            // actions: <Widget>[
            //   Container(
            //     height: AppConfig.verticalBlockSize * 6,
            //     child: new FlatButton(
            //       highlightColor: Colors.transparent,
            //       hoverColor: Colors.transparent,
            //       splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
            //       focusColor: Colors.transparent,
            //       onPressed: () => Navigator.of(context).pop(false),
            //       child: Container(
            //           height: AppConfig.verticalBlockSize * 6,
            //           width: double.infinity,
            //           child: Center(
            //             child: new Text(
            //               'No',
            //               textAlign: TextAlign.center,
            //               style: TextStyle(
            //                   fontSize: AppConfig.mediumFont,
            //                   color: PlunesColors.SPARKLINGGREEN),
            //             ),
            //           )),
            //     ),
            //   ),
            //   Container(
            //     height: AppConfig.verticalBlockSize * 6,
            //     child: new FlatButton(
            //       highlightColor: Colors.transparent,
            //       hoverColor: Colors.transparent,
            //       splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
            //       focusColor: Colors.transparent,
            //       onPressed: () => SystemNavigator.pop(),
            //       child: Container(
            //           height: AppConfig.verticalBlockSize * 6,
            //           width: double.infinity,
            //           child: Center(
            //             child: new Text(
            //               'Yes',
            //               textAlign: TextAlign.center,
            //               style: TextStyle(
            //                   fontSize: AppConfig.mediumFont,
            //                   color: PlunesColors.SPARKLINGGREEN),
            //             ),
            //           )),
            //     ),
            //   ),
          ),
        ) ??
        false;
  }

  _submitLogin() {
    if (!isValidNumber || phoneController.text.isEmpty)
      _showInSnackBar(
          (_isNumber() && phoneController.text.trim().length != 10)
              ? "Please fill a valid Phone Number"
              : (!_isNumber() && phoneController.text.trim().isNotEmpty)
                  ? "Please fill a valid User Id"
                  : PlunesStrings
                      .usernameCantBeEmpty, //plunesStrings.enterValidNumber,
          PlunesColors.BLACKCOLOR,
          _scaffoldKey);
    else if (!isValidPassword || passwordController.text.isEmpty)
      _showInSnackBar(plunesStrings.errorMsgPassword, PlunesColors.BLACKCOLOR,
          _scaffoldKey);
    else
      _userLoginRequest();
  }

  _userLoginRequest() async {
    progress = true;
    _setState();
    await Future.delayed(Duration(milliseconds: 100));
    var result = await _userBloc.login(phoneController.text.trim(),
        passwordController.text.trim(), _isProfessional);
    progress = false;
    _setState();
    await Future.delayed(Duration(milliseconds: 100));
    if (result is RequestSuccess) {
      LoginPost data = result.response;
      if (data.success) {
        AnalyticsProvider().registerEvent(AnalyticsKeys.loginKey);
        await bloc.saveDataInPreferences(data, context, plunesStrings.login);
        // _showInSnackBar(
        //     plunesStrings.success, PlunesColors.GREENCOLOR, _scaffoldKey);
      } else {
        _showInSnackBar(PlunesStrings.invalidCredentials,
            PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    } else if (result is RequestFailed) {
      _showInSnackBar(
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

  Widget _getDropDown() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            "Login as",
            style: TextStyle(fontSize: 12, color: PlunesColors.BLACKCOLOR),
          ),
        ),
        Container(
          child: DropdownButtonFormField(
            value: _userType,
            items: _dropDownMenuItems,
            icon: Image.asset(
              "assets/images/arrow-down-Icon.png",
              color: PlunesColors.GREYCOLOR,
              width: 15,
              height: 15,
            ),
            onChanged: changedDropDownItem,
            decoration: widget.myInputBoxDecoration(colorsFile.lightGrey1,
                colorsFile.lightGrey1, null, null, true, null),
          ),
        ),
      ],
    );
  }

  changedDropDownItem(String userTypeValue) {
    if (mounted)
      setState(() {
        _userType = userTypeValue;
        if (_userType == Constants.generalUser) {
          _isProfessional = false;
        } else {
          _isProfessional = true;
        }
      });
  }

  void _showInSnackBar(
      String message, Color blackcolor, GlobalKey<ScaffoldState> scaffoldKey) {
    if (mounted)
      showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets()
                .getInformativePopup(globalKey: _scaffoldKey, message: message);
          });
  }
}
