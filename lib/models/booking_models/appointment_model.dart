import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';

class AppointmentResponseModel {
  bool success;
  List<AppointmentModel> bookings;

  AppointmentResponseModel({
    this.success,
    this.bookings
  });

  AppointmentResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['bookings'] != null) {
      bookings = new List<AppointmentModel>();
      json['bookings'].forEach((v) {
        bookings.add(new AppointmentModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.bookings != null) {
      data['bookings'] = this.bookings.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class AppointmentModel {
  String professionalId;
  String solutionServiceId;
  String professionalName;
  String professionalAddress;
  String professionalMobileNumber;
  String professionalImageUrl;
  double latitude;
  double longitude;
  double distance;
  String serviceId;
  String bookingStatus;
  String timeSlot;
  String appointmentTime;
  String serviceName;
  bool rescheduled;
  Services service;
  bool isOpened=false;
 // List<num> paymentOption;
  String paymentPercentage;
  num amountPaid;
  num amountDue;
  String bookingId;


  AppointmentModel({
    this.professionalId,
    this.solutionServiceId,
    this.professionalName,
    this.professionalAddress,
    this.professionalMobileNumber,
    this.professionalImageUrl,
    this.latitude,
    this.longitude,
    this.distance,
    this.serviceId,
    this.bookingStatus,
    this.timeSlot,
    this.appointmentTime,
    this.serviceName,
    this.rescheduled,
    this.service,
    this.isOpened,
   // this.paymentOption,
    this.paymentPercentage,
    this.amountPaid,
    this.amountDue,
    this.bookingId,
  });


  AppointmentModel.fromJson(Map<String, dynamic> json) {
    professionalId = json['professionalId'];
    solutionServiceId = json['solutionServiceId'];
    serviceId = json['serviceId'];
    professionalName = json['professionalName'];
    professionalAddress = json['professionalAddress'];
    professionalMobileNumber = json['professionalMobileNumber'];
    professionalImageUrl = json['professionalImageUrl '];
    latitude = json['lattitude'];
    longitude = json['longitude'];
    distance = json['distance'];
    serviceId = json['serviceId'];
    bookingStatus = json['bookingStatus'];
    timeSlot = json['timeSlot'];
    appointmentTime = json['appointmentTime'];
    serviceName = json['serviceName'];
    rescheduled = json['rescheduled'];
    if (json['service'] != null) {
      service = new Services.fromJson(json['service']);
    }
   // paymentOption = json['paymentOption'];
    paymentPercentage = json['paymentPercentage'];
    amountPaid = json['amountPaid'];
    amountDue = json['amountDue'];
    bookingId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['professionalId'] = this.professionalId;
    data['solutionServiceId'] = this.solutionServiceId;
    data['serviceId'] = this.serviceId;
    data['professionalName'] = this.professionalName;
    data['professionalAddress'] = this.professionalAddress;
    data['professionalMobileNumber'] = this.professionalMobileNumber;
    data['professionalImageUrl'] = this.professionalImageUrl;
    data['lattitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['distance'] = this.distance;
    data['serviceId'] = this.serviceId;
    data['bookingStatus'] = this.bookingStatus;
    data['timeSlot'] = this.timeSlot;
    data['appointmentTime'] = this.appointmentTime;
    data['serviceName'] = this.serviceName;
    data['rescheduled'] = this.rescheduled;
    data['services'] = this.service;
   // data['paymentOption'] = this.paymentOption;
    data['paymentPercentage'] = this.paymentPercentage;
    data['amountPaid'] = this.amountPaid;
    data['amountDue'] = this.amountDue;
    data['_id'] = this.bookingId;
    return data;
  }
}


