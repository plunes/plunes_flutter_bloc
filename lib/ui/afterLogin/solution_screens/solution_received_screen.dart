import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import '../../widgets/dialogPopScreen.dart';

// ignore: must_be_immutable
class SolutionReceivedScreen extends BaseActivity {
  final CatalogueData catalogueData;

  SolutionReceivedScreen({this.catalogueData});

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

  bool _isFetchingInitialData;
  String _failureCause;
  int _solutionReceivedTime = 0;
  bool _shouldStartTimer;
  StreamController _streamForTimer;
  TextEditingController _searchController;
  FocusNode _focusNode;
  final double lat = 28.4594965, long = 77.0266383;
  User _user;
  Set<Marker> _markers = {};

  @override
  void initState() {
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
          appBar:
              widget.getAppBar(context, PlunesStrings.solutionSearched, true),
          body: Builder(builder: (context) {
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

  Widget _showContent() {
    return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CustomWidgets().getDocOrHospitalDetailWidget(
              _searchedDocResults.solution?.services ?? [],
              index,
              () => _checkAvailability(index),
              () => _onBookingTap(
                  _searchedDocResults.solution.services[index], index),
              widget.catalogueData);
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
            catalogueData: widget.catalogueData,
            solutions: _searchedDocResults.solution.services[selectedIndex]));
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
    var result = await _searchSolutionBloc
        .getDocHosSolution(widget.catalogueData.serviceId);
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
      } else {
        _searchedDocResults.solution.services.forEach((docData) {
//          print("docDataidis  ${docData.toString()}");
          _markers.add(Marker(
              markerId: MarkerId(docData.sId),
              icon: BitmapDescriptor.defaultMarker,
              position:
                  LatLng(docData.latitude ?? lat, docData.longitude ?? long),
              infoWindow: InfoWindow(
                  title: docData.name,
                  snippet:
                      "\n${docData.distance?.toStringAsFixed(3)} kms away")));
        });
//        print("docDataidis  ${_markers.length}");
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
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _negotiate();
      _tenMinutesInSeconds = _tenMinutesInSeconds - 2;
      if (_tenMinutesInSeconds <= 0) {
        _cancelNegotiationTimer();
      }
    });
  }

  Widget _showBody() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      padding: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 3,
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
                    myLocationEnabled: true,
                    markers: _markers,
                    myLocationButtonEnabled: false,
                    onMapCreated: (mapController) {
                      _googleMapController.complete(mapController);
                    },
                    initialCameraPosition: CameraPosition(
                        target: LatLng(double.tryParse(_user.latitude) ?? lat,
                            double.tryParse(_user.longitude) ?? long),
                        zoom: 10.0)),
                flex: 1,
              ),
              Expanded(
                  child: Card(
                elevation: 0.0,
                margin: EdgeInsets.all(0.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 4,
                          vertical: AppConfig.verticalBlockSize * 2),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              widget.catalogueData.service ?? PlunesStrings.NA,
                              style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.BLACKCOLOR,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(child: Container()),
                          Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () => _viewDetails(),
                                child: CustomWidgets().getRoundedButton(
                                    PlunesStrings.viewDetails,
                                    AppConfig.horizontalBlockSize * 8,
                                    PlunesColors.GREENCOLOR,
                                    AppConfig.horizontalBlockSize * 3,
                                    AppConfig.verticalBlockSize * 1,
                                    PlunesColors.WHITECOLOR),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 1),
                                child: _solutionReceivedTime == null ||
                                        _solutionReceivedTime == 0
                                    ? Container()
                                    : StreamBuilder(
                                        builder: (context, snapShot) {
                                          return Text(DateUtil.getDuration(
                                                  _solutionReceivedTime) ??
                                              PlunesStrings.NA);
                                        },
                                        stream: _streamForTimer.stream,
                                      ),
                              )
                            ],
                          )
                        ],
                      ),
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
                            return _showContent();
                          },
                          stream: _searchSolutionBloc.getDocHosStream(),
                        ),
                      ),
                    ),
                  ],
                ),
                color: PlunesColors.WHITECOLOR,
              ))
            ],
          ),
          (_timer != null && _timer.isActive) ? holdOnPopUp : Container()
        ],
      ),
    );
  }

  _viewDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          CustomWidgets().buildAboutDialog(catalogueData: widget.catalogueData),
    );
//    print("view details");
  }

  final holdOnPopUp = Container(
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
                      // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Hold on",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ],
                                )),
                              ],
                            ),
                            Container(
                              child: Text(
                                "We are negotiating the best fee for you."
                                " It may take sometime, we'll update you.",
                                style: TextStyle(
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
}
