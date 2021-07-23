import 'dart:io';

import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';

class CatalogueList {
  final List<ProcedureList> posts;
  final bool empty;

  CatalogueList({this.posts, this.empty});

  factory CatalogueList.fromJson(List<dynamic> parsedJson) {
    List<ProcedureList> posts = new List<ProcedureList>();
    if (parsedJson != null)
      posts = List<ProcedureList>.from(
          parsedJson.map((i) => ProcedureList.fromJson(i)));
    return new CatalogueList(posts: posts);
  }
}

class ProcedureList {
  List<_Services> _services = [];
  String _speciality, _id;

  List<_Services> get services => _services;

  get speciality => _speciality;

  get id => _id;

  ProcedureList.fromJson(Map<String, dynamic> json) {
    _id = json['_id'] != null ? json['_id'] : '';
    _speciality = json['speciality'] != null ? json['speciality'] : '';

    List<_Services> temp = [];
    for (int i = 0; i < json['services'].length; i++) {
      temp.add(_Services(json['services'][i]));
    }
    _services = temp;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._id;
    data['speciality'] = this.speciality;
    if (this.services != null && this.services.isNotEmpty) {
      data['services'] = <_Services>[];
    }
    return data;
  }
}

class _Services {
  String _id, _service, _details, _category, _description;
  List _categoriesArray;
  List<num> _nums = [];
  num price;

  get id => _id;

  get service => _service;

  get details => _details;

  get category => _category;

  get description => _description;

  _Services(result) {
    _id = result['serviceId'] != null ? result['serviceId'] : '';
    _service = result['service'] != null ? result['service'] : '';
    _details = result['details'] != null ? result['details'] : '';
    if (result['category'] != null && result['category'] is String) {
      _category = result['category'] != null ? result['category'] : '';
    } else if (result['category'] != null && result['category'] is List) {
      _categoriesArray =
      (result['category'] != null && result['category'].isNotEmpty)
          ? result['category']
          : [];
    }
    _description = result['dnd'] != null ? result['dnd'] : '';
    if (result["price"] != null) {
      try {
        _nums = result["price"].cast<num>();
        if (_nums != null && _nums.isNotEmpty) {
          price = _nums.first;
        }
      } catch (e) {
        price = 0;
      }
    }
  }
}

class LoginPost {
  final bool success;
  final String message;
  final String token;
  User user;

  LoginPost({this.success, this.token, this.user, this.message});

  factory LoginPost.fromJson(Map<String, dynamic> json) {
    if (json != null && json['success'] != null && json['success']) {
      return LoginPost(
          success: json['success'] != null ? json['success'] : false,
          message: json['message'] != null ? json['message'] : '',
          token: json['token'] != null ? json['token'] : '',
          user: User.fromJson(json['data']));
    } else if (json != null && json['user'] == null) {
      return LoginPost(
          success: json['success'] != null ? json['success'] : false,
          message: json['message'] != null ? json['message'] : '',
          user: User.fromJson(json));
    } else {
      return LoginPost(
        success: json != null
            ? (json['success'] != null ? json['success'] : false)
            : false,
        message: json != null
            ? (json['message'] != null ? json['message'] : 'false')
            : 'false',
      );
    }
  }
}

class BankDetails {
  String accountHolderName;
  String ifscCode;
  String accountNumber;
  String panNumber, bankName;

  @override
  String toString() {
    return 'BankDetails{name: $accountHolderName, ifscCode: $ifscCode, accountNumber: $accountNumber, panNumber: $panNumber, bankName: $bankName}';
  }

  BankDetails({this.accountHolderName,
    this.ifscCode,
    this.accountNumber,
    this.panNumber,
    this.bankName});

