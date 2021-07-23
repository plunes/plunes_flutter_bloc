class FacilityCollection {
  bool success;
  int size;
  List<Facility> data;

  FacilityCollection({this.success, this.size, this.data});

  FacilityCollection.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    size = json['size'];
    if (json['data'] != null) {
      data = new List<Facility>();
      json['data'].forEach((v) {
        data.add(new Facility.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['size'] = this.size;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Facility {
  String sId;
  String imageUrl;
  String name;
  String address;
  String userType;
  String locality;
  String subLocality;

  Facility(
      {this.sId,
      this.imageUrl,
      this.name,
      this.address,
      this.userType,
      this.locality,
      this.subLocality});

  Facility.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    imageUrl = json['imageUrl'];
    name = json['name'];
    address = json['address'];
    userType = json['userType'];
    locality = json['locality'];
    subLocality = json['subLocality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['imageUrl'] = this.imageUrl;
    data['name'] = this.name;
    data['address'] = this.address;
    data['userType'] = this.userType;
    data['locality'] = this.locality;
    data['subLocality'] = this.subLocality;
    return data;
  }
}
