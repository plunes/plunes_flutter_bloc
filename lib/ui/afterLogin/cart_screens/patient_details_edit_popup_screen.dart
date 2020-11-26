import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class EditPatientDetailScreen extends BaseActivity {
  @override
  _EditPatientDetailScreenState createState() =>
      _EditPatientDetailScreenState();
}

class _EditPatientDetailScreenState extends BaseState<EditPatientDetailScreen> {
  String _gender;
  DateTime _currentDate, _selectedDate;
  bool _hasScrolledOnce;

  @override
  void initState() {
    _currentDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
              child: FlatButton(
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                  focusColor: Colors.transparent,
                  onPressed: () => Navigator.pop(context),
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
          )
        ],
      ),
    );
  }

  Widget _getPatientDetailsFillUpView() {
    return
//      (_userProfileInfo == null || _userProfileInfo.user == null)
//        ? Container()
//        :
        Column(
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
//                        controller: _patientNameController,
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
//                          controller: _serviceNameController,
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
//                              controller: _ageController,
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
//    _selectedTimeSlot = PlunesStrings.noSlot;
//    widget.timeSlots.forEach((slot) {
//      if (slot.day.toLowerCase().contains(dateAsString.toLowerCase())) {
//        if (!slot.closed &&
//            slot.slotArray != null &&
//            slot.slotArray.isNotEmpty) {
//          _slotArray = slot.slotArray;
//          slot.slotArray.forEach((element) {
//            if (_selectedTimeSlot == PlunesStrings.noSlot) {
//              _checkSelectedSlot(element);
//            }
//          });
//        }
//      }
//    });
//    _setState();
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
}
