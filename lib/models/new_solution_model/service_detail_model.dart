class ServiceDetailModel {
  bool success;
  ServiceDetailData data;
  String message;

  ServiceDetailModel({this.success, this.data, this.message});

  ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? new ServiceDetailData.fromJson(json['data'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class ServiceDetailData {
  String speciality;
  List<ServiceDetailDataModel> services;

  ServiceDetailData({this.speciality, this.services});

  ServiceDetailData.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    if (json['services'] != null) {
      services = new List<ServiceDetailDataModel>();
      json['services'].forEach((v) {
        services.add(new ServiceDetailDataModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speciality'] = this.speciality;
    if (this.services != null) {
      data['services'] = this.services.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceDetailDataModel {
  String service;
  String speciality;
  String specialityId;
  String serviceId;
  String dnd;
  String details;
  String definitions;
  String category;
  String sittings;
  String duration;
  bool isExpanded;

  ServiceDetailDataModel(
      {this.service,
      this.speciality,
      this.specialityId,
      this.serviceId,
      this.dnd,
      this.details,
      this.definitions,
      this.category,
      this.sittings,
      this.duration,
      this.isExpanded});

  ServiceDetailDataModel.fromJson(Map<String, dynamic> json) {
    service = json['service'];
    speciality = json['speciality'];
    specialityId = json['specialityId'];
    serviceId = json['serviceId'];
    dnd = json['dnd'];
    details = json['details'];
    definitions = json['definitions'];
    category = json['category'];
    sittings = json['sittings'];
    duration = json['duration'];
    isExpanded = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service'] = this.service;
    data['speciality'] = this.speciality;
    data['specialityId'] = this.specialityId;
    data['serviceId'] = this.serviceId;
    data['dnd'] = this.dnd;
    data['details'] = this.details;
    data['definitions'] = this.definitions;
    data['category'] = this.category;
    data['sittings'] = this.sittings;
    data['duration'] = this.duration;
    return data;
  }
}
