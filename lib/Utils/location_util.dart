import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:permission/permission.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/StringsFile.dart';

class LocationUtil {
  static LocationUtil? _instance;
  late Location _location;

  LocationUtil._init() {
    _location = Location(latitude: 23.23, longitude: 74.3434523, timestamp: DateTime.now());
  }

  factory LocationUtil() {
    if (_instance == null) {
      _instance = LocationUtil._init();
    }
    return _instance!;
  }

  Future<LatLng?> getCurrentLatLong(BuildContext? context,
      {bool shouldOpenPopup = true}) async {
    try {
      // LocationData _currentLocation = await _location.();
      return LatLng(_location.latitude, _location.longitude);
    } catch (e) {
      if ((e is PlatformException) && shouldOpenPopup) {
        var result = await _openPermissionPopUp(context!);
        if (result != null && result) {
          openSettings();
        }
      }
      return null;
    }
  }

  Future _openPermissionPopUp(BuildContext context) async {
    return await showDialog(context: context,
        builder: (context) => CustomWidgets().showLocationPermissionPopUp(context),
    barrierDismissible: true) ?? false;
    // return await showDialog(
    //         context: context,
    //         child: CustomWidgets().showLocationPermissionPopUp(context),
    //         barrierDismissible: true) ?? false;
  }

  void openSettings() async {
    await openAppSettings();
   // await Permission.openSettings();
  }

  Future<String?> getAddressFromLatLong(String? latitude, String? longitude,
      {bool needFullLocation = false}) async {

    print("lat_long:${latitude},${longitude}");

    String? address = PlunesStrings.enterYourLocation;
    var userObj = UserManager().getUserDetails();
    if (needFullLocation &&
        userObj.googleLocation != null &&
        userObj.googleLocation!.isNotEmpty) {
      return userObj.googleLocation;
    }
    if (!(needFullLocation) &&
        userObj.region != null &&
        userObj.region!.isNotEmpty) {
      return userObj.region;
    }
    List<Placemark>? addresses;
    try {
      // final coordinates = new Coordinates(double.parse(latitude), double.parse(longitude));
      addresses =
      // await Geocoder.local.findAddressesFromCoordinates(coordinates);
      await GeocodingPlatform.instance.placemarkFromCoordinates(double.parse(latitude!), double.parse(longitude!));


      if (addresses != null &&
          addresses.isNotEmpty &&
          addresses.first.locality != null &&
          addresses.first.locality!.isNotEmpty) {
        if (addresses.first.subLocality != null &&
            addresses.first.subLocality!.isNotEmpty) {
          address = addresses.first.subLocality;
          UserManager().setRegion(address);
        } else {
          address = addresses.first.locality;
          UserManager().setRegion(address);
        }
      } else {
        address = addresses.first.name;
      }
    } catch (e) {}
    if (needFullLocation) {
      UserManager().setAddress(addresses?.first?.name);
      return addresses?.first?.name ?? address;
    }
    return address;
  }

  Future<String?> getFullAddress(String latitude, String longitude) async {
    List<Placemark> addresses;
    String? address = "";
    try {
      // final coordinates = new Coordinates(double.parse(latitude), double.parse(longitude));
      addresses =
          await GeocodingPlatform.instance.placemarkFromCoordinates(double.parse(latitude), double.parse(longitude));
      // Geocoder.local.findAddressesFromCoordinates(coordinates);
      if (addresses != null &&
          addresses.isNotEmpty &&
          addresses.first.name != null &&
          addresses.first.name!.isNotEmpty) {
        address = addresses.first.name;
        UserManager().setAddress(addresses.first.name);
      }
    } catch (e) {}
    return address;
  }
}
