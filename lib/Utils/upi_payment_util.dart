import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/models/upi_payment_model.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:upi_pay/upi_pay.dart';

class UpiUtil {
  static const String submitted = "SUBMITTED",
      success = "SUCCESS",
      failure = "FAILURE";

  Future<UpiTransactionResponse> initPayment(ApplicationMeta appMetaData,
      InitPaymentResponse initPaymentResponse, UpiModel upiResponse) async {
    final paymentResult = await UpiPay.initiateTransaction(
      amount: upiResponse.amount,
      app: appMetaData.upiApplication,
      receiverName: upiResponse.receiverName,
      receiverUpiAddress: upiResponse.receiverUpiAddress,
      transactionRef: upiResponse.bookingId,
      merchantCode: upiResponse.merchantCode,
    );
    return paymentResult;
  }

  bool isValidUpiAddress(String receiverUpiAddress) {
    //"9816199453@okbizaxis"
    bool isValidUpi = true;
    if (receiverUpiAddress == null ||
        receiverUpiAddress.trim().isEmpty ||
        !UpiPay.checkIfUpiAddressIsValid(receiverUpiAddress)) {
      isValidUpi = false;
    }
    return isValidUpi;
  }
}
