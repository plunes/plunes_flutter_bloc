class MoreFacilityResponse {
  bool status;
  List<MoreFacility> data;
  String msg;

  MoreFacilityResponse({this.status, this.data, this.msg});

  MoreFacilityResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = new List<MoreFacility>();
      json['data'].forEach((v) {
        data.add(new MoreFacility.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class MoreFacility {
  String sId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoreFacility &&
          runtimeType == other.runtimeType &&
          sId == other.sId;

  @override
  int get hashCode => sId.hashCode;
  String imageUrl;
  String name;
  String userType;
  String locality;
  num distance;
  num rating;
  num experience;

  MoreFacility(
      {this.sId,
      this.imageUrl,
      this.name,
      this.userType,
      this.locality,
      this.distance,
      this.rating,
      this.experience});

  MoreFacility.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    imageUrl = json['imageUrl'];
    name = json['name'];
    userType = json['userType'];
    locality = json['locality'];
    distance = json['distance'];
    rating = json['rating'];
    experience =
        json['experience'].runtimeType is num ? json['experience'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['imageUrl'] = this.imageUrl;
    data['name'] = this.name;
    data['userType'] = this.userType;
    data['locality'] = this.locality;
    data['distance'] = this.distance;
    data['rating'] = this.rating;
    data['experience'] = this.experience;
    return data;
  }
}
