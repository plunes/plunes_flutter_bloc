import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/ui/afterLogin/AccountSettings.dart';
import 'package:plunes/ui/afterLogin/AchievementsScreen.dart';
import 'package:plunes/ui/afterLogin/EditProfileScreen.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';

import 'package:plunes/ui/afterLogin/HealthSoulutionNear.dart';
import 'package:plunes/ui/afterLogin/HelpScreen.dart';
import 'package:plunes/ui/afterLogin/SettingsScreen.dart';
import 'package:plunes/ui/beforeLogin/EnterPhoneScreen.dart';
import 'package:plunes/ui/beforeLogin/GuidedTour.dart';
import 'package:plunes/ui/beforeLogin/Registration.dart';

import 'firebase/FirebaseNotification.dart';
import 'res/ColorsFile.dart';
import 'res/FontFile.dart';
import 'ui/afterLogin/AboutUs.dart';
import 'ui/afterLogin/Coupons.dart';
import 'ui/afterLogin/HomeScreen.dart';
import 'ui/afterLogin/PlockrMainScreen.dart';
import 'ui/afterLogin/ReferScreen.dart';
import 'ui/afterLogin/SecuritySettings.dart';
import 'ui/beforeLogin/ChangePassword.dart';
import 'ui/beforeLogin/CheckOTP.dart';
import 'ui/beforeLogin/ForgotPassword.dart';
import 'ui/beforeLogin/Login.dart';
import 'ui/beforeLogin/SplashScreen.dart';
import 'ui/afterLogin/appointment_screens/appointmentScreen.dart';
import 'ui/afterLogin/appointment_screens/appointment_main_screen.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - MyApp class is for specifying the starting point of the application and their routes.
 */

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _navKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    FirebaseNotification().setUpFireBase(context, _scaffoldKey, _navKey);
  }

  ///Below method having all the routes of the application.
  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;

    return MaterialApp(
      key: _scaffoldKey,
      navigatorKey: _navKey,
      theme: ThemeData(
        fontFamily: fontFile.appDefaultFont,
        accentColor: Color(hexColorCode.defaultGreen),
        highlightColor:
            Color(CommonMethods.getColorHexFromStr(colorsFile.lightGreen)),
        indicatorColor: Color(hexColorCode.defaultGreen),
        primaryColor: Color(hexColorCode.defaultGreen),
        cursorColor: Color(hexColorCode.defaultGreen),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          actionsIconTheme: IconThemeData(
            color: Colors.black,
          ),
          color: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(hexColorCode.defaultGreen),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        AchievementsScreen.tag: (context) => AchievementsScreen(),
        HealthSolutionNear.tag: (context) => HealthSolutionNear(),
        EditProfileScreen.tag: (context) => EditProfileScreen(),
        PlockrMainScreen.tag: (context) => PlockrMainScreen(),
        ChangePassword.tag: (context) => ChangePassword(),
        EnterPhoneScreen.tag: (context) => EnterPhoneScreen(),
        SettingScreen.tag: (context) => SettingScreen(),
        SecuritySettings.tag: (context) => SecuritySettings(),
        AccountSettings.tag: (context) => AccountSettings(),
        GalleryScreen.tag: (context) => GalleryScreen(),
        ForgetPassword.tag: (context) => ForgetPassword(),
        SplashScreen.tag: (context) => SplashScreen(),
        Registration.tag: (context) => Registration(),
        GuidedTour.tag: (context) => GuidedTour(),
        HomeScreen.tag: (context) => HomeScreen(),
        HelpScreen.tag: (context) => HelpScreen(),
        ReferScreen.tag: (context) => ReferScreen(),
        Coupons.tag: (context) => Coupons(),
        CheckOTP.tag: (context) => CheckOTP(),
        AboutUs.tag: (context) => AboutUs(),
        Login.tag: (context) => Login(),
        AppointmentMainScreen.tag: (context) => AppointmentMainScreen(),

        //AppointmentScreen.tag:(context) => AppointmentScreen(),
      },
      initialRoute: SplashScreen.tag,
    );
  }
}
