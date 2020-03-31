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
    var response = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_POST,
        queryParameter: {"expression": "den", "limit": 10, "page": 1},
        url: Urls.SEARCH_SOLUTION_API);
    print(response.isRequestSucceed);
    print(response.response?.data);
  }
}
