class UpiModel {
  String? amount, msg;
  String? receiverName, bookingId;
  String? receiverUpiAddress;
  String? transactionRef;
  String? merchantCode;

  UpiModel(
      {this.amount,
      this.receiverName,
      this.receiverUpiAddress,
      this.transactionRef,
      this.bookingId,
      this.merchantCode});

  UpiModel.fromJson(Map<String, dynamic> json) {
    if (json["data"] != null) {
      amount = json["data"]['paymentAmount'];
      receiverName = json["data"]['merchantName'];
      receiverUpiAddress = json["data"]['merchantUpiAddress'];
      transactionRef = json["data"]['transactionRef'];
      merchantCode = json["data"]['merchantCode'];
      bookingId = json['data']['bookingId'];
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['receiverName'] = this.receiverName;
    data['receiverUpiAddress'] = this.receiverUpiAddress;
    data['transactionRef'] = this.transactionRef;
    data['merchantCode'] = this.merchantCode;
    return data;
  }
}
