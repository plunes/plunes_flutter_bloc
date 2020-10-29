import 'package:plunes/models/explore/explore_main_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class ExploreMainRepo {
  Future<RequestState> getExploreData() async {
    var result = await DioRequester().requestMethod(
        url: Urls.EXPLORE_URL, requestType: HttpRequestMethods.HTTP_GET);
    ExploreOuterModel _exploreModel;
    if (result.isRequestSucceed) {
      try {
        _exploreModel = ExploreOuterModel.fromJson(result.response.data);
      } catch (e) {
        print("error occur ExploreMainRepo $e");
      }
      if (_exploreModel != null &&
          _exploreModel.success != null &&
          _exploreModel.success &&
          _exploreModel.data != null &&
          _exploreModel.data.isNotEmpty) {
        return RequestSuccess(response: _exploreModel);
      } else {
        return RequestFailed(
            failureCause: _exploreModel?.msg ?? result.failureCause);
      }
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
