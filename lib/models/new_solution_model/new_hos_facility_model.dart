class NewHosFacilityData {
  bool? success;
  List<NewServiceCategory>? data;

  NewHosFacilityData({this.success, this.data});

  NewHosFacilityData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = [];
    if(null != json['data']) {
      json['data'].forEach((element) {
        data!.add(NewServiceCategory.fromJson(element));
      });
    }
  }

}


class NewServiceCategory {
  String? specialityId;
  String? serviceId;
  List<num?>? price;
  String? specialityImageIcon;

  String? speciality;
  String? service;
  String? serviceName;
  String? family;
  String? category;

  NewServiceCategory({
    this.specialityId,
    this.serviceId,
    this.price,
    this.specialityImageIcon,

    this.speciality,
    this.service,
    this.serviceName,
    this.family,
    this.category,});

  NewServiceCategory.fromJson(Map<String, dynamic> json) {
    specialityId = json['specialityId'];
    serviceId = json['serviceId'] ?? '';
    if (json['price'] != null) {
      price = [];
      json['price'].forEach((v) {
        price!.add(num.tryParse(v.toString()));
      });
    }
    specialityImageIcon = json['specialityImageIcon'] ?? '';

    speciality = json['speciality'] ?? '';
    service = json['service'];
    serviceName = json['serviceName'];
    family = json['family'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['specialityId'] = this.specialityId;
    data['serviceId'] = this.serviceId;
    data['specialityImageIcon'] = this.specialityImageIcon;

    data['speciality'] = this.speciality;
    data['service'] = this.service;
    data['serviceName'] = this.serviceName;
    data['family'] = this.family;
    data['category'] = this.category;
    return data;
  }
}
