class InitPayment {
  String professional_id;
  String sol_id;
  String service_id;
  String time_slot;
  String appointmentTime;
  String percentage;
  int price_pos;
  int creditsUsed;
  String docHosServiceId;
  String user_id;
  String couponName;

  InitPayment(
      {this.docHosServiceId,
      this.appointmentTime,
      this.couponName,
      this.creditsUsed,
      this.percentage,
      this.price_pos,
      this.professional_id,
      this.service_id,
      this.sol_id,
      this.time_slot,
      this.user_id});

  Map<String, dynamic> initiatePaymentToJson() {
    Map<String, dynamic> body = {
      "solutionServiceId":
          sol_id + "|" + service_id + "|" + price_pos.toString(),
      "serviceId": docHosServiceId,
      "paymentPercent": percentage,
      "timeSlot": time_slot,
      "professionalId": professional_id,
      "appointmentTime": appointmentTime,
      "userId": user_id,
      "creditsUsed": creditsUsed,
      'coupon': couponName
    };
    return body;
  }
}
