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
      CartOuterModel cartOuterModel =
          CartOuterModel.fromJson(result.response.data);
      if (cartOuterModel.data == null ||
          cartOuterModel.data.bookingIds == null ||
          cartOuterModel.data.bookingIds.isEmpty) {
        return RequestFailed(failureCause: "No items in cart");
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
        return RequestSuccess(response: bookingId);
      } else {
        return RequestFailed(
            failureCause: PlunesStrings.unableToDelete, response: bookingId);
      }
    } else {
      return RequestFailed(
          failureCause: result.failureCause, response: bookingId);
    }
  }
}
