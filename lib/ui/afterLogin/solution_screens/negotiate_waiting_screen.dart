import 'dart:async';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_received_screen.dart';

// ignore: must_be_immutable
class BiddingLoading extends BaseActivity {
  final CatalogueData catalogueData;

  BiddingLoading({this.catalogueData});

  @override
  _BiddingLoadingState createState() => _BiddingLoadingState();
}

class _BiddingLoadingState extends BaseState<BiddingLoading> {
  double _bidProgress = 0.0;
  Timer _timer;
  int _start = 0;
  double _movingUnit = 110;

  @override
  void initState() {
    super.initState();
    _startAnimating();
  }

  _startAnimating() {
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        _start = _start + 1;
        if (_start > 9) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SolutionReceivedScreen(
                        catalogueData: widget.catalogueData,
                      ))).then((value) {
            Navigator.pop(context);
          });
        } else {
          _bidProgress = _bidProgress + 0.1;
          if (_movingUnit == 110) {
            _movingUnit = 10;
          } else {
            _movingUnit = 110;
          }
          _startAnimating();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlunesColors.WHITECOLOR,
      body: Container(
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: AppConfig.verticalBlockSize * 16,
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      height: 150,
                      width: 150,
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Colors.white, Color(0xfffafafa)],
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    stops: [0.0, 1.0],
                                    tileMode: TileMode.clamp),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(75),
                                ),
                                border: Border.all(
                                    color: Color(0xfffafafa), width: 2)),
                          ),
                          Align(
                            child: AnimatedContainer(
                              duration: Duration(seconds: 1),
                              height: 70,
                              width: 70,
                              margin: EdgeInsets.only(top: _movingUnit),
                              child: Center(
                                child: Image.asset(
                                  plunesImages.bidActiveIcon,
                                  height: 70,
                                  width: 70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppConfig.verticalBlockSize * 7,
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 9),
                    child: Text(
                      PlunesStrings.weAreGettingBestSolution,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.largeFont,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 170,
                ),
                Center(
                  child: Text(
                    PlunesStrings.receiving,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  height: 3,
                  margin:
                      EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                  child: LinearProgressIndicator(
                    value: _bidProgress,
                    backgroundColor: Color(0xffDCDCDC),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xff01d35a),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
