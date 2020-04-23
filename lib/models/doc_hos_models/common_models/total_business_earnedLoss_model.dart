class TotalBusinessEarnedModel {
  num  businessGained;
  num businessLost;

  TotalBusinessEarnedModel({
   this.businessGained, this.businessLost
  });

  TotalBusinessEarnedModel.fromJson(Map<String, dynamic> json) {
    businessGained= json['businessGained'];
    businessLost = json['businessLost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['businessGained'] = this.businessGained;
    data['businessLost'] = this.businessLost;
    return data;
  }
}