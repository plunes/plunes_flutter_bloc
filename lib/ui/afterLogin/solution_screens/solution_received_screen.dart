import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_map_screen.dart';
import '../../widgets/dialogPopScreen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// ignore: must_be_immutable
class SolutionReceivedScreen extends BaseActivity {
  final CatalogueData catalogueData;
  final String searchQuery;

  SolutionReceivedScreen({this.catalogueData, this.searchQuery});

  @override
  _SolutionReceivedScreenState createState() => _SolutionReceivedScreenState();
}

class _SolutionReceivedScreenState extends BaseState<SolutionReceivedScreen> {
  Completer<GoogleMapController> _googleMapController;
  Timer _timer, _timerToUpdateSolutionReceivedTime;
  int _tenMinutesInSeconds = 600;
  SearchSolutionBloc _searchSolutionBloc;
  SearchedDocResults _searchedDocResults;
  DocHosSolution _solution;
  BuildContext _buildContext;

  bool _isFetchingInitialData;
  String _failureCause;
  int _solutionReceivedTime = 0;
  bool _shouldStartTimer, _isCrossClicked;
  StreamController _streamForTimer;
  TextEditingController _searchController;
  FocusNode _focusNode;
  final double lat = 28.4594965, long = 77.0266383;
  User _user;
  Set<Marker> _markers = {};

//  BitmapDescriptor _hospitalIcon, _labIcon;

