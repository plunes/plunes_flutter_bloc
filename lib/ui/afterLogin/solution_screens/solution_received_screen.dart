import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class SolutionReceivedScreen extends BaseActivity {
  final String specialityId;

  SolutionReceivedScreen({this.specialityId});

  @override
  _SolutionReceivedScreenState createState() => _SolutionReceivedScreenState();
}

class _SolutionReceivedScreenState extends BaseState<SolutionReceivedScreen> {
  Completer<GoogleMapController> _googleMapController;
  Timer _timer;
  int _tenMinutesInSeconds = 600;
  SearchSolutionBloc _searchSolutionBloc;
  List<Services> _docHosList;
  SearchedDocResults _searchedDocResults;

  bool _isFetchingInitialData;
  String _failureCause;

  @override
  void initState() {
    _docHosList = [];
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
        child: Scaffold(
      key: scaffoldKey,
      appBar: widget.getAppBar(context, PlunesStrings.solutionSearched, true),
      body: Builder(builder: (context) {
        return _isFetchingInitialData
            ? CustomWidgets().getProgressIndicator()
            : _searchedDocResults == null ||
                    _docHosList == null ||
                    _docHosList.isEmpty
                ? CustomWidgets().errorWidget(_failureCause)
                : _showBody();
      }),
    ));
  }

  Widget _showContent() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CustomWidgets().getDocOrHospitalDetailRow(
            index, () => _checkAvailability(), () => _onBookingTap());
      },
      itemCount: 5,
    );
  }

  _checkAvailability() {}

  _onBookingTap() {}

  Future<RequestState> _negotiate() async {
    var result =
        await _searchSolutionBloc.getDocHosSolution(widget.specialityId);
    if (_docHosList != null && _docHosList.isNotEmpty) {
      return null;
    }
    if (result is RequestSuccess) {
      _searchedDocResults = result.response;
      _docHosList = _searchedDocResults?.solution?.services;
      if (_docHosList == null || _docHosList.isEmpty) {
        _failureCause = PlunesStrings.oopsServiceNotAvailable;
      }
    } else if (result is RequestFailed) {
      _failureCause = result.failureCause;
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
      timer.cancel();
      return;
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
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 4,
                  vertical: AppConfig.verticalBlockSize * 2),
              child: StreamBuilder<RequestState>(
                builder: (context, snapShot) {
                  if (snapShot.data is RequestSuccess) {
                    RequestSuccess _successObject = snapShot.data;
                    _searchedDocResults = _successObject.response;
                    _docHosList = _searchedDocResults?.solution?.services;
                  } else if (snapShot.data is RequestFailed) {
                    RequestFailed _failedObject = snapShot.data;
                    _failureCause = _failedObject.failureCause;
                  }
                  return _showContent();
                },
                stream: _searchSolutionBloc.getDocHosStream(),
              ),
            ),
            color: PlunesColors.WHITECOLOR,
          ))
        ],
      ),
    );
  }
}
