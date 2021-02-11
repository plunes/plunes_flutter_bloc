import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:plunes/Utils/custom_widgets.dart';

class PermissionUtil {
  static Future<bool> requestSpecificPermission(
      final PermissionName permissionName,
      {BuildContext context}) async {
    PermissionStatus permissionStatus;
    if (Platform.isIOS) {
      permissionStatus =
          await Permission.requestSinglePermission(permissionName);
    } else if (Platform.isAndroid) {
      var permissionList =
          await Permission.requestPermissions([permissionName]);
      permissionList.forEach((element) {
        if (element.permissionName == permissionName) {
          permissionStatus = element.permissionStatus;
        }
      });
    }
    bool permissionGiven = _hasPermission(permissionStatus);
    if (!permissionGiven && context != null) {
      _openPermissionPopUp(context, permissionName.toString()).then((value) {
        if (value != null && value) {
          Permission.openSettings();
        }
      });
    }
    return permissionGiven;
  }

  static bool _hasPermission(PermissionStatus permissionStatus) {
    if (permissionStatus != null &&
        ((permissionStatus == PermissionStatus.allow ||
            permissionStatus == PermissionStatus.always ||
            permissionStatus == PermissionStatus.whenInUse))) {
      return true;
    } else {
      return false;
    }
  }

  static Future _openPermissionPopUp(
      BuildContext context, String permissionName) async {
    bool result = await showDialog(
            context: context,
            child: CustomWidgets().showPermissionPopUp(context, permissionName),
            barrierDismissible: true) ??
        false;
    return result;
  }
}
