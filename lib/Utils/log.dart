import 'package:flutter/foundation.dart';

class AppLog {
  static printLog(var msg) {
    debugPrint("Log : $msg");
  }

  static debugLog(var msg) {
   debugPrint("Debug Log : $msg");
  }

  static printError(var msg) {
//    print("ERROR Log : $msg");
  }
}
