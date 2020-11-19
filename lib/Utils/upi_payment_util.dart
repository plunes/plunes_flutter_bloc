import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:upi_pay/upi_pay.dart';

class UpiUtil {
  Future<UpiTransactionResponse> initPayment(ApplicationMeta appMetaData,
      InitPaymentResponse initPaymentResponse) async {
    final paymentResult = await UpiPay.initiateTransaction(
      amount: "",
      app: appMetaData.upiApplication,
      receiverName: "Plunes",
      receiverUpiAddress: "9816199453@okbizaxis",
      transactionRef: initPaymentResponse.referenceId,
      merchantCode: '7372',
    );
    return paymentResult;
  }
}
