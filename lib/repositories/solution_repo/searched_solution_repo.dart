import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/doc_hos_models/common_models/facility_collection_model.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class SearchedSolutionRepo {
  static SearchedSolutionRepo _instance;

  SearchedSolutionRepo._init();

  factory SearchedSolutionRepo() {
    if (_instance == null) {
      _instance = SearchedSolutionRepo._init();
    }
    return _instance;
  }

  Future<RequestState> getSearchedSolution(String searchedString, int index,
      {bool isFacilitySelected = false}) async {
    if (isFacilitySelected) {
      return getSearchedFacilities(searchedString);
    }
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          "expression": searchedString,
          "page": index,
          "userId": UserManager().getUserDetails().uid
        },
        url: Urls.SEARCH_SOLUTION_API);
    if (serverResponse.isRequestSucceed) {
      List<CatalogueData> _solutions = [];
      if (serverResponse.response.data != null &&
          serverResponse.response.data['data'] != null) {
        Iterable _items = serverResponse.response.data['data'];
        _solutions = _items
            .map((item) => CatalogueData.fromJson(item))
            .toList(growable: true);
      }
      return RequestSuccess(response: _solutions, requestCode: index);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> getSearchedFacilities(String searchedString) async {
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          "expression": searchedString,
          "userId": UserManager().getUserDetails().uid
        },
        url: Urls.SEARCH_FACILITY_API);
    if (serverResponse.isRequestSucceed) {
      List<Facility> _solutions = [];
      if (serverResponse.response.data != null &&
          serverResponse.response.data['data'] != null) {
        Iterable _items = serverResponse.response.data['data'];
        _solutions = _items
            .map((item) => Facility.fromJson(item))
            .toList(growable: true);
      }
      return RequestSuccess(
          response: _solutions, additionalData: searchedString);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> getCataloguesForTestAndProcedures(
      final String searchedString,
      final String specId,
      int pageIndex,
      bool isProcedure) async {
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          "expression": searchedString ?? "",
          "type": isProcedure ? "procedures" : "tests",
          "specialityId": specId,
          "page": pageIndex,
          "userId": UserManager().getUserDetails().uid
        },
        url: Urls.GET_TEST_AND_PROCEDURES_CATALOGUE_API);
    if (serverResponse.isRequestSucceed) {
      List<CatalogueData> _solutions = [];
      if (serverResponse.response.data != null &&
          serverResponse.response.data["data"] != null) {
        Iterable _items = serverResponse.response.data["data"];
        _solutions = _items
            .map((item) => CatalogueData.fromJson(item))
            .toList(growable: true);
      }
      return RequestSuccess(response: _solutions);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> getDocHosSolution(final CatalogueData catalogueData,
      {final String searchQuery, final String userReportId}) async {
    User _user = UserManager().getUserDetails();
    double lat;
    double long;
    try {
      if (_user.latitude != null && _user.latitude.isNotEmpty) {
        lat = double.tryParse(_user.latitude);
      } else {
        lat = 0.0;
      }
      if (_user.latitude != null && _user.latitude.isNotEmpty) {
        long = double.tryParse(_user.longitude);
      } else {
        long = 0.0;
      }
    } catch (e) {
      AppLog.printError("SearchedSolutionRepo Error in parsing double ");
    }
    Map<String, dynamic> queryParams;
    if (catalogueData.isFromNotification != null &&
        catalogueData.isFromNotification) {
      queryParams = {
        "solutionId": catalogueData.solutionId,
        "notification": catalogueData.isFromNotification,
      };
    } else if (catalogueData.isFromProfileScreen != null &&
        catalogueData.isFromProfileScreen) {
      String _loc = "";
      if (lat != null && long != null && lat != 0.0 && long != 0.0) {
        _loc = await LocationUtil().getAddressFromLatLong(
            lat.toString(), long.toString(),
            needFullLocation: true);
      }
      queryParams = {
        "serviceId": catalogueData.serviceId,
        "userReportId": catalogueData.userReportId,
        "professionalId": catalogueData.profId,
        "latitude": lat,
        "longitude": long,
        "doctorId": catalogueData.doctorId,
        "searchQuery": searchQuery,
        "geoLocationName": _loc == PlunesStrings.enterYourLocation ? "" : _loc
      };
    } else {
      String _loc = "";
      if (lat != null && long != null && lat != 0.0 && long != 0.0) {
        _loc = await LocationUtil().getAddressFromLatLong(
            lat.toString(), long.toString(),
            needFullLocation: true);
      }
      queryParams = {
        "serviceId": catalogueData.serviceId,
        "userReportId": userReportId,
        "latitude": lat,
        "longitude": long,
        "searchQuery": searchQuery,
        "geoLocationName": _loc == PlunesStrings.enterYourLocation ? "" : _loc
      };
    }
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        url: (catalogueData.isFromProfileScreen != null &&
                catalogueData.isFromProfileScreen)
            ? Urls.createSolutionFromProfProfile
            : Urls.GET_DOC_HOS_API,
        headerIncluded: true,
        queryParameter: queryParams);
    if (result.isRequestSucceed) {
      SearchedDocResults _searchedDocResult =
          SearchedDocResults.fromJson(result.response.data);
      return RequestSuccess(response: _searchedDocResult);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getMoreFacilities(DocHosSolution catalogueData,
      {String searchQuery,
      int pageIndex,
      String userTypeFilter,
      String facilityLocationFilter,
      String allLocationKey}) async {
    var userDetail = UserManager().getUserDetails();
    double latitude = double.tryParse(userDetail?.latitude ?? 0.0);
    double longitude = double.tryParse(userDetail?.longitude ?? 0.0);
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          "solutionId": catalogueData.sId,
          "page": pageIndex,
          "searchQuery": searchQuery ?? "",
          "userType":
              (allLocationKey == userTypeFilter) ? null : userTypeFilter,
          "latitude":
              (facilityLocationFilter == allLocationKey) ? null : latitude,
          "longitude":
              (facilityLocationFilter == allLocationKey) ? null : longitude,
        },
        headerIncluded: true,
        url: Urls.MORE_FACILITIES_URL);
    if (serverResponse.isRequestSucceed) {
      MoreFacilityResponse _facilitiesResponse =
          MoreFacilityResponse.fromJson(serverResponse.response.data);
      return RequestSuccess(
          response: _facilitiesResponse?.data, requestCode: pageIndex);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> addFacilitiesInSolution(
      DocHosSolution catalogueData, final List<MoreFacility> facilities) async {
    List<String> _facilityId = [];
    facilities.forEach((facility) {
      _facilityId.add(facility.sId);
    });
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          "professionalIds": _facilityId,
          "solutionId": catalogueData.sId
        },
        headerIncluded: true,
        url: Urls.ADD_TO_SOLUTION_URL);
    if (serverResponse.isRequestSucceed) {
      return RequestSuccess();
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> getFacilitiesForManualBidding(String searchQuery,
      int pageIndex, LatLng latLng, String specialityId) async {
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          "page": pageIndex,
          "searchQuery": searchQuery ?? "",
          "latitude": latLng?.latitude,
          "longitude": latLng?.longitude,
          "specialityId": specialityId
        },
        headerIncluded: true,
        url: Urls.GET_FACILITIES_MANUAL_BIDDING);
    if (serverResponse.isRequestSucceed) {
      MoreFacilityResponse _facilitiesResponse =
          MoreFacilityResponse.fromJson(serverResponse.response.data);
      return RequestSuccess(
          response: _facilitiesResponse?.data,
          requestCode: pageIndex,
          additionalData: searchQuery);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> saveManualBiddingData(
      String query, List<MoreFacility> facilities) async {
    List _facilities = [];
    facilities.forEach((facility) {
      Map<String, dynamic> item = {
        "_id": facility.sId,
        "distance": facility.distance
      };
      _facilities.add(item);
    });
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {"facilities": _facilities, "queryDetails": query},
        headerIncluded: true,
        url: Urls.CREATE_MANUAL_BIDDING_URL);
    if (serverResponse.isRequestSucceed) {
      return RequestSuccess();
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> discoverPrice(
      String solutionId, String serviceId) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        url: Urls.DISCOVER_PRICE_API,
        headerIncluded: true,
        postData: {
          "solutionId": solutionId,
          "serviceId": serviceId,
          "suggestedInsights": true
        });
    if (result.isRequestSucceed) {
      return RequestSuccess(response: true);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
