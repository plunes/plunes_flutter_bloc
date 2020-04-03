import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/afterLogin/AddDoctorScreen.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';

import 'AchievementsScreen.dart';
import 'Adapter/AchievementItemAdapter.dart';

class HospitalProfileScreen extends BaseActivity {
  final String title;

  HospitalProfileScreen({this.title});

  @override
  State createState() => new HospitalProfileScreenState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class HospitalProfileScreenState extends State<HospitalProfileScreen>
    with TickerProviderStateMixin, ImagePickerListener
    implements DialogCallBack {
  final StreamController<String> _fetchImage = new StreamController();
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();

  Stream<String> get fetchImage => _fetchImage.stream;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;
  ScrollController _scrollController = new ScrollController();
  AnimationController _animationController;
  ImagePickerHandler imagePicker;
  var globalHeight,
      globalWidth,
      imageUrl = '',
      _latitude = '',
      _bannerImageUrl = '',
      _longitude = '';
  var _speciality = '',
      _userName = '',
      _userType = '',
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
  Set _special_lities = new Set();
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<dynamic> _doctorsList = List();
  final double _appBarHeight = 200.0;
  bool isFirstTime, isBackgroundImage = false;
  var top = 0.0;
  bool isRecord = false;
  File _image;
  Preferences preferences;

  @override
  void initState() {
    isFirstTime = true;
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    _fetchImage.close();
    bloc.disposeProfileStream();
  }

  initializeForImageFetching() {
    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {});
    imagePicker = new ImagePickerHandler(this, _animationController, false);
    imagePicker.init();
  }

