class PremiumBenefitsModel {
  bool success;
  List<PremiumBenefitData> data;

  PremiumBenefitsModel({this.success, this.data});

  PremiumBenefitsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<PremiumBenefitData>();
      json['data'].forEach((v) {
        data.add(new PremiumBenefitData.fromJson(v));
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

class PremiumBenefitData {
  int createdAt;
  int updateAt;
  String sId;

  // List<Null> description;
  String title;
  String titleImage;
  int indexing;
  String sectionType;
  int iV;

  PremiumBenefitData(
      {this.createdAt,
      this.updateAt,
      this.sId,
      // this.description,
      this.title,
      this.titleImage,
      this.indexing,
      this.sectionType,
      this.iV});

  PremiumBenefitData.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
    sId = json['_id'];
    // if (json['description'] != null) {
    //   description = new List<Null>();
    //   json['description'].forEach((v) {
    //     description.add(new Null.fromJson(v));
    //   });
    // }
    title = json['title'];
    titleImage = json['titleImage'];
    indexing = json['indexing'];
    sectionType = json['sectionType'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['updateAt'] = this.updateAt;
    data['_id'] = this.sId;
    // if (this.description != null) {
    //   data['description'] = this.description.map((v) => v.toJson()).toList();
    // }
    data['title'] = this.title;
    data['titleImage'] = this.titleImage;
    data['indexing'] = this.indexing;
    data['sectionType'] = this.sectionType;
    data['__v'] = this.iV;
    return data;
  }
}
