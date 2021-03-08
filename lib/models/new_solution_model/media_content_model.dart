class MediaContentPlunes {
  bool success;
  int count;
  List<MediaData> data;
  String exploreDocTitle, exploreCustomerTitle;

  MediaContentPlunes(
      {this.success,
      this.count,
      this.data,
      this.exploreCustomerTitle,
      this.exploreDocTitle});

  MediaContentPlunes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    exploreCustomerTitle = json['exploreCustomerTitle'];
    exploreDocTitle = json['exploreDocTitle'];
    if (json['data'] != null) {
      data = new List<MediaData>();
      json['data'].forEach((v) {
        data.add(new MediaData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaData {
  String mediaType;
  String sId;
  String mediaUrl;
  String name;
  String createdAt;
  String updatedAt;
  int iV;
  String service;
  String testimonial;
  int indexing;

  MediaData(
      {this.mediaType,
      this.sId,
      this.mediaUrl,
      this.name,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.service,
      this.testimonial,
      this.indexing});

  MediaData.fromJson(Map<String, dynamic> json) {
    mediaType = json['mediaType'];
    sId = json['_id'];
    mediaUrl = json['mediaUrl'];
    name = json['name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    service = json['service'];
    testimonial = json['testimonial'];
    indexing = json['indexing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mediaType'] = this.mediaType;
    data['_id'] = this.sId;
    data['mediaUrl'] = this.mediaUrl;
    data['name'] = this.name;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['service'] = this.service;
    data['testimonial'] = this.testimonial;
    data['indexing'] = this.indexing;
    return data;
  }
}
