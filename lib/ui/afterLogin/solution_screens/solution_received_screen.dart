import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';

// ignore: must_be_immutable
class SolutionReceivedScreen extends BaseActivity {
  final CatalogueData catalogueData;

  SolutionReceivedScreen({this.catalogueData});

  @override
  _SolutionReceivedScreenState createState() => _SolutionReceivedScreenState();
}

class _SolutionReceivedScreenState extends BaseState<SolutionReceivedScreen> {
  Completer<GoogleMapController> _googleMapController;
  Timer _timer;
  int _tenMinutesInSeconds = 600;
  SearchSolutionBloc _searchSolutionBloc;
  SearchedDocResults _searchedDocResults;

  bool _isFetchingInitialData;
  String _failureCause;

  @override
  void initState() {
    _isFetchingInitialData = true;
    _googleMapController = Completer();
    _searchSolutionBloc = SearchSolutionBloc();
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                    ? CustomWidgets().errorWidget(_failureCause)
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
              () => _onBookingTap(index),
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
    print("_checkAvailability");
  }

  _onBookingTap(int selectedIndex) {
    print("timer rinning ${_timer?.isActive}");
    _timer.cancel();
    print("timer rinning ${_timer?.isActive}");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BookingMainScreen()));
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
      }
    } else if (result is RequestFailed) {
      _failureCause = result.failureCause;
      _timer?.cancel();
    }
    _isFetchingInitialData = false;
    _setState();
  }

  _setState() {
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _negotiate();
      _tenMinutesInSeconds = _tenMinutesInSeconds - 2;
      if (_tenMinutesInSeconds <= 0) {
        timer?.cancel();
      }
    });
  }

  Widget _showBody() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      padding: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
      child: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
                padding: EdgeInsets.all(0.0),
                initialCameraPosition: CameraPosition(
                    target: LatLng(17.23432, 18.343), zoom: 4.0)),
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
                        flex: 1,
                        child: Text(
                          widget.catalogueData.service ?? PlunesStrings.NA,
                          style: TextStyle(
                              fontSize: AppConfig.mediumFont,
                              color: PlunesColors.BLACKCOLOR,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Container()),
                      InkWell(
                        onTap: () => _viewDetails(),
                        child: CustomWidgets().getRoundedButton(
                            PlunesStrings.viewDetails,
                            AppConfig.horizontalBlockSize * 8,
                            PlunesColors.GREENCOLOR,
                            AppConfig.horizontalBlockSize * 3,
                            AppConfig.verticalBlockSize * 1,
                            PlunesColors.WHITECOLOR),
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
                        } else if (snapShot.data is RequestFailed) {
                          RequestFailed _failedObject = snapShot.data;
                          _failureCause = _failedObject.failureCause;
                          _timer?.cancel();
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
    );
  }

  _viewDetails() {
    print("view details");
  }
}
