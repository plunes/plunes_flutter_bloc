class TestAndProcedureResponseModel {
  String sId;
  String specialityId;

  TestAndProcedureResponseModel({this.sId, this.specialityId});

  TestAndProcedureResponseModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    specialityId = json['specialityId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['specialityId'] = this.specialityId;
    return data;
  }
}
