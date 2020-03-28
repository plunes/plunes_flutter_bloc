import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

import 'AccountSettings.dart';
import 'SecuritySettings.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - SettingScreen class account holder information and that also can be updated.
 */

class SettingScreen extends BaseActivity {
  static const tag = '/setting_screen';

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth;

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: widget.getAppBar(context, stringsFile.settings, true),
        body: getBody());
  }

  Widget getBody() {
    return Container(
      child: Column(
        children: <Widget>[
          getSettingRow(
              assetsImageFile.settingIcon, stringsFile.accountSettings, 0),
          widget.getDividerRow(context, 0, 0, 0),
          getSettingRow(
              assetsImageFile.securityIcon, stringsFile.securitySettings, 1),
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
            Navigator.pushNamed(context, AccountSettings.tag);
            break;
          case 1:
            Navigator.pushNamed(context, SecuritySettings.tag);
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
}
