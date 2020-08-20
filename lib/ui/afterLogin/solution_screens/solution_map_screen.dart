import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';

// ignore: must_be_immutable
class SolutionMap extends BaseActivity {
  final SearchedDocResults solution;
  final CatalogueData catalogueData;

  SolutionMap(this.solution, this.catalogueData);

  _SolutionMapState createState() => _SolutionMapState();
}

class _SolutionMapState extends BaseState<SolutionMap> {
  SearchedDocResults _searchedDocResults;
  User _user;
  bool _isProcessing = true;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _googleMapController;
  TextEditingController _searchController;
  FocusNode _focusNode;
  String _failureCause;

//  BitmapDescriptor hosImage2XGreenBgDesc;

  @override
  void initState() {
    _searchedDocResults = widget.solution;
    _user = UserManager().getUserDetails();
//    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
//            PlunesImages.hosImage2XGreenBg)
//        .then((onValue) {
//      hosImage2XGreenBgDesc = onValue;
//    });
    _setMapSpecificData();
    _searchController = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.pop(context, true);
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _searchController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar: widget.getAppBar(context, "Location", true),
          body: _isProcessing
              ? CustomWidgets().getProgressIndicator()
              : _failureCause != null
                  ? CustomWidgets().errorWidget(_failureCause)
                  : Column(
                      children: <Widget>[
                        (widget.catalogueData != null &&
                                widget.catalogueData.isFromNotification !=
                                    null &&
                                widget.catalogueData.isFromNotification)
                            ? Container()
                            : Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 3,
                                    vertical: AppConfig.verticalBlockSize * 1),
                                child: CustomWidgets().searchBar(
                                    searchController: _searchController,
                                    hintText: PlunesStrings.chooseLocation,
                                    focusNode: _focusNode,
                                    searchBarHeight: 5.5),
                              ),
                        Expanded(
                          child: GoogleMap(
                              padding: EdgeInsets.all(0.0),
                              myLocationEnabled: false,
                              markers: _markers,
                              myLocationButtonEnabled: false,
                              onMapCreated: (mapController) {
                                if (_googleMapController != null &&
                                    _googleMapController.isCompleted) {
                                  return;
                                }
                                _googleMapController.complete(mapController);
                              },
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      double.tryParse(_user.latitude) ?? 0.0,
                                      double.tryParse(_user.longitude) ?? 0.0),
                                  zoom: 10)),
                          flex: 3,
                        ),
                      ],
                    ),
        ));
  }

  void _setMapSpecificData() async {
    if (_searchedDocResults == null ||
        _searchedDocResults.solution == null ||
        _searchedDocResults.solution.services == null ||
        _searchedDocResults.solution.services.isEmpty) {
      _failureCause = PlunesStrings.oopsServiceNotAvailable;
      if (_searchedDocResults != null &&
          _searchedDocResults.msg != null &&
          _searchedDocResults.msg.isNotEmpty) {
        _failureCause = _searchedDocResults.msg;
      }
    } else {
//      double minZoom = 0;
//      for (int index = 0;
//          index < _searchedDocResults.solution.services.length;
//          index++) {
//        if (_searchedDocResults.solution.services[index].distance != null &&
//            _searchedDocResults.solution.services[index].distance > minZoom) {
//          minZoom = _searchedDocResults.solution.services[index].distance;
//        }
//      }
//      if (minZoom != 0) {
////        _animateMapPosition(minZoom);
//        print("animating");
//      }
//      await Future.delayed(Duration(milliseconds: 100));
      _searchedDocResults.solution.services.forEach((docData) {
        _markers.add(Marker(
            markerId: MarkerId(docData.sId),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(docData.latitude ?? 0.0, docData.longitude ?? 0.0),
            infoWindow: InfoWindow(
                title: docData.name,
                snippet: "${docData.distance?.toStringAsFixed(1)} km",
                onTap: () => _viewProfile(docData))));
      });
    }
    _isProcessing = false;
    _setState();
  }

  _viewProfile(Services service) {
    if (service.userType != null && service.professionalId != null) {
      Widget route;
      if (service.userType.toLowerCase() ==
          Constants.doctor.toString().toLowerCase()) {
        route = DocProfile(userId: service.professionalId);
      } else {
        route = HospitalProfile(userID: service.professionalId);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  void _animateMapPosition(double minZoom) async {
    if (minZoom < 5) {
      minZoom = 14;
    } else if (minZoom < 10) {
      minZoom = 12;
    } else if (minZoom < 20) {
      minZoom = 11;
    } else if (minZoom < 35) {
      minZoom = 10.5;
    } else if (minZoom < 55) {
      minZoom = 9.2;
    } else {
      minZoom = 9;
    }
    Future.delayed(Duration(milliseconds: 700)).then((value) async {
      if (_googleMapController != null && _googleMapController.isCompleted) {
        var _mapController = await _googleMapController.future;
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(double.parse(_user.latitude),
                    double.parse(_user.longitude)),
                zoom: minZoom,
                bearing: 10)));
      }
    });
  }
}
