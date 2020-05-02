import 'dart:io';

import 'package:dio/dio.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';


class PlockrRepo {
  static PlockrRepo _instance;

  PlockrRepo._init();

  factory PlockrRepo() {
    if (_instance == null) {
      _instance = PlockrRepo._init();
    }
    return _instance;
  }

  Future<RequestState> uploadPlockrData(Map<String, dynamic> postData,) async {
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_POST,
      url: Urls.GET_UPLOAD_PLOCKR_DATA_URL,
      headerIncluded: true,
      isMultipartEnabled: true,
      postData: FormData.fromMap(postData),
    );
    if (result.isRequestSucceed) {
      return RequestSuccess(response:  result);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}