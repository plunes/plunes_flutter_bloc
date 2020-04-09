class InitPaymentResponse {
  final bool success;

  @override
  String toString() {
    return 'InitPaymentResponse{success: $success, message: $message, id: $id, status: $status, referenceId: $referenceId}';
  }

  final String message;
  final String id;
  final String status;
  final String referenceId;

  InitPaymentResponse(
      {this.success, this.message, this.id, this.referenceId, this.status});

  factory InitPaymentResponse.fromJson(Map<String, dynamic> json) {
    return InitPaymentResponse(
      success: json['success'] != null ? json['success'] : false,
      id: json['id'] != null ? json['id'] : '',
      referenceId: json['referenceId'] != null ? json['referenceId'] : '',
      message: json['message'] != null ? json['message'] : '',
      status: json['status'] != null ? json['status'] : '',
    );
  }
}
