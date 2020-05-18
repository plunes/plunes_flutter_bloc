import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/Utils/payment_web_view.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';

// ignore: must_be_immutable
class AppointmentScreen extends BaseActivity {
  final AppointmentModel appointmentModel;
  final BookingBloc bookingBloc;
  int index;
  String bookingId;
  GlobalKey<ScaffoldState> globalKey;
  Function getAppointment;

  AppointmentScreen(this.appointmentModel, this.index, this.bookingBloc,
      this.globalKey, this.getAppointment,
      {this.bookingId});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends BaseState<AppointmentScreen> {
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
      color: (widget.bookingId != null &&
              widget.bookingId == appointmentModel.bookingId)
          ? PlunesColors.LIGHTGREENCOLOR
          : PlunesColors.WHITECOLOR,
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 3),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            appointmentModel.professionalName ??
                                PlunesStrings.NA,
                            style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            appointmentModel.professionalAddress ??
                                PlunesStrings.NA,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                color: Colors.black54),
                          ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () {
                              if (appointmentModel.professionalMobileNumber !=
                                      null &&
                                  appointmentModel
                                      .professionalMobileNumber.isNotEmpty) {
                                LauncherUtil.launchUrl(
                                    "tel://${appointmentModel.professionalMobileNumber}");
                              }
                            },
                            onDoubleTap: () {},
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 5.0, top: 5.0, bottom: 5.0),
                              child: Text(
                                appointmentModel.professionalMobileNumber ??
                                    PlunesStrings.NA,
                                style: TextStyle(
                                    fontSize: AppConfig.mediumFont,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
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
                      child: Center(
                        child: IconButton(
                            icon: Image.asset(
                              "assets/images/drop-location-icon.png",
                              width: AppConfig.verticalBlockSize * 5,
                              height: AppConfig.verticalBlockSize * 5,
                            ),
                            onPressed: () {
                              (appointmentModel?.lat == null ||
                                      appointmentModel.lat.isEmpty ||
                                      appointmentModel?.long == null ||
                                      appointmentModel.long.isEmpty)
                                  ? widget.showInSnackBar(
                                      PlunesStrings.locationNotAvailable,
                                      PlunesColors.BLACKCOLOR,
                                      widget.globalKey)
                                  : LauncherUtil.openMap(
                                      double.tryParse(appointmentModel.lat),
                                      double.tryParse(appointmentModel.long));
                            }),
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
                                fontWeight: FontWeight.bold,
                                fontSize: AppConfig.mediumFont,
                              )),
                          Text(_getFullDate(),
                              style: TextStyle(
                                  fontSize: AppConfig.smallFont,
                                  color: Colors.black54)),
                          Text(_getAmPmTime(),
                              style: TextStyle(
                                  fontSize: AppConfig.smallFont,
                                  color: Colors.black54)),
                          (appointmentModel.serviceType == 'Procedure' &&
                                  appointmentModel.paymentPercent == '20' &&
                                  appointmentModel.bookingStatus !=
                                      AppointmentModel
                                          .cancelledStatus) //&& appointmentModel.bookingStatus !=)
                              ? Container(
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
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BookingMainScreen(
                                                    appointmentModel:
                                                        widget.appointmentModel,
                                                    profId: appointmentModel
                                                        .service.professionalId,
                                                    timeSlots: appointmentModel
                                                        .service.timeSlots,
                                                  )));
                                    },
                                    color: Colors.green,
                                  ),
                                )
                              : Container(),
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
//                ((appointmentModel.doctorConfirmation != null &&
//                            appointmentModel.doctorConfirmation) ||
//                        appointmentModel.bookingStatus ==
//                            AppointmentModel.cancelledStatus)
//                    ?
                InkWell(
                  child: Text(appointmentModel.bookingStatus,
                      style: TextStyle(
                          fontSize: AppConfig.smallFont, color: Colors.green)),
                  onTap: () {},
                  onDoubleTap: () {},
                ),
//                    : Text('Pending for confirmation',
//                        style: TextStyle(
//                            fontSize: AppConfig.smallFont, color: Colors.blue)),
                (appointmentModel.bookingStatus !=
                        AppointmentModel.cancelledStatus)
                    ? InkWell(
                        child: Text(PlunesStrings.reschedule,
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                color: Colors.black54)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookingMainScreen(
                                        appointmentModel:
                                            widget.appointmentModel,
                                        profId: appointmentModel
                                            .service.professionalId,
                                        timeSlots:
                                            appointmentModel.service.timeSlots,
                                      )));
                        },
                        onDoubleTap: () {},
                      )
                    : alreadyCancelAppointment(PlunesStrings.reschedule),
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
                              widget.getAppointment();
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
                        return (appointmentModel.bookingStatus !=
                                AppointmentModel.cancelledStatus)
                            ? InkWell(
                                onTap: () {
                                  if (widget.appointmentModel != null) {
                                    _bookingBloc.cancelAppointment(
                                        appointmentModel.bookingId, index);
                                  }
                                  return;
                                },
                                onDoubleTap: () {},
                                child: Text(plunesStrings.cancel,
                                    style: TextStyle(
                                        fontSize: AppConfig.smallFont,
                                        color: Colors.red)),
                              )
                            : alreadyCancelAppointment(plunesStrings.cancel);
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
                            fontSize: AppConfig.smallFont,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('\u20B9 ${appointmentModel.service.price.first}',
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                decoration: TextDecoration.lineThrough,
                                color: PlunesColors.GREYCOLOR)),
                        SizedBox(
                          width: AppConfig.horizontalBlockSize * 1,
                        ),
                        Text(
                          '\u20B9 ${appointmentModel.service.newPrice.first}',
                          style: TextStyle(
                            fontSize: AppConfig.smallFont,
                          ),
                        ),
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
                          fontSize: AppConfig.mediumFont,
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
              ? _getData(appointmentModel)
              : UserManager().getUserDetails().userType == Constants.user
                  ? _getData(appointmentModel)
                  : Container(),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
