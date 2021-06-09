import 'package:plunes/models/Models.dart';

class TopFacilityModel {
  bool success;
  List<TopFacility> data;
  String msg;

  TopFacilityModel({this.success, this.data, this.msg});

  TopFacilityModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = new List<TopFacility>();
      json['data'].forEach((v) {
        data.add(new TopFacility.fromJson(v));
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

class TopFacility {
  String professionalId;
  String name;
  String userType;
  String address;
  String imageUrl;
  String biography;
  List<AchievementsData> achievements;
  int experience;
  double rating, distance, dotsPositionForTopFacility = 0.0;

  List<String> specialities;

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
      this.distance});

  TopFacility.fromJson(Map<String, dynamic> json) {
    double dis = 0.0;
    professionalId = json['professionalId'];
    name = json['name'];
    userType = json['userType'];
    address = json['address'];
    imageUrl = json['imageUrl'];
    biography = json['biography'];
    if (json['achievements'] != null) {
      achievements = new List<AchievementsData>();
      json['achievements'].forEach((v) {
        achievements.add(new AchievementsData.fromJson(v));
      });
    }
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
