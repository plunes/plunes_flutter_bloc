import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'MyApp.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - MyApp class is for specifying the starting point of the application.
 */

///Below  method is the entry point of the application.
main() {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white, // navigation bar color
    statusBarColor: Colors.white, // status bar color
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runZoned(() {
            runApp(MyApp());
          }, onError: Crashlytics.instance.recordError));
}
