import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';

class AppointmentRepo {
  static AppointmentRepo _instance;

  AppointmentRepo._init();

  factory AppointmentRepo() {
    if (_instance == null) {
      _instance = AppointmentRepo._init();
    }
    return _instance;
  }

  Future<RequestState> getAppointmentDetails() async {
    var result = await DioRequester().requestMethod(
      requestType: HttpRequestMethods.HTTP_GET,
      url: (UserManager().getUserDetails().userType != Constants.user)
          ? Urls.PROF_BOOKING_URL
          : Urls.BOOKING_URL,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      AppointmentResponseModel _appointmentModel =
          AppointmentResponseModel.fromJson(result.response.data);
      return RequestSuccess(response: _appointmentModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
