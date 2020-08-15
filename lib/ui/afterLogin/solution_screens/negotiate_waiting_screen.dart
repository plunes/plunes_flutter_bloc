import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_painter_icon_gen.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_received_screen.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';

// ignore: must_be_immutable
class BiddingLoading extends BaseActivity {
  final CatalogueData catalogueData;
  final String searchQuery;

  BiddingLoading({this.catalogueData, this.searchQuery});

  @override
  _BiddingLoadingState createState() => _BiddingLoadingState();
}

class _BiddingLoadingState extends BaseState<BiddingLoading> {
  double _bidProgress = 0.0;
  Timer _timer;
  int _start = 0;
  double _movingUnit = 110;
  bool _progressEnabled;
  String _failureCause;
  Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController _mapController;
  bool _hasAnimated = false;
  SearchSolutionBloc _searchSolutionBloc;
  SearchedDocResults _searchedDocResults;
  Set<Marker> _markers = {}, _bigMarkers = {};
  BitmapDescriptor hosImage1XGreenBgDesc, hosImage2XGreenBgDesc;
  User _user;
  IconGenerator _iconGen;

  @override
  void initState() {
    _hasAnimated = false;
    _progressEnabled = false;
    _searchSolutionBloc = SearchSolutionBloc();
    _user = UserManager().getUserDetails();
    _iconGen = IconGenerator();
//    _iconGen
//        .getBytesFromAsset(PlunesImages.hosImage1XGreenBg, 90)
//        .then((value) {
//      print("pehli image");
//      hosImage1XGreenBgDesc = BitmapDescriptor.fromBytes(value);
//    });
    _iconGen
        .getBytesFromAsset(PlunesImages.hosImage2XGreenBg, 180)
        .then((value) {
      hosImage2XGreenBgDesc = BitmapDescriptor.fromBytes(value);
    });
//    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
//            PlunesImages.hosImage1XGreenBg)
//        .then((onValue) {
//      hosImage1XGreenBgDesc = onValue;
//    });
//    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
//            PlunesImages.hosImage2XGreenBg)
//        .then((onValue) {
//      hosImage2XGreenBgDesc = onValue;
//    });
    _negotiate();
    _startAnimating();
    super.initState();
  }

