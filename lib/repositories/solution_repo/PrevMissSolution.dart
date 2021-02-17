import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class PrevMissSolutionRepo {
  Future<RequestState> getPrevSolutions() async {
    var result = await DioRequester().requestMethod(
        url: Urls.PREV_SOLUTION_URL,
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true);
    if (result.isRequestSucceed) {
      return RequestSuccess(
          response: PrevSearchedSolution.fromJson(result.response.data));
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getUserReport(String userReportId) async {
    //602d1c5cd08fe0328bb8c7fb
    var result = await DioRequester().requestMethod(
        url: Urls.GET_REPORT_BY_REPORT_ID,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {"userReportId": "602d1c5cd08fe0328bb8c7fb"},
        headerIncluded: true);
    if (result.isRequestSucceed) {
      UserReportOuterModel _userReport;
      try {
        _userReport = UserReportOuterModel.fromJson(result.response.data);
      } catch (e) {
        return RequestFailed(failureCause: plunesStrings.somethingWentWrong);
      }
      return RequestSuccess(response: _userReport);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
