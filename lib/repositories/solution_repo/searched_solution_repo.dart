import 'package:plunes/models/solution_models/solution_model.dart';
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
        postData: {"expression": "den", "page": index},
        url: Urls.SEARCH_SOLUTION_API);
    if (serverResponse.isRequestSucceed) {
      List<CatalougeData> _solutions = [];
      Iterable _items = serverResponse.response.data;
      _solutions = _items
          .map((item) => CatalougeData.fromJson(item))
          .toList(growable: true);
      return RequestSuccess(response: _solutions, requestCode: index);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }
}