  _startAnimating() {
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        _hasAnimated = !_hasAnimated;
        _start = _start + 1;
        if (_start > 9) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SolutionReceivedScreen(
                        catalogueData: widget.catalogueData,
                        searchQuery: widget.searchQuery,
                        searchedDocResults: _searchedDocResults,
                      ))).then((value) {
            if (value != null && value) {
              Navigator.of(context)
                  .push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          LocationFetch()))
                  .then((val) {
                if (val != null) {
                  var addressControllerList = new List();
                  addressControllerList = val.toString().split(":");
                  String addr = addressControllerList[0] +
                      ' ' +
                      addressControllerList[1] +
                      ' ' +
                      addressControllerList[2];
//                  print("addr is $addr");
                  var _latitude = addressControllerList[3];
                  var _longitude = addressControllerList[4];
                  _progressEnabled = true;
                  _setState();
                  UserBloc()
                      .isUserInServiceLocation(_latitude, _longitude,
                          address: addr)
                      .then((result) {
                    if (result is RequestSuccess) {
                      CheckLocationResponse checkLocationResponse =
                          result.response;
                      if (checkLocationResponse != null &&
                          checkLocationResponse.msg != null &&
                          checkLocationResponse.msg.isNotEmpty) {
                        _failureCause = checkLocationResponse.msg;
                      }
                    } else if (result is RequestFailed) {
                      _failureCause = result.failureCause;
                    }
                    if (UserManager().getIsUserInServiceLocation()) {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BiddingLoading(
                                    catalogueData: widget.catalogueData,
                                    searchQuery: widget.searchQuery,
                                  )));
                      return;
                    } else if (_failureCause == null) {
                      _failureCause = PlunesStrings.switchToGurLoc;
                    }
                    _progressEnabled = false;
                    _setState();
                  });
                } else {
                  Navigator.pop(context);
                }
              });
            } else {
              Navigator.pop(context);
            }
          });
        } else {
          _bidProgress = _bidProgress + 0.1;
          if (_movingUnit == 110) {
            _movingUnit = 10;
          } else {
            _movingUnit = 110;
          }
          _startAnimating();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlunesColors.WHITECOLOR,
      body: _progressEnabled
          ? CustomWidgets().getProgressIndicator()
          : _failureCause != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CustomWidgets().errorWidget(_failureCause),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 38,
                          vertical: AppConfig.verticalBlockSize * 4),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: CustomWidgets().getRoundedButton(
                            "Ok",
                            AppConfig.horizontalBlockSize * 8,
                            PlunesColors.GREENCOLOR,
                            AppConfig.horizontalBlockSize * 3,
                            AppConfig.verticalBlockSize * 1,
                            PlunesColors.WHITECOLOR),
                      ),
                    )
                  ],
                )
              : Container(
                  color: Colors.black12,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        top: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: GoogleMap(
                                onMapCreated: (mapController) {
                                  if (_googleMapController != null &&
                                      _googleMapController.isCompleted) {
                                    return;
                                  }
                                  _mapController = mapController;
                                  _googleMapController.complete(_mapController);
                                },
                                markers: _markers,
                                // _hasAnimated ? _markers : _bigMarkers,
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(double.parse(_user.latitude),
                                        double.parse(_user.longitude)),
                                    zoom: 10),
                                padding: EdgeInsets.all(0.0),
                                myLocationEnabled: false,
                                zoomControlsEnabled: false,
                                zoomGesturesEnabled: false,
                                myLocationButtonEnabled: false,
                                buildingsEnabled: false,
                                trafficEnabled: false,
                                indoorViewEnabled: false,
                                mapType: MapType.terrain,
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        top: 0,
                        child: IgnorePointer(
                          child: Container(color: Colors.black12),
                          ignoring: true,
                        ),
                      ),
