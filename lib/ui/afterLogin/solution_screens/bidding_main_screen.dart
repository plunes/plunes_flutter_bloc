import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/blocs/solution_blocs/prev_missed_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/EditProfileScreen.dart';
import 'package:plunes/ui/afterLogin/HealthSoulutionNear.dart';
import 'package:plunes/ui/afterLogin/cart_screens/add_to_cart_main_screen.dart';
import 'package:plunes/ui/afterLogin/explore_screens/explore_main_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_received_screen.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import './previous_activity_screen.dart';
import 'package:showcaseview/showcaseview.dart';

// ignore: must_be_immutable
class BiddingMainScreen extends BaseActivity {
  final Function func;

  BiddingMainScreen(this.func);

  @override
  _BiddingMainScreenState createState() => _BiddingMainScreenState();
}

class _BiddingMainScreenState extends BaseState<BiddingMainScreen> {
  TextEditingController _textEditingController;
  FocusNode _focusNode;
  bool _progressEnabled;
  bool _canGoAhead, _isPanelOpened;
  String _failureCause, _locationMessage;
  PrevMissSolutionBloc _prevMissSolutionBloc;
  PrevSearchedSolution _prevSearchedSolution;
  Timer _timer;
  StreamController _controller, _panelStreamController;
  BuildContext _context;
  GlobalKey _searchKey = GlobalKey();
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  PanelController _panelController;
  CartMainBloc _cartBloc;

