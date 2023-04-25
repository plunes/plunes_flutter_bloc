class TotalBusinessEarnedModel {
  num? businessGained;
  num? businessLost;

  TotalBusinessEarnedModel({this.businessGained, this.businessLost});

  TotalBusinessEarnedModel.fromJson(Map<String, dynamic>? json) {
    if (json != null && json["data"] != null) {
      businessGained = json["data"]['businessGained'];
      businessLost = json["data"]['businessLost'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['businessGained'] = this.businessGained;
    data['businessLost'] = this.businessLost;
    return data;
  }
}
