import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/Utils/payment_web_view.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:plunes/resources/network/Urls.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointment_main_screen.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_payment_option_popup.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as latest;

// ignore: must_be_immutable
class BookingMainScreen extends BaseActivity {
  final List<TimeSlots> timeSlots;
  final String price, searchedSolutionServiceId, profId, docId;
  final num bookInPrice;
  final DocHosSolution docHosSolution;
  final String screenName = "BookingMainScreen";
  final int serviceIndex;
  final Services service;
  final AppointmentModel appointmentModel;

  BookingMainScreen(
      {this.price,
      this.profId,
      this.searchedSolutionServiceId,
      this.docHosSolution,
      this.timeSlots,
      this.bookInPrice,
      this.serviceIndex,
      this.appointmentModel,
      this.service,
      this.docId});

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
  bool _isFetchingDocHosInfo, _shouldUseCredit;
  LoginPost _docProfileInfo, _userProfileInfo;
  BookingBloc _bookingBloc;

  @override
  void initState() {
    _shouldUseCredit = false;
    _appointmentTime = "00:00";
    _notSelectedEntry = _appointmentTime;
    _selectedPaymentType = _paymentTypeCoupon;
    _bookingBloc = BookingBloc();
    _currentDate = DateTime.now();
    _selectedDate = _currentDate;
    _getDetails();
    super.initState();
  }

  _getDetails() {
    _getDocHosInfo();
    _getUserInfo();
    _getSlotsInfo(DateUtil.getDayAsString(_currentDate));
  }

