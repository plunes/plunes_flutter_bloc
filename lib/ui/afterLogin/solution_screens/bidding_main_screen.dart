import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/prev_missed_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/EditProfileScreen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_received_screen.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import './previous_activity_screen.dart';

// ignore: must_be_immutable
class BiddingMainScreen extends BaseActivity {
  @override
  _BiddingMainScreenState createState() => _BiddingMainScreenState();
}

class _BiddingMainScreenState extends BaseState<BiddingMainScreen> {
  TextEditingController _textEditingController;
  FocusNode _focusNode;
  bool _progressEnabled;
  bool _canGoAhead;
  String _failureCause, _locationMessage;
  PrevMissSolutionBloc _prevMissSolutionBloc;
  PrevSearchedSolution _prevSearchedSolution;
  Timer _timer;
  StreamController _controller;
  BuildContext _context;

  @override
  void initState() {
    _locationMessage = PlunesStrings.switchToGurLoc;
    _progressEnabled = false;
    _canGoAhead = false;
    _prevMissSolutionBloc = PrevMissSolutionBloc();
    _textEditingController = TextEditingController();
    _controller = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timer = timer;
      _controller.add(null);
    });
    _focusNode = FocusNode();
//      ..addListener(() async {
//        if (_focusNode.hasFocus) {
//          await Future.delayed(Duration(milliseconds: 100));
//          _focusNode?.unfocus();
//          await Navigator.push(context,
//              MaterialPageRoute(builder: (context) => SolutionBiddingScreen()));
//          _getPreviousSolutions();
//        }
//      });
    _getUserDetails();
    _getPreviousSolutions();
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == EditProfileScreen.tag &&
          mounted) {
        _getUserDetails();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.close();
    _timer?.cancel();
    _prevMissSolutionBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Builder(builder: (context) {
        _context = context;
        return _getWidgetBody();
      }),
    );
  }

  Widget _getWidgetBody() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: ExactAssetImage(PlunesImages.userLandingImage),
                  fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: _getSearchWidget(),
                      left: 0.0,
                      right: 0.0,
                      top: AppConfig.verticalBlockSize * 15,
                    )
                  ],
                ),
              ),
              _canGoAhead ? Container() : _getNoLocationView(),
              _getBottomView(),
            ],
          ),
        ),
      ],
    );
  }

  _getBottomView() {
    return (_prevSearchedSolution == null ||
            _prevSearchedSolution.data == null ||
            _prevSearchedSolution.data.isEmpty)
        ? Container()
        : Expanded(
            flex: 7,
            child: StreamBuilder<Object>(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  return Card(
                      margin: EdgeInsets.all(0.0),
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              if (_prevSearchedSolution.topSearches != null &&
                                  _prevSearchedSolution.topSearches) {
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PreviousActivity()));
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: AppConfig.verticalBlockSize * 1.5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    (_prevSearchedSolution.topSearches !=
                                                null &&
                                            _prevSearchedSolution.topSearches)
                                        ? PlunesStrings.topSearches
                                        : PlunesStrings.previousActivities,
                                    style: TextStyle(
                                        fontSize: AppConfig.smallFont,
                                        fontWeight: FontWeight.w600,
                                        decoration: (_prevSearchedSolution
                                                        .topSearches !=
                                                    null &&
                                                _prevSearchedSolution
                                                    .topSearches)
                                            ? TextDecoration.none
                                            : TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        decorationThickness: 5,
                                        decorationColor:
                                            PlunesColors.GREENCOLOR),
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
                              : Expanded(
                                  child: ListView.builder(
                                  padding: EdgeInsets.all(0.0),
                                  itemBuilder: (context, index) {
                                    TapGestureRecognizer tapRecognizer =
                                        TapGestureRecognizer()
                                          ..onTap = () => _onViewMoreTap(index);
                                    return CustomWidgets().getSolutionRow(
                                        _prevSearchedSolution.data, index,
                                        onButtonTap: () => _onSolutionItemTap(
                                            _prevSearchedSolution.data[index]),
                                        onViewMoreTap: tapRecognizer);
                                  },
                                  itemCount: _prevSearchedSolution.data.length,
                                ))
                        ],
                      ));
                }));
  }

  _getCurrentLocation() async {
    var latLong = await LocationUtil().getCurrentLatLong(_context);
    if (latLong != null &&
        latLong.longitude != null &&
        latLong.latitude != null) {
      print("location null nhai hai ${latLong.toString()}");
      _checkUserLocation(
          latLong?.latitude?.toString(), latLong?.longitude?.toString());
    }
    print("location null hai bhai${latLong.toString()}");
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
          Padding(
            padding: EdgeInsets.only(
              top: AppConfig.verticalBlockSize * 1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                    child: Hero(
                        tag: "my_tag",
                        child: Material(
                          child: InkWell(
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
                                      builder: (context) =>
                                          SolutionBiddingScreen()));
                              _canGoAhead =
                                  UserManager().getIsUserInServiceLocation();
                              if (_canGoAhead) {
                                _setState();
                              }
                              _getPreviousSolutions();
                            },
                            child: IgnorePointer(
                              ignoring: true,
                              child: CustomWidgets().searchBar(
                                  searchController: _textEditingController,
                                  isRounded: true,
                                  focusNode: _focusNode,
                                  hintText: plunesStrings.searchHint),
                            ),
                          ),
                        ))),
                InkWell(
                    onTap: () {
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
//                          print("addr is $addr");
                          var _latitude = addressControllerList[3];
                          var _longitude = addressControllerList[4];
//                          print("_latitude $_latitude");
//                          print("_longitude $_longitude");
                          _checkUserLocation(_latitude, _longitude,
                              address: addr);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(6.0),
                      height: AppConfig.verticalBlockSize * 5,
                      width: AppConfig.horizontalBlockSize * 10,
                      child: Image.asset(
                        PlunesImages.userLandingGoogleIcon,
                      ),
                    ))
              ],
            ),
          )
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
      if (_canGoAhead) {
        return;
      } else {
        _locationMessage = PlunesStrings.weAreNotAvailableInYourArea;
        _setState();
        _checkUserLocation(user?.latitude, user?.longitude);
      }
    } else {
      await Future.delayed(Duration(milliseconds: 400));
      _getCurrentLocation();
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  _checkUserLocation(var latitude, var longitude, {String address}) async {
    if (!_progressEnabled) {
      _progressEnabled = true;
      _setState();
    }
    UserBloc()
        .isUserInServiceLocation(latitude, longitude, address: address)
        .then((result) {
      if (result is RequestSuccess) {
        CheckLocationResponse checkLocationResponse = result.response;
        _canGoAhead = UserManager().getIsUserInServiceLocation();
        if (checkLocationResponse != null &&
            checkLocationResponse.msg != null &&
            checkLocationResponse.msg.isNotEmpty) {
          _failureCause = checkLocationResponse.msg;
        }
      } else if (result is RequestFailed) {
        _failureCause = result.failureCause;
      }
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
//                                    print("_latitude $_latitude");
//                                    print("_longitude $_longitude");
                  _checkUserLocation(_latitude, _longitude, address: addr);
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
}
