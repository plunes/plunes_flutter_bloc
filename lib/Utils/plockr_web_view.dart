import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlockrWebViewContainer extends BaseActivity {
  final url;

  PlockrWebViewContainer(this.url);

  @override
  createState() => _PlockrWebViewContainerState(this.url);
}

class _PlockrWebViewContainerState extends BaseState<PlockrWebViewContainer> {
  var _url;
  final _key = UniqueKey();

  _PlockrWebViewContainerState(this._url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Container(
          color: Colors.white70,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: WebviewScaffold(
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
                  url: _url,
                  appBar: widget.getAppBar(context, PlunesStrings.plockrViewer, true),
                )
              )
            ],
          ),
        ));
  }
}