  @override
  void initState() {
    _cartBloc = CartMainBloc();
    _panelController = PanelController();
    _isPanelOpened = false;
    _highlightSearchBar();
    _locationMessage = PlunesStrings.switchToGurLoc;
    _progressEnabled = false;
    _canGoAhead = false;
    _prevMissSolutionBloc = PrevMissSolutionBloc();
    _textEditingController = TextEditingController();
    _controller = StreamController.broadcast();
    _panelStreamController = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timer = timer;
      _controller.add(null);
    });
    _focusNode = FocusNode();
    _getPreviousSolutions();
    _getUserDetails();
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == EditProfileScreen.tag &&
          mounted) {
        _getUserDetails();
      } else if (event != null &&
          event.screenName == HealthSolutionNear.tag &&
          mounted) {
        _getPreviousSolutions();
      }
    });
    super.initState();
  }

  _highlightSearchBar() {
    if (!UserManager().getWidgetShownStatus(Constants.BIDDING_MAIN_SCREEN)) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            ShowCaseWidget.of(_context)
                .startShowCase([_searchKey, _one, _two]));
        Future.delayed(Duration(seconds: 1)).then((value) {
          UserManager().setWidgetShownStatus(Constants.BIDDING_MAIN_SCREEN);
        });
      });
    }
  }

  _setLocationManually() {
    Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => LocationFetch()))
        .then((val) {
      if (val != null) {
        var addressControllerList = new List();
        addressControllerList = val.toString().split(":");
        String addr = addressControllerList[0] +
            ' ' +
            addressControllerList[1] +
            ' ' +
            addressControllerList[2];
//                          print("addr is $addr");
        var _latitude = addressControllerList[3];
        var _longitude = addressControllerList[4];
        String region = addr;
        if (addressControllerList.length == 6 &&
            addressControllerList[5] != null) {
          region = addressControllerList[5];
        }
//                          print("_latitude $_latitude");
//                          print("_longitude $_longitude");
        _checkUserLocation(_latitude, _longitude,
            address: addr, region: region);
      }
    });
  }

  @override
  void dispose() {
    _controller?.close();
    _timer?.cancel();
    _prevMissSolutionBloc?.dispose();
    _cartBloc?.dispose();
    super.dispose();
  }

  _showLocationDialog() async {
    await showDialog(
        context: _context,
        builder: (context) {
          return CustomWidgets().fetchLocationPopUp(_context);
        },
        barrierDismissible: false);
    _canGoAhead = UserManager().getIsUserInServiceLocation();
    _setState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: ShowCaseWidget(
        builder: Builder(builder: (context) {
          _context = context;
          return StreamBuilder<RequestState>(
              stream: _prevMissSolutionBloc.baseStream,
              builder: (context, snapshot) {
                return _getWidgetBody();
              });
        }),
      ),
    );
  }

  Widget _getWidgetBody() {
    return Stack(
      children: <Widget>[
        Container(
            child: _getSearchWidget(),
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 15)),
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: ExactAssetImage(PlunesImages.userLandingImage),
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: (_prevSearchedSolution == null ||
                    _prevSearchedSolution.data == null ||
                    _prevSearchedSolution.data.isEmpty)
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: <Widget>[
              (_prevSearchedSolution == null ||
                      _prevSearchedSolution.data == null ||
                      _prevSearchedSolution.data.isEmpty)
                  ? AnimatedContainer(
                      padding: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 28),
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 10),
                      duration: Duration(milliseconds: 5500),
                      curve: Curves.ease,
                      child: Hero(tag: "my_tag", child: _getSearchBar()),
                    )
                  : Container(),
              (_prevSearchedSolution == null ||
                      _prevSearchedSolution.data == null ||
                      _prevSearchedSolution.data.isEmpty)
                  ? Container()
                  : Expanded(child: _getBottomView()),
              _canGoAhead ? Container() : _getNoLocationView(),
            ],
          ),
        ),
        Container(
          child: HomePageAppBar(
            widget.func,
            () => _showLocationDialog(),
            () => _setLocationManually(),
            one: _one,
            two: _two,
          ),
          margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
        )
      ],
    );
  }

  _getBottomView() {
    return SlidingUpPanel(
      boxShadow: null,
      controller: _panelController,
//            onPanelOpened: () {
////              print("onPanelOpened");
//              _isPanelOpened = true;
////              _panelStreamController.add(null);
//            },
//            onPanelClosed: () {
////              print("onPanelClosed");
//              _isPanelOpened = false;
////              _panelStreamController.add(null);
//            },
      color: Colors.transparent,
      maxHeight: _canGoAhead
          ? AppConfig.verticalBlockSize * 80
          : AppConfig.verticalBlockSize * 53,
      minHeight: _canGoAhead
          ? AppConfig.verticalBlockSize * 60
          : AppConfig.verticalBlockSize * 53,
      panelBuilder: (s) {
        return StreamBuilder<Object>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              return Stack(
                children: <Widget>[
                  Card(
                      color: Colors.white,
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 3.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35))),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 2),
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 4.5,
                                vertical: AppConfig.verticalBlockSize * 2),
                            child: InkWell(
                              onTap: () {
                                if (_prevSearchedSolution.topSearches != null &&
                                    _prevSearchedSolution.topSearches) {
                                  return;
                                }
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             PreviousActivity()));
                              },
                              highlightColor:
                                  (_prevSearchedSolution.topSearches != null &&
                                          _prevSearchedSolution.topSearches)
                                      ? Colors.transparent
                                      : null,
                              splashColor:
                                  (_prevSearchedSolution.topSearches != null &&
                                          _prevSearchedSolution.topSearches)
                                      ? Colors.transparent
                                      : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    (_prevSearchedSolution.topSearches !=
                                                null &&
                                            _prevSearchedSolution.topSearches)
                                        ? PlunesStrings.topSearches
                                        : PlunesStrings.previousActivities,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  (_prevSearchedSolution.topSearches != null &&
                                          _prevSearchedSolution.topSearches)
                                      ? Container()
                                      : Icon(
                                          Icons.chevron_right,
                                          color: PlunesColors.GREENCOLOR,
                                          size: 35,
                                        )
                                ],
                              ),
                            ),
                          ),
                          (_prevSearchedSolution == null ||
                                  _prevSearchedSolution.data == null ||
                                  _prevSearchedSolution.data.isEmpty)
                              ? Container()
                              : Flexible(
                                  child: ListView.builder(
                                  padding: EdgeInsets.all(0.0),
                                  itemBuilder: (context, index) {
                                    if (_prevSearchedSolution
                                                .data[index].toShowSearched !=
                                            null &&
                                        _prevSearchedSolution
                                            .data[index].toShowSearched) {
                                      return Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.only(
                                            top: AppConfig.verticalBlockSize *
                                                1),
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                                AppConfig.horizontalBlockSize *
                                                    4.5,
                                            vertical:
                                                AppConfig.verticalBlockSize *
                                                    2),
                                        child: Text(
                                          _prevSearchedSolution
                                                  .data[index].specialityId ??
                                              PlunesStrings.topSearches,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }
                                    TapGestureRecognizer tapRecognizer =
                                        TapGestureRecognizer()
                                          ..onTap = () => _onViewMoreTap(index);
                                    return CustomWidgets()
                                        .getTopSearchesPrevSearchedSolutionRow(
                                            _prevSearchedSolution.data, index,
                                            onButtonTap: () {
                                      if (_prevSearchedSolution
                                                  .data[index].topSearch !=
                                              null &&
                                          _prevSearchedSolution
                                              .data[index].topSearch) {
                                        _onSolutionItemTapForTopSearches(
                                            _prevSearchedSolution.data[index]);
                                      } else {
                                        _onSolutionItemTap(
                                            _prevSearchedSolution.data[index]);
                                      }
                                    },
                                            isTopSearches:
                                                ((_prevSearchedSolution
                                                                .topSearches !=
                                                            null &&
                                                        _prevSearchedSolution
                                                            .topSearches) ||
                                                    (_prevSearchedSolution
                                                                .data[index]
                                                                .topSearch !=
                                                            null &&
                                                        _prevSearchedSolution
                                                            .data[index]
                                                            .topSearch)),
                                            onViewMoreTap: tapRecognizer);
                                  },
                                  itemCount: _prevSearchedSolution.data.length,
                                )),
                        ],
                      )),
                  Positioned(
                    child: StreamBuilder<Object>(
                        stream: _panelStreamController.stream,
                        builder: (context, snapshot) {
//                                if (_isPanelOpened != null && !_isPanelOpened) {
//                                  return Container();
//                                }
                          return AnimatedContainer(
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 10),
                            duration: Duration(milliseconds: 5500),
                            curve: Curves.ease,
                            child: Hero(
                              child: _getSearchBar(),
                              tag: "my_tag",
                            ),
                          );
                        }),
                    left: 0.0,
                    right: 0.0,
                    top: 0,
                  ),
                ],
              );
            });
      },
    );
  }

  _getCurrentLocation() async {
    var latLong = await LocationUtil().getCurrentLatLong(_context);
    if (latLong != null &&
        latLong.longitude != null &&
        latLong.latitude != null) {
      _checkUserLocation(
          latLong?.latitude?.toString(), latLong?.longitude?.toString());
    }
    _setState();
  }

  Widget _getSearchWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 3),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 10,
            ),
            child: Text(
              PlunesStrings.negotiateForBestPrice,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppConfig.largeFont),
            ),
          ),
        ],
      ),
    );
  }

  _onViewMoreTap(int index) {}

  _onSolutionItemTap(CatalogueData catalogueData) async {
    if ((!(await _getLocationPermissionStatus()) &&
            !(UserManager().getIsUserInServiceLocation())) &&
        (_prevSearchedSolution != null &&
            _prevSearchedSolution.topSearches != null &&
            _prevSearchedSolution.topSearches)) {
      await showDialog(
          context: _context,
          builder: (context) {
            return CustomWidgets().fetchLocationPopUp(_context);
          },
          barrierDismissible: false);
      if (!UserManager().getIsUserInServiceLocation()) {
        return;
      }
      _canGoAhead = UserManager().getIsUserInServiceLocation();
      _setState();
    }
    if (_prevSearchedSolution.topSearches == null ||
        !(_prevSearchedSolution.topSearches)) {
      catalogueData.isFromNotification = true;
    }
    if (catalogueData.createdAt != null &&
        catalogueData.createdAt != 0 &&
        DateTime.fromMillisecondsSinceEpoch(catalogueData.createdAt)
                .difference(DateTime.now())
                .inHours ==
            0) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SolutionReceivedScreen(catalogueData: catalogueData)));
    } else {
      if (!_canGoAhead) {
        await showDialog(
            context: _context,
            builder: (context) {
              return CustomWidgets().fetchLocationPopUp(_context);
            },
            barrierDismissible: false);
        if (!UserManager().getIsUserInServiceLocation()) {
          return;
        }
        _canGoAhead = UserManager().getIsUserInServiceLocation();
        _setState();
      }
      catalogueData.isFromNotification = false;
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BiddingLoading(catalogueData: catalogueData)));
    }
    _canGoAhead = UserManager().getIsUserInServiceLocation();
    _setState();
    _getPreviousSolutions();
    _getCartCount();
  }

  _onSolutionItemTapForTopSearches(CatalogueData catalogueData) async {
    if ((!(await _getLocationPermissionStatus()) &&
        !(UserManager().getIsUserInServiceLocation()))) {
      await showDialog(
          context: _context,
          builder: (context) {
            return CustomWidgets().fetchLocationPopUp(_context);
          },
          barrierDismissible: false);
      if (!UserManager().getIsUserInServiceLocation()) {
        return;
      }
      _canGoAhead = UserManager().getIsUserInServiceLocation();
      _setState();
    }
    if (!_canGoAhead) {
      await showDialog(
          context: _context,
          builder: (context) {
            return CustomWidgets().fetchLocationPopUp(_context);
          },
          barrierDismissible: false);
      if (!UserManager().getIsUserInServiceLocation()) {
        return;
      }
      _canGoAhead = UserManager().getIsUserInServiceLocation();
      _setState();
    }
    catalogueData.isFromNotification = false;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BiddingLoading(catalogueData: catalogueData)));
    _canGoAhead = UserManager().getIsUserInServiceLocation();
    _setState();
    _getPreviousSolutions();
    _getCartCount();
  }

  _getUserDetails() async {
    _canGoAhead = UserManager().getIsUserInServiceLocation();
    var user = UserManager().getUserDetails();
    if (user?.latitude != null &&
        user?.longitude != null &&
        user.latitude.isNotEmpty &&
        user.longitude.isNotEmpty &&
        user.latitude != "0.0" &&
        user.latitude != "0" &&
        user.longitude != "0.0" &&
        user.longitude != "0") {
      _locationMessage = PlunesStrings.switchToGurLoc;
      _setState();
      _checkUserLocation(user?.latitude, user?.longitude);
    } else {
      await Future.delayed(Duration(milliseconds: 400));
      _getCurrentLocation();
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  _checkUserLocation(var latitude, var longitude,
      {String address, String region}) async {
    if (!_progressEnabled) {
      _progressEnabled = true;
      _setState();
    }
    UserBloc()
        .isUserInServiceLocation(latitude, longitude,
            address: address, region: region)
        .then((result) {
      if (result is RequestSuccess) {
        CheckLocationResponse checkLocationResponse = result.response;
        if (checkLocationResponse != null &&
            checkLocationResponse.msg != null &&
            checkLocationResponse.msg.isNotEmpty) {
          _failureCause = checkLocationResponse.msg;
        }
      } else if (result is RequestFailed) {
        _failureCause = result.failureCause;
      }
      _canGoAhead = UserManager().getIsUserInServiceLocation();
      _progressEnabled = false;
      _setState();
    });
  }

  Widget _getNoLocationView() {
    return FutureBuilder<bool>(
        initialData: false,
        future: _getLocationPermissionStatus(),
        builder: (context, snapShot) {
          return InkWell(
            onTap: () {
              if (_progressEnabled) {
                return;
              }
              Navigator.of(context)
                  .push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          LocationFetch()))
                  .then((val) {
                if (val != null) {
                  var addressControllerList = new List();
                  addressControllerList = val.toString().split(":");
                  String addr = addressControllerList[0] +
                      ' ' +
                      addressControllerList[1] +
                      ' ' +
                      addressControllerList[2];
//                                    print("addr is $addr");
                  var _latitude = addressControllerList[3];
                  var _longitude = addressControllerList[4];
                  String region = addr;
                  if (addressControllerList.length == 6 &&
                      addressControllerList[5] != null) {
                    region = addressControllerList[5];
                  }
//                                    print("_latitude $_latitude");
//                                    print("_longitude $_longitude");
                  _checkUserLocation(_latitude, _longitude,
                      address: addr, region: region);
                }
              });
            },
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Container(
                      color: Color(0xff99000000),
                      padding:
                          EdgeInsets.all(AppConfig.horizontalBlockSize * 5),
                      child: Stack(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              _progressEnabled
                                  ? CustomWidgets().getProgressIndicator()
                                  : Icon(
                                      Icons.location_off,
                                      color: PlunesColors.GREENCOLOR,
                                      size: AppConfig.verticalBlockSize * 4,
                                    ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    !(snapShot.data)
                                        ? _progressEnabled
                                            ? "Verifying location. . ."
                                            : _failureCause ?? _locationMessage
                                        : _failureCause ?? _locationMessage,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: AppConfig.mediumFont),
                                  ),
                                ),
                              ),
//                            InkWell(
//                                onTap: () {
//                                  Navigator.of(context)
//                                      .push(PageRouteBuilder(
//                                          opaque: false,
//                                          pageBuilder:
//                                              (BuildContext context, _, __) =>
//                                                  LocationFetch()))
//                                      .then((val) {
//                                    if (val != null) {
//                                      var addressControllerList = new List();
//                                      addressControllerList =
//                                          val.toString().split(":");
//                                      String addr = addressControllerList[0] +
//                                          ' ' +
//                                          addressControllerList[1] +
//                                          ' ' +
//                                          addressControllerList[2];
////                                    print("addr is $addr");
//                                      var _latitude = addressControllerList[3];
//                                      var _longitude = addressControllerList[4];
////                                    print("_latitude $_latitude");
////                                    print("_longitude $_longitude");
//                                      _checkUserLocation(_latitude, _longitude,
//                                          address: addr);
//                                    }
//                                  });
//                                },
//                                child: Container(
//                                  color: PlunesColors.LIGHTGREYCOLOR,
//                                  padding: EdgeInsets.all(6.0),
//                                  height: AppConfig.verticalBlockSize * 7,
//                                  width: AppConfig.horizontalBlockSize * 12,
//                                  child: Image.asset(
//                                    PlunesImages.userLandingGoogleIcon,
//                                    color: PlunesColors.GREENCOLOR,
//                                  ),
//                                ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void _getPreviousSolutions() async {
    var requestState = await _prevMissSolutionBloc.getPreviousSolutions();
    if (requestState is RequestSuccess) {
      _prevSearchedSolution = requestState.response;
      _setState();
    }
  }

  Future<bool> _getLocationPermissionStatus() async {
    bool _hasLocationPermission = true;
    try {
      if (Platform.isIOS) {
        PermissionStatus permissionStatus =
            await Permission.getSinglePermissionStatus(PermissionName.Location);
        if (permissionStatus != PermissionStatus.allow) {
          _hasLocationPermission = false;
          _locationMessage = PlunesStrings.turnOnLocationService;
        }
      } else {
        var permissionList =
            await Permission.getPermissionsStatus([PermissionName.Location]);
        permissionList.forEach((element) {
          if (element.permissionName == PermissionName.Location &&
              element.permissionStatus != PermissionStatus.allow) {
            _hasLocationPermission = false;
            _locationMessage = PlunesStrings.turnOnLocationService;
          }
        });
      }
      if (!_hasLocationPermission) {
        return _hasLocationPermission;
      }
      var user = UserManager().getUserDetails();
      if (user?.latitude == null ||
          user?.longitude == null ||
          user.latitude.isNotEmpty ||
          user.longitude.isNotEmpty ||
          user.latitude == "0.0" ||
          user.latitude == "0" ||
          user.longitude == "0.0" ||
          user.longitude == "0") {
        _hasLocationPermission = false;
        _locationMessage = PlunesStrings.pleaseSelectLocation;
      }
    } catch (e) {
      print("error is " + e);
    }
    return _hasLocationPermission;
  }

  Widget _getSearchBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
            child: InkWell(
          focusColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
//                              if ((!(await _getLocationPermissionStatus()) &&
//                                  !(UserManager()
//                                      .getIsUserInServiceLocation()))) {
//                                widget.showInSnackBar(
//                                    PlunesStrings.pleaseSelectALocation,
//                                    PlunesColors.GREYCOLOR,
//                                    scaffoldKey);
//                                return;
//                              }
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => EnterAdditionalUserDetailScr()));
            return;
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SolutionBiddingScreen()));
            _canGoAhead = UserManager().getIsUserInServiceLocation();
            if (_canGoAhead) {
              _setState();
            }
            _getPreviousSolutions();
            _getCartCount();
          },
          child: IgnorePointer(
            ignoring: true,
            child: CustomWidgets().getShowCase(_searchKey,
                child: CustomWidgets().searchBar(
                    searchController: _textEditingController,
                    isRounded: true,
                    focusNode: _focusNode,
                    hintText: plunesStrings.searchHint),
                title: plunesStrings.search,
                description: PlunesStrings.searchDesc),
          ),
        )),