  BankDetails.fromJson(Map<String, dynamic> json) {
    accountHolderName = json['name'];
    ifscCode = json['ifscCode'];
    accountNumber = json['accountNumber'];
    panNumber = json['panNumber'];
    bankName = json['bankName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.accountHolderName;
    data['ifscCode'] = this.ifscCode;
    data['accountNumber'] = this.accountNumber;
    data['panNumber'] = this.panNumber;
    data['bankName'] = this.bankName;
    return data;
  }
}

class User {
  String email,
      name,
      activated,
      userType,
      uid,
      imageUrl,
      speciality,
      profRegistrationNumber,
      qualification,
      experience,
      practising,
      college,
      about,
      gender,
      birthDate,
      referralCode,
      userReferralCode,
      coverImageUrl,
      mobileNumber,
      latitude,
      longitude,
      address,
      biography,
      registrationNumber,
      prescriptionLogoUrl,
      accessToken,
      credits,
      region,
      googleLocation;

  List<ProcedureList> specialities = [];
  List<TimeSlots> timeSlots = [];
  List<DoctorsData> doctorsData = [];
  List<AchievementsData> achievements = [];
  bool verifiedUser, notificationEnabled, isAdmin, isCentre, referralExpired;
  BankDetails bankDetails;
  num rating;
  int cartCount;
  bool hasMedia, hasReviews;
  num distanceFromUser;
  List<Centre> centres;
  String patientServed;

  User({this.hasMedia,
    this.hasReviews,
    this.uid,
    this.name,
    this.gender,
    this.birthDate,
    this.mobileNumber,
    this.email,
    this.verifiedUser,
    this.userType,
    this.address,
    this.referralCode,
    this.specialities,
    this.timeSlots,
    this.experience,
    this.practising,
    this.college,
    this.biography,
    this.registrationNumber,
    this.qualification,
    this.imageUrl,
    this.achievements,
    this.latitude,
    this.longitude,
    this.doctorsData,
    this.coverImageUrl,
    this.accessToken,
    this.about,
    this.speciality,
    this.prescriptionLogoUrl,
    this.credits,
    this.userReferralCode,
    this.notificationEnabled,
    this.cartCount,
    this.isAdmin,
    this.isCentre,
    this.rating,
    this.referralExpired,
    this.bankDetails,
    this.googleLocation,
    this.region,
    this.distanceFromUser,
    this.centres,
    this.patientServed});

