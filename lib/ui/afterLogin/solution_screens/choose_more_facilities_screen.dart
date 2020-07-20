import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class MoreFacilityScreen extends BaseActivity {
  final SearchSolutionBloc searchSolutionBloc;
  final CatalogueData catalogueData;

  MoreFacilityScreen({this.searchSolutionBloc, this.catalogueData});

  @override
  _MoreFacilityScreenState createState() => _MoreFacilityScreenState();
}

class _MoreFacilityScreenState extends BaseState<MoreFacilityScreen> {
  TextEditingController _searchController;
  SearchSolutionBloc _searchSolutionBloc;
  StreamController _streamController, _selectUnselectController;
  Timer _debounce;
  int pageIndex = SearchSolutionBloc.initialIndex;
  List<MoreFacility> _catalogues, _selectedItemList;
  bool _endReached;
  String _failureCause;

  _getMoreFacilities() {
    _searchSolutionBloc.getMoreFacilities(widget.catalogueData,
        searchQuery: _searchController.text.trim().toString(),
        pageIndex: pageIndex);
  }

  @override
  void initState() {
    _searchSolutionBloc = widget.searchSolutionBloc;
    _searchController = TextEditingController()..addListener(_onSearch);
    _streamController = StreamController.broadcast();
    _selectUnselectController = StreamController.broadcast();
    _catalogues = [];
    _selectedItemList = [];
    _endReached = false;
    _getMoreFacilities();
    super.initState();
  }

