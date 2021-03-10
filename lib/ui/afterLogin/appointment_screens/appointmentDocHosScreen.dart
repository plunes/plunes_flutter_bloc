import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
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
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/afterLogin/HelpScreen.dart';
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
  String bookingId;

  AppointmentDocHosScreen(this.appointmentModel, this.index, this.bookingBloc,
      this.globalKey, this.getAppointment,
      {this.bookingId});

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
      color: (widget.bookingId != null &&
              widget.bookingId == appointmentModel.bookingId)
          ? PlunesColors.LIGHTGREENCOLOR
          : PlunesColors.WHITECOLOR,
      padding: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 3,
          vertical: AppConfig.verticalBlockSize * .5),
      child: Column(
        children: <Widget>[
          _getUserInfoWidget(appointmentModel),
          _getInsuranceWidget(appointmentModel),
          (appointmentModel.service != null &&
                  appointmentModel.service.doctors != null &&
                  appointmentModel.service.doctors.isNotEmpty)
              ? Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    PlunesStrings.appointmentWithText +
                        "${CommonMethods.getStringInCamelCase(appointmentModel.service?.doctors?.first?.name) ?? PlunesStrings.NA}",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: AppConfig.mediumFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Container(),
          Container(
            margin:
                EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                (appointmentModel.doctorConfirmation == false &&
                        (appointmentModel.bookingStatus ==
                                AppointmentModel.confirmedStatus ||
                            appointmentModel.bookingStatus ==
                                AppointmentModel.reservedStatus))
                    ? confirmAppointment(
                        "Click to Confirm", _bookingBloc, appointmentModel)
                    : Flexible(
                        child: InkWell(
                        child: Text(
                            appointmentModel?.bookingStatus ?? PlunesStrings.NA,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                color: PlunesColors.GREENCOLOR)),
                        onTap: () {
                          if (appointmentModel != null &&
                              appointmentModel.bookingStatus !=
                                  AppointmentModel.confirmedStatus &&
                              appointmentModel.bookingStatus !=
                                  AppointmentModel.reservedStatus &&
                              appointmentModel.appointmentTime != null &&
                              DateTime.fromMillisecondsSinceEpoch(int.parse(
                                      appointmentModel.appointmentTime))
                                  .isBefore(DateTime.now())) {
                            _showErrorMessage(PlunesStrings.unableToProcess);
                          }
                        },
                        onDoubleTap: () {},
                      )),
                (appointmentModel.bookingStatus !=
                        AppointmentModel.cancelledStatus)
                    ? Flexible(
                        child: InkWell(
                        child: Text(PlunesStrings.reschedule,
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                color: Colors.black54)),
                        onTap: () async {
                          if (appointmentModel != null &&
                              appointmentModel.appointmentTime != null &&
                              DateTime.fromMillisecondsSinceEpoch(int.parse(
                                      appointmentModel.appointmentTime))
                                  .isBefore(DateTime.now())) {
                            _showErrorMessage(PlunesStrings.unableToReschedule);
                            return;
                          } else if (appointmentModel.bookingStatus ==
                              AppointmentModel.requestCancellation) {
                            _showErrorMessage(
                                PlunesStrings.cantRescheduleForDocHos);
                            return;
                          }
                          await Navigator.push(
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
                          widget.getAppointment();
                        },
                        onDoubleTap: () {},
                      ))
                    : alreadyCancelAppointment(PlunesStrings.reschedule),
                Flexible(
                  child: Container(
                    child: StreamBuilder<Object>(
                        stream: _bookingBloc.cancelAppointmentStream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null &&
                              snapshot.data is RequestInProgress) {
                            RequestInProgress req = snapshot.data;
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
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CustomWidgets()
                                          .appointmentCancellationPopup(
                                              req.response ??
                                                  PlunesStrings
                                                      .ourTeamWillContactYouSoonOnCancel,
                                              widget.globalKey);
                                    });
                              });
                              _bookingBloc.addStateInCancelProvider(null);
                            }
                            widget.getAppointment();
                          }
                          if (snapshot.data != null &&
                              snapshot.data is RequestFailed) {
                            RequestFailed requestFailed = snapshot.data;
                            if (requestFailed.requestCode != null &&
                                requestFailed.requestCode == index) {
                              Future.delayed(Duration(milliseconds: 20))
                                  .then((value) async {
                                _showErrorMessage(requestFailed.failureCause ??
                                    PlunesStrings.cancelFailedMessage);
//
                              });
                              _bookingBloc.addStateInCancelProvider(null);
                            }
                          }
                          return (appointmentModel.bookingStatus !=
                                  AppointmentModel.cancelledStatus)
                              ? InkWell(
                                  onTap: () {
                                    if ((appointmentModel != null &&
                                            appointmentModel.appointmentTime !=
                                                null &&
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    int.parse(appointmentModel
                                                        .appointmentTime))
                                                .isBefore(DateTime.now())) ||
                                        (appointmentModel.bookingStatus ==
                                            AppointmentModel
                                                .requestCancellation)) {
                                      Navigator.push(
                                          widget.globalKey.currentState.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HelpScreen()));
                                      return;
                                    }
