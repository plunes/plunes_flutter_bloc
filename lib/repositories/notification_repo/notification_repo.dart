import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/dio_requester.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';
import 'package:plunes/resources/network/Urls.dart';

class NotificationRepo {
  Future<RequestState> getNotifications({bool shouldNotify = false}) async {
    var result = await DioRequester().requestMethod(
        url: (UserManager().getUserDetails().userType != Constants.user)
            ? Urls.GET_NOTIFICATIONS_URL_FOR_PROF
            : Urls.GET_NOTIFICATIONS_URL,
        requestType: HttpRequestMethods.HTTP_GET,
        headerIncluded: true);
    if (result!.isRequestSucceed!) {
      AllNotificationsPost? _allNotificationPost;
      try {
        _allNotificationPost =
            AllNotificationsPost.fromJson(result.response!.data);
      } catch (e) {
        print("error occur NotificationRepo");
      }
      if (_allNotificationPost != null &&
          _allNotificationPost.posts != null &&
          _allNotificationPost.unreadCount != null &&
          _allNotificationPost.unreadCount != 0 &&
          shouldNotify) {
        FirebaseNotification().setNotificationCount(1);
      }
      return RequestSuccess(response: _allNotificationPost);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  Future<RequestState> setUnreadCountToZero() async {
    var result = await DioRequester().requestMethod(
        url: (UserManager().getUserDetails().userType != Constants.user)
            ? Urls.SET_NOTIFICATION_COUNT_ZERO + "/professional"
            : Urls.SET_NOTIFICATION_COUNT_ZERO,
        requestType: HttpRequestMethods.HTTP_PUT,
        headerIncluded: true);
    if (result!.isRequestSucceed!) {
      return RequestSuccess(response: true);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }

  removeNotification(PostsData post) async {
    var result = await DioRequester().requestMethod(
        url: Urls.DELETE_NOTIFICATIONS_URL,
        requestType: HttpRequestMethods.HTTP_DELETE,
        postData: {
          "deleteNotification": [post.id]
        },
        headerIncluded: true);
    if (result!.isRequestSucceed!) {
      return RequestSuccess(response: true);
    } else {
      return RequestFailed(failureCause: result.failureCause);
    }
  }
}
