import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * Created by - Plunes Technologies .
 * Developer -  Manvendra Kumar Singh
 * Description - FireBaseNotification class is used for setup and configure the FCM messaging for the mobile push notification.
 */

class FirebaseNotification {
  FirebaseMessaging _firebaseMessaging;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String title = '', body = '';
  BuildContext _buildContext;
  GlobalKey<ScaffoldState> _scaffoldKeyNotification;

  /// call this method to configure fireBase messaging in the app for push notification
  setUpFireBase(BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey) {
    _buildContext = context;
    _scaffoldKeyNotification = _scaffoldKey;
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

  Future onSelectNotification(String screen) async {
    handleRedirection(screen);
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

  void handleRedirection(String screen) {
    /*  if(screen == "4" || screen == "5" || screen == "6" ){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => BiddingActivity(screen: 1)));
    }else if(screen == config.Config.solution_notification || screen ==config.Config.comment_notification || screen == config.Config.appreciate_comment || screen == config.Config.apreciate_solution){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => HomeScreen(screen: "consult"),));
    }else if(screen== "7"||screen== "10"){
      Navigator.push(_buildContext,MaterialPageRoute(builder: (context) => AppointmentDetails(screen: 1),));
    }else if(screen == "8" || screen== "9" ){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => AppointmentDetails(screen: 0)));
    }  else if (screen == "11") {
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => BiddingActivity(screen: 0),));
    }else if(screen == ''){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => BiddingActivity(screen: 2)));
    }*/
  }

  fireBaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.getToken().then((token) {
      if (Constants.DEVICE_TOKEN.length < 5) updateToken(token);
      Constants.DEVICE_TOKEN = token;
      print('Firebase Token: $token');
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('==firebase==onMessage== $message');
        _showNotificationWithDefaultSound(message['notification']['body']);
      },
      onResume: (Map<String, dynamic> message) async {
        print('==firebase==onResume== $message');
        showLocalNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('==firebase==onLaunch== $message');
        showLocalNotification(message);
      },
    );
  }

  Future updateToken(String token) async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.DEVICE_TOKEN, token);
      print("Push Messaging token: $token");
    }
  }

  Future _showNotificationWithDefaultSound(String msg) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      msg,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<Null> _filterPopUp(String body, String userID) async {
    return showDialog<Null>(
        context: _buildContext,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return new Material(
              type: MaterialType.transparency,
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      color: Colors.white,
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                      color: Colors.white,
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onLongPress: () {
                          Navigator.pop(context);
                          Clipboard.setData(new ClipboardData(text: body));
                          _scaffoldKeyNotification.currentState
                              .showSnackBar(new SnackBar(
                            content: new Text(
                              "Copied to Clipboard",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.black,
                          ));
                        },
                        child: Text(
                          body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: new Container(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          margin: EdgeInsets.only(right: 10.0),
                          height: 30.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.black26),
                          child: new Center(
                              child: new Text(
                            "DONE",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              fontFamily: "openSans",
                            ),
                          )),

                          // Add box decoration
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyNotification,
      body: Container(),
    );
  }

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
    _filterPopUp(body, title);
  }
}
