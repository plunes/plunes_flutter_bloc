import 'dart:async';

/// Created by Manvendra Kumar Singh

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/HealthSoulutionNear.dart';

class BiddingScreen extends BaseActivity {
  static const tag = '/biddingscreen';

  @override
  _BiddingScreenState createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  var globalHeight, globalWidth;
  Preferences _preferences;

  List data = new List();
  Timer _timer, _timerTip;
  double _bottomSpace = 0;
  bool hideTip = true;


  @override
  void initState() {
    animateObject();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(_timer!=null)
    _timer.cancel();
    if(_timerTip!=null)
    _timerTip.cancel();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 100),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, HealthSolutionNear.tag);
                      },
                      child: widget.createTextViews(
                          stringsFile.solutionNearYouMsg,
                          20,
                          colorsFile.black0,
                          TextAlign.center,
                          FontWeight.normal))),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Center(
                        child: widget.createTextViews(
                            stringsFile.searchNearByMsg,
                            20,
                            colorsFile.black0,
                            TextAlign.center,
                            FontWeight.normal)),
                    searchRowView(),
                  ],
                ),
              ),
            ),
            Align(
                alignment: FractionalOffset.bottomCenter,
                child: getSolutionActivityRowView())
          ],
        ),
      ),
    );
  }

  Widget searchRowView() {
    return Container(
        margin: EdgeInsets.all(20),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: _searchController,
                      style: DefaultTextStyle.of(context).style.copyWith(),
                      onChanged: (text) {
                        setState(() {
                          if (text.length != 0) {
//                            cancel = true;
                          } else {
//                            cancel = false;
                          }
                        });
                      },
                      decoration: widget.inputDecorationWithoutError(stringsFile.searchHint)),
                  suggestionsCallback: (pattern) {
                    if (pattern != '') {
//                      filter_data(pattern);
                    } else {
//                      filter_data(pattern);
                    }

                    return data;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                        title: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            style: TextStyle(color: Colors.black),
                            text: suggestion.toString().contains('(Procedure)')
                                ? suggestion.toString().split('(Procedure)')[0]
                                : suggestion,
                          ),
                          TextSpan(
                            style: TextStyle(
                                color: Color(hexColorCode.defaultGreen)),
                            text: suggestion.toString().contains('(Procedure)')
                                ? '(Procedure)'
                                : '',
                          ),
                        ],
                      ),
                    ));
                  },
                  hideOnEmpty: false,
                  noItemsFoundBuilder: (context) {
                    return Container(
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                        onTap: () {
//                          submit_procedure.add(_searchcontroller.text);
//                          _searchController.text = "";

                          setState(() {
//                            cancel = false;
//                            btn = false;
//                            _searchController.text = '';
                          });

                          /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadPrescription(
                                  procedure_list: submit_procedure,
                                  bidding_type: "mannual",
                                  latitude: latitude,
                                  longitude: longitude,
                                ),
                              ));*/
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                  "Get Solution",
                                  style: TextStyle(
                                      color: Color(0xff01d35a),
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
//                      btn = true;
//                      cancel = false;
//                      _searchController.text = '';
//                      selected_procedure = suggestion;
                    });
                  },
                ),
                Visibility(
                  visible: hideTip,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 250,
                          margin: EdgeInsets.only(top: 10),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Get Started",
                                    style: TextStyle(color: Color(0xffBFF3D5))),
                                Text("Type the test or procedure",
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                              color: Color(0xff65D45A)),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: 250,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                              onTap: () {
                                _preferences.setPreferencesBoolean(
                                    Constants.IS_TIP_HIDE, true);
                                hideTip = true;
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/arrow.png',
                          color: Color(0xff65D45A),
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            /*    cancel
                ? Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  setState(() {
                    cancel = false;
                    _searchController.text = '';
                  });
                },
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.clear),
                  ),
                ),
              ),
            )
                : Container(),*/
          ],
        ));
  }

  Widget getSolutionActivityRowView() {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(_createRoute());
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  widget.createTextViews(stringsFile.solutionActivity, 18, colorsFile.black0, TextAlign.center, FontWeight.normal),
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    margin: EdgeInsets.only(bottom: _bottomSpace),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: Color(hexColorCode.defaultGreen)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void animateObject() {
    _preferences = Preferences();
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _bottomSpace = _bottomSpace == 0 ? 10 : 0;
      });
    });
    hideTip = !_preferences.getPreferenceBoolean(Constants.IS_TIP_HIDE);
    if (!_preferences.getPreferenceBoolean(Constants.IS_TIP_HIDE)) {
      _timerTip = Timer(Duration(seconds: 5), () {
        _timerTip.cancel();
        _preferences.setPreferencesBoolean(Constants.IS_TIP_HIDE, true);
        setState(() {
          hideTip = false;
        });
      });
    }

  }

  Route _createRoute() {
    /*   return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => BiddingActivity(
        screen: 0,
        single: "multiple",
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );*/
  }
}