  void get_data() async {
/*    procedure_name.clear();
    for(int j =0; j< config.Config.procedure_speciality.length; j++){
      if(config.Config.procedure_speciality[j].contains(_speciality)){
        procedure_name.add(config.Config.procedure_name[j]);
      }
    }*/
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        key: _scaffoldKey1,
        backgroundColor: Colors.white,
        body: CustomScrollView(
          controller: _scrollController,
          physics: ScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.black,
              expandedHeight: _appBarHeight,
//                pinned: _appBarBehavior == AppBarBehavior.pinned,
              floating: _appBarBehavior == AppBarBehavior.floating ||
                  _appBarBehavior == AppBarBehavior.snapping,
              snap: _appBarBehavior == AppBarBehavior.snapping,
              leading: Container(),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            widget.showPhoto(
                                context,
                                Photo(
                                    assetName: _bannerImageUrl,
                                    title: '',
                                    caption: ''));
                          },
                          child: Container(
                            height: 250.0,
                            width: globalWidth,
                            child: _bannerImageUrl.contains('http')
                                ? Image.network(
                                    _bannerImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(_bannerImageUrl,
                                    fit: BoxFit.cover),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    plunesImages.gradientImageArray[6]),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            isBackgroundImage = true;
                            imagePicker.showDialog(context);
                          },
                          child: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  top: (10), left: globalWidth - 60),
                              child: editProfileBackButton()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.dark,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          new Flexible(
                              flex: 1,
                              child: isRecord
                                  ? Container()
                                  : Container(
                                      margin:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          getImageHeaderView(),
                                          getCatAchievementTabView(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                  child: getProfileInfoView(
                                                      25,
                                                      22,
                                                      plunesImages
                                                          .locationIcon,
                                                      plunesStrings.locationSep,
                                                      _userLocation)),
                                              editButton('1')
                                            ],
                                          ),
                                          widget.getSpacer(0.0, 15.0),
                                          widget.getDividerRow(
                                              context, 20, 20, 0.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: widget.createTextViews(
                                                    plunesStrings.introduction,
                                                    15,
                                                    colorsFile.black0,
                                                    TextAlign.start,
                                                    FontWeight.normal),
                                              ),
                                              editButton('2')
                                            ],
                                          ),
                                          widget.getSpacer(0.0, 10.0),
                                          widget.createTextViews(
                                              'Lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum',
                                              14,
                                              colorsFile.lightGrey2,
                                              TextAlign.start,
                                              FontWeight.w100),
                                          widget.getSpacer(0.0, 20.0),
                                          widget.createTextViews(
                                              plunesStrings.specialization,
                                              15,
                                              colorsFile.black0,
                                              TextAlign.start,
                                              FontWeight.normal),
                                          widget.getSpacer(0.0, 10.0),
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Color(0xff01d35a))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: DropdownButtonFormField(
                                                value: _speciality,
                                                decoration: InputDecoration
                                                    .collapsed(
                                                        hintText: plunesStrings
                                                            .chooseSpeciality,
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        hasFloatingPlaceholder:
                                                            true,
                                                        fillColor:
                                                            Colors.white),
                                                items: _dropDownMenuItems,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _speciality = val;
                                                    get_data();
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          widget.getSpacer(0.0, 20.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: widget.createTextViews(
                                                    plunesStrings.teamOfExperts,
                                                    15,
                                                    colorsFile.black0,
                                                    TextAlign.start,
                                                    FontWeight.normal),
                                              ),
                                              editButton('3')
                                            ],
                                          ),
                                          _doctorsList.length == 0
                                              ? Container()
                                              : Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  height: 150,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        _doctorsList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10),
                                                        margin: EdgeInsets.only(
                                                            bottom: 10),
                                                        child: Card(
                                                          elevation: 3,
                                                          semanticContainer:
                                                              true,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 10),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                80,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 5),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(25)),
                                                                    gradient: new LinearGradient(
                                                                        colors: [
                                                                          Color(
                                                                              0xffababab),
                                                                          Color(
                                                                              0xff686868)
                                                                        ],
                                                                        begin: FractionalOffset
                                                                            .topCenter,
                                                                        end: FractionalOffset
                                                                            .bottomCenter,
                                                                        stops: [
                                                                          0.0,
                                                                          1.0
                                                                        ],
                                                                        tileMode:
                                                                            TileMode.clamp),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    CommonMethods.getInitialName(_doctorsList[index]
                                                                            [
                                                                            'name']
                                                                        .toString()
                                                                        .toUpperCase()),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        Container(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        _doctorsList[index]
                                                                            [
                                                                            'name'],
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            color: Color(CommonMethods.getColorHexFromStr(colorsFile.black0))),
                                                                      ),
                                                                      Text(
                                                                          _doctorsList[index]
                                                                              [
                                                                              'education'],
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w100,
                                                                              color: Color(CommonMethods.getColorHexFromStr(colorsFile.lightGrey1)),
                                                                              fontSize: 16)),
                                                                      Text(
                                                                          _doctorsList[index]
                                                                              [
                                                                              'designation'],
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w100,
                                                                              color: Color(CommonMethods.getColorHexFromStr(colorsFile.lightGrey1)),
                                                                              fontSize: 16)),
                                                                      Text(
                                                                        _doctorsList[index]
                                                                            [
                                                                            'department'],
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w100,
                                                                            color: Color(CommonMethods.getColorHexFromStr(colorsFile.lightGrey1)),
                                                                            fontSize: 16),
                                                                      ),
                                                                      Text(
                                                                        _doctorsList[index]['experience'] +
                                                                            ' years of Experience',
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w100,
                                                                            color: Color(CommonMethods.getColorHexFromStr(colorsFile.lightGrey1)),
                                                                            fontSize: 16),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                                InkWell(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0,
                                                                        bottom:
                                                                            8,
                                                                        right:
                                                                            8),
                                                                    child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _doctorsList
                                                                          .removeAt(
                                                                              index);
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                          widget.getDividerRow(
                                              context, 20, 20, 0.0),
                                          widget.getSpacer(0.0, 20.0),
                                          Container(
                                            color: Color(CommonMethods
                                                .getColorHexFromStr(
                                                    colorsFile.lightBlue0)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                widget.getSpacer(0.0, 30.0),
                                                Center(
                                                    child:
                                                        widget.createTextViews(
                                                            plunesStrings
                                                                .achievementBook,
                                                            15,
                                                            colorsFile.black0,
                                                            TextAlign.center,
                                                            FontWeight.normal)),
                                                widget.getSpacer(0.0, 30.0),
                                                AchievementItemAdapter(
                                                    Constants.profile,
                                                    globalWidth,
                                                    globalHeight),
                                                widget.getSpacer(0.0, 30.0),
                                              ],
                                            ),
                                          ),
                                          widget.getSpacer(0.0, 30.0),
                                        ],
                                      ),
                                    )),
                        ]),
                  ),
                ),
              ]),
            ),
          ],
        ));
  }

  Widget getCatAchievementTabView() {
    return Container(
      margin: EdgeInsets.only(bottom: 30, left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          getSingleTabView(
              plunesImages.achievementIcon, plunesStrings.achievements),
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

  Widget getProfileInfoView(
      double height, double width, String icon, String title, String value) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: width,
                  height: height,
                  margin: EdgeInsets.only(right: 8),
                  child: widget.getAssetIconWidget(
                      icon, height, width, BoxFit.contain)),
              Expanded(
                  child: widget.createTextViews(title, 14, colorsFile.black0,
                      TextAlign.start, FontWeight.normal))
            ],
          )),
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

  Widget getImageHeaderView() {
    return Container(
      margin: EdgeInsets.only(top: 20.0, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                isBackgroundImage = false;
                imagePicker.showDialog(context);
              },
              child: Stack(
                children: <Widget>[
                  StreamBuilder<String>(
                      stream: _fetchImage.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                              child: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                snapshot.data.toString().contains('http')
                                    ? NetworkImage(snapshot.data.toString())
                                    : ExactAssetImage(snapshot.data.toString()),
                          ));
                        } else
                          return getBackImageView();
                      }),
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
        ],
      ),
    );
  }

  onBackPressed() {
    try {
      Navigator.pop(context);
    } catch (Exception) {}
  }

  Widget editProfileBackButton() {
    return Container(
        width: 30,
        height: 30,
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
              radius: 15,
            ),
            Center(
                child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 15,
            )),
          ],
        ));
  }

  @override
  fetchImageCallBack(File _image) {
    if (_image != null) {
      print("image==" + base64Encode(_image.readAsBytesSync()).toString());
      this._image = _image;
      if (isBackgroundImage) {
        _bannerImageUrl = _image.path;
        setState(() {});
      } else {
        imageUrl = _image.path;
        _fetchImage.sink.add(_image.path.toString());
      }
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

  void initialize() {
    preferences = Preferences();
    getSharedPreferenceData();
    initializeForImageFetching();
    bloc.preferenceFetcher.listen((data) {
      if (data != null) {
        getSharedPreferenceData();
      }
    });
    bloc.fetchProfileData(context, this);
    bloc.profileData.listen((data) async {
      if (data.success) {
        await bloc.saveDataInPreferences(data, context, null);
        widget.showInSnackBar(plunesStrings.success, Colors.green, _scaffoldKey1);
      } else {
        await bloc.saveDataInPreferences(data, context, null);
        widget.showInSnackBar(
            plunesStrings.somethingWentWrong, Colors.red, _scaffoldKey1);
      }
    }, onDone: () {
      bloc.disposeProfileStream();
    });
    _special_lities.add(plunesStrings.chooseSpeciality);
    _dropDownMenuItems = getDropDownMenuItems();
    _speciality = _dropDownMenuItems[0].value;
    get_data();
  }

  Future<dynamic> getSharedPreferenceData() async {
    _userType = preferences.getPreferenceString(Constants.PREF_USER_TYPE);
    _accessToken = preferences.getPreferenceString(Constants.ACCESS_TOKEN);
    _userName = preferences.getPreferenceString(Constants.PREF_USERNAME);
    _userEmail = preferences.getPreferenceString(Constants.PREF_USER_EMAIL);
    _bannerImageUrl =
        preferences.getPreferenceString(Constants.PREF_USER_BANNER_IMAGE);
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
    _fetchImage.add(preferences.getPreferenceString(Constants.PREF_USER_IMAGE));
//    _userType = Constants.hospital;
  }

  Widget editButton(String _for) {
    return Container(
      child: InkWell(
        onTap: () {
          if (_for == '1')
            fetchLocation();
          else if (_for == '3')
            CommonMethods.goToPage(context, AddDoctorScreen());
        },
        child: Container(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: widget.createTextViews(
                _for == '3' ? plunesStrings.add : plunesStrings.edit,
                15,
                colorsFile.defaultGreen,
                TextAlign.start,
                FontWeight.normal)),
      ),
    );
  }

  // here we are creating the list needed for the DropDownButton
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String speciality in _special_lities) {
      items.add(
        new DropdownMenuItem(
            value: speciality,
            child: new Text(
              speciality,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            )),
      );
    }
    return items;
  }

  fetchLocation() {
    Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => LocationFetch()))
        .then((val) {
      var addressControllerList = new List();
      addressControllerList = val.toString().split(":");
      var address = addressControllerList[0] +
          ' ' +
          addressControllerList[1] +
          ' ' +
          addressControllerList[2];
      _userLocation = address.toString().trim();
      _latitude = addressControllerList[3];
      _longitude = addressControllerList[4];
      setState(() {});
    });
  }

  @override
  dialogCallBackFunction(String action) {}
}
