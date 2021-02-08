import 'dart:convert';

class RealTimeInsightsResponse {
  bool success;
  List<RealInsight> data;
  int timer;

  RealTimeInsightsResponse({this.success, this.data, this.timer});

  RealTimeInsightsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    timer = json["timer"];
    if (json['data'] != null) {
      data = new List<RealInsight>();
      json['data'].forEach((v) {
        data.add(new RealInsight.fromJson(v));
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

class RealInsight {
  String solutionId;
  String serviceId;
  String userName;
  String profName, centerLocation;
  String serviceName, expirationMessage, imageUrl, professionalId;
  bool negotiating,
      expired,
      booked,
      professionalBooked,
      priceUpdated,
      isCardOpened;
  int timeRemaining, expirationTimer;
  num userPrice, compRate, distance, recommendation, min, max;
  int createdAt;
  List<DataPoint> dataPoints;
  final List<String> images=["","","",""];

  @override
  String toString() {
    return 'RealInsight{solutionId: $solutionId, serviceId: $serviceId, userName: $userName, profName: $profName, centerLocation: $centerLocation, serviceName: $serviceName, expirationMessage: $expirationMessage, negotiating: $negotiating, expired: $expired, timeRemaining: $timeRemaining, userPrice: $userPrice, createdAt: $createdAt, suggested: $suggested, booked: $booked, professionalBooked: $professionalBooked, dataPoints: $dataPoints, compRate: $compRate, distance: $distance, recommendation $recommendation}';
  }

  bool suggested;

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
      this.isCardOpened});

  RealInsight.fromJson(Map<String, dynamic> json) {
//    print("json insight $json");
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
        dataPoints.add(new DataPoint.fromJson(v));
      });
    }
    compRate = json['competitionRate'];
    distance = json['distance'];
    recommendation = json['recommendation'];
    min = json['min'];
    max = json['max'];
    isCardOpened = false;
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
  num x, y;

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
