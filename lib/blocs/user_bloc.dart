import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/doc_hos_repo/doc_hos_main_screen_repo.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_handler.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase {
  final _specialityStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get specialityStream =>
      _specialityStreamProvider.stream;
  final _serviceStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get serviceStream => _serviceStreamProvider.stream;

  Future<RequestOutput> isUserInServiceLocation(var latitude, var longitude) {
    return UserManager().isUserInServiceLocation(latitude, longitude);
  }

  Future<RequestState> getUserProfile(final String userId,
      {bool shouldSaveInfo = false}) async {
    var result = await UserManager()
        .getUserProfile(userId, shouldSaveInfo: shouldSaveInfo);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> getGenerateOtp(String mobileNumber) async {
    var result = await UserManager().getGenerateOtp(mobileNumber);
    super.addIntoStream(result);
    return result;
  }

  Future<RequestState> getVerifyOtp(String mobileNumber, var otp) async {
    var result = await UserManager().getVerifyOtp(mobileNumber, otp);
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

  @override
  void dispose() {
    _specialityStreamProvider?.close();
    _serviceStreamProvider?.close();
    super.dispose();
  }

  void addStateInSpecialityStream(RequestState state) {
    addStateInGenericStream(_specialityStreamProvider, state);
  }

  void addStateInServiceStream(RequestState state) {
    addStateInGenericStream(_serviceStreamProvider, state);
  }
}
