import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../interface/CallBackListener.dart';

class ApiRequestWithMultiParts {
  final JsonDecoder _decoder = new JsonDecoder();
  String url, action = "";
  Map<String, String> headers;
  Map<String, File> mapOfFilesAndKey;

  dynamic body, result;
  BuildContext mContext;
  Encoding encoding;
  CallBackListener callBackListener;
  bool isMultiparts = false;

  ApiRequestWithMultiParts(
      BuildContext mContext,
      CallBackListener callBackListener,
      String url,
      String action,
      Map<String, File> mapOfFilesAndKey,
      {Map<String, String> headers,
      body}) {
    this.callBackListener = callBackListener;
    this.url = url;
    this.body = body;
    this.headers = headers;
    this.mContext = mContext;
    this.action = action;
    this.mapOfFilesAndKey = mapOfFilesAndKey;
    isMultiparts = true;
   _showLoaderNew(mContext);
    getApiRequestWithMultiParts();
  }  BuildContext mContextLoader;


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
                    backgroundColor: Colors.pink,
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



  dynamic resultFinal;

  // for multiparts...........
  Future<dynamic> getApiRequestWithMultiParts() async {
    List<String> keysForImage = List();
    for (int i = 0; i < mapOfFilesAndKey.length; i++) {
      String key = mapOfFilesAndKey.keys.elementAt(i);
      keysForImage.add(key);
    }
    // string to uri
    var uri = Uri.parse(url);

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    for (int i = 0; i < body.length; i++) {
      String key = body.keys.elementAt(i);
      request.fields[key] = body[key];
    }

    for (int i = 0; i < keysForImage.length; i++) {
      var stream = new http.ByteStream(
          DelegatingStream.typed(mapOfFilesAndKey[keysForImage[i]].openRead()));
      // get file length
      var length = await mapOfFilesAndKey[keysForImage[i]].length();

      // multipart that takes file

      var multipartFile = new http.MultipartFile(
          keysForImage[i], stream, length,
          filename: basename(mapOfFilesAndKey[keysForImage[i]].path));

      // add file to multipart
      request.files.add(multipartFile);
    }
    // send
//    final response = await request.send();
/*    if (new DateTime.now().millisecondsSinceEpoch - Constants.CURRENTTIMESTAMP > 1000) {
      Constants.CURRENTTIMESTAMP = new DateTime.now().millisecondsSinceEpoch;
      http.Response response = await http.Response.fromStream(await request.send());
//     int statusCode = response.statusCode;
      result = json.decode(response.body);
      print("==result is ${response.body}");
      final String res = response.body;

      int  statusCode = response.statusCode;
      resultFinal = _decoder.convert(res);
    Navigator.pop(mContextLoader);
      if (statusCode == 401) {
//        logoutWebService();
      } else
        callBackListener.callBackFunction(action, resultFinal);
      return _decoder.convert(res);
      return response.body;
    } else {
//      callBackListener.callBackFunctionError(action, onError.toString());

      return null;
    }*/
    //    return response.stream.transform(utf8.decoder).listen((value) {
//     result = json.decode(value);
//     print(value);
//    });
  }
}
