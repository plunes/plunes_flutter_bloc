import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/blocs/booking_blocs/appointment_bloc.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointmentScreen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'appointmentDocHosScreen.dart';

// ignore: must_be_immutable
class AppointmentMainScreen extends BaseActivity {
  static const tag = '/appointment';
  final String bookingId;
  final bool shouldOpenReviewPopup;

  AppointmentMainScreen({this.bookingId, this.shouldOpenReviewPopup});

  @override
  _AppointmentMainScreenState createState() => _AppointmentMainScreenState();
}

class _AppointmentMainScreenState extends BaseState<AppointmentMainScreen>
    with TickerProviderStateMixin {
  AppointmentBloc _appointmentBloc;
  BookingBloc _bookingBloc;
  AppointmentResponseModel _appointmentResponse;
  TabController _tabDocHosController, _tabUserController;
  ItemScrollController _docHosUpcomingApScrollController,
      _docHosConfirmedApScrollController,
      _docHosCancelledApScrollController,
      _scrollUserConfirmedApListController,
      _scrollUserCancelledApListController;
  String _appointmentFailureCause;
  int index, _appointmentIndex;
  bool _isDisplay, _shouldOpenPopUp = false;
  List<AppointmentModel> _upComingAppointments;
  List<AppointmentModel> _confirmedDocHosAppointments;
  List<AppointmentModel> _cancelledAppointments;
  List<AppointmentModel> _confirmedUserAppointments;
  BuildContext _context;

  @override
  void initState() {
    _shouldOpenPopUp = widget.shouldOpenReviewPopup ?? false;
    _upComingAppointments = [];
    _confirmedDocHosAppointments = [];
    _cancelledAppointments = [];
    _confirmedUserAppointments = [];
    _scrollUserConfirmedApListController = ItemScrollController();
    _scrollUserCancelledApListController = ItemScrollController();
    _docHosUpcomingApScrollController = ItemScrollController();
    _docHosConfirmedApScrollController = ItemScrollController();
    _docHosCancelledApScrollController = ItemScrollController();
    _tabDocHosController =
        TabController(initialIndex: 0, length: 3, vsync: this);
    _tabUserController = TabController(initialIndex: 0, length: 2, vsync: this);
    _appointmentBloc = AppointmentBloc();
    _bookingBloc = BookingBloc();
    _isDisplay = false;
    _getAppointmentDetails();
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == FirebaseNotification.bookingScreen &&
          mounted) {
        _getAppointmentDetails();
      }
    });
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
              context, plunesStrings.appointments ?? PlunesStrings.NA, true),
          body: Builder(builder: (context) {
            _context = context;
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
          if (_appointmentResponse.bookings != null &&
              _appointmentResponse.bookings.isEmpty) {
//            _appointmentFailureCause = PlunesStrings.noAppointmentAvailable;
          }
          _upComingAppointments = [];
          _confirmedDocHosAppointments = [];
          _cancelledAppointments = [];
          _confirmedUserAppointments = [];
          _setDocHosSpecificData();
          _setUserSpecificData();
          _appointmentBloc.addStateInAppointmentStream(null);
        }
        if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailed = snapShot.data;
          _appointmentFailureCause = _requestFailed.failureCause;
          _appointmentBloc.addStateInAppointmentStream(null);
        }
        return ((_appointmentResponse == null ||
                    _appointmentResponse.bookings.isEmpty) &&
                (_appointmentFailureCause != null &&
                    _appointmentFailureCause.isNotEmpty))
            ? _emptyAppointmentView(_appointmentFailureCause ??
                PlunesStrings.noAppointmentAvailable)
            : (UserManager().getUserDetails().userType == Constants.user)
                ? _showUserAppointmentItems()
                : _showDocHosAppointmentItem();
      },
      stream: _appointmentBloc.appointmentStream,
      initialData: RequestInProgress(),
    );
  }

  Widget _showUserAppointmentItems() {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabUserController,
          indicatorColor: PlunesColors.GREENCOLOR,
          indicatorWeight: 3.0,
          tabs: <Widget>[
            Tab(
                child: Text("Confirmed",
                    style: TextStyle(
                      fontSize: AppConfig.smallFont,
                    ))),
            Tab(
                child: Text("Cancelled",
                    style: TextStyle(
                      fontSize: AppConfig.smallFont,
                    ))),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabUserController,
            children: <Widget>[
              (_confirmedUserAppointments == null ||
                      _confirmedUserAppointments.isEmpty)
                  ? _emptyAppointmentView(PlunesStrings.noConfirmedAppointments)
                  : _renderAppointmentUserList(_confirmedUserAppointments),
              (_cancelledAppointments == null || _cancelledAppointments.isEmpty)
                  ? _emptyAppointmentView(PlunesStrings.noCancelledAppointments)
                  : _renderCancelledAppointmentUserList(_cancelledAppointments)
            ],
          ),
        ),
      ],
    );
  }

  Widget _showDocHosAppointmentItem() {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabDocHosController,
          indicatorColor: PlunesColors.GREENCOLOR,
          indicatorWeight: 3.0,
          tabs: <Widget>[
            Tab(
                child: Text("Upcoming",
                    style: TextStyle(
                      fontSize: AppConfig.smallFont,
                    ))),
            Tab(
                child: Text("Confirmed",
                    style: TextStyle(
                      fontSize: AppConfig.smallFont,
                    ))),
            Tab(
                child: Text("Cancelled",
                    style: TextStyle(
                      fontSize: AppConfig.smallFont,
                    ))),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabDocHosController,
            children: <Widget>[
              (_upComingAppointments == null || _upComingAppointments.isEmpty)
                  ? _emptyAppointmentView(PlunesStrings.noNewAppointments)
                  : _renderAppointmentDocHosList(_upComingAppointments),
              (_confirmedDocHosAppointments == null ||
                      _confirmedDocHosAppointments.isEmpty)
                  ? _emptyAppointmentView(PlunesStrings.noConfirmedAppointments)
                  : _renderConfirmedAppointmentDocHosList(
                      _confirmedDocHosAppointments),
              (_cancelledAppointments == null || _cancelledAppointments.isEmpty)
                  ? _emptyAppointmentView(PlunesStrings.noCancelledAppointments)
                  : _renderCancelledAppointmentDocHosList(
                      _cancelledAppointments)
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyAppointmentView(String message) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            PlunesImages.noAppointmentImage,
            width: AppConfig.horizontalBlockSize * 20,
            height: AppConfig.verticalBlockSize * 8,
          ),
          Container(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
            child: Text(
              message,
              style: TextStyle(fontSize: AppConfig.smallFont),
            ),
          ),
        ],
      ),
    );
  }

  _renderAppointmentUserList(List<AppointmentModel> appointmentList) {
    return ScrollablePositionedList.builder(
      itemScrollController: _scrollUserConfirmedApListController,
      itemBuilder: (context, index) {
        return Container(
          padding: (index == 0)
              ? EdgeInsets.only(top: AppConfig.verticalBlockSize * 2)
              : null,
          child: AppointmentScreen(
            appointmentList[index],
            index,
            _bookingBloc,
            scaffoldKey,
            () => _getAppointmentDetails(),
            _context,
            bookingId: _isDisplay ? null : widget.bookingId,
          ),
        );
      },
      itemCount: appointmentList?.length ?? 0,
    );
  }

  _renderCancelledAppointmentUserList(List<AppointmentModel> appointmentList) {
    return ScrollablePositionedList.builder(
      itemScrollController: _scrollUserCancelledApListController,
      itemBuilder: (context, index) {
        return Container(
          padding: (index == 0)
              ? EdgeInsets.only(top: AppConfig.verticalBlockSize * 2)
              : null,
          child: AppointmentScreen(
            appointmentList[index],
            index,
            _bookingBloc,
            scaffoldKey,
            () => _getAppointmentDetails(),
            _context,
            bookingId: _isDisplay ? null : widget.bookingId,
          ),
        );
      },
      itemCount: appointmentList?.length ?? 0,
    );
  }

  Widget _renderAppointmentDocHosList(List<AppointmentModel> appointmentList) {
    return ScrollablePositionedList.builder(
      itemScrollController: _docHosUpcomingApScrollController,
      itemBuilder: (context, index) {
        return Container(
          padding: (index == 0)
              ? EdgeInsets.only(top: AppConfig.verticalBlockSize * 2)
              : null,
          child: AppointmentDocHosScreen(
            appointmentList[index],
            index,
            _bookingBloc,
            scaffoldKey,
            () => _getAppointmentDetails(),
            bookingId: _isDisplay ? null : widget.bookingId,
          ),
        );
      },
      itemCount: appointmentList?.length ?? 0,
    );
  }

  Widget _renderConfirmedAppointmentDocHosList(
      List<AppointmentModel> appointmentList) {
    return ScrollablePositionedList.builder(
      itemScrollController: _docHosConfirmedApScrollController,
      itemBuilder: (context, index) {
        return Container(
          padding: (index == 0)
              ? EdgeInsets.only(top: AppConfig.verticalBlockSize * 2)
              : null,
          child: AppointmentDocHosScreen(
            appointmentList[index],
            index,
            _bookingBloc,
            scaffoldKey,
            () => _getAppointmentDetails(),
            bookingId: _isDisplay ? null : widget.bookingId,
          ),
        );
      },
      itemCount: appointmentList?.length ?? 0,
    );
  }

  Widget _renderCancelledAppointmentDocHosList(
      List<AppointmentModel> appointmentList) {
    return ScrollablePositionedList.builder(
      itemScrollController: _docHosCancelledApScrollController,
      itemBuilder: (context, index) {
        return Container(
          padding: (index == 0)
              ? EdgeInsets.only(top: AppConfig.verticalBlockSize * 2)
              : null,
          child: AppointmentDocHosScreen(
            appointmentList[index],
            index,
            _bookingBloc,
            scaffoldKey,
            () => _getAppointmentDetails(),
            bookingId: _isDisplay ? null : widget.bookingId,
          ),
        );
      },
      itemCount: appointmentList?.length ?? 0,
    );
  }

  void _setUserSpecificData() {
    if (UserManager().getUserDetails().userType == Constants.user) {
      if (_appointmentResponse != null &&
          _appointmentResponse.bookings != null &&
          _appointmentResponse.bookings.isNotEmpty) {
        _appointmentResponse.bookings.forEach((data) {
          _setConfirmedUserAppointmentList(data);
          _setCancelledAppointmentList(data);
        });
      }
      _changeTabAfterDelayForUser();
    }
  }

  void _setDocHosSpecificData() {
    if (UserManager().getUserDetails().userType != Constants.user) {
      if (_appointmentResponse != null &&
          _appointmentResponse.bookings != null &&
          _appointmentResponse.bookings.isNotEmpty) {
        _appointmentResponse.bookings.forEach((data) {
          _setUpcomingAppointmentList(data);
          _setConfirmedDocHosAppointmentList(data);
          _setCancelledAppointmentList(data);
        });
      }
      _changeTabAfterDelay();
    }
  }

  _setTabIndex(int selectedIndex, String bookingId) {
    if (widget.bookingId != null &&
        widget.bookingId.isNotEmpty &&
        widget.bookingId == bookingId &&
        !_isDisplay) {
      index = selectedIndex;
    }
  }

  void _setUpcomingAppointmentList(AppointmentModel appointmentModel) {
    if (appointmentModel.appointmentTime != null &&
        appointmentModel.appointmentTime.isNotEmpty &&
        appointmentModel.doctorConfirmation == false &&
        (appointmentModel.bookingStatus == AppointmentModel.confirmedStatus ||
            appointmentModel.bookingStatus ==
                AppointmentModel.requestCancellation ||
            appointmentModel.bookingStatus ==
                AppointmentModel.reservedStatus)) {
      _setTabIndex(0, appointmentModel.bookingId);
      _upComingAppointments.add(appointmentModel);
    }
  }

  void _setConfirmedDocHosAppointmentList(AppointmentModel appointmentModel) {
    if (appointmentModel.bookingStatus != null &&
        appointmentModel.bookingStatus.isNotEmpty &&
        (appointmentModel.bookingStatus != AppointmentModel.cancelledStatus &&
            appointmentModel.doctorConfirmation == true)) {
      _setTabIndex(1, appointmentModel.bookingId);
      _confirmedDocHosAppointments.add(appointmentModel);
    }
  }

  void _setConfirmedUserAppointmentList(AppointmentModel appointmentModel) {
    if (appointmentModel.bookingStatus != null &&
        appointmentModel.bookingStatus.isNotEmpty &&
        appointmentModel.bookingStatus != AppointmentModel.cancelledStatus) {
      _setTabIndex(0, appointmentModel.bookingId);
      _confirmedUserAppointments.add(appointmentModel);
    }
  }

  void _setCancelledAppointmentList(AppointmentModel appointmentModel) {
    if (appointmentModel.bookingStatus != null &&
        appointmentModel.bookingStatus.isNotEmpty &&
        appointmentModel.bookingStatus == AppointmentModel.cancelledStatus) {
      if (UserManager().getUserDetails().userType == Constants.user) {
        _setTabIndex(1, appointmentModel.bookingId);
      } else if (UserManager().getUserDetails().userType != Constants.user) {
        _setTabIndex(2, appointmentModel.bookingId);
      }
      _cancelledAppointments.add(appointmentModel);
    }
  }

  void _changeTabAfterDelayForUser() async {
    if (index != null) {
      Future.delayed(Duration(milliseconds: 700)).then((value) {
        _tabUserController.animateTo(index);
        _scrollUserAppointment();
      });
    }
  }

  void _changeTabAfterDelay() async {
    if (index != null) {
      Future.delayed(Duration(milliseconds: 700)).then((value) {
        _tabDocHosController.animateTo(index);
        _scrollToAppointment();
      });
    }
  }

  void _scrollUserAppointment() {
    Future.delayed(Duration(milliseconds: 700)).then((value) {
      bool hasIndex = false;
      AppointmentModel appointmentModel =
          AppointmentModel(bookingId: widget.bookingId);
      _appointmentIndex = _confirmedUserAppointments?.indexOf(appointmentModel);
      if (_appointmentIndex != null && _appointmentIndex >= 0) {
        hasIndex = true;
        _scrollUserConfirmedApListController?.scrollTo(
            index: _appointmentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
        _removeBookingId();
        Future.delayed(Duration(milliseconds: 1500)).then((value) {
          if (_shouldOpenPopUp != null && _shouldOpenPopUp) {
            CustomWidgets().showScrollableDialog(_context,
                _confirmedUserAppointments[_appointmentIndex], _bookingBloc);
            _shouldOpenPopUp = false;
          }
        });
      }
      if ((!hasIndex) && (_appointmentIndex == null || _appointmentIndex < 0)) {
        _appointmentIndex = _cancelledAppointments?.indexOf(appointmentModel);
      }
      if ((!hasIndex) && _appointmentIndex != null && _appointmentIndex >= 0) {
        _scrollUserCancelledApListController?.scrollTo(
            index: _appointmentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
        _removeBookingId();
        Future.delayed(Duration(milliseconds: 1500)).then((value) {
          if (_shouldOpenPopUp != null && _shouldOpenPopUp) {
            CustomWidgets().showScrollableDialog(_context,
                _cancelledAppointments[_appointmentIndex], _bookingBloc);
            _shouldOpenPopUp = false;
          }
        });
      }
    });
  }

  void _scrollToAppointment() {
    Future.delayed(Duration(milliseconds: 700)).then((value) {
      bool hasIndex = false;
      AppointmentModel appointmentModel =
          AppointmentModel(bookingId: widget.bookingId);
      _appointmentIndex = _upComingAppointments?.indexOf(appointmentModel);
      if (_appointmentIndex != null && _appointmentIndex >= 0) {
        hasIndex = true;
        _docHosUpcomingApScrollController.scrollTo(
            index: _appointmentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
        _removeBookingId();
      }
      if ((!hasIndex) && (_appointmentIndex == null || _appointmentIndex < 0)) {
        _appointmentIndex =
            _confirmedDocHosAppointments?.indexOf(appointmentModel);
      }
      if ((!hasIndex) && _appointmentIndex != null && _appointmentIndex >= 0) {
        hasIndex = true;
        _docHosConfirmedApScrollController.scrollTo(
            index: _appointmentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
        _removeBookingId();
      }
      if ((!hasIndex) && (_appointmentIndex == null || _appointmentIndex < 0)) {
        _appointmentIndex = _cancelledAppointments?.indexOf(appointmentModel);
      }
      if ((!hasIndex) && _appointmentIndex != null && _appointmentIndex >= 0) {
        _docHosCancelledApScrollController.scrollTo(
            index: _appointmentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease);
        _removeBookingId();
      }
    });
  }

  void _removeBookingId() {
    Future.delayed(Duration(milliseconds: 2200)).then((value) {
      _isDisplay = true;
      Future.delayed(Duration(milliseconds: 150)).then((value) {
        _appointmentBloc.addStateInAppointmentStream(null);
      });
    });
  }
}
