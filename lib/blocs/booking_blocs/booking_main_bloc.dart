import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/repositories/booking_repo/booking_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class BookingBloc extends BlocBase {
  final _rescheduleAppointmentProvider = PublishSubject<RequestState>();

  Observable<RequestState> get rescheduleAppointmentStream =>
      _rescheduleAppointmentProvider.stream;

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

  @override
  void dispose() {
    _rescheduleAppointmentProvider?.close();
    super.dispose();
  }

  void addStateInRescheduledProvider(RequestState state) {
    addStateInGenericStream(_rescheduleAppointmentProvider, state);
  }
}
