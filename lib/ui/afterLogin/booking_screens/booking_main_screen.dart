import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/Utils/payment_web_view.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:plunes/resources/network/Urls.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_payment_option_popup.dart';

// ignore: must_be_immutable
class BookingMainScreen extends BaseActivity {
  final List<TimeSlots> timeSlots;
  final String price, searchedSolutionServiceId, profId;
  final num bookInPrice;
  final DocHosSolution docHosSolution;
  final String screenName = "BookingMainScreen";
  final int serviceIndex;
  final Services service;

  BookingMainScreen(
      {this.price,
      this.profId,
      this.searchedSolutionServiceId,
      this.docHosSolution,
      this.timeSlots,
      this.bookInPrice,
      this.serviceIndex,
      this.service});

  @override
  _BookingMainScreenState createState() => _BookingMainScreenState();
}

class _BookingMainScreenState extends BaseState<BookingMainScreen> {
  DateTime _currentDate, _selectedDate, _tempSelectedDateTime;
  int _selectedPaymentType, _paymentTypeCash = 0, _paymentTypeCoupon = 1;
  String _appointmentTime,
      _firstSlotTime,
      _secondSlotTime,
      _selectedTimeSlot,
      _notSelectedEntry,
      _userFailureCause;
  bool _isFetchingDocHosInfo;
  LoginPost _docProfileInfo, _userProfileInfo;
  BookingBloc _bookingBloc;

  @override
  void initState() {
    _appointmentTime = "00:00";
    _notSelectedEntry = _appointmentTime;
    _selectedPaymentType = _paymentTypeCash;
    _getDocHosInfo();
    _getUserInfo();
    _bookingBloc = BookingBloc();
    _currentDate = DateTime.now();
    _getSlotsInfo(DateUtil.getDayAsString(_currentDate));
    super.initState();
  }

