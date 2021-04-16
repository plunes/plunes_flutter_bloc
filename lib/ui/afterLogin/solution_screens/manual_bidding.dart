import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/enter_procedure_detail_screen.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

// ignore: must_be_immutable
class ManualBidding extends BaseActivity {
  @override
  _ManualBiddingState createState() => _ManualBiddingState();
}

class _ManualBiddingState extends BaseState<ManualBidding> {
  TextEditingController _textEditingController, _searchController;
  List<MoreFacility> _catalogues, _selectedItemList;
  StreamController _streamController,
      _selectUnselectController,
      _queryStreamController;
  int pageIndex = SearchSolutionBloc.initialIndex;
  bool _endReached, _isProcessing;
  String _failureCause, _specialityFailureCause;
  SearchSolutionBloc _searchSolutionBloc;
  Timer _debounce;
  LatLng _selectedLoc;
  String _location = PlunesStrings.enterYourLocation;
  User _userObj;
  UserBloc _userBloc;
  String _specialitySelectedId;
  bool _scrollParent = false;
  ScrollController _scrollController;
  List<SpecialityModel> _specialityItems = [];

  String _selectedSpeciality;

  String _selectedSpecialityName;

  @override
  void initState() {
    _scrollController = ScrollController();
    _isProcessing = false;
    _scrollParent = false;
    _userObj = UserManager().getUserDetails();
    _userBloc = UserBloc();
    if (CommonMethods.catalogueLists == null ||
        CommonMethods.catalogueLists.isEmpty) {
      _isProcessing = true;
      _getSpecialities();
    }
    _getRegion();
    _searchSolutionBloc = SearchSolutionBloc();
    _catalogues = [];
    _selectedItemList = [];
    _searchController = TextEditingController()..addListener(_onSearch);
    _textEditingController = TextEditingController();
    _streamController = StreamController.broadcast();
    _queryStreamController = StreamController.broadcast();
    _selectUnselectController = StreamController.broadcast();
    _endReached = false;
    _getMoreFacilities();
    super.initState();
  }

  _getMoreFacilities() {
    _failureCause = null;
    _searchSolutionBloc.getFacilitiesForManualBidding(
        searchQuery: _searchController.text.trim().toString(),
        pageIndex: pageIndex,
        latLng: _selectedLoc,
        specialityId: _specialitySelectedId);
  }

