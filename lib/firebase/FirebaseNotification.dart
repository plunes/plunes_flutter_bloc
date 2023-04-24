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
import 'package:plunes/ui/afterLogin/cart_screens/add_to_cart_main_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';
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
  static FirebaseNotification? _firebaseNotification;

  FirebaseNotification._init();

  factory FirebaseNotification() {
    if (_firebaseNotification == null) {
      _firebaseNotification = FirebaseNotification._init();
    }
    return _firebaseNotification!;
  }

  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String title = '', body = '';
  late BuildContext _buildContext;
  GlobalKey<ScaffoldState>? _scaffoldKeyNotification;
  late GlobalKey<NavigatorState> _navKey;
  FacebookAppEvents? _facebookAppEvents;
  FirebaseAnalytics? _analytics;

  static const String homeScreenName = "HomeScreen";
  static const String cartScreenName = "CartScreen";
  static const String bookingScreen = "booking"; // for all
  static const String exploreScreen = "explore"; //"plockr";
  static const String solutionScreen = "solution";
  static const String reviewScreen = "review";
  static const String activityScreen = "activity";
  static const String solutionViewScreen = "ShowSolution";
  static String? _currentScreenName;
  int? _notificationCount = 0, _cartCount = 0;

  static setScreenName(String? screenName) {
    _currentScreenName = screenName;
  }

  static String? getCurrentScreenName() => _currentScreenName;

  int? getCartCount() {
    return _cartCount;
  }

  FacebookAppEvents? getFbInstance() {
    return _facebookAppEvents;
  }

  FirebaseAnalytics? getAnalyticsInstance() {
    return _analytics;
  }

  int? getNotificationCount() {
    return _notificationCount;
  }

  void setCartCount(int? count) {
    _cartCount = count;
    _notificationListener.add(count);
  }

  void setNotificationCount(int count) {
    _notificationCount = count;
    _notificationListener.add(count);
    if (count != null && count == 0) {
      NotificationBloc().setUnreadCountToZero();
    }
  }

  Stream<int?> get notificationStream => _notificationListener.stream;

  // for doc/hos/lab
  static const String insightScreen = "insight";
  var _notificationListener = PublishSubject<int?>();

  /// call this method to configure fireBase messaging in the app for push notification
  init(BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey, var key,
      FacebookAppEvents fbInstance, FirebaseAnalytics analytics) {
    _navKey = key;
    _buildContext = context;
    _scaffoldKeyNotification = _scaffoldKey;
    _facebookAppEvents = fbInstance;
    _analytics = analytics;
    _firebaseMessaging = FirebaseMessaging.instance;
    var initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher');

    // var initializationSettingsIOS = new IOSInitializationSettings(
    //     defaultPresentSound: true,
    //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings();
        // initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        // onSelectNotification: onSelectNotification
    );
    fireBaseCloudMessagingListeners();
  }

  Future onSelectNotification(String payLoad) async {
//    print(json.decode(payLoad));
    Map<String, dynamic>? msg = json.decode(payLoad);
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

  void handleRedirection(Map<String, dynamic>? payLoad) async {
    bool isHomeScreen = false;
    Widget? widget;
    if (Platform.isIOS) {
      payLoad = {"data": payLoad};
    }
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
      } else if (payLoad["data"]['screen'] == exploreScreen) {
        if (_currentScreenName != null && _currentScreenName == exploreScreen) {
          return;
        }
        isHomeScreen = true;
        widget = HomeScreen(
          screenNo: Constants.exploreScreenNumber,
        );
      } else if (payLoad["data"]['screen'] == activityScreen) {
        if (_currentScreenName != null &&
            _currentScreenName == activityScreen) {
          return;
        }
        isHomeScreen = true;
        widget = HomeScreen(
          screenNo: Constants.activityScreenNumber,
        );
      } else if (payLoad["data"]['screen'] == bookingScreen) {
        if (_currentScreenName != null && _currentScreenName == bookingScreen) {
          return;
        }
        widget = AppointmentMainScreen(bookingId: payLoad['data']['id']);
      } else if (payLoad["data"]['screen'] == reviewScreen) {
        widget = AppointmentMainScreen(
            bookingId: payLoad['data']['id'], shouldOpenReviewPopup: true);
      } else if (payLoad["data"]['screen'] == insightScreen) {
        isHomeScreen = true;
        widget = HomeScreen(screenNo: Constants.homeScreenNumber);
      } else if (payLoad["data"]['screen'] == solutionScreen) {
        await Future.delayed(Duration(milliseconds: 50));
        if (_currentScreenName != null &&
            _currentScreenName == solutionScreen) {
          return;
        }
        if (payLoad["data"]['id'] != null && payLoad["data"]['id'].isNotEmpty) {
          widget = SolutionShowPriceScreen(
            catalogueData: CatalogueData(
                solutionId: payLoad["data"]['id'], isFromNotification: true),
          );
        }
      } else if (payLoad["data"]['screen'] == solutionViewScreen) {
        await Future.delayed(Duration(milliseconds: 50));
        if (_currentScreenName != null &&
            _currentScreenName == solutionViewScreen) {
          return;
        }
        if (payLoad["data"]['id'] != null && payLoad["data"]['id'].isNotEmpty) {
          widget = ViewSolutionsScreen(
            catalogueData: CatalogueData(
                solutionId: payLoad["data"]['id'], isFromNotification: true),
          );
        }
      } else if (payLoad["data"]['screen'] == cartScreenName) {
        if (_currentScreenName != null &&
            _currentScreenName == cartScreenName) {
          return;
        }
        widget = AddToCartMainScreen(hasAppBar: true);
      }
    }
    if (widget != null) {
      if (isHomeScreen) {
        _navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => widget!), (_) => false);
      } else {
        await Future.delayed(Duration(milliseconds: 20));
        _navKey.currentState!
            .push(MaterialPageRoute(builder: (context) => widget!));
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
    // _firebaseMessaging.subscribeToTopic("Testing12346");
//     _firebaseMessaging.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         // print('==firebase==onMessage== $message');
//         setNotificationCount(1);
//         _notifyListeners(message);
//         _showNotificationWithDefaultSound(message);
//       },
//       onResume: (Map<String, dynamic> message) async {
// //        print('==firebase==onResume== $message');
//         showLocalNotification(message);
//       },
//       onLaunch: (Map<String, dynamic> message) async {
// //        print('==firebase==onLaunch== $message');
//         showLocalNotification(message);
//       },
//     );
  }

  Future _showNotificationWithDefaultSound(Map<String, dynamic> msg) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name',
        // 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
