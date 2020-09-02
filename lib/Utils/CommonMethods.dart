import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - This class is used for holding commonly and frequently used methods used within the application.
 */

class CommonMethods {
  static List<SpecialityModel> catalogueLists = new List();
  static bool checkOTPVerification = true; // true for production
  static BuildContext globalContext;

  ///Below method is to navigate the user to the received page.
  static Future<dynamic> goToPage(BuildContext buildContext, dynamic) async {
    return await Navigator.push(
        buildContext, MaterialPageRoute(builder: (buildContext) => dynamic));
  }

  ///Below method is to navigate the user to the received page clearing the below pages in the stack
  static removePagesUntilPushedName(BuildContext context, String pageRoute) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(pageRoute, (Route<dynamic> route) => false);
  }

  ///Below method is to navigate the user to the received page replacing the current one.
  static pushReplacement(BuildContext buildContext, dynamic) {
    Navigator.pushReplacement(
        buildContext, MaterialPageRoute(builder: (buildContext) => dynamic));
  }

  ///Below method is to ignore rendering issue and will show the image instead throughout the application.
  static getErrorWidgetPage() {
    ErrorWidget.builder = (FlutterErrorDetails details) => Container(
          height: double.infinity,
          width: double.infinity,
          child: InkWell(
            onTap: () {
//              Navigator.popAndPushNamed(CommonMethods.globalContext, HomeScreen.tag);
            },
            child: Image.asset(PlunesImages.errorPage, fit: BoxFit.fill),
          ),
        );
  }

  static void savePreferenceValues(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<dynamic> getPreferenceValues(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  ///Below method is here for check device platform.
  static bool isAndroidDevice() {
    bool isAndroid = true;
    if (Platform.isIOS) {
      isAndroid = false;
    } else if (Platform.isAndroid) {
      isAndroid = true;
    }
    return isAndroid;
  }

  static showLongToast(String message,
      {bool centerGravity = false, Color bgColor}) {
    Fluttertoast.showToast(
        msg: message,
        gravity: centerGravity ? ToastGravity.TOP : ToastGravity.BOTTOM,
        backgroundColor: (bgColor == null) ? Colors.transparent : bgColor,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2);
  }

  ///Below method is here for convert string color code into Hex color code.
  static int getColorHexFromStr(String colorStr) {
    colorStr = 'FF' + colorStr;
    colorStr = colorStr.replaceAll("#", '');
    int val = 0;
    int len = colorStr.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException(PlunesStrings.exceptionMsg);
      }
    }
    return val;
  }

  ///Below method is used for date different type date format.
  static format(DateTime date, String from) {
    var suffix = "th";
    var digit = date.day % 10;
    if ((digit > 0 && digit < 4) && (date.day < 11 || date.day > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }
    if (from == '0')
      return new DateFormat("EEEE d'$suffix', MMMyyyy").format(date);
    if (from == '1') return new DateFormat("dd/MM/yyyy hh:mm a").format(date);
    if (from == '2') return new DateFormat("hh:mm a").format(date);
  }

  ///Below method is used for check internet connectivity for the application .
  static Future<bool> checkInternetConnectivity() async {
    String connectionStatus;
    bool isConnected = false;
    final Connectivity _connectivity = Connectivity();
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
      if (await _connectivity.checkConnectivity() == ConnectivityResult.mobile)
        isConnected = true;
      else if (await _connectivity.checkConnectivity() ==
          ConnectivityResult.wifi)
        isConnected = true;
      else if (await _connectivity.checkConnectivity() ==
          ConnectivityResult.none) isConnected = false;
    } on PlatformException catch (e) {
      print("===internet==not connected" + e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }
    return isConnected;
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  String formatDuration(Duration position) {
    final ms = position.inMilliseconds;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;
    final hoursString = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';
    final minutesString =
        minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';
    final secondsString =
        seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';
    final formattedTime =
        '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';
    return formattedTime;
  }

  String formatTime(int time) {
    int min = (time ~/ 60);
    int sec = time % 60;
    String seconds = "00";
    String minutes = "00";
    if (sec > 0 && sec < 10) {
      seconds = "0" + sec.toString();
    } else if (sec == 0) {
      seconds = "00";
    } else if (sec > 9) {
      seconds = sec.toString();
    }
    if (min > 0 && min < 10) {
      minutes = "0" + min.toString();
    } else if (min == 0) {
      minutes = "00";
    } else if (min > 9) {
      minutes = min.toString();
    }
    return minutes + ":" + seconds;
  }

  ///Below method is used for move the textField cursor to the end of its text.
  static void moveCursorToLastPos(TextEditingController textField) {
    var cursorPos = new TextSelection.fromPosition(
        new TextPosition(offset: textField.text.length));
    textField.selection = cursorPos;
  }

  ///Below method is used for check valid email or not using given regex pattern.
  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  ///Below method is used for check entered string is number or not.
  static bool checkIfNumber(String value) {
    int limit = (value.length > 10) ? 10 : value.length;
    bool isValidNum = false;
    for (int i = 0; i < limit; i++) {
      int n = value.codeUnitAt(i);
      if (n >= 48 && n <= 57) {
        isValidNum = true;
      } else {
        isValidNum = false;
      }
    }
    return isValidNum;
  }

  ///Below method is used for open default Date Picker Dialog.
  static Future<String> selectDate(BuildContext context) async {
    var now = new DateTime.now();
    DateTime twelveYearsBack = now.subtract(new Duration(days: 0)); //3650
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: twelveYearsBack,
        firstDate: new DateTime(1900),
        lastDate: twelveYearsBack);
    return picked != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(picked.toString()))
        : '';
  }

  static Future<String> selectHoloTypeDate(BuildContext context,
      {bool isDoc = false}) async {
    var now = new DateTime.now();
    DateTime twelveYearsBack = now.subtract(new Duration(days: isDoc ? 0 : 1));
    if (isDoc) {
      twelveYearsBack = DateTime(now.year - 22, now.month, now.day);
    }
    final DateTime picked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: twelveYearsBack,
      firstDate: new DateTime(1900),
      lastDate: twelveYearsBack,
      dateFormat: "dd MMM yyyy",
      locale: DateTimePickerLocale.en_us,
      looping: true,
    );
    return picked != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(picked.toString()))
        : '';
  }

  ///Below method is used for open default Time Picker Dialog.
  static Future<String> selectTime(BuildContext context, String time) async {
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1].substring(0, 2)));
    final TimeOfDay picker = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
    return picker != null ? picker.format(context) : '';
  }

  ///Below method is used hide soft-Keyboard.
  static void hideSoftKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  ///Below method is used launch third party application or browser using given url or string value like for the open
  ///phone dialer application or default messaging application.
  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///Below method is used for open CupertinoAlertDialog with its callback.
  static void commonDialog(BuildContext context, DialogCallBack _callBack,
      String title, String content) {
    DialogCallBack callBack = _callBack;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext context,
      ) =>
          CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              if (title == plunesStrings.success) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                callBack.dialogCallBackFunction('DONE');
              }
            },
            child: new Text(
                title == plunesStrings.success
                    ? plunesStrings.ok
                    : PlunesStrings.tryAgain,
                style: TextStyle(color: Color(hexColorCode.defaultGreen))),
          ),
        ],
      ),
    );
  }

  static Widget getSpacer(double top, double bottom) {
    return Container(
      margin: EdgeInsets.only(top: top, bottom: bottom),
    );
  }

  ///Below method is used for open CupertinoAlertDialog with its callback.
  static Widget messageSubmitDialog(BuildContext context, String _title,
      TextEditingController controller, DialogCallBack _callBack) {
    DialogCallBack callBack = _callBack;
    return Dialog(
      elevation: 2.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: SingleChildScrollView(
        reverse: true,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                  Radius.circular(AppConfig.horizontalBlockSize * 7)),
              color: PlunesColors.WHITECOLOR),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                    child: Container(
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3,
                            bottom: AppConfig.verticalBlockSize * 1.5),
                        height: AppConfig.verticalBlockSize * 10,
                        child: Image.asset(PlunesImages.bdSupportImage))),
                Text(
                  PlunesStrings.ourTeamWillContactYou,
                  style: TextStyle(
                      color: PlunesColors.BLACKCOLOR,
                      fontSize: AppConfig.smallFont),
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.only(
                      right: AppConfig.horizontalBlockSize * 3,
                      bottom: AppConfig.verticalBlockSize * 4,
                      left: AppConfig.horizontalBlockSize * 3),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    style: TextStyle(fontSize: AppConfig.smallFont),
                    controller: controller,
                    maxLines: 2,
                    autofocus: false,
                    maxLength: 250,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                        hintText: plunesStrings.description,
                        counterText: "",
                        hintStyle: TextStyle(fontSize: AppConfig.smallFont)),
                  ),
                ),
                getSpacer(0, 1),
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: PlunesColors.GREYCOLOR,
                ),
                Container(
                  height: AppConfig.verticalBlockSize * 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              splashColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                              focusColor: Colors.transparent,
                              onPressed: () =>
                                  callBack.dialogCallBackFunction('CANCEL'),
                              child: Container(
                                  height: AppConfig.verticalBlockSize * 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(
                                          AppConfig.horizontalBlockSize * 4),
                                    ),
                                  ),
