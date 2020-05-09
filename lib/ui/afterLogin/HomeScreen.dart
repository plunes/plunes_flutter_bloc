import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/afterLogin/AvailabilitySelectionScreen.dart';
import 'package:plunes/ui/afterLogin/doc_hos_screen/hosptal_overview_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_main_screen.dart';

import 'AboutUs.dart';
import 'Coupons.dart';
import 'EditProfileScreen.dart';
import 'HealthSoulutionNear.dart';
import 'HelpScreen.dart';
import 'NotificationScreen.dart';
import 'PlockrMainScreen.dart';
import 'ProfileScreen.dart';
import 'ReferScreen.dart';
import 'SettingsScreen.dart';
import 'appointment_screens/appointmentScreen.dart';
import 'appointment_screens/appointment_main_screen.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - HomeScreen class is the main class which will open after login, it's just a Dashboard of the application.
 */

// ignore: must_be_immutable
class HomeScreen extends BaseActivity {
  static const tag = '/homescreen';
  final int screenNo;

  HomeScreen({Key key, this.screenNo}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight,
      globalWidth,
      _userType = '',
      from = '',
      _userName = '',
      _imageUrl,
      specialities = '',
      _selectedIndex = 0,
      count = 0,
      screen;
  bool _showBadge = false, progress = false, isSelected = false;
  final List<Widget> _widgetOptionsForUser = [
    BiddingMainScreen(),
    PlockrMainScreen(),
    NotificationScreen(),
  ];
  final List<Widget> _widgetOptionsForDoctor = [
    HospitalDoctorOverviewScreen(),
//    PlockrMainScreen(),
    NotificationScreen(),
//    ProfileScreen()
  ];
  final List<Widget> _widgetOptionsHospital = [
    HospitalDoctorOverviewScreen(),
    NotificationScreen(),
//    ProfileScreen()
  ];
  Preferences preferences;
  List<String> selectedPositions = new List();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    bloc.disposeProfileBloc();
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
        extendBodyBehindAppBar:
            (_selectedIndex == 0 && _userType == Constants.user) ? true : false,
        appBar: widget.getHomeAppBar(
            context,
            _userType != Constants.user
                ? (_selectedIndex == 1
                    ? plunesStrings.notifications
                    : _selectedIndex == 3
                        ? plunesStrings.profiles
                        : _selectedIndex == 2
                            ? plunesStrings.notifications
                            : '')
                : (_selectedIndex == 1
                    ? plunesStrings.plockr
                    : _selectedIndex == 2 ? plunesStrings.notifications : ''),
            isSelected,
            selectedPositions,
            from,
            this,
            isSolutionPageSelected:
                (_selectedIndex == 0 && _userType == Constants.user)),
        drawer: getDrawerView(),
        body: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(), child: bodyView()),
        bottomNavigationBar: _userType == Constants.user
            ? getBottomNavigationViewForGeneralUser()
            : _userType == Constants.doctor
                ? getBottomNavigationViewForDoctor()
                : getBottomNavigationHospitalView());
  }

  Widget getBottomNavigationHospitalView() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 20,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      selectedItemColor: Color(hexColorCode.defaultGreen),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        bottomNavigationBarItem(plunesStrings.home, plunesImages.homeNonActive,
            plunesImages.homeActive),
        bottomNavigationBarItem(plunesStrings.notification,
            plunesImages.notificationIcon, plunesImages.notificationActiveIcon),
//        bottomNavigationBarItem(plunesStrings.profile, plunesImages.profileIcon,
//            plunesImages.profileActiveIcon)
      ],
    );
  }

  Widget getBottomNavigationViewForDoctor() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 20,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      selectedItemColor: Color(hexColorCode.defaultGreen),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        bottomNavigationBarItem(plunesStrings.home, plunesImages.homeNonActive,
            plunesImages.homeActive),
//        bottomNavigationBarItem(plunesStrings.plockr,
//            plunesImages.plockrUnselectedIcon, plunesImages.plockrSelectedIcon),
        bottomNavigationBarItem(plunesStrings.notification,
            plunesImages.notificationIcon, plunesImages.notificationActiveIcon),
