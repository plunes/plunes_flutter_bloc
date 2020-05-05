import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
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

  Future<RequestState> getSearchedSolution(
      String searchedString, int index) async {
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {"expression": searchedString, "page": index},
        url: Urls.SEARCH_SOLUTION_API);
    if (serverResponse.isRequestSucceed) {
      List<CatalogueData> _solutions = [];
      Iterable _items = serverResponse.response.data;
      _solutions = _items
          .map((item) => CatalogueData.fromJson(item))
          .toList(growable: true);
      return RequestSuccess(response: _solutions, requestCode: index);
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
          "page": pageIndex
        },
        url: Urls.GET_TEST_AND_PROCEDURES_CATALOGUE_API);
    if (serverResponse.isRequestSucceed) {
      List<CatalogueData> _solutions = [];
      Iterable _items = serverResponse.response.data;
      _solutions = _items
          .map((item) => CatalogueData.fromJson(item))
          .toList(growable: true);
      return RequestSuccess(response: _solutions);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> getDocHosSolution(
      final CatalogueData catalogueData) async {
    final double _lat = 28.4594965, _long = 77.0266383;
    User _user = UserManager().getUserDetails();
//    print("userdetsils ${_user.toString()}");
    double lat;
    double long;
    Map<String, dynamic> queryParams;
    if (catalogueData.isFromNotification != null &&
        catalogueData.isFromNotification) {
      queryParams = {
        "solutionId": catalogueData.solutionId,
        "notification": catalogueData.isFromNotification,
      };
    } else {
      queryParams = {
        "serviceId": catalogueData.serviceId,
        "latitude": lat ?? _lat,
        "longitude": long ?? _long
      };
    }
    try {
      lat = double.parse(_user.latitude);
      long = double.parse(_user.longitude);
    } catch (e) {}
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        url: Urls.GET_DOC_HOS_API,
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
}
