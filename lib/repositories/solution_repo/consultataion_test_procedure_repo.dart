import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/models/solution_models/test_and_procedure_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class ConsultationTestProcedureRepo {
  static ConsultationTestProcedureRepo? _instance;

  ConsultationTestProcedureRepo._init();

  factory ConsultationTestProcedureRepo() {
    if (_instance == null) {
      _instance = ConsultationTestProcedureRepo._init();
    }
    return _instance!;
  }

  Future<RequestState> getConsultations() async {
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {"userId": UserManager().getUserDetails().uid},
        url: Urls.GET_CONSULTATION_API);
    if (serverResponse!.isRequestSucceed!) {
      List<CatalogueData> _solutions = [];
      if (serverResponse.response!.data != null &&
          serverResponse.response!.data["data"] != null) {
        Iterable _items = serverResponse.response!.data["data"];
        _solutions = _items
            .map((item) => CatalogueData.fromJson(item))
            .toList(growable: true);
      }
      return RequestSuccess(response: _solutions);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }

  Future<RequestState> getDetails(bool isProcedure) async {
    var serverResponse = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        url: isProcedure ? Urls.GET_PROCEDURES_API : Urls.GET_TESTS_API);
    if (serverResponse!.isRequestSucceed!) {
      List<TestAndProcedureResponseModel> _solutions = [];
      if (serverResponse.response!.data != null &&
          serverResponse.response!.data["data"] != null) {
        Iterable _items = serverResponse.response!.data["data"];
        _solutions = _items
            .map((item) => TestAndProcedureResponseModel.fromJson(item))
            .toList(growable: true);
      }
      return RequestSuccess(response: _solutions);
    } else {
      return RequestFailed(failureCause: serverResponse.failureCause);
    }
  }
}
