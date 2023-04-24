class CatalogueServiceModel {
  bool? success;
  List<CatalogueServiceData>? data;

  CatalogueServiceModel({this.success, this.data});

  CatalogueServiceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new CatalogueServiceData.fromJson(v));
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

class CatalogueServiceData {
  String? specialityId;
  String? speciality;
  List<DocServiceCatalogue>? services;

  CatalogueServiceData({this.specialityId, this.speciality, this.services});

  CatalogueServiceData.fromJson(Map<String, dynamic> json) {
    specialityId = json['specialityId'];
    speciality = json['speciality'];
    if (json['services'] != null) {
      services = [];
      json['services'].forEach((v) {
        services!.add(new DocServiceCatalogue.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['specialityId'] = this.specialityId;
    data['speciality'] = this.speciality;
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DocServiceCatalogue {
  String? serviceId;
  num? price;
  num? variance;
  String? service;

  DocServiceCatalogue(
      {this.serviceId, this.price, this.variance, this.service});

  DocServiceCatalogue.fromJson(Map<String, dynamic> json) {
    serviceId = json['serviceId'];
    price = json['price'];
    variance = json['variance'];
    service = json['service'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceId'] = this.serviceId;
    data['price'] = this.price;
    data['variance'] = this.variance;
    data['service'] = this.service;
    return data;
  }
}
