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

  Future<RequestState> rescheduleAppointment(String bookingId, String appointmentTime, String selectedTimeSlot) async {
    String url=Urls.GET_CANCEL_AND_RESCHEDULE_URL+"/$bookingId/reschedule";
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
    String url=Urls.GET_CANCEL_AND_RESCHEDULE_URL+"/$bookingId/cancel";
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_PUT,
        headerIncluded: true,
        url: url);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.isRequestSucceed, requestCode: index);
    } else {
      return RequestFailed(failureCause: result.failureCause, requestCode: index);
    }
  }

  Future<RequestState> refundAppointment(String bookingId, String reason)async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_PUT,
        headerIncluded: true,
        postData: {
          "bookingId":bookingId,
          "reason":reason
        },
        url: Urls.GET_REFUND_URL);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.isRequestSucceed);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> confirmAppointment(String bookingId, int index) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true,
        url: Urls.GET_CONFIRM_APPOINTMENT_URL,
        queryParameter: {
          "bookingId" :bookingId,
        }
     );
    if (result.isRequestSucceed) {
      if (result.response.data["success"] != null &&
          result.response.data["success"]){
        return RequestSuccess(response: result.isRequestSucceed);
      }
    else {
      return RequestFailed(failureCause: PlunesStrings.appointmentFailedMessage);
    }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
