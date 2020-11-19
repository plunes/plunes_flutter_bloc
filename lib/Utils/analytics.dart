import 'package:plunes/firebase/FirebaseNotification.dart';

class AnalyticsProvider {
  AnalyticsProvider._init();

  static AnalyticsProvider _instance;

  factory AnalyticsProvider() {
    if (_instance == null) {
      _instance = AnalyticsProvider._init();
    }
    return _instance;
  }

  void registerEvent(final String eventName) {
    return;
    try {
      FirebaseNotification()
          .getAnalyticsInstance()
          .logEvent(name: eventName)
          .then((value) {
//        print("fir== ana done");
      });
      FirebaseNotification()
          .getFbInstance()
          .logEvent(name: eventName)
          .then((value) {
//        print("face== ana done");
      });
    } catch (e) {
//      print("error $e");
    }
  }
}

class AnalyticsKeys {
  static const String loginKey = "Logged_In";
  static const String signUpKey = "Sign_Up";
  static const String inAppPurchaseKey = "In_App_Purchase";
  static const String beginCheckoutKey = "Begin_Checkout";
  static const String sessionStartKey = "Session_Started";
}
