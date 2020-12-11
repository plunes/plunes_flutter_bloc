import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/Utils/youtube_player.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/blocs/notification_repo/notification_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/afterLogin/AvailabilitySelectionScreen.dart';
import 'package:plunes/ui/afterLogin/cart_screens/add_to_cart_main_screen.dart';
import 'package:plunes/ui/afterLogin/doc_hos_screen/hosptal_overview_screen.dart';
import 'package:plunes/ui/afterLogin/explore_screens/explore_main_screen.dart';
import 'package:plunes/ui/afterLogin/fill_coupon.dart';
import 'package:plunes/ui/afterLogin/payment/manage_payment.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_main_screen.dart';

import 'AboutUs.dart';
import 'EditProfileScreen.dart';
import 'HealthSoulutionNear.dart';
import 'HelpScreen.dart';
import 'NotificationScreen.dart';
import 'PlockrMainScreen.dart';
import 'ReferScreen.dart';
import 'SettingsScreen.dart';
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
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>();
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
    BiddingMainScreen(() => _scaffoldKey.currentState.openDrawer()),
    ExploreMainScreen(),
    AddToCartMainScreen(),
//    PlockrMainScreen(),
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
  CartMainBloc _cartBloc;

  @override
  void initState() {
    _cartBloc = CartMainBloc();
    initialize();
    _getNotifications();
    _getCartCount();
    super.initState();
  }

  @override
  void dispose() {
    bloc.disposeProfileBloc();
    _cartBloc?.dispose();
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
        appBar: (_selectedIndex == 0 && _userType == Constants.user)
            ? null
            : widget.getHomeAppBar(
                context,
                _userType != Constants.user
                    ? (_selectedIndex == 0
                        ? CommonMethods.getStringInCamelCase(
                                UserManager().getUserDetails().name) ??
                            ""
                        : _selectedIndex == 1
                            ? plunesStrings.notifications
                            : _selectedIndex == 3
                                ? plunesStrings.profiles
                                : _selectedIndex == 2
                                    ? plunesStrings.notifications
                                    : '')
                    : (_selectedIndex == 1
                        ? PlunesStrings.explore
                        : _selectedIndex == 2
                            ? PlunesStrings.cart
                            : plunesStrings.notifications),
                isSelected,
                selectedPositions,
                from,
                this,
                isSolutionPageSelected:
                    (_selectedIndex == 0 && _userType == Constants.user)),
        drawer: getDrawerView(),
        body: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(), child: bodyView()),
        bottomNavigationBar: StreamBuilder(
          builder: (context, snapshot) {
            return _userType == Constants.user
                ? getBottomNavigationViewForGeneralUser()
                : _userType == Constants.doctor
                    ? getBottomNavigationViewForDoctor()
                    : getBottomNavigationHospitalView();
          },
          stream: FirebaseNotification().notificationStream,
        ));
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
        bottomNavigationBarItemForDoctor(plunesStrings.home,
            plunesImages.homeNonActive, plunesImages.homeActive),
        bottomNavigationBarItemForDoctor(
            plunesStrings.notification,
            (FirebaseNotification().getNotificationCount() != null &&
                    FirebaseNotification().getNotificationCount() != 0)
                ? PlunesImages.notificationUnreadImage
                : plunesImages.notificationIcon,
            plunesImages.notificationActiveIcon),
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
        bottomNavigationBarItemForDoctor(plunesStrings.home,
            plunesImages.homeNonActive, plunesImages.homeActive),
//        bottomNavigationBarItem(plunesStrings.plockr,
//            plunesImages.plockrUnselectedIcon, plunesImages.plockrSelectedIcon),
        bottomNavigationBarItemForDoctor(
            plunesStrings.notification,
            (FirebaseNotification().getNotificationCount() != null &&
                    FirebaseNotification().getNotificationCount() != 0)
                ? PlunesImages.notificationUnreadImage
                : plunesImages.notificationIcon,
            plunesImages.notificationActiveIcon),