  void _getSpecialities() async {
    if (!_isProcessing) {
      _isProcessing = true;
      _setState();
    }
    var result = await _userBloc.getSpeciality();
    if (result is RequestSuccess) {
      if (CommonMethods.catalogueLists == null ||
          CommonMethods.catalogueLists.isEmpty) {
        _specialityFailureCause = "No Data Available";
      }
    } else if (result is RequestFailed) {
      _specialityFailureCause = result.failureCause;
    }
    _isProcessing = false;
    _setState();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _searchController?.dispose();
    _streamController?.close();
    _queryStreamController?.close();
    _searchSolutionBloc?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        // appBar:
        //     widget.getAppBar(context, PlunesStrings.negotiateManually, true),
        body: Builder(builder: (context) {
          if (_isProcessing) {
            return CustomWidgets().getProgressIndicator();
          } else if (_specialityFailureCause != null &&
              _specialityFailureCause.isNotEmpty) {
            return CustomWidgets().errorWidget(_specialityFailureCause,
                onTap: () => _getSpecialities());
          }
          return _latestWidgetBody();
          // return _getBody();
        }),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget _getBody() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black12.withOpacity(0.000001),
          image: DecorationImage(
              image: ExactAssetImage(PlunesImages.userLandingImage),
              fit: BoxFit.cover)),
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 4),
        child: Stack(
          children: <Widget>[
            Scrollbar(
              isAlwaysShown: false,
              controller: _scrollController,
              child: ListView(
                shrinkWrap: true,
                controller: _scrollController,
                children: <Widget>[
                  _getLocationField(),
//                  Container(
//                    margin: EdgeInsets.only(
//                      left: AppConfig.verticalBlockSize * 3,
//                      right: AppConfig.verticalBlockSize * 3,
//                      bottom: AppConfig.verticalBlockSize * 2.5,
//                    ),
//                    child: Center(
//                      child: Text(
//                        PlunesStrings.enterTheSpecialityRelatedText,
//                        textAlign: TextAlign.center,
//                        style: TextStyle(
//                            color: PlunesColors.BLACKCOLOR,
//                            fontWeight: FontWeight.normal,
//                            fontSize: 18),
//                      ),
//                    ),
//                  ),
                  StreamBuilder<Object>(
                      stream: _searchSolutionBloc.getManualBiddingStream(),
                      builder: (context, snapshot) {
                        return _getSpecialityDropDown();
                      }),
//                  Padding(
//                    padding:
//                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
//                    child: _getGreenDash(),
//                  ),
//                  _getTextFiledWidget(),
//                  Padding(
//                    padding: EdgeInsets.symmetric(
//                        vertical: AppConfig.verticalBlockSize * 2),
//                    child: _getGreenDash(),
//                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 3.5),
                    child: _getGreenDash(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
//                      top: AppConfig.verticalBlockSize * 3.5,
                      left: AppConfig.verticalBlockSize * 3,
                      right: AppConfig.verticalBlockSize * 3,
                      bottom: AppConfig.verticalBlockSize * 1.5,
                    ),
                    child: Center(
                      child: Text(
                        PlunesStrings.selectTheFacilities,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.normal,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  StreamBuilder<Object>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        return _getSearchBar();
                      }),
                  _getSelectedItems(),
                  StreamBuilder<RequestState>(
                      stream: _searchSolutionBloc.getManualBiddingStream(),
                      initialData: (_catalogues == null || _catalogues.isEmpty)
                          ? RequestInProgress()
                          : null,
                      builder: (context, snapShot) {
                        if (snapShot.data is RequestSuccess) {
                          RequestSuccess _requestSuccessObject = snapShot.data;
                          if (_requestSuccessObject.requestCode ==
                              SearchSolutionBloc.initialIndex) {
                            if (_searchController.text.trim().isEmpty) {
                              pageIndex = SearchSolutionBloc.initialIndex;
                              _catalogues = [];
                            } else {
                              if (_searchController.text.trim().isNotEmpty &&
                                  _requestSuccessObject.additionalData !=
                                      null &&
                                  _requestSuccessObject.additionalData
                                      .toString()
                                      .trim()
                                      .isNotEmpty) {
                                pageIndex = SearchSolutionBloc.initialIndex;
                                _catalogues = [];
                              }
                            }
                          }
                          if (_requestSuccessObject.requestCode !=
                                  SearchSolutionBloc.initialIndex &&
                              _requestSuccessObject.response.isEmpty) {
                            _endReached = true;
                          } else {
                            _endReached = false;
                            if (_searchController.text.trim().isEmpty) {
                              Set _allItems = _catalogues.toSet();
                              _allItems.addAll(_requestSuccessObject.response);
                              _catalogues = _allItems.toList(growable: true);
                            } else {
                              if (_searchController.text.trim().isNotEmpty &&
                                  _requestSuccessObject.additionalData !=
                                      null &&
                                  _requestSuccessObject.additionalData
                                      .toString()
                                      .trim()
                                      .isNotEmpty) {
                                Set _allItems = _catalogues.toSet();
                                _allItems
                                    .addAll(_requestSuccessObject.response);
                                _catalogues = _allItems.toList(growable: true);
                              }
                            }
                          }
                          _selectedItemList.forEach((selectedItem) {
                            if (_catalogues.contains(selectedItem)) {
                              _catalogues.remove(selectedItem);
                            }
                          });
                          pageIndex++;
                          _searchSolutionBloc
                              .addStateInManualBiddingStream(null);
                        } else if (snapShot.data is RequestFailed) {
                          RequestFailed _requestFailed = snapShot.data;
                          pageIndex = SearchSolutionBloc.initialIndex;
                          _failureCause = _requestFailed.failureCause;
                          _searchSolutionBloc
                              .addStateInManualBiddingStream(null);
                        }
                        return (_catalogues == null || _catalogues.isEmpty)
                            ? _getDefaultWidget(snapShot)
                            : _showResultsFromBackend(snapShot);
                      }),
                ],
              ),
            ),
            Positioned(
              child: _getSubmitButton(),
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
            )
          ],
        ),
      ),
    );
  }

  Widget _getTextFiledWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Flexible(
                    child: TextField(
                  controller: _textEditingController,
                  onChanged: (data) {
                    _queryStreamController.add(null);
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: PlunesColors.BLACKCOLOR),
                  decoration: InputDecoration(
                      counterText: "",
                      hintText: PlunesStrings.enterProcedureAndTestDetails,
                      hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: PlunesColors.BLACKCOLOR)),
                  maxLines: null,
                  maxLength: 400,
                ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
            child: Center(
              child: Text(
                PlunesStrings.makeSureTheDetailsText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return searchBar(
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
        margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 0.5),
        child: Column(
          children: <Widget>[
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollState) {
                  if (scrollState is ScrollEndNotification &&
                      scrollState.metrics.extentAfter == 0 &&
                      !_endReached) {
                    _getMoreFacilities();
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
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                            bottom: (_catalogues != null &&
                                    _catalogues.isNotEmpty &&
                                    (index == _catalogues.length - 1))
                                ? AppConfig.verticalBlockSize * 16
                                : 0),
                        child: getMoreFacilityWidget(_catalogues, index,
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

  _onTextClear() {
    _catalogues = [];
    pageIndex = SearchSolutionBloc.initialIndex;
    _getMoreFacilities();
  }

  _viewProfile(MoreFacility service) {
    if (service.userType != null && service.professionalId != null) {
      // Widget route;
      // if (service.userType.toLowerCase() ==
      //     Constants.doctor.toString().toLowerCase()) {
      //   route = DocProfile(userId: service.professionalId);
      // } else {
      //   route = HospitalProfile(userID: service.professionalId);
      // }
      // Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorInfo(service.professionalId,
                  isDoc: (service.userType.toLowerCase() ==
                      Constants.doctor.toString().toLowerCase()))));
    }
  }

  _addRemoveFacilities(MoreFacility facility, {bool shouldAdd = false}) {
    if (shouldAdd &&
        _selectedItemList != null &&
        _selectedItemList.length >= 5) {
      _showInSnackBar("Can't select more than 5 facilities");
      return;
    }
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
    if (_catalogues == null || _catalogues.isEmpty) {
      _failureCause = PlunesStrings.emptyStr;
    }
    _selectUnselectController.add(null);
    _searchSolutionBloc.addStateInManualBiddingStream(null);
  }

  void _showInSnackBar(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets()
              .getInformativePopup(globalKey: scaffoldKey, message: message);
        });
//    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }

  Widget _getDefaultWidget(AsyncSnapshot<RequestState> snapShot) {
    return Container(
      constraints: BoxConstraints(
          minHeight: AppConfig.verticalBlockSize * 30,
          minWidth: double.infinity,
          maxWidth: double.infinity,
          maxHeight: AppConfig.verticalBlockSize * 55),
      child: Column(
        children: <Widget>[
          (snapShot.data is RequestInProgress &&
                  (_catalogues == null || _catalogues.isEmpty))
              ? Expanded(child: CustomWidgets().getProgressIndicator())
              : Expanded(
                  child: CustomWidgets().errorWidget(
                      (_failureCause == null || _failureCause.isEmpty)
                          ? (_specialitySelectedId != null)
                              ? PlunesStrings.afterFacilitySelectedText
                              : PlunesStrings.facilityNotAvailableMessage
                          : _failureCause,
                      onTap: (_failureCause != null &&
                              _failureCause == PlunesStrings.noInternet)
                          ? () => _getMoreFacilities()
                          : null,
                      shouldNotShowImage: !(_failureCause != null &&
                          _failureCause == PlunesStrings.noInternet)))
        ],
      ),
    );
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
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 0.5),
                constraints: BoxConstraints(
                    minHeight: AppConfig.verticalBlockSize * 5,
                    minWidth: double.infinity,
                    maxWidth: double.infinity,
                    maxHeight: AppConfig.verticalBlockSize * 100),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return getMoreFacilityWidget(_selectedItemList, index,
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
            ],
          );
        });
  }

  _onSearch() {
    _streamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController != null &&
          _searchController.text != null &&
          _searchController.text.trim().isNotEmpty) {
        _catalogues = [];
        _failureCause = null;
        _searchSolutionBloc.getFacilitiesForManualBidding(
            searchQuery: _searchController.text.trim().toString(),
            pageIndex: SearchSolutionBloc.initialIndex,
            latLng: _selectedLoc,
            specialityId: _specialitySelectedId);
      } else {
        _onTextClear();
      }
    });
  }

  Widget _getSubmitButton() {
    return InkWell(
      onTap: () {
        if (_selectedItemList == null || _selectedItemList.isEmpty) {
          _showInSnackBar(PlunesStrings.selectFacilityToReceiveBid);
          return;
        }
//        showDialog(
//                context: context,
//                builder: (context) {
//                  return CustomWidgets().getManualBiddingEnterDetailsPopup(
//                      scaffoldKey, _searchSolutionBloc, _selectedItemList);
//                },
//                barrierDismissible: true)
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EnterProcedureDetailScreen(
                      searchSolutionBloc: _searchSolutionBloc,
                      selectedItemList: _selectedItemList,
                    ))).then((value) {
          if (value != null && value) {
            Navigator.pop(context);
          }
        });
        return;
      },
      child: Container(
        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            PlunesStrings.continueText,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: PlunesColors.SPARKLINGGREEN,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
//    return StreamBuilder<Object>(
//        stream: _queryStreamController.stream,
//        builder: (context, snapshot) {
//          return Container(
//            child: StreamBuilder<Object>(
//                stream: _selectUnselectController.stream,
//                builder: (context, snapshot) {
//                  if (_textEditingController != null &&
//                      _textEditingController.text.trim().isNotEmpty &&
//                      _selectedItemList != null &&
//                      _selectedItemList.isNotEmpty) {
//                    return InkWell(
//                      onTap: () {
//                        _searchSolutionBloc.saveManualBiddingData(
//                            _textEditingController.text.trim(),
//                            _selectedItemList);
//                        return;
//                      },
//                      child: Container(
//                        color:
//                            Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//                        padding: EdgeInsets.all(10),
//                        child: Center(
//                          child: Text(
//                            plunesStrings.submit,
//                            textAlign: TextAlign.center,
//                            style: TextStyle(
//                                color: PlunesColors.SPARKLINGGREEN,
//                                fontSize: 16,
//                                fontWeight: FontWeight.normal),
//                          ),
//                        ),
//                      ),
//                    );
//                  }
//                  return Container();
//                }),
//          );
//        });
  }

  _getLocation() {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LocationFetch(shouldSaveLocation: false)))
        .then((val) {
      if (val != null) {
        var addressControllerList = new List();
        addressControllerList = val.toString().split(":");
        String addr = addressControllerList[0] +
            ' ' +
            addressControllerList[1] +
            ' ' +
            addressControllerList[2];
//                          print("addr is $addr");
        var _latitude = addressControllerList[3];
        var _longitude = addressControllerList[4];
        String region = addr;
        if (addressControllerList.length == 6 &&
            addressControllerList[5] != null) {
          region = addressControllerList[5];
        }
        _location = region;
        _setState();
        _selectedLoc =
            LatLng(double.tryParse(_latitude), double.tryParse(_longitude));
//        print("_latitude $_latitude");
//        print("_longitude $_longitude");
        pageIndex = SearchSolutionBloc.initialIndex;
        _catalogues = [];
        _getMoreFacilities();
      }
    });
  }

  _getAppBar() {
    return PreferredSize(
        child: Card(
            color: Colors.white,
            elevation: 3.0,
            margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(AppConfig.verticalBlockSize * 0.5),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                        return;
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: PlunesColors.BLACKCOLOR,
                      ),
                    )),
                Text(
                  PlunesStrings.negotiateManually,
                  textAlign: TextAlign.start,
                  style:
                      TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
                ),
                Flexible(
                  child: InkWell(
                    onTap: () => _getLocation(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 2.0, right: 3.0, top: 2.0, bottom: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(2),
                            child: Image.asset(plunesImages.locationIcon),
                            height: AppConfig.verticalBlockSize * 3.5,
                            width: AppConfig.horizontalBlockSize * 6,
                          ),
                          Flexible(
                              child: FittedBox(
                            child: Text(
                              _location ?? PlunesStrings.enterYourLocation,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                                decorationThickness: 2.0,
                              ),
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
        preferredSize: Size(double.infinity, AppConfig.verticalBlockSize * 10));
  }

  _setState() {
    if (mounted) setState(() {});
  }

  void _getRegion() {
    if (_userObj.latitude == null ||
        _userObj.longitude == null ||
        _userObj.latitude.isEmpty ||
        _userObj.longitude.isEmpty ||
        _userObj.latitude == '0.0' ||
        _userObj.longitude == '0.0') {
      _location = PlunesStrings.enterYourLocation;
      _setState();
    } else {
      LocationUtil()
          .getAddressFromLatLong(_userObj.latitude, _userObj.longitude)
          .then((value) {
        _location = value;
        _setState();
      });
    }
  }

  Widget _getSpecialityDropDown() {
    List<DropdownMenuItem<String>> itemList = [];
    CommonMethods.catalogueLists.toSet().forEach((item) {
      if (item != null && item.id != null && item.id.isNotEmpty) {
        itemList.add(DropdownMenuItem(
            value: item?.speciality ?? PlunesStrings.NA,
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                item?.speciality ?? PlunesStrings.NA,
                textAlign: TextAlign.center,
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
              ),
            )));
      }
    });
    return itemList == null || itemList.isEmpty
        ? Container()
        : SearchableDropdown.single(
            onChanged: (value) {
//              print("value hai $value");
              CommonMethods.catalogueLists.toSet().forEach((item) {
                if (item != null &&
                    item.id != null &&
                    item.id.isNotEmpty &&
                    value != null &&
                    value.toString().isNotEmpty &&
                    item.speciality != null &&
                    item.speciality.isNotEmpty &&
                    value.toString() == item.speciality) {
                  _specialitySelectedId = item.id;
                  _catalogues = [];
                  pageIndex = SearchSolutionBloc.initialIndex;
                  _getMoreFacilities();
                }
              });
            },
            isExpanded: true,
            isCaseSensitiveSearch: false,
            onClear: () {
              _specialitySelectedId = null;
              _catalogues = [];
              pageIndex = SearchSolutionBloc.initialIndex;
              _getMoreFacilities();
            },
            hint: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.close,
                    color: Colors.transparent,
                  ),
                  Text(
                    PlunesStrings.specialities,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(CommonMethods.getColorHexFromStr("#5D5D5D")),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            selectedValueWidgetFn: (item) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.only(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ),
                    Expanded(
                      child: Text(
                        item,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
            items: itemList,
          );
  }

//  Widget _getSpecialityDropDown() {
//    List<DropdownMenuItem<String>> itemList = [];
//    CommonMethods.catalogueLists.toSet().forEach((item) {
//      if (item != null && item.id != null && item.id.isNotEmpty) {
//        itemList.add(DropdownMenuItem(
//            value: item.id,
//            child: Container(
//              alignment: Alignment.center,
//              child: Text(
//                CommonMethods.getStringInCamelCase(item?.speciality) ??
//                    PlunesStrings.NA,
//                textAlign: TextAlign.center,
//                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
//              ),
//            )));
//      }
//    });
//    Widget dropDown;
//    if (itemList != null && itemList.isNotEmpty) {
//      dropDown = DropdownButton<String>(
//        isDense: true,
//        onChanged: (itemId) {
//          _specialitySelectedId = itemId;
//          _catalogues = [];
//          pageIndex = SearchSolutionBloc.initialIndex;
//          _getMoreFacilities();
//        },
//        value: _specialitySelectedId,
//        hint: Container(
//          alignment: Alignment.center,
//          child: Text(
//            PlunesStrings.specialities,
//            textAlign: TextAlign.center,
//            style: TextStyle(
//              color: Color(CommonMethods.getColorHexFromStr("#5D5D5D")),
//              fontSize: 16,
//              fontWeight: FontWeight.normal,
//            ),
//          ),
//        ),
//        items: itemList,
//        underline: Container(),
//        isExpanded: true,
//        elevation: 0,
//      );
//    }
//    return itemList == null || itemList.isEmpty
//        ? Container()
//        : Column(
//            children: <Widget>[
//              Container(
//                  padding: EdgeInsets.only(
//                      left: AppConfig.horizontalBlockSize * 4,
//                      right: AppConfig.horizontalBlockSize * 4),
//                  child:
//                      dropDown //DropdownButtonHideUnderline(child: dropDown),
//                  ),
//              Container(
//                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 0.6),
//                width: double.infinity,
//                color: PlunesColors.GREYCOLOR,
//                height: 0.8,
//              ),
//            ],
//          );
//  }

  Widget _getLocationField() {
    return Flexible(
      child: Container(
        // margin: EdgeInsets.symmetric(
        //     horizontal: AppConfig.verticalBlockSize * 2,
        //     vertical: AppConfig.horizontalBlockSize * 1.5),
        child: InkWell(
          onTap: () => _getLocation(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(2),
                child: Image.asset(plunesImages.locationIcon),
                height: AppConfig.verticalBlockSize * 3.5,
                width: AppConfig.horizontalBlockSize * 6,
              ),
              Flexible(
                  child: FittedBox(
                child: Text(
                  _location ?? PlunesStrings.enterYourLocation,
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 14,
                      color:
                          Color(CommonMethods.getColorHexFromStr("#4F4F4F"))),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _getGreenDash() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 40),
      height: AppConfig.verticalBlockSize * 0.45,
      color: Color(CommonMethods.getColorHexFromStr("#20D86E")),
    );
  }

  Widget searchBar(
      {@required final TextEditingController searchController,
      @required final String hintText,
      bool hasFocus = false,
      isRounded = true,
      FocusNode focusNode,
      double searchBarHeight = 6,
      Function onTextClear}) {
    return StatefulBuilder(builder: (context, newState) {
      return Column(
        children: <Widget>[
          Container(
            height: AppConfig.verticalBlockSize * searchBarHeight,
            padding: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 4,
                right: AppConfig.horizontalBlockSize * 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    autofocus: hasFocus,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: PlunesColors.BLACKCOLOR),
                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                    decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: hintText,
                        hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#5D5D5D")))),
                  ),
                ),
                searchController.text.trim().isEmpty
                    ? Image.asset(
                        PlunesImages.searchIcon,
                        color: PlunesColors.BLACKCOLOR,
                        width: AppConfig.verticalBlockSize * 2.5,
                        height: AppConfig.verticalBlockSize * 2.2,
                      )
                    : InkWell(
                        onTap: () {
                          searchController.text = "";
                          newState(() {});
                          if (onTextClear != null) {
                            onTextClear();
                          }
                        },
                        child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.clear,
                              color: Colors.green,
                            )),
                      )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: PlunesColors.GREYCOLOR,
            height: 0.8,
          ),
        ],
      );
    });
  }

  Widget _latestWidgetBody() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          Container(
            child: Column(
              children: [
                _getHeaderWidgets(),
                Expanded(
                    child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 4),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _getSelectedItems(),
                        _getUnselectedFacilities(),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          ),
          Positioned(
            child: _getSubmitButton(),
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
          )
        ],
      ),
    );
  }

  Widget _getHeaderWidgets() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2.5,
      child: Container(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.zero,
              elevation: 0.6,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 1.2,
                    horizontal: AppConfig.horizontalBlockSize * 4),
                child: Row(
                  children: [
                    Container(
                        child: IconButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                        return;
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: PlunesColors.BLACKCOLOR,
                      ),
                    )),
                    Expanded(
                        flex: 2,
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              PlunesStrings.negotiateManually,
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ))),
                    _getLocationField()
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 4),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      "Select the facilities that you want to discover",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 12),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _getModelBottomSheetForServiceList(context);
                          },
                          onDoubleTap: () {},
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Container(
                            padding: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1.2,
                                bottom: AppConfig.verticalBlockSize * 1.2,
                                left: AppConfig.horizontalBlockSize * 5,
                                right: AppConfig.horizontalBlockSize * 1),
                            margin: EdgeInsets.only(
                                right: AppConfig.horizontalBlockSize * 1.5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    AppConfig.horizontalBlockSize * 10)),
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#FFFFFF")),
                                border: Border.all(
                                    width: 0.8,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#E7E7E7")))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                StreamBuilder<Object>(
                                    stream: _searchSolutionBloc
                                        .getManualBiddingStream(),
                                    builder: (context, snapshot) {
                                      return Text(
                                        _getSpecialityName(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr(
                                                    "#717171"))),
                                      );
                                    }),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.arrow_drop_down),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            child: StreamBuilder<Object>(
                                stream: _streamController.stream,
                                builder: (context, snapshot) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#FFFFFF")),
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 0.5,
                                        bottom:
                                            AppConfig.verticalBlockSize * 0.5),
                                    child: Container(child: StatefulBuilder(
                                        builder: (context, newState) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: AppConfig
                                                        .horizontalBlockSize *
                                                    4),
                                            child: Icon(
                                              Icons.search,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#B1B1B1")),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _searchController,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: PlunesColors
                                                            .BLACKCOLOR),
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                          40)
                                                    ],
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            "Search facility",
                                                        hintStyle: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            color: Color(CommonMethods
                                                                .getColorHexFromStr(
                                                                    "#717171")))),
                                                  ),
                                                ),
                                                _searchController.text
                                                        .trim()
                                                        .isEmpty
                                                    ? Container()
                                                    : InkWell(
                                                        onTap: () {
                                                          _searchController
                                                              .text = "";
                                                          newState(() {});
                                                          _onTextClear();
                                                        },
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    2.0),
                                                            child: Icon(
                                                              Icons.clear,
                                                              color:
                                                                  Colors.green,
                                                            )),
                                                      )
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    })),
                                  );
                                }),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getUnselectedFacilities() {
    return StreamBuilder<RequestState>(
        stream: _searchSolutionBloc.getManualBiddingStream(),
        initialData: (_catalogues == null || _catalogues.isEmpty)
            ? RequestInProgress()
            : null,
        builder: (context, snapShot) {
          if (snapShot.data is RequestSuccess) {
            RequestSuccess _requestSuccessObject = snapShot.data;
            if (_requestSuccessObject.requestCode ==
                SearchSolutionBloc.initialIndex) {
              if (_searchController.text.trim().isEmpty) {
                pageIndex = SearchSolutionBloc.initialIndex;
                _catalogues = [];
              } else {
                if (_searchController.text.trim().isNotEmpty &&
                    _requestSuccessObject.additionalData != null &&
                    _requestSuccessObject.additionalData
                        .toString()
                        .trim()
                        .isNotEmpty) {
                  pageIndex = SearchSolutionBloc.initialIndex;
                  _catalogues = [];
                }
              }
            }
            if (_requestSuccessObject.requestCode !=
                    SearchSolutionBloc.initialIndex &&
                _requestSuccessObject.response.isEmpty) {
              _endReached = true;
            } else {
              _endReached = false;
              if (_searchController.text.trim().isEmpty) {
                Set _allItems = _catalogues.toSet();
                _allItems.addAll(_requestSuccessObject.response);
                _catalogues = _allItems.toList(growable: true);
              } else {
                if (_searchController.text.trim().isNotEmpty &&
                    _requestSuccessObject.additionalData != null &&
                    _requestSuccessObject.additionalData
                        .toString()
                        .trim()
                        .isNotEmpty) {
                  Set _allItems = _catalogues.toSet();
                  _allItems.addAll(_requestSuccessObject.response);
                  _catalogues = _allItems.toList(growable: true);
                }
              }
            }
            _selectedItemList.forEach((selectedItem) {
              if (_catalogues.contains(selectedItem)) {
                _catalogues.remove(selectedItem);
              }
            });
            pageIndex++;
            _searchSolutionBloc.addStateInManualBiddingStream(null);
          } else if (snapShot.data is RequestFailed) {
            RequestFailed _requestFailed = snapShot.data;
            pageIndex = SearchSolutionBloc.initialIndex;
            _failureCause = _requestFailed.failureCause;
            _searchSolutionBloc.addStateInManualBiddingStream(null);
          }
          return (_catalogues == null || _catalogues.isEmpty)
              ? _getDefaultWidget(snapShot)
              : _showResultsFromBackend(snapShot);
        });
  }

  Widget getMoreFacilityWidget(List<MoreFacility> catalogues, int index,
      {bool isSelected = false, Function onTap, Function onProfileTap}) {
    Widget _widget = _getCardWidget(catalogues, index,
        isSelected: isSelected, onTap: onTap, onProfileTap: onProfileTap);
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(2))),
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        child: Container(
          width: double.infinity,
          child: Stack(
            children: [
              _widget,
              Positioned.fill(child: Container(color: Colors.white)),
              Positioned.fill(
                child: Row(
                  children: [
                    Container(
                      width: AppConfig.horizontalBlockSize * 25,
                      child: SizedBox.expand(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              if (onProfileTap != null) {
                                onProfileTap();
                              }
                            },
                            onDoubleTap: () {},
                            child: CustomWidgets().getImageFromUrl(
                                catalogues[index]?.imageUrl ?? "",
                                boxFit: BoxFit.cover,
                                placeHolderPath: PlunesImages.doc_placeholder),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _widget
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCardWidget(List<MoreFacility> catalogues, int index,
      {bool isSelected = false, Function onTap, Function onProfileTap}) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(width: AppConfig.horizontalBlockSize * 25),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (onProfileTap != null) {
                              onProfileTap();
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${catalogues[index].name ?? "NA"} ",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: PlunesColors.BLACKCOLOR,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (onTap != null) {
                                    onTap();
                                  }
                                },
                                child: isSelected
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: PlunesColors.GREENCOLOR,
                                            shape: BoxShape.circle),
                                        padding: EdgeInsets.all(4),
                                        width:
                                            AppConfig.horizontalBlockSize * 8,
                                        child: Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 18,
                                            color: PlunesColors.WHITECOLOR,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: 1.2,
                                                color: PlunesColors.GREYCOLOR)),
                                        width:
                                            AppConfig.horizontalBlockSize * 8,
                                        child: Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(4),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * .3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  catalogues[index].locality ?? "",
                                  style: TextStyle(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#707070")),
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Container(
                                  height: AppConfig.verticalBlockSize * 4,
                                  width: AppConfig.horizontalBlockSize * 6,
                                  child:
                                      Image.asset(plunesImages.locationIcon)),
                              Text(
                                "${catalogues[index].distance?.toStringAsFixed(1) ?? PlunesStrings.NA}kms",
                                style: TextStyle(
                                    color: PlunesColors.GREYCOLOR,
                                    fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            (catalogues[index].experience != null &&
                                    catalogues[index].experience > 0)
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 2.5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Experience",
                                          style: TextStyle(
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#5D5D5D")),
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: AppConfig.verticalBlockSize *
                                                  .3),
                                          child: Text(
                                            "${catalogues[index].experience.toStringAsFixed(0)} ${catalogues[index].experience == 1 ? "Year" : "Years"}",
                                            style: TextStyle(
                                                color: PlunesColors.BLACKCOLOR,
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2.5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(
                                      Icons.star,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#FDCC0D")),
                                    ),
                                    Text(
                                      catalogues[index]
                                              .rating
                                              ?.toStringAsFixed(1) ??
                                          PlunesStrings.NA,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _getModelBottomSheetForServiceList(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17), topRight: Radius.circular(17))),
        builder: (anotherContext) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17)),
                border: Border.all(
                    color: Color(CommonMethods.getColorHexFromStr("#26AF78")),
                    width: 1)),
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 3,
                            top: AppConfig.verticalBlockSize * 1.5),
                        height: 3,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#707070")),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Service",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: 2, bottom: AppConfig.verticalBlockSize * 2.5),
                  height: 0.5,
                  color: Color(CommonMethods.getColorHexFromStr("#707070")),
                  width: double.infinity,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _selectedSpecialityName =
                              _getSpecialityItems()[index].speciality;
                          _specialitySelectedId =
                              _getSpecialityItems()[index].id;
                          _catalogues = [];
                          pageIndex = SearchSolutionBloc.initialIndex;
                          _getMoreFacilities();
                          Navigator.maybePop(context);
                        },
                        onDoubleTap: () {},
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 0.7),
                          child: Text(
                            _getSpecialityItems()[index].speciality ?? "NA",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      );
                    },
                    itemCount: _getSpecialityItems().length,
                  ),
                )
              ],
            ),
            constraints: BoxConstraints(
                minWidth: 10,
                maxWidth: double.infinity,
                minHeight: AppConfig.verticalBlockSize * 2,
                maxHeight: AppConfig.verticalBlockSize * 50),
          );
        });
  }

  List<SpecialityModel> _getSpecialityItems() {
    if (_specialityItems != null && _specialityItems.isNotEmpty) {
      return _specialityItems;
    }
    _specialityItems = [];
    CommonMethods.catalogueLists.forEach((element) {
      if (element.speciality != null &&
          element.speciality.trim().isNotEmpty &&
          element.id != null &&
          element.id.trim().isNotEmpty) {
        _specialityItems.add(element);
      }
    });
    return _specialityItems;
  }

  String _getSpecialityName() {
    if (_selectedSpecialityName == null) {
      return "Speciality";
    } else {
      return _selectedSpecialityName.length > 8
          ? _selectedSpecialityName.substring(0, 8)
          : _selectedSpecialityName;
    }
  }
}