//                                    if (appointmentModel.bookingStatus ==
//                                        AppointmentModel.requestCancellation) {
//                                      showDialog(
//                                          context: context,
//                                          builder: (context) {
//                                            return CustomWidgets()
//                                                .appointmentCancellationPopup(
//                                                    PlunesStrings
//                                                        .ourTeamWillContactYouSoonOnCancel,
//                                                    widget.globalKey);
//                                          });
//                                      return;
//                                    }
                                    if (widget.appointmentModel != null) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0)),
                                                elevation: 0.0,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        margin: EdgeInsets.symmetric(
                                                            horizontal: AppConfig
                                                                    .horizontalBlockSize *
                                                                5,
                                                            vertical: AppConfig
                                                                    .verticalBlockSize *
                                                                2.5),
                                                        child: Text(
                                                          "Cancel Appointment for patient ?" ??
                                                              plunesStrings
                                                                  .somethingWentWrong,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: PlunesColors
                                                                  .BLACKCOLOR,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 0.5,
                                                        width: double.infinity,
                                                        color: PlunesColors
                                                            .GREYCOLOR,
//
                                                      ),
                                                      Container(
                                                        height: AppConfig
                                                                .verticalBlockSize *
                                                            6,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          16),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          16)),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: FlatButton(
                                                                    highlightColor: Colors.transparent,
                                                                    hoverColor: Colors.transparent,
                                                                    splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                                                                    focusColor: Colors.transparent,
                                                                    onPressed: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      return;
                                                                    },
                                                                    child: Container(
                                                                        height: AppConfig.verticalBlockSize * 6,
                                                                        width: double.infinity,
//                                                                          padding: EdgeInsets.symmetric(
//                                                                              vertical: AppConfig.verticalBlockSize *
//                                                                                  1.5,
//                                                                              horizontal: AppConfig.horizontalBlockSize *
//                                                                                  6),
                                                                        child: Center(
                                                                          child:
                                                                              Text(
                                                                            'No',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(fontSize: AppConfig.mediumFont, color: PlunesColors.SPARKLINGGREEN),
                                                                          ),
                                                                        ))),
                                                              ),
                                                              Container(
                                                                height: AppConfig
                                                                        .verticalBlockSize *
                                                                    6,
                                                                color: PlunesColors
                                                                    .GREYCOLOR,
                                                                width: 0.5,
                                                              ),
                                                              Expanded(
                                                                child: FlatButton(
                                                                    highlightColor: Colors.transparent,
                                                                    hoverColor: Colors.transparent,
                                                                    splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                                                                    focusColor: Colors.transparent,
                                                                    onPressed: () {
                                                                      _bookingBloc.cancelAppointment(
                                                                          appointmentModel
                                                                              .bookingId,
                                                                          index);
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      return;
                                                                    },
                                                                    child: Container(
                                                                        height: AppConfig.verticalBlockSize * 6,
                                                                        width: double.infinity,
//                                                                          padding: EdgeInsets.symmetric(
//                                                                              vertical: AppConfig.verticalBlockSize *
//                                                                                  1.5,
//                                                                              horizontal: AppConfig.horizontalBlockSize *
//                                                                                  6),
                                                                        child: Center(
                                                                          child:
                                                                              Text(
                                                                            'Yes',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(fontSize: AppConfig.mediumFont, color: PlunesColors.SPARKLINGGREEN),
                                                                          ),
                                                                        ))),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ));
                                    }
                                    return;
                                  },
                                  onDoubleTap: () {},
                                  child: Text(
                                      (appointmentModel != null &&
                                              appointmentModel
                                                      .appointmentTime !=
                                                  null &&
                                              DateTime.fromMillisecondsSinceEpoch(
                                                      int.parse(appointmentModel
                                                          .appointmentTime))
                                                  .isBefore(DateTime.now()))
                                          ? plunesStrings.help
                                          : (appointmentModel.bookingStatus ==
                                                  AppointmentModel
                                                      .requestCancellation)
                                              ? plunesStrings.help
                                              : plunesStrings.cancel,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.smallFont,
                                          color: Colors.red)),
                                )
                              : alreadyCancelAppointment(plunesStrings.help);
                        }),
                  ),
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
                    child: Text(
                        appointmentModel?.serviceName ?? PlunesStrings.NA,
                        style: TextStyle(
                            fontSize: AppConfig.smallFont,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54)),
                  ),
                ),
                Container(
                  child: Text(
                    '\u20B9 ${appointmentModel.service.newPrice.first}',
                    style: TextStyle(
                        fontSize: AppConfig.smallFont,
                        fontWeight: FontWeight.w500,
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
                        fontSize: AppConfig.mediumFont,
                        fontWeight: FontWeight.w500,
                      )),
                  (widget.appointmentModel.isOpened != null &&
                          UserManager().getUserDetails().userType !=
                              Constants.user)
                      ? Icon(
                          widget.appointmentModel.isOpened
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: AppConfig.horizontalBlockSize * 6,
                        )
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
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          CustomWidgets().getTipsConversionsPopup(context));
                },
                icon: Image.asset(PlunesImages.bulbIconForTips),
                label: Text(
                  'Tips For More Conversions',
                  style: TextStyle(
                      fontSize: AppConfig.smallFont,
                      color: PlunesColors.GREENCOLOR),
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
    return " " + appointmentTime;
  }

  _setState() {
    if (mounted) setState(() {});
  }

  _showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets().getInformativePopup(
              globalKey: widget.globalKey, message: message);
        });
  }

  Widget _getPaymentData(AppointmentModel appointmentModel) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: CustomWidgets().amountProgressBar(appointmentModel),
          ),
          SizedBox(height: AppConfig.verticalBlockSize * 3),
          (appointmentModel.dueBookingAmount != null &&
                  appointmentModel.dueBookingAmount == 0)
              ? Text("Payments done by patient",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: AppConfig.smallFont,
                      fontWeight: FontWeight.w500))
              : Text(
                  '\u20B9 ${appointmentModel.dueBookingAmount}  remaining amount to be paid',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConfig.smallFont + 2,
                    color: PlunesColors.GREENCOLOR,
                  )),
          SizedBox(
            height: AppConfig.verticalBlockSize * 5,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Booking Id : ${appointmentModel.referenceId}',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: AppConfig.smallFont - 3),
              ),
              SizedBox(
                height: AppConfig.verticalBlockSize * 1,
              ),
              (appointmentModel.service.category != null &&
                      appointmentModel.service.category.isNotEmpty)
                  ? Text(
                      'Category : ${appointmentModel.service.category.first}',
                      style: TextStyle(fontSize: AppConfig.smallFont - 3))
                  : Container(),
            ],
          ),
