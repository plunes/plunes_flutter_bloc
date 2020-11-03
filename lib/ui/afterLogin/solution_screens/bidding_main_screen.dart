import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/prev_missed_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
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
import 'package:plunes/ui/afterLogin/explore_screens/explore_main_screen.dart';
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
  PrevSearchedSolution _prevSearchedSolution, _topSearchedSolutions;
  Timer _timer;
  StreamController _controller, _panelStreamController;
  BuildContext _context;
  GlobalKey _searchKey = GlobalKey();
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  PanelController _panelController;

  @override
  void initState() {
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
          return _getWidgetBody();
        }),
      ),
    );
  }

  Widget _getWidgetBody() {
    return Stack(
      children: <Widget>[
        Container(
          child: _getSearchWidget(),
          padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 15),
        ),
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: ExactAssetImage(PlunesImages.userLandingImage),
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              StreamBuilder<Object>(
                  stream: _panelStreamController.stream,
                  builder: (context, snapshot) {
                    if (_isPanelOpened != null && !_isPanelOpened) {
                      return AnimatedContainer(
                        padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 28),
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 10),
                        duration: Duration(milliseconds: 1500),
                        curve: Curves.ease,
                        child: _getSearchBar(),
                      );
                    }
                    return Container();
                  }),
              Expanded(
                child: _getBottomView(),
              ),
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
    return (_prevSearchedSolution == null ||
            _prevSearchedSolution.data == null ||
            _prevSearchedSolution.data.isEmpty)
        ? Container()
        : SlidingUpPanel(
            boxShadow: null,
            controller: _panelController,
            onPanelOpened: () {
//              print("onPanelOpened");
              _isPanelOpened = true;
              _panelStreamController.add(null);
            },
            onPanelClosed: () {
//              print("onPanelClosed");
              _isPanelOpened = false;
              _panelStreamController.add(null);
            },
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
                                StreamBuilder<Object>(
                                    stream: _panelStreamController.stream,
                                    builder: (context, snapshot) {
                                      return Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.only(
                                            top: (_isPanelOpened != null &&
                                                    !_isPanelOpened)
                                                ? AppConfig.verticalBlockSize *
                                                    1
                                                : AppConfig.verticalBlockSize *
                                                    4),
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                                AppConfig.horizontalBlockSize *
                                                    4.5,
                                            vertical:
                                                AppConfig.verticalBlockSize *
                                                    2),
                                        child: InkWell(
                                          onTap: () {
                                            if (_prevSearchedSolution
                                                        .topSearches !=
                                                    null &&
                                                _prevSearchedSolution
                                                    .topSearches) {
                                              return;
                                            }
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PreviousActivity()));
                                          },
                                          highlightColor: (_prevSearchedSolution
                                                          .topSearches !=
                                                      null &&
                                                  _prevSearchedSolution
                                                      .topSearches)
                                              ? Colors.transparent
                                              : null,
                                          splashColor: (_prevSearchedSolution
                                                          .topSearches !=
                                                      null &&
                                                  _prevSearchedSolution
                                                      .topSearches)
                                              ? Colors.transparent
                                              : null,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                (_prevSearchedSolution
                                                                .topSearches !=
                                                            null &&
                                                        _prevSearchedSolution
                                                            .topSearches)
                                                    ? PlunesStrings.topSearches
                                                    : PlunesStrings
                                                        .previousActivities,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              (_prevSearchedSolution
                                                              .topSearches !=
                                                          null &&
                                                      _prevSearchedSolution
                                                          .topSearches)
                                                  ? Container()
                                                  : Icon(
                                                      Icons.chevron_right,
                                                      color: PlunesColors
                                                          .GREENCOLOR,
                                                      size: 35,
                                                    )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                (_prevSearchedSolution == null ||
                                        _prevSearchedSolution.data == null ||
                                        _prevSearchedSolution.data.isEmpty)
                                    ? Container()
                                    : Flexible(
                                        child: ListView.builder(
                                        padding: EdgeInsets.all(0.0),
                                        itemBuilder: (context, index) {
                                          if (_prevSearchedSolution
                                                      .data[index].topSearch !=
                                                  null &&
                                              _prevSearchedSolution
                                                  .data[index].topSearch) {
                                            return Container();
                                          }
                                          TapGestureRecognizer tapRecognizer =
                                              TapGestureRecognizer()
                                                ..onTap =
                                                    () => _onViewMoreTap(index);
                                          return CustomWidgets()
                                              .getTopSearchesPrevSearchedSolutionRow(
                                                  _prevSearchedSolution.data,
                                                  index,
                                                  onButtonTap: () =>
                                                      _onSolutionItemTap(
                                                          _prevSearchedSolution
                                                              .data[index]),
                                                  isTopSearches:
                                                      (_prevSearchedSolution
                                                                  .topSearches !=
                                                              null &&
                                                          _prevSearchedSolution
                                                              .topSearches),
                                                  onViewMoreTap: tapRecognizer);
                                        },
                                        itemCount:
                                            _prevSearchedSolution.data.length,
                                      )),
                                (_topSearchedSolutions == null ||
                                        _topSearchedSolutions.data == null ||
                                        _topSearchedSolutions.data.isEmpty)
                                    ? Container()
                                    : Container(
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
                                          PlunesStrings.topSearches,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                (_topSearchedSolutions == null ||
                                        _topSearchedSolutions.data == null ||
                                        _topSearchedSolutions.data.isEmpty)
                                    ? Container()
                                    : Flexible(
                                        child: ListView.builder(
                                        padding: EdgeInsets.all(0.0),
                                        itemBuilder: (context, index) {
                                          TapGestureRecognizer tapRecognizer =
                                              TapGestureRecognizer()
                                                ..onTap =
                                                    () => _onViewMoreTap(index);
                                          return CustomWidgets()
                                              .getTopSearchesPrevSearchedSolutionRow(
                                                  _topSearchedSolutions.data,
                                                  index,
                                                  onButtonTap: () =>
                                                      _onSolutionItemTapForTopSearches(
                                                          _topSearchedSolutions
                                                              .data[index]),
                                                  isTopSearches: true,
                                                  onViewMoreTap: tapRecognizer);
                                        },
                                        itemCount:
                                            _topSearchedSolutions.data.length,
                                      )),
                              ],
                            )),
                        Positioned(
                          child: StreamBuilder<Object>(
                              stream: _panelStreamController.stream,
                              builder: (context, snapshot) {
                                if (_isPanelOpened != null && !_isPanelOpened) {
                                  return Container();
                                }
                                return AnimatedContainer(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 10),
                                  duration: Duration(milliseconds: 1500),
                                  curve: Curves.ease,
                                  child: _getSearchBar(),
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
//          Padding(
//            padding: EdgeInsets.only(
//              top: AppConfig.verticalBlockSize * 1,
//            ),
//            child: ,
//          )
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
      if (_prevSearchedSolution != null &&
          _prevSearchedSolution.data != null &&
          _prevSearchedSolution.data.isNotEmpty &&
          _prevSearchedSolution.topSearches != null &&
          !_prevSearchedSolution.topSearches) {
        List<CatalogueData> data = [];
        _prevSearchedSolution.data.forEach((element) {
          if (element.topSearch != null && element.topSearch) {
            data.add(element);
          }
        });
        _topSearchedSolutions = PrevSearchedSolution(data: data);
      }
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
            child: Hero(
                tag: "my_tag",
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
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SolutionBiddingScreen()));
                    _canGoAhead = UserManager().getIsUserInServiceLocation();
                    if (_canGoAhead) {
                      _setState();
                    }
                    _getPreviousSolutions();
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
                ))),
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
}

