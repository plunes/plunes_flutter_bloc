import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';

// ignore: must_be_immutable
class MoreFacilityScreen extends BaseActivity {
  final SearchSolutionBloc searchSolutionBloc;
  final DocHosSolution docHosSolution;
  final CatalogueData catalogueData;

  MoreFacilityScreen(
      {this.searchSolutionBloc, this.docHosSolution, this.catalogueData});

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
  bool _scrollParent = false;

  _getMoreFacilities() {
    _searchSolutionBloc.getMoreFacilities(widget.docHosSolution,
        searchQuery: _searchController.text.trim().toString(),
        pageIndex: pageIndex);
  }

  @override
  void initState() {
    _scrollParent = false;
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
        _searchSolutionBloc.getMoreFacilities(widget.docHosSolution,
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
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            key: scaffoldKey,
            appBar:
                widget.getAppBar(context, PlunesStrings.moreFacilities, true),
            body: Builder(builder: (context) {
              return StreamBuilder<RequestState>(
                  stream: _searchSolutionBloc.getFacilityAdditionStream(),
                  builder: (context, snapshot) {
                    if (snapshot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    } else if (snapshot.data is RequestSuccess) {
                      Future.delayed(Duration(milliseconds: 10)).then((value) {
                        _showInSnackBar(
                            "Congrats you have unlocked ${_selectedItemList?.length} more facilities!");
                        Future.delayed(Duration(milliseconds: 1200))
                            .then((value) {
                          Navigator.pop(context, true);
                        });
                      });
                    } else if (snapshot.data is RequestFailed) {
                      RequestFailed requestFailed = snapshot.data;
                      Future.delayed(Duration(milliseconds: 10)).then((value) {
                        _showInSnackBar(requestFailed?.failureCause ??
                            plunesStrings.somethingWentWrong);
                      });
                      _searchSolutionBloc.addIntoFacilitiesA(null);
                    }
                    return _getBody();
                  });
            })));
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
          color: Colors.black12.withOpacity(0.000001),
          image: DecorationImage(
              image: ExactAssetImage(PlunesImages.userLandingImage),
              fit: BoxFit.cover)),
      child: Container(
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
                        if (_catalogues != null &&
                            _catalogues.isNotEmpty &&
                            _selectedItemList != null &&
                            _selectedItemList.isNotEmpty) {
                          _selectedItemList.forEach((selectedItem) {
                            if (_catalogues.contains(selectedItem)) {
                              _catalogues.remove(selectedItem);
                            }
                          });
                        }
                        pageIndex++;
                        _searchSolutionBloc.addIntoMoreFacilitiesStream(null);
                      } else if (snapShot.data is RequestFailed) {
                        RequestFailed _requestFailed = snapShot.data;
                        pageIndex = SearchSolutionBloc.initialIndex;
                        _failureCause = _requestFailed.failureCause;
                        _searchSolutionBloc.addIntoMoreFacilitiesStream(null);
                      }
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
            color: Colors.transparent,
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
                fontWeight: FontWeight.w600,
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
            minHeight: AppConfig.verticalBlockSize * 25,
            minWidth: double.infinity,
            maxWidth: double.infinity,
            maxHeight: AppConfig.verticalBlockSize * 75),
        child: Column(
          children: <Widget>[
            StreamBuilder<Object>(
                stream: _selectUnselectController.stream,
                builder: (context, snapshot) {
                  return Container(
                    padding: const EdgeInsets.all(5.0),
                    margin: EdgeInsets.only(
                        top: (_selectedItemList == null ||
                                _selectedItemList.isEmpty)
                            ? AppConfig.verticalBlockSize * 1.5
                            : 0),
                    child: Text(
                      PlunesStrings.chooseFacilities,
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  );
                }),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollState) {
                  if (scrollState is ScrollEndNotification &&
                      scrollState.metrics.extentAfter == 0 &&
                      !_endReached) {
                    _searchSolutionBloc
                        .addIntoMoreFacilitiesStream(RequestInProgress());
                    _searchSolutionBloc.getMoreFacilities(widget.docHosSolution,
                        searchQuery: _searchController.text.trim().toString(),
                        pageIndex: pageIndex);
                  } else if (scrollState is OverscrollNotification) {
                    _scrollParent = true;
                    _setState();
                    Future.delayed(Duration(seconds: 1)).then((value) {
                      _scrollParent = false;
                      _setState();
                    });
                  }
                  return;
                },
                child: IgnorePointer(
                  ignoring: _scrollParent,
                  child: ListView.builder(
                    padding: null,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                            bottom: (_catalogues != null &&
                                    _catalogues.isNotEmpty &&
                                    (index == _catalogues.length - 1))
                                ? AppConfig.verticalBlockSize * 4
                                : 0),
                        child: CustomWidgets().getMoreFacilityWidget(
                            _catalogues, index,
                            onTap: () => _addRemoveFacilities(
                                _catalogues[index],
                                shouldAdd: true),
                            onProfileTap: () =>
                                _viewProfile(_catalogues[index])),
                      );
                    },
                    shrinkWrap: true,
                    itemCount: _catalogues?.length ?? 0,
                  ),
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

  _addRemoveFacilities(MoreFacility facility, {bool shouldAdd = false}) {
    if (shouldAdd &&
        _selectedItemList != null &&
        _selectedItemList.length >= 5) {
      _showInSnackBar("Can't select more than 5 facilities");
      return;
    }
//    if (_selectedItemList.contains(facility) && shouldAdd) {
//      _showInSnackBar("Facility already selected");
//      return;
//    }
    if (_selectedItemList.contains(facility)) {
      _selectedItemList.remove(facility);
      if (_catalogues != null &&
          _catalogues.isNotEmpty &&
          _searchController.text.trim().isEmpty) {
        _catalogues.insert(0, facility);
      }
    } else {
      _selectedItemList.add(facility);
      _catalogues.remove(facility);
    }
    _selectUnselectController.add(null);
    _searchSolutionBloc.addIntoMoreFacilitiesStream(null);
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
                            _addRemoveFacilities(_selectedItemList[index]),
                        onProfileTap: () =>
                            _viewProfile(_selectedItemList[index]));
                  },
                  shrinkWrap: true,
                  itemCount: _selectedItemList?.length ?? 0,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 25),
                child: InkWell(
                  onTap: () {
                    _searchSolutionBloc.addFacilitiesInSolution(
                        widget.docHosSolution, _selectedItemList);
                    return;
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: CustomWidgets().getRoundedButton(
                      PlunesStrings.negotiate,
                      AppConfig.horizontalBlockSize * 5,
                      PlunesColors.GREENCOLOR,
                      AppConfig.horizontalBlockSize * 5,
                      AppConfig.verticalBlockSize * 1.2,
                      PlunesColors.WHITECOLOR,
                      hasBorder: false,
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void _showInSnackBar(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }

  _viewProfile(MoreFacility service) {
    if (service.userType != null && service.professionalId != null) {
      Widget route;
      if (service.userType.toLowerCase() ==
          Constants.doctor.toString().toLowerCase()) {
        route = DocProfile(userId: service.professionalId);
      } else {
        route = HospitalProfile(userID: service.professionalId);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }
}
