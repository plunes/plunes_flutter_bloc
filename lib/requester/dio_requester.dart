import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_handler.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class DioRequester {
  static DioRequester _instance;
  Dio _dioClient;

  DioRequester._create() {
    _dioClient = Dio();
    _dioClient.options.baseUrl = Urls.baseUrl;
    _dioClient.options.sendTimeout = Urls.SEND_TIMEOUT;
    _dioClient.options.connectTimeout = Urls.CONNECTION_TIMEOUT;
    _dioClient.options.receiveTimeout = Urls.RECEIVE_TIMEOUT;
  }

  factory DioRequester() {
    if (_instance == null) {
      _instance = DioRequester._create();
    }
    return _instance;
  }

  final String _debug = "[Debug]";
  final String _postData = " Post Data";
  final String _paramData = " Param Data";
  final String _dioErrorSection = '[Debug] DioError section';
  final String _keyAuth = 'Authorization';

  Future<RequestOutput> requestMethod(
      {final String url,
      dynamic postData,
      dynamic queryParameter,
      final String requestType,
      bool headerIncluded,
      bool isMultipartEnabled = false}) async {
    RequestOutput response;
    try {
      AppLog.printLog(_dioClient.options.baseUrl + url);
      AppLog.printLog(_debug + _postData + " $postData");
      AppLog.printLog(_debug + _paramData + " $queryParameter");
      var options = Options(method: requestType);
      User userManager = UserManager().getUserDetails();
      var accessToken = userManager.accessToken;

      if (headerIncluded != null && accessToken != null && headerIncluded) {
        AppLog.debugLog("jwt token " + accessToken);
        options.headers = {
          _keyAuth: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1ZGY3OGQ5ZGUzNjY4YTI4MWVjZWUyYmQiLCJpYXQiOjE1ODIzNjcwNTZ9.X3zBhcRejl6AJG3MIqZRi-wdbI2qz9OU5GMTAa9eR-c',
        };
      }

      if (isMultipartEnabled) {
        options.contentType = "multipart/form-data";
      }
      Response response = await _dioClient.request(url,
          data: postData,
          queryParameters: queryParameter,
          options: options, onSendProgress: (int sent, int total) {
        AppLog.debugLog("${sent / total * 100} total sent");
      });
//      AppLog.printLog("Response occurred");
      return ResponseStatusCodeHandler()
          .checkRequestResponseStatusCode(response);
    } catch (e) {
      AppLog.printError(_debug + ' ${e.toString()}');
      if (e is TimeoutException) {
        response = RequestOutput(
            isRequestSucceed: false,
            failureCause: PlunesStrings.pleaseCheckInternetConnection,
            statusCode: 0);
        return response;
      } else if (e is SocketException) {
        response = RequestOutput(
            isRequestSucceed: false,
            failureCause: PlunesStrings.noInternet,
            statusCode: 0);
        return response;
      } else if (e is DioError) {
        response = _handleDioError(e);
        return response;
      } else {
        response = RequestOutput(
            isRequestSucceed: false,
            failureCause: plunesStrings.somethingWentWrong,
            statusCode: 0);
        return response;
      }
    }
  }

  RequestOutput _handleDioError(final DioError e) {
    print(_dioErrorSection);
    String errorDescription;
    switch (e.type) {
      case DioErrorType.CANCEL:
        errorDescription = PlunesStrings.cancelError;
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        errorDescription = PlunesStrings.pleaseCheckInternetConnection;
        break;
      case DioErrorType.DEFAULT:
        errorDescription = PlunesStrings.noInternet;
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        errorDescription = PlunesStrings.receiveTimeOut;
        break;
      case DioErrorType.RESPONSE:
        try {
//          HttpErrorModel httpErrorModel =
//              HttpErrorModel.fromJson(e.response.data);
//          if (httpErrorModel.statusCode == HttpResponseCode.UNAUTHORIZED) {
//            SessionExpirationEvent().getSessionEventBus().fire(RequestFailed(
//                requestCode: httpErrorModel.statusCode,
//                failureCause: httpErrorModel.message));
//            // return null;
//          }
//          AppLog.printError(
//              "${e.response.statusCode} response ${httpErrorModel.message}");
          errorDescription =
              plunesStrings.somethingWentWrong + " - ${e.response.statusCode}";
        } catch (error) {
          errorDescription =
              plunesStrings.somethingWentWrong + " - ${e.response.statusCode}";
        }
        break;
      case DioErrorType.SEND_TIMEOUT:
        break;
    }
    return RequestOutput(
        isRequestSucceed: false,
        failureCause: errorDescription,
        statusCode:
            e.type == DioErrorType.RESPONSE ? e.response.statusCode : 0);
  }
}
