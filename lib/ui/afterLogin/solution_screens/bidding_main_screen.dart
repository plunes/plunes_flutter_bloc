import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
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

  @override
  void initState() {
    _progressEnabled = false;
    _canGoAhead = false;
    _textEditingController = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() async {
        if (_focusNode.hasFocus) {
          if (!_canGoAhead) {
            _focusNode?.unfocus();
            widget.showInSnackBar(
                "Kindly switch to Gurgaoun location, currently we are not providing service in your area",
                PlunesColors.GREYCOLOR,
                scaffoldKey);
            return;
          }
          print("got focus");
          await Future.delayed(Duration(milliseconds: 100));
          _focusNode?.unfocus();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SolutionBiddingScreen()));
        }
      });
    _mapController = Completer();
    _checkUserLocation();
    _initialCameraPosition =
        CameraPosition(target: LatLng(45.521563, -122.677433), zoom: 14);
    super.initState();
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
          _getBottomView()
        ],
      ),
    );
  }

  _getBottomView() {
    TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
      ..onTap = () => {};
    return Expanded(
        flex: 1,
        child: Card(
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
//                Expanded(
//                    child: ListView.builder(
//                  padding: EdgeInsets.all(0.0),
//                  itemBuilder: (context, index) {
//                    TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
//                      ..onTap = () => _onViewMoreTap(index);
//                    return CustomWidgets().getSolutionRow(_solutions, index,
//                        onButtonTap: () => _onSolutionItemTap(index),
//                        onViewMoreTap: tapRecognizer);
//                  },
//                  itemCount: 50,
//                ))
              ],
            )));
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
                      _checkUserLocation();
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

  User _getUserDetails() {
    return UserManager().getUserDetails();
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  _checkUserLocation() async {
    if (!_progressEnabled) {
      _progressEnabled = true;
      _setState();
    }
    UserBloc().isUserInServiceLocation().then((result) {
      if (result.isRequestSucceed) {
        print("request succ ${result.response.data}");
        if (result.response.data == null || !result.response.data) {
          widget.showInSnackBar(
              "Kindly switch to Gurgaoun location, currently we are not providing service in your area",
              PlunesColors.GREYCOLOR,
              scaffoldKey);
        } else {
          _canGoAhead = true;
        }
      } else {
        print("error ${result.failureCause}");
        _failureCause = result.failureCause;
        widget.showInSnackBar(
            _failureCause, PlunesColors.GREYCOLOR, scaffoldKey);
      }
      _progressEnabled = false;
      _setState();
    });
  }
}
