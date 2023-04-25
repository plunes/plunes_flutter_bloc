import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plunes/Utils/Preferences.dart';

import '../../Utils/Constants.dart';
import '../interface/CallBackListener.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - This class is used for calling Network api using common method with callback listener and it's also handling the progress dialog.
 */

class ApiCall implements CallBackListener {
  final JsonDecoder _decoder = new JsonDecoder();
  String? url, action, _token, _method;
  Map<String, String>? headers;
  int statusCode = 0;
  bool onlyOnce = false, isLoader = false;

  late BuildContext mContextLoader;
  dynamic body;
  dynamic resultFinal;
  late BuildContext mContext;
  Encoding? encoding;
  CallBackListener? callBackListener;
  late Preferences preferences;

  Future<dynamic> getAPIRequest(
      BuildContext mContext, String url, String action, bool _isLoader,
      {var body, encoding, var token, String? method}) async {
    this.url = url;
    this.body = body;
    this.encoding = encoding;
    this.mContext = mContext;
    this.action = action;
    this.isLoader = _isLoader;
    this._token = token;
    this._method = method;
    preferences = Preferences();

    if (isLoader) _showLoaderNew(mContext);
    onlyOnce = true;
    if (_token != null)
      headers = {
        (action == '1' ? 'Content-Type' : 'Accept'): "application/json",
        "Authorization": "Bearer " + _token!
      };
    else
      headers = {
        (action == '1' ? 'Content-Type' : "Accept"): "application/json"
      };

    print("URL is:  " + url);
    print("Body is:  " + body.toString());

    if (body != null) {
      if (_method == Constants.POST)
        return http.Client()
            .post(Uri.parse(url), headers: headers, body: body, encoding: encoding)
            .then((http.Response response) {
          onlyOnce = false;
          final String res = response.body;
          print("result=res============67" + res.toString());
          statusCode = response.statusCode;
          resultFinal = _decoder.convert(res);
          if (isLoader) Navigator.pop(mContextLoader);
          if (statusCode == 401) {
            logoutWebService();
          }
          return resultFinal;
        }).catchError((onError) {
          onlyOnce = false;
//        Navigator.pop(mContext);
        });
      else if (_method == Constants.PUT)
        return http.Client()
            .put(Uri.parse(url), headers: headers, body: body, encoding: encoding)
            .then((http.Response response) {
          onlyOnce = false;
          final String res = response.body;
          print("result=res============85" + res.toString());
          statusCode = response.statusCode;
          resultFinal = _decoder.convert(res);
          if (isLoader) Navigator.pop(mContextLoader);
          if (statusCode == 401) {
            logoutWebService();
          }
          return resultFinal;
        }).catchError((onError) {
          onlyOnce = false;
          Navigator.pop(mContext);
        });
    } else
      return http.Client()
          .get(Uri.parse(url), headers: headers)
          .then((http.Response response) {
        onlyOnce = false;
        final String res = response.body;
        print("result=res============103" + res.toString());
        statusCode = response.statusCode;
        resultFinal = _decoder.convert(res);
        if (isLoader) Navigator.pop(mContextLoader);
        if (statusCode == 401) {
          logoutWebService();
        }
        return resultFinal;
      }).catchError((onError) {
        if (isLoader) Navigator.pop(mContextLoader);
        onlyOnce = false;
      });
  }

  Future<Null> _showLoaderNew(BuildContext context) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context1) {
        mContextLoader = context1;
        return Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.green,
                  ),
                  height: 50.0,
                  width: 50.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigationPage() {
    preferences.clearPreferences();
    Future.delayed(Duration(milliseconds: 200), () {
      return Navigator.of(mContext)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

  Future logoutWebService() async {
    navigationPage();
  }

  @override
  callBackFunction(action, result) {
    if (true == result[Constants.SUCCESS]) {
      /* Scaffold.of(mContext).showSnackBar(new SnackBar(content: new Text(result["message"])));*/
//      var route = new MaterialPageRoute(builder: (BuildContext context) => new Login());
//      Navigator.pushAndRemoveUntil(mContext, route, (Route<dynamic> route) => false);

      /*  Navigator.of(mContext).pushNamedAndRemoveUntil('/route', (Route<dynamic> route) => false);
*/
//      CommonMethods.clearPreferences();
    } else {
      ScaffoldMessenger.of(mContext).showSnackBar(SnackBar(content: new Text(result[Constants.MESSAGE])));
    }
  }

  @override
  callBackFunctionError(action, result) {}

  // Future<dynamic> foo(BuildContext context) {
  //   Future.delayed(Duration(milliseconds: 100), () {
  //     return resultFinal;
  //   });
  //   /*if( isResponse)
  //     {
  //       Navigator.pop(context);
  //     }*/
  // }
}
