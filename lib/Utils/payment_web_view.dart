import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:plunes/resources/network/Urls.dart';

class PaymentWebView extends StatefulWidget {
  static const tag = '/payment';

  final String id, url;

  PaymentWebView({Key key, this.id, this.url}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState(id);
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  final String id;

  _PaymentWebViewState(this.id);

  @override
  void initState() {
//    print("widget.url ${widget.url}");
    super.initState();
    check();
  }

  void check() async {
    flutterWebViewPlugin.onUrlChanged.listen((final String url) {
      if (widget.url != null && url.length > 300) {
        return;
      }
      if (url.contains("success")) {
        Navigator.of(context).pop(url);
      } else if (url.contains("error")) {
        Navigator.of(context).pop("fail");
      } else if (url.contains("cancelled")) {
//        String s =
//            "https://staging-app.zestmoney.in/?LoanApplicationId=3158523c-6d1b-430d-94cd-323de5623f2b&merchantid=35ce48c0-1fd7-4c09-bbfc-ef92e0314505&basketamount=30676&returnurl=https:%2F%2Fdevapi.plunes.com%2FpaymentControl%2Fcancelled%2F5fa3cf311ca71d121d769b73&approvedurl=https:%2F%2Fdevapi.plunes.com%2FpaymentControl%2FzestSuccess5fa3cf311ca71d121d769b73&downpaymentamount=10000&paymentGatewayId=e39985df-5ac9-4198-897c-94e6ecb9bfec";
//        print("s ${s.length}");
//            "${s == url} cancelling ${s.substring(0, 220)} ${s.indexOf("cancelled")}");
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
      url: widget.url != null
          ? widget.url
          : Urls.PAYMENT_WEB_VIEW_URL + "/" + id,
    );
  }
}
