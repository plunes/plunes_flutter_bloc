import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class AboutUs extends BaseActivity {
  static const tag = '/aboutus';

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;

    return WebviewScaffold(
      clearCache: false,
      withZoom: true,
      hidden: true,
      initialChild: Container(
        color: Colors.white,
        child: Center(
            child: SpinKitThreeBounce(
          color: Color(hexColorCode.defaultTransGreen),
          size: 30.0,
        )),
      ),
      url: urls.aboutUs,
      appBar: widget.getAppBar(context, stringsFile.aboutUs, true),
    );
  }
}
