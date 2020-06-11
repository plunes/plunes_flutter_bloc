import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

import 'EditProfileScreen.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - AccountSettings class account holder information and that also can be updated.
 */

// ignore: must_be_immutable
class AccountSettings extends BaseActivity {
  static const tag = '/accountSettings';

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends BaseState<AccountSettings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight,
      globalWidth,
      _userName = '',
      _userType = '',
      _specialization = '',
      _userEmail = '',
      _userLocation = '',
      _userDOB = '',
      _userEducation = '',
      _userCollege,
      _profRegNo,
      _practising,
      _experience,
      _introduction;
  bool _isNotificationEnabled = true;

  Preferences preferences;
  UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc();
    initialize();
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    super.dispose();
  }

  void initialize() {
    preferences = Preferences();
    getSharedPreferenceData();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: widget.getAppBar(context, plunesStrings.accountSettings, true),
        body: getBody());
  }

  Widget getBody() {
    return Container(
      child: Column(
        children: <Widget>[
          getSettingRow(plunesImages.settingNotificationIcon,
              plunesStrings.notifications, 0),
          widget.getDividerRow(context, 0, 0, 0),
          getSettingRow(
              plunesImages.editProfileIcon, plunesStrings.editProfile, 1),
          widget.getDividerRow(context, 0, 0, 0),
        ],
      ),
    );
  }

  Widget getSettingRow(String firstIcon, String title, int pos) {
    return InkWell(
      onTap: () async {
        switch (pos) {
          case 1:
            await CommonMethods.goToPage(
                context,
                EditProfileScreen(
                    userType: _userType,
                    fullName: _userName,
                    dateOfBirth: _userDOB,
                    education: _userEducation,
                    college: _userCollege,
                    location: _userLocation,
                    userEducation: _userEducation,
                    userCollege: _userCollege,
                    profRegNo: _profRegNo,
                    practising: _practising,
                    introduction: _introduction,
                    specializations: _specialization,
                    experience: _experience));
            getSharedPreferenceData();
            break;
        }
      },
      child: Container(
        margin: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: widget.getAssetIconWidget(
                    firstIcon, 25, 25, BoxFit.contain)),
            Expanded(
                child: widget.createTextViews(title, 16, colorsFile.black0,
                    TextAlign.start, FontWeight.normal)),
            pos == 0
                ? Switch(
                    value: _isNotificationEnabled,
                    onChanged: (value) => _switchNotification(value),
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Color(hexColorCode.defaultTransGreen),
                  )
                : Icon(Icons.keyboard_arrow_right, color: Colors.black)
          ],
        ),
      ),
    );
  }

  getSharedPreferenceData() {
    var user = UserManager().getUserDetails();
    _userType = user.userType;
    _userName = user.name;
    _userEmail = user.email;
    _userCollege = user.college;
    _profRegNo = user.profRegistrationNumber;
    _practising = user.practising;
    _userEducation = user.qualification;
    _userLocation = user.address;
    _experience = user.experience;
    _introduction = user.about;
    _userDOB = user.birthDate;
    _isNotificationEnabled = user.notificationEnabled;
    _setState();

//    _userType = preferences.getPreferenceString(Constants.PREF_USER_TYPE);
//    _userName = preferences.getPreferenceString(Constants.PREF_USERNAME);
//    _userEmail = preferences.getPreferenceString(Constants.PREF_USER_EMAIL);
//    _profRegNo =
//        preferences.getPreferenceString(Constants.PREF_PROF_REG_NUMBER);
//    _userEducation =
//        preferences.getPreferenceString(Constants.PREF_QUALIFICATION);
//    _userLocation =
//        preferences.getPreferenceString(Constants.PREF_USER_LOCATION);
//    _experience = preferences.getPreferenceString(Constants.PREF_EXPERIENCE);
//    _practising = preferences.getPreferenceString(Constants.PREF_PRACTISING);
//    _userCollege = preferences.getPreferenceString(Constants.PREF_COLLEGE);
//    _introduction =
//        preferences.getPreferenceString(Constants.PREF_INTRODUCTION);
//    _userDOB = preferences.getPreferenceString(Constants.PREF_DOB);
  }

  _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  _switchNotification(bool changedValue) async {
    _isNotificationEnabled = changedValue;
    _setState();
    var result =
        await _userBloc.turnOnOffNotification(_isNotificationEnabled ?? true);
    if (result is RequestFailed) {
      _isNotificationEnabled = !_isNotificationEnabled;
      _setState();
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        widget.showInSnackBar(
            result.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
      });
    }
  }
}
