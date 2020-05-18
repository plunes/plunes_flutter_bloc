import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class CouponRepo {
  Future<RequestState> sendCouponDetails(String couponDetail) async {
    var result = await DioRequester().requestMethod(
        postData: {"coupon": couponDetail},
        url: urls.userBaseUrl,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_PUT);
    if (result.isRequestSucceed) {
      if (result.response != null &&
          result.response.data != null &&
          result.response.data["success"] != null &&
          result.response.data["success"]) {
        return RequestSuccess(response: "Coupon applied successfully");
      }
      return RequestFailed(failureCause: result?.response?.data["message"]);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
