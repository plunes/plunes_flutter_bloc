class InsuranceModel {
  bool success;
  int count;
  int size;
  List<InsuranceProvider> data;

  InsuranceModel({this.success, this.count, this.size, this.data});

  InsuranceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    size = json['size'];
    if (json['data'] != null) {
      data = new List<InsuranceProvider>();
      json['data'].forEach((v) {
        data.add(new InsuranceProvider.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['count'] = this.count;
    data['size'] = this.size;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InsuranceProvider {
  String sId;
  int createdAt;
  int updateAt;
  String insurancePartner;
  int iV;

  InsuranceProvider(
      {this.sId,
      this.createdAt,
      this.updateAt,
      this.insurancePartner,
      this.iV});

  InsuranceProvider.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
    insurancePartner = json['insurancePartner'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updateAt'] = this.updateAt;
    data['insurancePartner'] = this.insurancePartner;
    data['__v'] = this.iV;
    return data;
  }
}