  factory User.fromJson(Map<String, dynamic> json) {
    num _rating = 4.0;
    num _distanceFromUser;
    if (json["rating"] != null &&
        json["rating"].runtimeType == _rating.runtimeType) {
      _rating = json["rating"];
    }
    if (json["distance"] != null &&
        json["distance"].runtimeType == _rating.runtimeType) {
      _distanceFromUser = json["distance"];
    }
    bool _isAdmin = json['isAdmin'] ?? false;
    bool _isCenter = json['isCenter'] ?? false;
    bool _referralExpired = json['referralExpired'] ?? false;
    List<TimeSlots> _timeSlots = [];
    if (json['timeSlots'] != null) {
      Iterable iterable = json['timeSlots'];
      _timeSlots = iterable
          .map((value) => TimeSlots.fromJson(value))
          .toList(growable: true);
    }
    String lat = "0.0",
        long = "0.0";
    if (json['location'] != null &&
        json['location']['coordinates'] != null &&
        json['location']['coordinates'].isNotEmpty) {
      long = json['location']['coordinates'][0]?.toString() ?? "0.0";
      lat = json['location']['coordinates'][1]?.toString() ?? "0.0";
    }
    if (long == null || long.isEmpty || long == "0") {
      long = "0.0";
    }
    if (lat == null || lat.isEmpty || lat == "0") {
      lat = "0.0";
    }
    print("\n \n specialities specialities ${json['specialities'] == null}");
//    print("lat in models $lat");
//    print(
//        "${json["rating"].runtimeType.toString()}long in ${_rating.runtimeType.toString()}models ${json["rating"]}");
    return User(
        uid: json['_id'] != null ? json['_id'] : '',
        hasMedia: json['hasMedia'] ?? false,
        hasReviews: json['hasReviews'] ?? false,
        name: json['name'] != null ? json['name'] : '',
        gender: json['gender'] != null ? json['gender'] : '',
        birthDate: json['birthDate'] != null ? json['birthDate'] : '',
        mobileNumber: json['mobileNumber'] != null ? json['mobileNumber'] : '',
        email: json['email'] != null ? json['email'] : '',
        verifiedUser:
        json['verifiedUser'] != null ? json['verifiedUser'] : false,
        userType: json['userType'] != null ? json['userType'] : '',
        address: json['address'] != null ? json['address'] : '',
        referralCode:
        json['userReferralCode'] != null ? json['userReferralCode'] : null,
        coverImageUrl:
        json['coverImageUrl'] != null ? json['coverImageUrl'] : '',
        specialities: json['specialities'] != null
            ? List<ProcedureList>.from(
            json['specialities'].map((i) => ProcedureList.fromJson(i)))
            : List(),
        achievements: json['achievements'] != null
            ? List<AchievementsData>.from(
            json['achievements'].map((i) => AchievementsData.fromJson(i)))
            : List(),
        doctorsData: json['doctors'] != null
            ? List<DoctorsData>.from(
            json['doctors'].map((i) => DoctorsData.fromJson(i)))
            : List(),
        experience:
        json['experience'] != null ? json['experience'].toString() : '',
        practising: json['practising'] != null ? json['practising'] : '',
        college: json['college'] != null ? json['college'] : '',
        biography: json['biography'] != null ? json['biography'] : '',
        registrationNumber: json['registrationNumber'] != null
            ? json['registrationNumber']
            : '',
        qualification:
        json['qualification'] != null ? json['qualification'] : '',
        imageUrl: json['imageUrl'] != null ? json['imageUrl'] : '',
        latitude: lat,
        longitude: long,
        isAdmin: _isAdmin,
        isCentre: _isCenter,
        prescriptionLogoUrl: json['prescription'] != null
            ? (json['prescription']['logoUrl'] != null
            ? json['prescription']['logoUrl']
            : '')
            : '',
        credits: json['credits'].toString() != null
            ? json['credits'].toString()
            : '0',
        speciality: json['specialityName'],
        userReferralCode: json['userReferralCode'],
        timeSlots: _timeSlots,
        bankDetails: json['bankDetails'] != null
            ? BankDetails.fromJson(json['bankDetails'])
            : null,
        googleLocation: json['googleAddress'],
        referralExpired: _referralExpired,
        cartCount: json["cartCount"],
        rating: _rating,
        distanceFromUser: _distanceFromUser,
        centres: json['centers'] != null
            ? List.from(json['centers'].map((i) => Centre.from(i)))
            : null,
        patientServed:
        json['patientsServed'] != null ? json['patientsServed'] : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.latitude != null &&
        this.longitude != null &&
        this.latitude.isNotEmpty &&
        this.longitude.isNotEmpty) {
      data['location'] = Location(type: 'Point', coordinates: [
        double.parse(this.longitude),
        double.parse(this.latitude)
      ]).toJson();
    }
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['mobileNumber'] = this.mobileNumber;
    data['email'] = this.email;
    data['registrationNumber'] = this.profRegistrationNumber;
    data['practising'] = this.practising;
    data['experience'] = this.experience;
    data['qualification'] = this.qualification;
    data['college'] = this.college;
    data['address'] = this.address;
    data['birthDate'] = this.birthDate;
    data['biography'] = this.biography;
    data['googleAddress'] = this.googleLocation;
    if (this.bankDetails != null) {
      data['bankDetails'] = this.bankDetails.toJson();
    }
    if (this.imageUrl != null) {
      data['imageUrl'] = this.imageUrl;
    }
    // data['referralCode'] = this.referralCode;
//    if (this.tokens != null) {
//      data['tokens'] = this.tokens.map((v) => v.toJson()).toList();
//    }
//    if (this.specialities != null) {
//      data['specialities'] = this.specialities.map((v) => v.toJson()).toList();
//    }
//    if (this.achievements != null) {
//      data['achievements'] = this.achievements.map((v) => v.toJson()).toList();
//    }

//    if (this.workTimings != null) {
//      data['workTimings'] = this.workTimings.map((v) => v.toJson()).toList();
//    }
//    if (this.timeSlots != null) {
//      data['timeSlots'] = this.timeSlots.map((v) => v.toJson()).toList();
//    }
//
//    if (this.doctors != null) {
//      data['doctors'] = this.doctors.map((v) => v.toJson()).toList();
//    }
    // data['userReferralCode'] = this.userReferralCode;
    // data['__v'] = this.iV;
    return data;
  }

