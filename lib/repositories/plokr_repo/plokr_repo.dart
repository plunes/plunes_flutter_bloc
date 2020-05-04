import 'dart:io';

import 'package:dio/dio.dart';
import 'package:plunes/models/plockr_model/plockr_response_model.dart';
import 'package:plunes/models/plockr_model/plockr_shareable_report_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
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

  Future<RequestState> uploadPlockrData(
    Map<String, dynamic> postData,
  ) async {
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_POST,
      url: Urls.GET_UPLOAD_PLOCKR_DATA_URL,
      headerIncluded: true,
      isMultipartEnabled: true,
      postData: FormData.fromMap(postData),
    );
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getPlockrData() async {
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_GET,
      url: Urls.GET_UPLOAD_PLOCKR_DATA_URL,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      PlockrResponseModel plockrResponseModel =
          PlockrResponseModel.fromJson(result.response.data);
      print(plockrResponseModel.uploadedReports);
      if (plockrResponseModel.uploadedReports == null ||
          plockrResponseModel.uploadedReports.isEmpty) {
        return RequestFailed(
            failureCause: PlunesStrings.noReportAvailabelMessage);
      }
      return RequestSuccess(response: plockrResponseModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getSharableLink(String id) async {
    String url = Urls.GET_SHARABLE_LINK_FILE_URL + id;
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_GET,
      url: url,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      ShareableReportModel shareableReportModel =
          ShareableReportModel.fromJson(result.response.data);
      print(shareableReportModel.link);
      return RequestSuccess(response: shareableReportModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> deletePlockrFile(String id) async {
    String url = Urls.GET_UPLOAD_PLOCKR_DATA_URL + '/$id';
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_DELETE,
      url: url,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      if (result.response.data["success"] != null &&
          result.response.data["success"]) {
        return RequestSuccess(response: result);
      } else {
        return RequestFailed(failureCause: PlunesStrings.unableToDelete);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
