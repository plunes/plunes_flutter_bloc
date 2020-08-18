import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/notification_repo/notification_repo.dart';
import 'package:plunes/requester/request_states.dart';

class NotificationBloc extends BlocBase {
  Future<RequestState> getNotifications({bool shouldNotify = false}) async {
    addIntoStream(RequestInProgress());
    var result =
        await NotificationRepo().getNotifications(shouldNotify: shouldNotify);
    addIntoStream(result);
    return result;
  }

  void setUnreadCountToZero() {
    NotificationRepo().setUnreadCountToZero();
  }

  @override
  void addIntoStream(RequestState result) {
    super.addIntoStream(result);
  }
}
