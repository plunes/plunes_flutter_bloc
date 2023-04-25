import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/booking_repo/appointment_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class AppointmentBloc extends BlocBase {
  final _appointmentProvider = PublishSubject<RequestState?>();

  Stream<RequestState?> get appointmentStream =>
      _appointmentProvider.stream;

  addStateInAppointmentStream(RequestState? state) {
    super.addStateInGenericStream(_appointmentProvider, state);
  }

  @override
  void dispose() {
    _appointmentProvider?.close();
    super.dispose();
  }

  getAppointment() async {
    addStateInAppointmentStream(
        await AppointmentRepo().getAppointmentDetails());
  }
}
