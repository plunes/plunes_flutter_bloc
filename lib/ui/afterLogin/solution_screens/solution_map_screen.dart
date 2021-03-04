import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_painter_icon_gen.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
import 'dart:ui' as ui;
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';

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
  Completer<GoogleMapController> _googleMapController = Completer();
  TextEditingController _searchController;
  FocusNode _focusNode;
  String _failureCause;
  List<Widget> _mapWidgets;
  List<GlobalKey> _globalKeys = [];
  List<Function> _functions = [];
  List<Services> _customServices = [];
  IconGenerator _iconGen;
  BitmapDescriptor hosImage2XGreenBgDesc;

  @override
  void initState() {
    _searchedDocResults = widget.solution;
    _user = UserManager().getUserDetails();
    _iconGen = IconGenerator();
    _iconGen.getBytesFromAsset(PlunesImages.labMapImage, 100).then((value) {
      hosImage2XGreenBgDesc = BitmapDescriptor.fromBytes(value);
      // _markers.add(Marker(
      //     icon: hosImage2XGreenBgDesc,
      //     position: LatLng(28.443, 78.3222),
      //     markerId: MarkerId("ds"),
      //     onTap: () => _doSomething()));
      // if (mounted) setState(() {});
    });
    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(size: Size(48, 48)), PlunesImages.labMapImage)
    //     .then((onValue) {
    //   hosImage2XGreenBgDesc = onValue;
    // });
//     _setMapSpecificData();
    _calculateMapData();
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
          body: _failureCause != null
              ? CustomWidgets().errorWidget(_failureCause)
              : Stack(
                  children: [
                    // Container(child: ListView(children: _mapWidgets ?? [])),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                    ),
                    Column(
                      children: <Widget>[
                        // (widget.catalogueData != null &&
                        //         widget.catalogueData.isFromNotification !=
                        //             null &&
                        //         widget.catalogueData.isFromNotification)
                        //     ? Container()
                        //     : Container(
                        //         margin: EdgeInsets.symmetric(
                        //             horizontal:
                        //                 AppConfig.horizontalBlockSize * 3,
                        //             vertical: AppConfig.verticalBlockSize * 1),
                        //         child: CustomWidgets().searchBar(
                        //             searchController: _searchController,
                        //             hintText: PlunesStrings.chooseLocation,
                        //             focusNode: _focusNode,
                        //             searchBarHeight: 5.5),
                        //       ),
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
                  ],
                ),
        ));
  }

