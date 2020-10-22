import 'dart:convert';
import 'dart:io';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/blocs/notification_repo/notification_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/HomeScreen.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointment_main_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_received_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * Created by - Plunes Technologies .
 * Developer -  Manvendra Kumar Singh
 * Description - FireBaseNotification class is used for setup and configure the FCM messaging for the mobile push notification.
 */

class FirebaseNotification {
  static FirebaseNotification _firebaseNotification;

  FirebaseNotification._init();

  factory FirebaseNotification() {
    if (_firebaseNotification == null) {
      _firebaseNotification = FirebaseNotification._init();
    }
    return _firebaseNotification;
  }

  FirebaseMessaging _firebaseMessaging;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String title = '', body = '';
  BuildContext _buildContext;
  GlobalKey<ScaffoldState> _scaffoldKeyNotification;
  GlobalKey<NavigatorState> _navKey;
  FacebookAppEvents _facebookAppEvents;
  FirebaseAnalytics _analytics;

  static const String homeScreenName = "HomeScreen";
  static const String bookingScreen = "booking"; // for all
  static const String plockrScreen = "plockr";
  static const String solutionScreen = "solution";
  static const String reviewScreen = "review";
  int _notificationCount = 0, _plockrCount = 0;

  int getPlockrCount() {
    return _plockrCount;
  }

  FacebookAppEvents getFbInstance() {
    return _facebookAppEvents;
  }

  FirebaseAnalytics getAnalyticsInstance() {
    return _analytics;
  }

  int getNotificationCount() {
    return _notificationCount;
  }

  void setPlockrCount(int count) {
    _plockrCount = count;
  }

  void setNotificationCount(int count) {
    _notificationCount = count;
    _notificationListener?.add(count);
    if (count != null && count == 0) {
      NotificationBloc().setUnreadCountToZero();
    }
  }

  Observable<int> get notificationStream => _notificationListener.stream;

  // for doc/hos/lab
  static const String insightScreen = "insight";
  var _notificationListener = PublishSubject<int>();

  /// call this method to configure fireBase messaging in the app for push notification
  init(BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey, var key,
      FacebookAppEvents fbInstance, FirebaseAnalytics analytics) {
    _navKey = key;
    _buildContext = context;
    _scaffoldKeyNotification = _scaffoldKey;
    _facebookAppEvents = fbInstance;
    _analytics = analytics;
    _firebaseMessaging = FirebaseMessaging();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
        defaultPresentSound: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    fireBaseCloudMessagingListeners();
  }

  Future onSelectNotification(String payLoad) async {
//    print(json.decode(payLoad));
    Map<String, dynamic> msg = json.decode(payLoad);
    handleRedirection(msg);
  }

  /// display a dialog with the notification details, tap ok to go to another page
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: _buildContext,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
          )
        ],
      ),
    );
  }

  void handleRedirection(Map<String, dynamic> payLoad) {
    bool isHomeScreen = false;
    Widget widget;
    if (payLoad != null &&
        payLoad.containsKey("data") &&
        payLoad["data"]['screen'] != null &&
        payLoad["data"]['screen'].toString().isNotEmpty) {
//      print(payLoad["data"]['screen']);
      if (payLoad["data"]['screen'] == homeScreenName) {
        isHomeScreen = true;
        widget = HomeScreen(
          screenNo: Constants.homeScreenNumber,
        );
      } else if (payLoad["data"]['screen'] == plockrScreen) {
        isHomeScreen = true;
        widget = HomeScreen(
          screenNo: Constants.plockerScreenNumber,
        );
      } else if (payLoad["data"]['screen'] == bookingScreen) {
        widget = AppointmentMainScreen(bookingId: payLoad['data']['id']);
      } else if (payLoad["data"]['screen'] == reviewScreen) {
        widget = AppointmentMainScreen(
            bookingId: payLoad['data']['id'], shouldOpenReviewPopup: true);
      } else if (payLoad["data"]['screen'] == insightScreen) {
        isHomeScreen = true;
        widget = HomeScreen(screenNo: Constants.homeScreenNumber);
      } else if (payLoad["data"]['screen'] == solutionScreen) {
        if (payLoad["data"]['id'] != null && payLoad["data"]['id'].isNotEmpty) {
          widget = SolutionReceivedScreen(
            catalogueData: CatalogueData(
                solutionId: payLoad["data"]['id'], isFromNotification: true),
          );
        }
      }
    }
    if (widget != null) {
      if (isHomeScreen) {
        _navKey.currentState.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => widget), (_) => false);
      } else {
        _navKey.currentState
            .push(MaterialPageRoute(builder: (context) => widget));
      }
    }
  }

  fireBaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.getToken().then((token) {
//      print("token: $token");
      Constants.DEVICE_TOKEN = token;
    });
