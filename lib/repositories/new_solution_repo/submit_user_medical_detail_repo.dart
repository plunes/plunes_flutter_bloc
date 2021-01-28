import 'dart:io';
import 'package:dio/dio.dart';
import 'package:plunes/models/new_solution_model/medical_file_upload_response_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class SubmitMedicalDetailRepo {
  static SubmitMedicalDetailRepo _instance;

  SubmitMedicalDetailRepo._init();

  factory SubmitMedicalDetailRepo() {
    if (_instance == null) {
      _instance = SubmitMedicalDetailRepo._init();
    }
    return _instance;
  }

  Future<RequestState> submitUserMedicalDetail(
      Map<String, dynamic> postData) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        url: Urls.SUBMIT_USER_MEDICAL_DETAIL_URL,
        headerIncluded: true,
        postData: postData);
    if (result.isRequestSucceed) {
      bool isSuccess = false;
      if (result.response != null &&
          result.response.data != null &&
          result.response.data["success"] != null) {
        isSuccess = result.response.data["success"];
      }
      return RequestSuccess(response: isSuccess);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> uploadFile(File file, {String fileType}) async {
    MultipartFile value = await MultipartFile.fromFile(file.path);
    Map<String, dynamic> fileData = {"file": value};
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_POST,
      url: Urls.UPLOAD_MEDICAL_FILE_URL,
      headerIncluded: true,
      isMultipartEnabled: true,
      queryParameter: {"reportType": fileType},
      postData: FormData.fromMap(fileData),
    );
    if (result.isRequestSucceed) {
      MedicalFileResponseModel _medicalFileResponseModel =
          MedicalFileResponseModel.fromJson(result.response.data);
      return RequestSuccess(
          response: _medicalFileResponseModel, additionalData: fileType);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
