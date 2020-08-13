import 'dart:convert';

import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_handler.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';

class UserManager {
  static UserManager _instance;
  CentreResponse _centreResponse;

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

  CentreResponse get centreData => _centreResponse;

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
        credits: preferences.getPreferenceString(Constants.PREF_CREDITS),
        region: preferences.getPreferenceString(Constants.REGION),
        notificationEnabled:
            preferences.getPreferenceBoolean(Constants.NOTIFICATION_ENABLED),
        isAdmin: preferences.getPreferenceBoolean(Constants.IS_ADMIN),
        isCentre: preferences.getPreferenceBoolean(Constants.IS_CENTRE),
        googleLocation:
            preferences.getPreferenceString(Constants.GOOGLE_LOCATION));
  }

  String getDeviceToken() {
    return Preferences().getPreferenceString(Constants.FIREBASE_TOKEN);
  }

  setDeviceToken(String token) {
    return Preferences().setPreferencesString(Constants.FIREBASE_TOKEN, token);
  }

  bool getNotificationStatus() {
    return Preferences().getPreferenceBoolean(Constants.NOTIFICATION_ENABLED);
  }

  setNotificationStatus(bool isOn) {
    return Preferences()
        .setPreferencesBoolean(Constants.NOTIFICATION_ENABLED, isOn);
  }

  Future<RequestState> isUserInServiceLocation(var latitude, var longitude,
      {String address, bool isFromPopup = false, String region}) async {
    if (longitude == null ||
        longitude.isEmpty ||
        latitude == null ||
        latitude.isEmpty) {
      return RequestFailed(failureCause: PlunesStrings.pleaseSelectLocation);
    }
    var result = await DioRequester().requestMethod(
      url: Urls.CHECK_LOCATION_API,
      postData: {
        "latitude": double.parse(latitude),
        "longitude": double.parse(longitude),
        "popup": isFromPopup
      },
      headerIncluded: true,
      requestType: HttpRequestMethods.HTTP_POST,
    );
    RequestState requestState;
    if (result.isRequestSucceed) {
      CheckLocationResponse checkLocationResponse =
          CheckLocationResponse.fromJson(result.response.data);
      if (checkLocationResponse != null &&
          checkLocationResponse.success != null &&
          checkLocationResponse.success) {
        setIsUserInServiceLocation(checkLocationResponse.success);
        setLanLong(latitude, longitude);
        if (address == null || address.isEmpty) {
          LocationUtil()
              .getAddressFromLatLong(
                  latitude?.toString(), longitude?.toString(),
                  needFullLocation: true)
              .then((addr) {
            setAddress(addr);
          });
        }
      } else {
        setIsUserInServiceLocation(false);
      }
      requestState = RequestSuccess(response: checkLocationResponse);
    } else {
      requestState = RequestFailed(failureCause: result.failureCause);
    }
    setAddress(address);
    setRegion(region);
    return requestState;
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
//      print(_loginPost == null);
      if (shouldSaveInfo) {}
      return RequestSuccess(response: _loginPost);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getGenerateOtp(String mobileNumber,
      {bool iFromForgotPassword = false}) async {
    String key = iFromForgotPassword ? 'userId' : 'mobileNumber';
    var result = await DioRequester().requestMethod(
        url: iFromForgotPassword
            ? Urls.FORGOT_PASSWORD_URL
            : Urls.GENERATE_OTP_URL,
        headerIncluded: false,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {key: mobileNumber});
    if (result.isRequestSucceed) {
      GetOtpModel _getOtp = GetOtpModel.fromJson(result.response.data);
      return RequestSuccess(response: _getOtp);
    } else {
      return RequestFailed(response: result.failureCause);
    }
  }

  Future<RequestState> getVerifyOtp(String mobileNumber, var otp,
      {bool iFromForgotPassword = false}) async {
    var queryParam;
    if (iFromForgotPassword) {
      queryParam = {'mobileNumber': mobileNumber, "otp": otp, "reset": true};
    } else {
      queryParam = {'mobileNumber': mobileNumber, "otp": otp};
    }
    var result = await DioRequester().requestMethod(
        url: Urls.VERIFY_OTP_URL,
        headerIncluded: false,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: queryParam);
    if (result.isRequestSucceed) {
      VerifyOtpResponse _verifyOtp =
          VerifyOtpResponse.fromJson(result.response.data);
//      print(_verifyOtp);
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
//        print("user, ${loginPost.user.toString()}");
        Bloc().saveDataInPreferences(loginPost, null, null);
      } catch (err) {
//        print('error $err');
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
      SpecialityOuterModel signUpSpecialityModel =
          SpecialityOuterModel.fromJson(result.response.data);
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

  Future<RequestState> saveUpdateFirebaseToken(String token) async {
    String savedToken = getDeviceToken();
    if (savedToken == null || savedToken.isEmpty) {
      return RequestFailed();
    }
    var result = await DioRequester().requestMethod(
        url: Urls.UPDATE_TOKEN,
        headerIncluded: true,
        postData: {"newToken": token, "oldToken": savedToken},
        requestType: HttpRequestMethods.HTTP_POST);
    if (result.isRequestSucceed) {
      setDeviceToken(token);
      return RequestSuccess();
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> turnOnOffNotification(bool isOn) async {
    var result = await DioRequester().requestMethod(
        url: Urls.NOTIFICATION_SWITCH,
        queryParameter: {"deviceId": getDeviceToken(), "op": isOn},
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true);
    if (result.isRequestSucceed) {
      setNotificationStatus(isOn);
      return RequestSuccess();
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getUserSpecificSpecialities(String userId) async {
    var result = await DioRequester().requestMethod(
        requestType: HttpRequestMethods.HTTP_GET,
        url: Urls.GET_USER_SPECIFIC_SPECIALITY,
        headerIncluded: true,
        queryParameter: {"professionalId": userId});
    if (result.isRequestSucceed) {
      List<SpecialityModel> specialityList = new List();
      SpecialityOuterModel signUpSpecialityModel =
          SpecialityOuterModel.fromJson(result.response.data);
      if (signUpSpecialityModel != null &&
          signUpSpecialityModel.data != null &&
          signUpSpecialityModel.data.isNotEmpty) {
        specialityList = signUpSpecialityModel.data;
      }
      return RequestSuccess(response: specialityList);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getSpecialityRelatedService(
      String userId, String specialityId) async {
    var result = await DioRequester().requestMethod(
        queryParameter: {
          "professionalId": userId,
          "specialityId": specialityId
        },
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true,
        url: Urls.GET_SPECIALITY_RELATED_SERVICE);
    if (result.isRequestSucceed) {
      List<CatalogueData> _serviceList = [];
      if (result.response.data['data'] != null) {
        result.response.data['data'].forEach((v) {
          _serviceList.add(CatalogueData.fromJson(v));
        });
      }
      return RequestSuccess(response: _serviceList);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> resetPassword(
      String phoneNumber, String otp, String password) async {
    var result = await DioRequester().requestMethod(
        url: Urls.RESET_PASSWORD_URL,
        postData: {"userId": phoneNumber, "otp": otp, "password": password},
        requestType: HttpRequestMethods.HTTP_PUT,
        headerIncluded: false);
    if (result.isRequestSucceed) {
      return RequestSuccess();
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> changePassword(
      String oldPassword, String newPassword) async {
    var result = await DioRequester().requestMethod(
        url: Urls.CHANGE_PASSWORD_URL,
        postData: {"oldPassword": oldPassword, "newPassword": newPassword},
        requestType: HttpRequestMethods.HTTP_PATCH,
        headerIncluded: true);
    if (result.isRequestSucceed) {
      return RequestSuccess();
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getHelplineNumber() async {
    var result = await DioRequester().requestMethod(
        url: Urls.GET_HELPLINE_NUMBER_URL,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      HelpLineNumberModel _helpNumberModel =
          HelpLineNumberModel.fromJson(result.response.data);
      return RequestSuccess(response: _helpNumberModel);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> checkUserExistence(String phoneNumber) async {
    var result = await DioRequester().requestMethod(
        url: urls.checkUserExistence + phoneNumber,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: result.response.data);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> login(String phoneNumber, String password) async {
    var result = await DioRequester().requestMethod(
        url: urls.login,
        requestType: HttpRequestMethods.HTTP_POST,
        postData: {
          'mobileNumber': phoneNumber,
          'password': password,
          'deviceId': Constants.DEVICE_TOKEN
        });
    if (result.isRequestSucceed) {
      return RequestSuccess(response: LoginPost.fromJson(result.response.data));
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> signUp(Map<String, dynamic> body) async {
    var result = await DioRequester().requestMethod(
        url: urls.signUp,
        requestType: HttpRequestMethods.HTTP_POST,
        postData: body);
    if (result.isRequestSucceed) {
      return RequestSuccess(response: LoginPost.fromJson(result.response.data));
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> getAdminSpecificData() async {
    var result = await DioRequester().requestMethod(
        url: Urls.GET_CENTRES_DATA,
        headerIncluded: true,
        requestType: HttpRequestMethods.HTTP_GET);
    if (result.isRequestSucceed) {
      CentreResponse centreResponse;
      try {
        centreResponse = CentreResponse.fromJson(result.response.data);
      } catch (e) {
        print("error $e");
      }
      _centreResponse = centreResponse;
      return RequestSuccess(response: centreResponse);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  void clear() {
    _centreResponse = null;
  }

  Future<RequestState> getRateAndReviews(String profId,
      {int initialIndex = 0}) async {
    var result = await DioRequester().requestMethod(
        url: Urls.RATE_AND_REVIEW,
        requestType: HttpRequestMethods.HTTP_GET,
        queryParameter: {"professionalId": profId},
        headerIncluded: true);
    if (result.isRequestSucceed) {
      List<RateAndReview> _list = [];
      Iterable items = result.response.data;
      _list =
          items?.map((e) => RateAndReview.fromJson(e))?.toList(growable: true);
      return RequestSuccess(response: _list);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  void setRegion(String region) {
    if (region != null && region.isNotEmpty) {
      Preferences().setPreferencesString(Constants.REGION, region);
    }
  }

  void setAddress(String address) {
    if (address != null && address.isNotEmpty) {
      Preferences().setPreferencesString(Constants.GOOGLE_LOCATION, address);
    }
  }

  bool getWidgetShownStatus(String key) {
    return Preferences().getPreferenceBoolean(key);
  }

  setWidgetShownStatus(String key, {bool status = true}) {
    return Preferences().setPreferencesBoolean(key, status);
  }
}
