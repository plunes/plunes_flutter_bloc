import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/prev_missed_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';

// ignore: must_be_immutable
class BiddingMainScreen extends BaseActivity {
  @override
  _BiddingMainScreenState createState() => _BiddingMainScreenState();
}

class _BiddingMainScreenState extends BaseState<BiddingMainScreen> {
  Completer<GoogleMapController> _mapController;
  CameraPosition _initialCameraPosition;
  TextEditingController _textEditingController;
  FocusNode _focusNode;
  bool _progressEnabled;
  bool _canGoAhead;
  String _failureCause;
  PrevMissSolutionBloc _prevMissSolutionBloc;
  PrevSearchedSolution _prevSearchedSolution;
  Timer _timer;
  StreamController _controller;

  @override
  void initState() {
    _progressEnabled = false;
    _canGoAhead = false;
    _prevMissSolutionBloc = PrevMissSolutionBloc();
    _textEditingController = TextEditingController();
    _controller = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timer = timer;
      _controller.add(null);
    });
    _focusNode = FocusNode()
      ..addListener(() async {
        if (_focusNode.hasFocus) {
//          if (!_canGoAhead) {
//            _focusNode?.unfocus();
//            widget.showInSnackBar(
//                "Kindly switch to Gurgaoun location, currently we are not providing service in your area",
//                PlunesColors.GREYCOLOR,
//                scaffoldKey);
//            return;
//          }
//          print("got focus");
          await Future.delayed(Duration(milliseconds: 100));
          _focusNode?.unfocus();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SolutionBiddingScreen()));
        }
      });
    _mapController = Completer();
    _getUserDetails();
    _getPreviousSolutions();
    _initialCameraPosition =
        CameraPosition(target: LatLng(45.521563, -122.677433), zoom: 14);
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: _getWidgetBody(),
    );
  }

  Widget _getWidgetBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_mapController.isCompleted)
                      _mapController.complete(controller);
                  },
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                ),
                Positioned(
                  child: _getSearchWidget(),
                  left: 0.0,
                  right: 0.0,
                  top: AppConfig.verticalBlockSize * 15,
                )
//              Positioned(
//                  right: 0.0,
//                  bottom: 0.0,
//                  child: FloatingActionButton(
//                      backgroundColor: Colors.grey,
//                      onPressed: () => _getCurrentLocation(),
//                      child: Icon(
//                        Icons.my_location,
//                        color: Colors.indigo,
//                      ))),
              ],
            ),
          ),
          _canGoAhead ? Container() : holdOnPopUp,
          _getBottomView(),
        ],
      ),
    );
  }

  _getBottomView() {
    return Expanded(
        flex: (_prevSearchedSolution == null ||
                _prevSearchedSolution.data == null ||
                _prevSearchedSolution.data.isEmpty)
            ? 0
            : 1,
        child: StreamBuilder<Object>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              return Card(
                  margin: EdgeInsets.all(0.0),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          print("Previous activity called");
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                PlunesStrings.previousActivities,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: PlunesColors.GREENCOLOR,
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
                                return CustomWidgets().getPrevMissSolutionRow(
                                    _prevSearchedSolution.data, index,
                                    onButtonTap: () =>
                                        _onSolutionItemTap(index),
                                    onViewMoreTap: tapRecognizer);
                              },
                              itemCount: _prevSearchedSolution.data.length,
                            ))
                    ],
                  ));
            }));
  }

  _getCurrentLocation() async {
    var latLong = await LocationUtil().getCurrentLatLong();
    if (latLong != null) {
      print("latlong are ${latLong.toString()}");
    }
  }

  Widget _getSearchWidget() {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle, color: PlunesColors.WHITECOLOR),
      padding: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 6,
          vertical: AppConfig.verticalBlockSize * 3),
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 6),
      child: Column(
        children: <Widget>[
          Text(
            PlunesStrings.negotiateForBestPrice,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: AppConfig.mediumFont),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                  child: CustomWidgets().searchBar(
                      searchController: _textEditingController,
                      focusNode: _focusNode,
                      hintText: plunesStrings.searchHint)),
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
                      print("addr is $addr");
                      var _latitude = addressControllerList[3];
                      var _longitude = addressControllerList[4];
                      print("_latitude $_latitude");
                      print("_longitude $_longitude");
                      _checkUserLocation(_latitude, _longitude);
                    }
                  });
                },
                child: Icon(
                  Icons.my_location,
                  color: PlunesColors.GREYCOLOR,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  _onViewMoreTap(int index) {}

  _onSolutionItemTap(int index) {}

  _getUserDetails() {
    _canGoAhead = UserManager().getIsUserInServiceLocation();
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  _checkUserLocation(var latitude, var longitude) async {
    if (!_progressEnabled) {
      _progressEnabled = true;
      _setState();
    }
    UserBloc().isUserInServiceLocation(latitude, longitude).then((result) {
      if (result.isRequestSucceed) {
        if (result.response.data == null || !result.response.data) {
          widget.showInSnackBar(PlunesStrings.switchToGurLoc,
              PlunesColors.GREYCOLOR, scaffoldKey);
        } else {
          _canGoAhead = true;
        }
      } else {
        _failureCause = result.failureCause;
        widget.showInSnackBar(
            _failureCause, PlunesColors.GREYCOLOR, scaffoldKey);
      }
      _progressEnabled = false;
      _setState();
    });
  }

  final holdOnPopUp = Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          child: Container(
            color: Color(0xff99000000),
//            decoration: BoxDecoration(
//                borderRadius: BorderRadius.all(Radius.circular(10)),
//                color: Color(0xff99000000)),
            padding: EdgeInsets.all(AppConfig.horizontalBlockSize * 5),
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
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
                          PlunesStrings.weAreNotAvailableInYourArea,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: AppConfig.mediumFont),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );

  void _getPreviousSolutions() async {
    var requestState = await _prevMissSolutionBloc.getPreviousSolutions();
    if (requestState is RequestSuccess) {
      _prevSearchedSolution = requestState.response;
      _setState();
    }
  }
}
