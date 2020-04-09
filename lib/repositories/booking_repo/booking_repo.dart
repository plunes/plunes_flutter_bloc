import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
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
}
