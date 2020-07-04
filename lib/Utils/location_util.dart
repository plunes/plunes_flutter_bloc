import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission/permission.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/res/StringsFile.dart';

class LocationUtil {
  static LocationUtil _instance;
  Location _location;

  LocationUtil._init() {
    _location = Location();
  }

  factory LocationUtil() {
    if (_instance == null) {
      _instance = LocationUtil._init();
    }
    return _instance;
  }

  Future<LatLng> getCurrentLatLong(BuildContext context) async {
    try {
      LocationData _currentLocation = await _location.getLocation();
      return LatLng(_currentLocation.latitude, _currentLocation.longitude);
    } catch (e) {
      if (e is PlatformException) {
        var result = await _openPermissionPopUp(context);
        if (result != null && result) {
          openSettings();
        }
      }
      return null;
    }
  }

  Future _openPermissionPopUp(BuildContext context) async {
    return await showDialog(
            context: context,
            child: CustomWidgets().showLocationPermissionPopUp(context),
            barrierDismissible: true) ??
        false;
  }

  void openSettings() async {
    await Permission.openSettings();
  }

  Future<String> getAddressFromLatLong(String latitude, String longitude,
      {bool needFullLocation = false}) async {
    String address = PlunesStrings.enterYourLocation;
    List<Address> addresses;
    try {
      final coordinates =
          new Coordinates(double.parse(latitude), double.parse(longitude));
      addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      if (addresses != null &&
          addresses.isNotEmpty &&
          addresses.first.locality != null &&
          addresses.first.locality.isNotEmpty) {
        if (addresses.first.subLocality != null &&
            addresses.first.subLocality.isNotEmpty) {
          address = addresses.first.subLocality;
        } else {
          address = addresses.first.locality;
        }
      } else {
        address = addresses.first.addressLine;
      }
    } catch (e) {}
    if (needFullLocation) {
      return addresses?.first?.addressLine ?? address;
    }
    return address;
  }
}
