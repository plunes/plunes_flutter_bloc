import 'package:shared_preferences/shared_preferences.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - Preferences class is for handling the sharedPreferences and for storing and retrieving the values from SharedPreferences.
 */

class Preferences {
  static final Preferences preferences = Preferences._internal();

  static SharedPreferences? sharedPreferences;

  factory Preferences() {
    return preferences;
  }

  Preferences._internal();

  ///Below method is to initialize the SharedPreference instance.
  instantiatePreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  ///Below method is to return the SharedPreference instance.
  SharedPreferences? getPreferenceInstance() {
    return sharedPreferences;
  }

  ///Below method is to set the string value in the SharedPreferences.
  Future setPreferencesString(String key, String stringValue) {
    return sharedPreferences!.setString(key, stringValue);
  }

  ///Below method is to get the string value from the SharedPreferences.
  String getPreferenceString(String key) {
    return sharedPreferences!.getString(key) ?? '';
  }

  ///Below method is to set the boolean value in the SharedPreferences.
  setPreferencesBoolean(String key, bool booleanValue) {
    sharedPreferences!.setBool(key, booleanValue);
  }

  ///Below method is to get the boolean value from the SharedPreferences.
  bool getPreferenceBoolean(String key) {
    return sharedPreferences!.getBool(key) ?? false;
  }

  ///Below method is to set the double value in the SharedPreferences.
  setPreferenceDouble(String key, double doubleValue) {
    sharedPreferences!.setDouble(key, doubleValue);
  }

  ///Below method is to set the double value from the SharedPreferences.
  double getPreferenceDouble(String key) {
    return sharedPreferences!.getDouble(key) ?? 0.0;
  }

  ///Below method is to set the int value in the SharedPreferences.
  setPreferenceInt(String key, int intValue) {
    sharedPreferences!.setInt(key, intValue);
  }

  ///Below method is to get the int value from the SharedPreferences.
  int getPreferenceInt(String key) {
    return sharedPreferences!.getInt(key) ?? 0;
  }

  ///Below method is to remove the received preference.
  removePreference(String key) {
    sharedPreferences!.remove(key);
  }

  ///Below method is to check the availability of the received preference .
  bool containPreference(String key) {
    if (sharedPreferences!.get(key) == null)
      return false;
    else
      return true;
  }

  ///Below method is to clear the SharedPreference.
  Future<bool> clearPreferences() async {
    return await sharedPreferences!.clear();
  }
}
