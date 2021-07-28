class CatalogueData {
  String service;
  String details;
  List<String> dnd;
  String category;
  bool isSelected = false,
      isActive,
      topSearch,
      toShowSearched,
      priceDiscovered,
      hasUserReport,
      isFromProfileScreen;
  String speciality;
  String specialityId;
  String serviceId, profId, doctorId;
  String sitting, expirationMessage, userReportId;
  String family, technique, specialityPicture, familyName;

  @override
  String toString() {
    return 'CatalogueData{service: $service, details: $details, dnd: $dnd, category: $category, isSelected: $isSelected, isActive: $isActive, speciality: $speciality, specialityId: $specialityId, serviceId: $serviceId, sitting: $sitting, duration: $duration, iV: $iV, createdAt: $createdAt, maxDiscount: $maxDiscount, isFromNotification: $isFromNotification, solutionId: $solutionId}';
  }

  String duration;
  int iV, createdAt, solutionExpiredAt;
  num maxDiscount, servicePrice;
  bool isFromNotification, booked;
  String solutionId;

  CatalogueData(
      {this.service,
      this.details,
      this.dnd,
      this.category,
      this.serviceId,
      this.specialityId,
      this.isSelected = false,
      this.priceDiscovered,
      this.iV,
      this.isActive,
      this.sitting,
      this.duration,
      this.createdAt,
      this.speciality,
      this.maxDiscount,
      this.isFromNotification,
      this.solutionId,
      this.booked,
      this.topSearch,
      this.solutionExpiredAt,
      this.toShowSearched,
      this.expirationMessage,
      this.userReportId,
      this.hasUserReport,
      this.profId,
      this.isFromProfileScreen,
      this.servicePrice,
      this.doctorId,
      this.family,
      this.technique,
      this.specialityPicture,
      this.familyName});

  CatalogueData.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    specialityId = json['specialityId'];
    serviceId = json['serviceId'];
    service = json['service'];
    details = json["definition"];
    if (json['dnd'] != null && json['dnd'].runtimeType == [].runtimeType) {
      dnd = [];
      for (var value in json['dnd']) {
        dnd.add(value?.toString());
      }
    }
    category = json['category'];
    isActive = json['active'] ?? true;
    createdAt = json['createdAt'];
    sitting = json['sittings'];
    duration = json['duration'];
    maxDiscount = json['maxDiscount'];
    solutionId = json['_id'];
    iV = json['__v'];
    booked = json['booked'];
    topSearch = json['topSearch'];
    toShowSearched = json['toShowSearched'];
    priceDiscovered = json['discoverPrice'];
    solutionExpiredAt = json["expiredAt"];
    expirationMessage = json['expirationMessage'];
    userReportId = json['userReportId'];
    hasUserReport = json['hasUserReport'];
    family = json['family'];
    technique = json['technique'];
    specialityPicture = json['specialityPicture'];
    familyName = json['familyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speciality'] = this.speciality;
    data['specialityId'] = this.specialityId;
    data['serviceId'] = this.serviceId;
    data['service'] = this.service;
    data['details'] = this.details;
    data['dnd'] = this.dnd;
    data['category'] = this.category;
    data['__v'] = this.iV;
    data['active'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['maxDiscount'] = this.maxDiscount;
    return data;
  }
}
