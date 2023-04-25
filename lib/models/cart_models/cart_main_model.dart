import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';

class CartOuterModel {
  bool? success;
  CartItem? data;
  int? subTotal;
  String? msg;
  num? credits;

  CartOuterModel(
      {this.success, this.data, this.subTotal, this.msg, this.credits});

  CartOuterModel.fromJson(Map<String, dynamic> json) {
    print("json $json");
    success = json['success'];
    data = json['data'] != null ? new CartItem.fromJson(json['data']) : null;
    subTotal = json['subTotal'];
    msg = json['msg'];
    credits = json['credits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['subTotal'] = this.subTotal;
    data['msg'] = this.msg;
    return data;
  }
}

class CartItem {
  List<BookingIds>? bookingIds;
  List<num>? paymentOptions;
  List<PaymentStatus>? paymentStatus;
  String? sId;
  String? userId;
  int? iV;
  String? createdAt, cartId;
  String? updatedAt;
  bool? zestMoney;

  CartItem(
      {this.bookingIds,
      this.paymentOptions,
      this.paymentStatus,
      this.sId,
      this.userId,
      this.iV,
      this.createdAt,
      this.updatedAt,
      this.zestMoney,
      this.cartId});

  CartItem.fromJson(Map<String, dynamic> json) {
    if (json['bookingIds'] != null) {
      bookingIds = [];
      json['bookingIds'].forEach((v) {
        bookingIds!.add(new BookingIds.fromJson(v));
      });
    }
    if (json['paymentOptions'] != null && json['paymentOptions'].isNotEmpty) {
      paymentOptions = json['paymentOptions'].cast<num>();
    }
    if (json['paymentProgress'] != null) {
      Iterable? _items = json['paymentProgress'];
      paymentStatus = [];
      if (_items != null && _items.isNotEmpty) {
        paymentStatus = _items
            .map((data) => PaymentStatus.fromJson(data))
            .toList(growable: true);
      }
    }
    sId = json['_id'];
    userId = json['userId'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    zestMoney = json['zestMoney'];
    cartId = json['cartId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bookingIds != null) {
      data['bookingIds'] = this.bookingIds!.map((v) => v.toJson()).toList();
    }
    data['paymentOptions'] = this.paymentOptions;
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['zestMoney'] = this.zestMoney;
    return data;
  }
}

class BookingIds {
  Service? service;
  String? sId;
  String? professionalId;
  String? appointmentTime;
  String? patientAge;
  String? patientName;
  String? patientSex;
  String? serviceName;
  bool? haveInsurance;

  BookingIds(
      {this.service,
      this.sId,
      this.professionalId,
      this.appointmentTime,
      this.patientAge,
      this.patientName,
      this.patientSex,
      this.serviceName,
      this.haveInsurance});

  BookingIds.fromJson(Map<String, dynamic> json) {
    service =
        json['service'] != null ? new Service.fromJson(json['service']) : null;
    sId = json['_id'];
    professionalId = json['professionalId'];
    appointmentTime = json['appointmentTime'];
    patientAge = json['patientAge'];
    patientName = json['patientName'];
    patientSex = json['patientSex'];
    serviceName = json['serviceName'];
    haveInsurance = json['haveInsurance'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.service != null) {
      data['service'] = this.service!.toJson();
    }
    data['_id'] = this.sId;
    data['professionalId'] = this.professionalId;
    data['appointmentTime'] = this.appointmentTime;
    data['patientAge'] = this.patientAge;
    data['patientName'] = this.patientName;
    data['patientSex'] = this.patientSex;
    data['serviceName'] = this.serviceName;
    data['haveInsurance'] = this.haveInsurance;
    return data;
  }
}

class Service {
  List<num>? newPrice;
  List<TimeSlots>? timeSlots;
  String? name, imageUrl, userType;
  double? distance;
  double? rating;
  int? expirationTimer, expiredAt;

  Service(
      {this.newPrice,
      this.timeSlots,
      this.name,
      this.distance,
      this.userType,
      this.rating,
      this.imageUrl,
      this.expirationTimer,
      this.expiredAt});

  Service.fromJson(Map<String, dynamic> json) {
    newPrice = json['newPrice'].cast<num>();
    if (json['timeSlots'] != null) {
      timeSlots = [];
      json['timeSlots'].forEach((v) {
        timeSlots!.add(new TimeSlots.fromJson(v));
      });
    }
    name = json['name'];
    distance = json['distance'];
    rating = json['rating'];
    imageUrl = json['imageUrl'];
    userType = json['userType'];
    expirationTimer = json['expirationTimer'];
    expiredAt = json['expiredAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['newPrice'] = this.newPrice;
    if (this.timeSlots != null) {
      data['timeSlots'] = this.timeSlots!.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['distance'] = this.distance;
    data['rating'] = this.rating;
    return data;
  }
}
