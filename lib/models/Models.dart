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
}

class _Services {
  String _id, _service, _details, _category, _description;

  get id => _id;

  get service => _service;

  get details => _details;

  get category => _category;

  get description => _description;

  _Services(result) {
    _id = result['_id'] != null ? result['_id'] : '';
    _service = result['service'] != null ? result['service'] : '';
    _details = result['details'] != null ? result['details'] : '';
    _category = result['category'] != null ? result['category'] : '';
    _description = result['dnd'] != null ? result['dnd'] : '';
  }
}

class LoginPost {
  final bool success;
  final String message;

  final String token;
  User user;

  LoginPost({this.success, this.token, this.user, this.message});

  factory LoginPost.fromJson(Map<String, dynamic> json) {
    if (json != null && json['user'] != null && json.containsKey('user')) {
      return LoginPost(
          success: json['success'] != null ? json['success'] : false,
          message: json['message'] != null ? json['message'] : '',
          token: json['token'] != null ? json['token'] : '',
          user: User.fromJson(json['user']));
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
      coverImageUrl,
      mobileNumber,
      latitude,
      longitude,
      address,
      biography,
      registrationNumber,
      prescriptionLogoUrl,
      credits;
  List<ProcedureList> specialities = [];
  List<TimeSlotsData> timeSlots = [];
  List<DoctorsData> doctorsData = [];
  List<AchievementsData> achievements = [];
  bool verifiedUser;

  User(
      {this.uid,
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
      this.prescriptionLogoUrl,
      this.credits});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['_id'] != null ? json['_id'] : '',
      name: json['name'] != null ? json['name'] : '',
      gender: json['gender'] != null ? json['gender'] : '',
      birthDate: json['birthDate'] != null ? json['birthDate'] : '',
      mobileNumber: json['mobileNumber'] != null ? json['mobileNumber'] : '',
      email: json['email'] != null ? json['email'] : '',
      verifiedUser: json['verifiedUser'] != null ? json['verifiedUser'] : false,
      userType: json['userType'] != null ? json['userType'] : '',
      address: json['address'] != null ? json['address'] : '',
      referralCode: json['referralCode'] != null ? json['referralCode'] : '',
      coverImageUrl: json['coverImageUrl'] != null ? json['coverImageUrl'] : '',
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
      registrationNumber:
          json['registrationNumber'] != null ? json['registrationNumber'] : '',
      qualification: json['qualification'] != null ? json['qualification'] : '',
      imageUrl: json['imageUrl'] != null ? json['imageUrl'] : '',
      latitude: json['geoLocation'] != null
          ? (json['geoLocation']['latitude'].toString() != null
              ? json['geoLocation']['latitude'].toString()
              : '')
          : '',
      longitude: json['geoLocation'] != null
          ? (json['geoLocation']['longitude'].toString() != null
              ? json['geoLocation']['longitude'].toString()
              : '')
          : '',
      prescriptionLogoUrl: json['prescription'] != null
          ? (json['prescription']['logoUrl'] != null
              ? json['prescription']['logoUrl']
              : '')
          : '',
      credits:
          json['credits'].toString() != null ? json['credits'].toString() : '0',
    );
  }
}

class DoctorsData {
  List<ProcedureList> specialities = [];
  List<TimeSlotsData> timeSlots = [];
  String id, name, education, designation, department, experience, imageUrl;

  DoctorsData(
      {this.specialities,
      this.timeSlots,
      this.name,
      this.education,
      this.id,
      this.designation,
      this.department,
      this.experience,
      this.imageUrl});

  factory DoctorsData.fromJson(Map<String, dynamic> parsedJson) {
    return new DoctorsData(
      name: parsedJson['name'] != null ? parsedJson['name'] : 'NA',
      education: parsedJson['education'] != null ? parsedJson['education'] : '',
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
      timeSlots: List<TimeSlotsData>.from(
          parsedJson['timeSlots'].map((i) => TimeSlotsData.fromJson(i))),
    );
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
  final String id;

  AchievementsData({this.title, this.imageUrl, this.id});

  factory AchievementsData.fromJson(Map<String, dynamic> parsedJson) {
    return new AchievementsData(
      title: parsedJson['title'] != null ? parsedJson['title'] : '',
      imageUrl: parsedJson['imageUrl'] != null ? parsedJson['imageUrl'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'].toString() : '',
    );
  }
}

class TimeSlotsData {
  final List slots;
  final String day;
  final bool closed;

  TimeSlotsData({this.slots, this.day, this.closed});

  factory TimeSlotsData.fromJson(Map<String, dynamic> parsedJson) {
    return new TimeSlotsData(
      slots: parsedJson['slots'] != null ? parsedJson['slots'] : '',
      day: parsedJson['day'] != null ? parsedJson['day'] : '',
      closed: parsedJson['closed'] != null ? parsedJson['closed'] : '',
    );
  }
}


class AllNotificationsPost {
  final bool success;
  final String message;
  List<PostsData> posts = [];

  AllNotificationsPost({this.success, this.message, this.posts});

  factory AllNotificationsPost.fromJson(Map<String, dynamic> json) {

    return AllNotificationsPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
      posts: List<PostsData>.from(json['notifications'].map((i) => PostsData.fromJson(i))),
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


  PostsData({this.senderImageUrl, this.createdTime,
    this.notificationType, this.senderUserId, this.id, this.notification,
    this.senderName});

  factory PostsData.fromJson(Map<String, dynamic> parsedJson) {
    return new PostsData(
      senderImageUrl: parsedJson['senderImageUrl'] != null ? parsedJson['senderImageUrl'] : '',
      createdTime: parsedJson['createdTime'] != null ? parsedJson['createdTime'] : 0,
      notificationType: parsedJson['notificationType'] != null ? parsedJson['notificationType'] : '',
      senderUserId: parsedJson['senderUserId'] != null ? parsedJson['senderUserId'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
      notification: parsedJson['notification'] != null ? parsedJson['notification'] : '',
      senderName: parsedJson['senderName'] != null ? parsedJson['senderName'] : '',
    );
  }
}
