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

  final _mediaContentStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get mediaContentStream =>
      _mediaContentStreamProvider.stream;

  final _insuranceStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get insuranceStream =>
      _insuranceStreamProvider.stream;

  final _insuranceFileUploadStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get insuranceFileUploadStream =>
      _insuranceFileUploadStreamProvider.stream;

  final _serviceRelatedToSpecilaityStreamProvider =
      PublishSubject<RequestState>();

  Observable<RequestState> get serviceRelatedToSpecialityStream =>
      _serviceRelatedToSpecilaityStreamProvider.stream;

  final _facilityAvailableInHospitalStreamProvider =
      PublishSubject<RequestState>();

  Observable<RequestState> get facilityOfHospitalStream =>
      _facilityAvailableInHospitalStreamProvider.stream;

  final _premiumBenefitsStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get premiumBenefitsStream =>
      _premiumBenefitsStreamProvider.stream;

  final _serviceCategoryStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get serviceCategoryStream =>
      _serviceCategoryStreamProvider.stream;

  Future<RequestState> isUserInServiceLocation(var latitude, var longitude,
      {String address, bool isFromPopup = false, String region}) {
    return UserManager().isUserInServiceLocation(latitude, longitude,
        address: address, isFromPopup: isFromPopup, region: region);
  }

  Future<RequestState> getUserProfile(final String userId,
      {bool shouldSaveInfo = false,
      bool isGenUser = true,
      String docId}) async {
    var result = await UserManager().getUserProfile(userId,
        shouldSaveInfo: shouldSaveInfo, isUser: isGenUser,docId: docId);
    print("result------------------->");
    print(result);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> getGenerateOtp(String mobileNumber,
      {bool iFromForgotPassword = false,
      String signature,
      bool isProfessional = false}) async {
    var result = await UserManager().getGenerateOtp(mobileNumber,
        iFromForgotPassword: iFromForgotPassword,
        signature: signature,
        isProfessional: isProfessional);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> getVerifyOtp(String mobileNumber, var otp,
      {bool iFromForgotPassword = false, bool isProfessional = false}) async {
    var result = await UserManager().getVerifyOtp(mobileNumber, otp,
        iFromForgotPassword: iFromForgotPassword,
        isProfessional: isProfessional);
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
    _mediaContentStreamProvider?.close();
    _insuranceStreamProvider?.close();
    _insuranceFileUploadStreamProvider?.close();
    _serviceRelatedToSpecilaityStreamProvider?.close();
    _facilityAvailableInHospitalStreamProvider?.close();
    _premiumBenefitsStreamProvider?.close();
    _serviceCategoryStreamProvider?.close();
    super.dispose();
  }

  void addStateInSpecialityStream(RequestState state) {
    addStateInGenericStream(_specialityStreamProvider, state);
  }

  void addStateInServiceStream(RequestState state) {
    addStateInGenericStream(_serviceStreamProvider, state);
  }

  Future<RequestState> resetPassword(
      String phoneNumber, String otp, String password,
      {bool isProf = false}) async {
    return UserManager()
        .resetPassword(phoneNumber, otp, password, isProf: isProf);
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

  Future<RequestState> login(
      String phoneNumber, String password, bool isProfessional) {
    return UserManager().login(phoneNumber, password, isProfessional);
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

  Future<RequestState> getMediaContent(String profId,
      {int initialIndex = 0}) async {
    addStateInMediaContentStream(RequestInProgress());
    var result = await UserManager().getMediaContent(profId);
    addStateInMediaContentStream(result);
    return result;
  }

  Future<RequestState> getInsuranceList(String profId) async {
    addStateInInsuranceListStream(RequestInProgress());
    var result = await UserManager().getInsuranceList(profId);
    addStateInInsuranceListStream(result);
    return result;
  }

  addStateInReviewStream(RequestState data) {
    addStateInGenericStream(_reviewStreamProvider, data);
  }

  addStateInProfileStream(RequestState data) {
    addStateInGenericStream(_profileImageProvider, data);
  }

  addStateInUploadInsuranceFileStream(RequestState data) {
    addStateInGenericStream(_insuranceFileUploadStreamProvider, data);
  }

  addStateInMediaContentStream(RequestState data) {
    addStateInGenericStream(_mediaContentStreamProvider, data);
  }

  addStateInInsuranceListStream(RequestState data) {
    addStateInGenericStream(_insuranceStreamProvider, data);
  }

  addStateInServiceRelatedToSpecialityStream(RequestState data) {
    addStateInGenericStream(_serviceRelatedToSpecilaityStreamProvider, data);
  }

  addStateInFacilityProviderStream(RequestState data) {
    addStateInGenericStream(_facilityAvailableInHospitalStreamProvider, data);
  }

  addStateInPremiumBenefitsProviderStream(RequestState data) {
    addStateInGenericStream(_premiumBenefitsStreamProvider, data);
  }

  Future<RequestState> uploadInsuranceFile(File file, {String fileType}) async {
    addStateInUploadInsuranceFileStream(RequestInProgress());
    var result =
        await UserManager().uploadInsuranceFile(file, fileType: fileType);
    addStateInUploadInsuranceFileStream(result);
    return result;
  }

  Future<RequestState> getServicesOfSpeciality(
      String specialityId, String profId) async {
    addStateInServiceRelatedToSpecialityStream(RequestInProgress());
    var result =
        await UserManager().getServicesOfSpeciality(profId, specialityId);
    addStateInServiceRelatedToSpecialityStream(result);
    return result;
  }

  Future<RequestState> getFacilitiesProvidedByHospitalOrDoc(
      String profId) async {
    addStateInFacilityProviderStream(RequestInProgress());
    var result =
        await UserManager().getFacilitiesProvidedByHospitalOrDoc(profId);
    addStateInFacilityProviderStream(result);
    return result;
  }

  Future<RequestState> getPremiumBenefitsForUsers(
      {bool isFromAboutUsScreen = false}) async {
    addStateInPremiumBenefitsProviderStream(RequestInProgress());
    var result = await UserManager()
        .getPremiumBenefitsForUsers(isFromAboutUsScreen: isFromAboutUsScreen);
    addStateInPremiumBenefitsProviderStream(result);
    return result;
  }

  Future<RequestState> getBankOffers() {
    return UserManager().getBankOffers();
  }

  Future<RequestState> getServiceCategoryData(String profId) async {
    var result = await UserManager().getServiceCategoryData(profId: profId);
    addStateInServiceCategoryData(result);
    return result;
  }

  void addStateInServiceCategoryData(RequestState data) {
    addStateInGenericStream(_serviceCategoryStreamProvider, RequestSuccess());
  }
}
