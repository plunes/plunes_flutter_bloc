import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class TestProcedureCatalogueScreen extends BaseActivity {
  final bool isProcedure;
  final String specialityId;
  final String title;

  TestProcedureCatalogueScreen(
      {this.isProcedure, this.specialityId, this.title});

  @override
  _TestProcedureSubScreenState createState() => _TestProcedureSubScreenState();
}

class _TestProcedureSubScreenState
    extends BaseState<TestProcedureCatalogueScreen> {
  List<CatalougeData> _searchedCatalogueList;
  List<CatalougeData> _defaultCatalogueList;
  Function onViewMoreTap;
  TextEditingController _searchController;
  Timer _debounce;
  SearchSolutionBloc _searchSolutionBloc;
  int _pageIndexForSearchedCatalogues = SearchSolutionBloc.initialIndex,
      _pageIndexForDefaultCatalogueList = SearchSolutionBloc.initialIndex;
  StreamController _searchStreamController;
  bool _endReachedForSearchedList, _endReachedForDefaultList;
  String _failureCause;
  bool _isFetchingInitialData,
      _isAlreadyFetchingDefaultData,
      _isAlreadyFetchingSearchedData;

  @override
  void initState() {
    _searchedCatalogueList = [];
    _defaultCatalogueList = [];
    _isFetchingInitialData = true;
    _endReachedForSearchedList = false;
    _endReachedForDefaultList = false;
    _isAlreadyFetchingDefaultData = false;
    _isAlreadyFetchingSearchedData = false;
    _searchSolutionBloc = SearchSolutionBloc();
    _getInitialList();
    _searchStreamController = StreamController.broadcast();
    _searchController = TextEditingController()..addListener(_onSearch);
    super.initState();
  }

  _setState() {
    if (mounted) setState(() {});
  }

  _getInitialList() {
    _pageIndexForDefaultCatalogueList = SearchSolutionBloc.initialIndex;
    _isFetchingInitialData = true;
    _setState();
    _getDefaultCatalogueList().then((result) {
      if (result is RequestSuccess) {
        _defaultCatalogueList = [];
        _defaultCatalogueList = result.response;
        if (_defaultCatalogueList.isEmpty) {
          _failureCause = PlunesStrings.serviceNotAvailable;
        } else {
          _pageIndexForDefaultCatalogueList++;
        }
      } else if (result is RequestFailed) {
        _failureCause = result.failureCause;
      }
      _isFetchingInitialData = false;
      _setState();
    });
  }

  Future<RequestState> _getDefaultCatalogueList() {
    return _searchSolutionBloc.getCataloguesForTestAndProcedures(
        "", widget.specialityId, widget.isProcedure,
        pageIndex: _pageIndexForDefaultCatalogueList);
  }

  _getSearchedCatalogueList() {
    _searchSolutionBloc.getCataloguesForTestAndProcedures(
        _searchController.text.trim().toString(),
        widget.specialityId,
        widget.isProcedure,
        pageIndex: _pageIndexForSearchedCatalogues);
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearch);
    _searchController?.dispose();
    _debounce?.cancel();
    _searchSolutionBloc?.dispose();
    _searchStreamController?.close();
    _searchSolutionBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar:
              widget.getAppBar(context, widget.title ?? PlunesStrings.NA, true),
          body: Builder(builder: (context) {
            return Container(
              padding: CustomWidgets().getDefaultPaddingForScreens(),
              width: double.infinity,
              child: _isFetchingInitialData
                  ? CustomWidgets().getProgressIndicator()
                  : _defaultCatalogueList == null ||
                          _defaultCatalogueList.isEmpty
                      ? CustomWidgets().errorWidget(_failureCause)
                      : _showBody(),
            );
          }),
        ));
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        StreamBuilder(
          builder: (context, snapShot) {
            return CustomWidgets().searchBar(
                hintText: plunesStrings.searchHint,
                hasFocus: false,
                searchController: _searchController);
          },
          stream: _searchStreamController.stream,
        ),
        widget.getSpacer(
            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
        widget.getSpacer(
            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
        Expanded(
            child: StreamBuilder(
          builder: (context, snapShot) {
            return _searchController != null &&
                    _searchController.text != null &&
                    _searchController.text.trim().isNotEmpty
                ? _streamBuilderForSearchedList()
                : _streamBuilderForDefaultList();
          },
          stream: _searchStreamController.stream,
        ))
      ],
    );
  }

  Widget _streamBuilderForSearchedList() {
    return StreamBuilder<RequestState>(
      builder: (context, snapShot) {
        if (snapShot.data is RequestSuccess) {
          RequestSuccess _requestSuccessObject = snapShot.data;
          if (_requestSuccessObject.requestCode ==
              SearchSolutionBloc.initialIndex) {
            _pageIndexForSearchedCatalogues = SearchSolutionBloc.initialIndex;
            _searchedCatalogueList = [];
          }
          if (_requestSuccessObject.requestCode !=
                  SearchSolutionBloc.initialIndex &&
              _requestSuccessObject.response.isEmpty) {
            _endReachedForSearchedList = true;
          } else {
            _endReachedForSearchedList = false;
            Set _allItems = _searchedCatalogueList.toSet();
            _allItems.addAll(_requestSuccessObject.response);
            _searchedCatalogueList = _allItems.toList(growable: true);
          }
          if (_requestSuccessObject.requestCode ==
                  SearchSolutionBloc.initialIndex &&
              _requestSuccessObject.response.isEmpty) {
            _failureCause = PlunesStrings.serviceNotAvailable;
          }
          _pageIndexForSearchedCatalogues++;
        } else if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailedObject = snapShot.data;
          _failureCause = _requestFailedObject.failureCause;
          _pageIndexForSearchedCatalogues = SearchSolutionBloc.initialIndex;
        }
        return _searchedCatalogueList == null || _searchedCatalogueList.isEmpty
            ? Text(PlunesStrings.noSolutionsAvailable)
            : Column(
                children: <Widget>[
                  Expanded(
                    child: _showSearchedItems(),
                    flex: 4,
                  ),
                  snapShot.data is RequestInProgress
                      ? Expanded(
                          child: CustomWidgets().getProgressIndicator(),
                          flex: 1,
                        )
                      : Container()
                ],
              );
      },
      stream: _searchSolutionBloc.getSearchCatalogueStream(),
    );
  }

  Widget _streamBuilderForDefaultList() {
    return StreamBuilder<RequestState>(
      builder: (context, snapShot) {
        if (snapShot.data is RequestSuccess) {
          RequestSuccess _requestSuccessObject = snapShot.data;
          if (_requestSuccessObject.requestCode ==
              SearchSolutionBloc.initialIndex) {
            _pageIndexForDefaultCatalogueList = SearchSolutionBloc.initialIndex;
            _defaultCatalogueList = [];
          }
          if (_requestSuccessObject.requestCode !=
                  SearchSolutionBloc.initialIndex &&
              _requestSuccessObject.response.isEmpty) {
            _endReachedForDefaultList = true;
          } else {
            _endReachedForDefaultList = false;
            Set _allItems = _searchedCatalogueList.toSet();
            _allItems.addAll(_requestSuccessObject.response);
            _defaultCatalogueList = _allItems.toList(growable: true);
          }
          if (_requestSuccessObject.requestCode ==
                  SearchSolutionBloc.initialIndex &&
              _requestSuccessObject.response.isEmpty) {
            _failureCause = PlunesStrings.serviceNotAvailable;
          }
          _pageIndexForDefaultCatalogueList++;
        } else if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailedObject = snapShot.data;
          _failureCause = _requestFailedObject.failureCause;
          _pageIndexForDefaultCatalogueList = SearchSolutionBloc.initialIndex;
        }
        return _defaultCatalogueList == null || _defaultCatalogueList.isEmpty
            ? CustomWidgets().errorWidget(_failureCause)
            : Column(
                children: <Widget>[
                  Expanded(
                    child: _showDefaultItems(),
                    flex: 4,
                  ),
                  snapShot.data is RequestInProgress
                      ? Expanded(
                          child: CustomWidgets().getProgressIndicator(),
                          flex: 1,
                        )
                      : Container()
                ],
              );
      },
      stream: _searchSolutionBloc.getDefaultCatalogueStream(),
    );
  }

  _onSolutionItemTap(int index) {
    print("whole button tapped");
  }

  _onViewMoreTap(int solution) {
    print("index is $solution");
  }

  _onSearch() {
    _searchStreamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController != null &&
          _searchController.text != null &&
          _searchController.text.trim().isNotEmpty) {
        _getSearchedCatalogueList();
      } else {
        _searchedCatalogueList = [];
        _searchSolutionBloc.addIntoSearchedStream(null);
      }
    });
  }

  Widget _showSearchedItems() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollState) {
        if (scrollState is ScrollEndNotification &&
            scrollState.metrics.extentAfter == 0 &&
            _searchController.text.trim().isNotEmpty &&
            !_endReachedForSearchedList) {
          if (_isAlreadyFetchingSearchedData == null) {
            _isAlreadyFetchingSearchedData = false;
          }
          if (_isAlreadyFetchingSearchedData) return;
          _isAlreadyFetchingSearchedData = true;
          Future.delayed(Duration(milliseconds: 200), () {
            _isAlreadyFetchingSearchedData = false;
          });

          print(
              "_pageIndexForSearchedCatalogues _showSearchedItems $_pageIndexForSearchedCatalogues");
          _searchSolutionBloc.addIntoStream(RequestInProgress());
          _getSearchedCatalogueList();
        }
        return;
      },
      child: _renderList(_searchedCatalogueList),
    );
  }

  Widget _showDefaultItems() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollState) {
        if (scrollState is ScrollEndNotification &&
            scrollState.metrics.extentAfter == 0 &&
            !_endReachedForDefaultList) {
          print(
              "_endReachedForDefaultList _showDefaultItems $_endReachedForDefaultList");
          if (_isAlreadyFetchingDefaultData == null) {
            _isAlreadyFetchingDefaultData = false;
          }
          if (_isAlreadyFetchingDefaultData) return;
          _isAlreadyFetchingDefaultData = true;
          Future.delayed(Duration(milliseconds: 1000), () {
            _isAlreadyFetchingDefaultData = false;
          });
          print(
              "_endReachedForDefaultList _showDefaultItems $_endReachedForDefaultList");
          _searchSolutionBloc.addIntoDefaultStream(RequestInProgress());
          _getDefaultCatalogueList();
        }
        return;
      },
      child: _renderList(_defaultCatalogueList),
    );
  }

  Widget _renderList(List<CatalougeData> catalogueList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
          ..onTap = () => _onViewMoreTap(index);
        return CustomWidgets().getSolutionRow(catalogueList, index,
            onButtonTap: () => _onSolutionItemTap(index),
            onViewMoreTap: tapRecognizer);
      },
      shrinkWrap: true,
      itemCount: catalogueList.length,
    );
  }
}
