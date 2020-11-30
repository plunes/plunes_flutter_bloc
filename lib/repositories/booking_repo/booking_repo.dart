import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class BookingRepo {
  static BookingRepo _instance;

  BookingRepo._init();

  factory BookingRepo() {
    if (_instance == null) {
      _instance = BookingRepo._init();
    }
    return _instance;
  }

  Future<RequestState> initPayment(InitPayment initPayment) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        headerIncluded: true,
        postData: initPayment.initiatePaymentToJson(),
        url: Urls.BOOKING_URL);
    if (result.isRequestSucceed) {
      InitPaymentResponse _initPaymentResponse =
          InitPaymentResponse.fromJson(result.response.data);
      return RequestSuccess(response: _initPaymentResponse);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> rescheduleAppointment(
      String bookingId, String appointmentTime, String selectedTimeSlot) async {
    String url = Urls.GET_CANCEL_AND_RESCHEDULE_URL + "/$bookingId/reschedule";
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_PUT,
        headerIncluded: true,
        postData: {
          "timeSlot": selectedTimeSlot,
          "appointmentTime": appointmentTime
        },
        url: url);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.isRequestSucceed);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> cancelAppointment(String bookingId, int index) async {
    String url =
        Urls.GET_CANCEL_AND_RESCHEDULE_URL + "/$bookingId/cancellationRequest";
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_PUT,
        headerIncluded: true,
        url: url);
    if (result.isRequestSucceed) {
      return RequestSuccess(
          response: result.response.data["msg"], requestCode: index);
    } else {
      return RequestFailed(
          failureCause: result.failureCause, requestCode: index);
    }
  }

  Future<RequestState> refundAppointment(
      String bookingId, String reason) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_PUT,
        headerIncluded: true,
        postData: {"bookingId": bookingId, "reason": reason},
        url: Urls.GET_REFUND_URL);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.isRequestSucceed);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> confirmAppointment(String bookingId) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true,
        url: Urls.GET_CONFIRM_APPOINTMENT_URL,
        queryParameter: {
          "bookingId": bookingId,
        });
    if (result.isRequestSucceed) {
      if (result.response.data["success"] != null &&
          result.response.data["success"]) {
        return RequestSuccess(response: result.isRequestSucceed);
      } else {
        return RequestFailed(
            failureCause: PlunesStrings.appointmentFailedMessage);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> payInstallment(Map<String, dynamic> payload) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        headerIncluded: true,
        postData: payload,
        url: Urls.BOOKING_URL);
    if (result.isRequestSucceed) {
      InitPaymentResponse _initPaymentResponse =
          InitPaymentResponse.fromJson(result.response.data);
      return RequestSuccess(response: _initPaymentResponse);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> cancelPayment(String bookingId) async {
    String url = Urls.cancelPaymentUrl + "$bookingId";
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true,
        url: url);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.isRequestSucceed);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> submitRateAndReview(
      double rate, String review, String professionalId) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        headerIncluded: true,
        postData: {
          "professionalId": professionalId,
          "description": review,
          "rating": rate
        },
        url: Urls.RATE_AND_REVIEW);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.isRequestSucceed);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> requestInvoice(
      String bookingId, int index, bool shouldSendInvoice) async {
    String url = Urls.REQUEST_INVOICE_URL +
        "/$bookingId" +
        "${shouldSendInvoice ? "/true" : ""}";
//    print("url $url");
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true,
        url: url);
    if (result.isRequestSucceed) {
      String pdfUrl;
      if (result.response.data != null &&
          result.response.data['data'] != null &&
          result.response.data['data'].toString().isNotEmpty) {
        pdfUrl = result.response.data['data'];
        if (shouldSendInvoice) {
          return await _downloadInvoice(
              bookingId, index, shouldSendInvoice, pdfUrl);
        }
      }
      return RequestSuccess(response: pdfUrl, requestCode: index);
    } else {
      return RequestFailed(
          failureCause: result.failureCause, requestCode: index);
    }
  }

  Future<RequestState> processZestMoney(
      InitPayment initPayment, InitPaymentResponse initPaymentResponse) async {
//    print("Urls.ZEST_MONEY_URL ${Urls.ZEST_MONEY_URL}");
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        requestType: HttpRequestMethods.HTTP_POST,
        headerIncluded: true,
        postData: {"bookingId": initPaymentResponse.id},
        url: Urls.ZEST_MONEY_URL);
    if (result.isRequestSucceed) {
      return RequestSuccess(
          response: ZestMoneyResponseModel.fromJson(result.response.data));
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> _downloadInvoice(String bookingId, int index,
      bool shouldSendInvoice, String pdfUrl) async {
    String filePath = await _getStoragePath();
    if (filePath == null) {
      return RequestFailed(
          failureCause: "Failed to get storage access", requestCode: index);
    }
    if (await File(filePath + "/$bookingId" + ".pdf").exists()) {
      return RequestSuccess(
          response: File(filePath + "/$bookingId" + ".pdf"),
          requestCode: index,
          additionalData: pdfUrl);
    }
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        requestType: HttpRequestMethods.HTTP_GET,
        url: pdfUrl,
        savePath: filePath + "/$bookingId" + ".pdf");
//    File _pdfFile;
    if (result.isRequestSucceed) {
      try {
        return RequestSuccess(
            response: File(filePath + "/$bookingId" + ".pdf"),
            requestCode: index,
            additionalData: pdfUrl);
      } catch (e) {
        return RequestFailed(
            failureCause: "Failed to download file", requestCode: index);
      }
    } else {
      return RequestFailed(
          failureCause: result.failureCause, requestCode: index);
    }
  }

  Future<String> _getStoragePath() async {
    try {
      if (Platform.isAndroid) {
        return (await getExternalStorageDirectory()).path;
      } else if (Platform.isIOS) {
        return (await getApplicationDocumentsDirectory()).path;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
