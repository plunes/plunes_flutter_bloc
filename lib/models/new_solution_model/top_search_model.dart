class TopSearchOuterModel {
  bool? success;
  List<TopSearchData>? data;
  String? message;

  TopSearchOuterModel({this.success, this.data, this.message});

  TopSearchOuterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new TopSearchData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class TopSearchData {
  String? sId;
  String? speciality;
  String? specialityId;
  String? serviceId;
  String? service;
  String? duration;
  String? sittings;
  List<String>? dnd;
  String? tags;
  String? definition;
  String? searchTags;
  String? category;
  int? serviceRank;
  int? iV;
  String? specializationImage;
  bool? topSearch;

  TopSearchData(
      {this.sId,
      this.speciality,
      this.specialityId,
      this.serviceId,
      this.service,
      this.duration,
      this.sittings,
      this.dnd,
      this.tags,
      this.definition,
      this.searchTags,
      this.category,
      this.serviceRank,
      this.iV,
      this.specializationImage,
      this.topSearch});

  TopSearchData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    speciality = json['speciality'];
    specialityId = json['specialityId'];
    serviceId = json['serviceId'];
    service = json['service'];
    duration = json['duration'];
    sittings = json['sittings'];
    if (json['dnd'] != null && json['dnd'].isNotEmpty) {
      dnd = [];
      json['dnd'].forEach((e) {
        if (e != null) {
          dnd!.add(e.toString());
        }
      });
    }
    // tags = json['tags'];
    definition = json['definition'];
    searchTags = json['search_tags'];
    category = json['category'];
    serviceRank = json['serviceRank'];
    iV = json['__v'];
    specializationImage = json['specializationImage'];
    topSearch = json['topSearch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['speciality'] = this.speciality;
    data['specialityId'] = this.specialityId;
    data['serviceId'] = this.serviceId;
    data['service'] = this.service;
    data['duration'] = this.duration;
    data['sittings'] = this.sittings;
    data['dnd'] = this.dnd;
    data['tags'] = this.tags;
    data['definition'] = this.definition;
    data['search_tags'] = this.searchTags;
    data['category'] = this.category;
    data['serviceRank'] = this.serviceRank;
    data['__v'] = this.iV;
    data['specializationImage'] = this.specializationImage;
    data['topSearch'] = this.topSearch;
    return data;
  }
}
