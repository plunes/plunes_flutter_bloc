class SearchedDocResults {
  bool success;
  DocHosSolution solution;

  SearchedDocResults({this.success, this.solution});

  SearchedDocResults.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    solution = json['solution'] != null
        ? new DocHosSolution.fromJson(json['solution'])
        : null;
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
  bool booked;
  String sId;
  String serviceId;
  String userId;
  String name;
  String imageUrl;
  int createdTime;
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
      this.iV});

  DocHosSolution.fromJson(Map<String, dynamic> json) {
    booked = json['booked'];
    sId = json['_id'];
    serviceId = json['serviceId'];
    userId = json['userId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    createdTime = json['createdTime'];
    if (json['services'] != null) {
      services = new List<Services>();
      json['services'].forEach((v) {
        services.add(new Services.fromJson(v));
      });
    }
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booked'] = this.booked;
    data['_id'] = this.sId;
    data['serviceId'] = this.serviceId;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['createdTime'] = this.createdTime;
    if (this.services != null) {
      data['services'] = this.services.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    return data;
  }
}

class Services {
  List<int> price;
  List<int> newPrice;
  List<String> category;
  List<TimeSlots> timeSlots;
  String sId;
  String professionalId;
  String name;
  String imageUrl;
  num discount;
  double latitude;
  double longitude;
  num distance;
  bool homeCollection;
  num recommendation;
  num bookIn;
  num rating;
  bool negotiating;

  Services(
      {this.price,
      this.newPrice,
      this.category,
      this.timeSlots,
      this.sId,
      this.professionalId,
      this.name,
      this.imageUrl,
      this.discount,
      this.latitude,
      this.longitude,
      this.distance,
      this.homeCollection,
      this.recommendation,
      this.bookIn,
      this.rating,
      this.negotiating});

  Services.fromJson(Map<String, dynamic> json) {
    price = json['price'].cast<int>();
    newPrice = json['newPrice'].cast<int>();
    category = json['category'].cast<String>();
    if (json['timeSlots'] != null) {
      timeSlots = new List<TimeSlots>();
      json['timeSlots'].forEach((v) {
        timeSlots.add(new TimeSlots.fromJson(v));
      });
    }
    sId = json['_id'];
    professionalId = json['professionalId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    discount = json['discount'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    distance = json['distance'];
    homeCollection = json['homeCollection'];
    recommendation = json['recommendation'];
    bookIn = json['bookIn'];
    rating = json['rating'];
    negotiating = json['negotiating'];
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
    data['discount'] = this.discount;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['distance'] = this.distance;
    data['homeCollection'] = this.homeCollection;
    data['recommendation'] = this.recommendation;
    data['bookIn'] = this.bookIn;
    data['rating'] = this.rating;
    data['negotiating'] = this.negotiating;
    return data;
  }
}

class TimeSlots {
  List<String> slots;
  String day;
  bool closed;

  @override
  String toString() {
    return 'TimeSlots{slots: $slots, day: $day, closed: $closed}';
  }

  TimeSlots({this.slots, this.day, this.closed});

  TimeSlots.fromJson(Map<String, dynamic> json) {
    slots = json['slots'].cast<String>();
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
