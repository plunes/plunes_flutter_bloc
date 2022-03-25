import 'package:plunes/models/doc_hos_models/common_models/media_content_model.dart';
import 'package:plunes/models/new_solution_model/know_procedure_model.dart';
import 'package:plunes/models/new_solution_model/media_content_model.dart';
import 'package:plunes/models/new_solution_model/new_speciality_model.dart';
import 'package:plunes/models/new_solution_model/professional_model.dart';
import 'package:plunes/models/new_solution_model/solution_home_scr_model.dart';
import 'package:plunes/models/new_solution_model/top_facility_model.dart';
import 'package:plunes/models/new_solution_model/top_search_model.dart';
import 'package:plunes/models/new_solution_model/why_us_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class HomeScreenMainRepo {
  TopFacilityModel _topFacilityModel;
  static HomeScreenMainRepo _instance;

  HomeScreenMainRepo._init();

  factory HomeScreenMainRepo() {
    if (_instance == null) {
      _instance = HomeScreenMainRepo._init();
    }
    return _instance;
  }

  TopFacilityModel getTopFacilityModelCachedData() {
    return _topFacilityModel;
  }

  Future<RequestState> getSolutionHomePageCategoryData() async {
    var result = await DioRequester().requestMethod(
        url: Urls.GET_HOME_SCREEN_CATEGORY_DATA_URL,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    print("result.statusCode----->9");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
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
    print("result.statusCode----->8");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
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
    print("result.statusCode----->7");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
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

    print("result.statusCode----->6");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
    if (result.isRequestSucceed) {
      KnowYourProcedureModel solutionHomeScreenModel =
          KnowYourProcedureModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  // for facility newar you and all
  Future<RequestState> getProfessionalsForService(String familyId, String familyName,
      {bool shouldHitSpecialityApi = false,
      bool shouldShowNearFacilities = false}) async {
    double lat, long;
    try {
      if (UserManager().getUserDetails().latitude != null) {
        lat = double.tryParse(UserManager().getUserDetails().latitude);
        long = double.tryParse(UserManager().getUserDetails().longitude);
      }
    } catch (e) {}

    print("----shouldHitSpecialityApi---->$shouldHitSpecialityApi ----shouldShowNearFacilities---->$shouldShowNearFacilities");

    Map<String, dynamic> map;
    // if (shouldShowNearFacilities) {
      map = {
        "specialityId": familyId,
        "longitude": shouldShowNearFacilities ? long : null,
        "latitude": shouldShowNearFacilities ? lat : null,
      };
    // } else {
    //   map = {
    //     "familyId": familyId,
    //     "longitude": shouldShowNearFacilities ? long : null,
    //     "latitude": shouldShowNearFacilities ? lat : null
    //   };
    // }
    var result = await DioRequester().requestMethod(
        url: shouldHitSpecialityApi
            ? Urls.getProfessionalForCommaSpeciality(familyName, shouldShowNearFacilities ? lat.toString() : null, shouldShowNearFacilities ? long.toString() : null)
            : Urls.GET_PROFESSIONAL_FOR_SERVICE_URL,
        headerIncluded: true,
        queryParameter: map,
        requestType: HttpRequestMethods.HTTP_GET);


    print("result.statusCode----->1");
    print(Urls.getProfessionalForCommaSpeciality(familyName));
    print("familyName");
    print(familyName);
    print(shouldHitSpecialityApi);
    print(map);
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);

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

    print("result.statusCode----->2");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
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

    print("result.statusCode----->3");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
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

    print("result.statusCode----->5");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
    if (result.isRequestSucceed) {
      TopSearchOuterModel solutionHomeScreenModel =
          TopSearchOuterModel.fromJson(result.response.data);
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getTopFacilities(
      {String specialityId,
      bool shouldSortByNearest,
      String facilityType,
      bool isInitialRequest = false,
      bool isFromHomeScreen = false}) async {
    double lat, long;
    try {
      if (UserManager().getUserDetails().latitude != null &&
          !isFromHomeScreen) {
        lat = double.tryParse(UserManager().getUserDetails().latitude);
        long = double.tryParse(UserManager().getUserDetails().longitude);
      }
    } catch (e) {}
    final String all = "All";
    var result = await DioRequester().requestMethod(
        url: isFromHomeScreen
            ? Urls.TOP_FACILITY_URL_FOR_HOME_SCREEN
            : Urls.TOP_FACILITY_URL,
        queryParameter: {
          "lat": lat,
          "lng": long,
          "speciality": specialityId,
          "facilityType": (facilityType != null && facilityType == all)
              ? null
              : facilityType,
          "sortByNearest": shouldSortByNearest ?? false
        },
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);

    print("result.statusCode----->4");
    print(result.statusCode);
    print(result.isRequestSucceed);
    print(result.response);
    print(isFromHomeScreen);
    if (result.isRequestSucceed) {
      TopFacilityModel solutionHomeScreenModel =
          TopFacilityModel.fromJson(result.response.data);
      if (isInitialRequest &&
          solutionHomeScreenModel != null &&
          solutionHomeScreenModel.data != null &&
          solutionHomeScreenModel.data.isNotEmpty) {
        _topFacilityModel = solutionHomeScreenModel;
      }
      return RequestSuccess(response: solutionHomeScreenModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  void clearCache() {
    _topFacilityModel = null;
  }
}
