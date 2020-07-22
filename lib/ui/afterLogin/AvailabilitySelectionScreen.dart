import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as latest;

// ignore: must_be_immutable
class AvailabilitySelectionScreen extends BaseActivity {
  static const tag = '/availabilitySelectionScreen';
  final String url;

  AvailabilitySelectionScreen({Key key, this.url}) : super(key: key);

  @override
  _AvailabilitySelectionScreenState createState() =>
      _AvailabilitySelectionScreenState();
}

class _AvailabilitySelectionScreenState
    extends BaseState<AvailabilitySelectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth;
  UserBloc userBloc;
  LoginPost loginPost;
  String failureCause;
  DateTime initialTime;
  String url;
  bool hasSubmitted;
  bool progress = true;
  List<String> check = new List();
  List<String> from_1 = new List();
  List<String> from_2 = new List();
  List<String> to_1 = new List();
  List<String> to_2 = new List();
  List timeslots_ = new List();
  double _movingUnit = 30;
  StreamController _streamController;
  Timer _timer;

  List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> days_name = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  DateTime from1, from2, to1, to2, temporaryTimeObj;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timer = timer;
      if (_movingUnit == 30) {
        _movingUnit = 10;
      } else {
        _movingUnit = 30;
      }
      _streamController.add(null);
    });
    userBloc = UserBloc();
    getSlots();
    hasSubmitted = false;
    initialTime = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController?.close();
    super.dispose();
  }

  void getSlots() async {
    check.clear();
    from_1.clear();
    from_2.clear();
    to_1.clear();
    to_2.clear();
    var result =
        await userBloc.getUserProfile(UserManager().getUserDetails().uid);
    if (result is RequestSuccess) {
      RequestSuccess requestSuccess = result;
      loginPost = requestSuccess.response;
      if (loginPost.success != null && loginPost.success) {
        if (loginPost.user != null &&
            loginPost.user.timeSlots != null &&
            loginPost.user.timeSlots.isNotEmpty) {
          for (int i = 0; i < loginPost.user.timeSlots.length; i++) {
            from_1.add(
                loginPost.user.timeSlots[i].slots[0].toString().split("-")[0]);
            to_1.add(
                loginPost.user.timeSlots[i].slots[0].toString().split("-")[1]);
            check
                .add(loginPost.user.timeSlots[i].closed?.toString() ?? "false");
            from_2.add(
                loginPost.user.timeSlots[i].slots[1].toString().split("-")[0]);
            to_2.add(
                loginPost.user.timeSlots[i].slots[1].toString().split("-")[1]);
          }
        } else {
          for (int i = 0; i < 7; i++) {
            if (i == 6) {
              check.add("true");
            } else
              check.add("false");
            from_1.add("9:00 AM");
            from_2.add("3:00 PM");
            to_1.add("1:00 PM");
            to_2.add("8:00 PM");
          }
        }
      }
    }
    if (result is RequestFailed) {
      RequestFailed requestFailed = result;
      failureCause = requestFailed.failureCause;
    }
    progress = false;
    _setState();
  }

  void addSlot() async {
    if (from_1 == null ||
        from_1.length != 7 ||
        to_1 == null ||
        to_1.length != 7 ||
        from_2 == null ||
        from_2.length != 7 ||
        to_2 == null ||
        to_2.length != 7) {
      widget.showInSnackBar(
          "Empty slots found", PlunesColors.BLACKCOLOR, _scaffoldKey);
      return;
    }
    hasSubmitted = true;
    timeslots_.clear();
    for (int i = 0; i < 7; i++) {
      timeslots_.add({
        "slots": [
          from_1[i] + "-" + to_1[i],
          from_2[i] + "-" + to_2[i],
        ],
        "day": days_name[i],
        "closed": check[i]
      });
    }
    print(timeslots_);
    var data;
    data = {"timeSlots": timeslots_};
    userBloc.updateUserData(data);
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    var streamWidget = StreamBuilder(
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5, vertical: 5),
              child: Text(
                PlunesStrings.makeSureYouFillSlotAccurately,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
            ),
            Container(
              height: 35,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(),
                    flex: 1,
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: AnimatedContainer(
                              alignment: Alignment.center,
                              duration: Duration(seconds: 1),
                              margin:
                                  EdgeInsets.only(top: _movingUnit, left: 8),
                              child: Icon(
                                Icons.arrow_downward,
                                size: 28.0,
                                color: PlunesColors.GREENCOLOR,
                              )),
                        ),
                      ],
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Container(),
                    flex: 3,
                  ),
                  Expanded(
                    child: Container(),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      stream: _streamController.stream,
    );
    final header = Container(
      margin: EdgeInsets.only(top: 15, bottom: 4, right: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Center(
                child: Text(
              "All",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
          Expanded(
            flex: 2,
            child: Center(
                child: Text("From - To",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            flex: 2,
            child: Center(
                child: Text("From - To",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            flex: 1,
            child: Center(
                child: Text("Closed",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );

    final dayList = Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color(0xffefefef)),
                      child: Center(
                        child: Text(days[index]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
                            _openTimePicker("form1", index);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: Text(
                                from_1[index],
                                style: TextStyle(
                                    fontSize: 10,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
//                            _openTimePicker("to1", index);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: Text(
                                to_1[index],
                                style: TextStyle(
                                    fontSize: 10,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
//                            _openTimePicker("form2", index);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: Text(
                                from_2[index],
                                style: TextStyle(
                                    fontSize: 10,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
//                            _openTimePicker("to2", index);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: Text(
                                to_2[index],
                                style: TextStyle(
                                    fontSize: 10,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                        child: Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: Colors.grey,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        onTap: () {
                          setState(() {
                            if (check[index] == 'true') {
                              check[index] = 'false';
                            } else {
                              check[index] = 'true';
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            child: check[index] == 'true'
                                ? Image.asset(
                                    'assets/images/bid/check.png',
                                    height: 20,
                                    width: 20,
                                  )
                                : Image.asset(
                                    'assets/images/bid/uncheck.png',
                                    height: 20,
                                    width: 20,
                                  ),
                          ),
                        ),
                      ),
                    ))),
              ],
            ),
          );
        },
        itemCount: from_1?.length ?? 0,
      ),
    );

    final submit = Container(
      margin: EdgeInsets.only(bottom: 20),
      child: StreamBuilder<RequestState>(
          stream: userBloc.baseStream,
          builder: (context, snapshot) {
            if (snapshot.data is RequestInProgress && hasSubmitted) {
              return CustomWidgets().getProgressIndicator();
            }
            if (snapshot.data is RequestSuccess && hasSubmitted) {
              Future.delayed(Duration(milliseconds: 20)).then((value) {
                widget.showInSnackBar("Time slots updated Sucessfully",
                    PlunesColors.BLACKCOLOR, _scaffoldKey);
                Future.delayed(Duration(seconds: 1)).then((value) {
                  Navigator.pop(context);
                });
              });
            }
            if (snapshot.data is RequestFailed && hasSubmitted) {
              RequestFailed requestFailed = snapshot.data;
              Future.delayed(Duration(milliseconds: 20)).then((value) {
                widget.showInSnackBar(
                    requestFailed.failureCause ?? "Unable to Update Slots",
                    PlunesColors.BLACKCOLOR,
                    _scaffoldKey);
              });
              userBloc.addIntoStream(null);
            }
            return InkWell(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              onTap: addSlot,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color(0xff01d35a)),
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }),
    );

    final loading = Expanded(
        child: ListView.builder(
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
            baseColor: Color(0xffF5F5F5),
            highlightColor: Color(0xffFAFAFA),
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Color(0xffefefef)),
                        child: Center(
                          child: Text(""),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "00:00",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                            child: Image.asset('assets/images/bid/check.png',
                                height: 20, width: 20)),
                      ))),
                ],
              ),
            ));
      },
      itemCount: 7,
    ));

    final form = Container(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20, top: 5, bottom: 10),
            child: failureCause == null
                ? Column(
                    children: <Widget>[
                      progress ? Container() : streamWidget,
                      header,
                      progress ? loading : dayList,
                      submit
                    ],
                  )
                : Center(
                    child: Text(failureCause ?? "No data available!"),
                  )));

    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.availability, true),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: form);
  }

  Widget _confirmation(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Repeat'),
      content: new Container(
        child: Column(
          children: <Widget>[
            Text("Repeat this slot in whole week"),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop("Done");
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color(0xff01d35a),
                            border:
                                Border.all(width: 1, color: Color(0xff01d35a))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("No"),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(width: 1, color: Colors.grey)),
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _openTimePicker(String check, int position) {
    latest.DatePicker.showTime12hPicker(context, currentTime: initialTime,
        onConfirm: (date) {
      if (date == null) {
        return;
      }
      temporaryTimeObj = date;
      _setTimeInBoxes(temporaryTimeObj, position, check);
    });
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  _setTimeInBoxes(DateTime time, int position, String check) async {
    if (time != null) {
      if (check == 'form1') {
        from1 = time;
        _openTimePicker("to1", position);
        return;
      } else if (check == 'to1') {
        if (from1.isBefore(time)) {
          to1 = time;
          _showSubmitNextSlotPopup();
          Future.delayed(Duration(milliseconds: 2000)).then((value) async {
            if (mounted) {
              Navigator.pop(context);
            }
            Future.delayed(Duration(milliseconds: 400)).then((value) {
              if (mounted && context != null) {
                _openTimePicker("form2", position);
              }
            });
          });
          return;
        } else {
          from1 = null;
          to1 = null;
          _showSnackBar("Please select valid time");
          return;
        }
      } else if (check == 'form2') {
        if (to1.isBefore(time)) {
          from2 = time;
          _openTimePicker("to2", position);
          return;
        } else {
          from1 = null;
          to1 = null;
          from2 = null;
          _showSnackBar("Please select valid time");
          return;
        }
      } else if (check == 'to2') {
        if (from2.isBefore(time)) {
          _showSubmitNextSlotPopup(isCompleted: true);
          Future.delayed(Duration(milliseconds: 2000)).then((value) async {
            if (mounted) {
              Navigator.pop(context);
            }
            Future.delayed(Duration(milliseconds: 400)).then((value) async {
              if (mounted && context != null) {
                to2 = time;
                from_1[position] = DateUtil.getTimeWithAmAndPmFormat(from1);
                to_1[position] = DateUtil.getTimeWithAmAndPmFormat(to1);
                from_2[position] = DateUtil.getTimeWithAmAndPmFormat(from2);
                to_2[position] = DateUtil.getTimeWithAmAndPmFormat(to2);
                if (position == 0) {
                  var result = await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (
                      BuildContext context,
                    ) =>
                        _confirmation(context),
                  );
                  if (result != null &&
                      result.toString().isNotEmpty &&
                      result == "Done") {
                    for (int i = 0; i < days.length; i++) {
                      from_1[i] = from_1[0];
                      from_2[i] = from_2[0];
                      to_1[i] = to_1[0];
                      to_2[i] = to_2[0];
                    }
                  }
                }
                _setState();
              }
            });
          });
        } else {
          from1 = null;
          to1 = null;
          from2 = null;
          to2 = time;
          _showSnackBar("Please select valid time");
          return;
        }
      }
      _setState();
    }
  }

  void _showSnackBar(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, _scaffoldKey);
  }

  void _showSubmitNextSlotPopup({bool isCompleted = false}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 42,
                horizontal: AppConfig.horizontalBlockSize * 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      isCompleted ? "Slot's filled!" : "Slot one filled ",
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                    Icon(
                      Icons.check,
                      color: PlunesColors.GREENCOLOR,
                    )
                  ],
                ),
                isCompleted
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 1),
                        child: Text(
                          PlunesStrings.enterTheRestToSubmit,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
              ],
            ),
          );
        });
  }
}
