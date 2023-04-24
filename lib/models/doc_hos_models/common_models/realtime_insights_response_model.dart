import 'package:plunes/models/new_solution_model/medical_file_upload_response_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';

class RealTimeInsightsResponse {
  bool? success;
  List<RealInsight>? data;
  int? timer;
  String? preferredTime, maximumTime;

  RealTimeInsightsResponse({this.success, this.data, this.timer});

  RealTimeInsightsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    timer = json["timer"];
    maximumTime = json['maximumTime'];
    preferredTime = json["preferredTime"];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new RealInsight.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RealInsight {
  String? solutionId;
  String? serviceId;
  String? userName;
  String? profName, centerLocation;
  String? serviceName, expirationMessage, imageUrl, professionalId;
  bool? negotiating,
      expired,
      booked,
      professionalBooked,
      priceUpdated,
      isCardOpened,
      hasUserReport,
      isPrice;
  int? timeRemaining, expirationTimer;
  num? userPrice, compRate, distance, recommendation, min, max;
  int? createdAt, expiredAt;
  List<DataPoint>? dataPoints;
  List<Map<String, dynamic>>? specialOffers;
  String? category;
  List<ServiceChildren>? serviceChildren;

  @override
  String toString() {
    return 'RealInsight{solutionId: $solutionId, serviceId: $serviceId, userName: $userName, profName: $profName, centerLocation: $centerLocation, serviceName: $serviceName, expirationMessage: $expirationMessage, negotiating: $negotiating, expired: $expired, timeRemaining: $timeRemaining, userPrice: $userPrice, createdAt: $createdAt, suggested: $suggested, booked: $booked, professionalBooked: $professionalBooked, dataPoints: $dataPoints, compRate: $compRate, distance: $distance, recommendation $recommendation}';
  }

  bool? suggested;
  UserReport? userReport;

  RealInsight(
      {this.solutionId,
      this.serviceId,
      this.userName,
      this.profName,
      this.serviceName,
      this.negotiating,
      this.timeRemaining,
      this.expired,
      this.expirationMessage,
      this.centerLocation,
      this.userPrice,
      this.createdAt,
      this.booked,
      this.imageUrl,
      this.professionalBooked,
      this.professionalId,
      this.expirationTimer,
      this.priceUpdated,
      this.suggested,
      this.dataPoints,
      this.compRate,
      this.distance,
      this.recommendation,
      this.min,
      this.max,
      this.isCardOpened,
      this.userReport,
      this.specialOffers,
      this.category,
      this.hasUserReport,
      this.expiredAt,
      this.isPrice,
      this.serviceChildren});

  RealInsight.fromJson(Map<String, dynamic> json) {
    solutionId = json['solutionId'];
    serviceId = json['serviceId'];
    userName = json['userName'];
    profName = json['profName'];
    serviceName = json['serviceName'];
    negotiating = json['negotiating'];
    timeRemaining = json['timeRemaining'];
    userPrice = json['userPrice'];
    createdAt = json['createdAt'];
    expired = json['expired'];
    expirationMessage = json['expirationMessage'];
    suggested = json['suggested'];
    centerLocation = json['centerLocation'];
    imageUrl = json['imageUrl'];
    booked = json['booked'];
    professionalBooked = json['professionalBooked'];
    priceUpdated = json['priceUpdated'];
    expirationTimer = json['expirationTimer'];
    professionalId = json['professionalId'];
    if (json['dataPoints'] != null) {
      dataPoints = [];
      json['dataPoints'].forEach((v) {
        dataPoints!.add(new DataPoint.fromJson(v));
      });
    }
    if (json['serviceChildren'] != null) {
      serviceChildren = [];
      json['serviceChildren'].forEach((v) {
        serviceChildren!.add(new ServiceChildren.fromJson(v));
      });
    }
    compRate = json['competitionRate'];
    distance = json['distance'];
    recommendation = json['recommendation'];
    min = json['min'];
    max = json['max'];
    isCardOpened = false;
    // print("json['userReport'] ${json['userReport']}");
    if (json['userReport'] != null) {
      userReport = UserReport.fromJson(json['userReport']);
    }
    specialOffers = [];
    if (json["specialOffers"] != null && json["specialOffers"].isNotEmpty) {
      Iterable? iterable = json["specialOffers"];
      if (iterable != null && iterable.isNotEmpty) {
        iterable.forEach((element) {
          if (element != null) {
            Map<String, dynamic> mapItem = element as Map<String, dynamic>;
            if (mapItem != null && mapItem.isNotEmpty) {
              mapItem.forEach((key, value) {
                if (value != null && value.toString().trim().isNotEmpty) {
                  specialOffers!.add({key: value});
                }
              });
            }
          }
        });
      }
    }
    category = json['category'];
    hasUserReport = json['hasUserReport'];
    expiredAt = json['expiredAt'];
    isPrice = json['isPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['solutionId'] = this.solutionId;
    data['serviceId'] = this.serviceId;
    data['userName'] = this.userName;
    data['profName'] = this.profName;
    data['serviceName'] = this.serviceName;
    data['negotiating'] = this.negotiating;
    data['timeRemaining'] = this.timeRemaining;
    data['userPrice'] = this.userPrice;
    data['createdAt'] = this.createdAt;
    data['suggested'] = this.suggested;
    return data;
  }
}

class DataPoint {
//  String id;
  num? x, y;

  @override
  String toString() {
    return 'DataPoint{x: $x, y: $y}';
  }

  DataPoint({this.x, this.y});

  DataPoint.fromJson(Map<String, dynamic> json) {
//    id = json['solutionId'];
    x = json['x'];
    y = json['y'];
  }
}

class UserReport {
  String? reportType;
  bool? treatedPreviously, haveInsurance;
  String? id;
  List<String>? reportUrl, imageUrl;
  List<UploadedReportUrl>? videoUrl;
  int? createdAt;
  String? serviceId;
  String? userId;
  String? description, additionalDetails;

  UserReport(
      {this.imageUrl,
      this.serviceId,
      this.description,
      this.videoUrl,
      this.id,
      this.additionalDetails,
      this.createdAt,
      this.haveInsurance,
      this.reportType,
      this.reportUrl,
      this.treatedPreviously,
      this.userId});

  UserReport.fromJson(Map<String, dynamic> json) {
    reportType = json['reportType'];
    treatedPreviously = json['treatedPreviously'];
    haveInsurance = json['insurance'];
    id = json['_id'];
    if (json['imageUrl'] != null && json['imageUrl'].isNotEmpty) {
      imageUrl = [];
      json['imageUrl'].forEach((element) {
        if (element != null &&
            element["imageUrl"] != null &&
            element["imageUrl"].toString().isNotEmpty) {
          imageUrl!.add(element["imageUrl"].toString());
        }
      });
    }
    if (json['reportUrl'] != null && json['reportUrl'].isNotEmpty) {
      reportUrl = [];
      json['reportUrl'].forEach((element) {
        if (element != null &&
            element["reportUrl"] != null &&
            element["reportUrl"].toString().isNotEmpty) {
          reportUrl!.add(element["reportUrl"].toString());
        }
      });
    }
    if (json["videoUrl"] != null && json["videoUrl"].isNotEmpty) {
      videoUrl = [];
      json['videoUrl'].forEach((element) {
        videoUrl!.add(UploadedReportUrl.fromJson(element));
      });
    }
    createdAt = json['createdAt'];
    serviceId = json['serviceId'];
    userId = json['userId'];
    description = json['description'];
    additionalDetails = json['additionalDetails'];
  }
}

class UserReportOuterModel {
  bool? success;
  UserReportModel? data;
  String? message;

  UserReportOuterModel({this.success, this.data, this.message});

  UserReportOuterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? new UserReportModel.fromJson(json['data'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class UserReportModel {
  String? reportType;
  bool? treatedPreviously;
  bool? insurance;
  String? sId;
  List<VideoUrl>? videoUrl;
  List<ImageUrl>? imageUrl;
  List<ReportUrl>? reportUrl;
  int? createdAt;
  String? serviceId;
  String? userId;
  String? description;
  String? additionalDetails;
  int? iV;

  UserReportModel(
      {this.reportType,
      this.treatedPreviously,
      this.insurance,
      this.sId,
      this.videoUrl,
      this.imageUrl,
      this.reportUrl,
      this.createdAt,
      this.serviceId,
      this.userId,
      this.description,
      this.additionalDetails,
      this.iV});

  UserReportModel.fromJson(Map<String, dynamic> json) {
    reportType = json['reportType'];
    treatedPreviously = json['treatedPreviously'];
    insurance = json['insurance'];
    sId = json['_id'];
    if (json['videoUrl'] != null) {
      videoUrl = [];
      json['videoUrl'].forEach((v) {
        videoUrl!.add(new VideoUrl.fromJson(v));
      });
    }
    if (json['imageUrl'] != null) {
      imageUrl = [];
      json['imageUrl'].forEach((v) {
        imageUrl!.add(new ImageUrl.fromJson(v));
      });
    }
    if (json['reportUrl'] != null) {
      reportUrl = [];
      json['reportUrl'].forEach((v) {
        reportUrl!.add(new ReportUrl.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    serviceId = json['serviceId'];
    userId = json['userId'];
    description = json['description'];
    additionalDetails = json['additionalDetails'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reportType'] = this.reportType;
    data['treatedPreviously'] = this.treatedPreviously;
    data['insurance'] = this.insurance;
    data['_id'] = this.sId;
    if (this.videoUrl != null) {
      data['videoUrl'] = this.videoUrl!.map((v) => v.toJson()).toList();
    }
    if (this.imageUrl != null) {
      data['imageUrl'] = this.imageUrl!.map((v) => v.toJson()).toList();
    }
    if (this.reportUrl != null) {
      data['reportUrl'] = this.reportUrl!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['serviceId'] = this.serviceId;
    data['userId'] = this.userId;
    data['description'] = this.description;
    data['additionalDetails'] = this.additionalDetails;
    data['__v'] = this.iV;
    return data;
  }
}

class VideoUrl {
  String? sId;
  String? videoUrl;
  String? thumbnail;

  VideoUrl({this.sId, this.videoUrl, this.thumbnail});

  VideoUrl.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    videoUrl = json['videoUrl'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['videoUrl'] = this.videoUrl;
    data['thumbnail'] = this.thumbnail;
    return data;
  }
}

class ImageUrl {
  String? sId;
  String? imageUrl;

  ImageUrl({this.sId, this.imageUrl});

  ImageUrl.fromJson(Map<String, dynamic> json) {
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

class ReportUrl {
  String? sId;
  String? reportUrl;

  ReportUrl({this.sId, this.reportUrl});

  ReportUrl.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    reportUrl = json['reportUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['reportUrl'] = this.reportUrl;
    return data;
  }
}
