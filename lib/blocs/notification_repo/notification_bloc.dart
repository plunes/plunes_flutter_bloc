import 'package:plunes/repositories/notification_repo/notification_repo.dart';
import 'package:plunes/requester/request_states.dart';

class NotificationBloc {
  Future<RequestState> getNotifications() {
    return NotificationRepo().getNotifications();
  }

  void setUnreadCountToZero() {
    NotificationRepo().setUnreadCountToZero();
  }
}
