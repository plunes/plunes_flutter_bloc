import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/resources/network/Urls.dart';

import 'ApiCall.dart';
import '../../Utils/Constants.dart';

class WebServices {
  final ApiCall _apiCall = ApiCall();

  Future<CatalogueList> getCatalogue(BuildContext context) async {
    dynamic postsList =
        await _apiCall.getAPIRequest(context, urls.catalogue, '', false);
    return CatalogueList.fromJson(postsList);
  }

  Future<dynamic> getUserExistence(
      BuildContext context, String phoneNumber) async {
    dynamic postsList = await _apiCall.getAPIRequest(
        context, urls.checkUserExistence + phoneNumber, '', false);
    return postsList;
  }

  Future<LoginPost> getProfileRequest(
      BuildContext context, String token) async {
    return LoginPost.fromJson(await _apiCall
        .getAPIRequest(context, urls.whoAmI, '', false, token: token));
  }

  Future<dynamic> getUserOTP(BuildContext context, String url) async {
    return await _apiCall.getAPIRequest(context, url, '', false);
  }

  Future<LoginPost> postLoginRequest(
      BuildContext context, phone, password) async {
    var body = {
      'mobileNumber': phone,
      'password': password,
      'deviceId': Constants.DEVICE_TOKEN
    };
    dynamic postsList = await _apiCall.getAPIRequest(
        context, urls.login, '1', false,
        body: json.encode(body), method: Constants.POST);
    return LoginPost.fromJson(postsList);
  }

  Future<dynamic> postChangePassword(
      BuildContext context, phone, password) async {
    var body = {'userId': phone, 'password': password};
    return await _apiCall.getAPIRequest(
        context, urls.changePassword, '1', false,
        body: json.encode(body), method: Constants.POST);
  }

  Future<dynamic> postHelpResult(BuildContext context, details, token) async {
    var body = {'text': details};
    return await _apiCall.getAPIRequest(context, urls.help, '1', false,
        body: json.encode(body), token: token, method: Constants.POST);
  }

  Future<AllNotificationsPost> postNotificationResult(
      BuildContext context, token) async {
    dynamic result = await _apiCall
        .getAPIRequest(context, urls.notification, '', false, token: token);
    return AllNotificationsPost.fromJson(result);
  }

  Future<LoginPost> postRegistrationRequest(
      BuildContext context, var body) async {
    dynamic postsList = await _apiCall.getAPIRequest(
        context, urls.signUp, '1', false,
        body: json.encode(body), method: Constants.POST);
    return LoginPost.fromJson(postsList);
  }

  Future<dynamic> postLogoutWebservice(
      BuildContext context, String token) async {
    var deviceToken = UserManager().getDeviceToken();
    return await _apiCall.getAPIRequest(
        context,
        context.widget.toString() == 'SecuritySettings'
            ? urls.logoutAll
            : urls.logout,
        '1',
        false,
        body: json.encode({'deviceId': deviceToken}),
        method: Constants.POST,
        token: token);
  }

  Future<dynamic> putUpdateProfileWebservice(
      BuildContext context, var body, String token) async {
    return await _apiCall.getAPIRequest(context, urls.userBaseUrl, '1', false,
        body: json.encode(body), method: Constants.PUT, token: token);
  }
}
