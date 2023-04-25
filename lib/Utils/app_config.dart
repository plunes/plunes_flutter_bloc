import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

/// This class is for app configurations (i.e Media query,App textSize )
class AppConfig {
  static MediaQueryData? _mediaQueryData;
  static late double screenFullHeight;
  static late double screenFullWidth;
  static double? screenHeightWihPaddingExclude;
  static double? screenWidthWihPaddingExclude;
  static double? smallFont;
  static double? verySmallFont;
  static double? mediumFont;
  static double? largeFont;
  static double? extraLargeFont;
  static double? veryExtraLargeFont;
  static late double horizontalBlockSize;
  static late double verticalBlockSize;
  static GlobalKey<NavigatorState>? _navKey;

  static void setNavKey(GlobalKey<NavigatorState> navKey) {
    _navKey = navKey;
  }

  static GlobalKey<NavigatorState>? getNavKey() {
    return _navKey;
  }

  static init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenFullHeight = _mediaQueryData!.size.height;
    screenFullWidth = _mediaQueryData!.size.width;
    horizontalBlockSize = screenFullWidth / 100;
    verticalBlockSize = screenFullHeight / 100;
    screenHeightWihPaddingExclude = (_mediaQueryData!.size.height -
            (_mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom)) /
        100;

    screenWidthWihPaddingExclude = (_mediaQueryData!.size.width -
            (_mediaQueryData!.padding.left + _mediaQueryData!.padding.right)) /
        100;
    _setTextSizes();
  }

  static MediaQueryData? getMediaQuery() {
    return _mediaQueryData;
  }

  ///This method used to set different text size
  static void _setTextSizes() {
    verySmallFont = horizontalBlockSize * 3.0;
    smallFont = horizontalBlockSize * 3.5;
    mediumFont = horizontalBlockSize * 4.2;
    largeFont = horizontalBlockSize * 5.3;
    extraLargeFont = horizontalBlockSize * 6.0;
    veryExtraLargeFont = horizontalBlockSize * 14.0;
  }

  ///This method used to get the type of device
//  static Future<String> getDeviceType() async {
//    return await PreferenceHelper().getString(LocalStorageKeys.platform);
//  }

  ///determines the platform
  static bool isAndroidPlatform() {
    return Platform.isAndroid;
  }

  static Future<String?> getAppSignature() async {
    String? signature = await SmsVerification.getAppSignature();
//    print("signature $signature");
    return signature;
  }
}
