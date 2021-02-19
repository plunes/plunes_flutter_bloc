class MediaContentModel {
  bool success;
  MediaData data;
  String message;

  MediaContentModel({this.success, this.data, this.message});

  MediaContentModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new MediaData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class MediaData {
  String sId;
  List<VideoData> serviceVideo;
  List<VideoData> customerReviewVideo;
  List<VideoData> introductionVideo;
  List<VideoData> achievementsVideo;
  List<HosPicture> hosPictures;

  // List<Null> photos;
  String mobileNumber;
  String professionalId;
  String professionalName;
  String createdAt;
  String updatedAt;
  int iV;

  MediaData(
      {this.sId,
      this.serviceVideo,
      this.customerReviewVideo,
      this.introductionVideo,
      this.achievementsVideo,
      // this.photos,
      this.mobileNumber,
      this.professionalId,
      this.professionalName,
      this.createdAt,
      this.updatedAt,
      this.hosPictures,
      this.iV});

  MediaData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json["hospitalPhotos"] != null) {
      hosPictures = new List<HosPicture>();
      json['hospitalPhotos'].forEach((v) {
        hosPictures.add(new HosPicture.fromJson(v));
      });
    }
    if (json['serviceVideo'] != null) {
      serviceVideo = new List<VideoData>();
      json['serviceVideo'].forEach((v) {
        serviceVideo.add(new VideoData.fromJson(v));
      });
    }
    if (json['customerReviewVideo'] != null) {
      customerReviewVideo = new List<VideoData>();
      json['customerReviewVideo'].forEach((v) {
        customerReviewVideo.add(new VideoData.fromJson(v));
      });
    }
    if (json['introductionVideo'] != null) {
      introductionVideo = new List<VideoData>();
      json['introductionVideo'].forEach((v) {
        introductionVideo.add(new VideoData.fromJson(v));
      });
    }
    if (json['achievementsVideo'] != null) {
      achievementsVideo = new List<VideoData>();
      json['achievementsVideo'].forEach((v) {
        achievementsVideo.add(new VideoData.fromJson(v));
      });
    }
    // if (json['photos'] != null) {
    //   photos = new List<Null>();
    //   json['photos'].forEach((v) {
    //     photos.add(new Null.fromJson(v));
    //   });
    // }
    mobileNumber = json['mobileNumber'];
    professionalId = json['professionalId'];
    professionalName = json['professionalName'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.serviceVideo != null) {
      data['serviceVideo'] = this.serviceVideo.map((v) => v.toJson()).toList();
    }
    if (this.customerReviewVideo != null) {
      data['customerReviewVideo'] =
          this.customerReviewVideo.map((v) => v.toJson()).toList();
    }
    if (this.introductionVideo != null) {
      data['introductionVideo'] =
          this.introductionVideo.map((v) => v.toJson()).toList();
    }
    if (this.achievementsVideo != null) {
      data['achievementsVideo'] =
          this.achievementsVideo.map((v) => v.toJson()).toList();
    }
    // if (this.photos != null) {
    //   data['photos'] = this.photos.map((v) => v.toJson()).toList();
    // }
    data['mobileNumber'] = this.mobileNumber;
    data['professionalId'] = this.professionalId;
    data['professionalName'] = this.professionalName;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class VideoData {
  String sId;
  String videoUrl;
  String serviceName;

  VideoData({this.sId, this.videoUrl, this.serviceName});

  VideoData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    videoUrl = json['videoUrl'];
    serviceName = json['serviceName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['videoUrl'] = this.videoUrl;
    return data;
  }
}

class HosPicture {
  String sId;
  String imageUrl;

  HosPicture({this.sId, this.imageUrl});

  HosPicture.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
