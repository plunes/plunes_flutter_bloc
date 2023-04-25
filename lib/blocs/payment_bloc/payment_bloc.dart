import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/payment_repo/manage_payment_repo.dart';
import 'package:plunes/requester/request_states.dart';

class ManagePaymentBloc extends BlocBase {
  Future<RequestState> getBankDetails() {
    return ManagePaymentRepo().getBankDetails();
  }

  Future<RequestState> setBankDetails(User user) {
    return ManagePaymentRepo().setBankDetails(user);
  }

  Future<RequestState> getUpiDetails(String? bookingId) {
    return ManagePaymentRepo().getUpiDetails(bookingId);
  }

  Future<RequestState> sendUpiPaymentResponse(
      String? bookingId, String status, String? txnId, String? responseCode) {
    return ManagePaymentRepo()
        .sendUpiPaymentResponse(bookingId, status, txnId, responseCode);
  }
}
