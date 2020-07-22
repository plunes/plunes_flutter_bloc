import 'package:plunes/models/doc_hos_models/common_models/actionable_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/total_business_earnedLoss_model.dart';
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

  Future<RequestState> getActionableInsights({String userId}) async {
    String url = Urls.GET_ACTIONABLE_INSIGHTS_URL;
    if (userId != null) {
      url = url + "?userId=$userId";
    }
    var result = await DioRequester().requestMethod(
      url: url,
      requestType: HttpRequestMethods.HTTP_GET,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      ActionableInsightResponseModel _actionableInsightsResponse =
          ActionableInsightResponseModel.fromJson(result.response.data);
      return RequestSuccess(response: _actionableInsightsResponse);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getTotalBusinessEarnedAndLoss(int days,
      {String userId}) async {
    Map<String, dynamic> _queryData = {"days": days};
    if (userId != null) {
      _queryData["userId"] = userId;
    }
    var result = await DioRequester().requestMethod(
      url: Urls.GET_TOTAL_BUSINESS_EARNED_AND_LOSS_URL,
      requestType: HttpRequestMethods.HTTP_GET,
      queryParameter: _queryData,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      TotalBusinessEarnedModel _totalBusinessEarndAndLossResponse =
          TotalBusinessEarnedModel.fromJson(result.response.data);
      return RequestSuccess(response: _totalBusinessEarndAndLossResponse);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> updateRealTimeInsightPrice(
      num price, String solutionId, String serviceId,
      {bool isSuggestive = false}) async {
    Map<String, dynamic> postData;
    if (isSuggestive) {
      postData = {
        "solutionId": solutionId,
        "serviceId": serviceId,
        "price": price
      };
    } else {
      postData = {
        "solutionId": solutionId,
        "serviceId": serviceId,
        "discount": price
      };
    }
    var result = await DioRequester().requestMethod(
      url: Urls.UPDATE_REALTIME_INSIGHT_PRICE_URL,
      requestType: HttpRequestMethods.HTTP_PUT,
      postData: postData,
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      return RequestSuccess(response: "");
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> updateActionableInsightPrice(
      num price, String serviceId, String specialityId) async {
    var result = await DioRequester().requestMethod(
      url: Urls.UPDATE_ACTIONABLE_INSIGHT_PRICE_URL,
      requestType: HttpRequestMethods.HTTP_PATCH,
      postData: {
        "serviceId": serviceId,
        "services": [
          {"specialityId": specialityId, "newPrice": price}
        ]
      },
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      return RequestSuccess(response: "");
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> helpQuery(String query) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        headerIncluded: true,
        postData: {"enquiry": query},
        url: Urls.HELP_QUERY_URL_FOR_DOC_HOS);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.isRequestSucceed);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
