class InitPaymentResponse {
  final bool? success, couponUsed;

  @override
  String toString() {
    return 'InitPaymentResponse{success: $success, message: $message, id: $id, status: $status, referenceId: $referenceId}';
  }

  final String? message;
  final String? id;
  final String? status;
  final String? referenceId;

  InitPaymentResponse(
      {this.success,
      this.message,
      this.id,
      this.referenceId,
      this.status,
      this.couponUsed});

  factory InitPaymentResponse.fromJson(Map<String, dynamic> json) {
    return InitPaymentResponse(
      success: json['success'] != null ? json['success'] : false,
      id: json["data"]['id'] != null ? json["data"]['id'] : '',
      referenceId: json["data"]['referenceId'] != null
          ? json["data"]['referenceId']
          : '',
      message: json['msg'] != null ? json['msg'] : '',
      status: json["data"]['status'] != null ? json["data"]['status'] : '',
//      couponUsed:
//          json["data"]['couponUsed'] != null ? json["data"]['couponUsed'] : '',
    );
  }
}
