import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/resources/network/WebServices.dart';


class Repository {

  final WebServices _webServices = WebServices();
  
  Future<CatalogueList> fetchCatalogue(BuildContext context) => _webServices.getCatalogue(context);

  Future<dynamic> logoutService(BuildContext context, token) => _webServices.postLogoutWebservice(context, token);

  Future<dynamic> fetchUserExistence(BuildContext context, String value) => _webServices.getUserExistence(context, value);

  Future<dynamic> fetchUserOTP(BuildContext context, String url) => _webServices.getUserOTP(context, url);

  Future<LoginPost> fetchLoginData(BuildContext context, String phone,  String password) => _webServices.postLoginRequest(context, phone, password);
  Future<LoginPost> fetchProfileData(BuildContext context, token) => _webServices.getProfileRequest(context, token);

  Future<dynamic> fetchChangePassword(BuildContext context, String phone,  String password) => _webServices.postChangePassword(context, phone, password);

  Future<LoginPost> fetchRegistrationData(BuildContext context, var body) => _webServices.postRegistrationRequest(context, body);
  Future<dynamic> updateProfileData(BuildContext context, var body, token) => _webServices.putUpdateProfileWebservice(context, body, token);

  Future<dynamic> fetchHelpResult(BuildContext context, String details, token) => _webServices.postHelpResult(context, details, token);
  Future<AllNotificationsPost> fetchNotificationResult(BuildContext context, token) => _webServices.postNotificationResult(context, token);


}