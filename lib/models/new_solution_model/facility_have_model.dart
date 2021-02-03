class FacilityHaveModel {
  bool success;
  List<FacilityData> data;

  FacilityHaveModel({this.success, this.data});

  FacilityHaveModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<FacilityData>();
      json['data'].forEach((v) {
        data.add(new FacilityData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FacilityData {
  int createdAt;
  int updateAt;
  String sId;
  String sectionType;
  String title;
  String titleImage;
  String subTitle;
  int indexing;

  // List<Null> description;

  FacilityData({
    this.createdAt,
    this.updateAt,
    this.sId,
    this.sectionType,
    this.title,
    this.titleImage,
    this.subTitle,
    this.indexing,
    // this.description
  });

  FacilityData.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
    sId = json['_id'];
    sectionType = json['sectionType'];
    title = json['title'];
    titleImage = json['titleImage'];
    subTitle = json['subTitle'];
    indexing = json['indexing'];
    // if (json['description'] != null) {
    //   description = new List<Null>();
    //   json['description'].forEach((v) {
    //     description.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['updateAt'] = this.updateAt;
    data['_id'] = this.sId;
    data['sectionType'] = this.sectionType;
    data['title'] = this.title;
    data['titleImage'] = this.titleImage;
    data['subTitle'] = this.subTitle;
    data['indexing'] = this.indexing;
    // if (this.description != null) {
    //   data['description'] = this.description.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}