  void _getSlotsInfo(String dateAsString) {
    _firstSlotTime = PlunesStrings.NA;
    _secondSlotTime = _firstSlotTime;
    widget.timeSlots.forEach((slot) {
      if (slot.day.toLowerCase().contains(dateAsString.toLowerCase())) {
        if (!slot.closed) {
          if (slot.slots.length >= 1)
            _firstSlotTime = slot?.slots[0] ?? _firstSlotTime;
          if (slot.slots.length >= 2)
            _secondSlotTime = slot?.slots[1] ?? _secondSlotTime;
        }
      }
    });
    _setState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar:
              widget.getAppBar(context, PlunesStrings.confirmYourBooking, true),
          body: Builder(builder: (context) {
            return Container(
                padding: CustomWidgets().getDefaultPaddingForScreens(),
                child: _isFetchingDocHosInfo
                    ? CustomWidgets().getProgressIndicator()
                    : (_docProfileInfo == null || _docProfileInfo.user == null)
                        ? CustomWidgets().errorWidget(_userFailureCause)
                        : _getBody());
          }),
        ));
  }

  Widget _getBody() {
    return Container(
      child: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              PlunesStrings.whyPlunes,
              style: TextStyle(
                fontSize: AppConfig.mediumFont,
                color: PlunesColors.BLACKCOLOR,
              ),
            ),
          ),
          getWhyPlunesView(),
          _getDoctorDetailsView(),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.5),
            child: Text(
              PlunesStrings.availableSlots,
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontSize: AppConfig.mediumFont),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * .5,
                bottom: AppConfig.verticalBlockSize * .5),
            child: CustomWidgets().getSeparatorLine(),
          ),
          _getDatePicker(),
          widget.getSpacer(
              AppConfig.verticalBlockSize * 3, AppConfig.verticalBlockSize * 1),
          _getSlots(),
          widget.getSpacer(
              AppConfig.verticalBlockSize * 3, AppConfig.verticalBlockSize * 1),
          _getSelectedSlot(),
          _getApplyCouponAndCashWidget(),
          _getPayNowWidget()
        ],
      ),
    );
  }

  Widget getWhyPlunesView() {
    return Container(
        padding:
            EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                child: getTagsView(
                    'assets/images/catIcon1.png', '100% Payments Refundable'),
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
                  child: getTagsView(
                      'assets/images/doctor.png', 'First Consultation Free'),
                ),
              )
            ]),
            Row(
              children: <Widget>[
                Expanded(
                  child: getTagsView('assets/images/calandergrey.png',
                      'Prefered timing as per your availability'),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 2),
                      child: getTagsView('assets/images/walletgrey.png',
                          'Make Partial Payments')),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  right: (MediaQuery.of(context).size.width / 2) - 10),
              child: getTagsView('assets/images/tellIcongrey2.png',
                  'Free telephonic consultations'),
            )
          ],
        ));
  }

  Widget getTagsView(String image, String text) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width / 2,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 10),
                child: Image.asset(
                  image,
                  height: 21,
                  width: 21,
                )),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 12, color: PlunesColors.BLACKCOLOR),
              ),
            )
          ]),
      decoration: BoxDecoration(
          color: PlunesColors.LIGHTGREYCOLOR,
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _getDoctorDetailsView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          child: Container(
            height: AppConfig.horizontalBlockSize * 11,
            width: AppConfig.horizontalBlockSize * 11,
            child: ClipOval(
                child: CustomWidgets().getImageFromUrl(
                    _docProfileInfo.user?.imageUrl,
                    boxFit: BoxFit.fill)),
          ),
          radius: AppConfig.horizontalBlockSize * 5.5,
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Text(
                      _docProfileInfo.user?.name ?? PlunesStrings.NA,
                      style: TextStyle(
                          fontSize: AppConfig.mediumFont,
                          fontWeight: FontWeight.bold,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _getDirections(),
                      onDoubleTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          PlunesStrings.getDirection,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: AppConfig.mediumFont,
                              color: PlunesColors.GREENCOLOR),
                        ),
                      ),
                    ),
                    flex: 3,
                  ),
                ],
              ),
              Text(
                _docProfileInfo.user?.speciality ?? PlunesStrings.NA,
                style: TextStyle(
                    fontSize: AppConfig.mediumFont,
                    color: PlunesColors.GREYCOLOR),
              ),
              Padding(
                padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                child: RichText(
                  text: new TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: new TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      new TextSpan(
                          text: '${PlunesStrings.addressInSmall} -',
                          style: TextStyle(
                              color: PlunesColors.GREYCOLOR,
                              fontSize: AppConfig.mediumFont)),
                      new TextSpan(
                          text:
                              _docProfileInfo.user?.address ?? PlunesStrings.NA,
                          style: new TextStyle(
                              fontSize: AppConfig.smallFont,
                              fontWeight: FontWeight.w300,
                              color: PlunesColors.BLACKCOLOR)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _getDirections() {
    (_docProfileInfo.user.latitude == null ||
            _docProfileInfo.user.latitude.isEmpty ||
            _docProfileInfo.user.latitude == null ||
            _docProfileInfo.user.latitude.isEmpty)
        ? widget.showInSnackBar(PlunesStrings.locationNotAvailable,
            PlunesColors.BLACKCOLOR, scaffoldKey)
        : LauncherUtil.openMap(double.tryParse(_docProfileInfo.user.latitude),
            double.tryParse(_docProfileInfo.user.longitude));
  }

  Widget _getDatePicker() {
    return Container(
      width: double.infinity,
      height: AppConfig.verticalBlockSize * 16,
      child: DatePicker(
        _currentDate,
        height: AppConfig.verticalBlockSize * 15,
        daysCount: 100,
        initialSelectedDate: _currentDate,
        dateTextStyle: TextStyle(
            color: PlunesColors.BLACKCOLOR, fontSize: AppConfig.largeFont),
        dayTextStyle: TextStyle(color: PlunesColors.BLACKCOLOR),
        monthTextStyle: TextStyle(color: PlunesColors.BLACKCOLOR),
        selectionColor: PlunesColors.GREENCOLOR,
        onDateChange: (DateTime selectedDateTime) {
          _selectedDate = selectedDateTime;
          print("selected date is ${selectedDateTime.toString()}");
          _openTimePicker();
        },
      ),
    );
  }

  Widget _getSlotInfo(String slotName, String fromAndToText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            slotName,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR, fontSize: AppConfig.mediumFont),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
          child: Text(
            fromAndToText,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR, fontSize: AppConfig.mediumFont),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              top: AppConfig.verticalBlockSize * .2,
              right: AppConfig.horizontalBlockSize * 3),
          width: double.infinity,
          height: 0.5,
          color: PlunesColors.GREYCOLOR,
        )
      ],
    );
  }

  Widget _getSlots() {
    return Row(
      children: <Widget>[
        Expanded(child: _getSlotInfo(PlunesStrings.slot1, _firstSlotTime)),
        Expanded(child: _getSlotInfo(PlunesStrings.slot2, _secondSlotTime))
      ],
    );
  }

  Widget _getSelectedSlot() {
    return Row(
      children: <Widget>[
        Expanded(
            child:
                _getSlotInfo(PlunesStrings.appointmentTime, _appointmentTime)),
        Expanded(child: Container())
      ],
    );
  }

  _getApplyCouponAndCashWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              top: AppConfig.verticalBlockSize * 3,
              bottom: AppConfig.verticalBlockSize * 3),
          width: double.infinity,
          height: 0.5,
          color: PlunesColors.GREYCOLOR,
        ),
        Text(PlunesStrings.availableCash),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
                value: _paymentTypeCash,
                groupValue: _selectedPaymentType,
                onChanged: (value) => _paymentTypeOnChange(value)),
            Text("Apply Cash     ")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
                value: _paymentTypeCoupon,
                groupValue: _selectedPaymentType,
                onChanged: (value) => _paymentTypeOnChange(value)),
            Text("Apply Coupon")
          ],
        ),
        Container(
          margin: EdgeInsets.only(
              top: AppConfig.verticalBlockSize * 3,
              bottom: AppConfig.verticalBlockSize * 3),
          width: double.infinity,
          height: 0.5,
          color: PlunesColors.GREYCOLOR,
        ),
      ],
    );
  }

  _getPayNowWidget() {
    return Column(
      children: <Widget>[
        Center(
          child: Text(
            "Make a payment of  300/- to confirm the booking",
            style: TextStyle(fontSize: 14),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 24,
              bottom: AppConfig.verticalBlockSize * 1.5,
              top: AppConfig.verticalBlockSize * 2.3,
              right: AppConfig.horizontalBlockSize * 24),
          child: InkWell(
            onTap: () {
              (_selectedDate == _tempSelectedDateTime &&
                      _appointmentTime != _notSelectedEntry &&
                      _appointmentTime != null)
                  ? _doPaymentRelatedQueries()
                  : _showErrorMessage(PlunesStrings.pleaseSelectValidSlot);
              return;
            },
            onDoubleTap: () {},
            child: CustomWidgets().getRoundedButton(
                PlunesStrings.payNow,
                AppConfig.horizontalBlockSize * 8,
                (_selectedDate == _tempSelectedDateTime &&
                        _appointmentTime != _notSelectedEntry &&
                        _appointmentTime != null)
                    ? PlunesColors.GREENCOLOR
                    : PlunesColors.WHITECOLOR,
                AppConfig.horizontalBlockSize * 3,
                AppConfig.verticalBlockSize * 1,
                PlunesColors.BLACKCOLOR,
                hasBorder: true),
          ),
        ),
        InkWell(
          onTap: () => LauncherUtil.launchUrl(urls.terms),
          onDoubleTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              PlunesStrings.tcApply,
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  void _paymentTypeOnChange(int value) {
    _selectedPaymentType = value;
    _setState();
  }

  _openTimePicker() {
    return showDialog(
        builder: (context) {
          return Container(
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 15,
                horizontal: AppConfig.horizontalBlockSize * 5),
            child: Material(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      PlunesStrings.setYourTime,
                      style: TextStyle(fontSize: AppConfig.mediumFont),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TimePickerSpinner(
                      is24HourMode: false,
                      time: _selectedDate,
                      normalTextStyle: TextStyle(
                          fontSize: 24, color: PlunesColors.BLACKCOLOR),
                      highlightedTextStyle: TextStyle(
                          fontSize: 24, color: PlunesColors.GREENCOLOR),
                      spacing: AppConfig.horizontalBlockSize * 8,
                      isShowSeconds: false,
                      itemHeight: AppConfig.verticalBlockSize * 10,
                      isForce2Digits: true,
                      onTimeChange: (time) {
                        _tempSelectedDateTime = time;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 30,
                        bottom: AppConfig.verticalBlockSize * 2,
                        top: AppConfig.verticalBlockSize * 2.3,
                        right: AppConfig.horizontalBlockSize * 30),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _timeChooseCallBack();
                        return;
                      },
                      child: CustomWidgets().getRoundedButton(
                          PlunesStrings.choose,
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 3,
                          AppConfig.verticalBlockSize * 1,
                          PlunesColors.WHITECOLOR,
                          hasBorder: false),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        barrierDismissible: true,
        context: context);
  }

  _timeChooseCallBack() {
//    print(
//        "${_tempSelectedDateTime.hour} selected Date Time is $_tempSelectedDateTime");
    _getSlotsInfo(DateUtil.getDayAsString(_tempSelectedDateTime));
    _checkAndValidateSelectedTime();
    _setState();
  }

  void _checkAndValidateSelectedTime() {
    if (widget.timeSlots != null && widget.timeSlots.isNotEmpty) {
      String selectedDay = DateUtil.getDayAsString(_tempSelectedDateTime);
      if (selectedDay == PlunesStrings.NA) {
        AppLog.printError(
            "${widget.screenName} Day is not parsable day is $selectedDay");
        return;
      }
      bool hasFoundEntry = false;
      widget.timeSlots.forEach((timeSlot) {
        if (timeSlot.day.toLowerCase().contains(selectedDay.toLowerCase()) &&
            !timeSlot.closed) {
          _setTime(timeSlot);
          hasFoundEntry = true;
        }
      });
      if (!hasFoundEntry) {
        _appointmentTime = _notSelectedEntry;
      }
    }
  }

  void _setTime(TimeSlots timeSlot) {
    if (timeSlot.slots.length == 1) {
      widget.showInSnackBar("Oops, Invalid time slot found.",
          PlunesColors.BLACKCOLOR, scaffoldKey);
      return;
    }
//    print("timeSlot ${timeSlot.slots.length}");
    List<String> _firstSlotFromTimeHourMinute =
        timeSlot.slots[0].split("-")[0].split(" ")[0].split(":");
    List<String> _firstSlotToTimeHourMinute =
        timeSlot.slots[0].split("-")[1].split(" ")[0].split(":");
    List<String> _secondSlotFromTimeHourMinute =
        timeSlot.slots[1].split("-")[0].split(" ")[0].split(":");
    List<String> _secondSlotToTimeHourMinute =
        timeSlot.slots[1].split("-")[1].split(" ")[0].split(":");
    int _fft = int.tryParse(_firstSlotFromTimeHourMinute[0]);
    if (timeSlot.slots[0].split("-")[0].contains("PM")) {
      _fft = _fft + 12;
    }
    TimeOfDay _firstFromTime = TimeOfDay(
        hour: _fft,
        minute: int.tryParse(_firstSlotFromTimeHourMinute[1].trim()));
    int _ftt = int.tryParse(_firstSlotToTimeHourMinute[0]);
    if (timeSlot.slots[1].split("-")[0].contains("PM")) {
      _ftt = _ftt + 12;
    }
    TimeOfDay _firstToTime = TimeOfDay(
        hour: _ftt, minute: int.tryParse(_firstSlotToTimeHourMinute[1].trim()));
    int _sft = int.tryParse(_secondSlotFromTimeHourMinute[0]);
    if (timeSlot.slots[1].split("-")[0].contains("PM")) {
      _sft = _sft + 12;
    }
    TimeOfDay _secondFromTime = TimeOfDay(
        hour: _sft,
        minute: int.tryParse(_secondSlotFromTimeHourMinute[1].trim()));
    int _stt = int.tryParse(_secondSlotToTimeHourMinute[0]);
    if (timeSlot.slots[1].split("-")[1].contains("PM")) {
      _stt = _stt + 12;
    }
    TimeOfDay _secondToTime = TimeOfDay(
        hour: _stt,
        minute: int.tryParse(_secondSlotToTimeHourMinute[1].trim()));

    ///slots calling
    bool isValidEntryFilled = false;
    if (timeSlot.slots[0] != null && timeSlot.slots[0].isNotEmpty)
      isValidEntryFilled = _validateTimeSlotWise(_firstFromTime, _firstToTime);
    if (isValidEntryFilled) {
      _selectedTimeSlot = timeSlot.slots[0];
    }
    if (!isValidEntryFilled &&
        timeSlot.slots[1] != null &&
        timeSlot.slots[1].isNotEmpty) {
      isValidEntryFilled =
          _validateTimeSlotWise(_secondFromTime, _secondToTime);
      if (isValidEntryFilled) {
        _selectedTimeSlot = timeSlot.slots[1];
      }
    }
    if (!isValidEntryFilled) {
      _appointmentTime = _notSelectedEntry;
    } else {
      _selectedDate = _tempSelectedDateTime;
    }
  }

  bool _validateTimeSlotWise(TimeOfDay fromDuration, TimeOfDay toDuration) {
    bool isValidEntryFilled = false;
    var _dateNow = DateTime.now();
    String appointmentTime =
        DateUtil.getTimeWithAmAndPmFormat(_tempSelectedDateTime);
    List<String> _hourNMinute = appointmentTime.split(":");
    int _selectedHour = int.tryParse(_hourNMinute[0]);
    if (_selectedHour == 12 && appointmentTime.contains("AM")) {
      return isValidEntryFilled;
    }
    if (appointmentTime.contains("PM") && _selectedHour != 12) {
      _selectedHour = _selectedHour + 12;
    }
    TimeOfDay _selectedTime = TimeOfDay(
        hour: _selectedHour,
        minute: int.tryParse(_hourNMinute[1].trim().split(" ")[0]));
    if (_selectedTime.hour >= fromDuration.hour &&
        _selectedTime.hour <= toDuration.hour &&
        _tempSelectedDateTime.day == _dateNow.day &&
        _selectedTime.hour >= _dateNow.hour) {
      //same day same hour case handled
      if (_selectedTime.hour == _dateNow.hour &&
          _selectedTime.minute >= _dateNow.minute) {
        //make it true
        _appointmentTime = appointmentTime;
        isValidEntryFilled = true;
      } else if (_selectedTime.hour > _dateNow.hour) {
        //success
        _appointmentTime = appointmentTime;
        isValidEntryFilled = true;
      } else {
        print("failed case 1");
      }
    } else if (_tempSelectedDateTime.day != _dateNow.day &&
        _selectedTime.hour >= fromDuration.hour &&
        _selectedTime.hour <= toDuration.hour) {
      _appointmentTime = appointmentTime;
      isValidEntryFilled = true;
      //success
    } else {
      print(
          "${_selectedTime.hour}failed ${fromDuration.hour}case2${toDuration.hour}");
    }
    return isValidEntryFilled;
  }

  void _getDocHosInfo() async {
    _isFetchingDocHosInfo = true;
    RequestState requestState = await UserBloc().getUserProfile(widget.profId);
    if (requestState is RequestSuccess) {
      _docProfileInfo = requestState.response;
    } else if (requestState is RequestFailed) {
      _userFailureCause = requestState.failureCause;
    }
    _isFetchingDocHosInfo = false;
    _setState();
  }

  void _getUserInfo() async {
    RequestState requestState =
        await UserBloc().getUserProfile(UserManager().getUserDetails().uid);
    if (requestState is RequestSuccess) {
      _userProfileInfo = requestState.response;
    } else if (requestState is RequestFailed) {
      _userFailureCause = requestState.failureCause;
    }
    _setState();
  }

  ///payment methods
  _initPayment(String payPercentage) async {
    print(DateUtil.getTimeWithAmAndPmFormat(_selectedDate));
    InitPayment _initPayment = InitPayment(
      appointmentTime: _selectedDate.toUtc().millisecondsSinceEpoch.toString(),
      percentage: payPercentage,
      price_pos: widget.serviceIndex,
      //negotiate prev id
      docHosServiceId: widget.docHosSolution.serviceId,
      //Services[0].id
      service_id: widget.searchedSolutionServiceId,
      //DocHosSolution's _id
      sol_id: widget.docHosSolution.sId,
      time_slot: _selectedTimeSlot,
      professional_id: widget.profId,
      creditsUsed: 0,
      user_id: UserManager().getUserDetails().uid,
      couponName: "",
    );
    print("initiate payment ${_initPayment.initiatePaymentToJson()}");
    RequestState _requestState = await _bookingBloc.initPayment(_initPayment);
    if (_requestState is RequestSuccess) {
      print("_requestState success");
      InitPaymentResponse _initPaymentResponse = _requestState.response;
      print("response is ${_initPaymentResponse.toString()}");

      if (_initPaymentResponse.success) {
        if (_initPaymentResponse.status.contains("Confirmed")) {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  PaymentSuccess(bookingId: _initPaymentResponse.referenceId));
        } else {
          Navigator.of(context)
              .push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __) =>
                      PaymentWebView(id: _initPaymentResponse.id)))
              .then((val) {
            if (val.toString().contains("success")) {
              showDialog(
                  context: context,
                  builder: (
                    BuildContext context,
                  ) =>
                      PaymentSuccess(
                          bookingId: _initPaymentResponse.referenceId));
            } else if (val.toString().contains("fail")) {
              widget.showInSnackBar(
                  "Payment Failed", PlunesColors.BLACKCOLOR, scaffoldKey);
            } else if (val.toString().contains("cancel")) {
              widget.showInSnackBar(
                  "Payment Cancelled", PlunesColors.BLACKCOLOR, scaffoldKey);
            }
          });
        }
      } else {
        widget.showInSnackBar(
            _initPaymentResponse.message, Colors.red, scaffoldKey);
      }
    } else if (_requestState is RequestFailed) {
      print("requestFailed ${_requestState.failureCause}");
    }
  }

  _doPaymentRelatedQueries() async {
    print("price${widget.price}");
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (
          BuildContext context,
        ) =>
            PopupChoose(
              bookInPrice: widget.bookInPrice,
              totalPrice: widget.price,
              services: widget.service,
            )).then((returnedValue) {
      if (returnedValue != null) {
        print("selected payment percenatge $returnedValue");
        _initPayment(returnedValue.toString());
      }
    });
  }

  ///payment methods end
  _showErrorMessage(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }
}

class PaymentSuccess extends StatefulWidget {
  final String bookingId;

  PaymentSuccess({Key key, this.bookingId}) : super(key: key);

  @override
  _PaymentSuccessState createState() => _PaymentSuccessState(bookingId);
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  final String bookingId;

  _PaymentSuccessState(this.bookingId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
        title: new Text("Payment Success"),
        content: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Image.asset(
                "assets/images/bid/check.png",
                height: 50,
                width: 50,
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text("Your Booking ID is $bookingId"),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            textStyle: TextStyle(color: Color(0xff01d35a)),
            isDefaultAction: true,
            child: new Text("OK"),
            onPressed: () {
              Navigator.pop(context);
//              Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) => Appointments(
//                      screen: 1,
//                    ),
//                  ));
            },
          ),
        ]);
  }
}
