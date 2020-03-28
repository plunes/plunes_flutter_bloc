import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/resources/repository.dart';
import 'package:plunes/ui/afterLogin/HomeScreen.dart';
import 'package:rxdart/rxdart.dart';

final bloc = Bloc();

class Bloc {
  final _repository = Repository();

  var _catalogueFetcher = PublishSubject<CatalogueList>();
  var loginResponseFetcher = PublishSubject<LoginPost>();
  var _checkUserFetcher = PublishSubject<dynamic>();
  var _checkUserOTP = PublishSubject<dynamic>();
  var __changePasswordFetcher = PublishSubject<dynamic>();
  var _helpApiFetcher = PublishSubject<dynamic>();
  var notificationApiFetcher = PublishSubject<AllNotificationsPost>();

  var _registrationResponseFetcher = PublishSubject<LoginPost>();
  var _logout = PublishSubject<dynamic>();
  var _updateProfileFetcher = PublishSubject<dynamic>();
  final StreamController<dynamic> _preferenceFetcher =
      new StreamController.broadcast();
  var _profileResponseFetcher = PublishSubject<LoginPost>();

  Observable<CatalogueList> get allCatalogue => _catalogueFetcher.stream;

  Observable<LoginPost> get loginData => loginResponseFetcher.stream;

  Observable<LoginPost> get profileData => _profileResponseFetcher.stream;

  Observable<dynamic> get isUserExist => _checkUserFetcher.stream;

  Observable<dynamic> get userOTP => _checkUserOTP.stream;

  Observable<dynamic> get changePasswordResult =>
      __changePasswordFetcher.stream;

  Observable<LoginPost> get registrationResult =>
      _registrationResponseFetcher.stream;

  Observable<dynamic> get logout => _logout.stream;

  Observable<dynamic> get updateProfileFetcher => _updateProfileFetcher.stream;

  Stream<dynamic> get preferenceFetcher => _preferenceFetcher.stream;

  Observable<dynamic> get helpApiFetcher => _helpApiFetcher.stream;

  Observable<AllNotificationsPost> get notificationApiFetcherList =>
      notificationApiFetcher.stream;

  final StreamController<dynamic> _deleteListenerFetcher =
      new StreamController.broadcast();

  Stream<dynamic> get deleteListenerFetcher => _deleteListenerFetcher.stream;