//                InkWell(
//                  onTap: () {},
//                  onDoubleTap: () {},
//                  child: Text(PlunesStrings.requestInvoice,
//                      style: TextStyle(
//                          fontSize: AppConfig.smallFont,
//                          color: Colors.black54,
//                          decoration: TextDecoration.underline)),
//                ),
                (appointmentModel.refundStatus != null &&
                        appointmentModel.refundStatus ==
                            AppointmentModel.notRequested)
                    ? InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => CustomWidgets().refundPopup(
                                  _bookingBloc, appointmentModel)).then(
                              (value) {
                            _bookingBloc.addStateInRefundProvider(null);
                            if (widget.getAppointment != null) {
                              widget.getAppointment();
                            }
                          });
                        },
                        onDoubleTap: () {},
                        child: Text(
                          PlunesStrings.refund,
                          style: TextStyle(
                              fontSize: AppConfig.smallFont,
                              color: Colors.black54,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    : Text(
                        'Refund ${appointmentModel.refundStatus}',
                        style: TextStyle(
                            fontSize: AppConfig.smallFont,
                            color: PlunesColors.GREENCOLOR),
                      )
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

  _getData(AppointmentModel appointmentModel) {
    bool isPaymentCompleted = false;
    if (appointmentModel.paymentStatus != null &&
        appointmentModel.paymentStatus.isNotEmpty) {
      for (int index = 0;
          index < appointmentModel.paymentStatus.length;
          index++) {
        if (appointmentModel.paymentStatus[index].status != null &&
            appointmentModel.paymentStatus[index].status) {
          isPaymentCompleted = true;
        } else {
          isPaymentCompleted = false;
          break;
        }
      }
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: CustomWidgets().amountProgressBar(appointmentModel),
          ),
          SizedBox(height: AppConfig.verticalBlockSize * 3),
          (appointmentModel.bookingStatus != null &&
                  appointmentModel.bookingStatus ==
                      AppointmentModel.cancelledStatus)
              ? Text(AppointmentModel.cancelledStatus)
              : isPaymentCompleted
                  ? Text(PlunesStrings.paymentDone)
                  : RichText(
                      text: TextSpan(
                          text: '${PlunesStrings.pay}',
                          style: TextStyle(
                              fontSize: AppConfig.mediumFont,
                              color: Colors.black,
                              decoration: TextDecoration.underline),
                          children: appointmentModel.paymentStatus
                                  .where((element) => !(element.status))
                                  .map((paymentObj) {
                                TapGestureRecognizer tapRecognizer =
                                    TapGestureRecognizer()
                                      ..onTap =
                                          () => _openPaymentOption(paymentObj);
                                return TextSpan(
                                    text:
                                        '      \u20B9${paymentObj.amount ?? 0}',
                                    style: TextStyle(
                                        fontSize: AppConfig.mediumFont,
                                        color: Colors.green,
                                        decoration: TextDecoration.none),
                                    recognizer: tapRecognizer);
                              }).toList() ??
                              []),
                    ),
          Container(
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 3,
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: Text(
                'Please make sure that you pay through app for ${appointmentModel?.service?.discount ?? 0}% discount to be valid',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConfig.verySmallFont,
                  color: Colors.black87,
                )),
          ),
        ],
      ),
    );
  }

  Widget alreadyCancelAppointment(String btnName) {
    return InkWell(
        child: Text(btnName,
            style: TextStyle(
                fontSize: AppConfig.smallFont, color: Colors.black54)),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  CustomWidgets().getCancelMessagePopup(context));
        },
        onDoubleTap: () {});
  }

  _openPaymentOption(PaymentStatus paymentObj) async {
    var result = await _bookingBloc.payInstallment(BookingInstallment(
            bookingId: widget.appointmentModel.bookingId,
            creditsUsed: true,
            paymentPercent: paymentObj.title.replaceAll("%", ""))
        .toJson());
    if (result is RequestSuccess) {
      print("payment success");
      InitPaymentResponse _initPaymentResponse = result.response;
      if (_initPaymentResponse.success) {
        if (_initPaymentResponse.status.contains("Confirmed")) {
          showDialog(
                  context: context,
                  builder: (BuildContext context) => PaymentSuccess(
                      bookingId: _initPaymentResponse.referenceId))
              .then((value) => widget.getAppointment());
        } else {
          Navigator.of(context)
              .push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __) =>
                      PaymentWebView(id: widget.appointmentModel.bookingId)))
              .then((val) {
            if (val.toString().contains("success")) {
              showDialog(
                      context: context,
                      builder: (
                        BuildContext context,
                      ) =>
                          PaymentSuccess(
                              bookingId: _initPaymentResponse.referenceId))
                  .then((value) => widget.getAppointment());
            } else if (val.toString().contains("fail")) {
              widget.showInSnackBar(
                  "Payment Failed", PlunesColors.BLACKCOLOR, widget.globalKey);
            } else if (val.toString().contains("cancel")) {
              widget.showInSnackBar("Payment Cancelled",
                  PlunesColors.BLACKCOLOR, widget.globalKey);
            }
          });
        }
      }
    } else if (result is RequestFailed) {
      print("payment failed");
      widget.showInSnackBar(
          result.failureCause, PlunesColors.BLACKCOLOR, widget.globalKey);
    }
  }
}
