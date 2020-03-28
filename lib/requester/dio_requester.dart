//import 'dart:async';
//import 'dart:io';
//import 'package:dio/dio.dart';
//import 'package:plunes/Utils/log.dart';
//import 'package:plunes/requester/request_handler.dart';
//
//class DioRequester {
//  static DioRequester _instance;
//  Dio _dioClient;
//
//  DioRequester._create() {
//    _dioClient = Dio();
////    _dioClient.options.baseUrl = HttpResourceUrls.BASE_URL;
////    _dioClient.options.sendTimeout = HttpResourceUrls.SEND_TIMEOUT;
////    _dioClient.options.connectTimeout = HttpResourceUrls.CONNECTION_TIMEOUT;
////    _dioClient.options.receiveTimeout = HttpResourceUrls.RECEIVE_TIMEOUT;
//  }
//
//  factory DioRequester() {
//    if (_instance == null) {
//      _instance = DioRequester._create();
//    }
//    return _instance;
//  }
//
//  final String _debug = "[Debug]";
//  final String _dioErrorSection = '[Debug] DioError section';
//  final String _keyAuth = 'authorization';
//
//  Future<RequestOutput> requestMethod(
//      {final String url,
//      dynamic postData,
//      dynamic queryParameter,
//      final String requestType,
//      bool headerIncluded,
//      bool isMultipartEnabled = false}) async {
//    RequestOutput response;
//    try {
//      AppLog.printLog(url);
//      AppLog.printLog(_debug + " $postData");
//      var options = Options(method: requestType);
////      var userManager = UserManager();
////      var accessToken = await userManager.getAccessToken();
//
////      if (headerIncluded != null && accessToken != null && headerIncluded) {
////        AppLog.debugLog("jwt token " + accessToken);
////        options.headers = {
////          _keyAuth: 'bearer $accessToken',
////        };
////      }
//
//      if (isMultipartEnabled) {
//        options.contentType = "multipart/form-data";
//      }
//      Response response = await _dioClient.request(url,
//          data: postData,
//          queryParameters: queryParameter,
//          options: options, onSendProgress: (int sent, int total) {
//        AppLog.debugLog("${sent / total * 100} total sent");
//      });
//      return ResponseStatusCodeHandler()
//          .checkRequestResponseStatusCode(response);
//    } catch (e) {
//      AppLog.printError(_debug + ' ${e.toString()}');
//      if (e is TimeoutException) {
//        response = RequestOutput(
//            isRequestSucceed: false,
//            failureCause: FnpStrings.pleaseCheckInternetConnection,
//            statusCode: 0);
//        return response;
//      } else if (e is SocketException) {
//        response = RequestOutput(
//            isRequestSucceed: false,
//            failureCause: FnpStrings.noInternet,
//            statusCode: 0);
//        return response;
//      } else if (e is DioError) {
//        response = _handleDioError(e);
//        return response;
//      } else {
//        response = RequestOutput(
//            isRequestSucceed: false,
//            failureCause: FnpStrings.somethingWentWrong,
//            statusCode: 0);
//        return response;
//      }
//    }
//  }
//
////  Future<RequestOutput> requestMethodWithCustomUrl(
////      {final String url,
////      dynamic postData,
////      dynamic queryParameter,
////      final String requestType,
////      bool headerIncluded,
////      bool isMultipartEnabled = false}) async {
////    RequestOutput response;
////    try {
////      AppLog.printLog(url);
////      AppLog.printLog(_debug + " $postData");
////      var client = FnpApplication().customDioClient;
////      var options = Options(method: requestType);
////
////      if (isMultipartEnabled) {
////        options.contentType = "multipart/form-data";
////      }
////      Response response = await client.request(url,
////          data: postData,
////          queryParameters: queryParameter,
////          options: options, onSendProgress: (int sent, int total) {
////        AppLog.debugLog("${sent / total * 100} total sent");
////      });
////      return ResponseStatusCodeHandler()
////          .checkRequestResponseStatusCode(response);
////    } catch (e) {
////      AppLog.printError(_debug + ' ${e.toString()}');
////      if (e is TimeoutException) {
////        response = RequestOutput(
////            isRequestSucceed: false,
////            failureCause: FnpStrings.pleaseCheckInternetConnection,
////            statusCode: 0);
////        return response;
////      } else if (e is SocketException) {
////        response = RequestOutput(
////            isRequestSucceed: false,
////            failureCause: FnpStrings.noInternet,
////            statusCode: 0);
////        return response;
////      } else if (e is DioError) {
////        response = _handleDioError(e);
////        return response;
////      } else {
////        response = RequestOutput(
////            isRequestSucceed: false,
////            failureCause: FnpStrings.somethingWentWrong,
////            statusCode: 0);
////        return response;
////      }
////    }
////  }
//
//  RequestOutput _handleDioError(final DioError e) {
//    print(_dioErrorSection);
//    String errorDescription;
//    switch (e.type) {
//      case DioErrorType.CANCEL:
//        errorDescription = FnpStrings.cancelError;
//        break;
//      case DioErrorType.CONNECT_TIMEOUT:
//        errorDescription = FnpStrings.pleaseCheckInternetConnection;
//        break;
//      case DioErrorType.DEFAULT:
//        errorDescription = FnpStrings.socketException;
//        break;
//      case DioErrorType.RECEIVE_TIMEOUT:
//        errorDescription = FnpStrings.receiveTimeOut;
//        break;
//      case DioErrorType.RESPONSE:
//        try {
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
//          errorDescription = httpErrorModel.message;
//        } catch (error) {
//          errorDescription =
//              FnpStrings.somethingWentWrong + " - ${e.response.statusCode}";
//        }
//        break;
//      case DioErrorType.SEND_TIMEOUT:
//        break;
//    }
//    return RequestOutput(
//        isRequestSucceed: false,
//        failureCause: errorDescription,
//        statusCode:
//            e.type == DioErrorType.RESPONSE ? e.response.statusCode : 0);
//  }
//}
