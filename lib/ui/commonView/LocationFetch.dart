import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as loc;
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

//GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Urls.googleApiKey);

// ignore: must_be_immutable
class LocationFetch extends BaseActivity {
  final bool shouldSaveLocation;

  LocationFetch({this.shouldSaveLocation});

  static const tag = '/location_fetch';

  @override
  _LocationFetchState createState() => _LocationFetchState();
}

class _LocationFetchState extends State<LocationFetch> {
  final landMarkController = new TextEditingController();
  final houseController = new TextEditingController();
  final locationController = TextEditingController();
  final regionController = TextEditingController();

  GoogleMapController _mapController;

  Set<Marker> marker = <Marker>{};
  var location = new loc.Location(), globalHeight, globalWidth;
  List _coordinateList = new List();

//  final double lat = 28.4594965, long = 77.0266383;
  String latitude = '0.0', longitude = '0.0', address = '';
  bool _isAddFetch = false, _isSettingLocationFromPlacesApi = false;
  Preferences _preferences;
  Completer<GoogleMapController> _completer = Completer();
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void getLocation() async {
    _preferences = new Preferences();
    String lat = _preferences.getPreferenceString(Constants.LATITUDE);
    String lng = _preferences.getPreferenceString(Constants.LONGITUDE);
    if (lat == null ||
        lng == null ||
        lat.isEmpty ||
        lng.isEmpty ||
        lat == "0.0" ||
        lng == "0.0" ||
        lat == "0" ||
        lng == "0") {
      await Future.delayed(Duration(milliseconds: 400));
      var loc = await LocationUtil().getCurrentLatLong(_context);
      if (loc != null) {
        _setLocation(loc.latitude.toString(), loc.longitude.toString());
      } else {
        getLocation();
      }
    } else {
      _setLocation(lat, lng);
    }
  }

  _setLocation(final String lat, final String lng) async {
    if (lat != null && lat.isNotEmpty && lng != null && lng.isNotEmpty) {
      latitude = lat;
      longitude = lng;
      print("lat $lat long $lng");
      print("lat $latitude long $longitude");
      final coordinates = new Coordinates(double.parse(lat), double.parse(lng));
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var addr = addresses?.first;
      String full_address = addr?.addressLine;
      locationController.text = full_address;
      _setRegionAddress(addr);
      if (lat != null && lng != null) {
        _setMarker(double.parse(lat), double.parse(lng));
        _animateCamera();
      }
    }
    if (mounted) setState(() {});
  }

