import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class SolutionReceivedScreen extends BaseActivity {
  @override
  _SolutionReceivedScreenState createState() => _SolutionReceivedScreenState();
}

class _SolutionReceivedScreenState extends State<SolutionReceivedScreen> {
  Completer<GoogleMapController> _googleMapController;

  @override
  void initState() {
    _googleMapController = Completer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: widget.getAppBar(context, PlunesStrings.solutionSearched, true),
      body: Builder(builder: (context) {
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
                  child: _showContent(),
                ),
                color: PlunesColors.WHITECOLOR,
              ))
            ],
          ),
        );
      }),
    ));
  }

  Widget _showContent() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CustomWidgets().getMedicalDetailRow(index);
      },
      itemCount: 5,
    );
  }
}
