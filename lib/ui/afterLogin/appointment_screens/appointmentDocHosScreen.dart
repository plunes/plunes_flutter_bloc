import 'package:flutter/material.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';

// ignore: must_be_immutable
class AppointmentDocHosScreen extends BaseActivity {
  final AppointmentModel appointmentModel;
  final BookingBloc bookingBloc;
  int index;
  GlobalKey<ScaffoldState> globalKey;
  Function getAppointment;

  AppointmentDocHosScreen(this.appointmentModel, this.index, this.bookingBloc,
      this.globalKey, this.getAppointment);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends BaseState<AppointmentDocHosScreen> {
  BookingBloc _bookingBloc;
  int index;

  @override
  void initState() {
    _bookingBloc = widget.bookingBloc;
    index = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: _getBodyWidget(widget.appointmentModel, index));
  }

  Widget _getBodyWidget(AppointmentModel appointmentModel, int index) {
    return Container(
      color: PlunesColors.WHITECOLOR,
      // margin: EdgeInsets.only(top:AppConfig.verticalBlockSize*3),
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 3),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            appointmentModel.userName,
                            style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            appointmentModel.userAddress,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                color: Colors.black54),
                          ),
                          SizedBox(height: 5),
                          Text(
                            appointmentModel.userMobileNumber,
                            style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(_getMonthWithYear().toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                          Text(_getFullDate(),
                              style: TextStyle(color: Colors.black54)),
                          Text(_getAmPmTime(),
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
          Container(
            margin:
                EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  child: Text(appointmentModel.bookingStatus,
                      style: TextStyle(
                          fontSize: AppConfig.mediumFont, color: Colors.green)),
                  onTap: () {},
                  onDoubleTap: () {},
                ),
                InkWell(
                  child: Text(PlunesStrings.reschedule,
                      style: TextStyle(
                          fontSize: AppConfig.mediumFont,
                          color: Colors.black54)),
                  onTap: () {
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
                  onDoubleTap: () {},
                ),
                Container(
                  child: StreamBuilder<Object>(
                      stream: _bookingBloc.cancelAppointmentStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null &&
                            snapshot.data is RequestInProgress) {
                          print(snapshot.data);
                          RequestInProgress req = snapshot.data;
                          print(req.requestCode);
                          if (req.requestCode != null &&
                              req.requestCode == index) {
                            return CustomWidgets().getProgressIndicator();
                          }
                        }
                        if (snapshot.data != null &&
                            snapshot.data is RequestSuccess) {
                          RequestSuccess req = snapshot.data;
                          if (req.requestCode != null &&
                              req.requestCode == index) {
                            Future.delayed(Duration(milliseconds: 20))
                                .then((value) async {
                              widget.showInSnackBar(
                                  PlunesStrings.cancelSuccessMessage,
                                  PlunesColors.BLACKCOLOR,
                                  widget.globalKey);
                            });
                            _bookingBloc.addStateInCancelProvider(null);
                          }
                        }
                        if (snapshot.data != null &&
                            snapshot.data is RequestFailed) {
                          RequestFailed requestFailed = snapshot.data;

                          if (requestFailed.requestCode != null &&
                              requestFailed.requestCode == index) {
                            Future.delayed(Duration(milliseconds: 20))
                                .then((value) async {
                              widget.showInSnackBar(
                                  requestFailed.failureCause ??
                                      PlunesStrings.cancelFailedMessage,
                                  PlunesColors.BLACKCOLOR,
                                  widget.globalKey);
                            });
                            _bookingBloc.addStateInCancelProvider(null);
                          }
                        }
                        return InkWell(
                          onTap: () {
                            print('hello on tap ${appointmentModel.bookingId}');
                            if (widget.appointmentModel != null) {
                              _bookingBloc.cancelAppointment(
                                  appointmentModel.bookingId, index);
                            }
                            return;
                          },
                          onDoubleTap: () {},
                          child: Text(plunesStrings.cancel,
                              style:
                                  TextStyle(fontSize: 17, color: Colors.red)),
                        );
                      }),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Text(appointmentModel.serviceName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                  ),
                ),
                Container(
                  child: Text(
                      '\u20B9 ${appointmentModel.service.newPrice.first}',
                    style: TextStyle(fontSize: 18 ,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
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
              ? _getPaymentData(appointmentModel)
              : UserManager().getUserDetails().userType == Constants.user
                  ? _getPaymentData(appointmentModel)
                  : Container(),
          Container(
            height: AppConfig.verticalBlockSize * 5,
            child: FlatButton.icon(
                    onPressed: (){
                    },
                    icon: Image.asset(PlunesImages.bulbIconForTips),
                    label: Text(
                      'Tips For More Conversions',
                      style: TextStyle(color: PlunesColors.GREENCOLOR),
                    )),
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

  _showErrorMessage(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }

  _getPaymentData(AppointmentModel appointmentModel) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: CustomWidgets().amountProgressBar(appointmentModel),
          ),
          SizedBox(height: AppConfig.verticalBlockSize * 3),
          (appointmentModel.amountDue == 0)? Text("Payments done by patient",  style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500)):
          Text('\u20B9 ${appointmentModel.amountDue}  remaining amount to be paid',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  decoration: TextDecoration.underline)),
          Container(
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 3,
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: Text(
                'Create Prescription',
                style: TextStyle(fontSize: 16,color: PlunesColors.GREENCOLOR,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}
