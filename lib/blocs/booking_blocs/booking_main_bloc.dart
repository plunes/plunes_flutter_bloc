import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/repositories/booking_repo/booking_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class BookingBloc extends BlocBase {
  final _rescheduleAppointmentProvider = PublishSubject<RequestState>();

  final _cancelAppointmentProvider = PublishSubject<RequestState>();

  final _refundAppointmentProvider = PublishSubject<RequestState>();

  // ignore: close_sinks
  final _confirmAppointmentByDocHosProvider = PublishSubject<RequestState>();
  final _installmentPaymentProvider = PublishSubject<RequestState>();

  Observable<RequestState> get rescheduleAppointmentStream =>
      _rescheduleAppointmentProvider.stream;

  Observable<RequestState> get cancelAppointmentStream =>
      _cancelAppointmentProvider.stream;

  Observable<RequestState> get refundAppointmentStream =>
      _refundAppointmentProvider.stream;

  Observable<RequestState> get confirmAppointmentByDocHosStream =>
      _confirmAppointmentByDocHosProvider.stream;

  Observable<RequestState> get installmentStream =>
      _installmentPaymentProvider.stream;

  Future<RequestState> initPayment(InitPayment initPayment) async {
    RequestState requestState = await BookingRepo().initPayment(initPayment);
    super.addIntoStream(requestState);
    return requestState;
  }

  Future rescheduleAppointment(
      String bookingId, String appointmentTime, String selectedTimeSlot) async {
    addStateInRescheduledProvider(RequestInProgress());
    var result = await BookingRepo()
        .rescheduleAppointment(bookingId, appointmentTime, selectedTimeSlot);
    addStateInRescheduledProvider(result);
    return result;
  }

  Future cancelAppointment(String bookingId, int index) async {
    addStateInCancelProvider(RequestInProgress(requestCode: index));
    var result = await BookingRepo().cancelAppointment(bookingId, index);
    addStateInCancelProvider(result);
    return result;
  }

  Future refundAppointment(String bookingId, String reason) async {
    addStateInRefundProvider(RequestInProgress());
    var result = await BookingRepo().refundAppointment(bookingId, reason);
    addStateInRefundProvider(result);
    return result;
  }

  Future confirmAppointmentByDocHos(String bookingId) async {
    addStateInConfirmProvider(RequestInProgress());
    var result = await BookingRepo().confirmAppointment(bookingId);
    addStateInConfirmProvider(result);
    return result;
  }

  Future payInstallment(Map<String, dynamic> payload) async {
    addStateInConfirmProvider(RequestInProgress());
    var result = await BookingRepo().payInstallment(payload);
    addStateInInstallmentProvider(result);
    return result;
  }

  @override
  void dispose() {
    _rescheduleAppointmentProvider?.close();
    _cancelAppointmentProvider?.close();
    _refundAppointmentProvider?.close();
    _confirmAppointmentByDocHosProvider?.close();
    _installmentPaymentProvider?.close();
    super.dispose();
  }

  void addStateInRescheduledProvider(RequestState state) {
    addStateInGenericStream(_rescheduleAppointmentProvider, state);
  }

  void addStateInCancelProvider(RequestState state) {
    addStateInGenericStream(_cancelAppointmentProvider, state);
  }

  void addStateInRefundProvider(RequestState state) {
    addStateInGenericStream(_refundAppointmentProvider, state);
  }

  void addStateInConfirmProvider(RequestState state) {
    addStateInGenericStream(_confirmAppointmentByDocHosProvider, state);
  }

  void addStateInInstallmentProvider(RequestState state) {
    addStateInGenericStream(_installmentPaymentProvider, state);
  }

  Future<RequestState> cancelPayment(String bookingId) {
    return BookingRepo().cancelPayment(bookingId);
  }
}
