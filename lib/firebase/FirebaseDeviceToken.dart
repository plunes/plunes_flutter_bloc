import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * Created by - Plunes Technologies .
 * Description - FirebaseDeviceToken class is for storing FCM Device Token .
 */

class FirebaseDeviceToken{

  FirebaseMessaging _firebaseMessaging;

  void generateDeviceToken() {
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) {
      if (Constants.DEVICE_TOKEN.length < 5) {
        updateToken(token);
      }
      Constants.DEVICE_TOKEN = token;
      print("FireBasedeviceToken===" + token.toString());
    });
  }

  Future updateToken(String token) async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.DEVICE_TOKEN, token);
      print("Push Messaging token: $token");
    }
  }

}