//                InkWell(
//                    onTap: () {
//                      Navigator.of(context)
//                          .push(PageRouteBuilder(
//                              opaque: false,
//                              pageBuilder: (BuildContext context, _, __) =>
//                                  LocationFetch()))
//                          .then((val) {
//                        if (val != null) {
//                          var addressControllerList = new List();
//                          addressControllerList = val.toString().split(":");
//                          String addr = addressControllerList[0] +
//                              ' ' +
//                              addressControllerList[1] +
//                              ' ' +
//                              addressControllerList[2];
////                          print("addr is $addr");
//                          var _latitude = addressControllerList[3];
//                          var _longitude = addressControllerList[4];
////                          print("_latitude $_latitude");
////                          print("_longitude $_longitude");
//                          _checkUserLocation(_latitude, _longitude,
//                              address: addr);
//                        }
//                      });
//                    },
//                    child: Container(
//                      padding: EdgeInsets.all(6.0),
//                      height: AppConfig.verticalBlockSize * 5,
//                      width: AppConfig.horizontalBlockSize * 10,
//                      child: Image.asset(
//                        PlunesImages.userLandingGoogleIcon,
//                      ),
//                    ))
      ],
    );
  }

  void _getCartCount() {
    _cartBloc.getCartCount();
  }
}

