import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/swipe_action_cell.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/notification_repo/notification_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointment_main_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_received_screen.dart';
import 'HomeScreen.dart';
/*
 * Created by  - Plunes Technologies.
 * Developer   - Manvendra Kumar Singh
 * Description - NotificationScreen class contains all the in-app notification, which is coming from different aspects of the application. Ex.: Booking,
 *               Payment Completion, PLOCKR notification, Appointment Notification, Negotiation Notification.
 *
 */

// ignore: must_be_immutable
class NotificationScreen extends BaseActivity {
  static const tag = 'notificationscreen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth;
  bool isSelected = false;
  List<String> selectedPositions = new List();
  AllNotificationsPost _items;
  NotificationBloc _notificationBloc;
  String _failedMessage;
  StreamController _streamController;
  Timer _timer;

  @override
  void initState() {
    _notificationBloc = NotificationBloc();
    _getNotifications();
    _streamController = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_streamController != null && !_streamController.isClosed)
        _streamController?.add(null);
    });
    FirebaseNotification().setNotificationCount(0);
    FirebaseNotification().notificationStream.listen((event) {
      if (FirebaseNotification().getNotificationCount() != null &&
          FirebaseNotification().getNotificationCount() != 0 &&
          mounted) {
        _getNotifications();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController?.close();
    if (FirebaseNotification().getNotificationCount() != null &&
        FirebaseNotification().getNotificationCount() != 0) {
      FirebaseNotification().setNotificationCount(0);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: PlunesColors.WHITECOLOR,
        body: Container(
            child: StreamBuilder<RequestState>(
          stream: _notificationBloc.baseStream,
          builder: ((context, snapshot) {
            if (snapshot.data is RequestSuccess) {
              RequestSuccess successObject = snapshot.data;
              _items = successObject.response;
            } else if (snapshot.data is RequestFailed) {
              RequestFailed _failedObj = snapshot.data;
              _failedMessage = _failedObj?.failureCause;
            }
            if (_failedMessage != null && _failedMessage.isNotEmpty) {
              return Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      PlunesImages.notification_empty_screen_icon,
                      height: AppConfig.verticalBlockSize * 22,
                      width: AppConfig.horizontalBlockSize * 42,
                      alignment: Alignment.center,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.5,
                          bottom: AppConfig.verticalBlockSize * 3.5),
                      child: Text(
                          _failedMessage ?? plunesStrings.noRecordsFound,
                          style: TextStyle(
                              fontSize: AppConfig.mediumFont,
                              fontWeight: FontWeight.w600)),
                    ),
                    FittedBox(
                      child: InkWell(
                        onTap: () {
                          _failedMessage = null;
                          _getNotifications();
                          return;
                        },
                        child: CustomWidgets().getRoundedButton(
                            PlunesStrings.refresh,
                            AppConfig.horizontalBlockSize * 6,
                            PlunesColors.GREENCOLOR,
                            AppConfig.horizontalBlockSize * 3,
                            AppConfig.verticalBlockSize * 1,
                            PlunesColors.WHITECOLOR),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (_items != null) {
              if (_items == null ||
                  _items.posts == null ||
                  _items.posts.length == 0) {
                return Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        PlunesImages.notification_empty_screen_icon,
                        height: AppConfig.verticalBlockSize * 22,
                        width: AppConfig.horizontalBlockSize * 42,
                        alignment: Alignment.center,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 1.5,
                            bottom: AppConfig.verticalBlockSize * 3.5),
                        child: Text(
                            _failedMessage ?? plunesStrings.noRecordsFound,
                            style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                fontWeight: FontWeight.w600)),
                      ),
                      UserManager().getUserDetails().userType == Constants.user
                          ? FittedBox(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen(
                                              screenNo:
                                                  Constants.homeScreenNumber)),
                                      (_) => false);
                                  return;
                                },
                                child: CustomWidgets().getRoundedButton(
                                    PlunesStrings.startNegotiating,
                                    AppConfig.horizontalBlockSize * 6,
                                    PlunesColors.GREENCOLOR,
                                    AppConfig.horizontalBlockSize * 3.2,
                                    AppConfig.verticalBlockSize * 1,
                                    PlunesColors.WHITECOLOR),
                              ),
                            )
                          : Container()
                    ],
                  ),
                );
              } else {
                return buildList(_items);
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
        )));
  }

  Widget buildList(final AllNotificationsPost items) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: items.posts.length,
      itemBuilder: (context, index) {
        if (items.posts[index] != null && items.posts[index].deleted) {
          return Container();
        }
        return SwipeActionCell(
            key: ObjectKey(items.posts[index]),
            performsFirstActionWithFullSwipe: true,
            closeWhenScrolling: true,
            actions: [
              SwipeAction(
                  closeOnTap: true,
                  backgroundRadius: 16,
                  icon: Icon(
                    Icons.delete,
                    color: PlunesColors.WHITECOLOR,
                  ),
                  onTap: (CompletionHandler handler) async {
                    _removeNotification(items.posts, index);
                  },
                  color: PlunesColors.SPARKLINGGREEN.withOpacity(.5)),
            ],
            child: rowLayout(items.posts[index]));
      },
    );
  }

  Widget rowLayout(PostsData result) {
    return InkWell(
      onTap: () => _onTap(result),
      child: Column(
        children: <Widget>[
          Container(
            color:
                (result.hasSeen ?? true) ? null : PlunesColors.LIGHTGREENCOLOR,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(bottom: 0, right: 10),
                        child: result.senderImageUrl != '' &&
                                !result.senderImageUrl.contains("default")
                            ? CircleAvatar(
                                radius: AppConfig.horizontalBlockSize * 5,
                                backgroundImage:
                                    NetworkImage(result.senderImageUrl),
                              )
                            : CustomWidgets().getProfileIconWithName(
                                result.senderName, 10, 10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            CommonMethods.getStringInCamelCase(
                                result?.senderName),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: AppConfig.smallFont,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: AppConfig.horizontalBlockSize * 65,
                            child: Text(
                              result.notification,
                              maxLines: null,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: AppConfig.smallFont),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      alignment: Alignment.topRight,
                      child: StreamBuilder<Object>(
                          stream: _streamController.stream,
                          builder: (context, snapshot) {
                            return Text(
                              CommonMethods.getDuration(result.createdTime),
                              style: TextStyle(
                                  fontSize: AppConfig.verySmallFont - 2),
                            );
                          }),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: PlunesColors.GREYCOLOR,
          ),
        ],
      ),
    );
  }

  Future _onTap(PostsData result) async {
    if (result.hasSeen != null && !(result.hasSeen)) {
      result.hasSeen = true;
      _notificationBloc.addIntoStream(null);
    }
    if (result.notificationScreen == null ||
        result.notificationScreen.isEmpty) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(screenNo: Constants.homeScreenNumber)),
          (_) => false);
    }
    if (result.notificationScreen == FirebaseNotification.solutionScreen &&
        UserManager().getUserDetails().userType == Constants.user) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SolutionReceivedScreen(
                    catalogueData: CatalogueData(
                        solutionId: result.notificationId,
                        isFromNotification: true),
                  )));
    } else if (result.notificationScreen ==
        FirebaseNotification.bookingScreen) {
//      print("notification id is ${result.notificationId}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AppointmentMainScreen(
                    bookingId: result.notificationId,
                  )));
    } else if (result.notificationScreen == FirebaseNotification.reviewScreen) {
//      print("notification id is ${result.notificationId}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AppointmentMainScreen(
                    bookingId: result.notificationId,
                    shouldOpenReviewPopup: true,
                  )));
    } else if ((result.notificationScreen ==
                FirebaseNotification.insightScreen ||
            result.notificationScreen == FirebaseNotification.solutionScreen) &&
        UserManager().getUserDetails().userType != Constants.user) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(screenNo: Constants.homeScreenNumber)),
          (_) => false);
    } else if (result.notificationScreen == FirebaseNotification.plockrScreen) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(screenNo: Constants.plockerScreenNumber)),
          (_) => false);
    }
  }

  void _getNotifications() {
    _notificationBloc.getNotifications();
  }

  void _removeNotification(List<PostsData> items, int index) {
    _notificationBloc.removeNotification(items[index]);
    items.removeAt(index);
    _setState();
  }

  void _setState() {
    if (mounted) setState(() {});
  }
}