  @override
  String toString() {
    return 'User{email: $email, name: $name, activated: $activated, userType: $userType, uid: $uid, imageUrl: $imageUrl, speciality: $speciality, profRegistrationNumber: $profRegistrationNumber, qualification: $qualification, experience: $experience, practising: $practising, college: $college, about: $about, gender: $gender, birthDate: $birthDate, referralCode: $referralCode, coverImageUrl: $coverImageUrl, mobileNumber: $mobileNumber, latitude: $latitude, longitude: $longitude, address: $address, biography: $biography, registrationNumber: $registrationNumber, prescriptionLogoUrl: $prescriptionLogoUrl, accessToken: $accessToken, credits: $credits, specialities: $specialities, timeSlots: $timeSlots, doctorsData: $doctorsData, achievements: $achievements, verifiedUser: $verifiedUser, bankDetais: ${bankDetails
        .toString()}';
  }
}

class Location {
  String type;
  List<double> coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['coordinates'] != null) {
      coordinates = [];
      json['coordinates'].forEach((element) {
        coordinates.add(double.tryParse(element.toString()));
      });
    }
    // coordinates = json['coordinates'].cast<num>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class DoctorsData {
  List<ProcedureList> specialities = [];
  List<TimeSlots> timeSlots = [];
  String id, name, education, designation, department, experience, imageUrl;
  num rating;

  DoctorsData({this.specialities,
    this.timeSlots,
    this.name,
    this.education,
    this.id,
    this.designation,
    this.department,
    this.experience,
    this.imageUrl,
    this.rating});

  factory DoctorsData.fromJson(Map<String, dynamic> parsedJson) {
    num _rating = 4.5;
    if (parsedJson["rating"] != null) {
      _rating = num.tryParse(parsedJson["rating"].toString());
    }
    return new DoctorsData(
        name: parsedJson['name'] != null ? parsedJson['name'] : 'NA',
        education:
        parsedJson['education'] != null ? parsedJson['education'] : '',
        designation:
        parsedJson['designation'] != null ? parsedJson['designation'] : '',
        department:
        parsedJson['department'] != null ? parsedJson['department'] : '',
        experience: parsedJson['experience'].toString() != null
            ? parsedJson['experience'].toString()
            : '',
        specialities: List<ProcedureList>.from(
            parsedJson['specialities'].map((i) => ProcedureList.fromJson(i))),
        id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
        imageUrl: parsedJson['imageUrl'] != null ? parsedJson['imageUrl'] : '',
        timeSlots: List<TimeSlots>.from(
            parsedJson['timeSlots'].map((i) => TimeSlots.fromJson(i))),
        rating: _rating);
  }
}

class ServicesData {
  final String serviceId;
  final List price;
  final String variance;

  ServicesData({this.serviceId, this.price, this.variance});

  factory ServicesData.fromJson(Map<String, dynamic> parsedJson) {
    return new ServicesData(
      serviceId: parsedJson['serviceId'] != null ? parsedJson['serviceId'] : '',
      price: parsedJson['price'] != null ? parsedJson['price'] : '',
      variance: parsedJson['variance'] != null
          ? parsedJson['variance'].toString()
          : '',
    );
  }
}

class AchievementsData {
  final String title;
  final String imageUrl;
  final String achievement;

  AchievementsData({this.title, this.imageUrl, this.achievement});

  factory AchievementsData.fromJson(Map<String, dynamic> parsedJson) {
    return new AchievementsData(
      title: parsedJson['title'] != null ? parsedJson['title'] : '',
      imageUrl: parsedJson['imageUrl'] != null ? parsedJson['imageUrl'] : '',
      achievement: parsedJson['achievement'] != null
          ? parsedJson['achievement'].toString()
          : '',
    );
  }
}

