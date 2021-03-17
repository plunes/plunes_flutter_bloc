import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/new_solution_repo/solution_home_page_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreenMainBloc extends BlocBase {
  final _categoryStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getHomeScreenDetailStream =>
      _categoryStreamProvider.stream;
  final _whyUsStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getWhyUsStream => _whyUsStreamProvider.stream;

  final _whyUsCardByIdStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getWhyUsCardByIdStream =>
      _whyUsCardByIdStreamProvider.stream;
  final _knowYourProcedureStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get knowYourProcedureStream =>
      _knowYourProcedureStreamProvider.stream;
  final _getProfessionalForServiceStreamProvider =
      PublishSubject<RequestState>();

  Observable<RequestState> get professionalForServiceStream =>
      _getProfessionalForServiceStreamProvider.stream;
  final _getCommonSpecialityDataStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get commonSpecialityStream =>
      _getCommonSpecialityDataStreamProvider.stream;
  final _mediaStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get mediaStream => _mediaStreamProvider.stream;

  final _topSearchStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get topSearchStream =>
      _topSearchStreamProvider.stream;
  final _topFacilityStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get topFacilityStream =>
      _topFacilityStreamProvider.stream;

  @override
  void dispose() {
    _categoryStreamProvider?.close();
    _whyUsStreamProvider?.close();
    _whyUsCardByIdStreamProvider?.close();
    _knowYourProcedureStreamProvider?.close();
    _getProfessionalForServiceStreamProvider?.close();
    _getCommonSpecialityDataStreamProvider?.close();
    _mediaStreamProvider?.close();
    _topSearchStreamProvider?.close();
    _topFacilityStreamProvider?.close();
    super.dispose();
  }

  Future<RequestState> getSolutionHomePageCategoryData() async {
    addIntoSolutionHomePageCategoryData(RequestInProgress());
    var result = await HomeScreenMainRepo().getSolutionHomePageCategoryData();
    addIntoSolutionHomePageCategoryData(result);
    return result;
  }

  void addIntoSolutionHomePageCategoryData(RequestState state) {
    addStateInGenericStream(_categoryStreamProvider, state);
  }

  Future<RequestState> getWhyUsData() async {
    addIntoGetWhyUsDataStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getWhyUsData();
    addIntoGetWhyUsDataStream(result);
    return result;
  }

  void addIntoGetWhyUsDataStream(RequestState state) {
    addStateInGenericStream(_whyUsStreamProvider, state);
  }

  Future<RequestState> getWhyUsDataById(String cardId) async {
    addIntoGetWhyUsDataByIdStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getWhyUsDataById(cardId);
    addIntoGetWhyUsDataByIdStream(result);
    return result;
  }

  void addIntoGetWhyUsDataByIdStream(RequestState state) {
    addStateInGenericStream(_whyUsCardByIdStreamProvider, state);
  }

  Future<RequestState> getKnowYourProcedureData() async {
    addIntoKnowYourProcedureDataStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getKnowYourProcedureData();
    addIntoKnowYourProcedureDataStream(result);
    return result;
  }

  void addIntoKnowYourProcedureDataStream(RequestState state) {
    addStateInGenericStream(_knowYourProcedureStreamProvider, state);
  }

  Future<RequestState> getProfessionalsForService(String familyId,
      {bool shouldHitSpecialityApi = false,
      bool shouldShowNearFacilities}) async {
    addIntoGetProfessionalForServiceDataStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getProfessionalsForService(familyId,
        shouldHitSpecialityApi: shouldHitSpecialityApi,
        shouldShowNearFacilities: shouldShowNearFacilities);
    addIntoGetProfessionalForServiceDataStream(result);
    return result;
  }

  void addIntoGetProfessionalForServiceDataStream(RequestState state) {
    addStateInGenericStream(_getProfessionalForServiceStreamProvider, state);
  }

  Future<RequestState> getCommonSpecialities() async {
    addIntoGetCommonSpecialitiesDataStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getCommonSpecialities();
    addIntoGetCommonSpecialitiesDataStream(result);
    return result;
  }

  void addIntoGetCommonSpecialitiesDataStream(RequestState state) {
    addStateInGenericStream(_getCommonSpecialityDataStreamProvider, state);
  }

  Future<RequestState> getMediaContent({String mediaType}) async {
    addIntoMediaStream(RequestInProgress());
    var result =
        await HomeScreenMainRepo().getMediaContent(mediaType: mediaType);
    addIntoMediaStream(result);
    return result;
  }

  void addIntoMediaStream(RequestState state) {
    addStateInGenericStream(_mediaStreamProvider, state);
  }

  Future<RequestState> getTopSearches() async {
    addIntoTopSearchStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getTopSearches();
    addIntoTopSearchStream(result);
    return result;
  }

  void addIntoTopSearchStream(RequestState state) {
    addStateInGenericStream(_topSearchStreamProvider, state);
  }

  Future<RequestState> getTopFacilities(
      {String specialityId,
      bool shouldSortByNearest,
      String facilityType,
      bool isInitialRequest = false}) async {
    addIntoTopFacilityStream(RequestInProgress());
    if (isInitialRequest &&
        HomeScreenMainRepo().getTopFacilityModelCachedData() != null) {
      addIntoTopFacilityStream(RequestSuccess(
          response: HomeScreenMainRepo().getTopFacilityModelCachedData()));
    }
    var result = await HomeScreenMainRepo().getTopFacilities(
        facilityType: facilityType,
        shouldSortByNearest: shouldSortByNearest,
        specialityId: specialityId,
        isInitialRequest: isInitialRequest);
    addIntoTopFacilityStream(result);
    return result;
  }

  void addIntoTopFacilityStream(RequestState state) {
    addStateInGenericStream(_topFacilityStreamProvider, state);
  }
}