//          Container(
//            margin: EdgeInsets.symmetric(
//                vertical: AppConfig.verticalBlockSize * 5,
//                horizontal: AppConfig.horizontalBlockSize * 3),
//            child: Text('Create Prescription',
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                    fontSize: AppConfig.verySmallFont + 2,
//                    color: PlunesColors.GREENCOLOR,
//                    decoration: TextDecoration.underline)),
//          ),
        ],
      ),
    );
  }

  Widget confirmAppointment(String btnName, BookingBloc bookingBloc,
      AppointmentModel appointmentModel) {
    return InkWell(
        child: Text(btnName,
            style: TextStyle(
                fontSize: AppConfig.smallFont,
                color: Colors.blue,
                fontWeight: FontWeight.w500)),
        onTap: () {
          if (appointmentModel != null &&
              appointmentModel.appointmentTime != null &&
              DateTime.fromMillisecondsSinceEpoch(
                      int.parse(appointmentModel.appointmentTime))
                  .isBefore(DateTime.now())) {
            _showErrorMessage(PlunesStrings.unableToConfirm);
            return;
          }
          showDialog(
                  context: context,
                  builder: (BuildContext context) => CustomWidgets()
                      .getDocHosConfirmAppointmentPopUp(
                          context, bookingBloc, appointmentModel))
              .then((value) async {
//            if (value != null && value is String && value == "No") {
//              await _bookingBloc.cancelAppointment(
//                  appointmentModel.bookingId, index);
//            } else {
            widget.getAppointment();
//            }
          });
        },
        onDoubleTap: () {});
  }

  Widget alreadyCancelAppointment(String btnName) {
    return InkWell(
        child: Text(btnName,
            style: TextStyle(
                fontSize: AppConfig.smallFont,
                color: btnName == plunesStrings.help
                    ? Colors.red
                    : Colors.black54)),
        onTap: () {
          if (btnName == plunesStrings.help) {
            Navigator.push(widget.globalKey.currentState.context,
                MaterialPageRoute(builder: (context) => HelpScreen()));
            return;
          }
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  CustomWidgets().getCancelMessagePopup(context));
        },
        onDoubleTap: () {});
  }

  Widget _getUserInfoWidget(AppointmentModel appointmentModel) {
    return Container(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              child: Container(
                height: 90,
                width: 90,
                child: ClipOval(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: CustomWidgets().getImageFromUrl(
                      appointmentModel?.userImage ?? "",
                      boxFit: BoxFit.fill),
                )),
              ),
              radius: 45,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: CommonMethods.getStringInCamelCase(
                                appointmentModel.patientName ??
                                    appointmentModel.userName) ??
                            PlunesStrings.NA,
                        style: TextStyle(
                            fontSize: 23, color: PlunesColors.BLACKCOLOR),
                        children: (appointmentModel.centerLocation != null &&
                                appointmentModel.centerLocation.isNotEmpty)
                            ? [
                                TextSpan(
                                  text:
                                      "\n${appointmentModel.centerLocation?.trim()}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: PlunesColors.GREENCOLOR),
                                )
                              ]
                            : null),
                  ),
                  (appointmentModel.userAddress == null ||
                          appointmentModel.userAddress.trim().isEmpty)
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(top: 4),
                          child: Text(
                            appointmentModel.userAddress?.trim() ??
                                PlunesStrings.NA,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: 20, color: PlunesColors.BLACKCOLOR),
                          ),
                        ),
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    child: InkWell(
                      onTap: () {
                        if (appointmentModel.userMobileNumber != null &&
                            appointmentModel.userMobileNumber.isNotEmpty) {
                          LauncherUtil.launchUrl(
                              "tel://${appointmentModel.userMobileNumber}");
                        }
                      },
                      onDoubleTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          appointmentModel.userMobileNumber ?? PlunesStrings.NA,
                          style: TextStyle(
                              fontSize: 20, color: PlunesColors.BLACKCOLOR),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(_getFullDate(),
                              style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontSize: 16,
                              )),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(_getAmPmTime(),
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
            // Expanded(
            //   child: Container(
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.stretch,
            //       children: <Widget>[
            //         RichText(
            //           text: TextSpan(
            //               text: CommonMethods.getStringInCamelCase(
            //                   appointmentModel.patientName ??
            //                       appointmentModel.userName) ??
            //                   PlunesStrings.NA,
            //               style: TextStyle(
            //                   fontSize: AppConfig.mediumFont,
            //                   color: PlunesColors.BLACKCOLOR),
            //               children: (appointmentModel.centerLocation !=
            //                   null &&
            //                   appointmentModel
            //                       .centerLocation.isNotEmpty)
            //                   ? [
            //                 TextSpan(
            //                   text:
            //                   "\n${appointmentModel.centerLocation?.trim()}",
            //                   style: TextStyle(
            //                       fontSize: AppConfig.mediumFont,
            //                       fontWeight: FontWeight.w500,
            //                       color: PlunesColors.GREENCOLOR),
            //                 )
            //               ]
            //                   : null),
            //         ),
            //         (appointmentModel.userAddress == null ||
            //             appointmentModel.userAddress.trim().isEmpty)
            //             ? Container()
            //             : SizedBox(height: 5),
            //         (appointmentModel.userAddress == null ||
            //             appointmentModel.userAddress.trim().isEmpty)
            //             ? Container()
            //             : Text(
            //           appointmentModel.userAddress?.trim() ??
            //               PlunesStrings.NA,
            //           overflow: TextOverflow.visible,
            //           style: TextStyle(
            //               fontSize: AppConfig.smallFont,
            //               color: Colors.black54),
            //         ),
            //         SizedBox(height: 5),
            //         InkWell(
            //           onTap: () {
            //             if (appointmentModel.userMobileNumber != null &&
            //                 appointmentModel
            //                     .userMobileNumber.isNotEmpty) {
            //               LauncherUtil.launchUrl(
            //                   "tel://${appointmentModel.userMobileNumber}");
            //             }
            //           },
            //           onDoubleTap: () {},
            //           child: Padding(
            //             padding: EdgeInsets.only(
            //                 right: 5.0, top: 5.0, bottom: 5.0),
            //             child: Text(
            //               appointmentModel.userMobileNumber ??
            //                   PlunesStrings.NA,
            //               style: TextStyle(
            //                 fontSize: AppConfig.mediumFont,
            //                 fontWeight: FontWeight.w500,
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // Expanded(
            //   child: Container(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: <Widget>[
            //         Text(_getMonthWithYear().toUpperCase(),
            //             style: TextStyle(
            //               fontWeight: FontWeight.w500,
            //               fontSize: AppConfig.mediumFont,
            //             )),
            //         Text(_getFullDate(),
            //             style: TextStyle(
            //               color: Colors.black54,
            //               fontSize: AppConfig.smallFont,
            //             )),
            //         Text(_getAmPmTime(),
            //             style: TextStyle(
            //               color: Colors.black54,
            //               fontSize: AppConfig.smallFont,
            //             )),
            //       ],
            //     ),
            //   ),
            // ),
          ]),
    );
  }

  Widget _getInsuranceWidget(AppointmentModel appointmentModel) {
    if (appointmentModel == null || appointmentModel.insuranceDetails == null) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (appointmentModel.insuranceDetails.insurancePartner == null ||
                  appointmentModel.insuranceDetails.insurancePartner
                      .trim()
                      .isEmpty)
              ? Container()
              : Text(
                  "Policy provider name",
                  style:
                      TextStyle(fontSize: 12.5, color: PlunesColors.BLACKCOLOR),
                ),
          (appointmentModel.insuranceDetails.insurancePartner == null ||
                  appointmentModel.insuranceDetails.insurancePartner
                      .trim()
                      .isEmpty)
              ? Container()
              : Container(
                  margin: EdgeInsets.only(top: 3),
                  child: Text(
                    appointmentModel.insuranceDetails.insurancePartner ?? "",
                    style:
                        TextStyle(fontSize: 16, color: PlunesColors.BLACKCOLOR),
                  )),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            width: AppConfig.horizontalBlockSize * 15,
            height: 0.8,
            color: PlunesColors.GREYCOLOR,
          ),
          Text(
            "Policy number",
            style: TextStyle(fontSize: 12.5, color: PlunesColors.BLACKCOLOR),
          ),
          Container(
              margin: EdgeInsets.only(top: 3),
              child: Text(
                appointmentModel.insuranceDetails?.policyNumber ?? "",
                style: TextStyle(fontSize: 16, color: PlunesColors.BLACKCOLOR),
              )),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            width: AppConfig.horizontalBlockSize * 15,
            height: 0.8,
            color: PlunesColors.GREYCOLOR,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (appointmentModel.insuranceDetails.insuranceCard == null ||
                        appointmentModel.insuranceDetails.insuranceCard
                            .trim()
                            .isEmpty)
                    ? Container()
                    : Flexible(
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            List<Photo> photos = [];
                            if (appointmentModel.insuranceDetails.insuranceCard
                                .contains("http")) {
                              photos.add(Photo(
                                  assetName: appointmentModel
                                      .insuranceDetails.insuranceCard));
                            }
                            if (photos != null && photos.isNotEmpty) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PageSlider(photos, 0)));
                            }
                          },
                          onDoubleTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                "Insurance card photo",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: PlunesColors.BLACKCOLOR
                                        .withOpacity(0.8)),
                              )),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                height: 102,
                                width: 160,
                                child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: CustomWidgets().getImageFromUrl(
                                        appointmentModel.insuranceDetails
                                                ?.insuranceCard ??
                                            "",
                                        boxFit: BoxFit.fill)),
                              )
                            ],
                          ),
                        ),
                      ),
                (appointmentModel.insuranceDetails.insurancePolicy == null ||
                        appointmentModel.insuranceDetails.insurancePolicy
                            .trim()
                            .isEmpty)
                    ? Container()
                    : Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: InkWell(
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onDoubleTap: () {},
                            onTap: () {
                              _launch(appointmentModel
                                  .insuranceDetails.insurancePolicy);
                              return;
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text(
                                  "Insurance document",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: PlunesColors.BLACKCOLOR
                                          .withOpacity(0.8)),
                                )),
                                Container(
                                  margin: EdgeInsets.only(top: 5, right: 4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  height: 102,
                                  width: 160,
                                  child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: Image.asset(
                                        plunesImages.pdfIcon1,
                                        fit: BoxFit.fill,
                                      )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _launch(String url) {
    LauncherUtil.launchUrl(url);
  }
}