//    _updateToken("randomtoken");
    _firebaseMessaging.onTokenRefresh.listen((token) {
      Constants.DEVICE_TOKEN = token;
      _updateToken(token);
    });
//    _firebaseMessaging.subscribeToTopic("Testing123");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
//        print('==firebase==onMessage== $message');
        setNotificationCount(1);
        _notifyListeners(message);
        _showNotificationWithDefaultSound(message);
      },
      onResume: (Map<String, dynamic> message) async {
//        print('==firebase==onResume== $message');
        showLocalNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
//        print('==firebase==onLaunch== $message');
        showLocalNotification(message);
      },
    );
  }

  Future _showNotificationWithDefaultSound(Map<String, dynamic> msg) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
//        style: AndroidNotificationStyle.BigText,
        icon: "@drawable/ic_launcher",
        ledOffMs: 500,
        ledOnMs: 1000,
        ledColor: Colors.green,
        color: Colors.green,
        styleInformation: BigTextStyleInformation(''));
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      msg['notification']['title'] ?? PlunesStrings.NA,
      msg['notification']['body'] ?? PlunesStrings.NA,
      platformChannelSpecifics,
      payload: json.encode(msg) ?? PlunesStrings.NA,
    );
  }

  iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
//      print("Settings registered: $settings");
    });
  }

  Future _handleNavigation(PostsData notificationModel) async {
    bool isHomeScreen = false;
    Widget widget;
//    print(notificationModel.notificationType);
    if (notificationModel.notificationType == homeScreenName) {
      isHomeScreen = true;
      widget = HomeScreen(
        screenNo: Constants.homeScreenNumber,
      );
    } else if (notificationModel.notificationType == plockrScreen) {
      isHomeScreen = true;
      widget = HomeScreen(
        screenNo: Constants.plockerScreenNumber,
      );
    } else if (notificationModel.notificationType == bookingScreen) {
      widget = AppointmentMainScreen(
        bookingId: notificationModel.id,
      );
    } else if (notificationModel.notificationType == reviewScreen) {
      widget = AppointmentMainScreen(
        bookingId: notificationModel.id,
        shouldOpenReviewPopup: true,
      );
    } else if (notificationModel.notificationType == insightScreen) {
      isHomeScreen = true;
      widget = HomeScreen(
        screenNo: Constants.homeScreenNumber,
      );
    } else if (notificationModel.notificationType == solutionScreen) {
      if (notificationModel.id != null && notificationModel.id.isNotEmpty) {
        widget = SolutionReceivedScreen(
          catalogueData: CatalogueData(
              solutionId: notificationModel.id, isFromNotification: true),
        );
      }
    }

    if (widget != null) {
      await Future.delayed(Duration(seconds: 3));
      if (isHomeScreen) {
        _navKey.currentState.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => widget), (_) => false);
      } else {
        _navKey.currentState
            .push(MaterialPageRoute(builder: (context) => widget));
      }
    }

//    return _navKey.currentState
//        .push(MaterialPageRoute(builder: (context) => AppointmentMainScreen()));
  }

