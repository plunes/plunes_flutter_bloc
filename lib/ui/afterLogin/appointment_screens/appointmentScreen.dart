import 'package:flutter/material.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/Utils/custom_widgets.dart';

// ignore: must_be_immutable
class AppointmentScreen extends BaseActivity {
  final AppointmentModel appointmentModel;

  AppointmentScreen(this.appointmentModel);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends BaseState<AppointmentScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: _getBodyWidget(widget.appointmentModel));
  }

  Widget _getBodyWidget(AppointmentModel appointmentModel) {
    return Container(
      color: PlunesColors.WHITECOLOR,
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            appointmentModel.professionalName,
                            style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            appointmentModel.professionalAddress,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                color: Colors.black54),
                          ),
                          SizedBox(height: 5),
                          Text(
                            appointmentModel.professionalMobileNumber,
                            style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                              icon: Image.asset(
                                "assets/images/drop-location-icon.png",
                                width: AppConfig.verticalBlockSize * 5,
                                height: AppConfig.verticalBlockSize * 5,
                              ),
                              onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      //margin: EdgeInsets.only(bottom:40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(_getMonthWithYear().toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                          Text(_getFullDate(),
                              style: TextStyle(color: Colors.black54)),
                          Text(_getAmPmTime(),
                              style: TextStyle(color: Colors.black54)),
                          Container(
                            margin: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 2),
                            child: RaisedButton(
                              child: Text(
                                PlunesStrings.visitAgain,
                                style: TextStyle(color: Colors.white),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(
                                    AppConfig.verticalBlockSize * 4),
                              ),
                              onPressed: () {},
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
          Container(
            margin:
                EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  child: Text(appointmentModel.bookingStatus,
                      style: TextStyle(
                          fontSize: AppConfig.mediumFont, color: Colors.green)),
                  onPressed: () {},
                  padding: EdgeInsets.symmetric(horizontal: 0),
                ),
                FlatButton(
                  child: Text(PlunesStrings.reschedule,
                      style: TextStyle(
                          fontSize: AppConfig.mediumFont,
                          color: Colors.black54)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookingMainScreen(
                                  appointmentModel: widget.appointmentModel,
                                  profId:
                                      appointmentModel.service.professionalId,
                                  timeSlots: appointmentModel.service.timeSlots,
                                )));
                  },
                  padding: EdgeInsets.symmetric(horizontal: 0),
                ),
                FlatButton(
                  child: Text(plunesStrings.cancel,
                      style: TextStyle(fontSize: 17, color: Colors.red)),
                  onPressed: () {},
                  padding: EdgeInsets.symmetric(horizontal: 0),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
            // margin: EdgeInsets.symmetric(: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(appointmentModel.serviceName,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('\u20B9 ${appointmentModel.service.price.first}',
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: PlunesColors.GREYCOLOR)),
                        SizedBox(
                          width: AppConfig.horizontalBlockSize * 1,
                        ),
                        Text(
                            '\u20B9 ${appointmentModel.service.newPrice.first}'),
                      ],
                    ),
                    Text('${appointmentModel.service.discount}%',
                        style: TextStyle(color: Colors.green))
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (widget.appointmentModel.isOpened != null &&
                  UserManager().getUserDetails().userType != Constants.user) {
                widget.appointmentModel.isOpened =
                    !widget.appointmentModel.isOpened;
                _setState();
              }
            },
            onDoubleTap: () {},
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
              ),
              child: Column(
                children: <Widget>[
                  Text(PlunesStrings.paymentStatus,
                      style: TextStyle(
                          fontSize: AppConfig.largeFont,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline)),
                  (widget.appointmentModel.isOpened != null &&
                          UserManager().getUserDetails().userType !=
                              Constants.user)
                      ? Icon(widget.appointmentModel.isOpened
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down)
                      : Container()
                ],
              ),
            ),
          ),
          (widget.appointmentModel.isOpened != null &&
                  UserManager().getUserDetails().userType != Constants.user &&
                  widget.appointmentModel.isOpened)
              ? Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child:
                            CustomWidgets().amountProgressBar(appointmentModel),
                      ),
                      SizedBox(height: AppConfig.verticalBlockSize * 3),
                      Text('\u20B9 ${appointmentModel.amountDue}',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                              decoration: TextDecoration.underline)),
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 3,
                            horizontal: AppConfig.horizontalBlockSize * 3),
                        child: Text(
                            'Please make sure that you pay through app for ${appointmentModel.service.discount}% discount to be valid',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 16)),
                      ),
                    ],
                  ),
                )
              : Container(),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(PlunesStrings.requestInvoice,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        decoration: TextDecoration.underline)),
                Text(PlunesStrings.refund,
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                        decoration: TextDecoration.underline)),
              ],
            ),
          ),
          SizedBox(
            height: AppConfig.verticalBlockSize * 2,
          ),
          CustomWidgets().getSeparatorLine(),
        ],
      ),
    );
  }

  String _getFullDate() {
    String appointmentTime = PlunesStrings.NA;
    if (widget.appointmentModel != null &&
        widget.appointmentModel.appointmentTime != null) {
      try {
        appointmentTime = DateUtil.getDateFormat(
            DateTime.fromMillisecondsSinceEpoch(
                int.parse(widget.appointmentModel.appointmentTime)));
      } catch (e) {
        AppLog.debugLog(PlunesStrings.appointmentScreenError + '$e');
      }
    }
    return appointmentTime;
  }

  String _getMonthWithYear() {
    String appointmentTime = PlunesStrings.NA;
    if (widget.appointmentModel != null &&
        widget.appointmentModel.appointmentTime != null) {
      try {
        appointmentTime = DateUtil.getMonthYear(
            DateTime.fromMillisecondsSinceEpoch(
                int.parse(widget.appointmentModel.appointmentTime)));
      } catch (e) {
        AppLog.debugLog(PlunesStrings.appointmentScreenError + '$e');
      }
    }
    return appointmentTime;
  }

  String _getAmPmTime() {
    String appointmentTime = PlunesStrings.NA;
    if (widget.appointmentModel != null &&
        widget.appointmentModel.appointmentTime != null) {
      try {
        appointmentTime = DateUtil.getTimeWithAmAndPmFormat(
            DateTime.fromMillisecondsSinceEpoch(
                int.parse(widget.appointmentModel.appointmentTime)));
      } catch (e) {
        AppLog.debugLog(PlunesStrings.appointmentScreenError + '$e');
      }
    }
    return appointmentTime;
  }

  _setState() {
    if (mounted) setState(() {});
  }
}
