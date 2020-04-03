import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/EditProfileScreen.dart';
import 'package:plunes/ui/afterLogin/HospitalProfileScreen.dart';

import 'AchievementsScreen.dart';
import 'Adapter/AchievementItemAdapter.dart';
import 'Adapter/UtilityNetItemAdapter.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - ProfileScreen class account holder information and that also can be updated.
 */

class ProfileScreen extends BaseActivity {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, ImagePickerListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final StreamController<dynamic> _fetchImage =
      new StreamController.broadcast();

  Stream<dynamic> get fetchImage => _fetchImage.stream;
  var globalHeight,
      globalWidth,
      imageUrl = '',
      _userName = '',
      _userType = '',
      _specialization = '',
      _userEmail = '',
      _accessToken = '',
      _phoneNo = '',
      _userLocation = '',
      _userDOB = '',
      _userEducation = '',
      _userCollege,
      _profRegNo,
      _practising,
      _experience,
      _introduction,
      _gender;
  List<dynamic> utilityNetList = List();
  AnimationController _animationController;
  ImagePickerHandler imagePicker;
  bool _isDoctor = false;
  Preferences preferences;
  File _image;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fetchImage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: _userType == Constants.hospital
            ? HospitalProfileScreen(title: 'Hospital Profile')
            : Column(children: <Widget>[
                Expanded(child: getBodyView()),
                getUtilityNetworkView()
              ]));
  }

  Widget getBodyView() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
            delegate: SliverChildListDelegate([
          getImageHeaderView(),
          widget.getSpacer(0.0, 10.0),
          getCatAchievementTabView(),
          getProfileInfoView(22, 22, plunesImages.locationIcon,
              plunesStrings.locationSep, _userLocation),
          widget.getSpacer(0.0, 15.0),
          getProfileInfoView(22, 22, plunesImages.emailIcon,
              plunesStrings.emailId.toString().replaceAll('*', ''), _userEmail),
          widget.getSpacer(0.0, 15.0),
          getProfileInfoView(
              22,
              22,
              _isDoctor
                  ? plunesImages.expertiseIcon
                  : plunesImages.genderIcon,
              '${_isDoctor ? plunesStrings.areaExpertise : plunesStrings.gender}',
              _isDoctor
                  ? 'Dentist'
                  : _gender == 'M' ? plunesStrings.male : plunesStrings.female),
          widget.getSpacer(0.0, 15.0),
          getProfileInfoView(
              22,
              22,
              _isDoctor ? plunesImages.clockIcon : plunesImages.phoneIcon,
              '${_isDoctor ? plunesStrings.expOfPractice : plunesStrings.phoneNumber}',
              _isDoctor ? '$_experience years' : _phoneNo),
          widget.getSpacer(0.0, 15.0),
          _isDoctor && _practising != ''
              ? getProfileInfoView(22, 22, plunesImages.practisingIcon,
                  '${plunesStrings.practising}', _practising)
              : Container(),
          widget.getSpacer(0.0, _isDoctor && _practising != '' ? 15.0 : 0),
          _userDOB != ''
              ? getProfileInfoView(22, 22, plunesImages.calIcon,
                  '${plunesStrings.dateOfBirth}', _userDOB)
              : Container(),
          widget.getSpacer(0.0, _userDOB != '' ? 15.0 : 0),
          _userEducation != ''
              ? getProfileInfoView(
                  22,
                  22,
                  plunesImages.eduIcon,
                  '${_isDoctor ? plunesStrings.qualification : plunesStrings.education}',
                  _userEducation)
              : Container(),
          widget.getSpacer(0.0, _userEducation != '' ? 15.0 : 0),
          _userCollege != ''
              ? getProfileInfoView(22, 22, plunesImages.uniIcon,
                  '${plunesStrings.college}', _userCollege)
              : Container(),
          widget.getSpacer(0.0, _userCollege != '' ? 15.0 : 0),
          getDoctorBottomView()
        ])),
      ],
    );
  }

  Widget getImageHeaderView() {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                imagePicker.showDialog(context);
                /*     if(imageUrl != ''){
                      showDialog(
                        context: context,
                        builder: (BuildContext context,) => ProfileImage(image_url: image_url, text: " ",),
                      );
                    }else{
                      _settingModalBottomSheet(context);
                    }*/
              },
              child: Stack(
                children: <Widget>[
                  imageUrl != ''
                      ? StreamBuilder(
                          stream: fetchImage,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                  child: CircleAvatar(
                                radius: 30,
                                backgroundImage: imageUrl.contains('http')
                                    ? NetworkImage(imageUrl)
                                    : ExactAssetImage(snapshot.data.toString()),
                              ));
                            } else
                              return getBackImageView();
                          })
                      : getBackImageView(),
                  Positioned(
                    child: Container(
                      height: 20,
                      width: 20,
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 12,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.green),
                    ),
                    top: 40,
                    left: 40,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: widget.createTextViews(_userName, 16, colorsFile.black0,
                  TextAlign.start, FontWeight.normal)),
          Container(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                CommonMethods.goToPage(
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
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: widget.createTextViews(
                      plunesStrings.editProfile,
                      15,
                      colorsFile.defaultGreen,
                      TextAlign.start,
                      FontWeight.normal)),
            ),
          )
        ],
      ),
    );
  }

  Widget getCatAchievementTabView() {
    return _isDoctor
        ? Container(
            margin: EdgeInsets.only(bottom: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                getSingleTabView(
                    plunesImages.catalogTabIcon, plunesStrings.catalogue),
                getSingleTabView(
                    plunesImages.achievementIcon, plunesStrings.achievements),
              ],
            ),
          )
        : Container();
  }

  Widget getProfileInfoView(
      double height, double width, String icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              width: width,
              height: height,
              margin: EdgeInsets.only(right: 10),
              child: widget.getAssetIconWidget(
                  icon, height, width, BoxFit.contain)),
          widget.createTextViews(
              title, 14, colorsFile.black0, TextAlign.start, FontWeight.normal),
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: widget.createTextViews(
                      value,
                      14,
                      colorsFile.lightGrey2,
                      TextAlign.start,
                      FontWeight.normal)))
        ],
      ),
    );
  }

  Widget getSingleTabView(String image, String title) {
    return Container(
        margin: EdgeInsets.only(right: 30, left: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AchievementsScreen.tag);
                },
                child: Container(
                    alignment: Alignment.center,
                    width: 70,
                    height: 70,
                    child: widget.getAssetIconWidget(
                        image, 70, 70, BoxFit.contain))),
            widget.getSpacer(0.0, 10),
            widget.createTextViews(title, 12, colorsFile.black0,
                TextAlign.center, FontWeight.normal)
          ],
        ));
  }

  Widget getUtilityNetworkView() {
    return _isDoctor
        ? Container()
        : Container(
            margin: EdgeInsets.only(left: 20, right: 0, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.createTextViews(plunesStrings.utilityNetwork, 15,
                    colorsFile.black0, TextAlign.start, FontWeight.normal),
                widget.getSpacer(0.0, 20.0),
                UtilityNetItemAdapter(
                    Constants.profile, globalWidth, globalHeight),
                widget.getSpacer(0.0, 10.0),
              ],
            ));
  }

  Widget getDoctorBottomView() {
    return _isDoctor
        ? Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.getDividerRow(context, 20, 20, 0.0),
                widget.createTextViews(plunesStrings.introduction, 15,
                    colorsFile.black0, TextAlign.start, FontWeight.normal),
                widget.getSpacer(0.0, 10.0),
                widget.createTextViews(
                    'Lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum',
                    14,
                    colorsFile.lightGrey2,
                    TextAlign.start,
                    FontWeight.w100),
                widget.getDividerRow(context, 20, 20, 0.0),
                widget.getSpacer(0.0, 20.0),
                Container(
                  color: Color(
                      CommonMethods.getColorHexFromStr(colorsFile.lightBlue0)),
                  child: Column(
                    children: <Widget>[
                      widget.getSpacer(0.0, 30.0),
                      Center(
                          child: widget.createTextViews(
                              plunesStrings.achievementBook,
                              15,
                              colorsFile.black0,
                              TextAlign.center,
                              FontWeight.normal)),
                      widget.getSpacer(0.0, 30.0),
                      AchievementItemAdapter(
                          Constants.profile, globalWidth, globalHeight),
                      widget.getSpacer(0.0, 30.0),
                    ],
                  ),
                ),
                widget.getSpacer(0.0, 30.0),
              ],
            ))
        : Container();
  }

  void initialize() {
    preferences = Preferences();
    getSharedPreferenceData();
    initializeForImageFetching();
    bloc.preferenceFetcher.listen((data) {
      if (data != null) {
        getSharedPreferenceData();
      }
    });
  }

  getSharedPreferenceData() {
    _userType = preferences.getPreferenceString(Constants.PREF_USER_TYPE);
    _accessToken = preferences.getPreferenceString(Constants.ACCESS_TOKEN);
    _userName = preferences.getPreferenceString(Constants.PREF_USERNAME);
    _userEmail = preferences.getPreferenceString(Constants.PREF_USER_EMAIL);
    imageUrl = preferences.getPreferenceString(Constants.PREF_USER_IMAGE);
    _phoneNo =
        preferences.getPreferenceString(Constants.PREF_USER_PHONE_NUMBER);
    _profRegNo =
        preferences.getPreferenceString(Constants.PREF_PROF_REG_NUMBER);
    _userEducation =
        preferences.getPreferenceString(Constants.PREF_QUALIFICATION);
    _userLocation =
        preferences.getPreferenceString(Constants.PREF_USER_LOCATION);
    _experience = preferences.getPreferenceString(Constants.PREF_EXPERIENCE);
    _practising = preferences.getPreferenceString(Constants.PREF_PRACTISING);
    _userCollege = preferences.getPreferenceString(Constants.PREF_COLLEGE);
    _introduction =
        preferences.getPreferenceString(Constants.PREF_INTRODUCTION);
    _gender = preferences.getPreferenceString(Constants.PREF_GENDER);
    _userDOB = preferences.getPreferenceString(Constants.PREF_DOB);
    _isDoctor = _userType == Constants.doctor ? true : false;
//    _userType = Constants.hospital;
  }

  initializeForImageFetching() {
    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {});
    imagePicker = new ImagePickerHandler(this, _animationController, false);
    imagePicker.init();
  }

  @override
  fetchImageCallBack(File _image) {
    if (_image != null) {
      print("image==" + base64Encode(_image.readAsBytesSync()).toString());
      this._image = _image;
      _fetchImage.sink.add(_image.path.toString());
    }
  }

  Widget getBackImageView() {
    return Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        child: widget.createTextViews(
            _userName != ''
                ? CommonMethods.getInitialName(_userName).toUpperCase()
                : '',
            22,
            colorsFile.white,
            TextAlign.center,
            FontWeight.normal),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          gradient: LinearGradient(
              colors: [Color(0xffababab), Color(0xff686868)],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ));
  }
}
