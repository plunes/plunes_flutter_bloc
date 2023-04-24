class WhatsappToken {
  bool? success;
  int? statusCode;
  String? status;
  TokenData? data;

  WhatsappToken({this.success, this.data, this.statusCode, this.status});

  WhatsappToken.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    status = json['status'];
    data = json['data'] != null ? TokenData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    data['status'] = this.status;
    data['data'] = this.data;
    return data;
  }
}

class TokenData {
  String? userMobile;
  String? userName;

  TokenData({this.userMobile,
    this.userName,});

  TokenData.fromJson(Map<String, dynamic> json) {
    userMobile = json['userMobile'];
    userName = json['userName'];
  }

}