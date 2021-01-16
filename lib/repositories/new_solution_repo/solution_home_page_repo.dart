import 'package:plunes/models/new_solution_model/solution_home_scr_model.dart';
import 'package:plunes/models/new_solution_model/why_us_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class HomeScreenMainRepo {
  Future<RequestState> getSolutionHomePageCategoryData() async {
    var result = await DioRequester().requestMethod(
        url: Urls.GET_HOME_SCREEN_CATEGORY_DATA_URL,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      SolutionHomeScreenModel solutionHomeScreenModel =
          SolutionHomeScreenModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getWhyUsData() async {
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        url: Urls.GET_WHY_US_URL,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      WhyUsModel solutionHomeScreenModel =
          WhyUsModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getWhyUsDataById(String cardId) async {
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        url: Urls.GET_WHY_US_BY_ID_URL + "$cardId",
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      WhyUsByIdModel solutionHomeScreenModel =
          WhyUsByIdModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
