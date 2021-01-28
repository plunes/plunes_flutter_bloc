/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - Constants class is for storing the references like assets ,preferences keys ,state keys ,route names.
 */

class Constants {
  static const List<String> genderList = ["Male", "Female", "Other"];
  static const int exploreScreenNumber = 1;
  static const int homeScreenNumber = 0;
  static const int cartScreenNumber = 2;
  static const int notificationScreenNumber = 3;
  static String DEVICE_TOKEN = "device_token";
  static const String profile = 'Profile';
  static const String POST = 'Post';
  static const String PUT = 'Put';
  static const String BIDDING_MAIN_SCREEN = "BIDDING_MAIN_SCREEN";
  static const String SOLUTION_SCREEN = "SOLUTION_SCREEN";
  static const String INSIGHT_MAIN_SCREEN = "INSIGHT_MAIN_SCREEN";
  static const String VIDEO_STATUS_FOR_PROF = "VIDEO_STATUS_FOR_PROF";
  static const String VIDEO_STATUS_FOR_USER = "VIDEO_STATUS_FOR_USER";
  static const String PLUNES_USER_VIDEO_DEMO =
      "https://www.youtube.com/watch?v=sITYg1awTPE";
  static const String consultationKey = "Consultation";
  static const String procedureKey = "Procedure";
  static const String testKey = "Test";
  static const String USER_TESTIMONIAL = "USER_TESTIMONIAL";
  static const String PROFESSIONAL_TESTIMONIAL = "PROFESSIONAL_TESTIMONIAL";
  static const String pdfExtension = "pdf";
  static const String xlsxExtension = "xlsx";
  static const String docxExtension = "docx";
  static const String typeImage = "IMAGE";
  static const String typeVideo = "VIDEO";
  static const String typeReport = "REPORT";

  static get hospital => 'Hospital';

  static get doctor => 'Doctor';

  static get generalUser => 'General User';

  static get labDiagnosticCenter => 'Lab';

  static get user => 'User';

  //Preference keys
  static const String PREF_USER_ID = 'ID';
  static const String ACCESS_TOKEN = 'Token';
  static const String PREF_USERNAME = 'UserName';
  static const String PREF_USER_EMAIL = 'UserEmail';
  static const String PREF_PHONE_VERIFIED = 'phone_verified';
  static const String PREF_USER_IMAGE = 'UserImage';
  static const String PREF_USER_BANNER_IMAGE = 'UserBannerImage';
  static const String PREF_USER_PHONE_NUMBER = 'UserNumber';
  static const String PREF_USER_TYPE = 'UserType';
  static const String PREF_PROF_REG_NUMBER = 'professionalRegistrationNumber';
  static const String PREF_ACTIVE = 'active';
  static const String PREF_QUALIFICATION = 'qualification';
  static const String PREF_REFERRAL_CODE = 'referralCode';
  static const String PREF_CREDITS = 'credits';
  static const String PREF_USER_LOCATION = 'user_location';
  static const String PREF_EXPERIENCE = 'experience';
  static const String PREF_PRACTISING = 'practising';
  static const String PREF_COLLEGE = 'college';
  static const String PREF_INTRODUCTION = 'intro';
  static const String PREF_DOB = 'dob';
  static const String PREF_GENDER = 'gender';
  static const String USER_UPDATED = 'userUpdated';
  static const String LATITUDE = 'latitude';
  static const String LONGITUDE = 'longitude';
  static const String SUCCESS = 'success';
  static const String MESSAGE = 'message';
  static const String IS_IN_SERVICE_LOCATION = "IS_IN_SERVICE_LOCATION";
  static const String FIREBASE_TOKEN = "FIREBASE_TOKEN";
  static const String NOTIFICATION_ENABLED = "NOTIFICATION_ENABLED";
  static const String IS_ADMIN = "IS_ADMIN";
  static const String IS_CENTRE = "IS_CENTRE";
  static const String GOOGLE_LOCATION = "GOOGLE_LOCATION";
  static const String REGION = "REGION";
}
