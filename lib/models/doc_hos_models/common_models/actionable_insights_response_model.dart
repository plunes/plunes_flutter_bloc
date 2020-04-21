class ActionableInsightResponseModel {
  bool success;
  List<ActionableInsight> data;

  ActionableInsightResponseModel({this.success, this.data});

  ActionableInsightResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<ActionableInsight>();
      json['data'].forEach((v) {
        data.add(new ActionableInsight.fromJson(v));
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

class ActionableInsight {
  String serviceName;
  num percent;
  String bookingPrice;
  String userPriceVariance;
  String specialityId;
  String serviceId;
  String userPrice;

  ActionableInsight(
      {this.serviceName,
      this.percent,
      this.bookingPrice,
      this.userPriceVariance,
      this.specialityId,
      this.serviceId,
      this.userPrice});

  ActionableInsight.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName'];
    percent = json['percent'];
    bookingPrice = json['bookingPrice'];
    userPriceVariance = json['userPriceVariance'];
    specialityId = json['specialityId'];
    serviceId = json['serviceId'];
    userPrice = json['userPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceName'] = this.serviceName;
    data['percent'] = this.percent;
    data['bookingPrice'] = this.bookingPrice;
    data['userPriceVariance'] = this.userPriceVariance;
    data['specialityId'] = this.specialityId;
    data['serviceId'] = this.serviceId;
    data['userPrice'] = this.userPrice;
    return data;
  }
}
