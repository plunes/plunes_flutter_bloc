import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';

class AppointmentResponseModel {
  bool success;
  List<AppointmentModel> bookings;

  AppointmentResponseModel({this.success, this.bookings});

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
  String userName;
  String userAddress;
  String userMobileNumber;
  String userEmail;
  UserLocation userLocation;
  String serviceId;
  String bookingStatus;
  String timeSlot;
  String appointmentTime;
  String serviceName;
  bool rescheduled;
  Services service;
  bool isOpened = false;
  String lat, long;

  // List<num> paymentOption;
  String paymentPercent;
  num amountPaid;
  num amountDue;
  num amountPaidCredits;
  String bookingId;
  String referenceId;
  bool doctorConfirmation;
  List<PaymentStatus> paymentStatus;
  String serviceProviderType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentModel &&
          runtimeType == other.runtimeType &&
          bookingId == other.bookingId;

  @override
  int get hashCode => bookingId.hashCode;
  String refundReason;
  String refundStatus;
  bool visitAgain;
  String serviceType;
  static const String confirmedStatus = "Confirmed";
  static const String cancelledStatus = "Cancelled";
  static const String notRequested = "Not Requested";

  AppointmentModel(
      {this.professionalId,
      this.solutionServiceId,
      this.professionalName,
      this.professionalAddress,
      this.professionalMobileNumber,
      this.professionalImageUrl,
      this.userName,
      this.userAddress,
      this.userMobileNumber,
      this.userEmail,
      this.userLocation,
      this.serviceId,
      this.bookingStatus,
      this.timeSlot,
      this.appointmentTime,
      this.serviceName,
      this.rescheduled,
      this.service,
      this.isOpened,
      // this.paymentOption,
      this.paymentPercent,
      this.amountPaid,
      this.amountPaidCredits,
      this.amountDue,
      this.bookingId,
      this.refundReason,
      this.refundStatus,
      this.referenceId,
      this.doctorConfirmation,
      this.visitAgain,
      this.serviceType,
      this.paymentStatus,
      this.long,
      this.lat,
      this.serviceProviderType});

  AppointmentModel.fromJson(Map<String, dynamic> json) {
//    print("${json['location']['coordinates']}json ${json["location"]}");
    professionalId = json['professionalId'];
    solutionServiceId = json['solutionServiceId'];
    serviceId = json['serviceId'];
    professionalName = json['professionalName'];
    professionalAddress = json['professionalAddress'];
    professionalMobileNumber = json['professionalMobileNumber'];
    professionalImageUrl = json['professionalImageUrl '];
    userName = json['userName'];
    userAddress = json['userAddress'];
    userEmail = json['userEmail'];
    userMobileNumber = json['userMobileNumber'];
    userLocation = json['userLocation'] != null
        ? new UserLocation.fromJson(json['userLocation'])
        : null;
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
    paymentPercent = json['paymentPercent'];
    amountPaid = json['amountPaid'];
    amountPaidCredits = json['amountPaidCredits'];
    amountDue = json['amountDue'];
    bookingId = json['_id'];
    refundReason = json['refundReason'];
    refundStatus = json['refundStatus'];
    referenceId = json['referenceId'];
    doctorConfirmation = json['doctorConfirmation'];
    if (json['paymentProgress'] != null) {
      Iterable _items = json['paymentProgress'];
      paymentStatus = [];
      if (_items != null && _items.isNotEmpty) {
        paymentStatus = _items
            .map((data) => PaymentStatus.fromJson(data))
            .toList(growable: true);
      }
    }
    visitAgain = json['visitAgain'];
    serviceType = json['serviceType'];
    if (json['location'] != null &&
        json['location']['coordinates'] != null &&
        json['location']['coordinates'].length == 2) {
      lat = json['location']['coordinates'][1]?.toString();
      long = json['location']['coordinates'][0]?.toString();
    }
    serviceProviderType = json['serviceProviderType'];
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
    data['userAddress'] = this.userAddress;
    data['userName'] = this.userName;
    data['userEmail'] = this.userEmail;
    data['userMobileNumber'] = this.userMobileNumber;
    if (this.userLocation != null) {
      data['userLocation'] = this.userLocation.toJson();
    }
    data['serviceId'] = this.serviceId;
    data['bookingStatus'] = this.bookingStatus;
    data['timeSlot'] = this.timeSlot;
    data['appointmentTime'] = this.appointmentTime;
    data['serviceName'] = this.serviceName;
    data['rescheduled'] = this.rescheduled;
    data['services'] = this.service;
    // data['paymentOption'] = this.paymentOption;
    data['paymentPercent'] = this.paymentPercent;
    data['amountPaid'] = this.amountPaid;
    data['amountPaidCredits'] = this.amountPaidCredits;
    data['amountDue'] = this.amountDue;
    data['_id'] = this.bookingId;
    data['refundReason'] = this.refundReason;
    data['refundStatus'] = this.refundStatus;
    data['referenceId'] = this.referenceId;
    data['doctorConfirmation'] = this.doctorConfirmation;
    data['visitAgain'] = this.visitAgain;
    data['serviceType'] = this.serviceType;
    return data;
  }
}

class UserLocation {
  double latitude;
  double longitude;

  UserLocation({this.latitude, this.longitude});

  UserLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class PaymentStatus {
  String title;
  String amount;

  @override
  String toString() {
    return 'PaymentStatus{title: $title, amount: $amount, status: $status}';
  }

  bool status;

  PaymentStatus({this.title, this.amount, this.status});

  PaymentStatus.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    amount = json['amount'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['amount'] = this.amount;
    data['status'] = this.status;
    return data;
  }
}

class LocationAppBarModel {
  bool hasLocation;
  String address;

  LocationAppBarModel({this.address, this.hasLocation});
}
