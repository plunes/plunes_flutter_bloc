import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:plunes/resources/network/Urls.dart';

class PaymentWebView extends StatefulWidget {
  static const tag = '/payment';

  final String id;

  PaymentWebView({Key key, this.id}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState(id);
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  final String id;

  _PaymentWebViewState(this.id);

  @override
  void initState() {
    super.initState();
    check();
  }

  void check() async {
    flutterWebViewPlugin.onUrlChanged.listen((String url) {
      print(url);
      if (url.contains("success")) {
        Navigator.of(context).pop(url);
      } else if (url.contains("error")) {
        Navigator.of(context).pop("fail");
      } else if (url.contains("cancelled")) {
        Navigator.of(context).pop("cancel");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      withZoom: true,
      clearCache: true,
      withLocalStorage: true,
      allowFileURLs: true,
      withJavascript: true,
      supportMultipleWindows: true,
      primary: true,
      hidden: true,
      initialChild: Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            "Waiting...",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ),
      appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "Payment",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      url: Urls.PAYMENT_WEB_VIEW_URL + "/" + id,
    );
  }
}
