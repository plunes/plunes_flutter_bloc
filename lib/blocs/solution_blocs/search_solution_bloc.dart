import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/solution_repo/searched_solution_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class SearchSolutionBloc extends BlocBase {
  static const int initialIndex = 0;
  final _defaultStreamProvider = PublishSubject<RequestState?>();
  final _searchStreamProvider = PublishSubject<RequestState?>();
  final _docHosStreamProvider = PublishSubject<RequestState?>();
  final _moreFacilitiesProvider = PublishSubject<RequestState?>();
  final _facilitiesAdditionProvider = PublishSubject<RequestState?>();
  final _manualBiddingFacilitiesProvider = PublishSubject<RequestState?>();
  final _manualBiddingAdditionProvider = PublishSubject<RequestState?>();
  final _discoverPriceStreamProvider = PublishSubject<RequestState?>();
  final _popularCitiesStreamProvider = PublishSubject<RequestState?>();

  Stream<RequestState?> get popularCitiesAndServicesStream =>
      _popularCitiesStreamProvider.stream;

  Stream<RequestState?> get discoverPriceStream =>
      _discoverPriceStreamProvider.stream;

  Stream<RequestState?> getDefaultCatalogueStream() =>
      _defaultStreamProvider.stream;

  Stream<RequestState?> getSearchCatalogueStream() =>
      _searchStreamProvider.stream;

  Stream<RequestState?> getDocHosStream() => _docHosStreamProvider.stream;

  Stream<RequestState?> getMoreFacilitiesStream() =>
      _moreFacilitiesProvider.stream;

  Stream<RequestState?> getFacilityAdditionStream() =>
      _facilitiesAdditionProvider.stream;

  Stream<RequestState?> getManualBiddingStream() =>
      _manualBiddingFacilitiesProvider.stream;

  Stream<RequestState?> getManualBiddingAdditionStream() =>
      _manualBiddingAdditionProvider.stream;

  Future<RequestState> getSearchedSolution({required String searchedString, int index = initialIndex, bool isFacilitySelected = false}) async {
    if (isFacilitySelected) {
      super.addIntoStream(RequestInProgress());
    }

    print("data------>${isFacilitySelected}");

    var result = await SearchedSolutionRepo().getSearchedSolution(
        searchedString, index, isFacilitySelected: isFacilitySelected);

    if (searchedString == null || searchedString.isEmpty) {
      addIntoDefaultStream(result);
    } else {
      addIntoSearchedStream(result);
    }
    return result;

  }

  void addState(RequestState? requestState) {
    super.addIntoStream(requestState);
  }

  Future<RequestState> getCataloguesForTestAndProcedures(
      String searchedString, final String? specId, bool isProcedure,
      {int pageIndex = initialIndex}) async {
    var result = await SearchedSolutionRepo().getCataloguesForTestAndProcedures(
        searchedString, specId, pageIndex, isProcedure);
    if (searchedString == null || searchedString.isEmpty) {
      addIntoDefaultStream(result);
    } else {
      addIntoSearchedStream(result);
    }
    return result;
  }

  void addIntoDefaultStream(RequestState? requestState) {
    if (_defaultStreamProvider != null && !_defaultStreamProvider.isClosed) {
      _defaultStreamProvider.add(requestState);
    }
  }

  void addIntoSearchedStream(RequestState? requestState) {
    if (_searchStreamProvider != null && !_searchStreamProvider.isClosed) {
      _searchStreamProvider.add(requestState);
    }
  }

  @override
  void dispose() {
    _defaultStreamProvider?.close();
    _searchStreamProvider?.close();
    _docHosStreamProvider?.close();
    _moreFacilitiesProvider?.close();
    _facilitiesAdditionProvider?.close();
    _manualBiddingFacilitiesProvider?.close();
    _manualBiddingAdditionProvider?.close();
    _discoverPriceStreamProvider?.close();
    _popularCitiesStreamProvider?.close();
    super.dispose();
  }

  Future<RequestState> getDocHosSolution(final CatalogueData catalogueData, var data,
      {final String? searchQuery, String? userReportId}) async {

print("))))-----((((((-----)))))-----(((----newurl-data--->${data}");


var result = await SearchedSolutionRepo().getDocHosSolution(catalogueData,
        searchQuery: searchQuery, userReportId: userReportId);
    print("))))-----((((((-----)))))-----(((----newurl--else__got_the_result--->${result}");

    addIntoDocHosStream(result);
    return result;
  }

  void addIntoDocHosStream(RequestState? requestState) {
    if (_docHosStreamProvider != null && !_docHosStreamProvider.isClosed) {
      _docHosStreamProvider.add(requestState);
    }
  }

  Future<RequestState> getMoreFacilities(final DocHosSolution catalogueData,
      {final String? searchQuery,
      int pageIndex = initialIndex,
      String? userTypeFilter,
      String? facilityLocationFilter,
      String? allLocationKey}) async {
    addIntoMoreFacilitiesStream(RequestInProgress());
    var result = await SearchedSolutionRepo().getMoreFacilities(catalogueData,
        searchQuery: searchQuery,
        pageIndex: pageIndex,
        allLocationKey: allLocationKey,
        userTypeFilter: userTypeFilter,
        facilityLocationFilter: facilityLocationFilter);
    addIntoMoreFacilitiesStream(result);
    return result;
  }

  void addIntoMoreFacilitiesStream(RequestState? requestState) {
    if (_moreFacilitiesProvider != null && !_moreFacilitiesProvider.isClosed) {
      _moreFacilitiesProvider.add(requestState);
    }
  }

  Future<RequestState> addFacilitiesInSolution(
      final DocHosSolution catalogueData,
      final List<MoreFacility> facilities) async {
    addIntoFacilitiesA(RequestInProgress());
    var result = await SearchedSolutionRepo()
        .addFacilitiesInSolution(catalogueData, facilities);
    addIntoFacilitiesA(result);
    return result;
  }

  void addIntoFacilitiesA(RequestState? requestState) {
    if (_facilitiesAdditionProvider != null &&
        !_facilitiesAdditionProvider.isClosed) {
      _facilitiesAdditionProvider.add(requestState);
    }
  }

  Future<RequestState> getFacilitiesForManualBidding(
      {String? searchQuery,
      int? pageIndex,
      LatLng? latLng,
      String? specialityId}) async {
    addStateInManualBiddingStream(RequestInProgress());
    var result = await SearchedSolutionRepo().getFacilitiesForManualBidding(
        searchQuery, pageIndex, latLng, specialityId);
    addStateInManualBiddingStream(result);
    return result;
  }

  void addStateInManualBiddingStream(RequestState? requestState) {
    super.addStateInGenericStream(
        _manualBiddingFacilitiesProvider, requestState);
  }

  Future<RequestState> saveManualBiddingData(
      String query, List<MoreFacility> facilities) async {
    addStateInManualBiddingAdditionStream(RequestInProgress());
    var result =
        await SearchedSolutionRepo().saveManualBiddingData(query, facilities);
    addStateInManualBiddingAdditionStream(result);
    return result;
  }

  void addStateInManualBiddingAdditionStream(RequestState? requestState) {
    super.addStateInGenericStream(_manualBiddingAdditionProvider, requestState);
  }

  Future<RequestState> discoverPrice(
      String? solutionId, String? serviceId) async {
    addStateInDiscoverPriceStream(RequestInProgress());
    var result =
        await SearchedSolutionRepo().discoverPrice(solutionId, serviceId);
    addStateInDiscoverPriceStream(result);
    return result;
  }

  void addStateInDiscoverPriceStream(RequestState? requestState) {
    super.addStateInGenericStream(_discoverPriceStreamProvider, requestState);
  }

  Future<RequestState> getPopularCitiesAndServices() async {
    addStateInPopularCitiesAndServicesStream(RequestInProgress());
    var result = await SearchedSolutionRepo().getPopularCitiesAndServices();
    addStateInPopularCitiesAndServicesStream(result);
    return result;
  }

  void addStateInPopularCitiesAndServicesStream(RequestState? requestState) {
    super.addStateInGenericStream(_popularCitiesStreamProvider, requestState);
  }

  Future<RequestState> getCatalogueUsingFamilyId(String? familyName) {
    return SearchedSolutionRepo().getCatalogueUsingFamilyId(familyName);
  }
}