//                      (_start > 8)
//                          ? Positioned(
//                              top: AppConfig.verticalBlockSize * 5,
//                              left: AppConfig.horizontalBlockSize * 4,
//                              child: ScaleAnimatedWidget.tween(
//                                enabled: !_hasAnimated,
//                                duration: Duration(milliseconds: 500),
//                                scaleDisabled: 0.5,
//                                scaleEnabled: 1.3,
//                                child: Container(
//                                  padding: EdgeInsets.all(15.0),
//                                  decoration: BoxDecoration(
//                                      shape: BoxShape.circle,
//                                      color: Colors.green.withOpacity(0.5)),
//                                  child: Container(
//                                    child:
//                                        Image.asset(PlunesImages.labMapImage),
//                                    height: AppConfig.verticalBlockSize * 10,
//                                    width: AppConfig.horizontalBlockSize * 30,
//                                  ),
//                                ),
//                              ))
//                          : Container(),
//                      (_start > 8)
//                          ? Positioned(
//                              top: AppConfig.verticalBlockSize * 5,
//                              right: 10.0,
//                              child: ScaleAnimatedWidget.tween(
//                                enabled: !_hasAnimated,
//                                duration: Duration(milliseconds: 500),
//                                scaleDisabled: 0.5,
//                                scaleEnabled: 1.3,
//                                child: Container(
//                                  padding: EdgeInsets.all(15.0),
//                                  decoration: BoxDecoration(
//                                      shape: BoxShape.circle,
//                                      color: Colors.green.withOpacity(0.5)),
//                                  child: Container(
//                                    child: Image.asset(
//                                        PlunesImages.hospitalMapImage),
//                                    height: AppConfig.verticalBlockSize * 8,
//                                    width: AppConfig.horizontalBlockSize * 30,
//                                  ),
//                                ),
//                              ))
//                          : Container(),
//                      (_start > 1)
//                          ? Positioned(
//                              top: AppConfig.verticalBlockSize * 30,
//                              right: 10,
//                              left: 0,
//                              child: ScaleAnimatedWidget.tween(
//                                enabled: !_hasAnimated,
//                                duration: Duration(milliseconds: 500),
//                                scaleDisabled: 0.5,
//                                scaleEnabled: 1.3,
//                                child: Container(
//                                  padding: EdgeInsets.all(15.0),
//                                  decoration: BoxDecoration(
//                                      shape: BoxShape.circle,
//                                      color: Colors.green.withOpacity(0.5)),
//                                  child: Container(
//                                    child:
//                                        Image.asset(PlunesImages.labMapImage),
//                                    height: AppConfig.verticalBlockSize * 8,
//                                    width: AppConfig.horizontalBlockSize * 30,
//                                  ),
//                                ),
//                              ))
//                          : Container(),
//                      (_start > 5)
//                          ? Positioned(
//                              top: AppConfig.verticalBlockSize * 55,
//                              right: 10.0,
//                              child: ScaleAnimatedWidget.tween(
//                                enabled: _hasAnimated,
//                                duration: Duration(milliseconds: 500),
//                                scaleDisabled: 0.5,
//                                scaleEnabled: 1.3,
//                                child: Container(
//                                  padding: EdgeInsets.all(15.0),
//                                  decoration: BoxDecoration(
//                                      shape: BoxShape.circle,
//                                      color: Colors.green.withOpacity(0.5)),
//                                  child: Container(
//                                    child:
//                                        Image.asset(PlunesImages.labMapImage),
//                                    height: AppConfig.verticalBlockSize * 8,
//                                    width: AppConfig.horizontalBlockSize * 30,
//                                  ),
//                                ),
//                              ))
//                          : Container(),
//                      (_start > 3)
//                          ? Positioned(
//                              top: AppConfig.verticalBlockSize * 45,
//                              left: 10.0,
//                              child: ScaleAnimatedWidget.tween(
//                                enabled: _hasAnimated,
//                                duration: Duration(milliseconds: 500),
//                                scaleDisabled: 0.5,
//                                scaleEnabled: 1.3,
//                                child: Container(
//                                  padding: EdgeInsets.all(15.0),
//                                  decoration: BoxDecoration(
//                                      shape: BoxShape.circle,
//                                      color: Colors.green.withOpacity(0.5)),
//                                  child: Container(
//                                    child: Image.asset(
//                                        PlunesImages.hospitalMapImage),
//                                    height: AppConfig.verticalBlockSize * 8,
//                                    width: AppConfig.horizontalBlockSize * 30,
//                                  ),
//                                ),
//                              ))
//                          : Container(),
//                      (_start > 7)
//                          ? Positioned(
//                              bottom: AppConfig.verticalBlockSize * 28,
//                              left: 0,
//                              right: 0,
//                              child: ScaleAnimatedWidget.tween(
//                                enabled: _hasAnimated,
//                                duration: Duration(milliseconds: 500),
//                                scaleDisabled: 0.5,
//                                scaleEnabled: 1.3,
//                                child: Container(
//                                  padding: EdgeInsets.all(15.0),
//                                  decoration: BoxDecoration(
//                                      shape: BoxShape.circle,
//                                      color: Colors.green.withOpacity(0.5)),
//                                  child: Container(
//                                    child:
//                                        Image.asset(PlunesImages.labMapImage),
//                                    height: AppConfig.verticalBlockSize * 10,
//                                    width: AppConfig.horizontalBlockSize * 30,
//                                  ),
//                                ),
//                              ))
//                          : Container(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: AppConfig.verticalBlockSize * 7,
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                height: AppConfig.verticalBlockSize * 20,
                                width: AppConfig.verticalBlockSize * 20,
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2,
                                    bottom: AppConfig.verticalBlockSize * 1),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