  @override
  void dispose() {
    _bookingBloc?.dispose();
    super.dispose();
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
          backgroundColor: PlunesColors.WHITECOLOR,
          key: scaffoldKey,
          appBar:
              widget.getAppBar(context, PlunesStrings.confirmYourBooking, true),
          body: Builder(builder: (context) {
            return Container(
                padding: CustomWidgets().getDefaultPaddingForScreens(),
                child: _isFetchingDocHosInfo
                    ? CustomWidgets().getProgressIndicator()
                    : (_docProfileInfo == null || _docProfileInfo.user == null)
                        ? CustomWidgets().errorWidget(_userFailureCause,
                            onTap: () => _getDetails(), isSizeLess: true)
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
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 1.5),
            child: _getDoctorDetailsView(),
          ),
          CustomWidgets().getSeparatorLine(),
//          Container(
//            margin: EdgeInsets.only(
//                top: AppConfig.verticalBlockSize * .1,
//                bottom: AppConfig.verticalBlockSize * .1),
//            child:,
//          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 1.5),
            child: Text(
              PlunesStrings.availableSlots,
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontSize: AppConfig.mediumFont),
            ),
          ),
          _getDatePicker(),
          widget.getSpacer(AppConfig.verticalBlockSize * 1.5,
              AppConfig.verticalBlockSize * .1),
          _getSlots(),
          widget.getSpacer(AppConfig.verticalBlockSize * 2,
              AppConfig.verticalBlockSize * .1),
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
            Row(
              children: <Widget>[
                Expanded(
                  child: getTagsView('assets/images/tellIcongrey2.png',
                      'Free telephonic consultations'),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ],
        ));
  }

  Widget getTagsView(String image, String text) {
    return Container(
      height: AppConfig.verticalBlockSize * 6,
      width: MediaQuery.of(context).size.width / 2,
      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
      padding: EdgeInsets.all(5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: AppConfig.verticalBlockSize * 1),
                child: Image.asset(
                  image,
                  height: AppConfig.verticalBlockSize * 3.8,
                  width: AppConfig.verticalBlockSize * 3.8,
                  color: PlunesColors.GREYCOLOR,
                )),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: AppConfig.smallFont,
                    color: PlunesColors.BLACKCOLOR),
              ),
            )
          ]),
      decoration: BoxDecoration(
          color: PlunesColors.LIGHTGREYCOLOR.withOpacity(.30),
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _getDoctorDetailsView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () => _goToProfilePage(),
          onDoubleTap: () {},
          child: (_docProfileInfo.user != null &&
                  _docProfileInfo.user.imageUrl != null &&
                  _docProfileInfo.user.imageUrl.isNotEmpty &&
                  _docProfileInfo.user.imageUrl.contains("http"))
              ? CircleAvatar(
                  child: Container(
                    height: 45,
                    width: 45,
                    child: ClipOval(
                        child: CustomWidgets().getImageFromUrl(
                            _docProfileInfo.user?.imageUrl,
                            boxFit: BoxFit.fill)),
                  ),
                  radius: 23.5,
                )
              : CustomWidgets().getBackImageView(
                  _docProfileInfo.user?.name ?? PlunesStrings.NA,
                  width: 45,
                  height: 45),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: () => _goToProfilePage(),
                      onDoubleTap: () {},
                      child: Text(
                        CommonMethods.getStringInCamelCase(
                                _docProfileInfo?.user?.name) ??
                            PlunesStrings.NA,
                        style: TextStyle(
                            fontSize: AppConfig.mediumFont,
                            fontWeight: FontWeight.w600,
                            color: PlunesColors.BLACKCOLOR),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _getDirections(),
                      onDoubleTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          PlunesStrings.getDirection,
                          style: TextStyle(
                              fontSize: AppConfig.smallFont,
                              color: PlunesColors.GREENCOLOR),
                        ),
                      ),
                    ),
                    flex: 3,
                  ),
                ],
              ),
              Text(
                CommonMethods.getStringInCamelCase(
                        _docProfileInfo.user?.speciality) ??
                    PlunesStrings.NA,
                style: TextStyle(
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.normal,
                    color: PlunesColors.BLACKCOLOR),
              ),
              Padding(
                padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                child: RichText(
                  text: new TextSpan(
                    style: new TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      new TextSpan(
                          text: '${PlunesStrings.addressInSmall} - ',
                          style: TextStyle(
                              color: PlunesColors.GREYCOLOR,
                              fontSize: AppConfig.mediumFont)),
                      new TextSpan(
                          text:
                              _docProfileInfo.user?.address ?? PlunesStrings.NA,
                          style: new TextStyle(
                              fontSize: AppConfig.smallFont,
                              fontWeight: FontWeight.normal,
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
          _selectedDate = selectedDateTime;
          _appointmentTime = _notSelectedEntry;
          _getSlotsInfo(DateUtil.getDayAsString(_selectedDate));
//          print("selected date is ${selectedDateTime.toString()}");
//          _openTimePicker();
        },
      ),
    );
  }

  Widget _getSlotInfo(String slotName, String fromAndToText,
      {bool isSelectedTimeSlot = false, Color selectedColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
            onTap: () {
              if (isSelectedTimeSlot) {
                _openTimePicker();
              }
            },
            child: Container(
              padding: EdgeInsets.all(isSelectedTimeSlot ? 10 : 3.0),
              child: Text(
                slotName,
                style: TextStyle(
                    color: isSelectedTimeSlot
                        ? PlunesColors.GREENCOLOR
                        : PlunesColors.BLACKCOLOR,
                    fontSize: AppConfig.mediumFont,
//                    decoration: isSelectedTimeSlot
//                        ? TextDecoration.underline
//                        : TextDecoration.none,
                    decorationThickness: 1.5),
              ),
            )),
        Padding(
          padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
          child: Text(
            fromAndToText,
            style: TextStyle(
                color: selectedColor != null
                    ? selectedColor
                    : PlunesColors.GREENCOLOR,
                fontSize: AppConfig.mediumFont),
          ),
        ),
        isSelectedTimeSlot
            ? Container(
                margin: EdgeInsets.only(
                    top: AppConfig.verticalBlockSize * .2,
                    right: isSelectedTimeSlot
                        ? AppConfig.horizontalBlockSize * 26
                        : AppConfig.horizontalBlockSize * 3,
                    left: isSelectedTimeSlot
                        ? AppConfig.horizontalBlockSize * 26
                        : AppConfig.horizontalBlockSize * 3),
                width: double.infinity,
                height: 0.8,
                color: selectedColor != null
                    ? selectedColor
                    : isSelectedTimeSlot
                        ? PlunesColors.GREYCOLOR
                        : PlunesColors.GREENCOLOR,
              )
            : Container()
      ],
    );
  }

  Widget _getSlots() {
    return Row(
      children: <Widget>[
        Expanded(child: _getSlotInfo(PlunesStrings.slot1, _firstSlotTime)),
        Expanded(child: _getSlotInfo(PlunesStrings.slot2, _secondSlotTime)),
      ],
    );
  }

  Widget _getSelectedSlot() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _getSlotInfo(PlunesStrings.appointmentTime, _appointmentTime,
              isSelectedTimeSlot: true,
              selectedColor: _appointmentTime == _notSelectedEntry
                  ? PlunesColors.GREYCOLOR
                  : PlunesColors.GREENCOLOR),
        ),
