class ExploreOuterModel {
  bool success;
  List<ExploreData> data;
  String msg;

  ExploreOuterModel({this.success, this.data, this.msg});

  ExploreOuterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<ExploreData>();
      json['data'].forEach((v) {
        data.add(new ExploreData.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class ExploreData {
  Section1 section1;
  Section3 section2;
  Section3 section3;
  Section3 section4;
  Section3 section5;
  String sId;

  ExploreData(
      {this.section1,
      this.section2,
      this.section3,
      this.section4,
      this.section5,
      this.sId});

  ExploreData.fromJson(Map<String, dynamic> json) {
    section1 = json['section1'] != null
        ? new Section1.fromJson(json['section1'])
        : null;
    section2 = json['section2'] != null
        ? new Section3.fromJson(json['section2'])
        : null;
    section3 = json['section3'] != null
        ? new Section3.fromJson(json['section3'])
        : null;
    section4 = json['section4'] != null
        ? new Section3.fromJson(json['section4'])
        : null;
    section5 = json['section5'] != null
        ? new Section3.fromJson(json['section5'])
        : null;
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.section1 != null) {
      data['section1'] = this.section1.toJson();
    }
    if (this.section2 != null) {
      data['section2'] = this.section2.toJson();
    }
    if (this.section3 != null) {
      data['section3'] = this.section3.toJson();
    }
    if (this.section4 != null) {
      data['section4'] = this.section4.toJson();
    }
    if (this.section5 != null) {
      data['section5'] = this.section5.toJson();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class Section1 {
  List elements;
  String heading;

  Section1({this.elements, this.heading});

  Section1.fromJson(Map<String, dynamic> json) {
    if (json['elements'] != null) {
      elements = new List<Null>();
      json['elements'].forEach((v) {
//        elements.add(new Null.fromJson(v));
      });
    }
    heading = json['heading'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.elements != null) {
      data['elements'] = this.elements.map((v) => v.toJson()).toList();
    }
    data['heading'] = this.heading;
    return data;
  }
}

class Section3 {
  String heading;
  List<Elements> elements;

  Section3({this.heading, this.elements});

  Section3.fromJson(Map<String, dynamic> json) {
    heading = json['heading'];
    if (json['elements'] != null) {
      elements = new List<Elements>();
      json['elements'].forEach((v) {
        elements.add(new Elements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['heading'] = this.heading;
    if (this.elements != null) {
      data['elements'] = this.elements.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Elements {
  String imgUrl;
  String name;
  String subHeading, serviceName;
  String subHeading1;
  String subHeading2;

  Elements(
      {this.imgUrl,
      this.name,
      this.subHeading,
      this.serviceName,
      this.subHeading1,
      this.subHeading2});

  Elements.fromJson(Map<String, dynamic> json) {
    imgUrl = json['imgUrl'];
    name = json['name'];
    subHeading = json['subHeading'];
    serviceName = json['serviceName'];
    subHeading1 = json['subHeading1'];
    subHeading2 = json['subHeading2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imgUrl'] = this.imgUrl;
    data['name'] = this.name;
    data['subHeading'] = this.subHeading;
    return data;
  }
}
