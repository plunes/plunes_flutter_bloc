import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/beforeLogin/ChangePassword.dart';

import 'AccountSettings.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - SecuritySettings class account holder information and that also can be updated.
 */

class SecuritySettings extends BaseActivity {
  static const tag = '/securitySettings';

  @override
  _SecuritySettingsState createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings>
    implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth;

  Preferences preferences;

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: widget.getAppBar(context, plunesStrings.securitySettings, true),
        body: getBody());
  }

  Widget getBody() {
    return Container(
      child: Column(
        children: <Widget>[
          getSettingRow(
              assetsImageFile.changePassIcon, plunesStrings.changePassword, 0),
          widget.getDividerRow(context, 0, 0, 0),
          getSettingRow(
              assetsImageFile.logoutIcon2, plunesStrings.logoutFromAllDevices, 1),
          widget.getDividerRow(context, 0, 0, 0),
        ],
      ),
    );
  }

  Widget getSettingRow(String firstIcon, String title, int pos) {
    return InkWell(
      onTap: () {
        switch (pos) {
          case 0:
            Navigator.pushNamed(context, ChangePassword.tag);
            break;
          case 1:
            CommonMethods.confirmationDialog(
                context, plunesStrings.logoutAllMsg, this);
            break;
        }
      },
      child: Container(
        margin: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: widget.getAssetIconWidget(
                    firstIcon, 25, 25, BoxFit.contain)),
            Expanded(
                child: widget.createTextViews(title, 16, colorsFile.black0,
                    TextAlign.start, FontWeight.normal)),
            Icon(Icons.keyboard_arrow_right, color: Colors.black)
          ],
        ),
      ),
    );
  }

  @override
  dialogCallBackFunction(String action) {
    if (action != null && action == 'DONE') logout();
  }

  void logout() {
    bloc.logoutService(context, this);
    bloc.logout.listen((data) {
      if (data != null && data['success'] != null && data['success'])
        navigationPage();
      else
        widget.showInSnackBar(
            plunesStrings.somethingWentWrong, Colors.red, _scaffoldKey);
    });
  }

  void navigationPage() {
    preferences = Preferences();
    preferences.clearPreferences();
    Future.delayed(Duration(milliseconds: 200), () {
      return Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }
}
