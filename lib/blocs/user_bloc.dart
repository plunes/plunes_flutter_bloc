import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/doc_hos_repo/doc_hos_main_screen_repo.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_handler.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';


class UserBloc extends BlocBase {
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

  Future<RequestState> getVerifyOtp(String mobileNumber, int otp) async {
    var result = await UserManager().getVerifyOtp(mobileNumber, otp);
    super.addIntoStream(result);
    return result;
  }
    Future<RequestState> updateUserData(Map<String, dynamic> userData) async {
       var result = await UserManager().updateUserData(userData);
      // super.addIntoStream(result);
       return result;
      }
}
