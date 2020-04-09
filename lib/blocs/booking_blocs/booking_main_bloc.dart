import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/models/booking_models/init_payment_model.dart';
import 'package:plunes/repositories/booking_repo/booking_repo.dart';
import 'package:plunes/requester/request_states.dart';

class BookingBloc extends BlocBase {
  Future<RequestState> initPayment(InitPayment initPayment) async {
    RequestState requestState = await BookingRepo().initPayment(initPayment);
    super.addIntoStream(requestState);
    return requestState;
  }
}