//                                    Container(
//                                      height: AppConfig.verticalBlockSize * 30,
//                                      width: AppConfig.verticalBlockSize * 30,
//                                      decoration: BoxDecoration(
//                                          gradient: LinearGradient(
//                                              colors: [
//                                                Colors.white,
//                                                Color(0xfffafafa)
//                                              ],
//                                              begin: FractionalOffset.topCenter,
//                                              end:
//                                                  FractionalOffset.bottomCenter,
//                                              stops: [0.0, 1.0],
//                                              tileMode: TileMode.clamp),
//                                          borderRadius: BorderRadius.all(
//                                            Radius.circular(
//                                                AppConfig.verticalBlockSize *
//                                                    30),
//                                          ),
//                                          border: Border.all(
//                                              color: Color(0xfffafafa),
//                                              width: 2)),
//                                    ),
                                    Align(
                                      child: AnimatedContainer(
                                        duration: Duration(seconds: 1),
                                        height: 70,
                                        width: 70,
                                        margin:
                                            EdgeInsets.only(top: _movingUnit),
                                        child: Center(
                                          child: Image.asset(
                                            plunesImages.bidActiveIcon,
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: AppConfig.verticalBlockSize * 7,
                          ),
                          Expanded(child: Container()),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.black38),
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              child: Text(
                                PlunesStrings.weAreNegotiatingBestSolution,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppConfig.largeFont,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppConfig.verticalBlockSize * 2,
                          ),
                          Center(
                            child: Text(
                              PlunesStrings.receiving,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: AppConfig.mediumFont,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Container(
                            height: AppConfig.horizontalBlockSize * 1,
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 0.2,
                                horizontal: AppConfig.horizontalBlockSize * 5),
                            child: LinearProgressIndicator(
                              value: _bidProgress,
                              backgroundColor: Color(0xffDCDCDC),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xff01d35a),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 4)),
                          _getHoldOnPopup()
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  _getHoldOnPopup() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white),
              padding: EdgeInsets.all(4),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: PlunesColors.GREENCOLOR,
                        size: 40,
                      ),
                      SizedBox(
                        width: AppConfig.horizontalBlockSize * 2,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  PlunesStrings.pleaseMakeSureText,
                                  maxLines: 3,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  _negotiate() async {
    var result = await _searchSolutionBloc.getDocHosSolution(
        widget.catalogueData,
        searchQuery: widget.searchQuery);
    if (result is RequestSuccess) {
      _searchedDocResults = result.response;
      if (_searchedDocResults == null ||
          _searchedDocResults.solution == null ||
          _searchedDocResults.solution.services == null ||
          _searchedDocResults.solution.services.isEmpty) {
        if (_searchedDocResults != null &&
            _searchedDocResults.msg != null &&
            _searchedDocResults.msg.isNotEmpty) {
          _failureCause = _searchedDocResults.msg;
        }
      } else {
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
        for (int index = 0; index < arrLength; index++) {
          await Future.delayed(Duration(milliseconds: 300));
          _markers.add(Marker(
              markerId:
                  MarkerId(_searchedDocResults.solution.services[index].sId),
              icon: hosImage2XGreenBgDesc,
              position: LatLng(
                  _searchedDocResults.solution.services[index].latitude
                          ?.toDouble() ??
                      0.0,
                  _searchedDocResults.solution.services[index].longitude
                          ?.toDouble() ??
                      0.0),
              infoWindow: InfoWindow(
                  title: _searchedDocResults.solution.services[index].name,
                  snippet:
                      "${_searchedDocResults.solution.services[index].distance?.toStringAsFixed(1)} km")));
        }
      }
    } else if (result is RequestFailed) {
      _failureCause = result.failureCause;
    }
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
      if (_mapController != null) {
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(double.parse(_user.latitude),
                    double.parse(_user.longitude)),
                zoom: minZoom,
                bearing: 10)));
      }
    });
  }
}
