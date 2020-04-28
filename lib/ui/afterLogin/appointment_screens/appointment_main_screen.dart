import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/blocs/booking_blocs/appointment_bloc.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointmentScreen.dart';

// ignore: must_be_immutable
class AppointmentMainScreen extends BaseActivity {
  static const tag = '/appointment';

  @override
  _AppointmentMainScreenState createState() => _AppointmentMainScreenState();
}

class _AppointmentMainScreenState extends BaseState<AppointmentMainScreen> {
  AppointmentBloc _appointmentBloc;
  BookingBloc _bookingBloc;
  AppointmentResponseModel _appointmentResponse;

  String _appointmentFailureCause;

  @override
  void initState() {
    _appointmentBloc = AppointmentBloc();
    _bookingBloc = BookingBloc();
    _getAppointmentDetails();
    super.initState();
  }

  _getAppointmentDetails() {
    _appointmentBloc.getAppointment();
  }

  @override
  void dispose() {
    _appointmentBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: PlunesColors.WHITECOLOR,
          appBar: widget.getAppBar(
              context, 'Appointment' ?? PlunesStrings.NA, true),
          body: Builder(builder: (context) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 3,
                  vertical: AppConfig.verticalBlockSize * 1.5),
              child: _renderAppointments(),
            );
          }),
        ));
  }

  Widget _renderAppointments() {
    return StreamBuilder<RequestState>(
      builder: (context, snapShot) {
        if (snapShot.data is RequestInProgress) {
          return CustomWidgets().getProgressIndicator();
        }
        if (snapShot.data is RequestSuccess) {
          RequestSuccess _requestSuccess = snapShot.data;
          _appointmentResponse = _requestSuccess.response;
          if (_appointmentResponse?.bookings != null &&
              _appointmentResponse.bookings.isEmpty) {
            _appointmentFailureCause =
                PlunesStrings.noActionableInsightAvailable;
          }
          _appointmentBloc.addStateInAppointmentStream(null);
        }
        if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailed = snapShot.data;
          _appointmentFailureCause = _requestFailed.failureCause;
          _appointmentBloc.addStateInAppointmentStream(null);
        }
        return (_appointmentResponse == null ||
                _appointmentResponse.bookings.isEmpty)
            ? Center(
                child: Text(_appointmentFailureCause ??
                    PlunesStrings.noActionableInsightAvailable),
              )
            : _showItems();
      },
      stream: _appointmentBloc.appointmentStream,
      initialData: RequestInProgress(),
    );
  }

  Widget _showItems() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return AppointmentScreen(_appointmentResponse.bookings[index], index, _bookingBloc, scaffoldKey);
//        return CustomWidgets().getAppointmentList(_appointmentResponse, index,
//            () => onTap(_appointmentResponse.bookings[index]));
      },
      itemCount: _appointmentResponse?.bookings?.length ?? 0,
    );
  }

//  void onTap(AppointmentModel appointmentModel, int index) {
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//          builder: (context) => AppointmentScreen(appointmentModel, index),
//        ));
//  }

}
