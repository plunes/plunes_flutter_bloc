import 'package:dio/dio.dart';
import 'package:plunes/models/cart_models/cart_main_model.dart';
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
      String message;
      if (result.response != null &&
          result.response.data != null &&
          result.response.data["msg"] != null) {
        message = result.response.data["msg"];
      }
      return RequestSuccess(response: message);
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
      CartOuterModel cartOuterModel =
          CartOuterModel.fromJson(result.response.data);
      if (cartOuterModel.data == null ||
          cartOuterModel.data.bookingIds == null ||
          cartOuterModel.data.bookingIds.isEmpty) {
        return RequestFailed(
            failureCause: (cartOuterModel != null &&
                    cartOuterModel.msg != null &&
                    cartOuterModel.msg.isNotEmpty)
                ? cartOuterModel.msg
                : "Your cart is still empty.Discover Price Of your Treatment Now!");
      }
      return RequestSuccess(response: cartOuterModel);
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
        String message;
        if (result.response != null &&
            result.response.data != null &&
            result.response.data["msg"] != null) {
          message = result.response.data["msg"];
        }
        return RequestSuccess(response: bookingId, additionalData: message);
      } else {
        return RequestFailed(
            failureCause: PlunesStrings.unableToDelete, response: bookingId);
      }
    } else {
      return RequestFailed(
          failureCause: result.failureCause, response: bookingId);
    }
  }

  Future<RequestState> reGenerateCartItem(String itemId) async {
    String url = Urls.REGENERATE_CART_ITEM_URL + itemId;
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_GET,
      url: url,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      if (result.response.data["success"] != null &&
          result.response.data["success"]) {
        return RequestSuccess(response: itemId);
      } else {
        return RequestFailed(
            failureCause: plunesStrings.somethingWentWrong, response: itemId);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause, response: itemId);
    }
  }

  Future<RequestState> saveEditedPatientDetails(
      Map<String, dynamic> json) async {
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_PUT,
      postData: json,
      url: Urls.EDIT_CART_DETAIL_URL,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      if (result.response.data["success"] != null &&
          result.response.data["success"]) {
        return RequestSuccess(response: result.isRequestSucceed);
      } else {
        return RequestFailed(failureCause: plunesStrings.somethingWentWrong);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> payCartItemBill(bool creditsUsed) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {"credits": creditsUsed},
        url: Urls.PAY_CART_ITEMS_BILL_URL,
        headerIncluded: true);
    if (result.isRequestSucceed) {
      if (result.response.data["success"] != null &&
          result.response.data["success"]) {
        return RequestSuccess(response: result.isRequestSucceed);
      } else {
        return RequestFailed(failureCause: plunesStrings.somethingWentWrong);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
