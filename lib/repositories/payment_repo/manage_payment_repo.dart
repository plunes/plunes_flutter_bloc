import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class ManagePaymentRepo {
  Future<RequestState> getBankDetails() async {
    var result = await DioRequester().requestMethod(
        url: urls.userBaseUrl,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {"userId": UserManager().getUserDetails().uid});
    if (result.isRequestSucceed) {
      BankDetails _bankDetails;
      LoginPost _loginPost = LoginPost.fromJson(result.response.data);
      if (_loginPost != null &&
          _loginPost.user != null &&
          _loginPost.user.bankDetails != null) {
        _bankDetails = _loginPost.user.bankDetails;
      }
      return RequestSuccess(response: _bankDetails);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> setBankDetails(User user) async {
    var result = await DioRequester().requestMethod(
        url: urls.userBaseUrl,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_PUT,
        postData: user.toJson());
    if (result.isRequestSucceed) {
      return RequestSuccess();
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
