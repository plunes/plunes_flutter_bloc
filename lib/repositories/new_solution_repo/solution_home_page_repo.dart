import 'package:plunes/models/doc_hos_models/common_models/media_content_model.dart';
import 'package:plunes/models/new_solution_model/know_procedure_model.dart';
import 'package:plunes/models/new_solution_model/media_content_model.dart';
import 'package:plunes/models/new_solution_model/new_speciality_model.dart';
import 'package:plunes/models/new_solution_model/professional_model.dart';
import 'package:plunes/models/new_solution_model/solution_home_scr_model.dart';
import 'package:plunes/models/new_solution_model/top_facility_model.dart';
import 'package:plunes/models/new_solution_model/top_search_model.dart';
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

  Future<RequestState> getKnowYourProcedureData() async {
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        url: Urls.KNOW_YOUR_PROCEDURE_URL,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      KnowYourProcedureModel solutionHomeScreenModel =
          KnowYourProcedureModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getProfessionalsForService(String familyId,
      {bool shouldHitSpecialityApi = false}) async {
    Map<String, dynamic> map;
    if (shouldHitSpecialityApi) {
      map = {"specialityId": familyId};
    } else {
      map = {"familyId": familyId};
    }
    var result = await DioRequester().requestMethod(
        url: shouldHitSpecialityApi
            ? Urls.GET_PROFESSIONAL_FOR_COMMON_SPECIALITY
            : Urls.GET_PROFESSIONAL_FOR_SERVICE_URL,
        headerIncluded: true,
        queryParameter: map,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      ProfessionDataModel solutionHomeScreenModel =
          ProfessionDataModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getCommonSpecialities() async {
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        url: Urls.GET_COMMON_SPECIALITIES_URL,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      NewSpecialityModel solutionHomeScreenModel =
          NewSpecialityModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getMediaContent({String mediaType}) async {
    var result = await DioRequester().requestMethodWithNoBaseUrl(
        url: Urls.GET_PLUNES_MEDIA_URL,
        headerIncluded: true,
        queryParameter: {"mediaType": mediaType},
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      MediaContentPlunes solutionHomeScreenModel =
          MediaContentPlunes.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getTopSearches() async {
    var result = await DioRequester().requestMethod(
        url: Urls.TOP_SEARCH_URL,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      TopSearchOuterModel solutionHomeScreenModel =
          TopSearchOuterModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getTopFacilities() async {
    var result = await DioRequester().requestMethod(
        url: Urls.TOP_FACILITY_URL,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      TopFacilityModel solutionHomeScreenModel =
          TopFacilityModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
