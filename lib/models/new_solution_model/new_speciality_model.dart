class NewSpecialityModel {
  bool? success;
  int? size;
  List<SpecData>? data;
  String? message;

  NewSpecialityModel({this.success, this.size, this.data, this.message});

  NewSpecialityModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    size = json['size'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new SpecData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['size'] = this.size;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class SpecData {
  String? sId;
  List<Families>? families;
  String? speciality;
  String? specialityId;
  String? definition;
  String? specailizationImage, specialityIconImage;

  SpecData(
      {this.sId,
      this.families,
      this.speciality,
      this.specialityId,
      this.definition,
      this.specailizationImage,
      this.specialityIconImage});

  SpecData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['families'] != null) {
      families = [];
      json['families'].forEach((v) {
        families!.add(new Families.fromJson(v));
      });
    }
    speciality = json['speciality'];
    specialityId = json['specialityId'];
    definition = json['definition'];
    specailizationImage = json['specialityPicture'];
    specialityIconImage = json["specialityIconImageApp"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.families != null) {
      data['families'] = this.families!.map((v) => v.toJson()).toList();
    }
    data['speciality'] = this.speciality;
    data['specialityId'] = this.specialityId;
    data['definition'] = this.definition;
    data['specailizationImage'] = this.specailizationImage;
    return data;
  }
}

class Families {
  String? sId;
  String? familyId;
  String? familyName;

  Families({this.sId, this.familyId, this.familyName});

  Families.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    familyId = json['familyId'];
    familyName = json['familyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['familyId'] = this.familyId;
    data['familyName'] = this.familyName;
    return data;
  }
}