//                                padding: EdgeInsets.symmetric(
//                                    vertical: AppConfig.verticalBlockSize * 1.5,
//                                    horizontal:
//                                        AppConfig.horizontalBlockSize * 7),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont,
                                          color: PlunesColors.SPARKLINGGREEN),
                                    ),
                                  ))),
                        ),
                        Container(
                          height: AppConfig.verticalBlockSize * 6,
                          color: PlunesColors.GREYCOLOR,
                          width: 0.5,
                        ),
                        Expanded(
                          child: FlatButton(
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              splashColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                              focusColor: Colors.transparent,
                              onPressed: () {
                                callBack.dialogCallBackFunction('DONE');
                              },
                              child: Container(
                                  height: AppConfig.verticalBlockSize * 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(
                                          AppConfig.horizontalBlockSize * 4),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Submit',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont,
                                          color: PlunesColors.SPARKLINGGREEN),
                                    ),
                                  ))),
                        ),
                      ],
                    ),
                  ),
                )
//            Container(
//              margin: EdgeInsets.only(
//                  left: AppConfig.horizontalBlockSize * 25,
//                  right: AppConfig.horizontalBlockSize * 25,
//                  bottom: AppConfig.verticalBlockSize * 3),
//              child: InkWell(
//                borderRadius: BorderRadius.all(Radius.circular(5)),
//                onTap: () {
//                  callBack.dialogCallBackFunction('DONE');
//                  return;
//                },
//                child: CustomWidgets().getRoundedButton(
//                    plunesStrings.submit,
//                    AppConfig.horizontalBlockSize * 8,
//                    PlunesColors.GREENCOLOR,
//                    AppConfig.horizontalBlockSize * 0,
//                    AppConfig.verticalBlockSize * 1.2,
//                    PlunesColors.WHITECOLOR),
//              ),
//            )
              ]),
        ),
      ),
    );
  }

  ///Below method is used for open Alert Dialog with Animation and callback.
  static confirmationDialog(
      BuildContext context, String action, DialogCallBack _callBack) {
    DialogCallBack callBack = _callBack;

    return showGeneralDialog<bool>(
        barrierColor: Colors.black.withOpacity(0.3),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                elevation: 0.0,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 5,
                            vertical: AppConfig.verticalBlockSize * 2.5),
                        child: Text(
                          action,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      CustomWidgets().getDoubleCommonButton(context, _callBack,
                          'No', 'Yes', AppConfig.verticalBlockSize * 6)
                    ],
                  ),
                ),
              ),
