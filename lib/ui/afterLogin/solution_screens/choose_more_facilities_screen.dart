import 'dart:async';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_painter_icon_gen.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';

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
  StreamController _streamController,
      _selectUnselectController,
      _carouselStreamController;
  Timer _debounce;
  int pageIndex = SearchSolutionBloc.initialIndex;
  List<MoreFacility> _catalogues, _selectedItemList;
  bool _endReached;
  String _failureCause;
  bool _scrollParent = false;
  final CarouselController _controller = CarouselController();
  double _currentDotPosition = 0.0;
  User _user;
  GoogleMapController _mapController;
  Completer<GoogleMapController> _googleMapController = Completer();
  String _initialSearchedString;
  List<DropdownMenuItem<String>> facilityTypeWidget = [
    DropdownMenuItem(
      child: Text("Hospital"),
      value: Constants.hospital.toString(),
    ),
    DropdownMenuItem(
      child: Text("Doctor"),
      value: Constants.doctor.toString(),
    ),
    DropdownMenuItem(
      child: Text("Lab"),
      value: Constants.labDiagnosticCenter.toString(),
    ),
    DropdownMenuItem(
      child: Text("All"),
      value: "All",
    ),
  ];

  List<DropdownMenuItem<String>> _facilityLocationDropDownItems = [
    DropdownMenuItem(
      child: Text(
        "Near me",
      ),
      value: _nearMeKey,
    ),
    DropdownMenuItem(
      child: Text("All"),
      value: _allKey,
    )
  ];

  static final String _nearMeKey = "Near me";
  static final String _allKey = "All";

  String _userTypeFilter = Constants.hospital.toString();

  String _locationFilter = _nearMeKey;
  IconGenerator _iconGen;
  BitmapDescriptor _hosImage2XGreenBgDesc;
  Set<Marker> _markers = {};

  _getMoreFacilities() {
    _failureCause = null;
    _searchSolutionBloc.getMoreFacilities(widget.docHosSolution,
        searchQuery: _searchController.text.trim().toString(),
        pageIndex: pageIndex,
        allLocationKey: _allKey,
        facilityLocationFilter: _locationFilter,
        userTypeFilter: _userTypeFilter);
  }

  _addMarkers() {
    // print("markers called");
    _markers = {};
    List<MoreFacility> _allFacilities = [];
    if (_catalogues != null && _catalogues.isNotEmpty) {
      _allFacilities = _catalogues;
    }
    if (_selectedItemList != null && _selectedItemList.isNotEmpty) {
      _allFacilities = _selectedItemList;
    }
    _allFacilities = _allFacilities.toSet()?.toList(growable: true);
    // print("marker length earlier ${_markers?.length}");
    if (_allFacilities != null && _allFacilities.isNotEmpty) {
      _markers = _allFacilities.where((e) {
        return e.professionalId != null &&
            e.professionalId.trim().isNotEmpty &&
            e.latitude != null &&
            e.latitude.isNotEmpty &&
            e.longitude != null &&
            e.longitude.isNotEmpty;
      }).map((e) {
        return Marker(
            markerId: MarkerId(e.professionalId),
            icon: _hosImage2XGreenBgDesc,
            onTap: () => _viewProfile(e),
            position: LatLng(double.tryParse(e.latitude) ?? 0.0,
                double.tryParse(e.longitude) ?? 0.0),
            infoWindow: InfoWindow(
                title: e.name ?? '',
                snippet: "${e.distance?.toStringAsFixed(1)} km"));
      }).toSet();
    }
    // print("marker length after ${_markers?.length}");
  }

  @override
  void initState() {
    _markers = {};
    _user = UserManager().getUserDetails();
    _scrollParent = false;
    _searchSolutionBloc = widget.searchSolutionBloc;
    _searchController = TextEditingController()..addListener(_onSearch);
    _streamController = StreamController.broadcast();
    _selectUnselectController = StreamController.broadcast();
    _carouselStreamController = StreamController.broadcast();
    _catalogues = [];
    _selectedItemList = [];
    _endReached = false;
    _iconGen = IconGenerator();
    _iconGen.getBytesFromAsset(PlunesImages.labMapImage, 100).then((value) {
      _hosImage2XGreenBgDesc = BitmapDescriptor.fromBytes(value);
    });
    _getMoreFacilities();
    super.initState();
  }

  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

  _onSearch() {
    _streamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController != null &&
          _searchController.text != null &&
          _searchController.text.trim().isNotEmpty) {
        if (_initialSearchedString == null) {
          _initialSearchedString = _searchController.text.trim();
        }
        _failureCause = null;
        _searchSolutionBloc.addIntoMoreFacilitiesStream(RequestInProgress());
        _searchSolutionBloc.getMoreFacilities(widget.docHosSolution,
            searchQuery: _searchController.text.trim().toString(),
            pageIndex: 0,
            allLocationKey: _allKey,
            facilityLocationFilter: _locationFilter,
            userTypeFilter: _userTypeFilter);
      } else {
        if (_initialSearchedString == null ||
            _initialSearchedString.trim().isEmpty) {
          return;
        }
        _onTextClear();
      }
    });
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearch);
    _searchController?.dispose();
    _carouselStreamController?.close();
    _streamController?.close();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            appBar: widget.getAppBar(
                context, PlunesStrings.discoverFacilityNearYou, true),
            body: Builder(builder: (context) {
              return StreamBuilder<RequestState>(
                  stream: _searchSolutionBloc.getFacilityAdditionStream(),
                  builder: (context, snapshot) {
                    if (snapshot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    } else if (snapshot.data is RequestSuccess) {
                      Future.delayed(Duration(milliseconds: 10)).then((value) {
                        _showInSnackBar(
                            "Congrats! You have unlocked ${_selectedItemList.length} more ${_selectedItemList.length == 1 ? "facility" : "facilities"}!",
                            shouldTakeBack: true);
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
    // print("_markers $_markers");
    return StreamBuilder<RequestState>(
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
            _addMarkers();
          } else if (snapShot.data is RequestFailed) {
            RequestFailed _requestFailed = snapShot.data;
            pageIndex = SearchSolutionBloc.initialIndex;
            _failureCause = _requestFailed.failureCause;
            _searchSolutionBloc.addIntoMoreFacilitiesStream(null);
          }
          if (((_catalogues == null || _catalogues.isEmpty) &&
              (_selectedItemList == null || _selectedItemList.isEmpty))) {
            return _getDefaultWidget(snapShot);
          } else {
            return Container(
              child: Column(
                children: <Widget>[
                  StreamBuilder<Object>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        return _getSearchBar();
                      }),
                  _getFilterWidget(),
                  Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: (mapController) {
                            if (_googleMapController != null &&
                                _googleMapController.isCompleted) {
                              return;
                            }
                            _mapController = mapController;
                            _googleMapController.complete(_mapController);
                          },
                          markers: _markers ?? {},
                          initialCameraPosition: CameraPosition(
                              target: LatLng(double.parse(_user.latitude),
                                  double.parse(_user.longitude)),
                              zoom: 10),
                          zoomControlsEnabled: false,
                          padding: EdgeInsets.all(0.0),
                          myLocationEnabled: false,
                          zoomGesturesEnabled: true,
                          myLocationButtonEnabled: false,
                          buildingsEnabled: false,
                          trafficEnabled: false,
                          indoorViewEnabled: false,
                          mapType: MapType.terrain,
                          // markers: _markers,
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.3,
                            minChildSize: 0.3,
                            maxChildSize: 0.88,
                            builder: (context, controller) {
                              return Card(
                                margin: EdgeInsets.all(0),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(35),
                                        topRight: Radius.circular(35))),
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 3.8,
                                      vertical:
                                          AppConfig.verticalBlockSize * 2.8),
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification: (scrollState) {
                                      if (scrollState
                                              is ScrollEndNotification &&
                                          scrollState.metrics.extentAfter ==
                                              0 &&
                                          !_endReached) {
                                        _failureCause = null;
                                        _searchSolutionBloc
                                            .addIntoMoreFacilitiesStream(
                                                RequestInProgress());
                                        _searchSolutionBloc.getMoreFacilities(
                                            widget.docHosSolution,
                                            searchQuery: _searchController.text
                                                .trim()
                                                .toString(),
                                            pageIndex: pageIndex,
                                            allLocationKey: _allKey,
                                            facilityLocationFilter:
                                                _locationFilter,
                                            userTypeFilter: _userTypeFilter);
                                      } else if (scrollState
                                          is OverscrollNotification) {
                                        _scrollParent = true;
                                        _setState();
                                        Future.delayed(Duration(seconds: 1))
                                            .then((value) {
                                          _scrollParent = false;
                                          _setState();
                                        });
                                      }
                                      return;
                                    },
                                    child: SingleChildScrollView(
                                      controller: controller,
                                      child: _showResultsFromBackend(snapShot),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  _getContinueButton()
                ],
              ),
            );
          }
        });
  }

  Widget _getContinueButton() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 28,
            right: AppConfig.horizontalBlockSize * 28,
            bottom: AppConfig.verticalBlockSize * 2),
        child: InkWell(
          onTap: () {
            _searchSolutionBloc.addFacilitiesInSolution(
                widget.docHosSolution, _selectedItemList);
            return;
          },
          onDoubleTap: () {},
          child: CustomWidgets().getRoundedButton(
              PlunesStrings.continueText,
              AppConfig.horizontalBlockSize * 8,
              PlunesColors.PARROTGREEN,
              AppConfig.horizontalBlockSize * 3,
              AppConfig.verticalBlockSize * 1,
              PlunesColors.WHITECOLOR,
              hasBorder: false),
        ),
      ),
    );
  }

  Widget _getSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: AppConfig.verticalBlockSize * 1.5,
          horizontal: AppConfig.horizontalBlockSize * 5),
      child: CommonWidgets().getSearchBarForManualBidding(
          searchController: _searchController,
          isRounded: true,
          hintText: "Search the desired service",
          onTextClear: () => _onTextClear()),
    );
  }

  Widget _showResultsFromBackend(AsyncSnapshot<RequestState> snapShot) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 38,
              right: AppConfig.horizontalBlockSize * 38,
              bottom: 2),
          height: 3,
          decoration: BoxDecoration(
              color: Color(CommonMethods.getColorHexFromStr("#CDCDCD")),
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        StreamBuilder<Object>(
            stream: _selectUnselectController.stream,
            builder: (context, snapshot) {
              if (_selectedItemList == null || _selectedItemList.isEmpty) {
                return Container();
              }
              return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                    top: AppConfig.verticalBlockSize * 0.8,
                    bottom: AppConfig.verticalBlockSize * 1.2),
                child: Text(
                  PlunesStrings.selectedFacilities,
                  style:
                      TextStyle(fontSize: 20, color: PlunesColors.BLACKCOLOR),
                ),
              );
            }),
        StreamBuilder<Object>(
            stream: _selectUnselectController.stream,
            builder: (context, snapshot) {
              if (_selectedItemList == null || _selectedItemList.isEmpty) {
                _currentDotPosition = 0.0;
                return Container();
              }
              return Column(
                children: [
                  Container(
                    child: CarouselSlider.builder(
                      itemCount: _selectedItemList?.length ?? 0,
                      carouselController: _controller,
                      itemBuilder: (context, index) {
                        return CommonWidgets().getHorizontalProfessionalWidget(
                            _selectedItemList, index,
                            isSelected: true,
                            onTap: () =>
                                _addRemoveFacilities(_selectedItemList[index]),
                            onProfileTap: () =>
                                _viewProfile(_selectedItemList[index]));
                      },
                      options: CarouselOptions(
                          // height: AppConfig.verticalBlockSize * 20,
                          aspectRatio: 16 / 7,
                          initialPage: 0,
                          enableInfiniteScroll: false,
                          pageSnapping: true,
                          reverse: false,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, _) {
                            // print(
                            //     "$index current index now upcoming${_currentDotPosition.toInt()}");
                            if (_currentDotPosition.toInt() != index) {
                              _currentDotPosition = index.toDouble();
                              _carouselStreamController?.add(null);
                            }
                          }),
                    ),
                  ),
                  StreamBuilder<Object>(
                      stream: _carouselStreamController.stream,
                      builder: (context, snapshot) {
                        return Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 0.5),
                          child: DotsIndicator(
                            dotsCount: _selectedItemList.length,
                            position: (_currentDotPosition.toInt() + 1 >
                                    _selectedItemList.length)
                                ? (_selectedItemList.length - 1).toDouble()
                                : _currentDotPosition,
                            axis: Axis.horizontal,
                            decorator: _decorator,
                            onTap: (pos) {
                              // _controller.animateToPage(pos.toInt(),
                              //     curve: Curves.easeInOut,
                              //     duration: Duration(milliseconds: 300));
                              // _currentDotPosition = pos;
                              // _carouselStreamController?.add(null);
                              // return;
                            },
                          ),
                        );
                      })
                ],
              );
            }),
        StreamBuilder<Object>(
            stream: _selectUnselectController.stream,
            builder: (context, snapshot) {
              if (_catalogues == null || _catalogues.isEmpty) {
                return Container();
              }
              return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                    top: AppConfig.verticalBlockSize * 0.8,
                    bottom: AppConfig.verticalBlockSize * 1.2),
                child: Text(
                  PlunesStrings.chooseFacilities,
                  style:
                      TextStyle(fontSize: 20, color: PlunesColors.BLACKCOLOR),
                ),
              );
            }),
        ListView.builder(
          padding: null,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              child: CommonWidgets().getManualBiddingProfessionalWidget(
                  _catalogues, index,
                  onTap: () =>
                      _addRemoveFacilities(_catalogues[index], shouldAdd: true),
                  onProfileTap: () => _viewProfile(_catalogues[index])),
            );
          },
          shrinkWrap: true,
          itemCount: _catalogues?.length ?? 0,
        ),
        (snapShot.data is RequestInProgress &&
                (_catalogues != null && _catalogues.isNotEmpty))
            ? CustomWidgets().getProgressIndicator()
            : Container()
      ],
    );
  }

  Widget _getDefaultWidget(AsyncSnapshot<RequestState> snapShot) {
    return Container(
      child: Column(
        children: <Widget>[
          (snapShot.data != null &&
                  snapShot.data is RequestInProgress &&
                  (_catalogues == null || _catalogues.isEmpty))
              ? Expanded(child: CustomWidgets().getProgressIndicator())
              : Expanded(
                  child: CustomWidgets().errorWidget(
                      _failureCause ??
                          PlunesStrings.facilityNotAvailableMessage, onTap: () {
                    _searchController.text = "";
                    _locationFilter = _nearMeKey;
                    _userTypeFilter = Constants.hospital.toString();
                    _initialSearchedString = null;
                    pageIndex = SearchSolutionBloc.initialIndex;
                    _getMoreFacilities();
                  },
                      shouldNotShowImage: !(_failureCause != null &&
                          _failureCause == PlunesStrings.noInternet)),
                )
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
    if (_selectedItemList.contains(facility)) {
      _selectedItemList.remove(facility);
      if (_catalogues != null &&
          _catalogues.isNotEmpty &&
          _searchController.text.trim().isEmpty) {
        _catalogues.insert(0, facility);
      } else if (_catalogues != null &&
          _catalogues.isEmpty &&
          _selectedItemList != null &&
          _selectedItemList.isEmpty) {
        _catalogues.insert(0, facility);
      }
    } else {
      _selectedItemList.add(facility);
      _catalogues.remove(facility);
    }
    if (_catalogues == null || _catalogues.isEmpty) {
      _failureCause = PlunesStrings.emptyStr;
    }
    _addMarkers();
    _selectUnselectController.add(null);
    _searchSolutionBloc.addIntoMoreFacilitiesStream(null);
  }

  void _showInSnackBar(String message, {bool shouldTakeBack = false}) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets()
              .getInformativePopup(message: message, globalKey: scaffoldKey);
        }).then((value) {
      if (shouldTakeBack) {
        Navigator.pop(context, shouldTakeBack);
      }
    });
  }

  _viewProfile(MoreFacility service) {
    if (service.userType != null && service.professionalId != null) {
      Widget route = DoctorInfo(service.professionalId,
          isDoc: (service.userType.toLowerCase() ==
              Constants.doctor.toString().toLowerCase()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getFilterWidget() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 6),
      padding: EdgeInsets.only(
        bottom: AppConfig.verticalBlockSize * 1.5,
      ),
      child: Row(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 5),
            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(AppConfig.horizontalBlockSize * 10)),
                color: Color(CommonMethods.getColorHexFromStr("#00000012")),
                border: Border.all(
                    width: 0.8,
                    color: Color(CommonMethods.getColorHexFromStr("#E7E7E7")))),
            child: DropdownButton<String>(
              items: facilityTypeWidget,
              underline: Container(),
              value: _userTypeFilter,
              isExpanded: true,
              hint: Text(
                "Hospital",
                style: TextStyle(fontSize: 14, color: PlunesColors.BLACKCOLOR),
              ),
              onChanged: (userType) {
                _userTypeFilter = userType;
                _doFilterAndGetFacilities();
              },
            ),
          )),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3),
            padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(AppConfig.horizontalBlockSize * 10)),
                color: Color(CommonMethods.getColorHexFromStr("#00000012")),
                border: Border.all(
                    width: 0.8,
                    color: Color(CommonMethods.getColorHexFromStr("#E7E7E7")))),
            child: DropdownButton(
              items: _facilityLocationDropDownItems,
              isExpanded: true,
              value: _locationFilter,
              underline: Container(),
              hint: Text(
                "Near Me",
                style: TextStyle(fontSize: 14, color: PlunesColors.BLACKCOLOR),
              ),
              onChanged: (locationFilter) {
                _locationFilter = locationFilter;
                _doFilterAndGetFacilities();
              },
            ),
          )),
        ],
      ),
    );
  }

  void _doFilterAndGetFacilities() {
    _catalogues = [];
    pageIndex = SearchSolutionBloc.initialIndex;
    _getMoreFacilities();
  }
}
