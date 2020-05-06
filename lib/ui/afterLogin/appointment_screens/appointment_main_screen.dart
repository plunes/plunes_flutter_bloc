import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/blocs/booking_blocs/appointment_bloc.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointmentScreen.dart';

import 'appointmentDocHosScreen.dart';

// ignore: must_be_immutable
class AppointmentMainScreen extends BaseActivity {
  static const tag = '/appointment';

  @override
  _AppointmentMainScreenState createState() => _AppointmentMainScreenState();
}

class _AppointmentMainScreenState extends BaseState<AppointmentMainScreen>
    with SingleTickerProviderStateMixin {
  AppointmentBloc _appointmentBloc;
  BookingBloc _bookingBloc;
  AppointmentResponseModel _appointmentResponse;
  TabController _tabController;
  String _appointmentFailureCause;
  List<AppointmentModel> _upComingAppointments;
  List<AppointmentModel> _confirmedAppointments;
  List<AppointmentModel> _cancelledAppointments;

  @override
  void initState() {
    _upComingAppointments = [];
    _confirmedAppointments = [];
    _cancelledAppointments = [];
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
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
            _appointmentFailureCause = PlunesStrings.noAppointmentAvailable;
          }
          _setDocHosSpecificData();
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
                    PlunesStrings.noAppointmentAvailable),
              )
            : (UserManager().getUserDetails().userType == Constants.generalUser)
                ? _showUserAppointmentItems()
                : _showDocHosAppointmentItem();
      },
      stream: _appointmentBloc.appointmentStream,
      initialData: RequestInProgress(),
    );
  }

  Widget _showUserAppointmentItems() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return AppointmentScreen(_appointmentResponse.bookings[index], index,
            _bookingBloc, scaffoldKey, () => _getAppointmentDetails());
//        return CustomWidgets().getAppointmentList(_appointmentResponse, index,
//            () => onTap(_appointmentResponse.bookings[index]));
      },
      itemCount: _appointmentResponse?.bookings?.length ?? 0,
    );
  }

  Widget _showDocHosAppointmentItem() {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          indicatorColor: PlunesColors.GREENCOLOR,
          indicatorWeight: 5.0,
          tabs: <Widget>[
            Tab(child: Text("Upcoming")),
            Tab(child: Text("Confirmed")),
            Tab(child: Text("Cancelled")),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _upComingAppointments.isEmpty
                  ? _emptyAppointmentView()
                  : _renderAppointmentDocHosList(_upComingAppointments),
              _confirmedAppointments.isEmpty
                  ? _emptyAppointmentView()
                  : _renderAppointmentDocHosList(_confirmedAppointments),
              _cancelledAppointments.isEmpty
                  ? _emptyAppointmentView()
                  : _renderAppointmentDocHosList(_cancelledAppointments)
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyAppointmentView() {
   return Container(
      child: Center(
        child:
        Text(PlunesStrings.noAppointmentAvailable),
      ),
    );
  }

  Widget _renderAppointmentDocHosList(List<AppointmentModel> appointmentList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          padding: (index==0)? EdgeInsets.only(top: AppConfig.verticalBlockSize*2):null,
          child: AppointmentDocHosScreen(appointmentList[index], index,
              _bookingBloc, scaffoldKey, () => _getAppointmentDetails()),
        );
      },
      itemCount: appointmentList?.length ?? 0,
    );
  }

  void _setDocHosSpecificData() {
    var today = DateTime.now();

    if (UserManager().getUserDetails().userType != Constants.generalUser) {
      if (_appointmentResponse != null &&
          _appointmentResponse.bookings != null &&
          _appointmentResponse.bookings.isNotEmpty) {
        _appointmentResponse.bookings.forEach((data) {
          _setUpcomingAppointmentList(today, data);
          _setConfirmedAppointmentList(data);
          _setCancelledAppointmentList(data);
        });
      }
    }
  }

  void _setUpcomingAppointmentList(
      DateTime now, AppointmentModel appointmentModel) {
    if (appointmentModel.appointmentTime != null &&
        appointmentModel.appointmentTime.isNotEmpty) {
      if (DateUtil.getDateFormat(now) ==
          DateUtil.getDateFormat(DateTime.fromMillisecondsSinceEpoch(
              int.parse(appointmentModel.appointmentTime)))) {
        _upComingAppointments.add(appointmentModel);
      }
    }
  }

  void _setConfirmedAppointmentList(AppointmentModel appointmentModel) {
    if (appointmentModel.bookingStatus != null &&
        appointmentModel.bookingStatus.isNotEmpty &&
        appointmentModel.bookingStatus == AppointmentModel.confirmedStatus) {
      _confirmedAppointments.add(appointmentModel);
    }
  }

  void _setCancelledAppointmentList(AppointmentModel appointmentModel) {
    if (appointmentModel.bookingStatus != null &&
        appointmentModel.bookingStatus.isNotEmpty &&
        appointmentModel.bookingStatus == AppointmentModel.cancelledStatus) {
      _cancelledAppointments.add(appointmentModel);
    }
  }

//  void onTap(AppointmentModel appointmentModel, int index) {
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//          builder: (context) => AppointmentScreen(appointmentModel, index),
//        ));
//  }

}
