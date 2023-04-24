class HosFacilityData {
  bool? success;
  FacilityCategoryData? data;

  HosFacilityData({this.success, this.data});

  HosFacilityData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? FacilityCategoryData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class FacilityCategoryData {
  List<ServiceCategory>? consultation;
  List<ServiceCategory>? test;
  List<ServiceCategory>? procedure;

  FacilityCategoryData({this.consultation, this.test, this.procedure});

  FacilityCategoryData.fromJson(Map<String, dynamic> json) {
    if (json['consultation'] != null) {
      consultation = [];
      json['consultation'].forEach((v) {
        consultation!.add(new ServiceCategory.fromJson(v));
      });
    }
    if (json['test'] != null) {
      test = [];
      json['test'].forEach((v) {
        test!.add(new ServiceCategory.fromJson(v));
      });
    }
    if (json['procedure'] != null) {
      procedure = [];
      json['procedure'].forEach((v) {
        procedure!.add(new ServiceCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.consultation != null) {
      data['consultation'] = this.consultation!.map((v) => v.toJson()).toList();
    }
    if (this.test != null) {
      data['test'] = this.test!.map((v) => v.toJson()).toList();
    }
    if (this.procedure != null) {
      data['procedure'] = this.procedure!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceCategory {
  String? speciality;
  String? specialityId;
  String? service;
  String? serviceName;
  String? serviceId;
  String? family;
  List<num?>? price;
  String? category;
  String? specialityImageIcon;

  ServiceCategory(
      {this.speciality,
      this.specialityId,
      this.service,
      this.serviceName,
      this.serviceId,
      this.family,
      this.price,
      this.category,
      this.specialityImageIcon});

  ServiceCategory.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'] ?? '';
    specialityId = json['specialityId'];
    service = json['service'];
    serviceName = json['serviceName'];
    serviceId = json['serviceId'] ?? '';
    family = json['family'];
    if (json['price'] != null) {
      price = [];
      json['price'].forEach((v) {
        price!.add(num.tryParse(v.toString()));
      });
    }
    category = json['category'];
    specialityImageIcon = json['specialityImageIcon'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speciality'] = this.speciality;
    data['specialityId'] = this.specialityId;
    data['service'] = this.service;
    data['serviceName'] = this.serviceName;
    data['serviceId'] = this.serviceId;
    data['family'] = this.family;
    data['category'] = this.category;
    data['specialityImageIcon'] = this.specialityImageIcon;
    return data;
  }
}
