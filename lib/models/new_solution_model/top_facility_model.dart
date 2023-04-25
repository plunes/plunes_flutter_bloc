import 'package:plunes/models/Models.dart';

class TopFacilityModel {
  bool? success;
  List<TopFacility>? data;
  String? msg;

  TopFacilityModel({this.success, this.data, this.msg});

  TopFacilityModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new TopFacility.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopFacility {
  String? professionalId;
  String? name;
  String? userType;
  String? address, locality, accreditationImage, hospitalType;
  String? imageUrl;
  String? biography;
  List<AchievementsData>? achievements;
  int? experience, doctorCount;
  double? rating, distance, dotsPositionForTopFacility = 0.0;
  List<Centre>? centres;
  List<String>? specialities, accreditationList;
  bool? insuranceAvailable;

  TopFacility(
      {this.professionalId,
      this.name,
      this.userType,
      this.address,
      this.imageUrl,
      this.biography,
      this.achievements,
      this.experience,
      this.rating,
      this.specialities,
      this.distance,
      this.centres,
      this.accreditationImage,
      this.doctorCount,
      this.locality,
      this.hospitalType,
      this.accreditationList,
      this.insuranceAvailable});

  TopFacility.fromJson(Map<String, dynamic> json) {
    double dis = 0.0;
    if (json['accreditation'] != null) {
      accreditationList = json['accreditation'].cast<String>();
    }
    insuranceAvailable = json['insuranceAvailable'];
    professionalId = json['professionalId'];
    name = json['name'];
    userType = json['userType'];
    address = json['address'];
    imageUrl = json['imageUrl'];
    biography = json['biography'];
    if (json['achievements'] != null) {
      achievements = [];
      json['achievements'].forEach((v) {
        achievements!.add(new AchievementsData.fromJson(v));
      });
    }
    centres = json['centers'] != null
        ? List.from(json['centers'].map((i) => Centre.from(i)))
        : null;
    if (json["distance"] != null &&
        json["distance"].runtimeType == dis.runtimeType) {
      distance = json["distance"];
    }
    experience = json['experience'];
    if (json['rating'] != null &&
        json['rating'].runtimeType != "".runtimeType) {
      rating = double.tryParse(json['rating'].toString());
    }
    specialities = json['specialities'].cast<String>();
    accreditationImage = json['accreditationImage'];
    doctorCount = json['doctorCount'];
    locality = json['locality'];
    hospitalType = json['hospitalType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['professionalId'] = this.professionalId;
    data['name'] = this.name;
    data['userType'] = this.userType;
    data['address'] = this.address;
    data['imageUrl'] = this.imageUrl;
    data['biography'] = this.biography;
    // if (this.achievements != null) {
    //   data['achievements'] = this.achievements.map((v) => v.toJson()).toList();
    // }
    data['experience'] = this.experience;
    data['rating'] = this.rating;
    data['specialities'] = this.specialities;
    return data;
  }
}