// ignore: must_be_immutable
class HomePageAppBar extends StatefulWidget {
  final Function onDrawerTap, onSetLocationTap, onSetLocationManually;
  bool hasSearchBar;
  final GlobalKey<State<StatefulWidget>> two, one;
  Function refreshCartItems;
  String searchBarText;

  HomePageAppBar(
      this.onDrawerTap, this.onSetLocationTap, this.onSetLocationManually,
      {this.two,
      this.one,
      this.hasSearchBar,
      this.searchBarText,
      this.refreshCartItems});

  @override
  _HomePageAppBarState createState() => _HomePageAppBarState();
}

class _HomePageAppBarState extends State<HomePageAppBar> {
  initState() {
//    Future.delayed(Duration(milliseconds: 900)).then((value) {
//      if (!UserManager().getWidgetShownStatus(Constants.BIDDING_MAIN_SCREEN)) {
//        WidgetsBinding.instance.addPostFrameCallback(
//            (_) => ShowCaseWidget.of(context).startShowCase([_one, _two]));
//      }
//    });
    super.initState();
  }

  _showLocationDialog(bool isCalledFromHomeScreen) async {
    await showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets().fetchLocationPopUp(context,
              isCalledFromHomeScreen: isCalledFromHomeScreen);
        },
        barrierDismissible: false);
    // _canGoAhead = UserManager().getIsUserInServiceLocation();
    _setState();
  }

  Future<RequestState> _getLocationStatusForTop() async {
    RequestState _requestState;
    var user = UserManager().getUserDetails();
    if (user?.latitude != null &&
        user?.longitude != null &&
        user.latitude.isNotEmpty &&
        user.longitude.isNotEmpty &&
        user.latitude != "0.0" &&
        user.latitude != "0" &&
        user.longitude != "0.0" &&
        user.longitude != "0") {
      String address = await LocationUtil()
          .getAddressFromLatLong(user.latitude, user.longitude);
      _requestState = RequestSuccess(
          response: LocationAppBarModel(
              address: (address != null &&
                      address == PlunesStrings.enterYourLocation)
                  ? PlunesStrings.enterYourLocation
                  : address,
              hasLocation: (address != null &&
                      address == PlunesStrings.enterYourLocation)
                  ? false
                  : true));
    } else {
      _requestState = RequestSuccess(
          response: LocationAppBarModel(
              address: PlunesStrings.enterYourLocation, hasLocation: false));
    }
    return _requestState;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {
            widget.onDrawerTap();
            return;
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.menu,
              color: PlunesColors.BLACKCOLOR,
            ),
          ),
        ),
        Expanded(
            child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              (widget.hasSearchBar != null && widget.hasSearchBar)
                  ? Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          widget.searchBarText,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : Flexible(child: _getLocationWidget()),
              Container(
                child: StreamBuilder<Object>(
                    stream: FirebaseNotification().notificationStream,
                    builder: (context, snapshot) {
                      return IconButton(
                        icon: Stack(
                          children: [
                            (FirebaseNotification().getCartCount() != null &&
                                    FirebaseNotification().getCartCount() != 0)
                                ? Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${FirebaseNotification().getCartCount() < 10 ? FirebaseNotification().getCartCount() : 9}",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    margin: EdgeInsets.only(
                                        right: AppConfig.horizontalBlockSize *
                                            1.5),
                                    height: AppConfig.verticalBlockSize * 3,
                                    width: double.infinity,
                                  )
                                : Container(),
                            Image.asset(
                              (FirebaseNotification().getCartCount() != null &&
                                      FirebaseNotification().getCartCount() !=
                                          0)
                                  ? PlunesImages.itemInCartImage
                                  : PlunesImages.cartImage,
                              color: (FirebaseNotification().getCartCount() !=
                                          null &&
                                      FirebaseNotification().getCartCount() !=
                                          0)
                                  ? null
                                  : PlunesColors.BLACKCOLOR,
                              height: AppConfig.verticalBlockSize * 4,
                              width: AppConfig.horizontalBlockSize * 8,
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddToCartMainScreen(
                                        hasAppBar: true,
                                      )));
                        },
                      );
                    }),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getLocationWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 5),
      child: FutureBuilder<RequestState>(
        future: _getLocationStatusForTop(),
        builder: (context, snapshot) {
          if (snapshot.data is RequestSuccess) {
            RequestSuccess reqSuccess = snapshot.data;
            LocationAppBarModel locationModel = reqSuccess.response;
            if (locationModel != null && locationModel.hasLocation) {
              return InkWell(
                onTap: () {
                  _showLocationDialog(false);
                  return;
                },
                onDoubleTap: () {},
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        plunesImages.locationIcon,
                        color: PlunesColors.BLACKCOLOR,
                        height: AppConfig.verticalBlockSize * 3,
                        width: AppConfig.horizontalBlockSize * 5,
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 5.0, right: 3),
                          child: Tooltip(
                              message: locationModel.address,
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 5),
                              preferBelow: true,
                              child: Text(
                                locationModel.address,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(fontSize: 15),
                              )),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#4F4F4F")),
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return InkWell(
                onDoubleTap: () {},
                onTap: () {
                  _showLocationDialog(true);
                  return;
                },
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        plunesImages.locationIcon,
                        color: PlunesColors.BLACKCOLOR,
                        height: AppConfig.verticalBlockSize * 3,
                        width: AppConfig.horizontalBlockSize * 5,
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 5.0, right: 3),
                          child: Text(
                            "Please enter your location",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#4F4F4F")),
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          }
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  plunesImages.locationIcon,
                  color: PlunesColors.BLACKCOLOR,
                  height: AppConfig.verticalBlockSize * 3,
                  width: AppConfig.horizontalBlockSize * 5,
                ),
                Flexible(
                  child: Container(
                      margin: EdgeInsets.only(left: 5.0, right: 3),
                      child: Text(
                        PlunesStrings.processing,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        softWrap: false,
                        maxLines: 1,
                        style: TextStyle(fontSize: 15),
                      )),
                ),
                Container(
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(CommonMethods.getColorHexFromStr("#4F4F4F")),
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getSearchBar() {
    return Card(
      elevation: 1.8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        margin: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 2,
            right: AppConfig.horizontalBlockSize * 2),
        height: AppConfig.verticalBlockSize * 5.5,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SolutionBiddingScreen()))
                .then((value) {
              if (widget.refreshCartItems != null) {
                widget.refreshCartItems();
              }
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 4),
                child: Icon(
                  Icons.search,
                  color: Color(CommonMethods.getColorHexFromStr("#B1B1B1")),
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(bottom: 2),
                  child: IgnorePointer(
                    ignoring: true,
                    child: TextField(
                      textAlign: TextAlign.left,
                      onTap: () {},
                      decoration: InputDecoration(
                        hintMaxLines: 1,
                        hintText: widget.searchBarText ??
                            'Search the desired service',
                        hintStyle: TextStyle(
                          color: Color(0xffB1B1B1).withOpacity(1.0),
                          fontSize: AppConfig.mediumFont,
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//                                          if (index ==
//                                              _prevSearchedSolution
//                                                  .data.length) {
//                                            return InkWell(
//                                              onTap: () {
//                                                Navigator.push(
//                                                    context,
//                                                    MaterialPageRoute(
//                                                        builder: (context) =>
//                                                            ExploreMainScreen(
//                                                              hasAppBar: true,
//                                                            ))).then((value) {
//                                                  _getPreviousSolutions();
//                                                });
//                                              },
//                                              child: Container(
//                                                alignment: Alignment.center,
//                                                padding: EdgeInsets.symmetric(
//                                                    vertical: AppConfig
//                                                            .verticalBlockSize *
//                                                        1.8),
//                                                child: Text(
//                                                  PlunesStrings.exploreMore,
//                                                  style: TextStyle(
//                                                      color: PlunesColors
//                                                          .GREENCOLOR,
//                                                      fontSize: 15,
//                                                      fontWeight:
//                                                          FontWeight.w600),
//                                                ),
//                                                width: double.infinity,
//                                              ),
//                                            );
//                                          }
