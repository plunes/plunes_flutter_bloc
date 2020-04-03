class CatalogueData {
  String service;
  String details;
  String dnd;
  String category;
  bool isSelected = false;
  String speciality;
  String specialityId;
  String serviceId;
  int iV;

  CatalogueData(
      {this.service,
      this.details,
      this.dnd,
      this.category,
      this.serviceId,
      this.specialityId,
      this.isSelected = false,
      this.iV,
      this.speciality});

  CatalogueData.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    specialityId = json['specialityId'];
    serviceId = json['serviceId'];
    service = json['service'];
    details = json['details'];
    dnd = json['dnd'];
    category = json['category'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speciality'] = this.speciality;
    data['specialityId'] = this.specialityId;
    data['serviceId'] = this.serviceId;
    data['service'] = this.service;
    data['details'] = this.details;
    data['dnd'] = this.dnd;
    data['category'] = this.category;
    data['__v'] = this.iV;
    return data;
  }
}
