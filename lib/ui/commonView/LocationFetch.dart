import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as loc;
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Urls.googleApiKey);

class LocationFetch extends BaseActivity {
  static const tag = '/location_fetch';

  @override
  _LocationFetchState createState() => _LocationFetchState();
}

class _LocationFetchState extends State<LocationFetch> {
  final landMarkController = new TextEditingController();
  final houseController = new TextEditingController();
  final locationController = TextEditingController();

  GoogleMapController _mapController;

  Map<MarkerId, Marker> marker = <MarkerId, Marker>{};
  var location = new loc.Location(), globalHeight, globalWidth;
  List _coordinateList = new List();
  String latitude = '0.0', longitude = '0.0', address = '';
  bool  _isAddFetch = false;
  Preferences _preferences;
  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void getLocation() async {
    _preferences = new Preferences();
    String lat = _preferences.getPreferenceString(Constants.LATITUDE);
    String lng = _preferences.getPreferenceString(Constants.LONGITUDE);
    final coordinates = new Coordinates(double.parse(lat), double.parse(lng));
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var addr = addresses.first;
    String full_address = addr.addressLine;
    latitude = lat;
    longitude = lng;
    locationController.text = full_address;
    setState(() {
    });
  }

   saveLatLang() async {
    _preferences.setPreferencesString(Constants.LATITUDE, latitude);
    _preferences.setPreferencesString(Constants.LONGITUDE, longitude);
    String home = houseController.text;
    String land = landMarkController.text;
    print(home + "," + land + "," + address + "," + latitude + "," + longitude);
    Navigator.of(context).pop(home + ":" + land + ":" + locationController.text + ":" + latitude + ":" + longitude);

//    if (houseController.text == '' && landMarkController.text == '') {
//      Navigator.of(context).pop(address);
//    } else if (houseController.text != '' && landMarkController.text == '') {
//      Navigator.of(context).pop(home + address);
//    } else if (houseController.text == '' && landMarkController.text != '') {
//      Navigator.of(context).pop(land + address);
//    } else {
//      Navigator.of(context).pop(home + land + address);
//    }
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () => CommonMethods.hideSoftKeyboard(),
        child: Container(
                child: Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              height: globalHeight / 2,
                              child: getGoogleMapView(),
                            ),
                            widget.getBlackBackButton(context),
                            widget.getBlackLocationIcon(globalHeight / 2),
                          ],
                        ),
                      ],
                    ),
                    getBottomView()
                  ],
                ),
              )
      ),
    );
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
            widget.createTextViews(stringsFile.setLocation, 16.0, colorsFile.black0, TextAlign.left, FontWeight.bold),
            widget.getSpacer(0.0, 20.0),
            createTextField(locationController, stringsFile.address, TextInputType.text, TextCapitalization.none, false, ''),
            createTextField(houseController, stringsFile.houseFlatNo, TextInputType.text, TextCapitalization.none, true, ''),
            widget.getSpacer(0.0, 20.0),
            createTextField(landMarkController, stringsFile.landMark, TextInputType.text, TextCapitalization.none, true, ''),
            widget.getSpacer(0.0, 20.0),
            widget.getDefaultButton(stringsFile.proceed, globalWidth - 40,42, saveLatLang),
            widget.getSpacer(0.0, 20.0),
          ],
        ),
      ),
    );
  }

  Widget createTextField(TextEditingController controller, String placeHolder, TextInputType inputType, TextCapitalization textCapitalization, bool fieldFlag, String errorMsg) {
    return InkWell(
      onTap: () async {
        if (controller == locationController) {
          Prediction p = await PlacesAutocomplete.show(context: context, apiKey: Urls.googleApiKey);
          displayPrediction(p);
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
              cursorColor: Color(CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
              enabled: (controller == locationController) ? false : true,
              style: TextStyle(
                fontSize: 15.0,
              ),
              decoration: widget.myInputBoxDecoration(colorsFile.defaultGreen, colorsFile.lightGrey1, placeHolder, errorMsg, fieldFlag, controller, null))),
    );
  }

  Widget getGoogleMapView() {
    return GoogleMap(
      onTap: (LatLng latlng) {
        print(latlng.latitude.toString() + "," + latlng.longitude.toString());
      },
      mapType: MapType.normal,
      myLocationButtonEnabled: true,
      rotateGesturesEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: true,
      markers: Set<Marker>.of(marker.values),
      onCameraMoveStarted: () {
        print("Started to move");
      },
      onCameraIdle: () async {
        if (_coordinateList.length != 0) {
          _isAddFetch = true;
          Coordinates coordinates = _coordinateList[_coordinateList.length - 1];
          latitude = coordinates.latitude.toString();
          longitude = coordinates.longitude.toString();
          var addresses = await Geocoder.local.findAddressesFromCoordinates(_coordinateList[_coordinateList.length - 1]);
          var addr = addresses.first;
          String full_address = addr.addressLine;
          locationController.text = full_address;
          _isAddFetch = false;
          setState(() {});
        }
      },
      onCameraMove: ((_p) async {
        _coordinateList.add(Coordinates(_p.target.latitude, _p.target.longitude));
      }),
      initialCameraPosition: CameraPosition(
        target: LatLng(double.parse(latitude), double.parse(longitude)),
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      setState(() {
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(zoom: 15, target: LatLng(lat, lng)),
          ),
        );
        latitude = lat.toString();
        longitude = lng.toString();
        locationController.text = detail.result.formattedAddress;
      });
    }
  }
}
