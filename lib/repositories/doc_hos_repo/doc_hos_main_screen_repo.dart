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

  Future<RequestState> getActionableInsights() async {
    var result = await DioRequester().requestMethod(
      url: Urls.GET_ACTIONABLE_INSIGHTS_URL,
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

  Future<RequestState> getTotalBusinessEarnedAndLoss(int days) async {
    var result = await DioRequester().requestMethod(
      url: Urls.GET_TOTAL_BUSINESS_EARNED_AND_LOSS_URL,
      requestType: HttpRequestMethods.HTTP_GET,
      queryParameter: {"days": days},
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

  Future<RequestState> updateRealTimeIsightPrice(num price, String solutionId, String serviceId) async {
    var result = await DioRequester().requestMethod(
      url: Urls.UPDATE_REALTIME_INSIGHT_PRICE_URL,
      requestType: HttpRequestMethods.HTTP_PUT,
      postData: {
        "solutionId":solutionId,
        "serviceId": serviceId,
        "updatedPrice": price},
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      return RequestSuccess(response: "");
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

 Future<RequestState> updateActionableInsightPrice(num price, String serviceId, String specialityId) async {
    var result = await DioRequester().requestMethod(
      url: Urls.UPDATE_ACTIONABLE_INSIGHT_PRICE_URL,
      requestType: HttpRequestMethods.HTTP_PATCH,
      postData: {
        "serviceId": serviceId,
        "specialityId": specialityId,
        "newPrice": price},
      headerIncluded: true,
    );
    if (result.isRequestSucceed) {
      return RequestSuccess(response: "");
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
