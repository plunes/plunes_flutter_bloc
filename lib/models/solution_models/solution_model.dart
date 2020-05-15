class CatalogueData {
  String service;
  String details;
  String dnd;
  String category;
  bool isSelected = false, isActive;
  String speciality;
  String specialityId;
  String serviceId;
  String sitting;
  String duration;
  int iV, createdAt;
  num maxDiscount;
  bool isFromNotification;
  String solutionId;

  CatalogueData(
      {this.service,
      this.details,
      this.dnd,
      this.category,
      this.serviceId,
      this.specialityId,
      this.isSelected = false,
      this.iV,
      this.isActive,
      this.sitting,
      this.duration,
      this.createdAt,
      this.speciality,
      this.maxDiscount,
      this.isFromNotification,
      this.solutionId});

  CatalogueData.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    specialityId = json['specialityId'];
    serviceId = json['serviceId'];
    service = json['service'];
    details = json['details'];
    dnd = json['dnd'];
    category = json['category'];
    isActive = json['active'] ?? true;
    createdAt = json['createdAt'];
//    sitting = json['sitting'];
//    duration = json['duration'];
    maxDiscount = json['maxDiscount'];
    solutionId = json['_id'];
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
    data['active'] = this.isActive;
    data['createdAt'] = this.createdAt;
//    data['sitting'] = this.sitting;
//    data['duration'] = this.duration;
    data['maxDiscount'] = this.maxDiscount;
    return data;
  }
}
