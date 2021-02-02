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
  final _defaultStreamProvider = PublishSubject<RequestState>();
  final _searchStreamProvider = PublishSubject<RequestState>();
  final _docHosStreamProvider = PublishSubject<RequestState>();
  final _moreFacilitiesProvider = PublishSubject<RequestState>();
  final _facilitiesAdditionProvider = PublishSubject<RequestState>();
  final _manualBiddingFacilitiesProvider = PublishSubject<RequestState>();
  final _manualBiddingAdditionProvider = PublishSubject<RequestState>();
  final _discoverPriceStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get discoverPriceStream =>
      _discoverPriceStreamProvider.stream;

  Observable<RequestState> getDefaultCatalogueStream() =>
      _defaultStreamProvider.stream;

  Observable<RequestState> getSearchCatalogueStream() =>
      _searchStreamProvider.stream;

  Observable<RequestState> getDocHosStream() => _docHosStreamProvider.stream;

  Observable<RequestState> getMoreFacilitiesStream() =>
      _moreFacilitiesProvider.stream;

  Observable<RequestState> getFacilityAdditionStream() =>
      _facilitiesAdditionProvider.stream;

  Observable<RequestState> getManualBiddingStream() =>
      _manualBiddingFacilitiesProvider.stream;

  Observable<RequestState> getManualBiddingAdditionStream() =>
      _manualBiddingAdditionProvider.stream;

  Future getSearchedSolution({
    @required String searchedString,
    int index = initialIndex,
  }) async {
    super.addIntoStream(await SearchedSolutionRepo()
        .getSearchedSolution(searchedString, index));
  }

  void addState(RequestState requestState) {
    super.addIntoStream(requestState);
  }

  Future<RequestState> getCataloguesForTestAndProcedures(
      String searchedString, final String specId, bool isProcedure,
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

  void addIntoDefaultStream(RequestState requestState) {
    if (_defaultStreamProvider != null && !_defaultStreamProvider.isClosed) {
      _defaultStreamProvider.add(requestState);
    }
  }

  void addIntoSearchedStream(RequestState requestState) {
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
    super.dispose();
  }

  Future<RequestState> getDocHosSolution(final CatalogueData catalogueData,
      {final String searchQuery}) async {
    var result = await SearchedSolutionRepo()
        .getDocHosSolution(catalogueData, searchQuery: searchQuery);
    addIntoDocHosStream(result);
    return result;
  }

  void addIntoDocHosStream(RequestState requestState) {
    if (_docHosStreamProvider != null && !_docHosStreamProvider.isClosed) {
      _docHosStreamProvider.add(requestState);
    }
  }

  Future<RequestState> getMoreFacilities(final DocHosSolution catalogueData,
      {final String searchQuery,
      int pageIndex = initialIndex,
      String userTypeFilter,
      String facilityLocationFilter,
      String allLocationKey}) async {
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

  void addIntoMoreFacilitiesStream(RequestState requestState) {
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

  void addIntoFacilitiesA(RequestState requestState) {
    if (_facilitiesAdditionProvider != null &&
        !_facilitiesAdditionProvider.isClosed) {
      _facilitiesAdditionProvider.add(requestState);
    }
  }

  Future<RequestState> getFacilitiesForManualBidding(
      {String searchQuery,
      int pageIndex,
      LatLng latLng,
      String specialityId}) async {
    addStateInManualBiddingStream(RequestInProgress());
    var result = await SearchedSolutionRepo().getFacilitiesForManualBidding(
        searchQuery, pageIndex, latLng, specialityId);
    addStateInManualBiddingStream(result);
    return result;
  }

  void addStateInManualBiddingStream(RequestState requestState) {
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

  void addStateInManualBiddingAdditionStream(RequestState requestState) {
    super.addStateInGenericStream(_manualBiddingAdditionProvider, requestState);
  }

  Future<RequestState> discoverPrice(
      String solutionId, String serviceId) async {
    addStateInDiscoverPriceStream(RequestInProgress());
    var result =
        await SearchedSolutionRepo().discoverPrice(solutionId, serviceId);
    addStateInDiscoverPriceStream(result);
    return result;
  }

  void addStateInDiscoverPriceStream(RequestState requestState) {
    super.addStateInGenericStream(_discoverPriceStreamProvider, requestState);
  }
}
