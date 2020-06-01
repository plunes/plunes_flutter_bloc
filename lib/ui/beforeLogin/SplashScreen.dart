import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/afterLogin/HomeScreen.dart';

import 'GuidedTour.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - SplashScreen class is for showing the app logo for 7 seconds delay and doing processing in the background.
 */

// ignore: must_be_immutable
class SplashScreen extends BaseActivity {
  static const tag = 'splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> implements DialogCallBack {
  Timer mTimer;
  Preferences preferences;
  UserBloc _userBloc;
  var location = new loc.Location();

  @override
  void initState() {
    _userBloc = UserBloc();
    super.initState();
    startTime();
  }

  @override
  void dispose() {
    super.dispose();
    _userBloc.dispose();
    bloc.dispose();
  }

  startTime() async {
    await Preferences().instantiatePreferences();
    preferences = new Preferences();
    await Future.delayed(Duration(seconds: 2));
    _userBloc.getSpeciality();
    navigationPage();
  }

  navigationPage() {
    Route route;
    if (preferences.getPreferenceString(Constants.ACCESS_TOKEN) != null &&
        preferences.getPreferenceString(Constants.ACCESS_TOKEN).length > 0) {
      route = MaterialPageRoute(builder: (context) => HomeScreen());
    } else {
      route = MaterialPageRoute(builder: (context) => GuidedTour());
    }
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    AppConfig.init(context);
    return Scaffold(
        backgroundColor: Color(hexColorCode.defaultGreen),
        body: Center(child: Image.asset(PlunesImages.splashImage)));
  }

  @override
  dialogCallBackFunction(String action) {
    startTime();
  }
}