//   void _setMapSpecificData() async {
//     if (_searchedDocResults == null ||
//         _searchedDocResults.solution == null ||
//         _searchedDocResults.solution.services == null ||
//         _searchedDocResults.solution.services.isEmpty) {
//       _failureCause = PlunesStrings.oopsServiceNotAvailable;
//       if (_searchedDocResults != null &&
//           _searchedDocResults.msg != null &&
//           _searchedDocResults.msg.isNotEmpty) {
//         _failureCause = _searchedDocResults.msg;
//       }
//     } else {
// //      double minZoom = 0;
// //      for (int index = 0;
// //          index < _searchedDocResults.solution.services.length;
// //          index++) {
// //        if (_searchedDocResults.solution.services[index].distance != null &&
// //            _searchedDocResults.solution.services[index].distance > minZoom) {
// //          minZoom = _searchedDocResults.solution.services[index].distance;
// //        }
// //      }
// //      if (minZoom != 0) {
// ////        _animateMapPosition(minZoom);
// //        print("animating");
// //      }
// //      await Future.delayed(Duration(milliseconds: 100));
//       _searchedDocResults.solution.services.forEach((docData) {
//         _markers.add(Marker(
//             markerId: MarkerId(docData.sId),
//             icon: BitmapDescriptor.defaultMarker,
//             position: LatLng(docData.latitude ?? 0.0, docData.longitude ?? 0.0),
//             infoWindow: InfoWindow(
//                 title: docData.name,
//                 snippet: "${docData.distance?.toStringAsFixed(1)} km",
//                 onTap: () => _viewProfile(docData))));
//       });
//     }
//     _isProcessing = false;
//     _setState();
//   }

  void _calculateMapData() async {
    await Future.delayed(Duration(milliseconds: 20));
    if (_searchedDocResults != null &&
        _searchedDocResults.solution != null &&
        _searchedDocResults.solution.services != null &&
        _searchedDocResults.solution.services.isNotEmpty) {
      _globalKeys = [];
      _mapWidgets = [];
      _functions = [];
      _customServices = [];
      for (int index = 0;
          index < _searchedDocResults.solution.services.length;
          index++) {
        if (_searchedDocResults.solution.services[index].doctors != null &&
            _searchedDocResults.solution.services[index].doctors.isNotEmpty) {
          _searchedDocResults.solution.services[index].doctors
              .forEach((doctor) {
            var key = GlobalKey();
            _globalKeys.add(key);
            _functions.add(() =>
                _openProfile(_searchedDocResults.solution.services[index]));
            Services service = Services(
                name: doctor?.name ?? "",
                sId: _searchedDocResults.solution.services[index].sId,
                latitude: _searchedDocResults.solution.services[index].latitude,
                longitude:
                    _searchedDocResults.solution.services[index].longitude,
                professionalPhotos: _searchedDocResults
                        .solution.services[index].professionalPhotos ??
                    [],
                distance:
                    _searchedDocResults.solution.services[index].distance);
            _customServices.add(service);
            // _mapWidgets.add(RepaintBoundary(
            //   child: Container(
            //     child: Column(
            //       children: [
            //         ClipOval(
            //           child: Container(
            //             width: 70,
            //             height: 70,
            //             decoration: BoxDecoration(
            //                 color: Colors.transparent, shape: BoxShape.circle),
            //             child: CustomWidgets().getImageFromUrl(
            //                 doctor.imageUrl ?? "",
            //                 placeHolderPath: PlunesImages.labMapImage,
            //                 boxFit: BoxFit.fill),
            //           ),
            //         ),
            //         SizedBox(
            //           height: 4,
            //         ),
            //         Container(
            //           height: 12,
            //           width: 12,
            //           decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               color: Colors.indigo.withOpacity(0.4)),
            //         )
            //       ],
            //     ),
            //   ),
            //   key: key,
            // ));
          });
        } else {
          var key = GlobalKey();
          _globalKeys.add(key);
          _functions.add(
              () => _openProfile(_searchedDocResults.solution.services[index]));
          _customServices.add(_searchedDocResults.solution.services[index]);
          // _mapWidgets.add(RepaintBoundary(
          //   child: Container(
          //     child: Column(
          //       children: [
          //         ClipOval(
          //           child: Container(
          //             width: 70,
          //             height: 70,
          //             decoration: BoxDecoration(
          //                 color: Colors.transparent, shape: BoxShape.circle),
          //             child: CustomWidgets().getImageFromUrl(
          //                 _searchedDocResults.solution.services[index].imageUrl,
          //                 placeHolderPath: PlunesImages.labMapImage,
          //                 boxFit: BoxFit.fill),
          //           ),
          //         ),
          //         SizedBox(
          //           height: 4,
          //         ),
          //         Container(
          //           height: 12,
          //           width: 12,
          //           decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               color: Colors.indigo.withOpacity(0.4)),
          //         )
          //       ],
          //     ),
          //   ),
          //   key: key,
          // ));
        }
      }
      _setState();
      _showMapWidgetsAfterDelay();
    }
  }

  void _showMapWidgetsAfterDelay() async {
    try {
      double minZoom = 0;
      int arrLength = _searchedDocResults.solution.services.length;
      for (int index = 0; index < arrLength; index++) {
        if (_searchedDocResults.solution.services[index].distance != null &&
            _searchedDocResults.solution.services[index].distance > minZoom) {
          minZoom = _searchedDocResults.solution.services[index].distance;
        }
      }
      if (minZoom != 0) {
        _animateMapPosition(minZoom);
      }
      await Future.delayed(Duration(seconds: 1));
      for (int index = 0; index < _globalKeys.length; index++) {
        // RenderRepaintBoundary boundary =
        //     _globalKeys[index].currentContext.findRenderObject();
        // var image = await boundary?.toImage(pixelRatio: 2.0);
        // ByteData byteData =
        //     await image?.toByteData(format: ui.ImageByteFormat.png);
        // var bytes = byteData.buffer.asUint8List();
        // print("bytes are $bytes");
        await Future.delayed(Duration(milliseconds: 150));
        _markers.add(Marker(
            markerId: MarkerId(_customServices[index].sId),
            onTap: () => _functions[index](),
            icon: hosImage2XGreenBgDesc,
            position: LatLng(_customServices[index].latitude?.toDouble() ?? 0.0,
                _customServices[index].longitude?.toDouble() ?? 0.0),
            infoWindow: InfoWindow(
                title: _customServices[index].name,
                snippet:
                    "${_customServices[index].distance?.toStringAsFixed(1) ?? 1} km")));
        _setState();
      }
    } catch (e) {}
  }

  // _viewProfile(Services service) {
  //   if (service.userType != null && service.professionalId != null) {
  //     Widget route;
  //     if (service.userType.toLowerCase() ==
  //         Constants.doctor.toString().toLowerCase()) {
  //       route = DocProfile(userId: service.professionalId);
  //     } else {
  //       route = HospitalProfile(userID: service.professionalId);
  //     }
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => route));
  //   }
  // }

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

  _openProfile(Services service) {
    if (service != null &&
        service.userType != null &&
        service.professionalId != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorInfo(service.professionalId,
                  isDoc: (service.userType.toLowerCase() ==
                      Constants.doctor.toString().toLowerCase()))));
    }
  }
}