//  Future<Null> _filterPopUp(String body, String userID) async {
//    return
//      showDialog<Null>(
//        context: _navKey.currentContext,
//        barrierDismissible: true, // user must tap button!
//        builder: (BuildContext context) {
//          return new Material(
//              type: MaterialType.transparency,
//              child: Container(
//                alignment: Alignment.center,
//                color: Colors.transparent,
//                margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 50.0),
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Container(
//                      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
//                      color: Colors.white,
//                      alignment: Alignment.topLeft,
//                      child: Text(
//                        title,
//                        textAlign: TextAlign.center,
//                        style: TextStyle(
//                            color: Colors.black,
//                            fontWeight: FontWeight.bold,
//                            fontSize: 16.0),
//                      ),
//                    ),
//                    Container(
//                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
//                      color: Colors.white,
//                      alignment: Alignment.topLeft,
//                      child: InkWell(
//                        onLongPress: () {
//                          Navigator.pop(context);
//                          Clipboard.setData(new ClipboardData(text: body));
//                          _scaffoldKeyNotification.currentState
//                              .showSnackBar(new SnackBar(
//                            content: new Text(
//                              "Copied to Clipboard",
//                              style: TextStyle(color: Colors.white),
//                            ),
//                            backgroundColor: Colors.black,
//                          ));
//                        },
//                        child: Text(
//                          body,
//                          textAlign: TextAlign.center,
//                          style: TextStyle(
//                              color: Colors.black,
//                              fontWeight: FontWeight.normal,
//                              fontSize: 16.0),
//                        ),
//                      ),
//                    ),
//                    Container(
//                      padding: EdgeInsets.only(
//                          left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
//                      color: Colors.white,
//                      child: GestureDetector(
//                        onTap: () {
//                          Navigator.pop(context);
//                        },
//                        child: new Container(
//                          padding:
//                              const EdgeInsets.only(left: 10.0, right: 10.0),
//                          margin: EdgeInsets.only(right: 10.0),
//                          height: 30.0,
//                          decoration: new BoxDecoration(
//                              shape: BoxShape.rectangle,
//                              borderRadius: BorderRadius.circular(5.0),
//                              color: Colors.black26),
//                          child: new Center(
//                              child: new Text(
//                            "DONE",
//                            textAlign: TextAlign.center,
//                            style: new TextStyle(
//                              fontSize: 15.0,
//                              color: Colors.white,
//                              fontFamily: "openSans",
//                            ),
//                          )),
//
//                          // Add box decoration
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ));
//        });
//  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: _scaffoldKeyNotification,
//      body: Container(),
//    );
//  }

  showLocalNotification(Map<String, dynamic> message) {
    if (Platform.isIOS) {
      title = message['notification']['title'] != null
          ? message["notification"]['title']
          : '';
      body = message['notification']['body'] != null
          ? message["notification"]['body']
          : '';
    } else {
      title = message['notification']['title'] != null
          ? message["notification"]['title']
          : '';
      body = message['notification']['body'] != null
          ? message["notification"]['body']
          : '';
    }
    PostsData _postData = PostsData.fromJsonForPush(message);
//    print('post data' + _postData?.toString());
    if (_postData != null && _postData.notificationType != null) {
      _handleNavigation(_postData);
    }
  }

  void _updateToken(String token) async {
    Future.delayed(Duration(seconds: 10)).then((value) {
      if (token != UserManager().getDeviceToken()) {
        UserBloc().saveUpdateFirebaseToken(token);
      }
    });
  }

  close() {
    _notificationListener?.close();
  }

  void _notifyListeners(Map<String, dynamic> payLoad) {
    if (Platform.isIOS) {
      String screenName;
      if (payLoad != null &&
          payLoad.containsKey("screen") &&
          payLoad['screen'] != null &&
          payLoad['screen'].toString().isNotEmpty) {
        if (payLoad['screen'] == plockrScreen) {
          screenName = plockrScreen;
        } else if (payLoad['screen'] == bookingScreen) {
          screenName = bookingScreen;
        } else if (payLoad['screen'] == insightScreen) {
          screenName = insightScreen;
        }
        if (screenName != null && screenName.isNotEmpty) {
          EventProvider()
              .getSessionEventBus()
              .fire(ScreenRefresher(screenName: screenName));
        }
      }
    } else {
      String screenName;
      if (payLoad != null &&
          payLoad.containsKey("data") &&
          payLoad["data"]['screen'] != null &&
          payLoad["data"]['screen'].toString().isNotEmpty) {
        if (payLoad["data"]['screen'] == plockrScreen) {
          screenName = plockrScreen;
        } else if (payLoad["data"]['screen'] == bookingScreen) {
          screenName = bookingScreen;
        } else if (payLoad["data"]['screen'] == insightScreen) {
          screenName = insightScreen;
        }
        if (screenName != null && screenName.isNotEmpty) {
          EventProvider()
              .getSessionEventBus()
              .fire(ScreenRefresher(screenName: screenName));
        }
      }
    }
  }
}
