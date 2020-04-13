class PrevSearchedSolution {
  bool success;
  List<PrevSolution> data;

  PrevSearchedSolution({this.success, this.data});

  PrevSearchedSolution.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<PrevSolution>();
      json['data'].forEach((v) {
        data.add(new PrevSolution.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PrevSolution {
  String sId;
  int createdAt;
  bool booked;
  String serviceId;
  String userId;
  String name;
  String imageUrl;
  int iV;
  String serviceName;
  String serviceCategory;
  String serviceSpeciality;
  bool active;
  bool isSelected = false;

  PrevSolution(
      {this.sId,
      this.createdAt,
      this.booked,
      this.serviceId,
      this.userId,
      this.name,
      this.imageUrl,
      this.iV,
      this.serviceName,
      this.serviceCategory,
      this.serviceSpeciality,
      this.active,
      this.isSelected = false});

  PrevSolution.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    createdAt = json['createdAt'];
    booked = json['booked'];
    serviceId = json['serviceId'];
    userId = json['userId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    iV = json['__v'];
    serviceName = json['serviceName'];
    serviceCategory = json['serviceCategory'];
    serviceSpeciality = json['serviceSpeciality'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['booked'] = this.booked;
    data['serviceId'] = this.serviceId;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['__v'] = this.iV;
    data['serviceName'] = this.serviceName;
    data['serviceCategory'] = this.serviceCategory;
    data['serviceSpeciality'] = this.serviceSpeciality;
    data['active'] = this.active;
    return data;
  }
}