//        bottomNavigationBarItem(plunesStrings.profile, plunesImages.profileIcon,
//            plunesImages.profileActiveIcon)
      ],
    );
  }

  Widget getBottomNavigationViewForGeneralUser() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 20,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      selectedItemColor: Color(hexColorCode.defaultGreen),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        bottomNavigationBarItem(plunesStrings.solution, plunesImages.bidIcon,
            plunesImages.bidActiveIcon),
        bottomNavigationBarItem(plunesStrings.plockr,
            plunesImages.plockrUnselectedIcon, plunesImages.plockrSelectedIcon),
        bottomNavigationBarItem(plunesStrings.notification,
            plunesImages.notificationIcon, plunesImages.notificationActiveIcon),
      ],
    );
  }

  BottomNavigationBarItem bottomNavigationBarItem(
      String title, String icon, String activeIcon) {
    return BottomNavigationBarItem(
        icon: (_showBadge && title == plunesStrings.notification)
            ? badgeIconWidget(icon)
            : widget.getAssetIconWidget(icon, 32, 32, BoxFit.contain),
        activeIcon:
            widget.getAssetIconWidget(activeIcon, 32, 32, BoxFit.contain),
        title: widget.createTextWithoutColor(
            title, 11.0, TextAlign.center, FontWeight.normal));
  }

  Widget bodyView() {
    return Container(
        child: _userType == Constants.user
            ? _widgetOptionsForUser[_selectedIndex]
            : _userType == Constants.doctor
                ? _widgetOptionsForDoctor[_selectedIndex]
                : _widgetOptionsHospital[_selectedIndex]);
  }

  void initialize() {
    preferences = Preferences();
    getSharedPreferencesData();
    _userType = preferences.getPreferenceString(Constants.PREF_USER_TYPE);
    if (_userType == Constants.user) {
      switch (widget.screenNo) {
        case Constants.homeScreenNumber:
          _selectedIndex = 0;
          break;
        case Constants.plockerScreenNumber:
          _selectedIndex = 1;
          break;
        case Constants.notificationScreenNumber:
          _selectedIndex = 2;
          break;
        default:
          _selectedIndex = 0;
//      case 'profile':
//        _selectedIndex = 3;
//        break;
      }
    } else {
      switch (widget.screenNo) {
        case Constants.homeScreenNumber:
          _selectedIndex = 0;
          break;
        case Constants.notificationScreenNumber:
          _selectedIndex = 1;
          break;
        default:
          _selectedIndex = 0;
      }
    }

    bloc.preferenceFetcher.listen((data) {
      if (data != null) {
        _userName = data['name'] != null ? data['name'] : '';
      }
    });

    bloc.deleteListenerFetcher.listen((data) {
      if (mounted)
        setState(() {
          if (data != null) {
            from = plunesStrings.notification;
            isSelected =
                data['isSelected'] != null ? data['isSelected'] : false;
            selectedPositions = data['selectedItemList'] != null
                ? data['selectedItemList']
                : new List();
          } else {
            isSelected = false;
            from = '';
          }
        });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2)
        _showBadge = false;
      else {
        bloc.changeAppBar(context, null);
      }
    });
  }

  void logout() {
    bloc.logoutService(context, this);
    bloc.logout.listen((data) {
      progress = false;
      if (data != null &&
          data[Constants.SUCCESS] != null &&
          data[Constants.SUCCESS]) {
        navigationPage();
      } else {
        widget.showInSnackBar(
            plunesStrings.somethingWentWrong, Colors.red, _scaffoldKey);
      }
    });
  }

  void navigationPage() {
    preferences.clearPreferences();
    Future.delayed(Duration(milliseconds: 200), () {
      return Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

  Widget badgeIconWidget(String icon) {
    return Stack(
      children: <Widget>[
        widget.getAssetIconWidget(icon, 32, 32, BoxFit.contain),
        Positioned(
          right: 0,
          child: Container(
              height: 18,
              width: 18,
              padding: EdgeInsets.all(5),
              decoration: new BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: BoxConstraints(minWidth: 12, minHeight: 12),
              child: widget.createTextViews(count.toString(), 8.0,
                  colorsFile.white, TextAlign.center, FontWeight.normal)),
        )
      ],
    );
  }

  Widget getDrawerView() {
    return Container(
      margin: EdgeInsets.only(
          top: AppConfig.verticalBlockSize * 3,
          bottom: AppConfig.verticalBlockSize * 6),
      child: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: ListView(
                    children: <Widget>[
                      Container(
                        //padding: EdgeInsets.only(top: 10),
                        // height: 100,
                        child: InkWell(
                          onTap: () => navigatePage(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                  child: _imageUrl != ''
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(_imageUrl),
                                          backgroundColor: Colors.transparent,
                                          radius: 35,
                                        )
                                      : Container(),
                                  backgroundImage:
                                      AssetImage('assets/default_img.png'),
                                  backgroundColor: Colors.transparent,
                                  radius: 35,
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    widget.createTextViews(
                                        _userName,
                                        18,
                                        colorsFile.black0,
                                        TextAlign.left,
                                        FontWeight.normal),
                                    /* _userType == Constants.user ? widget.createTextViews(stringsFile.generalUser, 16, colorsFile.lightGrey2, TextAlign.left, FontWeight.w100)
                                    : widget.createTextViews(specialities, 16, colorsFile.lightGrey2, TextAlign.left, FontWeight.w100)*/
                                  ],
                                ) /*StreamBuilder(
                             stream: bloc.preferenceFetcher,
                             builder: ((context, snapshot) {
                               if (snapshot.hasData) {
//                                 _userName = snapshot
                                 return Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: <Widget>[
                                     widget.createTextViews(_userName, 18, colorsFile.black0, TextAlign.left, FontWeight.normal),
                                     _userType == Constants.user ? widget.createTextViews(stringsFile.generalUser, 16, colorsFile.lightGrey2, TextAlign.left, FontWeight.w100)
                                         : widget.createTextViews(specialities, 16, colorsFile.lightGrey2, TextAlign.left, FontWeight.w100)
                                   ],
                                 );
                               } else if (snapshot.hasError) {
                                 print("Inside hasError");
                                 return Text(snapshot.error.toString());
                               }
                               return Center(
                                 child: CircularProgressIndicator(),
                               );
                             }),
                           )*/
                                ,
                              )),
                            ],
                          ),
                        ),
                      ),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      _userType != Constants.user
                          ? getListTile(1, plunesStrings.myAvailability,
                              plunesImages.availIcon)
                          : Container(),
                      _userType != Constants.user
                          ? widget.getDividerRow(context, 0, 0, 70.0)
                          : Container(),
                      getListTile(2, plunesStrings.appointments,
                          plunesImages.appointmentIcon),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      getListTile(
                          3, plunesStrings.settings, plunesImages.settingsIcon),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      _userType != Constants.user
                          ? getListTile(4, plunesStrings.managePayment,
                              plunesImages.walletIcon)
                          : Container(),
                      _userType != Constants.user
                          ? widget.getDividerRow(context, 0, 0, 70.0)
                          : Container(),
                      getListTile(5, plunesStrings.help, plunesImages.helpIcon),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      getListTile(
                          6, plunesStrings.aboutUs, plunesImages.aboutUsIcon),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      _userType != Constants.hospital
                          ? getListTile(7, plunesStrings.referAndEarn,
                              plunesImages.referIcon)
                          : Container(),
                      _userType != Constants.hospital
                          ? widget.getDividerRow(context, 0, 0, 70.0)
                          : Container(),
                      _userType != Constants.hospital
                          ? getListTile(8, plunesStrings.coupons,
                              plunesImages.navCouponIcon)
                          : Container(),
                      _userType != Constants.hospital
                          ? widget.getDividerRow(context, 0, 0, 70.0)
                          : Container(),
                      getListTile(
                          9, plunesStrings.logout, plunesImages.logoutIcon),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, HealthSolutionNear.tag);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          color: Color(CommonMethods.getColorHexFromStr(
                              colorsFile.white0)),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.createTextViews(
                                  plunesStrings.availOfferMsg,
                                  16.0,
                                  colorsFile.lightGrey2,
                                  TextAlign.left,
                                  FontWeight.w100)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getListTile(int position, String title, String icon) {
    return ListTile(
        onTap: () => navigatePage(position),
        leading: widget.getAssetIconWidget(icon, 25, 25, BoxFit.contain),
        title: widget.createTextViews(title, 16.0, colorsFile.lightGrey2,
            TextAlign.left, FontWeight.w100));
  }

  void navigatePage(int position) async {
    switch (position) {
      case 0:
//        setState(() {
//          _selectedIndex = 3;
//          closeDrawer();
//        });
        var user = UserManager().getUserDetails();
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                    userType: _userType,
                    fullName: _userName,
                    dateOfBirth: user.birthDate,
                    education: user.qualification,
                    college: user.college,
                    location: user.address,
                    userEducation: user.qualification,
                    userCollege: user.college,
                    profRegNo: user.profRegistrationNumber,
                    practising: user.practising,
                    introduction: user.about,
                    specializations: user.speciality,
                    experience: user.experience)));
        getSharedPreferencesData();
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AvailabilitySelectionScreen()));
        break;
      case 2:
//        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Appointments(screen: 0,),));
        // Navigator.popAndPushNamed(context, AppointmentScreen.tag);
        Navigator.popAndPushNamed(context, AppointmentMainScreen.tag);
        break;
      case 3:
        await Navigator.popAndPushNamed(context, SettingScreen.tag);
        getSharedPreferencesData();
        break;
      case 4:
//        Navigator.popAndPushNamed(context, ManagePayments.tag);
        break;
      case 5:
        Navigator.popAndPushNamed(context, HelpScreen.tag);
        break;
      case 6:
        Navigator.popAndPushNamed(context, AboutUs.tag);
        break;
      case 7:
        Navigator.popAndPushNamed(context, ReferScreen.tag);
        break;
      case 8:
        Navigator.popAndPushNamed(context, Coupons.tag);
        break;
      case 9:
        closeDrawer();
        CommonMethods.confirmationDialog(
            context, plunesStrings.logoutMsg, this);
        break;
    }
  }

  void openDrawer() {
    if (_scaffoldKey.currentState.isEndDrawerOpen)
      _scaffoldKey.currentState.openDrawer();
  }

  void closeDrawer() {
    if (_scaffoldKey.currentState.isDrawerOpen)
      _scaffoldKey.currentState.openEndDrawer();
  }

  @override
  dialogCallBackFunction(String action) {
    if (action != null && action == 'DONE') logout();
  }

  getSharedPreferencesData() {
    _userType = preferences.getPreferenceString(Constants.PREF_USER_TYPE);
    _userName = preferences.getPreferenceString(Constants.PREF_USERNAME);
    _imageUrl = preferences.getPreferenceString(Constants.PREF_USER_IMAGE);
    print("_userType is $_userType");
    _setState();
  }

  _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