  _onSearch() {
    _streamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController != null &&
          _searchController.text != null &&
          _searchController.text.trim().isNotEmpty) {
        _searchSolutionBloc.addIntoMoreFacilitiesStream(RequestInProgress());
        _searchSolutionBloc.getMoreFacilities(widget.catalogueData,
            searchQuery: _searchController.text.trim().toString(),
            pageIndex: 0);
      } else {
        _onTextClear();
      }
    });
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearch);
    _searchController?.dispose();
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar:
                widget.getAppBar(context, PlunesStrings.moreFacilities, true),
            body: Builder(builder: (context) {
              return _getBody();
            })));
  }

  Widget _getBody() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: ExactAssetImage(PlunesImages.moreFacilityBgImage),
              fit: BoxFit.fill,
              alignment: Alignment.center)),
      child: Container(
        color: PlunesColors.WHITECOLOR.withOpacity(0.5),
        margin:
            EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 5),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              children: <Widget>[
                _getUpperImageAndText(),
                StreamBuilder<Object>(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      return _getSearchBar();
                    }),
                _getSelectedItems(),
                StreamBuilder<RequestState>(
                    stream: _searchSolutionBloc.getMoreFacilitiesStream(),
                    initialData: (_catalogues == null || _catalogues.isEmpty)
                        ? RequestInProgress()
                        : null,
                    builder: (context, snapShot) {
                      if (snapShot.data is RequestSuccess) {
                        RequestSuccess _requestSuccessObject = snapShot.data;
                        if (_requestSuccessObject.requestCode ==
                            SearchSolutionBloc.initialIndex) {
                          pageIndex = SearchSolutionBloc.initialIndex;
                          _catalogues = [];
                        }
                        if (_requestSuccessObject.requestCode !=
                                SearchSolutionBloc.initialIndex &&
                            _requestSuccessObject.response.isEmpty) {
                          _endReached = true;
                        } else {
                          _endReached = false;
                          Set _allItems = _catalogues.toSet();
                          _allItems.addAll(_requestSuccessObject.response);
                          _catalogues = _allItems.toList(growable: true);
                        }
                        pageIndex++;
                      } else if (snapShot.data is RequestFailed) {
                        RequestFailed _requestFailed = snapShot.data;
                        pageIndex = SearchSolutionBloc.initialIndex;
                        _failureCause = _requestFailed.failureCause;
                      }
                      print(
                          "$pageIndex _catalogues_catalogues_catalogues ${_catalogues?.length}");
                      return (_catalogues == null || _catalogues.isEmpty)
                          ? _getDefaultWidget(snapShot)
                          : _showResultsFromBackend(snapShot);
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getUpperImageAndText() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
            color: PlunesColors.WHITECOLOR,
            height: AppConfig.horizontalBlockSize * 14,
            width: AppConfig.horizontalBlockSize * 14,
            child: (widget.catalogueData == null ||
                    widget.catalogueData.speciality == null ||
                    widget.catalogueData.speciality.isEmpty)
                ? Image.asset(PlunesImages.basicImage, fit: BoxFit.contain)
                : CustomWidgets().getImageFromUrl(
                    "https://specialities.s3.ap-south-1.amazonaws.com/${widget.catalogueData.speciality}.png",
                    boxFit: BoxFit.contain),
          ),
          Padding(padding: EdgeInsets.only(top: 3)),
          Text(
            PlunesStrings.congrats,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Padding(padding: EdgeInsets.only(top: 3)),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 10),
            child: Text(
              PlunesStrings.negotiateWithFiveMore,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return CustomWidgets().searchBar(
        searchController: _searchController,
        hintText: PlunesStrings.searchFacilities,
        onTextClear: () => _onTextClear());
  }

  Widget _showResultsFromBackend(AsyncSnapshot<RequestState> snapShot) {
    return Container(
        constraints: BoxConstraints(
            minHeight: AppConfig.verticalBlockSize * 30,
            minWidth: double.infinity,
            maxWidth: double.infinity,
            maxHeight: AppConfig.verticalBlockSize * 65),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                PlunesStrings.chooseFacilities,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollState) {
                  print("listning");
                  if (scrollState is ScrollEndNotification &&
                      scrollState.metrics.extentAfter == 0 &&
                      !_endReached) {
                    _searchSolutionBloc
                        .addIntoMoreFacilitiesStream(RequestInProgress());
                    _searchSolutionBloc.getMoreFacilities(widget.catalogueData,
                        searchQuery: _searchController.text.trim().toString(),
                        pageIndex: pageIndex);
                  }
                  return;
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return CustomWidgets().getMoreFacilityWidget(
                        _catalogues, index,
                        onTap: () => _addRemoveFacilities(_catalogues[index]));
                  },
                  shrinkWrap: true,
                  itemCount: _catalogues?.length ?? 0,
                ),
              ),
            ),
            (snapShot.data is RequestInProgress &&
                    (_catalogues != null && _catalogues.isNotEmpty))
                ? CustomWidgets().getProgressIndicator()
                : Container()
          ],
        ));
  }

  Widget _getDefaultWidget(AsyncSnapshot<RequestState> snapShot) {
    return Container(
      constraints: BoxConstraints(
          minHeight: AppConfig.verticalBlockSize * 30,
          minWidth: double.infinity,
          maxWidth: double.infinity,
          maxHeight: AppConfig.verticalBlockSize * 65),
      child: Column(
        children: <Widget>[
          (snapShot.data is RequestInProgress &&
                  (_catalogues == null || _catalogues.isEmpty))
              ? Expanded(
                  child: CustomWidgets().getProgressIndicator(),
                )
              : Expanded(
                  child: CustomWidgets()
                      .errorWidget(_failureCause ?? "Facilities not available"))
        ],
      ),
    );
  }

  _onTextClear() {
    _catalogues = [];
    pageIndex = SearchSolutionBloc.initialIndex;
    _getMoreFacilities();
  }

  _addRemoveFacilities(MoreFacility facility) {
    if (_selectedItemList.contains(facility)) {
      _selectedItemList.remove(facility);
    } else {
      _selectedItemList.add(facility);
    }
    _selectUnselectController.add(null);
  }

  Widget _getSelectedItems() {
    return StreamBuilder<Object>(
        stream: _selectUnselectController.stream,
        builder: (context, snapshot) {
          if (_selectedItemList == null || _selectedItemList.isEmpty) {
            return Container();
          }
          return Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    minHeight: AppConfig.verticalBlockSize * 5,
                    minWidth: double.infinity,
                    maxWidth: double.infinity,
                    maxHeight: AppConfig.verticalBlockSize * 100),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CustomWidgets().getMoreFacilityWidget(
                        _selectedItemList, index,
                        isSelected: true,
                        onTap: () =>
                            _addRemoveFacilities(_selectedItemList[index]));
                  },
                  shrinkWrap: true,
                  itemCount: _selectedItemList?.length ?? 0,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 25),
                child: CustomWidgets().getRoundedButton(
                  PlunesStrings.negotiate,
                  AppConfig.horizontalBlockSize * 5,
                  PlunesColors.GREENCOLOR,
                  AppConfig.horizontalBlockSize * 5,
                  AppConfig.verticalBlockSize * 1.3,
                  PlunesColors.WHITECOLOR,
                  hasBorder: true,
                ),
              )
            ],
          );
        });
  }
}
