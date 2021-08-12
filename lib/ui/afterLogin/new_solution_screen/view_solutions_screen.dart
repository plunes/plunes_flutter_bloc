import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_painter_icon_gen.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/new_solution_model/premium_benefits_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:plunes/ui/afterLogin/solution_screens/choose_more_facilities_screen.dart';

// ignore: must_be_immutable
class ViewSolutionsScreen extends BaseActivity {
  final String searchQuery, reportId;
  final CatalogueData catalogueData;

  ViewSolutionsScreen({this.catalogueData, this.searchQuery, this.reportId});

  @override
  _ViewSolutionsScreenState createState() => _ViewSolutionsScreenState();
}

class _ViewSolutionsScreenState extends BaseState<ViewSolutionsScreen> {
  IconGenerator _iconGen;
  BitmapDescriptor hosImage2XGreenBgDesc;
  Set<Marker> _markers = {};
  SearchSolutionBloc _searchSolutionBloc;
  SearchedDocResults _searchedDocResults;
  List<Widget> _mapWidgets;
  List<GlobalKey> _globalKeys = [];
  List<Function> _functions = [];
  List<Services> _customServices = [];
  String _failedMessage;
  GoogleMapController _mapController;
  Completer<GoogleMapController> _googleMapController = Completer();
  User _user;

  // PremiumBenefitsModel _premiumBenefitsModel;
  UserBloc _userBloc;
  bool _isPopUpOpened;

