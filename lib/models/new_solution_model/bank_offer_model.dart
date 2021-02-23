class BankOfferModel {
  bool success;
  String confirmTitle;
  String benefitDescription;
  List<BankOffer> data;

  BankOfferModel(
      {this.success, this.confirmTitle, this.benefitDescription, this.data});

  BankOfferModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    confirmTitle = json['confirmTitle'];
    benefitDescription = json['benefitDescription'];
    if (json['data'] != null) {
      data = new List<BankOffer>();
      json['data'].forEach((v) {
        data.add(new BankOffer.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['confirmTitle'] = this.confirmTitle;
    data['benefitDescription'] = this.benefitDescription;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BankOffer {
  int createdAt;
  int updateAt;
  String sId;
  String title;
  String titleImage;
  String bankOffer;
  String percentageDiscount;
  String amountLimit;
  String sectionType;
  int indexing;
  int iV;

  BankOffer(
      {this.createdAt,
      this.updateAt,
      this.sId,
      this.title,
      this.titleImage,
      this.bankOffer,
      this.percentageDiscount,
      this.amountLimit,
      this.sectionType,
      this.indexing,
      this.iV});

  BankOffer.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
    sId = json['_id'];
    title = json['title'];
    titleImage = json['titleImage'];
    bankOffer = json['bankOffer'];
    percentageDiscount = json['percentageDiscount'];
    amountLimit = json['amountLimit'];
    sectionType = json['sectionType'];
    indexing = json['indexing'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['updateAt'] = this.updateAt;
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['titleImage'] = this.titleImage;
    data['bankOffer'] = this.bankOffer;
    data['percentageDiscount'] = this.percentageDiscount;
    data['amountLimit'] = this.amountLimit;
    data['sectionType'] = this.sectionType;
    data['indexing'] = this.indexing;
    data['__v'] = this.iV;
    return data;
  }
}