  @override
  void initState() {
//    BitmapDescriptor.fromAssetImage(
//            ImageConfiguration(size: Size(48, 48)), PlunesImages.doctorMapImage)
//        .then((onValue) {
//      _docIcon = onValue;
//    });
    _isCrossClicked = false;
//    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
//            PlunesImages.hospitalMapImage)
//        .then((onValue) {
//      _hospitalIcon = onValue;
//    });
//    BitmapDescriptor.fromAssetImage(
//            ImageConfiguration(size: Size(48, 48)), PlunesImages.labMapImage)
//        .then((onValue) {
//      _labIcon = onValue;
//    });
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          Navigator.pop(context, true);
        }
      });
    _searchController = TextEditingController();
    _shouldStartTimer = false;
    _streamForTimer = StreamController.broadcast();
    _timerToUpdateSolutionReceivedTime =
        Timer.periodic(Duration(seconds: 1), (timer) {
      _timerToUpdateSolutionReceivedTime = timer;
      _streamForTimer.add(null);
    });
    _solutionReceivedTime = DateTime.now().millisecondsSinceEpoch;
    _isFetchingInitialData = true;
    _googleMapController = Completer();
    _searchSolutionBloc = SearchSolutionBloc();
    _user = UserManager().getUserDetails();
    _fetchResultAndStartTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamForTimer?.close();
    _timerToUpdateSolutionReceivedTime?.cancel();
    _searchController?.dispose();
    _focusNode?.dispose();
    _searchSolutionBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
              child: Card(
                  color: Colors.white,
                  elevation: 3.0,
                  margin: EdgeInsets.only(
                      top: AppConfig.getMediaQuery().padding.top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          padding:
                              EdgeInsets.all(AppConfig.verticalBlockSize * 2),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                              return;
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          )),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            PlunesStrings.negotiatedSolutions,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 16),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                PlunesImages.validForOneHourOnlyWatch,
                                scale: 3,
                              ),
                              Padding(
                                child: Text(
                                  PlunesStrings.validForOneHour,
                                  style: TextStyle(
                                      color: PlunesColors.GREYCOLOR,
                                      fontSize: 16),
                                ),
                                padding: EdgeInsets.only(left: 4.0),
                              )
                            ],
                          )
                        ],
                      ),
                      Container(),
                      Container(),
                      Container(),
                    ],
                  )),
              preferredSize:
                  Size(double.infinity, AppConfig.verticalBlockSize * 8)),
          body: Builder(builder: (context) {
            _buildContext = context;
            return _isFetchingInitialData
                ? CustomWidgets().getProgressIndicator()
                : _searchedDocResults == null ||
                        _searchedDocResults.solution == null ||
                        _searchedDocResults.solution.services == null ||
                        _searchedDocResults.solution.services.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 8),
                        child: CustomWidgets().errorWidget(_failureCause))
                    : _showBody();
          }),
        ));
  }

  Widget _showContent(ScrollController sc) {
    return ListView.builder(
        shrinkWrap: true,
        controller: sc,
        itemBuilder: (context, index) {
          return CustomWidgets().getDocOrHospitalDetailWidget(
              _searchedDocResults.solution?.services ?? [],
              index,
              () => _checkAvailability(index),
              () => _onBookingTap(
                  _searchedDocResults.solution.services[index], index),
              _searchedDocResults.catalogueData,
              _buildContext,
              () =>
                  _viewProfile(_searchedDocResults.solution?.services[index]));
        },
        itemCount: _searchedDocResults.solution == null
            ? 0
            : _searchedDocResults.solution.services == null ||
                    _searchedDocResults.solution.services.isEmpty
                ? 0
                : _searchedDocResults.solution.services.length);
  }

  _checkAvailability(int selectedIndex) {
    showDialog(
        context: context,
        builder: (BuildContext context) => DialogWidgets().buildProfileDialog(
            catalogueData: _searchedDocResults.catalogueData,
            solutions: _searchedDocResults.solution.services[selectedIndex],
            context: _buildContext));
  }

  _onBookingTap(Services service, int index) {
    _solution = _searchedDocResults.solution;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingMainScreen(
                  price: service.newPrice[0].toString(),
                  profId: service.professionalId,
                  searchedSolutionServiceId: service.sId,
                  timeSlots: service.timeSlots,
                  docHosSolution: _solution,
                  bookInPrice: service.bookIn,
                  serviceIndex: 0,
                  service: service,
                )));
  }

  Future<RequestState> _negotiate() async {
    var result = await _searchSolutionBloc.getDocHosSolution(
        widget.catalogueData,
        searchQuery: widget.searchQuery);
    if (_searchedDocResults != null &&
        _searchedDocResults.solution != null &&
        _searchedDocResults.solution.services != null &&
        _searchedDocResults.solution.services.isNotEmpty) {
      return result;
    }
    if (result is RequestSuccess) {
      _searchedDocResults = result.response;
      if (_searchedDocResults.solution?.services == null ||
          _searchedDocResults.solution.services.isEmpty) {
        _failureCause = PlunesStrings.oopsServiceNotAvailable;
        if (_searchedDocResults != null &&
            _searchedDocResults.msg != null &&
            _searchedDocResults.msg.isNotEmpty) {
          _failureCause = _searchedDocResults.msg;
        }
      } else {
        _searchedDocResults.solution.services.forEach((docData) {
          _markers.add(Marker(
              markerId: MarkerId(docData.sId),
              icon: BitmapDescriptor.defaultMarker,
              position:
                  LatLng(docData.latitude ?? lat, docData.longitude ?? long),
              infoWindow: InfoWindow(
                  title: docData.name,
                  snippet: "${docData.distance?.toStringAsFixed(1)} km",
                  onTap: () => _viewProfile(docData))));
        });
        _checkShouldTimerRun();
      }
    } else if (result is RequestFailed) {
      _failureCause = result.failureCause;
      _timer?.cancel();
    }
    _isFetchingInitialData = false;
    _setState();
    return result;
  }

  _setState() async {
    await Future.delayed(Duration(milliseconds: 15));
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _negotiate();
      _tenMinutesInSeconds = _tenMinutesInSeconds - 2;
      if (_tenMinutesInSeconds <= 0) {
        _cancelNegotiationTimer();
      }
    });
  }

  Widget _showBody() {
    return SlidingUpPanel(
      body: Container(
        color: PlunesColors.WHITECOLOR,
        padding: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                (widget.catalogueData != null &&
                        widget.catalogueData.isFromNotification != null &&
                        widget.catalogueData.isFromNotification)
                    ? Container()
                    : Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 3,
                            vertical: AppConfig.verticalBlockSize * 1),
                        child: CustomWidgets().searchBar(
                            searchController: _searchController,
                            hintText: PlunesStrings.chooseLocation,
                            focusNode: _focusNode,
                            searchBarHeight: 5.5),
                      ),
//                Expanded(
//                  child: GoogleMap(
//                      padding: EdgeInsets.all(0.0),
//                      myLocationEnabled: false,
//                      markers: _markers,
//                      myLocationButtonEnabled: false,
//                      onMapCreated: (mapController) {
//                        if (!_googleMapController.isCompleted)
//                          _googleMapController.complete(mapController);
//                      },
//                      initialCameraPosition: CameraPosition(
//                          target: LatLng(double.tryParse(_user.latitude) ?? lat,
//                              double.tryParse(_user.longitude) ?? long),
//                          zoom: 11.2)),
//                  flex: 3,
//                ),
//                Expanded(
//                  child: Container(),
//                  flex: 3,
//                ),
              ],
            ),
          ],
        ),
      ),
      maxHeight: (widget.catalogueData != null &&
              widget.catalogueData.isFromNotification != null &&
              widget.catalogueData.isFromNotification)
          ? AppConfig.verticalBlockSize * 90
          : AppConfig.verticalBlockSize * 79,
      minHeight: (widget.catalogueData != null &&
              widget.catalogueData.isFromNotification != null &&
              widget.catalogueData.isFromNotification)
          ? AppConfig.verticalBlockSize * 90
          : AppConfig.verticalBlockSize * 79,
