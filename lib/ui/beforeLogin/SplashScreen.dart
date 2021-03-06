import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
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

class SplashScreen extends BaseActivity {
  static const tag = 'splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> implements DialogCallBack {
  Timer mTimer;
  Preferences preferences;
  var location = new loc.Location();
  @override
  void initState() {
    super.initState();
    startTime();
  }
  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  getData(data) {
    for (int i = 0; i < data.posts.length; i++) {
      CommonMethods.catalogueLists.add(data.posts[i]);
    }
    mTimer = new Timer(Duration(seconds: 7), navigationPage);

  }

  startTime() async {
    await Preferences().instantiatePreferences();
    preferences = new Preferences();
    var getLocation = await location.getLocation();
    var  _latitude = getLocation.latitude.toString();
    var _longitude = getLocation.longitude.toString();

    if(_latitude!=null && _longitude!=null){
      preferences.setPreferencesString(Constants.LATITUDE, _latitude);
      preferences.setPreferencesString(Constants.LONGITUDE, _longitude);
    }
    bloc.fetchCatalogue(context, this);
    bloc.allCatalogue.listen((data) {
      getData(data);
    }, onDone: () {
      bloc.dispose();
    });
    return mTimer;
  }

   navigationPage() {
    Route route;
    if (preferences.getPreferenceString(Constants.ACCESS_TOKEN) != null && preferences.getPreferenceString(Constants.ACCESS_TOKEN).length > 0) {
      route = MaterialPageRoute(builder: (context) => HomeScreen());
    } else {
      route = MaterialPageRoute(builder: (context) => GuidedTour());
    }
    Navigator.pushReplacement(context, route);

  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;

    return Scaffold(
        backgroundColor: Color(hexColorCode.defaultGreen),
        body: Center(child: Image.asset(AssetsImagesFile.splashImage)));
  }

  @override
  dialogCallBackFunction(String action) {
    startTime();
  }
}
