import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

// ignore: must_be_immutable
class BookingMainScreen extends BaseActivity {
  @override
  _BookingMainScreenState createState() => _BookingMainScreenState();
}

class _BookingMainScreenState extends BaseState<BookingMainScreen> {
  DateTime _currentDate, _selectedDate;

  @override
  void initState() {
    _currentDate = DateTime.now();
    _selectedDate = _currentDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar:
              widget.getAppBar(context, PlunesStrings.confirmYourBooking, true),
          body: Builder(builder: (context) {
            return Container(
              padding: CustomWidgets().getDefaultPaddingForScreens(),
              child: _getBody(),
            );
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
          child: ClipOval(
              child: CustomWidgets().getImageFromUrl(
                  "https://plunes.co/v4/data/5e6cda3106e6765a2d08ce24_1584192397080.jpg")),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Dr . Something here",
                          style: TextStyle(
                              fontSize: AppConfig.mediumFont,
                              fontWeight: FontWeight.bold,
                              color: PlunesColors.BLACKCOLOR),
                        ),
                        Text(
                          "Speciality here",
                          style: TextStyle(
                              fontSize: AppConfig.mediumFont,
                              color: PlunesColors.GREYCOLOR),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _getDirections(),
                      child: Text(
                        PlunesStrings.getDirection,
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: AppConfig.mediumFont,
                            color: PlunesColors.GREENCOLOR),
                      ),
                    ),
                    flex: 3,
                  ),
                ],
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
                              "dsfdsdsdsfdsfsdfdf dsfdsdsfjkbhsdfbvsdfjdsvfdghjskgyefgfusydifhggkdfsgydhksfbhkdsfkghdshfdfsbhkdfsbhjdfscddsfdsfwdfdwfed",
                          style: new TextStyle(
                              fontSize: AppConfig.mediumFont,
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

  _getDirections() {}

  Widget _getDatePicker() {
    return DatePickerTimeline(
      _currentDate,
      width: double.infinity,
      height: AppConfig.verticalBlockSize * 11,
      daysCount: 100,
      dateTextStyle: TextStyle(
          color: PlunesColors.BLACKCOLOR, fontSize: AppConfig.largeFont),
      dayTextStyle: TextStyle(color: PlunesColors.BLACKCOLOR),
      monthTextStyle: TextStyle(color: PlunesColors.BLACKCOLOR),
      selectionColor: PlunesColors.GREENCOLOR,
      onDateChange: (DateTime selectedDateTime) {
        _selectedDate = selectedDateTime;
        print("selected date is ${selectedDateTime.toString()}");
      },
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
//                decoration: TextDecoration.underline,
                color: PlunesColors.BLACKCOLOR,
                fontSize: AppConfig.mediumFont),
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
        Expanded(
            child: _getSlotInfo(PlunesStrings.slot1, "10:00 am - 13:00 pm")),
        Expanded(
            child: _getSlotInfo(PlunesStrings.slot2, "10:00 am - 13:00 pm"))
      ],
    );
  }

  Widget _getSelectedSlot() {
    return Row(
      children: <Widget>[
        Expanded(
            child: _getSlotInfo(
                PlunesStrings.appointmentTime, "10:00 am - 13:00 pm")),
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
        Text("Apply Cash"),
        Text("Apply Cash"),
        Text("Apply Cash"),
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
              bottom: AppConfig.verticalBlockSize * 2.3,
              top: AppConfig.verticalBlockSize * 2.3,
              right: AppConfig.horizontalBlockSize * 24),
          child: CustomWidgets().getRoundedButton(
              PlunesStrings.payNow,
              AppConfig.horizontalBlockSize * 8,
              PlunesColors.WHITECOLOR,
              AppConfig.horizontalBlockSize * 3,
              AppConfig.verticalBlockSize * 1,
              PlunesColors.BLACKCOLOR,
              hasBorder: true),
        ),
        InkWell(
          child: Text(
            PlunesStrings.tcApply,
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
