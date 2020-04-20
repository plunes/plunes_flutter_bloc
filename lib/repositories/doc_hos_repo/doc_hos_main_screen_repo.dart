import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class DocHosMainRepo {
  static DocHosMainRepo _instance;

  DocHosMainRepo._init();

  factory DocHosMainRepo() {
    if (_instance == null) {
      _instance = DocHosMainRepo._init();
    }
    return _instance;
  }

  Future<RequestState> getRealTimeInsights() async {
    var result = await DioRequester().requestMethod(
      url: Urls.GET_REALTIME_INSIGHTS_URL,
      requestType: HttpRequestMethods.HTTP_GET,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      RealTimeInsightsResponse _realTimeInsightsResponse =
          RealTimeInsightsResponse.fromJson(result.response.data);
      return RequestSuccess(response: _realTimeInsightsResponse);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
