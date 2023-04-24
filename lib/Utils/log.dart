

import 'package:flutter/cupertino.dart';

class AppLog {
  static printLog(var msg) {
    // debugPrint("Log : $msg");
  }

  static debugLog(var msg) {
    debugPrint("DebugLog : $msg");
  }

  static printError(var msg) {
//    print("ERROR Log : $msg");
  }
}