//      collapsed: (_timer != null && _timer.isActive && !(_isCrossClicked))
//          ? _getHoldOnPopup()
//          : Container(),
      panelBuilder: (sc) {
        return Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Card(
                  elevation: 4.0,
                  margin: EdgeInsets.all(AppConfig.horizontalBlockSize * 4),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 4,
                        vertical: AppConfig.verticalBlockSize * 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () => _viewDetails(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.catalogueData.service ??
                                      _searchedDocResults
                                          ?.catalogueData?.service ??
                                      PlunesStrings.NA,
                                  style: TextStyle(
                                      fontSize: AppConfig.mediumFont,
                                      color: PlunesColors.BLACKCOLOR,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1),
                                  child: Text(
                                    PlunesStrings.viewDetails,
                                    style: TextStyle(
                                        fontSize: AppConfig.smallFont,
                                        color: PlunesColors.GREENCOLOR,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              alignment: Alignment.topRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  _solutionReceivedTime == null ||
                                          _solutionReceivedTime == 0
                                      ? Container()
                                      : StreamBuilder(
                                          builder: (context, snapShot) {
                                            return Text(
                                              DateUtil.getDuration(
                                                      _solutionReceivedTime) ??
                                                  PlunesStrings.NA,
                                              style: TextStyle(
                                                  fontSize:
                                                      AppConfig.smallFont),
                                            );
                                          },
                                          stream: _streamForTimer.stream,
                                        ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SolutionMap(
                                                  _searchedDocResults,
                                                  widget.catalogueData))).then(
                                          (value) {
                                        if (value != null && value) {
                                          Navigator.pop(context, true);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: AppConfig.verticalBlockSize * 1),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Flexible(
                                            flex: 2,
                                            child: Container(
                                              child: Image.asset(
                                                  plunesImages.locationIcon),
                                              height:
                                                  AppConfig.verticalBlockSize *
                                                      3,
                                              width: AppConfig
                                                      .horizontalBlockSize *
                                                  8,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 10,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2),
                                              child: Text(
                                                PlunesStrings.viewOnMap,
                                                textAlign: TextAlign.right,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize:
                                                        AppConfig.smallFont,
                                                    color:
                                                        PlunesColors.GREENCOLOR,
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                  color: PlunesColors.WHITECOLOR,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 4,
                        vertical: AppConfig.verticalBlockSize * 2),
                    child: StreamBuilder<RequestState>(
                      builder: (context, snapShot) {
                        if (snapShot.data is RequestSuccess) {
                          RequestSuccess _successObject = snapShot.data;
                          _searchedDocResults = _successObject.response;
                          _searchSolutionBloc.addIntoDocHosStream(null);
                          _checkShouldTimerRun();
                        } else if (snapShot.data is RequestFailed) {
                          RequestFailed _failedObject = snapShot.data;
                          _failureCause = _failedObject.failureCause;
                          _searchSolutionBloc.addIntoDocHosStream(null);
                          _cancelNegotiationTimer();
                        }
                        return _showContent(sc);
                      },
                      stream: _searchSolutionBloc.getDocHosStream(),
                    ),
                  ),
                ),
              ],
            ),
            (_timer != null && _timer.isActive && !(_isCrossClicked))
                ? _getHoldOnPopup()
                : Container(),
          ],
        );
      },
      boxShadow: null,
    );
  }

  _viewDetails() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
            catalogueData: _searchedDocResults?.catalogueData));
  }

  Widget _getHoldOnPopup() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xff99000000)),
              padding: EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SpinKitCircle(
                        color: Color(0xff01d35a),
                        size: 50.0,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Hold on",
                                          style: TextStyle(
                                              fontSize: AppConfig.smallFont,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      Expanded(child: Container()),
                                      InkWell(
                                          onTap: () {
                                            _isCrossClicked = true;
                                            _setState();
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: PlunesColors.WHITECOLOR,
                                          ))
                                    ],
                                  )),
                                ],
                              ),
                              Container(
                                child: Text(
                                  "We are negotiating the best fee for you."
                                  "It may take upto 10 mins, we'll update you.",
                                  style: TextStyle(
                                      fontSize: AppConfig.smallFont,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
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
  }

  void _fetchResultAndStartTimer() async {
    await _negotiate();
    if (_shouldStartTimer) {
      _startTimer();
    }
  }

  _cancelNegotiationTimer() {
    if (_searchedDocResults.solution?.services != null ||
        _searchedDocResults.solution.services.isNotEmpty) {
      _searchedDocResults.solution.services.forEach((service) {
        if (service.negotiating != null && service.negotiating) {
          service.negotiating = false;
        }
      });
    }
    if (_timer != null && _timer.isActive) {
      _timer?.cancel();
    }
    _setState();
  }

  _checkShouldTimerRun() {
    if (_searchedDocResults.solution?.services == null ||
        _searchedDocResults.solution.services.isEmpty) {
      if (_timer != null && _timer.isActive) {
        _cancelNegotiationTimer();
      }
      return;
    }
    bool shouldNegotiate = false;
    _solutionReceivedTime = _searchedDocResults.solution?.createdTime ?? 0;
    _searchedDocResults.solution.services.forEach((service) {
      if (service.negotiating != null && service.negotiating) {
        shouldNegotiate = true;
      }
    });
    if (shouldNegotiate) {
      _shouldStartTimer = true;
    } else {
      if (_timer != null && _timer.isActive) {
        _cancelNegotiationTimer();
      }
    }
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
}