  @override
  void initState() {
    _isPopUpOpened = false;
    _initScreenNameAfterDelay();
    _userBloc = UserBloc();
    _user = UserManager().getUserDetails();
    _mapWidgets = [];
    _markers = {};
    _iconGen = IconGenerator();
    _searchSolutionBloc = SearchSolutionBloc();
    _getFacilities();
    _iconGen.getBytesFromAsset(PlunesImages.labMapImage, 100).then((value) {
      hosImage2XGreenBgDesc = BitmapDescriptor.fromBytes(value);
      // _markers.add(Marker(
      //     icon: hosImage2XGreenBgDesc,
      //     position: LatLng(28.443, 78.3222),
      //     markerId: MarkerId("ds"),
      //     onTap: () => _doSomething()));
      // if (mounted) setState(() {});
    });
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == FirebaseNotification.solutionViewScreen &&
          FirebaseNotification.getCurrentScreenName() != null &&
          FirebaseNotification.getCurrentScreenName() ==
              FirebaseNotification.solutionViewScreen &&
          mounted) {
        if (_isPopUpOpened != null && _isPopUpOpened) {
          Navigator.pop(context);
        }
        Navigator.maybePop(context);
      }
    });
    super.initState();
  }

  _setScreenName(String screenName) {
    FirebaseNotification.setScreenName(screenName);
  }

  // _getPremiumBenefitsForUsers() {
  //   _userBloc.getPremiumBenefitsForUsers().then((value) {
  //     if (value is RequestSuccess) {
  //       _premiumBenefitsModel = value.response;
  //     } else if (value is RequestFailed) {}
  //     _setState();
  //   });
  // }

  @override
  void dispose() {
    _setScreenName(null);
    _globalKeys = [];
    _functions = [];
    _customServices = [];
    _searchSolutionBloc?.dispose();
    _userBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<RequestState>(
          stream: _searchSolutionBloc.getDocHosStream(),
          initialData:
              (_searchedDocResults == null) ? RequestInProgress() : null,
          builder: (context, snapshot) {
            if (snapshot.data is RequestInProgress) {
              return CustomWidgets().getProgressIndicator();
            } else if (snapshot.data is RequestSuccess) {
              RequestSuccess data = snapshot.data;
              _searchedDocResults = data.response;
              // if (_premiumBenefitsModel == null ||
              //     _premiumBenefitsModel.data == null ||
              //     _premiumBenefitsModel.data.isEmpty) {
              //   _getPremiumBenefitsForUsers();
              // }
              _calculateMapData();
              _searchSolutionBloc.addIntoDocHosStream(null);
            } else if (snapshot.data is RequestFailed) {
              RequestFailed _reqFailObj = snapshot.data;
              _failedMessage = _reqFailObj?.failureCause;
              _searchSolutionBloc.addIntoDocHosStream(null);
            }
            return (_searchedDocResults == null ||
                    (_searchedDocResults.success != null &&
                        !_searchedDocResults.success) ||
                    _searchedDocResults.solution == null ||
                    _searchedDocResults.solution.services == null ||
                    _searchedDocResults.solution.services.isEmpty)
                ? CustomWidgets().errorWidget(
                    _failedMessage ?? _searchedDocResults?.msg,
                    onTap: () => _getFacilities(),
                    isSizeLess: true)
                : Container(
                    child: Scaffold(
                      body: _getBody(),
                      key: scaffoldKey,
                      appBar: PreferredSize(
                          child: Card(
                              color: Colors.white,
                              elevation: 3.0,
                              margin: EdgeInsets.only(
                                  top: AppConfig.getMediaQuery().padding.top),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.all(
                                          AppConfig.verticalBlockSize * 2),
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        (widget.catalogueData != null &&
                                                widget.catalogueData.category !=
                                                    null &&
                                                widget.catalogueData.category
                                                    .isNotEmpty)
                                            ? "Book Your ${widget.catalogueData.category.trim()}"
                                            : "Book Facility",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PlunesColors.BLACKCOLOR,
                                            fontSize: 16),
                                      ),
                                      (widget.catalogueData != null &&
                                              widget.catalogueData.speciality !=
                                                  null)
                                          ? Text(
                                              widget.catalogueData
                                                      ?.speciality ??
                                                  "",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#727272")),
                                                  fontSize: 14),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  Container(),
                                  Container(),
                                  Container(),
                                ],
                              )),
                          preferredSize: Size(double.infinity,
                              AppConfig.verticalBlockSize * 8)),
                    ),
                  );
          }),
    );
  }

  Widget _getBody() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
        Container(
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
                markers: _markers,
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.3,
                  maxChildSize: 0.9,
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
                            horizontal: AppConfig.horizontalBlockSize * 3.8,
                            vertical: AppConfig.verticalBlockSize * 2.8),
                        child: ListView(
                          controller: controller,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 38,
                                  right: AppConfig.horizontalBlockSize * 38),
                              height: 3,
                              decoration: BoxDecoration(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#707070")),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            // _getBenefitsWidget(),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 1.2,
                                  top: AppConfig.verticalBlockSize * 1.8,
                                  bottom: AppConfig.verticalBlockSize * 1.8,
                                  right: AppConfig.horizontalBlockSize * 1.2),
                              child: Text(
                                _searchedDocResults?.title ??
                                    "Congrats! We have discovered Top Facilities Near You.",
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontSize: 18),
                              ),
                            ),
                            _getSolutionListWidget(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Card(
              margin: EdgeInsets.all(0),
              child: Container(
                margin: EdgeInsets.only(
                    left: AppConfig.horizontalBlockSize * 4,
                    right: AppConfig.horizontalBlockSize * 4,
                    bottom: AppConfig.verticalBlockSize * 2,
                    top: AppConfig.verticalBlockSize * 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _getDiscoverMoreFacilitiesButton(),
                    _hasDiscoverMoreFacilityButton()
                        ? Flexible(child: _getDiscoverPriceButton())
                        : _getDiscoverPriceButton()
                  ],
                ),
              ),
            ))
      ],
    );
  }

  bool _hasDiscoverMoreFacilityButton() {
    return ((_searchedDocResults.solution.showAdditionalFacilities != null &&
            _searchedDocResults.solution.showAdditionalFacilities) &&
        !(widget.catalogueData != null &&
            widget.catalogueData.isFromProfileScreen != null &&
            widget.catalogueData.isFromProfileScreen));
  }

  Widget _getSolutionListWidget() {
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return (_searchedDocResults.solution.services[index].doctors !=
                      null &&
                  _searchedDocResults
                      .solution.services[index].doctors.isNotEmpty)
              ? _getDoctorListWidget(
                  _searchedDocResults.solution.services[index])
              : CommonWidgets().getSolutionViewWidget(
                  _searchedDocResults.solution.services[index],
                  widget.catalogueData,
                  () => _openProfile(
                      _searchedDocResults.solution.services[index]));
        },
        itemCount: _searchedDocResults.solution.services.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget _getDiscoverPriceButton() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: StreamBuilder<RequestState>(
          stream: _searchSolutionBloc.discoverPriceStream,
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.data is RequestInProgress) {
              return CustomWidgets().getProgressIndicator();
            } else if (snapshot.data is RequestSuccess) {
              _searchSolutionBloc.addStateInDiscoverPriceStream(null);
              Future.delayed(Duration(milliseconds: 10)).then((value) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SolutionShowPriceScreen(
                              catalogueData: widget.catalogueData,
                              searchQuery: widget.searchQuery,
                            )));
              });
            } else if (snapshot.data is RequestFailed) {
              RequestFailed _reqFailed = snapshot.data;
              Future.delayed(Duration(milliseconds: 10)).then((value) {
                _showMessagePopup(_reqFailed?.failureCause);
              });
              _searchSolutionBloc.addStateInDiscoverPriceStream(null);
            }
            return InkWell(
              onTap: () {
                _searchSolutionBloc.discoverPrice(
                    _searchedDocResults?.solution?.sId,
                    _searchedDocResults?.solution?.serviceId);
              },
              onDoubleTap: () {},
              child: CustomWidgets().getRoundedButton(
                  PlunesStrings.discoverPrice,
                  AppConfig.horizontalBlockSize * 8,
                  PlunesColors.PARROTGREEN,
                  AppConfig.horizontalBlockSize * 3,
                  AppConfig.verticalBlockSize * 1,
                  PlunesColors.WHITECOLOR,
                  hasBorder: false),
            );
          }),
    );
  }

  _showProfessionalPopup(
      Services service, CatalogueData catalogueData, Function openProfile) {
    _isPopUpOpened = true;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: SingleChildScrollView(
              child: CommonWidgets().getSolutionViewWidgetPopUp(
                  service, catalogueData, openProfile, context),
            ),
          );
        }).then((value) {
      _isPopUpOpened = false;
    });
  }

  _showHospitalDoctorPopup(Services service, CatalogueData catalogueData,
      Function openProfile, int index) {
    _isPopUpOpened = true;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: SingleChildScrollView(
              child: CommonWidgets().getSolutionViewWidgetForHospitalDocPopup(
                  service, catalogueData, openProfile, index, context),
            ),
          );
        }).then((value) {
      _isPopUpOpened = false;
    });
  }

  void _getFacilities() {
    _searchSolutionBloc.getDocHosSolution(widget.catalogueData,
        searchQuery: widget.searchQuery, userReportId: widget.reportId);
  }

  void _calculateMapData() {
    if (_searchedDocResults != null &&
        _searchedDocResults.solution != null &&
        _searchedDocResults.solution.services != null &&
        _searchedDocResults.solution.services.isNotEmpty) {
      _globalKeys = [];
      _mapWidgets = [];
      _functions = [];
      _customServices = [];
      for (int index = 0;
          index < _searchedDocResults.solution.services.length;
          index++) {
        if (_searchedDocResults.solution.services[index].doctors != null &&
            _searchedDocResults.solution.services[index].doctors.isNotEmpty) {
          _searchedDocResults.solution.services[index].doctors
              .forEach((doctor) {
            var key = GlobalKey();
            _globalKeys.add(key);
            _functions.add(() => _showHospitalDoctorPopup(
                _searchedDocResults.solution.services[index],
                widget.catalogueData,
                () =>
                    _openProfile(_searchedDocResults.solution.services[index]),
                _searchedDocResults.solution.services[index].doctors
                    .indexOf(doctor)));
            Services service = Services(
                name: doctor?.name ?? "",
                sId: _searchedDocResults.solution.services[index].sId,
                latitude: _searchedDocResults.solution.services[index].latitude,
                longitude:
                    _searchedDocResults.solution.services[index].longitude,
                professionalPhotos: _searchedDocResults
                        .solution.services[index].professionalPhotos ??
                    [],
                distance:
                    _searchedDocResults.solution.services[index].distance);
            _customServices.add(service);
            // _mapWidgets.add(RepaintBoundary(
            //   child: Container(
            //     child: Column(
            //       children: [
            //         ClipOval(
            //           child: Container(
            //             width: 70,
            //             height: 70,
            //             decoration: BoxDecoration(
            //                 color: Colors.transparent, shape: BoxShape.circle),
            //             child: CustomWidgets().getImageFromUrl(
            //                 doctor.imageUrl ?? "",
            //                 placeHolderPath: PlunesImages.labMapImage,
            //                 boxFit: BoxFit.fill),
            //           ),
            //         ),
            //         SizedBox(
            //           height: 4,
            //         ),
            //         Container(
            //           height: 12,
            //           width: 12,
            //           decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               color: Colors.indigo.withOpacity(0.4)),
            //         )
            //       ],
            //     ),
            //   ),
            //   key: key,
            // ));
          });
        } else {
          var key = GlobalKey();
          _globalKeys.add(key);
          _functions.add(() => _showProfessionalPopup(
              _searchedDocResults.solution.services[index],
              widget.catalogueData,
              () =>
                  _openProfile(_searchedDocResults.solution.services[index])));
          _customServices.add(_searchedDocResults.solution.services[index]);
          // _mapWidgets.add(RepaintBoundary(
          //   child: Container(
          //     child: Column(
          //       children: [
          //         ClipOval(
          //           child: Container(
          //             width: 70,
          //             height: 70,
          //             decoration: BoxDecoration(
          //                 color: Colors.transparent, shape: BoxShape.circle),
          //             child: CustomWidgets().getImageFromUrl(
          //                 _searchedDocResults.solution.services[index].imageUrl,
          //                 placeHolderPath: PlunesImages.labMapImage,
          //                 boxFit: BoxFit.fill),
          //           ),
          //         ),
          //         SizedBox(
          //           height: 4,
          //         ),
          //         Container(
          //           height: 12,
          //           width: 12,
          //           decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               color: Colors.indigo.withOpacity(0.4)),
          //         )
          //       ],
          //     ),
          //   ),
          //   key: key,
          // ));
        }
      }
      _showMapWidgetsAfterDelay();
    }
  }

  void _showMapWidgetsAfterDelay() async {
    try {
      double minZoom = 0;
      int arrLength = _searchedDocResults.solution.services.length;
      for (int index = 0; index < arrLength; index++) {
        if (_searchedDocResults.solution.services[index].distance != null &&
            _searchedDocResults.solution.services[index].distance > minZoom) {
          minZoom = _searchedDocResults.solution.services[index].distance;
        }
      }
      if (minZoom != 0) {
        _animateMapPosition(minZoom);
      }
      await Future.delayed(Duration(seconds: 1));
      for (int index = 0; index < _globalKeys.length; index++) {
        await Future.delayed(Duration(milliseconds: 150));
        _markers.add(Marker(
            markerId: MarkerId(_customServices[index].sId),
            icon: hosImage2XGreenBgDesc,
            onTap: () => _functions[index](),
            position: LatLng(_customServices[index].latitude?.toDouble() ?? 0.0,
                _customServices[index].longitude?.toDouble() ?? 0.0),
            infoWindow: InfoWindow(
                title: _customServices[index].name,
                snippet:
                    "${_customServices[index].distance?.toStringAsFixed(1) ?? 1} km")));
        _setState();
      }
    } catch (e) {}
  }

  _openProfile(Services service) {
    if (service != null &&
        service.userType != null &&
        service.professionalId != null) {
      _setScreenName(null);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorInfo(service.professionalId,
                  isDoc: (service.userType.toLowerCase() ==
                      Constants.doctor.toString().toLowerCase()),
                  isAlreadyInBookingProcess: true))).then((value) {
        _setScreenName(FirebaseNotification.solutionViewScreen);
      });
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  void _animateMapPosition(double minZoom) async {
    if (minZoom < 5) {
      minZoom = 14;
    } else if (minZoom < 10) {
      minZoom = 12;
    } else if (minZoom < 20) {
      minZoom = 11;
    } else if (minZoom < 35) {
      minZoom = 10.5;
    } else if (minZoom < 55) {
      minZoom = 9.2;
    } else {
      minZoom = 9;
    }
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      if (_mapController != null && mounted) {
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(double.parse(_user.latitude),
                    double.parse(_user.longitude)),
                zoom: minZoom,
                bearing: 10)));
      }
    });
  }

  Widget _getDoctorListWidget(Services service) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          child: CommonWidgets().getSolutionViewWidgetForHospitalDoc(service,
              widget.catalogueData, () => _openProfile(service), index),
        );
      },
      itemCount: service?.doctors?.length ?? 0,
    );
  }

  void _showMessagePopup(String message) {
    if (mounted) {
      _isPopUpOpened = true;
      showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets()
                .getInformativePopup(globalKey: scaffoldKey, message: message);
          }).then((value) {
        _isPopUpOpened = false;
      });
    }
  }

  void _initScreenNameAfterDelay() async {
    Future.delayed(Duration(seconds: 1)).then((value) {
      _setScreenName(FirebaseNotification.solutionViewScreen);
    });
  }

  Widget _getDiscoverMoreFacilitiesButton() {
    if (_searchedDocResults.solution.showAdditionalFacilities != null &&
        _searchedDocResults.solution.showAdditionalFacilities) {
      if (widget.catalogueData != null &&
          widget.catalogueData.isFromProfileScreen != null &&
          widget.catalogueData.isFromProfileScreen) {
        return Container();
      }
      return Flexible(
        child: Container(
          child: Container(
            child: InkWell(
              onTap: () {
                _setScreenName(null);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MoreFacilityScreen(
                              catalogueData: _searchedDocResults.catalogueData,
                              docHosSolution: _searchedDocResults.solution,
                              searchSolutionBloc: _searchSolutionBloc,
                            ))).then((value) {
                  _setScreenName(FirebaseNotification.solutionViewScreen);
                  _getFacilities();
                });
              },
              child: CustomWidgets().getRoundedButton(
                  PlunesStrings.discoverMoreFacilityButtonText,
                  AppConfig.horizontalBlockSize * 8,
                  PlunesColors.WHITECOLOR,
                  AppConfig.horizontalBlockSize * 3,
                  AppConfig.verticalBlockSize * 1,
                  Color(CommonMethods.getColorHexFromStr("#25B281")),
                  borderColor:
                      Color(CommonMethods.getColorHexFromStr("#25B281")),
                  hasBorder: true),
            ),
          ),
        ),
      );
    }
    return Container();
  }
}
