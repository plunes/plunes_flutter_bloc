import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:plunes/resources/network/Urls.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  static const tag = '/payment';

  final String? id, url;

  PaymentWebView({Key? key, this.id, this.url}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState(id);
}

class _PaymentWebViewState extends State<PaymentWebView> {
  // final flutterWebViewPlugin = new FlutterWebviewPlugin();

  final String? id;

  _PaymentWebViewState(this.id);

  late var controller;

  @override
  void initState() {
    print("payment_initState");
    print("${widget.url ?? "as"}");
    print(Uri.parse(widget.url != null
        ? widget.url!
        : Urls.PAYMENT_WEB_VIEW_URL + "/" + id!));
//    print("${Urls.PAYMENT_WEB_VIEW_URL + "/" + id}widget.url ${widget.url}");
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {

            if (request.url.contains("success")) {
              Navigator.of(context).pop(request.url);
            } else if (request.url.contains("error")) {
              Navigator.of(context).pop("fail");
            } else if (request.url.contains("cancelled")) {
              Navigator.of(context).pop("cancel");
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url != null
          ? widget.url!
          : Urls.PAYMENT_WEB_VIEW_URL + "/" + id!));
    // check();
  }

  void check() async {
    // flutterWebViewPlugin.onUrlChanged.listen((final String url) {
    //   if (widget.url != null && url.length > 300) {
    //     return;
    //   } else if (widget.url != null && url.contains("Success")) {
    //     Navigator.of(context).pop("success");
    //     return;
    //   }
    //   if (url.contains("success")) {
    //     Navigator.of(context).pop(url);
    //   } else if (url.contains("error")) {
    //     Navigator.of(context).pop("fail");
    //   } else if (url.contains("cancelled")) {
    //     Navigator.of(context).pop("cancel");
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: WebViewWidget(
          controller: controller,
        ));

    // return WebviewScaffold(
    //   withZoom: true,
    //   clearCache: true,
    //   withLocalStorage: true,
    //   allowFileURLs: true,
    //   withJavascript: true,
    //   supportMultipleWindows: true,
    //   primary: true,
    //   hidden: true,
    //   initialChild: Container(
    //     color: Colors.white,
    //     child: const Center(
    //       child: Text(
    //         "Waiting...",
    //         style: TextStyle(color: Colors.black, fontSize: 18),
    //       ),
    //     ),
    //   ),
    //   appBar: new AppBar(
    //     brightness: Brightness.light,
    //     backgroundColor: Colors.white,
    //     title: Text(
    //       "Payment",
    //       style: TextStyle(color: Colors.black),
    //     ),
    //     elevation: 2,
    //     iconTheme: IconThemeData(color: Colors.black),
    //   ),
    //   url: widget.url != null
    //       ? widget.url
    //       : Urls.PAYMENT_WEB_VIEW_URL + "/" + id,
    // );
  }
}
