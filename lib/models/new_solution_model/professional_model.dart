import 'package:plunes/models/Models.dart';

class ProfessionDataModel {
  bool success;
  int count;
  List<ProfData> data;

  ProfessionDataModel({this.success, this.count, this.data});

  ProfessionDataModel.fromJson(Map<String, dynamic> json) {
    success = json['succes'];
    count = json['count'];
    if (json['data'] != null) {
      data = new List<ProfData>();
      json['data'].forEach((v) {
        data.add(new ProfData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['succes'] = this.success;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProfData {
  String sId;
  String userType;
  String name;
  String address, centerLocation;
  String mobileNumber;
  String biography;
  String registrationNumber;

  // GeoLocation geoLocation;
  String email;
  String coverImageUrl;
  String professionalId;
  String imageUrl;
  Location location;
  bool isAdmin;
  bool isCenter;
  int level;
  dynamic rating;
  num experience;

  ProfData(
      {this.sId,
      this.userType,
      this.name,
      this.address,
      this.mobileNumber,
      this.biography,
      this.registrationNumber,
      // this.geoLocation,
      this.email,
      this.coverImageUrl,
      this.professionalId,
      this.imageUrl,
      this.location,
      this.isAdmin,
      this.isCenter,
      this.level,
      this.rating,
      this.experience,
      this.centerLocation});

  ProfData.fromJson(Map<String, dynamic> json) {
    if (json['centerLocation'] != null) {
      centerLocation = json['centerLocation'];
    }
    sId = json['_id'];
    userType = json['userType'];
    name = json['name'];
    address = json['address'];
    mobileNumber = json['mobileNumber'];
    biography = json['biography'];
    registrationNumber = json['registrationNumber'];
    if (json['geoLocation'] != null) {
      // geoLocation = GeoLocation.fromJson(json['geoLocation']);
    }
    email = json['email'];
    coverImageUrl = json['coverImageUrl'];
    professionalId = json['professionalId'];
    imageUrl = json['imageUrl'];
    // location = json['location'] != null
    //     ? new Location.fromJson(json['location'])
    //     : null;
    isAdmin = json['isAdmin'];
    isCenter = json['isCenter'];
    level = json['level'];
    rating = json['rating'];
    experience = json['experience'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userType'] = this.userType;
    data['name'] = this.name;
    data['address'] = this.address;
    data['mobileNumber'] = this.mobileNumber;
    data['biography'] = this.biography;
    data['registrationNumber'] = this.registrationNumber;
    // if (this.geoLocation != null) {
    //   // data['geoLocation'] = this.geoLocation.toJson();
    // }
    data['email'] = this.email;
    data['coverImageUrl'] = this.coverImageUrl;
    data['professionalId'] = this.professionalId;
    data['imageUrl'] = this.imageUrl;
    if (this.location != null) {
      data['location'] = this.location.toJson();
    }
    data['isAdmin'] = this.isAdmin;
    data['isCenter'] = this.isCenter;
    data['level'] = this.level;
    data['rating'] = this.rating;
    data['experience'] = this.experience;
    return data;
  }
}
