import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/models/cart_models/cart_main_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class EditPatientDetailScreen extends BaseActivity {
  final BookingIds bookingIds;
  CartMainBloc cartMainBloc;

  EditPatientDetailScreen(this.bookingIds, this.cartMainBloc);

  @override
  _EditPatientDetailScreenState createState() =>
      _EditPatientDetailScreenState();
}

class _EditPatientDetailScreenState extends BaseState<EditPatientDetailScreen> {
  String _gender, _selectedTimeSlot;
  DateTime _currentDate, _selectedDate;
  bool _hasScrolledOnce, _hasGotSize;
  List<String> _slotArray;
  ScrollController _scrollController;
  GlobalKey _selectedTimeSlotKey;
  double _widgetSize = 0;
  CartMainBloc _cartMainBloc;
  TextEditingController _patientNameController;
  TextEditingController _serviceNameController;
  TextEditingController _ageController;

  @override
  void initState() {
    _patientNameController = TextEditingController();
    _serviceNameController = TextEditingController();
    _ageController = TextEditingController();
    if (widget.bookingIds != null) {
      _patientNameController.text = widget.bookingIds.patientName ?? "";
      _serviceNameController.text = widget.bookingIds.serviceName ?? "";
      _ageController.text = widget.bookingIds.patientAge ?? "";
      _gender = widget.bookingIds.patientSex;
    }
    _cartMainBloc = widget.cartMainBloc;
    _currentDate = DateTime.now();
    _selectedDate = _currentDate;
    _slotArray = [];
    _hasGotSize = false;
    _hasScrolledOnce = false;
    _selectedTimeSlotKey = GlobalKey(debugLabel: "GlobalKey");
    _scrollController = ScrollController();
    _getSlotsInfo(DateUtil.getDayAsString(_currentDate));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: scaffoldKey,
      body: Dialog(
        insetPadding:
            EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: _showContent(),
      ),
    );
  }

  _showContent() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _getUpperWidgets(),
          _getSlotsArray(),
          Container(
            height: 0.5,
            width: double.infinity,
            color: PlunesColors.GREYCOLOR,
          ),
          Container(
            height: AppConfig.verticalBlockSize * 6,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
              child: StreamBuilder<RequestState>(
                  stream: _cartMainBloc.editInfoStream,
                  builder: (context, snapshot) {
                    if (snapshot != null &&
                        snapshot.data is RequestInProgress) {
                      return Container(
                        child: CustomWidgets().getProgressIndicator(),
                        margin: EdgeInsets.only(bottom: 3),
                      );
                    } else if (snapshot != null &&
                        snapshot.data is RequestSuccess) {
                      Future.delayed(Duration(milliseconds: 10)).then((value) {
                        Navigator.pop(context, true);
                      });
                      _cartMainBloc.addStateInEditDetailsStream(null);
                    } else if (snapshot != null &&
                        snapshot.data is RequestFailed) {
                      RequestFailed _requestFailed = snapshot.data;
                      Future.delayed(Duration(milliseconds: 10)).then((value) {
                        _showInSnackBar(_requestFailed.failureCause);
                      });
                      _cartMainBloc.addStateInEditDetailsStream(null);
                    }
                    return Row(
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              splashColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                              focusColor: Colors.transparent,
                              onPressed: () {
                                Navigator.pop(context);
                                return;
                              },
                              child: Container(
                                  height: AppConfig.verticalBlockSize * 8,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont,
                                          color: PlunesColors.SPARKLINGGREEN),
                                    ),
                                  ))),
                        ),
                        Container(
                          height: AppConfig.verticalBlockSize * 8,
                          color: PlunesColors.GREYCOLOR,
                          width: 0.5,
                        ),
                        Expanded(
                          child: FlatButton(
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              splashColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                              focusColor: Colors.transparent,
                              onPressed: () {
                                if (_selectedDate != null &&
                                    _selectedTimeSlot != null &&
                                    _selectedTimeSlot != PlunesStrings.noSlot) {
                                  if (_hasFilledDetails()) _saveInfo();
                                } else {
                                  _showInSnackBar(
                                      PlunesStrings.pleaseSelectValidSlot);
                                }
                                return;
                              },
                              child: Container(
                                  height: AppConfig.verticalBlockSize * 6,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      PlunesStrings.save.substring(0, 4),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont,
                                          color: PlunesColors.SPARKLINGGREEN),
                                    ),
                                  ))),
                        ),
                      ],
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget _getPatientDetailsFillUpView() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          width: double.infinity,
          child: Text(
            "Patient Details",
            style: TextStyle(
                fontSize: 16,
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.normal),
          ),
        ),
        Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: _patientNameController,
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontSize: 15,
                        fontWeight: FontWeight.normal),
                    minLines: 1,
                    decoration: InputDecoration(
                        hintText: PlunesStrings.enterName,
                        border: InputBorder.none,
                        labelText: PlunesStrings.enterName,
                        labelStyle: TextStyle(
                            color: PlunesColors.GREYCOLOR, fontSize: 13),
                        hintStyle: TextStyle(
                            color: PlunesColors.GREYCOLOR, fontSize: 15)),
                  )),
                ],
              ),
              getSeparatorLine()
            ],
          ),
        ),
        Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                          controller: _serviceNameController,
                          maxLines: 1,
                          readOnly: true,
                          enabled: false,
                          style: TextStyle(
                              color: PlunesColors.GREYCOLOR,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Enter procedure",
                              labelStyle: TextStyle(
                                  color: PlunesColors.GREYCOLOR,
                                  fontSize: 13)))),
                ],
              ),
              getSeparatorLine()
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        right: AppConfig.horizontalBlockSize * 6),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                              controller: _ageController,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              maxLength: 3,
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                  labelText: "Enter age",
                                  labelStyle: TextStyle(
                                      color: PlunesColors.GREYCOLOR,
                                      fontSize: 13))),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: getSeparatorLine(),
                    margin: EdgeInsets.only(
                        right: AppConfig.horizontalBlockSize * 6),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              items: Constants.genderList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal)),
                                );
                              }).toList(),
                              value: _gender,
                              isExpanded: true,
                              hint: Text(
                                "Enter gender",
                                style: TextStyle(
                                    color: PlunesColors.GREYCOLOR,
                                    fontSize: 13),
                              ),
                              onChanged: (String gender) {
                                _gender = gender;
                                _setState();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: getSeparatorLine(),
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 4,
                        top: AppConfig.verticalBlockSize * 0.6),
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget getSeparatorLine() {
    return Container(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
      width: double.infinity,
      height: 0.7,
      color: PlunesColors.GREYCOLOR,
    );
  }

  Widget _getDatePicker() {
    return Container(
      width: double.infinity,
      child: DatePicker(
        _currentDate,
        width: AppConfig.horizontalBlockSize * 15.5,
        height: AppConfig.verticalBlockSize * 12.5,
        daysCount: 100,
        initialSelectedDate: _currentDate,
        dateTextStyle: TextStyle(
            color: PlunesColors.BLACKCOLOR, fontSize: AppConfig.largeFont),
        dayTextStyle: TextStyle(color: PlunesColors.BLACKCOLOR),
        monthTextStyle: TextStyle(color: PlunesColors.BLACKCOLOR),
        selectionColor: PlunesColors.SPARKLINGGREEN,
        onDateChange: (DateTime selectedDateTime) {
          _hasScrolledOnce = false;
          _selectedDate = selectedDateTime;
          _getSlotsInfo(DateUtil.getDayAsString(_selectedDate));
        },
      ),
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  void _getSlotsInfo(String dateAsString) {
    _selectedTimeSlot = PlunesStrings.noSlot;
    widget.bookingIds.service?.timeSlots?.forEach((slot) {
      if (slot.day.toLowerCase().contains(dateAsString.toLowerCase())) {
        if (!slot.closed &&
            slot.slotArray != null &&
            slot.slotArray.isNotEmpty) {
          _slotArray = slot.slotArray;
          slot.slotArray.forEach((element) {
            if (_selectedTimeSlot == PlunesStrings.noSlot) {
              _checkSelectedSlot(element);
            }
          });
        }
      }
    });
    _setState();
  }

  Widget _getUpperWidgets() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 4,
          vertical: AppConfig.verticalBlockSize * 2.5),
      child: Column(
        children: <Widget>[
          _getPatientDetailsFillUpView(),
          _getDatePicker(),
        ],
      ),
    );
  }

  Widget _getSlotsArray() {
    return Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 2,
            vertical: AppConfig.verticalBlockSize * 2.5),
        height: AppConfig.verticalBlockSize * 10.5,
        child: (_selectedTimeSlot == null ||
                _selectedTimeSlot == PlunesStrings.noSlot)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 1),
                        child: Image.asset(
                          PlunesImages.noSlotAvailableImage,
                        )),
                  ),
                  Text(
                    "Closed",
                    style: TextStyle(
                        color:
                            Color(CommonMethods.getColorHexFromStr("#434343")),
                        fontSize: AppConfig.smallFont,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _scrollController
                          .jumpTo(_scrollController.position.minScrollExtent);
                      return;
                    },
                    child: Padding(
                      child: Icon(
                        Icons.navigate_before,
                        color: PlunesColors.BLACKCOLOR,
                      ),
                      padding: EdgeInsets.only(
                          right: AppConfig.horizontalBlockSize * 2,
                          top: AppConfig.horizontalBlockSize * 2,
                          bottom: AppConfig.horizontalBlockSize * 2),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8),
                      itemBuilder: (_, index) {
                        if (!_hasScrolledOnce) {
                          _hasScrolledOnce = true;
                          _doScroll();
                        }
                        return InkWell(
                          key: (index == 0 && !_hasGotSize)
                              ? _selectedTimeSlotKey
                              : null,
                          onTap: () {
                            _checkSelectedSlot(_slotArray[index],
                                shouldShowPopup: true);
                            _setState();
                            return;
                          },
                          child: _getTimeBoxWidget(_slotArray[index],
                              _slotArray[index] == _selectedTimeSlot),
                        );
                      },
                      itemCount: _slotArray?.length ?? 0,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                      return;
                    },
                    child: Padding(
                      child: Icon(
                        Icons.navigate_next,
                        color: PlunesColors.GREYCOLOR,
                      ),
                      padding: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 2,
                          top: AppConfig.horizontalBlockSize * 2,
                          bottom: AppConfig.horizontalBlockSize * 2),
                    ),
                  ),
                ],
              ));
  }

  void _doScroll() {
    if ((_selectedTimeSlot != null &&
        _selectedTimeSlot != PlunesStrings.noSlot)) {
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        if (_slotArray != null &&
            _slotArray.isNotEmpty &&
            _slotArray.contains(_selectedTimeSlot)) {
          if (!_hasGotSize) {
            _hasGotSize = true;
            var _context = _selectedTimeSlotKey.currentContext;
            _widgetSize = _context.size.height;
          }
          int index = _slotArray.indexOf(_selectedTimeSlot);
          if (index != null && index >= 0) {
            _scrollController.animateTo(_widgetSize * index.toDouble(),
                duration: Duration(milliseconds: 50), curve: Curves.easeInOut);
          }
        }
      });
    }
  }

  _checkSelectedSlot(String selectedTime, {bool shouldShowPopup = false}) {
    //        print("contains pm");
    try {
      var _currentDateTime = DateTime.now();
      List<String> splitTime = selectedTime.split(":");
      int _pmTime = 0;
      bool _shouldDecreaseDay = false;
      if (selectedTime.contains("PM") && splitTime.first != "12") {
//        print("contains pm");
        _pmTime = 12;
        splitTime.first = "${_pmTime + int.parse(splitTime.first)}";
      } else if (selectedTime.contains("AM") && splitTime.first == "12") {
//        print("contains pm");
        _pmTime = 12;
        splitTime.first = "${_pmTime + int.parse(splitTime.first)}";
        _shouldDecreaseDay = true;
      }
      List<String> lastTimeOfBooking =
          _slotArray[_slotArray.length - 1].split(":");
      int _pmTimeLastSlot = 0;
      if (_slotArray[_slotArray.length - 1].contains("PM") &&
          lastTimeOfBooking.first != "12") {
        _pmTimeLastSlot = 12;
        lastTimeOfBooking.first =
            "${_pmTimeLastSlot + int.parse(lastTimeOfBooking.first)}";
      }
      if (_selectedDate != null &&
          (_selectedDate.year == _currentDateTime.year &&
              _selectedDate.month == _currentDateTime.month &&
              _selectedDate.day == _currentDateTime.day)) {
        List<String> _currentTimeOfBooking =
            DateUtil.getTimeWithAmAndPmFormat(_currentDateTime).split(":");
        int _pmSlotForCurrentTime = 0;
        if (DateUtil.getTimeWithAmAndPmFormat(_currentDateTime)
                .contains("PM") &&
            _currentTimeOfBooking.first != "12") {
          _pmSlotForCurrentTime = 12;
          _currentTimeOfBooking.first =
              "${_pmSlotForCurrentTime + int.parse(_currentTimeOfBooking.first)}";
        }
        _currentDateTime = DateTime(
            _currentDateTime.year,
            _currentDateTime.month,
            _currentDateTime.day,
            int.tryParse(_currentTimeOfBooking.first),
            int.tryParse(_currentTimeOfBooking[1]
                .substring(0, _currentTimeOfBooking[1].indexOf(" "))));
//        print("$lastTimeOfBooking lastTimeOfBooking hello $splitTime");
        var _selectedDateTime = DateTime(
            _currentDateTime.year,
            _currentDateTime.month,
            _shouldDecreaseDay
                ? _currentDateTime.day - 1
                : _currentDateTime.day,
            int.tryParse(splitTime.first),
            int.tryParse(splitTime[1].substring(0, splitTime[1].indexOf(" "))));
        var _todayLatBookingDateTime = DateTime(
            _currentDateTime.year,
            _currentDateTime.month,
            _currentDateTime.day,
            int.tryParse(lastTimeOfBooking.first),
            int.tryParse(lastTimeOfBooking[1]
                .substring(0, lastTimeOfBooking[1].indexOf(" "))));
//        print(
//            "_selectedDateTime $_selectedDateTime  _currentDateTime $_currentDateTime _todayLatBookingDateTime $_todayLatBookingDateTime");
//        print(
//            "sdsdsdsds ${((_selectedDateTime.isAfter(_currentDateTime) || (_selectedDateTime.difference(_currentDateTime)).inMinutes == 0) && _selectedDateTime.isBefore(_todayLatBookingDateTime))}");
        if ((_selectedDateTime.isAfter(_currentDateTime) ||
                (_selectedDateTime.difference(_currentDateTime)).inMinutes ==
                    0) &&
            _selectedDateTime.isBefore(_todayLatBookingDateTime)) {
          _selectedTimeSlot = selectedTime;
          _selectedDate = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              (int.tryParse(splitTime.first)),
              int.tryParse(
                  splitTime[1].substring(0, splitTime[1].indexOf(" "))));
//          print("valid");
        } else if ((_selectedDateTime.isBefore(_todayLatBookingDateTime) ||
                (_selectedDateTime.difference(_todayLatBookingDateTime))
                        .inMinutes ==
                    0) &&
            (_selectedDateTime.isAfter(_currentDateTime))) {
          _selectedTimeSlot = selectedTime;
          _selectedDate = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              (int.tryParse(splitTime.first)),
              int.tryParse(
                  splitTime[1].substring(0, splitTime[1].indexOf(" "))));
//          print("valid");
        } else {
          if (shouldShowPopup) {
            _showPopupForInvalidSlotSelection();
          }
//          print("invalid slot");
        }
      } else {
//        print("else part");
        _selectedTimeSlot = selectedTime;
        _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            (int.tryParse(splitTime.first)),
            int.tryParse(splitTime[1].substring(0, splitTime[1].indexOf(" "))));
      }
    } catch (e, s) {
//      print("error hai $s");
    }
  }

  void _showPopupForInvalidSlotSelection() {
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConfig.horizontalBlockSize * 5)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: AppConfig.verticalBlockSize * 10,
                        margin: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 3,
                            horizontal: AppConfig.horizontalBlockSize * 5),
                        child: Image.asset(PlunesImages.invalidSlotImage)),
                    Container(
                      margin: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 3,
                          right: AppConfig.horizontalBlockSize * 3,
                          top: AppConfig.verticalBlockSize * .1,
                          bottom: AppConfig.verticalBlockSize * 2),
                      child: Text(
                        PlunesStrings.timeNotAvailable,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: AppConfig.smallFont),
                      ),
                    ),
                    CustomWidgets().getSingleCommonButton(context, 'Ok')
                  ],
                ),
              ),
            );
          });
    });
  }

  bool _isSlotTimeExpired(String time) {
    bool isSlotTimeExpired = true;
    try {
      var _currentDateTime = DateTime.now();
      if (_selectedDate != null &&
          (_selectedDate.year == _currentDateTime.year &&
              _selectedDate.month == _currentDateTime.month &&
              _selectedDate.day == _currentDateTime.day)) {
        List<String> splitTime = time.split(":");
        int _pmTime = 0;
        bool _shouldDecreaseDay = false;
        if (time.contains("PM") && splitTime.first != "12") {
          _pmTime = 12;
          splitTime.first = "${_pmTime + int.parse(splitTime.first)}";
        } else if (time.contains("AM") && splitTime.first == "12") {
          _pmTime = 12;
          splitTime.first = "${_pmTime + int.parse(splitTime.first)}";
          _shouldDecreaseDay = true;
        }
        List<String> lastTimeOfBooking =
            _slotArray[_slotArray.length - 1].split(":");
        int _pmTimeLastSlot = 0;
        if (_slotArray[_slotArray.length - 1].contains("PM") &&
            lastTimeOfBooking.first != "12") {
          _pmTimeLastSlot = 12;
          lastTimeOfBooking.first =
              "${_pmTimeLastSlot + int.parse(lastTimeOfBooking.first)}";
        }
        List<String> _currentTimeOfBooking =
            DateUtil.getTimeWithAmAndPmFormat(_currentDateTime).split(":");
        int _pmSlotForCurrentTime = 0;
        if (DateUtil.getTimeWithAmAndPmFormat(_currentDateTime)
                .contains("PM") &&
            _currentTimeOfBooking.first != "12") {
          _pmSlotForCurrentTime = 12;
          _currentTimeOfBooking.first =
              "${_pmSlotForCurrentTime + int.parse(_currentTimeOfBooking.first)}";
        }
        _currentDateTime = DateTime(
            _currentDateTime.year,
            _currentDateTime.month,
            _currentDateTime.day,
            int.tryParse(_currentTimeOfBooking.first),
            int.tryParse(_currentTimeOfBooking[1]
                .substring(0, _currentTimeOfBooking[1].indexOf(" "))));
        var _selectedDateTime = DateTime(
            _currentDateTime.year,
            _currentDateTime.month,
            _shouldDecreaseDay
                ? _currentDateTime.day - 1
                : _currentDateTime.day,
            int.tryParse(splitTime.first),
            int.tryParse(splitTime[1].substring(0, splitTime[1].indexOf(" "))));
        if (_selectedDateTime.isAfter(_currentDateTime) ||
            (_selectedDateTime.difference(_currentDateTime)).inMinutes == 0) {
          isSlotTimeExpired = false;
        }
      } else {
        isSlotTimeExpired = false;
      }
    } catch (e) {
//      print("error" + e);
    }
    return isSlotTimeExpired;
  }

  Widget _getTimeBoxWidget(String time, bool isSelected) {
    bool _isSlotTimeExpire = _isSlotTimeExpired(time);
    double opacity = 1.0;
    if (_isSlotTimeExpire) {
      opacity = 0.3;
    }
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
          color: PlunesColors.WHITECOLOR,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border.all(
              color: isSelected
                  ? PlunesColors.GREENCOLOR
                  : PlunesColors.BLACKCOLOR.withOpacity(opacity),
              // Color(CommonMethods.getColorHexFromStr("#D2D2D2"))
              //         .withOpacity(opacity),
              width: .8)),
      alignment: Alignment.center,
      child: Text(
        time ?? "",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: isSelected
                ? PlunesColors.GREENCOLOR
                : PlunesColors.BLACKCOLOR.withOpacity(opacity),
            // Color(CommonMethods.getColorHexFromStr("#9C9C9C"))
            //         .withOpacity(opacity),
            fontWeight: FontWeight.normal,
            fontSize: AppConfig.smallFont - 1),
      ),
    );
  }

  void _showInSnackBar(String message, {bool shouldPop = false}) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets()
              .getInformativePopup(globalKey: scaffoldKey, message: message);
        }).then((value) {
      if (shouldPop) {
        Navigator.pop(context);
      }
    });
  }

  bool _hasFilledDetails() {
    bool _hasFilledDetails = true;
    String _message;
    if (_patientNameController.text.trim().isEmpty ||
        _patientNameController.text.trim().length < 2) {
      _hasFilledDetails = false;
      _message = PlunesStrings.nameMustBeGreaterThanTwoChar;
    } else if (_ageController.text.trim().isEmpty ||
        _ageController.text.trim() == "0" ||
        int.tryParse(_ageController.text) < 0) {
      _hasFilledDetails = false;
      _message = PlunesStrings.enterValidAge;
    } else if (_gender == null || _gender.isEmpty) {
      _hasFilledDetails = false;
      _message = PlunesStrings.pleaseSelectYourGender;
    }
    if (_message != null) {
      _showInSnackBar(_message);
    }
    return _hasFilledDetails;
  }

  _saveInfo() {
    Map<String, dynamic> json = {
      "patientName": _patientNameController.text.trim(),
      "patientAge": _ageController.text.trim(),
      "patientSex": _gender,
      "patientMobileNumber": UserManager().getUserDetails().mobileNumber,
      "bookingId": widget.bookingIds.sId,
      "timeSlot": _selectedTimeSlot,
      "appointmentTime": _selectedDate.millisecondsSinceEpoch.toString()
    };
    _cartMainBloc.saveEditedPatientDetails(json);
  }
}
