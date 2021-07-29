class FormDataModel {
  bool success;
  FormInnerData data;
  static const String bodyPartKey = "bodyPart",
      sessionGraftKey = "session_grafts";

  FormDataModel({this.success, this.data});

  FormDataModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data =
        json['data'] != null ? new FormInnerData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class FormInnerData {
  String sId;
  List<String> childrenKeys;
  List<Children> children;
  String sessionKey;
  List<String> sessions;
  String speciality;
  String family;
  String specialityId;
  String familyId;
  String technique;
  String service;
  String serviceName;
  String duration;
  String category;

  FormInnerData(
      {this.sId,
      this.childrenKeys,
      this.children,
      this.sessionKey,
      this.sessions,
      this.speciality,
      this.family,
      this.specialityId,
      this.familyId,
      this.technique,
      this.service,
      this.serviceName,
      this.duration,
      this.category});

  FormInnerData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    childrenKeys = json['childrenKeys']?.cast<String>();
    if (json['children'] != null) {
      children = new List<Children>();
      json['children'].forEach((v) {
        children.add(new Children.fromJson(v));
      });
    }
    sessionKey = json['sessionKey'];
    sessions = json['sessions']?.cast<String>();
    speciality = json['speciality'];
    family = json['family'];
    specialityId = json['specialityId'];
    familyId = json['familyId'];
    technique = json['technique'];
    service = json['service'];
    serviceName = json['serviceName'];
    duration = json['duration'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['childrenKeys'] = this.childrenKeys;
    if (this.children != null) {
      data['children'] = this.children.map((v) => v.toJson()).toList();
    }
    data['sessionKey'] = this.sessionKey;
    data['sessions'] = this.sessions;
    data['speciality'] = this.speciality;
    data['family'] = this.family;
    data['specialityId'] = this.specialityId;
    data['familyId'] = this.familyId;
    data['technique'] = this.technique;
    data['service'] = this.service;
    data['serviceName'] = this.serviceName;
    data['duration'] = this.duration;
    data['category'] = this.category;
    return data;
  }
}

class Children {
  String bodyPart;
  List<String> possibleValues;

  Children({this.bodyPart, this.possibleValues});

  Children.fromJson(Map<String, dynamic> json) {
    bodyPart = json['bodyPart'];
    possibleValues = json['possibleValues']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bodyPart'] = this.bodyPart;
    data['possibleValues'] = this.possibleValues;
    return data;
  }
}
