class SolutionCatalouge {
  bool status;
  List<CatalougeData> data;
  int count;
  String msg;

  SolutionCatalouge({this.status, this.data, this.count, this.msg});

  SolutionCatalouge.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = new List<CatalougeData>();
      json['data'].forEach((v) {
        data.add(new CatalougeData.fromJson(v));
      });
    }
    count = json['count'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    data['msg'] = this.msg;
    return data;
  }
}

class CatalougeData {
  String service;
  String details;
  String dnd;
  String category;
  String sId;
  bool isSelected = false;

  CatalougeData(
      {this.service,
      this.details,
      this.dnd,
      this.category,
      this.sId,
      this.isSelected = false});

  CatalougeData.fromJson(Map<String, dynamic> json) {
    service = json['service'];
    details = json['details'];
    dnd = json['dnd'];
    category = json['category'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service'] = this.service;
    data['details'] = this.details;
    data['dnd'] = this.dnd;
    data['category'] = this.category;
    data['_id'] = this.sId;
    return data;
  }
}
