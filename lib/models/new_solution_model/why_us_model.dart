class WhyUsModel {
  bool success;
  List<WhyUsInnerModel> data;

  WhyUsModel({this.success, this.data});

  WhyUsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<WhyUsInnerModel>();
      json['data'].forEach((v) {
        data.add(new WhyUsInnerModel.fromJson(v));
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

class WhyUsInnerModel {
  int createdAt;
  int updateAt;
  String sId;
  List<Description> description;
  String title;
  String titleImage;
  String sectionType;
  int indexing;
  int iV;

  WhyUsInnerModel(
      {this.createdAt,
      this.updateAt,
      this.sId,
      this.description,
      this.title,
      this.titleImage,
      this.sectionType,
      this.indexing,
      this.iV});

  WhyUsInnerModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
    sId = json['_id'];
    if (json['description'] != null) {
      description = new List<Description>();
      json['description'].forEach((v) {
        description.add(new Description.fromJson(v));
      });
    }
    title = json['title'];
    titleImage = json['titleImage'];
    sectionType = json['sectionType'];
    indexing = json['indexing'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['updateAt'] = this.updateAt;
    data['_id'] = this.sId;
    if (this.description != null) {
      data['description'] = this.description.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['titleImage'] = this.titleImage;
    data['sectionType'] = this.sectionType;
    data['indexing'] = this.indexing;
    data['__v'] = this.iV;
    return data;
  }
}

class Description {
  String sId;
  String image;
  String content;

  Description({this.sId, this.image, this.content});

  Description.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    image = json['image'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['image'] = this.image;
    data['content'] = this.content;
    return data;
  }
}

class WhyUsByIdModel {
  bool success;
  WhyUsCardArrayData data;

  WhyUsByIdModel({this.success, this.data});

  WhyUsByIdModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? new WhyUsCardArrayData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class WhyUsCardArrayData {
  int createdAt;
  int updateAt;
  String sId;
  List<Description> description;
  String title;
  String titleImage;
  String sectionType;
  int indexing;
  int iV;

  WhyUsCardArrayData(
      {this.createdAt,
      this.updateAt,
      this.sId,
      this.description,
      this.title,
      this.titleImage,
      this.sectionType,
      this.indexing,
      this.iV});

  WhyUsCardArrayData.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
    sId = json['_id'];
    if (json['description'] != null) {
      description = new List<Description>();
      json['description'].forEach((v) {
        description.add(new Description.fromJson(v));
      });
    }
    title = json['title'];
    titleImage = json['titleImage'];
    sectionType = json['sectionType'];
    indexing = json['indexing'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['updateAt'] = this.updateAt;
    data['_id'] = this.sId;
    if (this.description != null) {
      data['description'] = this.description.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['titleImage'] = this.titleImage;
    data['sectionType'] = this.sectionType;
    data['indexing'] = this.indexing;
    data['__v'] = this.iV;
    return data;
  }
}
