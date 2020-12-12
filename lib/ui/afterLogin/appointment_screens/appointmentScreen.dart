import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/analytics.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/log.dart';
import 'package:plunes/Utils/payment_web_view.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/ui/afterLogin/HelpScreen.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_payment_option_popup.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';

// ignore: must_be_immutable
class AppointmentScreen extends BaseActivity {
  final AppointmentModel appointmentModel;
  final BookingBloc bookingBloc;
  int index;
  String bookingId;
  GlobalKey<ScaffoldState> globalKey;
  Function getAppointment;
  BuildContext context;

  AppointmentScreen(this.appointmentModel, this.index, this.bookingBloc,
      this.globalKey, this.getAppointment, this.context,
      {this.bookingId});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends BaseState<AppointmentScreen> {
  BookingBloc _bookingBloc;
  int index;
  String _profNumber;

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
          vertical: AppConfig.verticalBlockSize * 2),
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
                          InkWell(
                            onTap: () => _openProfile(),
                            onDoubleTap: () {},
                            child: Text(
                              CommonMethods.getStringInCamelCase(
                                      appointmentModel?.professionalName) ??
                                  PlunesStrings.NA,
                              style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () => _openProfile(),
                            onDoubleTap: () {},
                            child: Text(
                              appointmentModel.professionalAddress?.trim() ??
                                  PlunesStrings.NA,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  fontSize: AppConfig.smallFont,
                                  color: Colors.black54),
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
                          bottom: AppConfig.verticalBlockSize * 1),
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
                                  ? _showSnackBar(
                                      PlunesStrings.locationNotAvailable)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(_getMonthWithYear().toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
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
//                          (appointmentModel.serviceType == 'Procedure' &&
//                                  appointmentModel.paymentPercent == '20' &&
//                                  appointmentModel.bookingStatus !=
//                                      AppointmentModel
//                                          .cancelledStatus) //&& appointmentModel.bookingStatus !=)
//                              ? Container(
//                                  margin: EdgeInsets.only(
//                                      top: AppConfig.verticalBlockSize * 2),
//                                  child: RaisedButton(
//                                    child: Text(
//                                      PlunesStrings.visitAgain,
//                                      style: TextStyle(color: Colors.white),
//                                    ),
//                                    shape: RoundedRectangleBorder(
//                                      borderRadius: new BorderRadius.circular(
//                                          AppConfig.verticalBlockSize * 4),
//                                    ),
//                                    onPressed: () {
//                                      Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                              builder: (context) =>
//                                                  BookingMainScreen(
//                                                    appointmentModel:
//                                                        widget.appointmentModel,
//                                                    profId: appointmentModel
//                                                        .service.professionalId,
//                                                    timeSlots: appointmentModel
//                                                        .service.timeSlots,
//                                                  )));
//                                    },
//                                    color: Colors.green,
//                                  ),
//                                )
//                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
          SizedBox(height: 5),
          appointmentModel.patientName != null
              ? Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Patient Name - ${CommonMethods.getStringInCamelCase(appointmentModel?.patientName) ?? PlunesStrings.NA}",
                    style: TextStyle(
                      fontSize: AppConfig.mediumFont,
                    ),
                  ),
                )
              : Container(),
          SizedBox(height: 3),
          _getProfessionalNumber(appointmentModel),
          (appointmentModel.centreNumber != null &&
                  appointmentModel.centreNumber.isNotEmpty &&
                  _profNumber != null &&
                  _profNumber != appointmentModel.centreNumber)
              ? SizedBox(height: AppConfig.verticalBlockSize * 1.5)
              : Container(),
          (appointmentModel.centreNumber != null &&
                  appointmentModel.centreNumber.isNotEmpty &&
                  _profNumber != null &&
                  _profNumber != appointmentModel.centreNumber)
              ? _getCentreNumber(appointmentModel)
              : Container(),
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
                  child: Text(
//                      (appointmentModel.bookingStatus ==
//                              AppointmentModel.requestCancellation)
//                          ? AppointmentModel.confirmedStatus
//                          :
                      appointmentModel.bookingStatus,
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
                        DateTime.fromMillisecondsSinceEpoch(
                                int.parse(appointmentModel.appointmentTime))
                            .isBefore(DateTime.now())) {
                      _showSnackBar(PlunesStrings.unableToProcess);
                    }
                  },
                  onDoubleTap: () {},
                ),
                (appointmentModel.bookingStatus !=
                        AppointmentModel.cancelledStatus)
                    ? InkWell(
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
                            _showSnackBar(PlunesStrings.unableToReschedule);
                            return;
                          } else if (appointmentModel.bookingStatus ==
                              AppointmentModel.requestCancellation) {
                            _showSnackBar(PlunesStrings.cantRescheduleForUser);
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
                      )
                    : alreadyCancelAppointment(PlunesStrings.reschedule),
                Container(
                  child: StreamBuilder<Object>(
                      stream: _bookingBloc.cancelAppointmentStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null &&
                            snapshot.data is RequestInProgress) {
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
                              _showSnackBar(requestFailed.failureCause ??
                                  PlunesStrings.cancelFailedMessage);
//                              widget.showInSnackBar(
//                                  requestFailed.failureCause ??
//                                      PlunesStrings.cancelFailedMessage,
//                                  PlunesColors.BLACKCOLOR,
//                                  widget.globalKey);
                            });
                            _bookingBloc.addStateInCancelProvider(null);
                          }
                        }
                        return (appointmentModel.bookingStatus !=
                                    AppointmentModel.cancelledStatus ||
                                appointmentModel.bookingStatus ==
                                    AppointmentModel.requestCancellation)
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
//                                  if (appointmentModel.bookingStatus ==
//                                      AppointmentModel.requestCancellation) {
//                                    showDialog(
//                                        context: context,
//                                        builder: (context) {
//                                          return CustomWidgets()
//                                              .appointmentCancellationPopup(
//                                                  PlunesStrings
//                                                      .ourTeamWillContactYouSoonOnCancel,
//                                                  widget.globalKey);
//                                        });
//                                    return;
//                                  }
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
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
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
                                                        "Cancel the Appointment ?" ??
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
//                                                      margin: EdgeInsets.only(
//                                                          top: AppConfig
//                                                                  .verticalBlockSize *
//                                                              1),
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
                                                                bottomRight:
                                                                    Radius
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
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  splashColor: PlunesColors
                                                                      .SPARKLINGGREEN
                                                                      .withOpacity(
                                                                          .1),
                                                                  focusColor: Colors
                                                                      .transparent,
