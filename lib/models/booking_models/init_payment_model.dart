class InitPayment {
  String professional_id;
  String sol_id;
  String service_id;
  String time_slot;
  String appointmentTime;
  String percentage;
  int price_pos;
  bool creditsUsed;
  String docHosServiceId;
  String user_id;
  String couponName, bookIn;

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
      this.user_id,
      this.bookIn});

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
      'coupon': couponName,
      'bookIn': bookIn
    };
    return body;
  }
}

class BookingInstallment {
  String bookingId, paymentPercent;
  bool creditsUsed;

  BookingInstallment({this.bookingId, this.creditsUsed, this.paymentPercent});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "bookingId": this.bookingId,
      "paymentPercent": this.paymentPercent,
      "creditsUsed": this.creditsUsed
    };
  }
}
