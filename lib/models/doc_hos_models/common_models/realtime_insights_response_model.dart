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
  String serviceName, expirationMessage;
  bool negotiating, expired;
  int timeRemaining;
  num userPrice;
  int createdAt;

  @override
  String toString() {
    return 'RealInsight{solutionId: $solutionId, serviceId: $serviceId, userName: $userName, profName: $profName, centerLocation: $centerLocation, serviceName: $serviceName, expirationMessage: $expirationMessage, negotiating: $negotiating, expired: $expired, timeRemaining: $timeRemaining, userPrice: $userPrice, createdAt: $createdAt, suggested: $suggested}';
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
      this.suggested});

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
