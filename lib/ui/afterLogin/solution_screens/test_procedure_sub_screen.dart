import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';

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
  List<CatalogueData> _searchedCatalogueList;
  List<CatalogueData> _defaultCatalogueList;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          backgroundColor: PlunesColors.WHITECOLOR,
          key: scaffoldKey,
          appBar:
              widget.getAppBar(context, widget.title ?? PlunesStrings.NA, true),
          body: Builder(builder: (context) {
            return Container(
              padding: CustomWidgets().getDefaultPaddingForScreensVertical(2),
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
            return Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 2),
              child: CustomWidgets().searchBar(
                  hintText: plunesStrings.searchHint,
                  hasFocus: false,
                  searchController: _searchController),
            );
          },
          stream: _searchStreamController.stream,
        ),
//        widget.getSpacer(
//            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
//        widget.getSpacer(
//            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
        Expanded(
            child: StreamBuilder(
          builder: (context, snapShot) {
            print(
                "will show searched list ${(_searchController != null && _searchController.text != null && _searchController.text.trim().isNotEmpty)}");
            return (_searchController != null &&
                    _searchController.text != null &&
                    _searchController.text.trim().isNotEmpty)
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
            if (_requestSuccessObject.response.isEmpty) {
              _failureCause = PlunesStrings.serviceNotAvailable;
            }
          }
          if (_requestSuccessObject.requestCode !=
                  SearchSolutionBloc.initialIndex &&
              _requestSuccessObject.response.isEmpty) {
            _endReachedForSearchedList = true;
          } else {
            _endReachedForSearchedList = false;
            Set _allItems = _searchedCatalogueList.toSet();
            _allItems.addAll(_requestSuccessObject.response);
            _searchedCatalogueList = [];
            _searchedCatalogueList = _allItems.toList(growable: true);
          }
          _pageIndexForSearchedCatalogues++;
          _searchSolutionBloc.addIntoSearchedStream(null);
        } else if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailedObject = snapShot.data;
          _failureCause = _requestFailedObject.failureCause;
          _pageIndexForSearchedCatalogues = SearchSolutionBloc.initialIndex;
          _searchSolutionBloc.addIntoSearchedStream(null);
        }
        return _searchedCatalogueList == null || _searchedCatalogueList.isEmpty
            ? snapShot.data is RequestInProgress &&
                    _pageIndexForSearchedCatalogues ==
                        SearchSolutionBloc.initialIndex
                ? CustomWidgets().getProgressIndicator()
                : CustomWidgets().errorWidget(
                    _failureCause ?? PlunesStrings.noSolutionsAvailable)
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
            if (_requestSuccessObject.response.isEmpty) {
              _failureCause = PlunesStrings.serviceNotAvailable;
            }
          }
          if (_requestSuccessObject.requestCode !=
                  SearchSolutionBloc.initialIndex &&
              _requestSuccessObject.response.isEmpty) {
            _endReachedForDefaultList = true;
          } else {
            _endReachedForDefaultList = false;
            Set _allItems = _defaultCatalogueList.toSet();
            _allItems.addAll(_requestSuccessObject.response);
            _defaultCatalogueList = [];
            _defaultCatalogueList = _allItems.toList(growable: true);
          }
          _pageIndexForDefaultCatalogueList++;
          _searchSolutionBloc.addIntoDefaultStream(null);
        } else if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailedObject = snapShot.data;
          _failureCause = _requestFailedObject.failureCause;
          _pageIndexForDefaultCatalogueList = SearchSolutionBloc.initialIndex;
          _searchSolutionBloc.addIntoDefaultStream(null);
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

  _onSolutionItemTap(CatalogueData catalogueData) async {
    if (!UserManager().getIsUserInServiceLocation()) {
      await showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets().fetchLocationPopUp(context);
          },
          barrierDismissible: false);
      if (!UserManager().getIsUserInServiceLocation()) {
        return;
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BiddingLoading(
                  catalogueData: catalogueData,
                )));
  }

  _onViewMoreTap(CatalogueData catalogueData) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
        catalogueData: catalogueData,
      ),
    );
  }

  _onSearch() {
    _searchStreamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    if (_searchController != null &&
        _searchController.text != null &&
        _searchController.text.trim().isNotEmpty) {
      _searchSolutionBloc.addIntoSearchedStream(RequestInProgress());
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _getSearchedCatalogueList();
      });
    } else {
      _searchedCatalogueList = [];
      _pageIndexForSearchedCatalogues = SearchSolutionBloc.initialIndex;
      _searchSolutionBloc.addIntoSearchedStream(null);
    }
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
          Future.delayed(Duration(milliseconds: 1000), () {
            _isAlreadyFetchingSearchedData = false;
          });
          _searchSolutionBloc.addIntoSearchedStream(RequestInProgress());
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
          if (_isAlreadyFetchingDefaultData == null) {
            _isAlreadyFetchingDefaultData = false;
          }
          if (_isAlreadyFetchingDefaultData) return;
          _isAlreadyFetchingDefaultData = true;
          Future.delayed(Duration(milliseconds: 1000), () {
            _isAlreadyFetchingDefaultData = false;
          });
          _searchSolutionBloc.addIntoDefaultStream(RequestInProgress());
          _getDefaultCatalogueList();
        }
        return;
      },
      child: _renderList(_defaultCatalogueList),
    );
  }

  Widget _renderList(List<CatalogueData> catalogueList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
          ..onTap = () => _onViewMoreTap(catalogueList[index]);
        return CustomWidgets().getSolutionRow(catalogueList, index,
            onButtonTap: () => _onSolutionItemTap(catalogueList[index]),
            onViewMoreTap: tapRecognizer);
      },
      shrinkWrap: true,
      itemCount: catalogueList.length,
    );
  }
}
