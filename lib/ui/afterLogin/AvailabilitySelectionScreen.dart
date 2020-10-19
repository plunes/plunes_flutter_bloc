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
import 'package:plunes/res/AssetsImagesFile.dart';
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
  List _timeSlots = new List();

  ///////////new////////////
  List<AvailabilityModel> _availabilityModel;
  int _currentDayIndex = 0;
  static const int _fromIndex = 0, _toIndex = 1;
  ScrollController _dayScrollController, _daySelectionScrollController;

  ////////////////////////
//  double _movingUnit = 30;
//  StreamController _streamController;
//  Timer _timer;

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
  DateTime from1,
      from2,
      to1,
      to2,
      _tempFromHolder,
      _tempToHolder,
      _fromDateHolderForSlotEdit,
      _toDateHolderForSlotEdit;

  @override
  void initState() {
    _currentDayIndex = 0;
    _dayScrollController = ScrollController();
    _daySelectionScrollController = ScrollController();
    _availabilityModel = [];
    userBloc = UserBloc();
    _getSlots();
    hasSubmitted = false;
    initialTime = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _dayScrollController?.dispose();
    _daySelectionScrollController?.dispose();
    super.dispose();
  }

  void _getSlots() async {
    failureCause = null;
    if (progress != null && progress == false) {
      progress = true;
      _setState();
    }
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
                slots: loginPost.user.timeSlots[i].slots ?? [],
                daySelectionList: days_name
                    .map(
                        (e) => DaySelectionModel(isSelected: false, dayName: e))
                    .toList(growable: true)));
          }
        } else {
          for (int i = 0; i < 7; i++) {
            _availabilityModel.add(AvailabilityModel(
                isSelected: i == 0 ? true : false,
                closed: i == 6 ? true : false,
                day: days_name[i],
                slots: [],
                daySelectionList: days_name
                    .map(
                        (e) => DaySelectionModel(isSelected: false, dayName: e))
                    .toList(growable: true)));
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

  void _submitSlots() async {
    _timeSlots =
        _availabilityModel.map((e) => e.toJson()).toList(growable: true);
//    print("timeslots_ $_timeSlots");
    var data;
    data = {"timeSlots": _timeSlots};
    userBloc.updateUserData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.availability, true),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: (progress != null && progress)
            ? CustomWidgets().getProgressIndicator()
            : (_availabilityModel == null || _availabilityModel.isEmpty)
                ? CustomWidgets().errorWidget(
                    failureCause ?? "No data available!",
                    onTap: () => _getSlots(),
                    isSizeLess: true)
                : _getBody());
  }

  _openTimePicker(int position) {
    latest.DatePicker.showTime12hPicker(context, currentTime: initialTime,
        onConfirm: (date) {
      if (date == null) {
        return;
      }
      if (position == _fromIndex) {
        _tempFromHolder = date;
      } else if (position == _toIndex) {
        _tempToHolder = date;
      }
      _setTimeInBoxes(position);
    });
  }

  _openTimePickerForSlotEditing(int position) {
    latest.DatePicker.showTime12hPicker(context, currentTime: initialTime,
        onConfirm: (date) {
      if (date == null) {
        return;
      }
      if (_fromDateHolderForSlotEdit == null) {
        _fromDateHolderForSlotEdit = date;
        _openTimePickerForSlotEditing(position);
        return;
      } else if (_toDateHolderForSlotEdit == null) {
        _toDateHolderForSlotEdit = date;
      }
      _editTime(position);
    });
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

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
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      controller: _dayScrollController,
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
                              _availabilityModel[index]
                                  .daySelectionList
                                  ?.forEach((element) {
                                element.isSelected = false;
                              });
                              _setState();
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                right: AppConfig.horizontalBlockSize * 2.5),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppConfig.horizontalBlockSize * 2.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color:
                                  _availabilityModel[index]?.isSelected ?? false
                                      ? PlunesColors.GREENCOLOR
                                      : Color(CommonMethods.getColorHexFromStr(
                                          "#F5F5F5")),
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
                                      _availabilityModel[index]?.isSelected ??
                                              false
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
                  InkWell(
                    onTap: () {
                      _dayScrollController.jumpTo(
                          _dayScrollController.position.maxScrollExtent);
                      return;
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(
                        Icons.navigate_next,
                        color: PlunesColors.BLACKCOLOR,
                      ),
                      padding: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 1,
                          top: AppConfig.horizontalBlockSize * 2,
                          bottom: AppConfig.horizontalBlockSize * 2),
                    ),
                  ),
                ],
              ),
            ),
            _getSlotView(),
            _getApplyView(),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 3),
              child: StreamBuilder<RequestState>(
                  stream: userBloc.baseStream,
                  builder: (context, snapshot) {
                    if (snapshot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    } else if (snapshot.data is RequestFailed) {
                      RequestFailed _reqFail = snapshot.data as RequestFailed;
                      userBloc.addIntoStream(null);
                      Future.delayed(Duration(milliseconds: 100)).then((value) {
                        _showSnackBar(_reqFail?.failureCause);
                      });
                    } else if (snapshot.data is RequestSuccess) {
                      userBloc.addIntoStream(null);
                      Future.delayed(Duration(milliseconds: 100)).then((value) {
                        _showSnackBar(PlunesStrings.slotUpdatedSuccessfully,
                            shouldPop: true);
                      });
                    }
                    return InkWell(
                      onTap: () {
                        _submitSlots();
                        return;
                      },
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
                    );
                  }),
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
                        color:
                            Color(CommonMethods.getColorHexFromStr("#F5F5F5"))),
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
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: AppConfig.verticalBlockSize * 1.5),
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 3.5),
                      child: Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(_availabilityModel[_currentDayIndex]
                                .slots[index]
                                .split("-")[0]),
                            Icon(
                              Icons.arrow_forward,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                            Text(_availabilityModel[_currentDayIndex]
                                .slots[index]
                                .split("-")[1]),
                          ],
                        ),
                      ),
                    )),
                    InkWell(
                        onTap: () {
                          _availabilityModel[_currentDayIndex]
                              .slots
                              .removeAt(index);
                          _setState();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            PlunesImages.binImage,
                            width: AppConfig.horizontalBlockSize * 8,
                            height: AppConfig.verticalBlockSize * 2.8,
                          ),
                        )),
                    InkWell(
                        onTap: () {
//                          _availabilityModel[_currentDayIndex]
//                              .slots
//                              .removeAt(index);
//                          _setState();
                          _fromDateHolderForSlotEdit = null;
                          _toDateHolderForSlotEdit = null;
                          _openTimePickerForSlotEditing(index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            PlunesImages.availability_edit_image,
                            width: AppConfig.horizontalBlockSize * 8,
                            height: AppConfig.verticalBlockSize * 2.8,
                          ),
                        ))
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
                _checkFirstAndLastSlot();
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: 28,
                  width: 48,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PlunesColors.WHITECOLOR,
                      border: Border.all(color: PlunesColors.GREENCOLOR)),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: PlunesColors.GREENCOLOR,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: Text(
              "Add more slots",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _setTimeInBoxes(int position) {
    switch (position) {
      case _fromIndex:
        if (_tempFromHolder == null) {
          return;
        }
        try {
          _doFromIndexOperation();
        } catch (e, s) {
          print("error $s");
        }
        break;
      case _toIndex:
        try {
          _setToIndexDate();
        } catch (e, s) {
          print("error $s");
        }
        break;
    }
  }

  void _checkFirstAndLastSlot() {
    if (_availabilityModel != null &&
        _availabilityModel.isNotEmpty &&
        _currentDayIndex != null &&
        _availabilityModel.length > _currentDayIndex) {
      _openTimePicker(_fromIndex);
    }
  }

  void _setToIndexDate() {
    if (_tempToHolder != null) {
      if (_availabilityModel != null &&
          _availabilityModel.isNotEmpty &&
          _currentDayIndex != null &&
          _availabilityModel.length > _currentDayIndex) {
        if (_availabilityModel[_currentDayIndex].slots != null &&
            _availabilityModel[_currentDayIndex].slots.isNotEmpty) {
          List<String> _lastTimeArray =
              _availabilityModel[_currentDayIndex].slots.last.split("-");
//          print("_lastTimeArray $_lastTimeArray");

          List<String> lastSplitTime = _lastTimeArray[1].split(":");
          int _lastPmTime = 0;
          if (_lastTimeArray[0].contains("PM") && lastSplitTime.first != "12") {
            _lastPmTime = 12;
            lastSplitTime.first =
                "${_lastPmTime + int.parse(lastSplitTime.first)}";
          }
          var _lastDate = DateTime(
              _tempFromHolder.year,
              _tempFromHolder.month,
              _tempFromHolder.day,
              int.tryParse(lastSplitTime.first),
              int.tryParse(lastSplitTime[1]
                  .substring(0, lastSplitTime[1].indexOf(" "))));
          print("_lastDate $_lastDate");
          if (_tempToHolder.isAfter(_tempFromHolder) &&
              _lastDate.isBefore(_tempToHolder)) {
            print(
                "valid hai _tempToHolder $_tempToHolder, _tempFromHolder $_tempFromHolder, _lastDate $_lastDate");
            String duration =
                DateUtil.getTimeWithAmAndPmFormat(_tempFromHolder) +
                    "-" +
                    DateUtil.getTimeWithAmAndPmFormat(_tempToHolder);
            print("duration $duration");
            _availabilityModel[_currentDayIndex].slots.add(duration);
            _setState();
          } else {
            print(
                "Invalid hai _tempToHolder $_tempToHolder, _tempFromHolder $_tempFromHolder, _lastDate $_lastDate");
            return;
          }
        } else {
          String duration = DateUtil.getTimeWithAmAndPmFormat(_tempFromHolder) +
              "-" +
              DateUtil.getTimeWithAmAndPmFormat(_tempToHolder);
          print("duration $duration");
          _availabilityModel[_currentDayIndex].slots = [duration];
          _setState();
        }
      }
    }
  }

  void _doFromIndexOperation() {
    if (_availabilityModel != null &&
        _availabilityModel.isNotEmpty &&
        _currentDayIndex != null &&
        _availabilityModel.length > _currentDayIndex) {
      if (_availabilityModel[_currentDayIndex].slots != null &&
          _availabilityModel[_currentDayIndex].slots.isNotEmpty) {
        List<String> _firstTimeArray =
            _availabilityModel[_currentDayIndex].slots.first.split("-");
        print("_firstTimeArray $_firstTimeArray");
        List<String> _lastTimeArray =
            _availabilityModel[_currentDayIndex].slots.last.split("-");
        print("_lastTimeArray $_lastTimeArray");
        List<String> splitTime = _firstTimeArray[0].split(":");
        int _pmTime = 0;
        if (_firstTimeArray[0].contains("PM") && splitTime.first != "12") {
          _pmTime = 12;
          splitTime.first = "${_pmTime + int.parse(splitTime.first)}";
        }
        var _firstDate = DateTime(
            _tempFromHolder.year,
            _tempFromHolder.month,
            _tempFromHolder.day + 1,
            int.tryParse(splitTime.first),
            int.tryParse(splitTime[1].substring(0, splitTime[1].indexOf(" "))));
//        print("_firstDate $_firstDate");
        List<String> lastSplitTime = _lastTimeArray[1].split(":");
//        print(
//            "${(lastSplitTime[1].contains("PM") && lastSplitTime.first != "12")} lastSplitTime $lastSplitTime");
        int _lastPmTime = 0;
        if (lastSplitTime[1].contains("PM") && lastSplitTime.first != "12") {
          _lastPmTime = 12;
          lastSplitTime.first =
              "${_lastPmTime + int.parse(lastSplitTime.first)}";
        }
        var _lastDate = DateTime(
            _tempFromHolder.year,
            _tempFromHolder.month,
            _tempFromHolder.day,
            int.tryParse(lastSplitTime.first),
            int.tryParse(
                lastSplitTime[1].substring(0, lastSplitTime[1].indexOf(" "))));
//        print("_lastDate $_lastDate");
        if (_firstDate.isAfter(_tempFromHolder) &&
            _lastDate.isBefore(_tempFromHolder)) {
          print(
              "valid hai $_firstDate, _tempFromHolder $_tempFromHolder, _lastDate $_lastDate");
        } else {
          print(
              "invalid hai _firstDate $_firstDate, _tempFromHolder $_tempFromHolder, _lastDate $_lastDate");
          return;
        }
      }
      print("calling _openTimePicker");
      _openTimePicker(_toIndex);
    }
  }

  Widget _getApplyView() {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 4),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _daySelectionScrollController,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            _availabilityModel[_currentDayIndex]
                                ?.daySelectionList[index]
                                .isSelected = true;
                            if (_availabilityModel.length > index) {
                              _availabilityModel[index].slots =
                                  _availabilityModel[_currentDayIndex].slots;
                              _availabilityModel[index].closed =
                                  _availabilityModel[_currentDayIndex].closed;
                            }
                            _setState();
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: AppConfig.verticalBlockSize * .8,
                                    bottom: AppConfig.horizontalBlockSize * 2),
                                child: Text(
                                  _availabilityModel[_currentDayIndex]
                                          ?.daySelectionList[index]
                                          ?.dayName
                                          ?.substring(0, 3)
                                          ?.toUpperCase() ??
                                      PlunesStrings.NA,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _availabilityModel[_currentDayIndex]
                                                ?.daySelectionList[index]
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
                                  color: _availabilityModel[_currentDayIndex]
                                              ?.daySelectionList[index]
                                              ?.isSelected ??
                                          false
                                      ? PlunesColors.GREENCOLOR
                                      : Color(CommonMethods.getColorHexFromStr(
                                          "#F5F5F5")),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: _availabilityModel[_currentDayIndex]
                              ?.daySelectionList
                              ?.length ??
                          0,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _daySelectionScrollController.jumpTo(
                          _daySelectionScrollController
                              .position.maxScrollExtent);
                      return;
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(
                        Icons.navigate_next,
                        color: PlunesColors.BLACKCOLOR,
                      ),
                      padding: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 1,
                          top: AppConfig.horizontalBlockSize * 2,
                          bottom: AppConfig.horizontalBlockSize * 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editTime(int index) {
    try {
      String slotToBeEdited =
          _availabilityModel[_currentDayIndex]?.slots[index];
      if (slotToBeEdited != null) {
        if (_availabilityModel[_currentDayIndex].slots.first ==
            slotToBeEdited) {
          ///if first slot
          _editFirstSlot(slotToBeEdited);
        } else if (_availabilityModel[_currentDayIndex].slots.last ==
            slotToBeEdited) {
          ///if last slot
          _editLastSlot(slotToBeEdited);
        } else {
          ///middle slot
          _editMiddleSlot(slotToBeEdited);
        }
      }
    } catch (e) {
      print("error $e");
    }
  }

  void _editFirstSlot(String slotToBeEdited) {
    try {
      if (_availabilityModel[_currentDayIndex].slots.length > 1) {
        String _secondSlot = _availabilityModel[_currentDayIndex].slots[1];
        List<String> _lastTimeArray = _secondSlot.split("-");
        print("_lastTimeArray $_lastTimeArray");
        List<String> lastSplitTime = _lastTimeArray[0].split(":");
        int _lastPmTime = 0;
        if (lastSplitTime[1].contains("PM") && lastSplitTime.first != "12") {
          _lastPmTime = 12;
          lastSplitTime.first =
              "${_lastPmTime + int.parse(lastSplitTime.first)}";
        }
        print("lastSplitTime $lastSplitTime");
        var _lastDate = DateTime(
            _fromDateHolderForSlotEdit.year,
            _fromDateHolderForSlotEdit.month,
            _fromDateHolderForSlotEdit.day,
            int.tryParse(lastSplitTime.first),
            int.tryParse(
                lastSplitTime[1].substring(0, lastSplitTime[1].indexOf(" "))));
//        print("_lastDate $_lastDate");
        if (_fromDateHolderForSlotEdit.isBefore(_toDateHolderForSlotEdit) &&
            _toDateHolderForSlotEdit.isBefore(_lastDate)) {
          print(
              "valid hai _fromDateHolderForSlotEdit $_fromDateHolderForSlotEdit, _toDateHolderForSlotEdit $_toDateHolderForSlotEdit, _lastDate $_lastDate");
          String duration =
              DateUtil.getTimeWithAmAndPmFormat(_fromDateHolderForSlotEdit) +
                  "-" +
                  DateUtil.getTimeWithAmAndPmFormat(_toDateHolderForSlotEdit);
          print("duration $duration");
          _availabilityModel[_currentDayIndex].slots[
              _availabilityModel[_currentDayIndex]
                  .slots
                  .indexOf(slotToBeEdited)] = duration;
          _setState();
        } else {
          print(
              "in valid hai _fromDateHolderForSlotEdit $_fromDateHolderForSlotEdit, _toDateHolderForSlotEdit $_toDateHolderForSlotEdit, _lastDate $_lastDate");
          return;
        }
      } else {
        if (_fromDateHolderForSlotEdit.isBefore(_toDateHolderForSlotEdit)) {
          print("valid slot");
          String duration =
              DateUtil.getTimeWithAmAndPmFormat(_fromDateHolderForSlotEdit) +
                  "-" +
                  DateUtil.getTimeWithAmAndPmFormat(_toDateHolderForSlotEdit);
          print("duration $duration");
          _availabilityModel[_currentDayIndex].slots = [duration];
          _setState();
        } else {
          print("in valid slot");
        }
      }
    } catch (e) {
      print("error $e");
    }
  }

  void _editLastSlot(String slotToBeEdited) {
    try {
      if (_availabilityModel[_currentDayIndex].slots.length > 1) {
        String _firstSlot = _availabilityModel[_currentDayIndex].slots[0];
        String previousSlot = _availabilityModel[_currentDayIndex].slots[
            _availabilityModel[_currentDayIndex].slots.indexOf(slotToBeEdited) -
                1];
        List<String> _lastTimeArray = previousSlot.split("-");
        print("_lastTimeArray $_lastTimeArray");
        List<String> lastSplitTime = _lastTimeArray[1].split(":");
        int _lastPmTime = 0;
        if (lastSplitTime[1].contains("PM") && lastSplitTime.first != "12") {
          _lastPmTime = 12;
          lastSplitTime.first =
              "${_lastPmTime + int.parse(lastSplitTime.first)}";
        }
        print("lastSplitTime $lastSplitTime");
        var _lastDate = DateTime(
            _fromDateHolderForSlotEdit.year,
            _fromDateHolderForSlotEdit.month,
            _fromDateHolderForSlotEdit.day,
            int.tryParse(lastSplitTime.first),
            int.tryParse(
                lastSplitTime[1].substring(0, lastSplitTime[1].indexOf(" "))));
        //////////////////////////////
        List<String> _firstTimeArray = _firstSlot.split("-");
        print("_lastTimeArray $_lastTimeArray");
        List<String> firstSplitTime = _firstTimeArray[0].split(":");
        int _firstPmTime = 0;
        if (firstSplitTime[1].contains("PM") && firstSplitTime.first != "12") {
          _firstPmTime = 12;
          firstSplitTime.first =
              "${_firstPmTime + int.parse(firstSplitTime.first)}";
        }
        print("firstSplitTime $firstSplitTime");
        var _firstDate = DateTime(
            _fromDateHolderForSlotEdit.year,
            _fromDateHolderForSlotEdit.month,
            _fromDateHolderForSlotEdit.day + 1,
            int.tryParse(firstSplitTime.first),
            int.tryParse(firstSplitTime[1]
                .substring(0, firstSplitTime[1].indexOf(" "))));
//        print("_lastDate $_lastDate");
        if (_fromDateHolderForSlotEdit.isBefore(_toDateHolderForSlotEdit) &&
            _fromDateHolderForSlotEdit.isAfter(_lastDate) &&
            _toDateHolderForSlotEdit.isBefore(_firstDate)) {
          print(
              "valid slot _fromDateHolderForSlotEdit: $_fromDateHolderForSlotEdit, _toDateHolderForSlotEdit: $_toDateHolderForSlotEdit, _lastDate: $_lastDate, _firstDate: $_firstDate");
          String duration =
              DateUtil.getTimeWithAmAndPmFormat(_fromDateHolderForSlotEdit) +
                  "-" +
                  DateUtil.getTimeWithAmAndPmFormat(_toDateHolderForSlotEdit);
          print("duration $duration");
          _availabilityModel[_currentDayIndex].slots[
              _availabilityModel[_currentDayIndex]
                  .slots
                  .indexOf(slotToBeEdited)] = duration;
          _setState();
        } else {
          print(
              "in valid slot _fromDateHolderForSlotEdit: $_fromDateHolderForSlotEdit, _toDateHolderForSlotEdit: $_toDateHolderForSlotEdit, _lastDate: $_lastDate, _firstDate: $_firstDate");
          return;
        }
      }
    } catch (e) {
      print("error $e");
    }
  }

  void _editMiddleSlot(String slotToBeEdited) {
    try {
      int _editableSlotIndex =
          _availabilityModel[_currentDayIndex].slots.indexOf(slotToBeEdited);
      print(
          "_availabilityModel[_currentDayIndex].slots.length ${_availabilityModel[_currentDayIndex].slots.length}");
      if (_editableSlotIndex != null && _editableSlotIndex != -1) {
        if (_availabilityModel[_currentDayIndex].slots.length > 2 &&
            (_availabilityModel[_currentDayIndex].slots.length >=
                (_editableSlotIndex + 1))) {
          String _earlierSlot = _availabilityModel[_currentDayIndex]
              .slots[_editableSlotIndex - 1];
          print("earlier slot $_earlierSlot");
          String _laterSlot = _availabilityModel[_currentDayIndex]
              .slots[_editableSlotIndex + 1];
          print("later slot $_laterSlot");

          List<String> _lastTimeArray = _laterSlot.split("-");
          print("_lastTimeArray $_lastTimeArray");
          List<String> lastSplitTime = _lastTimeArray[0].split(":");
          int _lastPmTime = 0;
          if (lastSplitTime[1].contains("PM") && lastSplitTime.first != "12") {
            _lastPmTime = 12;
            lastSplitTime.first =
                "${_lastPmTime + int.parse(lastSplitTime.first)}";
          }
          print("lastSplitTime $lastSplitTime");
          var _lastDate = DateTime(
              _fromDateHolderForSlotEdit.year,
              _fromDateHolderForSlotEdit.month,
              _fromDateHolderForSlotEdit.day,
              int.tryParse(lastSplitTime.first),
              int.tryParse(lastSplitTime[1]
                  .substring(0, lastSplitTime[1].indexOf(" "))));
          //////////////////////////////
          List<String> _firstTimeArray = _earlierSlot.split("-");
          print("_firstTimeArray $_firstTimeArray");
          List<String> firstSplitTime = _firstTimeArray[1].split(":");
          int _firstPmTime = 0;
          if (firstSplitTime[1].contains("PM") &&
              firstSplitTime.first != "12") {
            _firstPmTime = 12;
            firstSplitTime.first =
                "${_firstPmTime + int.parse(firstSplitTime.first)}";
          }
          print("firstSplitTime $firstSplitTime");
          var _firstDate = DateTime(
              _fromDateHolderForSlotEdit.year,
              _fromDateHolderForSlotEdit.month,
              _fromDateHolderForSlotEdit.day,
              int.tryParse(firstSplitTime.first),
              int.tryParse(firstSplitTime[1]
                  .substring(0, firstSplitTime[1].indexOf(" "))));

          if (_fromDateHolderForSlotEdit.isBefore(_toDateHolderForSlotEdit) &&
              _fromDateHolderForSlotEdit.isAfter(_firstDate) &&
              _toDateHolderForSlotEdit.isBefore(_lastDate)) {
            print(
                "valid slot _fromDateHolderForSlotEdit: $_fromDateHolderForSlotEdit, _toDateHolderForSlotEdit: $_toDateHolderForSlotEdit, _lastDate: $_lastDate, _firstDate: $_firstDate");
            String duration =
                DateUtil.getTimeWithAmAndPmFormat(_fromDateHolderForSlotEdit) +
                    "-" +
                    DateUtil.getTimeWithAmAndPmFormat(_toDateHolderForSlotEdit);
            print("duration $duration");
            _availabilityModel[_currentDayIndex].slots[
                _availabilityModel[_currentDayIndex]
                    .slots
                    .indexOf(slotToBeEdited)] = duration;
            _setState();
          } else {
            print(
                "in valid slot _fromDateHolderForSlotEdit: $_fromDateHolderForSlotEdit, _toDateHolderForSlotEdit: $_toDateHolderForSlotEdit, _lastDate: $_lastDate, _firstDate: $_firstDate");
            return;
          }
        }
      }
    } catch (e) {
      print("error $e");
    }
  }
}