  saveLatLang() async {
    if (widget.shouldSaveLocation == null) {
      await _preferences.setPreferencesString(Constants.LATITUDE, latitude);
      await _preferences.setPreferencesString(Constants.LONGITUDE, longitude);
    }
    String home = houseController.text;
    String land = landMarkController.text;
//    print(home + "," + land + "," + address + "," + latitude + "," + longitude);
    Navigator.of(context).pop(home +
        ":" +
        land +
        ":" +
        locationController.text +
        ":" +
        latitude +
        ":" +
        longitude +
        ":" +
        regionController.text);
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(body: Builder(builder: (context) {
      _context = context;
      return GestureDetector(
          onTap: () => CommonMethods.hideSoftKeyboard(),
          child: Container(
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top),
                            height: globalHeight / 2,
                            child: getGoogleMapView(),
                          ),
                          widget.getBlackBackButton(context),
                          // widget.getBlackLocationIcon(globalHeight / 2),
                        ],
                      ),
                    ),
                  ],
                ),
                getBottomView()
              ],
            ),
          ));
    }));
  }

  Widget getBottomView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        height: globalHeight / 2,
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: <Widget>[
            widget.getLinearProgressView(_isAddFetch),
            widget.getSpacer(0.0, 10.0),
            widget.createTextViews(plunesStrings.setLocation, 16.0,
                colorsFile.black0, TextAlign.left, FontWeight.w600),
            widget.getSpacer(0.0, 20.0),
            createTextField(locationController, plunesStrings.address,
                TextInputType.text, TextCapitalization.none, false, ''),
            createTextField(houseController, plunesStrings.houseFlatNo,
                TextInputType.text, TextCapitalization.none, true, ''),
            widget.getSpacer(0.0, 20.0),
            createTextField(landMarkController, plunesStrings.landMark,
                TextInputType.text, TextCapitalization.none, true, ''),
            widget.getSpacer(0.0, 20.0),
            Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 30,
                  right: AppConfig.horizontalBlockSize * 30),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onTap: saveLatLang,
                child: CustomWidgets().getRoundedButton(
                    plunesStrings.proceed,
                    AppConfig.horizontalBlockSize * 8,
                    PlunesColors.GREENCOLOR,
                    AppConfig.horizontalBlockSize * 0,
                    AppConfig.verticalBlockSize * 1.2,
                    PlunesColors.WHITECOLOR),
              ),
            ),
            widget.getSpacer(0.0, 20.0),
          ],
        ),
      ),
    );
  }

  Widget createTextField(
      TextEditingController controller,
      String placeHolder,
      TextInputType inputType,
      TextCapitalization textCapitalization,
      bool fieldFlag,
      String errorMsg) {
    return InkWell(
      onTap: () async {
        try {
          if (controller == locationController) {
            Prediction p = await PlacesAutocomplete.show(
                context: context,
                apiKey: Urls.googleApiKey,
                onError: (error) {
//                  print("error ${error.errorMessage}");
                });
            displayPrediction(p);
          }
        } catch (e) {
//          print(e);
        }
      },
      child: Container(
          padding: EdgeInsets.zero,
          width: MediaQuery.of(context).size.width,
          child: TextField(
              maxLines: controller == locationController ? 3 : null,
              textCapitalization: textCapitalization,
              keyboardType: inputType,
              textInputAction: TextInputAction.next,
              controller: controller,
              cursorColor: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
              enabled: (controller == locationController) ? false : true,
              style: TextStyle(
                fontSize: 15.0,
              ),
              decoration: widget.myInputBoxDecoration(
                  colorsFile.defaultGreen,
                  colorsFile.lightGrey1,
                  placeHolder,
                  errorMsg,
                  fieldFlag,
                  controller,
                  null))),
    );
  }

  Widget getGoogleMapView() {
    return GoogleMap(
      onTap: (LatLng latlng) {
//        print(latlng.latitude.toString() + "," + latlng.longitude.toString());
      },
      mapType: MapType.normal,
      myLocationButtonEnabled: true,
      rotateGesturesEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: true,
      markers: marker,
      onCameraMoveStarted: () {
//        print("Started to move");
      },
      onCameraIdle: () async {
        if (!_completer.isCompleted) {
          return;
        }
        try {
          if (_coordinateList.length != 0 && !_isSettingLocationFromPlacesApi) {
            _isAddFetch = true;
            Coordinates coordinates =
                _coordinateList[_coordinateList.length - 1];
            _setMarker(coordinates?.latitude, coordinates?.longitude);
            latitude = coordinates.latitude?.toString();
            longitude = coordinates.longitude?.toString();
            if (latitude == '0.0' && longitude == '0.0') {
              return;
            }
//            print(
//                "${_coordinateList[_coordinateList.length - 1]}lat is $latitude long is $longitude");
            var addresses = await Geocoder.local.findAddressesFromCoordinates(
                _coordinateList[_coordinateList.length - 1]);
            var addr = addresses.first;
            _setRegionAddress(addr);
            String full_address = addr.addressLine;
            locationController.text = full_address;
            _isAddFetch = false;
            if (mounted) setState(() {});
          }
        } catch (e) {}
      },
      onCameraMove: ((_p) async {
        _coordinateList
            .add(Coordinates(_p.target.latitude, _p.target.longitude));
      }),
      initialCameraPosition: CameraPosition(
        target: LatLng(double.parse(latitude ?? "28.4594965"),
            double.parse(longitude ?? "77.0266383")),
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        if (!_completer.isCompleted) {
          _mapController = controller;
          _completer.complete(_mapController);
        }
      },
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    try {
      if (p != null) {
//      PlacesDetailsResponse detail =
//          await _places.getDetailsByPlaceId(p.placeId);
        final query = p.description;
        var addresses = await Geocoder.local.findAddressesFromQuery(query);
        var first = addresses.first;
        _setRegionAddress(first);
//        print("${first.addressLine} : ${first.coordinates}");
        if (first == null ||
            first.addressLine == null ||
            first.coordinates == null) {
          return;
        }
        _isSettingLocationFromPlacesApi = true;
        double lat = first.coordinates.latitude;
        double lng = first.coordinates.longitude;
        _setMarker(lat, lng);
        latitude = lat?.toString();
        longitude = lng?.toString();
        if (mounted)
          setState(() {
            _animateCamera();
            locationController.text = first.addressLine;
          });
        Future.delayed(Duration(milliseconds: 1500)).then((value) {
          _coordinateList = [];
          _isSettingLocationFromPlacesApi = false;
        });
      }
    } catch (e) {}
  }

  _setMarker(double lat, double lon) {
    if (lat != null && lon != null) {
      marker.add(Marker(
          markerId: MarkerId("currentLocation"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(lat, lon)));
    }
  }

  void _animateCamera() {
    if (latitude != null &&
        latitude.isNotEmpty &&
        longitude != null &&
        longitude.isNotEmpty &&
        _completer.isCompleted) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 12,
              target: LatLng(double.parse(latitude), double.parse(longitude))),
        ),
      );
    }
  }

  void _setRegionAddress(Address address) {
    if (address != null) {
      if (address != null &&
          address.locality != null &&
          address.locality.isNotEmpty) {
        if (address.subLocality != null && address.subLocality.isNotEmpty) {
          regionController.text = address.subLocality;
        } else {
          regionController.text = address.locality;
        }
      } else {
        regionController.text = address.addressLine;
      }
    }
  }
}