// ignore: must_be_immutable
class HomePageAppBar extends StatefulWidget {
  final Function onDrawerTap, onSetLocationTap, onSetLocationManually;

  final GlobalKey<State<StatefulWidget>> two, one;

  HomePageAppBar(
      this.onDrawerTap, this.onSetLocationTap, this.onSetLocationManually,
      {this.two, this.one});

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            widget.onDrawerTap();
            return;
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomWidgets().getShowCase(widget.two,
                child: Icon(
                  Icons.menu,
                  color: PlunesColors.BLACKCOLOR,
                ),
                title: PlunesStrings.menu,
                description: PlunesStrings.menuDesc),
          ),
        ),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<RequestState>(
            future: _getLocationStatusForTop(),
            builder: (context, snapshot) {
              if (snapshot.data is RequestSuccess) {
                RequestSuccess reqSuccess = snapshot.data;
                LocationAppBarModel locationModel = reqSuccess.response;
                if (locationModel != null && locationModel.hasLocation) {
                  return Container(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: widget.onSetLocationManually,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            child: Image.asset(plunesImages.locationIcon),
                            height: AppConfig.verticalBlockSize * 3,
                            width: AppConfig.horizontalBlockSize * 5,
                          ),
                          Flexible(
                            child: CustomWidgets().getShowCase(
                              widget.one,
                              description:
                                  PlunesStrings.youCanChangeLocationFromHere,
                              title: PlunesStrings.locationDesc,
                              child: Container(
                                margin: EdgeInsets.only(left: 12.0),
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
                                      style: TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.dashed,
                                        decorationThickness: 2.0,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    width: AppConfig.horizontalBlockSize * 48,
                  );
                } else {
                  return Container(
                      width: AppConfig.horizontalBlockSize * 40,
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: widget.onSetLocationTap,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: CustomWidgets().getShowCase(
                                    widget.one,
                                    description: PlunesStrings
                                        .youCanChangeLocationFromHere,
                                    title: PlunesStrings.locationDesc,
                                    child: Text(
                                      locationModel.address ??
                                          PlunesStrings.enterYourLocation,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  flex: 10,
                                ),
                                Flexible(
                                  child: Icon(Icons.radio_button_checked,
                                      size: 16.0),
                                  flex: 1,
                                )
                              ],
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 3.0),
                              width: double.infinity,
                              height: 1,
                              color: PlunesColors.GREYCOLOR)
                        ],
                      ));
                }
              }
              return Text(PlunesStrings.processing);
            },
          ),
        )
      ],
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