//class TimeSlotsData {
//  final List<String> slots;
//  final String day;
//  final bool closed;
//
//  TimeSlotsData({this.slots, this.day, this.closed});
//
//  factory TimeSlotsData.fromJson(Map<String, dynamic> parsedJson) {
//    List<String> _slots = [];
//    if (parsedJson['slots'] != null) {
//      parsedJson['slots'].forEach((element) {
//        _slots.add(element.toString());
//      });
//    }
//
//    return new TimeSlotsData(
//      slots: _slots,
//      day: parsedJson['day'] != null ? parsedJson['day'] : '',
//      closed: parsedJson['closed'] != null ? parsedJson['closed'] : '',
//    );
//  }
//}

class AllNotificationsPost {
  final bool success;
  final String message;
  List<PostsData> posts = [];
  int unreadCount;

  AllNotificationsPost(
      {this.success, this.message, this.posts, this.unreadCount});

  factory AllNotificationsPost.fromJson(Map<String, dynamic> json) {
    return AllNotificationsPost(
      success: json['success'] != null ? json['success'] : false,
      message: json['message'] != null ? json['message'] : '',
      posts: (json['data'] != null && json['data']['notifications'] != null)
          ? List<PostsData>.from(
          json['data']['notifications'].map((i) => PostsData.fromJson(i)))
          : <PostsData>[],
      unreadCount: (json['data'] != null && json['data']['count'] != null)
          ? json['data']['count']
          : 0,
    );
  }
}

class PostsData {
  final String senderImageUrl;
  final int createdTime;
  final String notificationType;
  final String senderUserId;
  final String id;
  final String notification;
  final String senderName;
  final String notificationId;
  final String notificationScreen;
  bool hasSeen, deleted;

  PostsData({this.senderImageUrl,
    this.createdTime,
    this.notificationType,
    this.senderUserId,
    this.id,
    this.notification,
    this.senderName,
    this.deleted,
    this.notificationId,
    this.notificationScreen,
    this.hasSeen});

  factory PostsData.fromJson(Map<String, dynamic> parsedJson) {
//    print("parsedJson ${parsedJson["deleted"]}");
    return new PostsData(
        senderImageUrl: parsedJson['senderImageUrl'] != null
            ? parsedJson['senderImageUrl']
            : '',
        createdTime:
        parsedJson['createdTime'] != null ? parsedJson['createdTime'] : 0,
        notificationType: parsedJson['notificationType'] != null
            ? parsedJson['notificationType']
            : '',
        senderUserId: parsedJson['senderUserId'] != null
            ? parsedJson['senderUserId']
            : '',
        id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
        notification: parsedJson['notification'] != null
            ? parsedJson['notification']
            : '',
        senderName:
        parsedJson['senderName'] != null ? parsedJson['senderName'] : '',
        notificationId: parsedJson['notificationId'] != null
            ? parsedJson['notificationId']
            : '',
        notificationScreen: parsedJson['notificationScreen'] != null
            ? parsedJson['notificationScreen']
            : '',
        hasSeen: parsedJson['read'],
        deleted: parsedJson["deleted"] ?? false);
  }

  factory PostsData.fromJsonForPush(Map<String, dynamic> parsedJson) {
    if (Platform.isIOS) {
      return PostsData(
          notificationType:
          parsedJson['screen'] != null ? parsedJson['screen'] : null,
          id: parsedJson['id'] != null ? parsedJson['id'] : null);
    } else {
      var data = new PostsData(
        notificationType: parsedJson['data']['screen'] != null
            ? parsedJson['data']['screen']
            : null,
        id: parsedJson['data']['id'] != null ? parsedJson['data']['id'] : null,
      );
      return data;
    }
  }

  @override
  String toString() {
    return 'PostsData{senderImageUrl: $senderImageUrl, createdTime: $createdTime, notificationType: $notificationType, senderUserId: $senderUserId, id: $id, notification: $notification, senderName: $senderName}';
  }
}

class GetOtpModel {
  bool success;

  GetOtpModel({this.success});

  GetOtpModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    return data;
  }
}

class VerifyOtpResponse {
  bool success;

  VerifyOtpResponse({this.success});

  VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    return data;
  }
}

class SpecialityOuterModel {
  bool success;
  List<SpecialityModel> data;
  String msg;

  SpecialityOuterModel({this.success, this.data, this.msg});

  SpecialityOuterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = new List<SpecialityModel>();
      json['data'].forEach((v) {
        data.add(new SpecialityModel.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class SpecialityModel {
  String speciality;
  String id, specialityImageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SpecialityModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  SpecialityModel({this.speciality, this.id, this.specialityImageUrl});

  SpecialityModel.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    id = json['specialityId'];
    specialityImageUrl = json['specializationImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speciality'] = this.speciality;
    data['specialityId'] = this.id;
    return data;
  }
}

class HttpErrorModel {
  int statusCode;
  String error;

  HttpErrorModel({this.statusCode, this.error});

  HttpErrorModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['error'] = this.error;
    return data;
  }
}

class HelpLineNumberModel {
  bool success;
  String number;
  String msg;

  HelpLineNumberModel({this.success, this.number, this.msg});

  HelpLineNumberModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    number = json['data'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['data'] = this.number;
    data['msg'] = this.msg;
    return data;
  }
}

class CheckLocationResponse {
  bool success;
  String msg;
  List<double> coordinates;

  CheckLocationResponse({this.success, this.msg, this.coordinates});

  CheckLocationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    coordinates =
    json['coordinates'] != null ? json['coordinates'].cast<double>() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['msg'] = this.msg;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class CouponTextResponseModel {
  bool success;
  CouponText data;

  CouponTextResponseModel({this.success, this.data});

  CouponTextResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new CouponText.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class CouponText {
  String message;

  CouponText({this.message});

  CouponText.fromJson(Map<String, dynamic> json) {
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    return data;
  }
}

class CentreResponse {
  bool success;
  int len;
  List<CentreData> data;

  CentreResponse({this.success, this.len, this.data});

  CentreResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    len = json['len'];
    if (json['data'] != null) {
      data = new List<CentreData>();
      json['data'].forEach((v) {
        data.add(new CentreData.fromJson(v));
      });
    }
  }
}

class CentreData {
  Location location;
  String imageUrl;
  bool isCenter;
  bool isAdmin;
  String sId;
  String name;
  String userType;
  String email;
  String centerLocation;
  String mobileNumber;
  String adminMobileNumber;
  String adminRefId;
  String address;

  CentreData({this.address,
    this.imageUrl,
    this.name,
    this.userType,
    this.adminMobileNumber,
    this.adminRefId,
    this.centerLocation,
    this.email,
    this.isAdmin,
    this.isCenter,
    this.location,
    this.mobileNumber,
    this.sId});

  CentreData.fromJson(Map<String, dynamic> json) {
//    location = json['location'] != null
//        ? new Location.fromJson(json['location'])
//        : null;
    imageUrl = json['imageUrl'];
    isCenter = json['isCenter'];
    isAdmin = json['isAdmin'];
    sId = json['_id'];
    name = json['name'];
    userType = json['userType'];
    email = json['email'];
    centerLocation = json['centerLocation'];
    mobileNumber = json['mobileNumber'];
    adminMobileNumber = json['adminMobileNumber'];
    adminRefId = json['adminRefId'];
    address = json['address'];
  }
}

class RateAndReview {
  String sId;
  String professionalId;
  String userId;
  int iV;
  String description;
  num rating;
  Null title;
  String userName;
  String userImage;

  int createdAt;

  RateAndReview({this.sId,
    this.professionalId,
    this.userId,
    this.iV,
    this.description,
    this.rating,
    this.title,
    this.userName,
    this.createdAt,
    this.userImage});

  RateAndReview.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    professionalId = json['professionalId'];
    userId = json['userId'];
    iV = json['__v'];
    description = json['description'];
    rating = json['rating'];
    title = json['title'];
    userName = json['userName'];
    createdAt = json['createdAt'];
    userImage = json['userImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['professionalId'] = this.professionalId;
    data['userId'] = this.userId;
    data['__v'] = this.iV;
    data['description'] = this.description;
    data['rating'] = this.rating;
    data['title'] = this.title;
    data['userName'] = this.userName;
    data['userImage'] = this.userImage;
    return data;
  }
}

class Centre {
  String name, id, address, mobileNumber;

  Centre(this.id, this.name, this.address, this.mobileNumber);

  Centre.from(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    address = json['address'];
    mobileNumber = json['mobileNumber'];
  }
}
