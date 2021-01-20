class KnowYourProcedureModel {
  bool success;
  int size;
  List<ProcedureData> data;
  String message;

  KnowYourProcedureModel({this.success, this.size, this.data, this.message});

  KnowYourProcedureModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    size = json['size'];
    if (json['data'] != null) {
      data = new List<ProcedureData>();
      json['data'].forEach((v) {
        data.add(new ProcedureData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['size'] = this.size;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class ProcedureData {
  List<String> signs;
  List<String> symptoms;
  List<String> testimonials;
  List<String> dnd;
  String sId;
  List<Services> services;
  String speciality;
  String specialityId;
  String familyName;
  int iV;
  String familyImage;
  String details;
  String duration;
  List<FAQ> fAQ;
  String category;
  String tags;
  String sittings;
  String defination;
  String moreInfo;

  ProcedureData(
      {this.signs,
        this.symptoms,
        this.testimonials,
        this.dnd,
        this.sId,
        this.services,
        this.speciality,
        this.specialityId,
        this.familyName,
        this.iV,
        this.familyImage,
        this.details,
        this.duration,
        this.fAQ,
        this.category,
        this.tags,
        this.sittings,
        this.defination,
        this.moreInfo});

  ProcedureData.fromJson(Map<String, dynamic> json) {
    signs = json['signs'].cast<String>();
    symptoms = json['symptoms'].cast<String>();
    testimonials = json['testimonials'].cast<String>();
    dnd = json['dnd'].cast<String>();
    sId = json['_id'];
    if (json['services'] != null) {
      services = new List<Services>();
      json['services'].forEach((v) {
        services.add(new Services.fromJson(v));
      });
    }
    speciality = json['speciality'];
    specialityId = json['specialityId'];
    familyName = json['familyName'];
    iV = json['__v'];
    familyImage = json['familyImage'];
    details = json['details'];
    duration = json['duration'];
    if (json['FAQ'] != null) {
      fAQ = new List<FAQ>();
      json['FAQ'].forEach((v) {
        fAQ.add(new FAQ.fromJson(v));
      });
    }
    category = json['category'];
    tags = json['tags'];
    sittings = json['sittings'];
    defination = json['defination'];
    moreInfo = json['more_info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['signs'] = this.signs;
    data['symptoms'] = this.symptoms;
    data['testimonials'] = this.testimonials;
    data['dnd'] = this.dnd;
    data['_id'] = this.sId;
    if (this.services != null) {
      data['services'] = this.services.map((v) => v.toJson()).toList();
    }
    data['speciality'] = this.speciality;
    data['specialityId'] = this.specialityId;
    data['familyName'] = this.familyName;
    data['__v'] = this.iV;
    data['familyImage'] = this.familyImage;
    data['details'] = this.details;
    data['duration'] = this.duration;
    if (this.fAQ != null) {
      data['FAQ'] = this.fAQ.map((v) => v.toJson()).toList();
    }
    data['category'] = this.category;
    data['tags'] = this.tags;
    data['sittings'] = this.sittings;
    data['defination'] = this.defination;
    data['more_info'] = this.moreInfo;
    return data;
  }
}

class Services {
  String sId;
  String service;
  String serviceId;

  Services({this.sId, this.service, this.serviceId});

  Services.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    service = json['service'];
    serviceId = json['serviceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['service'] = this.service;
    data['serviceId'] = this.serviceId;
    return data;
  }
}

class FAQ {
  String sId;
  String q;
  String a;

  FAQ({this.sId, this.q, this.a});

  FAQ.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    q = json['Q'];
    a = json['A'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['Q'] = this.q;
    data['A'] = this.a;
    return data;
  }
}