//        style: AndroidNotificationStyle.BigText,
        icon: "@drawable/ic_launcher",
        ledOffMs: 500,
        ledOnMs: 1000,
        ledColor: Colors.green,
        color: Colors.green,
        styleInformation: BigTextStyleInformation(''));
    // var iOSPlatformChannelSpecifics = new IOSNotificationDetails(presentAlert: true);
    var platformChannelSpecifics = new NotificationDetails();
        // androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      Platform.isIOS
          ? msg['title']
          : msg['notification']['title'] ?? PlunesStrings.NA,
      Platform.isIOS
          ? msg['body']
          : msg['notification']['body'] ?? PlunesStrings.NA,
      platformChannelSpecifics,
      payload: json.encode(msg) ?? PlunesStrings.NA,
    );
  }

  iOSPermission() {
    _firebaseMessaging.requestPermission(
        sound: true, badge: true, alert: true);

    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
//      print("Settings registered: $settings");
//     });
  }

  Future _handleNavigation(PostsData notificationModel) async {
    bool isHomeScreen = false;
    Widget widget;
//    print(notificationModel.notificationType);
//     if (notificationModel.notificationType == homeScreenName) {
//       isHomeScreen = true;
//       widget = HomeScreen(
//         screenNo: Constants.homeScreenNumber,
//       );
//     } else if (notificationModel.notificationType == exploreScreen) {
//       if (_currentScreenName != null && _currentScreenName == exploreScreen) {
//         return;
//       }
//       isHomeScreen = true;
//       widget = HomeScreen(
//         screenNo: Constants.exploreScreenNumber,
//       );
//     } else if (notificationModel.notificationType == activityScreen) {
//       if (_currentScreenName != null && _currentScreenName == activityScreen) {
//         return;
//       }
//       isHomeScreen = true;
//       widget = HomeScreen(
//         screenNo: Constants.activityScreenNumber,
//       );
//     } else if (notificationModel.notificationType == bookingScreen) {
//       if (_currentScreenName != null && _currentScreenName == bookingScreen) {
//         return;
//       }
//       widget = AppointmentMainScreen(
//         bookingId: notificationModel.id,
//       );
//     } else if (notificationModel.notificationType == reviewScreen) {
//       widget = AppointmentMainScreen(
//         bookingId: notificationModel.id,
//         shouldOpenReviewPopup: true,
//       );
//     } else if (notificationModel.notificationType == insightScreen) {
//       isHomeScreen = true;
//       widget = HomeScreen(
//         screenNo: Constants.homeScreenNumber,
//       );
//     } else if (notificationModel.notificationType == solutionScreen) {
//       await Future.delayed(Duration(milliseconds: 50));
//       if (_currentScreenName != null && _currentScreenName == solutionScreen) {
//         return;
//       }
//       if (notificationModel.id != null && notificationModel.id.isNotEmpty) {
//         widget = SolutionShowPriceScreen(
//           catalogueData: CatalogueData(
//               solutionId: notificationModel.id, isFromNotification: true),
//         );
//       }
//     } else if (notificationModel.notificationType == solutionViewScreen) {
//       await Future.delayed(Duration(milliseconds: 50));
//       if (_currentScreenName != null &&
//           _currentScreenName == solutionViewScreen) {
//         return;
//       }
//       if (notificationModel.id != null && notificationModel.id.isNotEmpty) {
//         widget = ViewSolutionsScreen(
//           catalogueData: CatalogueData(
//               solutionId: notificationModel.id, isFromNotification: true),
//         );
//       }
//     } else if (notificationModel.notificationType == cartScreenName) {
//       if (_currentScreenName != null && _currentScreenName == cartScreenName) {
//         return;
//       }
//       widget = AddToCartMainScreen(hasAppBar: true);
//     }
//     if (widget != null) {
//       await Future.delayed(Duration(seconds: 3));
//       if (isHomeScreen) {
//         _navKey.currentState.pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => widget), (_) => false);
//       } else {
//         _navKey.currentState
//             .push(MaterialPageRoute(builder: (context) => widget));
//       }
//     }
  }

  showLocalNotification(Map<String, dynamic> message) {
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
    _notificationListener.close();
  }

  void _notifyListeners(Map<String, dynamic> payLoad) async {
    if (Platform.isIOS) {
      String? screenName, id;
      Widget? widget;
      if (payLoad != null &&
          payLoad.containsKey("screen") &&
          payLoad['screen'] != null &&
          payLoad['screen'].toString().isNotEmpty) {
        if (payLoad['screen'] == exploreScreen) {
          screenName = exploreScreen;
        } else if (payLoad['screen'] == bookingScreen) {
          screenName = bookingScreen;
        } else if (payLoad['screen'] == insightScreen) {
          screenName = insightScreen;
        } else if (payLoad['screen'] == cartScreenName) {
          screenName = cartScreenName;
        } else if (payLoad['screen'] == solutionScreen) {
          screenName = solutionScreen;
          id = payLoad['id'];

          if (_currentScreenName != null &&
              _currentScreenName == solutionScreen) {
            widget = SolutionShowPriceScreen(
              catalogueData:
                  CatalogueData(solutionId: id, isFromNotification: true),
            );
          }
        } else if (payLoad['screen'] == solutionViewScreen) {
          screenName = solutionViewScreen;
          id = payLoad['id'];
          if (_currentScreenName != null &&
              _currentScreenName == solutionViewScreen) {
            widget = ViewSolutionsScreen(
              catalogueData:
                  CatalogueData(solutionId: id, isFromNotification: true),
            );
          }
        } else if (payLoad['screen'] == activityScreen) {
          screenName = activityScreen;
        }
        if (screenName != null && screenName.isNotEmpty) {
          EventProvider()
              .getSessionEventBus()!
              .fire(ScreenRefresher(screenName: screenName));
          if (id != null && widget != null) {
            await Future.delayed(Duration(milliseconds: 10));
            _navKey.currentState!
                .push(MaterialPageRoute(builder: (context) => widget!));
          }
        }
      }
    } else {
      String? screenName, id;
      Widget? widget;
      // print("ssss ${payLoad["data"]['screen']}");
      if (payLoad != null &&
          payLoad.containsKey("data") &&
          payLoad["data"]['screen'] != null &&
          payLoad["data"]['screen'].toString().isNotEmpty) {
        if (payLoad["data"]['screen'] == exploreScreen) {
          screenName = exploreScreen;
        } else if (payLoad["data"]['screen'] == bookingScreen) {
          screenName = bookingScreen;
        } else if (payLoad["data"]['screen'] == insightScreen) {
          screenName = insightScreen;
        } else if (payLoad["data"]['screen'] == cartScreenName) {
          screenName = cartScreenName;
        } else if (payLoad["data"]['screen'] == solutionScreen) {
          screenName = solutionScreen;
          id = payLoad["data"]['id'];

          if (_currentScreenName != null &&
              _currentScreenName == solutionScreen) {
            widget = SolutionShowPriceScreen(
              catalogueData:
                  CatalogueData(solutionId: id, isFromNotification: true),
            );
          }
        } else if (payLoad["data"]['screen'] == solutionViewScreen) {
          screenName = solutionViewScreen;
          id = payLoad["data"]['id'];

          if (_currentScreenName != null &&
              _currentScreenName == solutionViewScreen) {
            widget = ViewSolutionsScreen(
              catalogueData:
                  CatalogueData(solutionId: id, isFromNotification: true),
            );
          }
        } else if (payLoad["data"]['screen'] == activityScreen) {
          screenName = activityScreen;
        }
        if (screenName != null && screenName.isNotEmpty) {
          // print("fired$screenName");
          EventProvider()
              .getSessionEventBus()!
              .fire(ScreenRefresher(screenName: screenName));
          if (id != null && widget != null) {
            await Future.delayed(Duration(milliseconds: 10));
            _navKey.currentState!
                .push(MaterialPageRoute(builder: (context) => widget!));
          }
        }
      }
    }
  }
}
