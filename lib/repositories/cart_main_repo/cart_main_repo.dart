import 'package:dio/dio.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/models/cart_models/cart_main_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

import '../../models/booking_models/appointment_model.dart';
import '../../models/new_solution_model/hos_facility_model.dart';

class CartMainRepo {
  static CartMainRepo? _instance;

  CartMainRepo._init();

  factory CartMainRepo() {
    if (_instance == null) {
      _instance = CartMainRepo._init();
    }
    return _instance!;
  }

  Future<RequestState> addItemToCart(Map<String, dynamic> postData) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        url: Urls.ADD_TO_CART_URL,
        headerIncluded: true,
        postData: postData);
    if (result!.isRequestSucceed!) {
      String? message;
      if (result.response != null &&
          result.response!.data != null &&
          result.response!.data["msg"] != null) {
        message = result.response!.data["msg"];
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
    if (result!.isRequestSucceed!) {
      CartOuterModel cartOuterModel =
          CartOuterModel.fromJson(result.response!.data);
      if (cartOuterModel.data == null ||
          cartOuterModel.data!.bookingIds == null ||
          cartOuterModel.data!.bookingIds!.isEmpty) {
        return RequestFailed(
            failureCause: (cartOuterModel != null &&
                    cartOuterModel.msg != null &&
                    cartOuterModel.msg!.isNotEmpty)
                ? cartOuterModel.msg
                : "Your cart is empty. Discover prices for your treatment NOW!");
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
    if (result!.isRequestSucceed!) {
      if (result.response!.data["success"] != null &&
          result.response!.data["success"]) {
        String? message;
        if (result.response != null &&
            result.response!.data != null &&
            result.response!.data["msg"] != null) {
          message = result.response!.data["msg"];
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
    if (result!.isRequestSucceed!) {
      if (result.response!.data["success"] != null &&
          result.response!.data["success"]) {
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
    if (result!.isRequestSucceed!) {
      if (result.response!.data["success"] != null &&
          result.response!.data["success"]) {
        return RequestSuccess(response: result.isRequestSucceed);
      } else {
        return RequestFailed(failureCause: plunesStrings.somethingWentWrong);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> payCartItemBill(bool creditsUsed, String? cartId,
      String? paymentPercent, bool zestMoney) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          "credits": creditsUsed,
          "cartId": cartId,
          "paymentPercent": zestMoney ? null : paymentPercent,
          "zestMoney": zestMoney
        },
        url: Urls.PAY_CART_ITEMS_BILL_URL,
        headerIncluded: true);
    if (result!.isRequestSucceed!) {
      if (result.response!.data["success"] != null &&
          result.response!.data["success"]) {
        InitPaymentResponse initPaymentResponse =
            InitPaymentResponse.fromJson(result.response!.data);
        return RequestSuccess(response: initPaymentResponse);
      } else {
        return RequestFailed(failureCause: plunesStrings.somethingWentWrong);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getCartCount() async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        url: Urls.CART_COUNT_URL,
        headerIncluded: true);

    if (result!.isRequestSucceed!) {
      if (result.response!.data["success"] != null &&
          result.response!.data["success"]) {
        int? count = 0;
        if ((result.response!.data["data"] != null)) {
          count = result.response!.data["data"];
        }
        FirebaseNotification().setCartCount(count);
        return RequestSuccess(response: count);
      } else {
        return RequestFailed(failureCause: plunesStrings.somethingWentWrong);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }


  Future<RequestState> getBookingDoneViaInsurance(String bookingID) async {
    // var result = await DioRequester().requestMethod(
    //     requestType: HttpRequestMethods.HTTP_POST,
    //     postData: {
    //       "payment_id": bookingID,
    //     },
    //     queryParameter: {
    //       "payment_id": bookingID,
    //     },
    //     url: Urls.PAY_VIA_INSURANCE_PAYMENT_URL(bookingID),
    //     headerIncluded: true,
    //     isPayViaInsurance:true
    // );


    // var serverResponse = await DioRequester().requestMethod(
    //     requestType: HttpRequestMethods.HTTP_POST,
    //     postData: {"payment_id": bookingID},
    //     headerIncluded: false,
    //     isPayViaInsurance: true,
    //     isMultipartEnabled: false,
    //     url: Urls.PAY_VIA_INSURANCE_PAYMENT_URL(bookingID));

    final header = {
      "Accept" : "application/json"
    };

    var statusCode = 200;
    var response = await Dio().post("https://api.plunes.com/paymentControl/payViaInsurance/$bookingID",
      data: {"payment_id": bookingID},
      options: Options(
          followRedirects: false,
          headers : header,
          validateStatus: (status) {
            statusCode=status!;
            return status! < 500; }
      ),
    );



    print("response-----");
    print(response);
    print(response.requestOptions);
    print(response.statusCode);
    print(response.statusMessage);
    print(response.data);

    if(statusCode == 302) {
      print("30333333333333333332222222222") ;
      var model = AppointmentResponseModel(
          success: true,
          bookings:  [],
          msg: "Booking successfully done"
      );
      return RequestSuccess(response: model);

    } else {
      return RequestFailed(failureCause: "Booking failed");

    }


    // print("widget.getBookingDoneViaInsurance1-->${serverResponse}");
    // print("widget.getBookingDoneViaInsurance2-->${serverResponse.response}");
    // print("widget.getBookingDoneViaInsurance3-->${serverResponse!.statusCode!}");
    // print("widget.getBookingDoneViaInsurance4-->${serverResponse!.failureCause}");
    // print("widget.getBookingDoneViaInsurance5-->${serverResponse!.isRequestSucceed}");
    
    // if(serverResponse!.statusCode==302) {
    //   await DioRequester().requestMethod(url: "paymentControl/success",
    //   requestType: HttpRequestMethods.HTTP_GET,
    //   isPayViaInsurance: true
    //   );
    //   print("widget.getBookingDoneViaInsurance1-- asfasdf df}");
    //
    //   return RequestSuccess(response: "hosFacilityData");
    //
    // } else {
    //   if (serverResponse.isRequestSucceed!) {
    //     AppointmentResponseModel hosFacilityData = AppointmentResponseModel
    //         .fromJson(serverResponse.response!.data);
    //     return RequestSuccess(response: hosFacilityData);
    //   } else {
    //     print("widget.getBookingDoneViaInsurance_fail-->${serverResponse
    //         .failureCause}");
    //     return RequestFailed(failureCause: serverResponse.failureCause);
    //   }
    // }
    //     return RequestFailed(failureCause: "serverResponse.failureCause");

  }

}
