import 'package:flutter/foundation.dart';
import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/searched_solution_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class SearchSolutionBloc extends BlocBase {
  static const int initialIndex = 0;
  final _defaultStreamProvider = PublishSubject<RequestState>();
  final _searchStreamProvider = PublishSubject<RequestState>();
  final _docHosStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> getDefaultCatalogueStream() =>
      _defaultStreamProvider.stream;

  Observable<RequestState> getSearchCatalogueStream() =>
      _searchStreamProvider.stream;

  Observable<RequestState> getDocHosStream() => _docHosStreamProvider.stream;

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
    super.dispose();
  }

  Future<RequestState> getDocHosSolution(final String serviceId) async {
    var result = await SearchedSolutionRepo().getDocHosSolution(serviceId);
    addIntoDocHosStream(result);
    return result;
  }

  void addIntoDocHosStream(RequestState requestState) {
    if (_docHosStreamProvider != null && !_docHosStreamProvider.isClosed) {
      _docHosStreamProvider.add(requestState);
    }
  }
}
