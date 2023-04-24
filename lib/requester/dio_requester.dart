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
  static DioRequester? _instance;
  Dio? _dioClient, _customClient;

  DioRequester._create() {
    _dioClient = Dio();
    _customClient = Dio();
    _dioClient!.options.baseUrl = Urls.baseUrl;
    _dioClient!.options.sendTimeout = Duration(seconds: Urls.SEND_TIMEOUT);
    _dioClient!.options.connectTimeout = Duration(seconds: Urls.CONNECTION_TIMEOUT);
    _dioClient!.options.receiveTimeout = Duration(seconds: Urls.RECEIVE_TIMEOUT);
    _customClient!.options.sendTimeout = Duration(seconds: Urls.SEND_TIMEOUT);
    _customClient!.options.connectTimeout = Duration(seconds: Urls.CONNECTION_TIMEOUT);
    _customClient!.options.receiveTimeout = Duration(seconds: Urls.RECEIVE_TIMEOUT);
  }

  factory DioRequester() {
    if (_instance == null) {
      _instance = DioRequester._create();
    }
    return _instance!;
  }

  final String _debug = "[Debug]";
  final String _postData = " Post Data";
  final String _paramData = " Param Data";
  final String _dioErrorSection = '[Debug] DioError section';
  final String _keyAuth = 'Authorization';

  Future<RequestOutput?> requestMethod(
      {required final String url,
      dynamic postData,
      dynamic queryParameter,
      final String? requestType,
      bool? headerIncluded,
      Function? fileUploadProgress,
      bool isMultipartEnabled = false,
      bool isPayViaInsurance = false}) async {
    RequestOutput response;
    try {

      if(isPayViaInsurance) {
        _dioClient!.options.baseUrl = Urls.customBaseUrl;
      } else {
        _dioClient!.options.baseUrl = Urls.baseUrl;
      }


      print(url);
      print("api_url--->${_dioClient!.options.baseUrl + url}");
      print("api_requestType--->${requestType}");
      print("api_queryParameter--->${queryParameter}");
      AppLog.printLog(_dioClient!.options.baseUrl + url);
      AppLog.printLog(_debug + _postData + " $postData");
      print(_debug + _paramData + " $queryParameter");
      var options = Options(method: requestType);
      User userManager = UserManager().getUserDetails();
      var accessToken = userManager.accessToken;

      if (headerIncluded != null && accessToken != null && headerIncluded) {
        AppLog.debugLog("jwt token " + accessToken);
        options.headers = {
          _keyAuth: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: "application/json",

        };
      }

      if (isMultipartEnabled) {
        AppLog.debugLog("jwt token multipart enabled");

        options.contentType = "multipart/form-data";
      } else {
        AppLog.debugLog("jwt token multipart not enabled");

        options.contentType = "application/json";
      }


      Response response = await _dioClient!.request(url,
          data: postData,
          queryParameters: queryParameter,
          options: options, onSendProgress: (int sent, int total) {
        AppLog.debugLog("${sent / total * 100} total sent");
        if (fileUploadProgress != null) {
          fileUploadProgress(sent / total * 100);
        } else {
          print("eeeeerrrrrrrrrr----000000101010");

        }
      });


      print("result.statusCode----->all_common_data");
      print("url-->${_dioClient!.options.baseUrl + url}");
      print(response);
      print(requestType);
      print(_dioClient!.options.baseUrl + url);
      print(url);
      print(accessToken);
      print(postData);
      print(_postData);
      print(response.statusCode);
      // print(response.request);
      // print(response.request.toString());
      // print(response.request.data);
      print(response.data);
      print(response.statusCode);
      print(response.statusMessage);

      AppLog.printLog("Response occurred ${response.data.toString()}");
      return ResponseStatusCodeHandler()
          .checkRequestResponseStatusCode(response);
    } catch (e) {
      print("eeeeerrrrrrrrrr----${e.toString()}");
      AppLog.printLog("Response occurred ${e}");
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
//    print(_dioErrorSection);
    String? errorDescription;
    switch (e.type) {
      case DioErrorType.cancel:
        errorDescription = PlunesStrings.cancelError;
        break;
      case DioErrorType.connectionTimeout:
        errorDescription = PlunesStrings.pleaseCheckInternetConnection;
        break;
      case DioErrorType.connectionError:
        errorDescription = PlunesStrings.noInternet;
        break;
      case DioErrorType.receiveTimeout:
        errorDescription = PlunesStrings.receiveTimeOut;
        break;
      case DioErrorType.unknown:
        try {
          HttpErrorModel httpErrorModel =
              HttpErrorModel.fromJson(e.response!.data);
//          if (httpErrorModel.statusCode == HttpResponseCode.UNAUTHORIZED) {
//            SessionExpirationEvent().getSessionEventBus().fire(RequestFailed(
//                requestCode: httpErrorModel.statusCode,
//                failureCause: httpErrorModel.message));
//            // return null;
//          }
          errorDescription = httpErrorModel?.error ??
              plunesStrings.somethingWentWrong + " - ${e.response!.statusCode}";
          AppLog.printError("$errorDescription");
        } catch (error) {
          try {
            errorDescription = plunesStrings.somethingWentWrong + " - ${e.response!.statusCode ?? ""}";
          } catch (e) {
            errorDescription = plunesStrings.somethingWentWrong;
          }
        }
        break;
      case DioErrorType.sendTimeout:
        break;
    }
    return RequestOutput(
        isRequestSucceed: false,
        failureCause: errorDescription,
        statusCode:
            e.type == DioErrorType.unknown ? e.response!.statusCode : 0);
  }

  Future<RequestOutput?> requestMethodWithNoBaseUrl(
      {final String? url,
      dynamic postData,
      dynamic queryParameter,
      final String? requestType,
      bool? headerIncluded,
      bool isMultipartEnabled = false,
      String? savePath}) async {
    RequestOutput response;
    try {
      AppLog.printLog(url);
      AppLog.printLog(_debug + _postData + " $postData");
      AppLog.printLog(_debug + _paramData + " $queryParameter");
      var options = Options(method: requestType);
      User userManager = UserManager().getUserDetails();
      var accessToken = userManager.accessToken;

      if (headerIncluded != null && accessToken != null && headerIncluded) {
        AppLog.debugLog("jwt token " + accessToken);
        options.headers = {
          _keyAuth: 'Bearer $accessToken',
        };
      }

      if (isMultipartEnabled) {
        options.contentType = "multipart/form-data";
      }
      Response response;
      if (savePath != null) {
        response = await _customClient!.download(url!, savePath);

        return ResponseStatusCodeHandler()
            .checkRequestResponseStatusCode(response);
      }
      response = await _customClient!.request(url!,
          data: postData,
          queryParameters: queryParameter,
          options: options, onSendProgress: (int sent, int total) {
        AppLog.debugLog("${sent / total * 100} total sent");
      });
      AppLog.printLog("Response occurred ${response.data.toString()}");
      return ResponseStatusCodeHandler()
          .checkRequestResponseStatusCode(response);
    } catch (e) {
      AppLog.printLog("Response occurred ${e}");
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
}