//                                                                  splashColor: Colors
//                                                                      .redAccent
//                                                                      .withOpacity(
//                                                                          .2),
//                                                                  highlightColor: Colors
//                                                                      .redAccent
//                                                                      .withOpacity(
//                                                                          .2),
//                                                                  focusColor: Colors
//                                                                      .redAccent
//                                                                      .withOpacity(
//                                                                          .2),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    return;
                                                                  },
                                                                  child: Container(
                                                                      height: AppConfig.verticalBlockSize * 6,
                                                                      width: double.infinity,
//                                                                        padding: EdgeInsets.symmetric(
//                                                                            vertical: AppConfig.verticalBlockSize *
//                                                                                1.5,
//                                                                            horizontal: AppConfig.horizontalBlockSize *
//                                                                                6),
                                                                      child: Center(
                                                                        child:
                                                                            Text(
                                                                          'No',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              fontSize: AppConfig.mediumFont,
                                                                              color: PlunesColors.SPARKLINGGREEN),
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
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  splashColor: PlunesColors
                                                                      .SPARKLINGGREEN
                                                                      .withOpacity(
                                                                          .1),
                                                                  focusColor: Colors
                                                                      .transparent,
//                                                                  focusColor: PlunesColors
//                                                                      .SPARKLINGGREEN
//                                                                      .withOpacity(
//                                                                          .2),
//                                                                  splashColor: PlunesColors
//                                                                      .SPARKLINGGREEN
//                                                                      .withOpacity(
//                                                                          .2),
//                                                                  highlightColor:
//                                                                      PlunesColors
//                                                                          .SPARKLINGGREEN
//                                                                          .withOpacity(
//                                                                              .2),
                                                                  onPressed:
                                                                      () {
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
//                                                                        padding: EdgeInsets.symmetric(
//                                                                            vertical: AppConfig.verticalBlockSize *
//                                                                                1.5,
//                                                                            horizontal: AppConfig.horizontalBlockSize *
//                                                                                6),
                                                                      child: Center(
                                                                        child:
                                                                            Text(
                                                                          'Yes',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              fontSize: AppConfig.mediumFont,
                                                                              color: PlunesColors.SPARKLINGGREEN),
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
                                            appointmentModel.appointmentTime !=
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
                                    style: TextStyle(
                                        fontSize: AppConfig.smallFont,
                                        color: Colors.red)),
                              )
                            : alreadyCancelAppointment(plunesStrings.help);
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
                    child: Text(
                        appointmentModel?.serviceName ?? PlunesStrings.NA,
                        style: TextStyle(
                            fontSize: AppConfig.smallFont,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54)),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                            (appointmentModel.service.price == null ||
                                    appointmentModel.service.price.isEmpty ||
                                    appointmentModel.service.price.first ==
                                        appointmentModel
                                            ?.service?.newPrice?.first)
                                ? ""
                                : '\u20B9 ${appointmentModel.service?.price?.first?.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: AppConfig.smallFont,
                                decoration: TextDecoration.lineThrough,
                                color: PlunesColors.GREYCOLOR)),
                        SizedBox(
                          width: AppConfig.horizontalBlockSize * 1,
                        ),
                        Text(
                          '\u20B9 ${appointmentModel?.service?.newPrice?.first}',
                          style: TextStyle(
                            fontSize: AppConfig.smallFont,
                          ),
                        ),
                      ],
                    ),
                    (appointmentModel.service == null ||
                            appointmentModel.service.discount == null ||
                            appointmentModel.service.discount == 0 ||
                            appointmentModel.service.discount < 0)
                        ? Container()
                        : Text(
                            '${appointmentModel?.service?.discount?.toStringAsFixed(2)}%',
                            style: TextStyle(color: PlunesColors.GREENCOLOR))
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
                        fontWeight: FontWeight.w500,
                      )),
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
              mainAxisAlignment: (appointmentModel.bookingStatus != null &&
                      (appointmentModel.bookingStatus ==
                              AppointmentModel.confirmedStatus ||
                          appointmentModel.bookingStatus ==
                              AppointmentModel.reservedStatus))
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: <Widget>[
                (appointmentModel.bookingStatus != null &&
                        (appointmentModel.bookingStatus ==
                                AppointmentModel.confirmedStatus ||
                            appointmentModel.bookingStatus ==
                                AppointmentModel.reservedStatus))
                    ? InkWell(
                        onTap: () {
                          if (!_isPaymentCompleted()) {
                            _showSnackBar(PlunesStrings.pleasePayFull);
                            return;
                          }
                          _bookingBloc
                              .requestInvoice(
                                  appointmentModel.bookingId, index, true)
                              .then((value) {});
                        },
                        onDoubleTap: () {},
                        child: StreamBuilder<RequestState>(
                            stream: _bookingBloc.requestInvoiceStream,
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
                                    if (req.response != null) {
                                      File file = req.response;
                                      print("file path ${file.path}");
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return CustomWidgets()
                                                .getInvoiceSuccessPopup(
                                                    globalKey: widget.globalKey,
                                                    message:
                                                        "Invoice saved successfully ${file.path}",
                                                    pdfUrl: req.additionalData
                                                        ?.toString());
                                          });
//                                      LauncherUtil.launchUrl(
//                                          file.path);
                                    }
//                                    showDialog(
//                                        context: context,
//                                        builder: (context) {
//                                          return CustomWidgets()
//                                              .requestInvoiceSuccessPopup(
//                                                  PlunesStrings
//                                                      .invoiceSuccessMessage,
//                                                  widget.globalKey);
//                                        });
//                                    widget.getAppointment();
                                  });
                                  _bookingBloc
                                      .addStateInRequestInvoiceProvider(null);
                                }
                              }
                              if (snapshot.data != null &&
                                  snapshot.data is RequestFailed) {
                                RequestFailed requestFailed = snapshot.data;
                                if (requestFailed.requestCode != null &&
                                    requestFailed.requestCode == index) {
                                  Future.delayed(Duration(milliseconds: 20))
                                      .then((value) async {
                                    _showSnackBar(requestFailed.failureCause ??
                                        PlunesStrings.unableToGenerateInvoice);
                                  });
                                  _bookingBloc
                                      .addStateInRequestInvoiceProvider(null);
                                }
                              }
                              return Text(PlunesStrings.requestInvoice,
                                  style: TextStyle(
                                    fontSize: AppConfig.smallFont,
                                    color: Colors.black54,
                                  ));
                            }),
                      )
                    : Container(),
                (appointmentModel.bookingStatus != null &&
                        (appointmentModel.bookingStatus ==
                                AppointmentModel.confirmedStatus ||
                            appointmentModel.bookingStatus ==
                                AppointmentModel.reservedStatus) &&
                        _isPaymentCompleted())
                    ? Expanded(child: Container())
                    : Container(),
                (appointmentModel.paymentStatus != null &&
                        appointmentModel.paymentStatus.isNotEmpty &&
                        !(appointmentModel.paymentStatus.first.status))
                    ? Container()
                    : (appointmentModel.refundStatus != null &&
                            appointmentModel.refundStatus ==
                                AppointmentModel.notRequested)
                        ? InkWell(
                            onTap: () {
                              showDialog(
                                      context: context,
                                      builder: (context) => CustomWidgets()
                                          .refundPopup(
                                              _bookingBloc, appointmentModel))
                                  .then((value) {
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
                              ),
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
          (_isPaymentCompleted() &&
                  (appointmentModel.bookingStatus ==
                          AppointmentModel.confirmedStatus ||
                      appointmentModel.bookingStatus ==
                          AppointmentModel.reservedStatus))
              ? Container(
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                  child: InkWell(
                    onTap: () {
                      CustomWidgets().showScrollableDialog(
                          widget.context, appointmentModel, _bookingBloc);
                    },
                    onDoubleTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            color: PlunesColors.GREENCOLOR,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              PlunesStrings.reviewYourExpr,
                              style: TextStyle(
                                  color: PlunesColors.GREENCOLOR,
                                  fontWeight: FontWeight.normal,
                                  fontSize: AppConfig.smallFont),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
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
    bool isPaymentCompleted = true;
    if (appointmentModel.dueBookingAmount != null &&
        appointmentModel.dueBookingAmount > 0) {
      isPaymentCompleted = false;
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
                  : Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 21.5),
                      child: InkWell(
                        onTap: () => _queryPayment(),
                        onDoubleTap: () {},
                        child: CustomWidgets().getRoundedButton(
                            PlunesStrings.completePaymentText,
                            18.0,
                            PlunesColors.GREENCOLOR,
                            AppConfig.horizontalBlockSize * 1.5,
                            AppConfig.horizontalBlockSize * 2.5,
                            PlunesColors.WHITECOLOR),
                      ),
                    ),
          isPaymentCompleted
              ? Container()
              : Container(
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                  child: Text(
                    "(Amount due \u20B9${appointmentModel.dueBookingAmount?.toStringAsFixed(1)})",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
          (appointmentModel.service == null ||
                  appointmentModel.service.discount == null ||
                  appointmentModel.service.discount == 0 ||
                  appointmentModel.service.discount < 0)
              ? Container()
              : Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 3,
                      horizontal: AppConfig.horizontalBlockSize * 3),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'Please make sure that you pay through app for',
                        style: TextStyle(
                            fontSize: AppConfig.verySmallFont,
                            wordSpacing: 1.5,
                            color: Colors.black87),
                        children: [
                          TextSpan(
                            text:
                                ' ${appointmentModel?.service?.discount?.toStringAsFixed(2) ?? 0}%',
                            style: TextStyle(
                                fontSize: AppConfig.verySmallFont,
                                wordSpacing: 1.5,
                                color: PlunesColors.GREENCOLOR,
                                decoration: TextDecoration.none),
                          ),
                          TextSpan(
                            text: ' discount to be valid',
                            style: TextStyle(
                                fontSize: AppConfig.verySmallFont,
                                wordSpacing: 1.5,
                                color: Colors.black87,
                                decoration: TextDecoration.none),
                          ),
                        ]),
                  )),
        ],
      ),
    );
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

  void _queryPayment({bool credits}) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => PopupChoose(
              services: Services(
                  paymentOptions: widget.appointmentModel?.paymentOptions ?? [],
                  zestMoney: widget.appointmentModel?.zestMoney ?? false),
            )).then((returnedValue) {
      if (returnedValue != null) {
//        print("selected payment percenatge $returnedValue");
        _openPaymentOption(returnedValue);
      }
    });
  }

  _openPaymentOption(PaymentSelector paymentSelector) async {
    bool zestMoney = false;
    if (paymentSelector.paymentUnit == PlunesStrings.zestMoney) {
      zestMoney = true;
    }
    var result = await _bookingBloc.payInstallment(BookingInstallment(
            bookingId: widget.appointmentModel.bookingId,
            creditsUsed: true,
            paymentPercent: zestMoney ? null : paymentSelector?.paymentUnit,
            zestMoney: zestMoney)
        .toJson());
    if (result is RequestSuccess) {
      InitPaymentResponse _initPaymentResponse = result.response;
      if (_initPaymentResponse.success) {
        if (zestMoney) {
          _processZestMoneyQueries(_initPaymentResponse);
          return;
        }
        if (_initPaymentResponse.status.contains("Confirmed")) {
          showDialog(
              context: context,
              builder: (BuildContext context) => CustomWidgets()
                  .paymentStatusPopup(
                      "Payment Success",
                      "Your Booking ID is ${_initPaymentResponse.referenceId}",
                      plunesImages.checkIcon,
                      context,
                      bookingId:
                          null)).then((value) => widget.getAppointment());
        } else {
          if (mounted)
            Navigator.of(context)
                .push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) =>
                        PaymentWebView(id: widget.appointmentModel.bookingId)))
                .then((val) {
              if (val == null) {
                _bookingBloc.cancelPayment(widget.appointmentModel.bookingId);
                return;
              }
              if (val.toString().contains("success")) {
                showDialog(
                    context: context,
                    builder: (
                      BuildContext context,
                    ) =>
                        CustomWidgets().paymentStatusPopup(
                            "Payment Success",
                            "Your Booking ID is ${_initPaymentResponse.referenceId}",
                            plunesImages.checkIcon,
                            context,
                            bookingId:
                                null)).then((value) => widget.getAppointment());
              } else if (val.toString().contains("fail")) {
                _showSnackBar("Payment Failed");
              } else if (val.toString().contains("cancel")) {
                _showSnackBar("Payment Cancelled");
              }
            });
        }
      }
    } else if (result is RequestFailed) {
      _showSnackBar(result.failureCause);
    }
  }

  void _processZestMoneyQueries(InitPaymentResponse initPaymentResponse) {
    _bookingBloc.processZestMoney(initPaymentResponse).then((value) {
      {
        if (value is RequestSuccess) {
          ZestMoneyResponseModel zestMoneyResponseModel = value.response;
          if (zestMoneyResponseModel != null &&
              zestMoneyResponseModel.success != null &&
              zestMoneyResponseModel.success &&
              zestMoneyResponseModel.data != null &&
              zestMoneyResponseModel.data.trim().isNotEmpty) {
            _openWebViewWithDynamicUrl(
                zestMoneyResponseModel, initPaymentResponse);
            return;
          } else {
            _showSnackBar(zestMoneyResponseModel?.msg);
          }
        } else if (value is RequestFailed) {
          _showSnackBar(value.failureCause);
        }
      }
    });
  }

  void _openWebViewWithDynamicUrl(ZestMoneyResponseModel zestMoneyResponseModel,
      InitPaymentResponse initPaymentResponse) {
    if (mounted)
      Navigator.of(context)
          .push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) =>
                  PaymentWebView(url: zestMoneyResponseModel.data)))
          .then((val) {
        if (val == null) {
          AnalyticsProvider().registerEvent(AnalyticsKeys.beginCheckoutKey);
          _bookingBloc.cancelPayment(initPaymentResponse.id);
          return;
        }
        if (val.toString().contains("success")) {
          AnalyticsProvider().registerEvent(AnalyticsKeys.inAppPurchaseKey);
          showDialog(
              context: context,
              builder: (
                BuildContext context,
              ) =>
                  CustomWidgets().paymentStatusPopup(
                      "Payment Success",
                      "Your Booking ID is ${initPaymentResponse.referenceId}",
                      plunesImages.checkIcon,
                      context,
                      bookingId:
                          null)).then((value) => widget.getAppointment());
        } else if (val.toString().contains("fail")) {
          _showSnackBar("Payment Failed");
        } else if (val.toString().contains("cancel")) {
          _showSnackBar("Payment Cancelled");
        }
      });
  }

  _openProfile() {
    if (widget.appointmentModel != null &&
        widget.appointmentModel.serviceProviderType != null &&
        widget.appointmentModel.serviceProviderType.isNotEmpty) {
      Widget _widget;
      if (widget.appointmentModel.serviceProviderType == Constants.doctor) {
        _widget = DocProfile(userId: widget.appointmentModel.professionalId);
      } else {
        _widget =
            HospitalProfile(userID: widget.appointmentModel.professionalId);
      }
      if (_widget != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => _widget));
      }
    }
  }

  _showSnackBar(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets().getInformativePopup(
              globalKey: widget.globalKey, message: message);
        });
  }

  bool _isPaymentCompleted() {
    bool isPaymentCompleted = true;
    if (widget.appointmentModel.dueBookingAmount != null &&
        widget.appointmentModel.dueBookingAmount > 0) {
      isPaymentCompleted = false;
    }
    return isPaymentCompleted;
  }

  Widget _getProfessionalNumber(AppointmentModel appointmentModel) {
    _profNumber = (appointmentModel.isCentre != null &&
            appointmentModel.isCentre &&
            appointmentModel.adminHosNumber != null &&
            appointmentModel.adminHosNumber.isNotEmpty)
        ? appointmentModel.adminHosNumber
        : (appointmentModel.isCentre != null &&
                appointmentModel.isCentre &&
                (appointmentModel.adminHosNumber == null ||
                    appointmentModel.alternateNumber.isNotEmpty))
            ? ""
            : appointmentModel.professionalMobileNumber ?? PlunesStrings.NA;
    String numb = "";
    if (_profNumber != null && _profNumber.isNotEmpty) {
      if (widget.appointmentModel != null &&
          widget.appointmentModel.serviceProviderType != null &&
          widget.appointmentModel.serviceProviderType.isNotEmpty) {
        if (widget.appointmentModel.serviceProviderType == Constants.doctor) {
          numb = " (Central Helpline)";
        } else if (widget.appointmentModel.serviceProviderType ==
            Constants.hospital) {
          numb = " (Central Helpline)";
        } else if (widget.appointmentModel.serviceProviderType ==
            Constants.labDiagnosticCenter) {
          numb = " (Central Helpline)";
        }
      }
    }
    return InkWell(
      onTap: () {
        if (appointmentModel.isCentre != null &&
            appointmentModel.isCentre &&
            appointmentModel.adminHosNumber != null &&
            appointmentModel.adminHosNumber.isNotEmpty) {
          LauncherUtil.launchUrl("tel://${appointmentModel.adminHosNumber}");
        } else if (appointmentModel.isCentre != null &&
            appointmentModel.isCentre &&
            (appointmentModel.adminHosNumber == null ||
                appointmentModel.alternateNumber.isEmpty)) {
          return;
        } else if (appointmentModel.professionalMobileNumber != null &&
            appointmentModel.professionalMobileNumber.isNotEmpty) {
          LauncherUtil.launchUrl(
              "tel://${appointmentModel.professionalMobileNumber}");
        }
      },
      onDoubleTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(right: 5.0, top: 5.0, bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _profNumber,
              style: TextStyle(
                  fontSize: AppConfig.mediumFont,
                  fontWeight: FontWeight.w500,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationThickness: 2.0,
                  decorationColor: PlunesColors.BLACKCOLOR),
            ),
            (appointmentModel.centreNumber != null &&
                    appointmentModel.centreNumber.isNotEmpty &&
                    _profNumber != null &&
                    _profNumber != appointmentModel.centreNumber)
                ? Text(
                    numb,
                    style: TextStyle(
                        fontSize: AppConfig.smallFont,
                        fontWeight: FontWeight.w500,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationThickness: 2.0,
                        decorationColor: PlunesColors.BLACKCOLOR),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _getCentreNumber(AppointmentModel appointmentModel) {
    return InkWell(
      onTap: () {
        if (appointmentModel.centreNumber != null &&
            appointmentModel.centreNumber.isNotEmpty) {
          LauncherUtil.launchUrl("tel://${appointmentModel.centreNumber}");
        }
      },
      onDoubleTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(right: 5.0, top: 1.0, bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              appointmentModel.centreNumber,
              style: TextStyle(
                  fontSize: AppConfig.mediumFont,
                  fontWeight: FontWeight.w500,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationThickness: 2.0,
                  decorationColor: PlunesColors.BLACKCOLOR),
            ),
            Text(
              " (Booked Centre)",
              style: TextStyle(
                  fontSize: AppConfig.smallFont,
                  fontWeight: FontWeight.w500,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationThickness: 2.0,
                  decorationColor: PlunesColors.BLACKCOLOR),
            ),
          ],
        ),
      ),
    );
  }
}
