import 'package:plunes/models/solution_models/solution_model.dart';

class SearchedDocResults {
  bool success;
  DocHosSolution solution;
  CatalogueData catalogueData;
  String msg;

  SearchedDocResults(
      {this.success, this.solution, this.catalogueData, this.msg});

  SearchedDocResults.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    solution = (json['data'] != null && json['data']['solution'] != null)
        ? new DocHosSolution.fromJson(json['data']['solution'])
        : null;
    catalogueData = (json['data'] != null && json['data']['service'] != null)
        ? CatalogueData.fromJson(json['data']['service'])
        : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.solution != null) {
      data['solution'] = this.solution.toJson();
    }
    return data;
  }
}

class DocHosSolution {
  bool booked, showAdditionalFacilities;
  String sId;
  String serviceId;
  String userId;
  String name;
  String imageUrl;
  int createdTime, expirationTimer;
  List<Services> services;
  int iV;

  DocHosSolution(
      {this.booked,
      this.sId,
      this.serviceId,
      this.userId,
      this.name,
      this.imageUrl,
      this.createdTime,
      this.services,
      this.iV,
      this.showAdditionalFacilities,
      this.expirationTimer});

  DocHosSolution.fromJson(Map<String, dynamic> json) {
    booked = json['booked'];
    sId = json['_id'];
    serviceId = json['serviceId'];
    userId = json['userId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    createdTime = json['createdAt'];
    if (json['services'] != null) {
      services = new List<Services>();
      json['services'].forEach((v) {
        services.add(new Services.fromJson(v));
      });
    }
    iV = json['__v'];
    showAdditionalFacilities = json['showAdditionalFacilities'];
    expirationTimer = json['expirationTimer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booked'] = this.booked;
    data['_id'] = this.sId;
    data['serviceId'] = this.serviceId;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['createdAt'] = this.createdTime;
    if (this.services != null) {
      data['services'] = this.services.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    return data;
  }
}

class Services {
  List<num> price;
  List<num> newPrice;
  List<String> category;
  List<num> paymentOptions;
  List<Doctors> doctors;
  List<TimeSlots> timeSlots;

  @override
  String toString() {
    return 'Services{price: $price, newPrice: $newPrice, category: $category, paymentOptions: $paymentOptions, timeSlots: $timeSlots, sId: $sId, professionalId: $professionalId, name: $name, imageUrl: $imageUrl, discount: $discount, latitude: $latitude, longitude: $longitude, distance: $distance, homeCollection: $homeCollection, recommendation: $recommendation, bookIn: $bookIn, rating: $rating, negotiating: $negotiating}';
  }

  String userType;
  int experience;
  String sId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Services && runtimeType == other.runtimeType && sId == other.sId;

  @override
  int get hashCode => sId.hashCode;
  String professionalId;
  String name;
  String imageUrl;
  String address;
  num discount;
  num latitude;
  num longitude;
  num distance;
  bool homeCollection, isExpanded = false;
  num recommendation;
  num bookIn;
  num rating;
  bool negotiating, zestMoney;

  Services(
      {this.price,
      this.newPrice,
      this.category,
      this.timeSlots,
      this.sId,
      this.professionalId,
      this.name,
      this.imageUrl,
      this.userType,
      this.address,
      this.discount,
      this.latitude,
      this.longitude,
      this.distance,
      this.homeCollection,
      this.recommendation,
      this.bookIn,
      this.rating,
      this.negotiating,
      this.experience,
      this.paymentOptions,
      this.doctors,
      this.isExpanded = false,
      this.zestMoney});

  Services.fromJson(Map<String, dynamic> json) {
    price = json['price'].cast<num>();
    newPrice = json['newPrice']?.cast<num>();
    category = json['category']?.cast<String>();
    if (json['timeSlots'] != null) {
      timeSlots = new List<TimeSlots>();
      json['timeSlots'].forEach((v) {
        timeSlots.add(new TimeSlots.fromJson(v));
      });
    }
    if (json['doctors'] != null) {
      doctors = new List<Doctors>();
      json['doctors'].forEach((v) {
        doctors.add(new Doctors.fromJson(v));
      });
    }
    sId = json['_id'];
    professionalId = json['professionalId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    address = json['address'];
    discount = json['discount'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    distance = json['distance'];
    homeCollection = json['homeCollection'];
    recommendation = json['recommendation'];
    bookIn = json['bookIn'];
    rating = json['rating'];
    negotiating = json['negotiating'];
    userType = json['userType'];
    if (json['paymentOptions'] != null && json['paymentOptions'].isNotEmpty) {
      paymentOptions = json['paymentOptions'].cast<num>();
    }
    experience = json['experience'];
    zestMoney = json['zestMoney'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['newPrice'] = this.newPrice;
    data['category'] = this.category;
    if (this.timeSlots != null) {
      data['timeSlots'] = this.timeSlots.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    data['professionalId'] = this.professionalId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['address'] = this.address;
    data['discount'] = this.discount;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['distance'] = this.distance;
    data['homeCollection'] = this.homeCollection;
    data['recommendation'] = this.recommendation;
    data['bookIn'] = this.bookIn;
    data['rating'] = this.rating;
    data['negotiating'] = this.negotiating;
    data['paymentOptions'] = paymentOptions;
    data['experience'] = experience;
    return data;
  }
}

class TimeSlots {
  List<String> slots, slotArray;
  String day;
  bool closed;

  @override
  String toString() {
    return 'TimeSlots{slots: $slots, day: $day, closed: $closed slotArray: $slotArray}';
  }

  TimeSlots({this.slots, this.day, this.closed, this.slotArray});

  TimeSlots.fromJson(Map<String, dynamic> json) {
    slots = json['slots']?.cast<String>();
    slotArray = json['slotArray']?.cast<String>();
    day = json['day'];
    closed = json['closed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slots'] = this.slots;
    data['day'] = this.day;
    data['closed'] = this.closed;
    return data;
  }
}

class Doctors {
  String professionalId;
  String name;
  String imageUrl;
  List<num> price;
  bool homeCollection;
  num discount;
  num experience;
  List<num> newPrice;
  List<String> category;
  List<TimeSlots> timeSlots;
  bool negotiating, zestMoney;
  num bookIn;
  num rating;

  Doctors(
      {this.professionalId,
      this.name,
      this.imageUrl,
      this.price,
      this.homeCollection,
      this.discount,
      this.experience,
      this.newPrice,
      this.category,
      this.timeSlots,
      this.negotiating,
      this.rating,
      this.bookIn,
      this.zestMoney});

  Doctors.fromJson(Map<String, dynamic> json) {
    professionalId = json['professionalId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    price = json['price'].cast<num>();
    homeCollection = json['homeCollection'];
    discount = json['discount'];
    experience = json['experience'];
    newPrice = json['newPrice']?.cast<num>();
    category = json['category']?.cast<String>();
    bookIn = json['bookIn'];
    rating = json['rating'];
    negotiating = json['negotiating'];
    zestMoney = json['zestMoney'];
    if (json['timeSlots'] != null) {
      timeSlots = new List<TimeSlots>();
      json['timeSlots'].forEach((v) {
        timeSlots.add(new TimeSlots.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['professionalId'] = this.professionalId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['price'] = this.price;
    data['homeCollection'] = this.homeCollection;
    data['discount'] = this.discount;
    data['experience'] = this.experience;
    data['newPrice'] = this.newPrice;
    data['category'] = this.category;
    if (this.timeSlots != null) {
      data['timeSlots'] = this.timeSlots.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