//        bottomNavigationBarItem(plunesStrings.profile, plunesImages.profileIcon,
//            plunesImages.profileActiveIcon)
      ],
    );
  }

  BottomNavigationBarItem bottomNavigationBarItemForDoctor(
      String title, String icon, String activeIcon) {
    return BottomNavigationBarItem(
        icon: (_showBadge && title == plunesStrings.notification)
            ? badgeIconWidget(icon, 32, 32)
            : (title == plunesStrings.notification)
                ? widget.getAssetIconWidget(icon, 32, 32, BoxFit.contain)
                : widget.getAssetIconWidget(icon, 32, 26, BoxFit.contain),
        activeIcon: (title == plunesStrings.notification)
            ? widget.getAssetIconWidget(activeIcon, 32, 32, BoxFit.contain)
            : widget.getAssetIconWidget(activeIcon, 32, 26, BoxFit.contain),
        title: widget.createTextWithoutColor(
            title, 11.0, TextAlign.center, FontWeight.normal));
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
        bottomNavigationBarItem(
            PlunesStrings.explore.toUpperCase(),
            PlunesImages.exploreSelectedImage,
            PlunesImages.exploreInActiveIcon),
        bottomNavigationBarItem(
            PlunesStrings.cart.toUpperCase(),
            (FirebaseNotification().getCartCount() != null &&
                    FirebaseNotification().getCartCount() != 0)
                ? PlunesImages.itemInCartImage
                : PlunesImages.cartUnSelectedImage,
            PlunesImages.cartSelectedImage),
        bottomNavigationBarItem(
            plunesStrings.notification,
            (FirebaseNotification().getNotificationCount() != null &&
                    FirebaseNotification().getNotificationCount() != 0)
                ? PlunesImages.notificationUnreadImage
                : plunesImages.notificationIcon,
            plunesImages.notificationActiveIcon),
      ],
    );
  }

  BottomNavigationBarItem bottomNavigationBarItem(
      String title, String icon, String activeIcon) {
    return BottomNavigationBarItem(
        icon: (_showBadge && title == plunesStrings.notification)
            ? badgeIconWidget(icon, 32, 32)
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
    _checkShouldPlayVideo();
    if (_userType == Constants.user) {
      switch (widget.screenNo) {
        case Constants.homeScreenNumber:
          _selectedIndex = 0;
          break;
        case Constants.exploreScreenNumber:
          _selectedIndex = 1;
          break;
        case Constants.cartScreenNumber:
          _selectedIndex = 2;
          break;
        case Constants.notificationScreenNumber:
          _selectedIndex = 3;
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
        widget.showInSnackBar(plunesStrings.somethingWentWrong,
            PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    });
  }

  void navigationPage() async {
    UserManager().clear();
    bool BIDDING_MAIN_SCREEN =
        UserManager().getWidgetShownStatus(Constants.BIDDING_MAIN_SCREEN);
    bool SOLUTION_SCREEN =
        UserManager().getWidgetShownStatus(Constants.SOLUTION_SCREEN);
    bool INSIGHT_MAIN_SCREEN =
        UserManager().getWidgetShownStatus(Constants.INSIGHT_MAIN_SCREEN);

    bool VIDEO_STATUS_FOR_USER =
        UserManager().getWidgetShownStatus(Constants.VIDEO_STATUS_FOR_USER);
    bool VIDEO_STATUS_FOR_PROF =
        UserManager().getWidgetShownStatus(Constants.VIDEO_STATUS_FOR_PROF);

    preferences.clearPreferences().then((value) {
      UserManager().setWidgetShownStatus(Constants.BIDDING_MAIN_SCREEN,
          status: BIDDING_MAIN_SCREEN);
      UserManager().setWidgetShownStatus(Constants.SOLUTION_SCREEN,
          status: SOLUTION_SCREEN);
      UserManager().setWidgetShownStatus(Constants.INSIGHT_MAIN_SCREEN,
          status: INSIGHT_MAIN_SCREEN);
      UserManager().setWidgetShownStatus(Constants.VIDEO_STATUS_FOR_USER,
          status: VIDEO_STATUS_FOR_USER);
      UserManager().setWidgetShownStatus(Constants.VIDEO_STATUS_FOR_PROF,
          status: VIDEO_STATUS_FOR_PROF);
    });
    Future.delayed(Duration(milliseconds: 100), () {
      return Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

  Widget badgeIconWidget(String icon, double height, double width) {
    return Stack(
      children: <Widget>[
        widget.getAssetIconWidget(icon, height, width, BoxFit.contain),
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
                        child: InkWell(
                          onTap: () => navigatePage(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                alignment: Alignment.center,
                                child: _imageUrl != ''
                                    ? CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 35,
                                        child: Container(
                                          height: 70,
                                          width: 70,
                                          child: ClipOval(
                                            child: CustomWidgets()
                                                .getImageFromUrl(_imageUrl,
                                                    boxFit: BoxFit.fill),
                                          ),
                                        ),
                                      )
                                    : Container(),
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
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                      _userType != Constants.user
                          ? widget.getDividerRow(context, 22, 0, 70.0)
                          : Container(),
                      _userType != Constants.user
                          ? getListTile(1, plunesStrings.myAvailability,
                              plunesImages.availIcon)
                          : Container(),
                      widget.getDividerRow(context,
                          _userType == Constants.user ? 22 : 0, 0, 70.0),
                      getListTile(2, plunesStrings.appointments,
                          plunesImages.appointmentIcon),
                      (_userType != Constants.user &&
                              !(UserManager().getUserDetails().isCentre))
                          ? widget.getDividerRow(context, 0, 0, 70.0)
                          : Container(),
                      (_userType != Constants.user &&
                              !(UserManager().getUserDetails().isCentre))
                          ? getListTile(4, plunesStrings.managePayment,
                              plunesImages.walletIcon)
                          : Container(),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      getListTile(
                          6, plunesStrings.aboutUs, plunesImages.aboutUsIcon),
                      (_userType == Constants.user)
                          ? widget.getDividerRow(context, 0, 0, 70.0)
                          : Container(),
                      (_userType == Constants.user)
                          ? getListTile(7, plunesStrings.referAndEarn,
                              plunesImages.referIcon)
                          : Container(),
                      (_userType == Constants.user)
                          ? widget.getDividerRow(context, 0, 0, 70.0)
                          : Container(),
                      (_userType == Constants.user)
                          ? getListTile(8, plunesStrings.coupons,
                              plunesImages.navCouponIcon)
                          : Container(),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      getListTile(
                          3, plunesStrings.settings, plunesImages.settingsIcon),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      getListTile(5, plunesStrings.help, plunesImages.helpIcon),
                      widget.getDividerRow(context, 0, 0, 70.0),
                      getListTile(
                          9, plunesStrings.logout, plunesImages.logoutIcon),
                      _userType == Constants.user
                          ? InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                        context, HealthSolutionNear.tag)
                                    .then((value) {
                                  EventProvider().getSessionEventBus().fire(
                                      ScreenRefresher(
                                          screenName: HealthSolutionNear.tag));
                                });
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
                          : Container(),
                      InkWell(
                        onTap: () {
                          LauncherUtil.launchUrl("tel://7011311900");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 2.0),
                          height: 50,
                          color: Color(CommonMethods.getColorHexFromStr(
                              colorsFile.white0)),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.createTextViews(
                                  PlunesStrings.reachUsAt,
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
        Navigator.pop(context);
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
        EventProvider()
            .getSessionEventBus()
            .fire(ScreenRefresher(screenName: EditProfileScreen.tag));
        break;
      case 1:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AvailabilitySelectionScreen()));
        break;
      case 2:
        Navigator.popAndPushNamed(context, AppointmentMainScreen.tag);
        break;
      case 3:
        await Navigator.popAndPushNamed(context, SettingScreen.tag);
        getSharedPreferencesData();
        EventProvider()
            .getSessionEventBus()
            .fire(ScreenRefresher(screenName: EditProfileScreen.tag));
        break;
      case 4:
        Navigator.popAndPushNamed(context, ManagePayments.tag);
        break;
      case 5:
        Navigator.popAndPushNamed(context, HelpScreen.tag);
        break;
      case 6:
        Navigator.pop(context);
        getSharedPreferencesData();
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AboutUs(userType: _userType)));
        EventProvider()
            .getSessionEventBus()
            .fire(ScreenRefresher(screenName: AboutUs.tag));
//        Navigator.popAndPushNamed(context, AboutUs.tag);
        break;
      case 7:
        Navigator.popAndPushNamed(context, ReferScreen.tag);
        break;
      case 8:
        Navigator.popAndPushNamed(context, FillCoupon.tag);
        break;
      case 9:
        closeDrawer();
        CommonMethods.confirmationDialog(
            context, plunesStrings.logoutMsg, this);
        break;
    }
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
//    print("_userType is $_userType");
    _setState();
  }

  _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _getNotifications() async {
    await Future.delayed(Duration(milliseconds: 400));
    NotificationBloc().getNotifications(shouldNotify: true);
  }

  void _checkShouldPlayVideo() {
    if (_userType == Constants.user) {
      if (!UserManager()
          .getWidgetShownStatus(Constants.VIDEO_STATUS_FOR_USER)) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            UserManager().setWidgetShownStatus(Constants.VIDEO_STATUS_FOR_USER);
//            _showPopupForUser();
          });
        });
      }
    } else {
      if (!UserManager()
          .getWidgetShownStatus(Constants.VIDEO_STATUS_FOR_PROF)) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            UserManager().setWidgetShownStatus(Constants.VIDEO_STATUS_FOR_PROF);
//            _showPopupForProf();
          });
        });
      }
    }
  }

  void _showPopupForProf() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets().getVideoPopupForUser(
              message: "Would like to see how Plunes work?",
              globalKey: _scaffoldKey);
        }).then((value) {
      if (value != null && value.toString() == PlunesStrings.watch) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    YoutubePlayerProvider(Constants.PLUNES_USER_VIDEO_DEMO)));
      }
    });
  }

  void _showPopupForUser() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets().getVideoPopupForUser(
              message: "Would like to see how Plunes work?",
              globalKey: _scaffoldKey);
        }).then((value) {
      if (value != null && value.toString() == PlunesStrings.watch) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    YoutubePlayerProvider(Constants.PLUNES_USER_VIDEO_DEMO)));
      }
    });
  }

  void _getCartCount() {
    Future.delayed(Duration(milliseconds: 401)).then((value) {
      if (_userType != null && _userType == Constants.user) {
        _cartBloc.getCartCount();
      }
    });
  }
}