  fetchCatalogue(BuildContext context, DialogCallBack callBack) async {
    _catalogueFetcher = PublishSubject<CatalogueList>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) {
      if (isConnected) {
        CommonMethods.getPreferenceValues(Constants.ACCESS_TOKEN)
            .then((dynamic _token) async {
          CatalogueList itemModel = await _repository.fetchCatalogue(context);
          _catalogueFetcher.sink.add(itemModel);
        });
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  checkUserExistence(
      BuildContext context, DialogCallBack callBack, String value) async {
    _checkUserFetcher = PublishSubject<dynamic>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) async {
      if (isConnected) {
        dynamic success = await _repository.fetchUserExistence(context, value);
        _checkUserFetcher.sink.add(success);
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  sendOTP(BuildContext context, DialogCallBack callBack, String url) async {
    _checkUserOTP = PublishSubject<dynamic>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) async {
      if (isConnected) {
        _checkUserOTP.sink.add(await _repository.fetchUserOTP(context, url));
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  loginRequest(BuildContext context, DialogCallBack callBack, String phone,
      String password) async {
    loginResponseFetcher = PublishSubject<LoginPost>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) async {
      if (isConnected) {
        loginResponseFetcher.sink
            .add(await _repository.fetchLoginData(context, phone, password));
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  changePassword(BuildContext context, DialogCallBack callBack, String phone,
      String password) async {
    __changePasswordFetcher = PublishSubject<dynamic>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) async {
      if (isConnected) {
        __changePasswordFetcher.sink.add(
            await _repository.fetchChangePassword(context, phone, password));
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  registrationRequest(
      BuildContext context, DialogCallBack callBack, var body) async {
    _registrationResponseFetcher = PublishSubject<LoginPost>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) async {
      if (isConnected) {
        _registrationResponseFetcher.sink
            .add(await _repository.fetchRegistrationData(context, body));
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  logoutService(BuildContext context, DialogCallBack callBack) async {
    _logout = PublishSubject<dynamic>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) {
      if (isConnected) {
        CommonMethods.getPreferenceValues(Constants.ACCESS_TOKEN)
            .then((dynamic _token) async {
          _logout.sink.add(await _repository.logoutService(context, _token));
        });
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  updateRequest(BuildContext context, DialogCallBack callBack, var body) async {
    _updateProfileFetcher = PublishSubject<dynamic>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) async {
      if (isConnected) {
        CommonMethods.getPreferenceValues(Constants.ACCESS_TOKEN)
            .then((dynamic _token) async {
          _updateProfileFetcher.sink
              .add(await _repository.updateProfileData(context, body, _token));
        });
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  fetchProfileData(BuildContext context, DialogCallBack callBack) async {
    _profileResponseFetcher = PublishSubject<LoginPost>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) {
      if (isConnected) {
        CommonMethods.getPreferenceValues(Constants.ACCESS_TOKEN)
            .then((dynamic _token) async {
          _profileResponseFetcher.sink
              .add(await _repository.fetchProfileData(context, _token));
        });
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  fetchHelpResult(
      BuildContext context, DialogCallBack callBack, String details) async {
    _helpApiFetcher = PublishSubject<dynamic>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) async {
      if (isConnected) {
        CommonMethods.getPreferenceValues(Constants.ACCESS_TOKEN)
            .then((dynamic _token) async {
          _helpApiFetcher.sink
              .add(await _repository.fetchHelpResult(context, details, _token));
        });
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  fetchNotificationData(BuildContext context, DialogCallBack callBack) async {
    notificationApiFetcher = PublishSubject<AllNotificationsPost>();
    CommonMethods.checkInternetConnectivity().then((bool isConnected) {
      if (isConnected) {
        CommonMethods.getPreferenceValues(Constants.ACCESS_TOKEN)
            .then((dynamic _token) async {
          notificationApiFetcher.sink
              .add(await _repository.fetchNotificationResult(context, _token));
        });
      } else
        CommonMethods.commonDialog(context, callBack, StringsFile.noInternetMsg,
            StringsFile.cantConnectInternet);
    });
  }

  disposeProfileStream() {
    _profileResponseFetcher?.close();
  }

  disposeHelpApiStream() {
    _helpApiFetcher?.close();
  }

  disposeNotificationApiStream() {
    notificationApiFetcher?.close();
  }

  disposeProfileBloc() {
    _preferenceFetcher?.close();
  }

  disposeEditStream() {
//    _updateProfileFetcher?.close();
  }

  dispose() {
    _catalogueFetcher?.close();
    _checkUserFetcher?.close();
    _checkUserOTP?.close();
    loginResponseFetcher?.close();
    __changePasswordFetcher?.close();
    _registrationResponseFetcher?.close();
    _logout?.close();
  }

  ///Below method is for saving data in the preferences
  saveDataInPreferences(
      LoginPost data, BuildContext context, String _from) async {
    Preferences preferences = Preferences();
    preferences.setPreferencesString(Constants.PREF_USER_ID, data.user.uid);
    if (data.token.isNotEmpty)
      preferences.setPreferencesString(Constants.ACCESS_TOKEN, data.token);
    preferences.setPreferencesString(Constants.PREF_USERNAME, data.user.name);
    preferences.setPreferencesString(
        Constants.PREF_USER_IMAGE, data.user.imageUrl);
    preferences.setPreferencesString(
        Constants.PREF_USER_PHONE_NUMBER, data.user.mobileNumber);
    preferences.setPreferencesString(
        Constants.PREF_USER_TYPE, data.user.userType);
    preferences.setPreferencesString(
        Constants.PREF_PROF_REG_NUMBER, data.user.profRegistrationNumber);
    preferences.setPreferencesString(
        Constants.PREF_QUALIFICATION, data.user.qualification);
    preferences.setPreferencesString(
        Constants.PREF_USER_LOCATION, data.user.address);
    preferences.setPreferencesString(
        Constants.PREF_EXPERIENCE, data.user.experience);
    preferences.setPreferencesString(
        Constants.PREF_PRACTISING, data.user.practising);
    preferences.setPreferencesString(Constants.PREF_COLLEGE, data.user.college);
    preferences.setPreferencesString(
        Constants.PREF_INTRODUCTION, data.user.about);
    preferences.setPreferencesString(Constants.PREF_GENDER, data.user.gender);
    preferences.setPreferencesString(
        Constants.PREF_USER_EMAIL, data.user.email);
    preferences.setPreferencesString(Constants.PREF_DOB, data.user.birthDate);
    preferences.setPreferencesString(
        Constants.PREF_USER_BANNER_IMAGE, data.user.coverImageUrl);
    preferences.setPreferencesString(
        Constants.PREF_REFERRAL_CODE, data.user.referralCode);
    preferences.setPreferencesString(Constants.PREF_CREDITS, data.user.credits);
    if (_from != null)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(screen: Constants.BIDS)));
  }

  ///Below method is for saving data in the preferences
  saveEditProfileDataInPreferences(BuildContext context, Map data) async {
    Preferences preferences = Preferences();
    preferences.setPreferencesString(Constants.PREF_USERNAME, data['name']);
//    preferences.setPreferencesString(Constants.PREF_USER_IMAGE,  data.user.imageUrl);
//    preferences.setPreferencesString(Constants.PREF_USER_PHONE_NUMBER, data.user.phoneNumber);
//    preferences.setPreferencesString(Constants.PREF_PROF_REG_NUMBER, data.user.profRegistrationNumber);
//    preferences.setPreferencesString(Constants.PREF_QUALIFICATION, data.user.qualification);
    preferences.setPreferencesString(
        Constants.PREF_USER_LOCATION, data['address']);
//    preferences.setPreferencesString(Constants.PREF_EXPERIENCE, data.user.experience);
//    preferences.setPreferencesString(Constants.PREF_PRACTISING, data.user.practising);
//    preferences.setPreferencesString(Constants.PREF_COLLEGE, data.user.college);
//    preferences.setPreferencesString(Constants.PREF_INTRODUCTION, data.user.about);
//    preferences.setPreferencesString(Constants.PREF_DOB, data['dob']);
    _preferenceFetcher.sink.add(data);
    Navigator.of(context).pop();
  }

  changeAppBar(BuildContext context, Map data) async {
    _deleteListenerFetcher.sink.add(data);
  }
}