//        Expanded(child: Container())
      ],
    );
  }

  _getApplyCouponAndCashWidget() {
    return (_userProfileInfo == null ||
            _userProfileInfo.user == null ||
            _userProfileInfo.user.credits == null ||
            _userProfileInfo.user.credits == "0")
        ? Container(
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 3,
                bottom: AppConfig.verticalBlockSize * 1),
            width: double.infinity,
            height: 0.5,
            color: PlunesColors.GREYCOLOR,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    top: AppConfig.verticalBlockSize * 3,
                    bottom: AppConfig.verticalBlockSize * 3),
                width: double.infinity,
                height: 0.5,
                color: PlunesColors.GREYCOLOR,
              ),
              Text(
                PlunesStrings.availableCash,
                style: TextStyle(fontSize: AppConfig.smallFont),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: AppConfig.verticalBlockSize * 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.asset(plunesImages.cashIcon),
                    height: AppConfig.verticalBlockSize * 3,
                    width: AppConfig.horizontalBlockSize * 6,
                    margin: EdgeInsets.only(
                        right: AppConfig.horizontalBlockSize * 2),
                  ),
                  Text(
                    _userProfileInfo.user.credits,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppConfig.smallFont,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: AppConfig.verticalBlockSize * 2,
              ),
              InkWell(
                onTap: () {
                  _shouldUseCredit = !_shouldUseCredit;
                  _setState();
                },
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        _shouldUseCredit
                            ? plunesImages.checkIcon
                            : plunesImages.unCheckIcon,
                        height: 20,
                        width: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 2),
                        child: Text(
                          "Apply Cash  ",
                          style: TextStyle(fontSize: AppConfig.smallFont),
                        ),
                      )
                    ],
                  ),
                ),
              ),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Radio(
//                value: _paymentTypeCoupon,
//                groupValue: _selectedPaymentType,
//                onChanged: (value) => _paymentTypeOnChange(value)),
//            Text("Apply Coupon")
//          ],
//        ),
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
    return Padding(
      padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          widget.appointmentModel == null
              ? Center(
                  child: Text(
                    "Make a payment of  ${_calcPriceToShow()}/- to confirm the booking",
                    style: TextStyle(fontSize: AppConfig.smallFont),
                  ),
                )
              : Container(),
          Container(
            padding: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 28,
                bottom: AppConfig.verticalBlockSize * 1.5,
                top: AppConfig.verticalBlockSize * 2.3,
                right: AppConfig.horizontalBlockSize * 28),
            child: StreamBuilder<Object>(
                stream: _bookingBloc.rescheduleAppointmentStream,
                builder: (context, snapshot) {
                  if (snapshot.data != null &&
                      snapshot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  if (snapshot.data != null &&
                      snapshot.data is RequestSuccess) {
                    Future.delayed(Duration(milliseconds: 20))
                        .then((value) async {
                      widget.showInSnackBar(
                          PlunesStrings.rescheduledSuccessMessage,
                          PlunesColors.BLACKCOLOR,
                          scaffoldKey);
                      await Future.delayed(Duration(milliseconds: 250));
                      Navigator.pop(context);
                    });
                  }
                  if (snapshot.data != null && snapshot.data is RequestFailed) {
                    RequestFailed requestFailed = snapshot.data;
                    Future.delayed(Duration(milliseconds: 20))
                        .then((value) async {
                      widget.showInSnackBar(
                          requestFailed.failureCause ??
                              PlunesStrings.rescheduledFailedMessage,
                          PlunesColors.BLACKCOLOR,
                          scaffoldKey);
                    });
                    _bookingBloc.addStateInRescheduledProvider(null);
                  }
                  return InkWell(
                    onTap: () {
                      (_selectedDate == _tempSelectedDateTime &&
                              _appointmentTime != _notSelectedEntry &&
                              _appointmentTime != null)
                          ? _doPaymentRelatedQueries()
                          : _showErrorMessage(
                              PlunesStrings.pleaseSelectValidSlot);
                      return;
                    },
                    onDoubleTap: () {},
                    child: CustomWidgets().getRoundedButton(
                        widget.appointmentModel == null
                            ? PlunesStrings.payNow
                            : PlunesStrings.reschedule,
                        AppConfig.horizontalBlockSize * 8,
                        (_selectedDate == _tempSelectedDateTime &&
                                _appointmentTime != _notSelectedEntry &&
                                _appointmentTime != null)
                            ? PlunesColors.SPARKLINGGREEN
                            : PlunesColors.WHITECOLOR,
                        AppConfig.horizontalBlockSize * 3,
                        AppConfig.verticalBlockSize * 1,
                        (_selectedDate == _tempSelectedDateTime &&
                                _appointmentTime != _notSelectedEntry &&
                                _appointmentTime != null)
                            ? PlunesColors.WHITECOLOR
                            : PlunesColors.BLACKCOLOR,
                        hasBorder: (_selectedDate == _tempSelectedDateTime &&
                                _appointmentTime != _notSelectedEntry &&
                                _appointmentTime != null)
                            ? false
                            : true),
                  );
                }),
          ),
          InkWell(
            onTap: () => LauncherUtil.launchUrl(urls.terms),
            onDoubleTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                PlunesStrings.tcApply,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: AppConfig.smallFont),
              ),
            ),
          ),
        ],
      ),
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
    latest.DatePicker.showTime12hPicker(context, currentTime: _selectedDate,
        onConfirm: (date) {
      if (date == null) {
        return;
      }
      _tempSelectedDateTime = date;
      _timeChooseCallBack();
    });
  }

  _timeChooseCallBack() {
//    print(
//        "${_tempSelectedDateTime.hour} selected Date Time is $_tempSelectedDateTime");
//    _getSlotsInfo(DateUtil.getDayAsString(_tempSelectedDateTime));
    _checkAndValidateSelectedTime();
    _setState();
    _showPopupForInvalidSlotSelection();
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
//    print("timeSlot ${timeSlot.slots}");
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
//    print(
//        "${fromDuration.toString()}appointment ${toDuration.toString()}time ${appointmentTime}");
    TimeOfDay _selectedTime = TimeOfDay(
        hour: _selectedHour,
        minute: int.tryParse(_hourNMinute[1].trim().split(" ")[0]));
//    print("_selectedTime ${_selectedTime.toString()}");
    if (_selectedTime.hour >= fromDuration.hour &&
        _selectedTime.hour <= toDuration.hour &&
        _tempSelectedDateTime.day == _dateNow.day &&
        _selectedTime.hour >= _dateNow.hour) {
      //same day same hour case handled
      if (_selectedTime.hour == _dateNow.hour &&
          _selectedTime.minute >= _dateNow.minute) {
        //make it true
        ///repeated ///
        if (_selectedTime.hour == toDuration.hour) {
          if (_selectedTime.minute <= toDuration.minute) {
            _appointmentTime = appointmentTime;
            isValidEntryFilled = true;
          }
        } else if (_selectedTime.hour == fromDuration.hour) {
          if (_selectedTime.minute >= fromDuration.minute) {
            _appointmentTime = appointmentTime;
            isValidEntryFilled = true;
          }
        } else {
          _appointmentTime = appointmentTime;
          isValidEntryFilled = true;
        }
      } else if (_selectedTime.hour > _dateNow.hour) {
        //success
        ///repeated ///
        if (_selectedTime.hour == toDuration.hour) {
          if (_selectedTime.minute <= toDuration.minute) {
            _appointmentTime = appointmentTime;
            isValidEntryFilled = true;
          }
        } else if (_selectedTime.hour == fromDuration.hour) {
          if (_selectedTime.minute >= fromDuration.minute) {
            _appointmentTime = appointmentTime;
            isValidEntryFilled = true;
          }
        } else {
          _appointmentTime = appointmentTime;
          isValidEntryFilled = true;
        }

        ///repeated ///
      }
    } else if (_tempSelectedDateTime.day != _dateNow.day &&
        _selectedTime.hour >= fromDuration.hour &&
        _selectedTime.hour <= toDuration.hour) {
      if (_selectedTime.hour == toDuration.hour) {
        if (_selectedTime.minute <= toDuration.minute) {
          _appointmentTime = appointmentTime;
          isValidEntryFilled = true;
        }
      } else if (_selectedTime.hour == fromDuration.hour) {
        if (_selectedTime.minute >= fromDuration.minute) {
          _appointmentTime = appointmentTime;
          isValidEntryFilled = true;
        }
      } else {
        _appointmentTime = appointmentTime;
        isValidEntryFilled = true;
      }
      //success
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
  _initPayment(PaymentSelector paymentSelector) async {
//    print(paymentSelector.toString());
//    print(DateUtil.getTimeWithAmAndPmFormat(_selectedDate));
    InitPayment _initPayment = InitPayment(
        appointmentTime:
            _selectedDate.toUtc().millisecondsSinceEpoch.toString(),
        percentage:
            paymentSelector.isInPercent ? paymentSelector.paymentUnit : null,
        price_pos: widget.serviceIndex,
        //negotiate prev id
        docHosServiceId: widget.docHosSolution.serviceId,
        //Services[0].id
        service_id: widget.searchedSolutionServiceId,
        doctorId: widget.docId,
        //DocHosSolution's _id
        sol_id: widget.docHosSolution.sId,
        time_slot: _selectedTimeSlot,
        professional_id: widget.profId,
        creditsUsed: _shouldUseCredit,
        user_id: UserManager().getUserDetails().uid,
        couponName: "",
        bookIn: !(paymentSelector.isInPercent)
            ? paymentSelector.paymentUnit
            : null);
//    print("initiate payment ${_initPayment.initiatePaymentToJson()}");
    RequestState _requestState = await _bookingBloc.initPayment(_initPayment);
    if (_requestState is RequestSuccess) {
      InitPaymentResponse _initPaymentResponse = _requestState.response;
      if (_initPaymentResponse.success) {
        if (_initPaymentResponse.status.contains("Confirmed")) {
          showDialog(
              context: context,
              builder: (BuildContext context) => PaymentSuccess(
                    referenceID: _initPaymentResponse.referenceId,
                    bookingId: _initPaymentResponse.referenceId,
                  )).then((value) {
            Navigator.pop(context, "pop");
          });
        } else {
          Navigator.of(context)
              .push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __) =>
                      PaymentWebView(id: _initPaymentResponse.id)))
              .then((val) {
            if (val == null) {
              _bookingBloc.cancelPayment(_initPaymentResponse.id);
              return;
            }
            if (val.toString().contains("success")) {
              showDialog(
                      context: context,
                      builder: (
                        BuildContext context,
                      ) =>
                          PaymentSuccess(
                              referenceID: _initPaymentResponse.referenceId,
                              bookingId: _initPaymentResponse.referenceId))
                  .then((value) {
                Navigator.pop(context, "pop");
              });
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
      widget.showInSnackBar(
          _requestState.failureCause, PlunesColors.BLACKCOLOR, scaffoldKey);
    }
  }

  _doPaymentRelatedQueries() async {
    if (widget.appointmentModel != null) {
      _bookingBloc.rescheduleAppointment(
          widget.appointmentModel.bookingId,
          _selectedDate.toUtc().millisecondsSinceEpoch.toString(),
          _selectedTimeSlot);
      return;
    }
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => PopupChoose(
              bookInPrice: widget.bookInPrice,
              totalPrice: widget.price,
              services: widget.service,
            )).then((returnedValue) {
      if (returnedValue != null) {
//        print("selected payment percenatge $returnedValue");
        _initPayment(returnedValue);
      }
    });
  }

  ///payment methods end
  _showErrorMessage(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }

  _calcPriceToShow() {
    if (widget.bookInPrice != null) {
      return "${widget.bookInPrice}";
    } else {
      num price = widget?.service?.newPrice[0]?.toDouble() ?? 0;
      num percentage = widget?.service?.paymentOptions[1] ?? 0;
      var finalPrice = (price * percentage) / 100;
      return finalPrice == null
          ? PlunesStrings.NA
          : "${finalPrice.floorToDouble().toInt()}";
    }
  }

  _goToProfilePage() {
    if (_docProfileInfo.user.userType != null &&
        _docProfileInfo.user.uid != null) {
      Widget route;
      if (_docProfileInfo.user.userType.toLowerCase() ==
          Constants.doctor.toString().toLowerCase()) {
        route = DocProfile(userId: _docProfileInfo.user.uid);
      } else {
        route = HospitalProfile(userID: _docProfileInfo.user.uid);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    }
  }

  void _showPopupForInvalidSlotSelection() {
    if (_appointmentTime != _notSelectedEntry) {
      return;
    }
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              elevation: 0.0,
              child: Container(
                height: AppConfig.verticalBlockSize * 44,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        onDoubleTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.close),
                        ),
                      ),
                    ),
                    Flexible(
                        child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 2,
                                horizontal: AppConfig.horizontalBlockSize * 5),
                            child: Image.asset(PlunesImages.invalidSlotImage))),
                    Flexible(
                        child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 3,
                          vertical: AppConfig.verticalBlockSize * .1),
                      child: Text(
                        PlunesStrings.timeNotAvailable,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR, fontSize: 16),
                      ),
                    )),
                  ],
                ),
              ),
            );
          });
    });
  }
}

class PaymentSuccess extends StatefulWidget {
  final String referenceID;
  final String bookingId;

  PaymentSuccess({Key key, this.referenceID, this.bookingId}) : super(key: key);

  @override
  _PaymentSuccessState createState() => _PaymentSuccessState(referenceID);
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
              if (widget.bookingId != null && widget.bookingId.isNotEmpty) {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AppointmentMainScreen()))
                    .then((value) {
                  Navigator.pop(context, "pop");
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ]);
  }
}
