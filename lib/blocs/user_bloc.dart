import 'dart:io';

import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase {
  final _specialityStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get specialityStream =>
      _specialityStreamProvider.stream;
  final _serviceStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get serviceStream => _serviceStreamProvider.stream;

  final _reviewStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get rateAndReviewStream =>
      _reviewStreamProvider.stream;

  final _profileImageProvider = PublishSubject<RequestState>();

  Observable<RequestState> get profileStream => _profileImageProvider.stream;

  Future<RequestState> isUserInServiceLocation(var latitude, var longitude,
      {String address, bool isFromPopup = false, String region}) {
    return UserManager().isUserInServiceLocation(latitude, longitude,
        address: address, isFromPopup: isFromPopup, region: region);
  }

  Future<RequestState> getUserProfile(final String userId,
      {bool shouldSaveInfo = false}) async {
    var result = await UserManager()
        .getUserProfile(userId, shouldSaveInfo: shouldSaveInfo);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> getGenerateOtp(String mobileNumber,
      {bool iFromForgotPassword = false}) async {
    var result = await UserManager()
        .getGenerateOtp(mobileNumber, iFromForgotPassword: iFromForgotPassword);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> getVerifyOtp(String mobileNumber, var otp,
      {bool iFromForgotPassword = false}) async {
    var result = await UserManager().getVerifyOtp(mobileNumber, otp,
        iFromForgotPassword: iFromForgotPassword);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> updateUserData(Map<String, dynamic> userData) async {
    super.addIntoStream(RequestInProgress());
    var result = await UserManager().updateUserData(userData);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> getSpeciality() async {
    var result = await UserManager().getSpecialities();
    return result;
  }

  Future<RequestState> saveUpdateFirebaseToken(String token) {
    return UserManager().saveUpdateFirebaseToken(token);
  }

  Future<RequestState> turnOnOffNotification(final bool isOn) {
    return UserManager().turnOnOffNotification(isOn);
  }

  Future<RequestState> getUserSpecificSpecialities(String userId) async {
    var result = await UserManager().getUserSpecificSpecialities(userId);
    addStateInSpecialityStream(result);
    return result;
  }

  Future<RequestState> getSpecialityRelatedService(
      String userId, String specialityId) async {
    addStateInServiceStream(RequestInProgress());
    var result =
        await UserManager().getSpecialityRelatedService(userId, specialityId);
    addStateInServiceStream(result);
    return result;
  }

  Future<RequestState> uploadPicture(File image) async {
    addStateInProfileStream(RequestInProgress());
    var result = await UserManager().uploadPicture(image);
    addStateInProfileStream(result);
    return result;
  }

  @override
  void dispose() {
    _specialityStreamProvider?.close();
    _serviceStreamProvider?.close();
    _reviewStreamProvider?.close();
    _profileImageProvider?.close();
    super.dispose();
  }

  void addStateInSpecialityStream(RequestState state) {
    addStateInGenericStream(_specialityStreamProvider, state);
  }

  void addStateInServiceStream(RequestState state) {
    addStateInGenericStream(_serviceStreamProvider, state);
  }

  Future<RequestState> resetPassword(
      String phoneNumber, String otp, String password) async {
    return UserManager().resetPassword(phoneNumber, otp, password);
  }

  Future<RequestState> changePassword(
      String oldPassword, String newPassword) async {
    return UserManager().changePassword(oldPassword, newPassword);
  }

  Future<RequestState> getHelplineNumber() {
    return UserManager().getHelplineNumber();
  }

  Future<RequestState> checkUserExistence(String phoneNumber) {
    return UserManager().checkUserExistence(phoneNumber);
  }

  Future<RequestState> login(String phoneNumber, String password) {
    return UserManager().login(phoneNumber, password);
  }

  Future<RequestState> signUp(Map<String, dynamic> body) {
    return UserManager().signUp(body);
  }

  Future<RequestState> getAdminSpecificData() async {
    return await UserManager().getAdminSpecificData();
  }

  Future<RequestState> getRateAndReviews(String profId,
      {int initialIndex = 0}) async {
    addStateInReviewStream(RequestInProgress());
    var result = await UserManager().getRateAndReviews(profId);
    addStateInReviewStream(result);
    return result;
  }

  addStateInReviewStream(RequestState data) {
    addStateInGenericStream(_reviewStreamProvider, data);
  }

  addStateInProfileStream(RequestState data) {
    addStateInGenericStream(_profileImageProvider, data);
  }
}
