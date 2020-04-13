import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
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

}
