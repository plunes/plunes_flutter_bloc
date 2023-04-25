class CommonModel {
  bool? success;
  String? msg;

  CommonModel(this.success, this.msg);

  CommonModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
  }

}