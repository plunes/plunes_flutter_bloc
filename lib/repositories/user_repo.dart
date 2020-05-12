import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_handler.dart';
import 'package:plunes/requester/request_states.dart';
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

  bool getIsUserInServiceLocation() {
    return Preferences().getPreferenceBoolean(Constants.IS_IN_SERVICE_LOCATION);
  }

  setIsUserInServiceLocation(bool isInServiceLocation) {
    return Preferences().setPreferencesBoolean(
        Constants.IS_IN_SERVICE_LOCATION, isInServiceLocation);
  }

  setLanLong(var lat, var long) {
    Preferences().setPreferencesString(Constants.LATITUDE, lat.toString());
    Preferences().setPreferencesString(Constants.LONGITUDE, long.toString());
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

  Future<RequestOutput> isUserInServiceLocation(
      var latitude, var longitude) async {
    if (longitude == null ||
        longitude.isEmpty ||
        latitude == null ||
        latitude.isEmpty) {
      return RequestOutput(failureCause: PlunesStrings.pleaseSelectLocation);
    }
    var result = await DioRequester().requestMethod(
      url: Urls.CHECK_LOCATION_API,
      postData: {
        "latitude": double.parse(latitude),
        "longitude": double.parse(longitude)
      },
      headerIncluded: true,
      requestType: HttpRequestMethods.HTTP_POST,
    );
    if (result.isRequestSucceed) {
      if (result.response.data != null && result.response.data) {
        setIsUserInServiceLocation(result.response.data);
        setLanLong(latitude, longitude);
      } else {
        setIsUserInServiceLocation(false);
      }
    }
    return result;
  }

  Future<RequestState> getUserProfile(String userId,
      {bool shouldSaveInfo}) async {
    var result = await DioRequester().requestMethod(
        url: urls.userBaseUrl,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {"userId": userId});
    if (result.isRequestSucceed) {
      LoginPost _loginPost = LoginPost.fromJson(result.response.data);
      print(_loginPost == null);
      if (shouldSaveInfo) {}
      return RequestSuccess(response: _loginPost);
    } else {
      return RequestFailed(response: result.failureCause);
    }
  }

  Future<RequestState> getGenerateOtp(String mobileNumber) async {
    var result = await DioRequester().requestMethod(
        url: Urls.GENERATE_OTP_URL,
        headerIncluded: false,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {'mobileNumber': mobileNumber});
    if (result.isRequestSucceed) {
      GetOtpModel _getOtp = GetOtpModel.fromJson(result.response.data);
      return RequestSuccess(response: _getOtp);
    } else {
      return RequestFailed(response: result.failureCause);
    }
  }

  Future<RequestState> getVerifyOtp(String mobileNumber, int otp) async {
    var result = await DioRequester().requestMethod(
        url: Urls.VERIFY_OTP_URL,
        headerIncluded: false,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {'mobileNumber': mobileNumber, "otp": otp});
    if (result.isRequestSucceed) {
      VerifyOtpResponse _verifyOtp = VerifyOtpResponse.fromJson(result.response.data);
      print(_verifyOtp);
      return RequestSuccess(response: _verifyOtp);
    } else {
      return RequestFailed(response: result.failureCause);
    }
  }

  Future<RequestState> updateUserData(Map<String, dynamic> userData) async {
    var result = await DioRequester().requestMethod(
      url: "user/",
      headerIncluded: true,
      requestType: HttpRequestMethods.HTTP_PUT,
      postData: userData,
    );
    if (result.isRequestSucceed) {
      LoginPost loginPost;
      try {
        loginPost = LoginPost.fromJson(result.response.data);
        print("user, ${loginPost.user.toString()}");
        Bloc().saveDataInPreferences(loginPost, null, null);
      } catch (err) {
        print('error $err');
      }
      return RequestSuccess(response: loginPost);
    } else {
      return RequestFailed(response: result.failureCause);
    }
  }

  Future<RequestState> getSpecialities() async {
    var result = await DioRequester().requestMethod(
      headerIncluded: true,
      requestType: HttpRequestMethods.HTTP_GET,
      url: Urls.GET_SPECIALITIES_URL,
    );
    if (result.isRequestSucceed) {
      List<SpecialityModel> specialityList = new List();
      SignUpSpecialityModel signUpSpecialityModel =
          SignUpSpecialityModel.fromJson(result.response.data);
      if (signUpSpecialityModel != null &&
          signUpSpecialityModel.data != null &&
          signUpSpecialityModel.data.isNotEmpty) {
        CommonMethods.catalogueLists = specialityList;
        CommonMethods.catalogueLists = signUpSpecialityModel.data;
        specialityList = signUpSpecialityModel.data;
      }
      return RequestSuccess(response: specialityList);
    } else {
      return RequestFailed(response: result.failureCause);
    }
  }
}
