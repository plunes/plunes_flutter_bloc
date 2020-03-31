import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';

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

  Future<LatLng> getCurrentLatLong() async {
    try {
      LocationData _currentLocation = await _location.getLocation();
      print("asdsds");
      return LatLng(_currentLocation.latitude, _currentLocation.longitude);
    } catch (e) {
      print("exception in $e");
      return null;
    }
  }
}