//              AlertDialog(
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(
//                        AppConfig.horizontalBlockSize * 3)),
//                contentPadding: EdgeInsets.zero,
//                content: Container(
//                    margin: EdgeInsets.symmetric(
//                        vertical: AppConfig.verticalBlockSize * 6,
//                        horizontal: AppConfig.horizontalBlockSize * 15),
//                    child: Text(
//                      action,
//                      style: TextStyle(fontSize: AppConfig.mediumFont),
//                    )),
//                actions: <Widget>[
//                  new FlatButton(
//                    child: new Text(
//                      "No",
//                      style: TextStyle(
//                          fontSize: AppConfig.mediumFont, color: Colors.grey),
//                    ),
//                    onPressed: () {
//                      Navigator.pop(
//                          context, false); // showDialog() returns false
//                      callBack.dialogCallBackFunction('CANCEL');
//                    },
//                  ),
//                  new FlatButton(
//                    padding: EdgeInsets.symmetric(
//                        horizontal: AppConfig.horizontalBlockSize * 4),
//                    child: new Text(
//                      "Yes",
//                      style: TextStyle(
//                          fontSize: AppConfig.mediumFont, color: Colors.black),
//                    ),
//                    onPressed: () {
//                      Navigator.pop(context);
//                      _callBack.dialogCallBackFunction('DONE');
//                    },
//                  ),
//                ],
//              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  ///Below method is used for adding multiple images using arrayList into slide.
  static List<Slide> addSlideImages() {
    List<Slide> slides = new List();
    for (var item in PlunesImages.imageArray) {
      slides.add(new Slide(
        backgroundColor: Colors.white,
        backgroundOpacity: 0,
        backgroundImageFit: BoxFit.contain,
        backgroundOpacityColor: Colors.transparent,
        backgroundImage: item,
      ));
    }
    return slides;
  }

  ///Below method is used for generating Random OTP or 4 digit code for the OTP Verification.
  static String getRandomOTP() {
    return (Random().nextInt(9000) + 1000).toString();
  }

  ///Below method is used for fetch specific Device ID.
  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    Map<String, dynamic> deviceData;
    try {
      if (Platform.isAndroid)
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      else if (Platform.isIOS)
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return Platform.isAndroid
        ? (deviceData['id'] != null ? deviceData['id'] : '')
        : (deviceData['identifierForVendor'] != null
            ? deviceData['identifierForVendor']
            : '');
  }

  ///Below method is used for fetch specific Device information.
  static Future<String> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    Map<String, dynamic> deviceData;
    print("===this is device data");
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        print("====that is Android${deviceData['version.release']}");
        return "Android${deviceData['version.release']}";
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return 'Device Info: $deviceData';
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static String getInitialName(String _name) {
    String name = _name;
    String initialName = _name.substring(0, 1);
    List nameList = name.split(" ");
//    print(name + nameList.length.toString());
    try {
      if (name.contains("Dr")) {
        if (nameList.length > 2) {
          initialName = nameList[1].toString().substring(0, 1);
          if (nameList[2] != '') {
            initialName = nameList[1].toString().substring(0, 1) +
                nameList[2].toString().substring(0, 1);
          }
        } else if (nameList[1] != '') {
          initialName = nameList[1].toString().substring(0, 1);
        } else {
          initialName = nameList[0].toString().substring(0, 1);
        }
      } else {
        if (initialName != '') {
          initialName = nameList[0].toString().substring(0, 1);
          if (nameList.length > 1) {
            if (nameList[1] != '') {
              initialName = nameList[0].toString().substring(0, 1) +
                  nameList[1].toString().substring(0, 1);
            }
          }
        }
      }
    } catch (Exception) {
      initialName = name.substring(0, 1).toUpperCase();
    }
    return initialName;
  }

  static String getDuration(int epoch_time) {
    var curr_time = new DateTime.now().millisecondsSinceEpoch;
    int time_diff = curr_time.round() - epoch_time;

    Duration fastestMarathon = new Duration(milliseconds: time_diff);
    String s = "";
    int minutes = fastestMarathon.inMinutes;
    int hours = fastestMarathon.inHours;
    int days = fastestMarathon.inDays;
    int seconds = fastestMarathon.inSeconds;
    if (days < 30) {
      s = days.toString() + " days ago";
      if (hours < 24) {
        s = hours.toString() + "h ago";
        if (minutes < 60) {
          s = minutes.toString() + "m ago";
          if (seconds < 60) {
            if (seconds < 0) {
              s = "0 sec ago";
            } else {
              s = seconds.toString() + " sec ago";
            }
          }
        }
      }
    } else {
      s = "month ago";
    }
    return s;
  }

  static Widget getDialogView(BuildContext context, DialogCallBack callBack,
      String _title, TextEditingController controller) {
    return Card(
      color: Colors.transparent,
      elevation: 0.0,
      child: Stack(children: <Widget>[
        Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Icon(Icons.clear),
              ),
            )),
        Column(children: <Widget>[
          getSpacer(0, 20),
          Center(
              child: Text(
            _title,
            style: TextStyle(fontSize: 16),
          )),
          getSpacer(0, 20),
          Container(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                controller: controller,
                decoration: InputDecoration.collapsed(
                    hintText: plunesStrings.description),
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey, width: 0.3)),
          ),
          getSpacer(0, 20),
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
                callBack.dialogCallBackFunction('DONE');
              },
              child: Container(
                height: 35,
                width: 200,
                alignment: Alignment.center,
                child: Text(
                  plunesStrings.submit,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color(0xff01d35a)),
              ))
        ])
      ]),
    );
  }

  static String getStringInCamelCase(String someValue) {
    String stringToReturn = PlunesStrings.NA;
    try {
      if (someValue == null || someValue.trim().isEmpty) {
        return stringToReturn;
      }
      someValue = someValue.replaceAll("(", "( ");
      List<String> multipleStrings = someValue.split(" ");
      stringToReturn = null;
      multipleStrings.forEach((element) {
        if (element == null || element.isEmpty) {
        } else if (stringToReturn == null) {
          stringToReturn = element.substring(0, 1).toUpperCase();
          if (element.trim().length > 1) {
            stringToReturn =
                stringToReturn + element.substring(1).toLowerCase();
          }
        } else {
          stringToReturn =
              stringToReturn + " " + element.substring(0, 1).toUpperCase();
          if (element.trim().length > 1) {
            stringToReturn =
                stringToReturn + element.substring(1).toLowerCase();
          }
        }
      });
    } catch (e) {
      print("an error occured in getStringInCamelCase method commonMethods");
      stringToReturn = someValue;
    }
    return stringToReturn?.replaceAll("( ", "(");
  }
}
