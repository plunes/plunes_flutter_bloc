import 'package:plunes/models/doc_hos_models/common_models/catalogue_service_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class CatalogueServiceRepo {
  Future<RequestState> getServiceCatalogues() async {
    var result = await DioRequester().requestMethod(
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET,
        url: Urls.CATALOGUE_SERVICE_URL);
    if (result!.isRequestSucceed!) {
      CatalogueServiceModel _catalogueServiceModel =
          CatalogueServiceModel.fromJson(result.response!.data);
      return RequestSuccess(response: _catalogueServiceModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
