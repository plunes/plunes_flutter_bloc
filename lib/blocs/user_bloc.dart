import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_handler.dart';
import 'package:plunes/requester/request_states.dart';

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

}
