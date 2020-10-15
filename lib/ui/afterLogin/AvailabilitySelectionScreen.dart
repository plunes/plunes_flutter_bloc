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
import 'package:plunes/models/doc_hos_models/common_models/availability_model.dart';
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

  ///////////new////////////
  List<AvailabilityModel> _availabilityModel;
  int _currentDayIndex = 0;

  ////////////////////////
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
    _currentDayIndex = 0;
//    _streamController = StreamController.broadcast();
//    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//      _timer = timer;
//      if (_movingUnit == 30) {
//        _movingUnit = 10;
//      } else {
//        _movingUnit = 30;
//      }
//      _streamController.add(null);
//    });
    _availabilityModel = [];
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
    failureCause = null;
    if (progress != null && progress == false) {
      progress = true;
      _setState();
    }
    check = [];
    from_1 = [];
    from_2 = [];
    to_1 = [];
    to_2 = [];
    var result =
        await userBloc.getUserProfile(UserManager().getUserDetails().uid);
    _availabilityModel = [];
    if (result is RequestSuccess) {
      RequestSuccess requestSuccess = result;
      loginPost = requestSuccess.response;
      if (loginPost.success != null && loginPost.success) {
        if (loginPost.user != null &&
            loginPost.user.timeSlots != null &&
            loginPost.user.timeSlots.isNotEmpty) {
          for (int i = 0; i < loginPost.user.timeSlots.length; i++) {
            _availabilityModel.add(AvailabilityModel(
                isSelected: i == 0 ? true : false,
                closed: loginPost.user.timeSlots[i].closed ?? false,
                day: days_name[i],
                slots: loginPost.user.timeSlots[i].slots ?? []));
          }
        } else {
          for (int i = 0; i < 7; i++) {
            _availabilityModel.add(AvailabilityModel(
                isSelected: i == 0 ? true : false,
                closed: i == 6 ? true : false,
                day: days_name[i],
                slots: []));
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
      _showSnackBar("Empty slots found");
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
//    print(timeslots_);
    var data;
    data = {"timeSlots": timeslots_};
    userBloc.updateUserData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.availability, true),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: _getBody());
  }

  _openTimePicker(String check, int position) {
    latest.DatePicker.showTime12hPicker(context, currentTime: initialTime,
        onConfirm: (date) {
      if (date == null) {
        return;
      }
      temporaryTimeObj = date;
//      _setTimeInBoxes(temporaryTimeObj, position, check);
    });
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

//  _setTimeInBoxes(DateTime time, int position, String check) async {
//    if (time != null) {
//      if (check == 'form1') {
//        from1 = time;
//        _openTimePicker("to1", position);
//        return;
//      } else if (check == 'to1') {
//        if (from1.isBefore(time)) {
//          to1 = time;
//          _showSubmitNextSlotPopup();
//          Future.delayed(Duration(milliseconds: 2000)).then((value) async {
//            if (mounted) {
//              Navigator.pop(context);
//            }
//            Future.delayed(Duration(milliseconds: 400)).then((value) {
//              if (mounted && context != null) {
//                _openTimePicker("form2", position);
//              }
//            });
//          });
//          return;
//        } else {
//          from1 = null;
//          to1 = null;
//          _showSnackBar("Please select valid time");
//          return;
//        }
//      } else if (check == 'form2') {
//        if (to1.isBefore(time)) {
//          from2 = time;
//          _openTimePicker("to2", position);
//          return;
//        } else {
//          from1 = null;
//          to1 = null;
//          from2 = null;
//          _showSnackBar("Please select valid time");
//          return;
//        }
//      } else if (check == 'to2') {
//        if (from2.isBefore(time)) {
//          _showSubmitNextSlotPopup(isCompleted: true);
//          Future.delayed(Duration(milliseconds: 2000)).then((value) async {
//            if (mounted) {
//              Navigator.pop(context);
//            }
//            Future.delayed(Duration(milliseconds: 400)).then((value) async {
//              if (mounted && context != null) {
//                to2 = time;
//                from_1[position] = DateUtil.getTimeWithAmAndPmFormat(from1);
//                to_1[position] = DateUtil.getTimeWithAmAndPmFormat(to1);
//                from_2[position] = DateUtil.getTimeWithAmAndPmFormat(from2);
//                to_2[position] = DateUtil.getTimeWithAmAndPmFormat(to2);
//                if (position == 0) {
//                  var result = await showDialog(
//                    context: context,
//                    barrierDismissible: true,
//                    builder: (
//                      BuildContext context,
//                    ) =>
//                        _confirmation(context),
//                  );
//                  if (result != null &&
//                      result.toString().isNotEmpty &&
//                      result == "Done") {
//                    for (int i = 0; i < days.length; i++) {
//                      from_1[i] = from_1[0];
//                      from_2[i] = from_2[0];
//                      to_1[i] = to_1[0];
//                      to_2[i] = to_2[0];
//                    }
//                  }
//                }
//                _setState();
//              }
//            });
//          });
//        } else {
//          from1 = null;
//          to1 = null;
//          from2 = null;
//          to2 = time;
//          _showSnackBar("Please select valid time");
//          return;
//        }
//      }
//      _setState();
//    }
//  }

  void _showSnackBar(String message, {bool shouldPop = false}) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets()
              .getInformativePopup(globalKey: _scaffoldKey, message: message);
        }).then((value) {
      if (shouldPop) {
        Navigator.pop(context);
      }
    });
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 5,
            vertical: AppConfig.verticalBlockSize * 2),
        color: Color(CommonMethods.getColorHexFromStr("#FFFFFF")),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 4,
                  vertical: AppConfig.verticalBlockSize * 2),
              child: Text(
                "Enter your time slots correctly so that you obtain reservations according to your availability",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 15,
                    fontWeight: FontWeight.normal),
              ),
            ),
            Container(
              width: double.infinity,
              height: AppConfig.verticalBlockSize * 8,
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 3),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (index != _currentDayIndex) {
                        _currentDayIndex = index;
                        _availabilityModel.forEach((element) {
                          element.isSelected = false;
                        });
//                      print("_currentDayIndex ${_availabilityModel[_currentDayIndex].closed}");
                        _availabilityModel[index].isSelected = true;
                        _setState();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          right: AppConfig.horizontalBlockSize * 2.5),
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 2.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: _availabilityModel[index]?.isSelected ?? false
                            ? PlunesColors.GREENCOLOR
                            : PlunesColors.GREYCOLOR.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Text(
                          _availabilityModel[index]
                                  ?.day
                                  ?.substring(0, 3)
                                  ?.toUpperCase() ??
                              PlunesStrings.NA,
                          style: TextStyle(
                            color:
                                _availabilityModel[index]?.isSelected ?? false
                                    ? PlunesColors.WHITECOLOR
                                    : PlunesColors.BLACKCOLOR,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _availabilityModel?.length ?? 0,
              ),
            ),
            _getSlotView(),
            Container(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 4),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                elevation: 3.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 4,
                          vertical: AppConfig.verticalBlockSize * 3),
                      child: Text(
                        "Apply this time slot to",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR.withOpacity(.7),
                            fontSize: AppConfig.mediumFont,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: AppConfig.verticalBlockSize * 10,
                      margin: EdgeInsets.all(
                        AppConfig.horizontalBlockSize * 3,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (index != _currentDayIndex) {
                                _currentDayIndex = index;
                                _availabilityModel.forEach((element) {
                                  element.isSelected = false;
                                });
                                _availabilityModel[index].isSelected = true;
                                _setState();
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      left: AppConfig.verticalBlockSize * .8,
                                      bottom:
                                          AppConfig.horizontalBlockSize * 2),
                                  child: Text(
                                    _availabilityModel[index]
                                            ?.day
                                            ?.substring(0, 3)
                                            ?.toUpperCase() ??
                                        PlunesStrings.NA,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _availabilityModel[index]
                                                  ?.isSelected ??
                                              false
                                          ? PlunesColors.SPARKLINGGREEN
                                          : PlunesColors.BLACKCOLOR,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: AppConfig.verticalBlockSize * 5.4,
                                  height: AppConfig.verticalBlockSize * 5.4,
                                  margin: EdgeInsets.only(
                                      right: AppConfig.horizontalBlockSize * 4),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        _availabilityModel[index]?.isSelected ??
                                                false
                                            ? PlunesColors.GREENCOLOR
                                            : PlunesColors.GREYCOLOR
                                                .withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: _availabilityModel?.length ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 3),
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: Text(
                    "Submit",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: PlunesColors.SPARKLINGGREEN,
                        fontSize: AppConfig.largeFont + 3,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getSlotView() {
    if (_availabilityModel == null || _availabilityModel.isEmpty) {
      return Container();
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.5),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _availabilityModel[_currentDayIndex].closed =
                        !_availabilityModel[_currentDayIndex].closed;
                    _setState();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: PlunesColors.GREYCOLOR.withOpacity(0.3)),
                    height: AppConfig.verticalBlockSize * 4,
                    width: AppConfig.horizontalBlockSize * 8,
                    child: (_availabilityModel[_currentDayIndex] == null ||
                                _availabilityModel[_currentDayIndex].closed ??
                            false)
                        ? Container()
                        : Center(
                            child: Icon(
                              Icons.check,
                              color: PlunesColors.GREENCOLOR,
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
                  child: Text(
                    "OPEN",
                    style:
                        TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 11,
                        child: Card(
                          elevation: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * .7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  _availabilityModel[_currentDayIndex]
                                      .slots[index]
                                      .split("-")[0],
                                  style:
                                      TextStyle(fontSize: AppConfig.mediumFont),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: PlunesColors.BLACKCOLOR,
                                ),
                                Text(
                                  _availabilityModel[_currentDayIndex]
                                      .slots[index]
                                      .split("-")[1],
                                  style:
                                      TextStyle(fontSize: AppConfig.mediumFont),
                                ),
                              ],
                            ),
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: AppConfig.extraLargeFont),
                          onPressed: () {}),
                    ),
                    // Expanded(
                    //     flex: 1,
                    //     child: IconButton(
                    //         icon: Stack(
                    //             alignment: Alignment.bottomCenter,
                    //             fit: StackFit.loose,
                    //             overflow: Overflow.visible,
                    //             children: <Widget>[
                    //               Positioned(
                    //                 top: -5,
                    //                 left: 7,
                    //                 child: Icon(
                    //                   Icons.mode_edit,
                    //                   color: PlunesColors.SPARKLINGGREEN,
                    //                   size: AppConfig.mediumFont + 2.5,
                    //                 ),
                    //               ),
                    //               Icon(
                    //                 Icons.check_box_outline_blank,
                    //                 color: PlunesColors.SPARKLINGGREEN,
                    //                 size: AppConfig.mediumFont + 4,
                    //               )
                    //             ]),
                    //         onPressed: () {}))
                  ],
                ),
              );
            },
            itemCount: _availabilityModel[_currentDayIndex].slots?.length ?? 0,
            shrinkWrap: true,
          ),
          Container(
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
            child: InkWell(
              onTap: () {
                print("hello");
              },
              child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: AppConfig.veryExtraLargeFont - 15,
                    color: PlunesColors.SPARKLINGGREEN,
                  )
                  // Container(
                  //   height: 28,
                  //   width: 48,
                  //   decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: PlunesColors.WHITECOLOR,
                  //       border: Border.all(color: PlunesColors.GREENCOLOR)),
                  //   child: Center(
                  //     child: Icon(
                  //       Icons.add,
                  //       size: 18,
                  //       color: PlunesColors.SPARKLINGGREEN,
                  //     ),
                  //   ),
                  // ),
                  ),
            ),
          ),
          Container(
            child: Text(
              "Add more slots",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontSize: AppConfig.smallFont - 1,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
