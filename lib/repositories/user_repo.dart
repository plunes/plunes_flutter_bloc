import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_handler.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class UserManager {
  static UserManager _instance;

  UserManager._init();

  factory UserManager() {
    if (_instance == null) {
      _instance = UserManager._init();
    }
    return _instance;
  }

  User getUserDetails() {
    Preferences preferences = Preferences();
    return User(
        gender: preferences.getPreferenceString(Constants.PREF_GENDER),
        email: preferences.getPreferenceString(Constants.PREF_USER_EMAIL),
        mobileNumber:
            preferences.getPreferenceString(Constants.PREF_USER_PHONE_NUMBER),
        college: preferences.getPreferenceString(Constants.PREF_COLLEGE),
        name: preferences.getPreferenceString(Constants.PREF_USERNAME),
        imageUrl: preferences.getPreferenceString(Constants.PREF_USER_IMAGE),
        experience: preferences.getPreferenceString(Constants.PREF_EXPERIENCE),
        latitude: preferences.getPreferenceString(Constants.LATITUDE),
        longitude: preferences.getPreferenceString(Constants.LONGITUDE),
        userType: preferences.getPreferenceString(Constants.PREF_USER_TYPE),
        qualification:
            preferences.getPreferenceString(Constants.PREF_QUALIFICATION),
        registrationNumber:
            preferences.getPreferenceString(Constants.PREF_PROF_REG_NUMBER),
        referralCode:
            preferences.getPreferenceString(Constants.PREF_REFERRAL_CODE),
        address: preferences.getPreferenceString(Constants.PREF_USER_LOCATION),
        uid: preferences.getPreferenceString(Constants.PREF_USER_ID),
        accessToken: preferences.getPreferenceString(Constants.ACCESS_TOKEN),
        practising: preferences.getPreferenceString(Constants.PREF_PRACTISING),
        about: preferences.getPreferenceString(Constants.PREF_INTRODUCTION),
        birthDate: preferences.getPreferenceString(Constants.PREF_DOB),
        coverImageUrl:
            preferences.getPreferenceString(Constants.PREF_USER_BANNER_IMAGE),
        credits: preferences.getPreferenceString(Constants.PREF_CREDITS));
  }

  Future<RequestOutput> isUserInServiceLocation() async {
    User _user = getUserDetails();
    print(_user.toString());
    if (_user.longitude == null ||
        _user.longitude.isEmpty ||
        _user.latitude == null ||
        _user.latitude.isEmpty) {
      return RequestOutput(failureCause: PlunesStrings.pleaseSelectLocation);
    }
    return await DioRequester().requestMethod(
      url: Urls.CHECK_LOCATION_API,
      postData: {
        "latitude": double.parse(_user.latitude),
        "longitude": double.parse(_user.longitude)
      },
      requestType: HttpRequestMethods.HTTP_POST,
    );
  }
}
