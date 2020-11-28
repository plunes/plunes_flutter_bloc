import 'package:dio/dio.dart';
import 'package:plunes/models/plockr_model/plockr_response_model.dart';
import 'package:plunes/models/plockr_model/plockr_shareable_report_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class CartMainRepo {
  static CartMainRepo _instance;

  CartMainRepo._init();

  factory CartMainRepo() {
    if (_instance == null) {
      _instance = CartMainRepo._init();
    }
    return _instance;
  }

  Future<RequestState> addItemToCart(Map<String, dynamic> postData) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        url: Urls.ADD_TO_CART_URL,
        headerIncluded: true,
        postData: postData);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getCartItems() async {
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_GET,
      url: Urls.GET_CART_ITEMS,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      PlockrResponseModel plockrResponseModel =
          PlockrResponseModel.fromJson(result.response.data);
      if ((plockrResponseModel.uploadedReports == null ||
              plockrResponseModel.uploadedReports.isEmpty) &&
          (plockrResponseModel.sharedReports == null ||
              plockrResponseModel.sharedReports.isEmpty)) {
        return RequestFailed(
            failureCause: PlunesStrings.noReportAvailabelMessage);
      }
      return RequestSuccess(response: plockrResponseModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> deleteCartItem(String bookingId) async {
    String url = Urls.DELETE_FROM_CART + bookingId;
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
