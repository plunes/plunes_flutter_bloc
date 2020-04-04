import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_handler.dart';

class UserBloc extends BlocBase {
  Future<RequestOutput> isUserInServiceLocation() {
    return UserManager().isUserInServiceLocation();
  }
}
