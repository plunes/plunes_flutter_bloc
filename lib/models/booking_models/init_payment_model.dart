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
  String couponName,
      bookIn,
      doctorId,
      patientName,
      patientMobileNumber,
      patientAge,
      patientSex;

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
      this.bookIn,
      this.patientAge,
      this.patientMobileNumber,
      this.patientName,
      this.patientSex,
      this.doctorId});

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
      'bookIn': bookIn,
      "doctorId": doctorId,
      "patientAge": patientAge,
      "patientMobileNumber": patientMobileNumber,
      "patientName": patientName,
      "patientSex": patientSex
    };
    return body;
  }
}

class BookingInstallment {
  String bookingId, paymentPercent;
  bool creditsUsed, zestMoney;

  BookingInstallment(
      {this.bookingId, this.creditsUsed, this.paymentPercent, this.zestMoney});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "bookingId": this.bookingId,
      "paymentPercent": this.paymentPercent,
      "creditsUsed": this.creditsUsed,
      "zestMoney": this.zestMoney
    };
  }
}

class ZestMoneyResponseModel {
  bool success;
  String data;
  String msg;

  ZestMoneyResponseModel({this.success, this.data, this.msg});

  ZestMoneyResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['data'] = this.data;
    data['msg'] = this.msg;
    return data;
  }
}
