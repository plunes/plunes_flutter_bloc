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
import 'package:plunes/models/booking_models/appointment_model.dart';
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
    _getPreviousSolutions();
    _getUserDetails();
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == EditProfileScreen.tag &&
          mounted) {
        _getUserDetails();
      }
    });
    super.initState();
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
        Container(
          child: HomePageAppBar(widget.func, () => _showLocationDialog(),
              () => _setLocationManually()),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    (_prevSearchedSolution.topSearches !=
                                                null &&
                                            _prevSearchedSolution.topSearches)
                                        ? PlunesStrings.topSearches
                                        : PlunesStrings.previousActivities,
                                    style: TextStyle(
                                      fontSize: AppConfig.mediumFont,
                                      fontWeight: FontWeight.normal,
//                                        decoration: (_prevSearchedSolution
//                                                        .topSearches !=
//                                                    null &&
//                                                _prevSearchedSolution
//                                                    .topSearches)
//                                            ? TextDecoration.none
//                                            : TextDecoration.underline,
//                                        decorationStyle:
//                                            TextDecorationStyle.solid,
//                                        decorationThickness: 5,
//                                        decorationColor:
//                                            PlunesColors.GREENCOLOR
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
                                        isTopSearches: (_prevSearchedSolution
                                                    .topSearches !=
                                                null &&
                                            _prevSearchedSolution.topSearches),
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

class HomePageAppBar extends StatefulWidget {
  final Function onDrawerTap, onSetLocationTap, onSetLocationManually;

  HomePageAppBar(
      this.onDrawerTap, this.onSetLocationTap, this.onSetLocationManually);

  @override
  _HomePageAppBarState createState() => _HomePageAppBarState();
}

class _HomePageAppBarState extends State<HomePageAppBar> {
  GlobalKey _one = GlobalKey();

  initState() {
    Future.delayed(Duration(seconds: 1)).then((value) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ShowCaseWidget.of(context).startShowCase([_one]));
    });
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
            child: Icon(
              Icons.menu,
              color: PlunesColors.BLACKCOLOR,
            ),
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
                            child: Showcase(
                              showcaseBackgroundColor: Colors.blueAccent,
                              textColor: Colors.white,
                              shapeBorder: CircleBorder(),
                              key: _one,
                              description: "Tap to change your location",
                              title: 'Location',
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
                                  child: Showcase(
                                    showcaseBackgroundColor: Colors.blueAccent,
                                    textColor: Colors.white,
                                    shapeBorder: CircleBorder(),
                                    key: _one,
                                    description: "Tap to change your location",
                                    title: 'Location',
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
