import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:plunes/res/Http_constants.dart';

class ResponseStatusCodeHandler {
  static ResponseStatusCodeHandler _instance;

  ResponseStatusCodeHandler._create();

  factory ResponseStatusCodeHandler() {
    if (_instance == null) {
      _instance = ResponseStatusCodeHandler._create();
    }
    return _instance;
  }

  RequestOutput checkRequestResponseStatusCode(final Response response) {
    RequestOutput _response;
    print(response);
    if (response.statusCode == HttpResponseCode.OK) {
      _response = RequestOutput(
          isRequestSucceed: true, response: json.decode(response.data));
      return _response;
    }
    if (response.statusCode == HttpResponseCode.CREATED) {
      _response = RequestOutput(
          isRequestSucceed: true, response: json.decode(response.data));
      return _response;
    }

    if (response.statusCode == HttpResponseCode.NO_CONTENT) {
      _response = RequestOutput(
          isRequestSucceed: false,
          failureCause: "No Data found",
          statusCode: HttpResponseCode.NO_CONTENT);
      return _response;
    }
  }
}

class RequestOutput {
  bool isRequestSucceed;
  String failureCause;
  var response;
  int statusCode;

  RequestOutput(
      {this.failureCause,
      this.isRequestSucceed,
      this.response,
      this.statusCode});
}
