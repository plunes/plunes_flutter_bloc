import 'package:plunes/Utils/Constants.dart';

/*
 * Created by - Plunes Technologies .
 * Description - This class is all the network url which will be used throughout the application.
 */

final urls = Urls();

class Urls {
  static final int CONNECTION_TIMEOUT = 60000;
  static final int RECEIVE_TIMEOUT = 60000;
  static final int SEND_TIMEOUT = 120000;

  ///'Plunes is the sender id'
  get sendOTPUrl =>
      'https://control.msg91.com/api/sendotp.php?authkey=278069AIdfPwGj5ce79990&mobile=91';
  static const String googleApiKey = 'AIzaSyBsy04mUPFZvE2jp2qW6ytyexI5ZLeO1Uc';

  // static const String baseUrl =
  //     'https://api.plunes.com/v9/'; // production server
  static const String baseUrl =
      'https://devapi.plunes.com/staging/'; // staging server

  // static const String customBaseUrl =
  //     'https://api.plunes.com/'; // production server
  static const String customBaseUrl =
      'https://devapi.plunes.com/'; // staging server

  // static const String socketUrl = 'https://api.plunes.com'; // production server
  static const String socketUrl = 'https://devapi.plunes.com'; // staging server

  // static const String mcmBaseUrl =
  //     "https://api.plunes.com/mcm/"; // production server
  static const String mcmBaseUrl =
      "https://devapi.plunes.com/mcm/"; // staging server

  get catalogue => baseUrl + 'catalogue';

  get logout => baseUrl + 'user/logout';

  get logoutProf => baseUrl + 'professional/logout';

  get logoutAll => baseUrl + 'user/logout_all';

  get userBaseUrl => baseUrl + 'user';

  get checkUserExistence => 'user?mobileNumber=';

  get whoAmI => baseUrl + 'user/whoami';

  get login => baseUrl + 'user/login';

  get signUp => baseUrl + 'user/register';

  get changePassword => baseUrl + 'user/updatePassword';

  get terms => 'https://plunes-html.s3.amazonaws.com/resources/tnc.html';

  get aboutUs => 'https://plunes-html.s3.amazonaws.com/resources/about-us.html';

  get plockrBaseUrl => "https://www.plunes.com/dicom_viewer?fileId=";

  get help => baseUrl + "enquiry/help";

  get notification => baseUrl + "notification/0";
  static const String SEARCH_SOLUTION_API = "catalogue/search/";
  static const String GET_CONSULTATION_API = "catalogue/category/consultations";
  static const String GET_PROCEDURES_API = "catalogue/category/procedures";
  static const String GET_TESTS_API = "catalogue/category/tests";
  static const String GET_TEST_AND_PROCEDURES_CATALOGUE_API =
      "catalogue/serviceList";
  static const String CHECK_LOCATION_API = "user/checkLocation";
  static const String GET_DOC_HOS_API = "solution/solution";
  static const String BOOKING_URL = 'booking';
  static const String PROF_BOOKING_URL = "professionalBooking";

  // static const String PAYMENT_WEB_VIEW_URL =
  //     "https://api.plunes.com/payment"; //production
  static const String PAYMENT_WEB_VIEW_URL =
      'https://devapi.plunes.com/payment'; //'https://plunes.co/payment'; //dev
  static const String ZEST_MONEY_URL =
      PAYMENT_WEB_VIEW_URL + "Control/zestMoney";
  static const String cancelPaymentUrl =
      customBaseUrl + "paymentControl/viewClosed/";
  static const String PREV_SOLUTION_URL = "solution/search";
  static const String GENERATE_OTP_URL = "user/generateOtp";
  static const String FORGOT_PASSWORD_URL = "user/forgotPassword";
  static const String VERIFY_OTP_URL = "user/verifyOtp";
  static const String CATALOGUE_SERVICE_URL = "user/getServices";
  static const String GET_REALTIME_INSIGHTS_URL = "analytics/solutionSearch";
  static const String GET_ACTIONABLE_INSIGHTS_URL =
      "analytics/actionableInsight";
  static const String GET_TOTAL_BUSINESS_EARNED_AND_LOSS_URL =
      "analytics/totalBusiness";
  static const String UPDATE_REALTIME_INSIGHT_PRICE_URL =
      'solution/updateSolution';
  static const String UPDATE_ACTIONABLE_INSIGHT_PRICE_URL = 'admin/updatePrice';
  static const String GET_CANCEL_AND_RESCHEDULE_URL = 'booking/';
  static const String GET_CANCEL_AND_RESCHEDULE_URL_FOR_PROF =
      PROF_BOOKING_URL + "/";
  static const String GET_CONFIRM_APPOINTMENT_URL = 'booking/confirmBooking';
  static const String GET_CONFIRM_APPOINTMENT_URL_FOR_PROF =
      PROF_BOOKING_URL + '/confirmBooking';
  static const String GET_REFUND_URL = 'booking/refund';
  static const String GET_SPECIALITIES_URL = 'catalogue/getSpecialities';
  static const GET_UPLOAD_PLOCKR_DATA_URL = 'report';
  static const GET_SHARABLE_LINK_FILE_URL = 'report/getShareableLink/';
  static const String UPDATE_TOKEN = "user/notificationTokenRefresh";
  static const String UPDATE_TOKEN_PROF = "professional/notificationTokenRefresh";
  static const String NOTIFICATION_SWITCH = "user/notificationSwitch";
  static const String NOTIFICATION_SWITCH_PROF = "professional/notificationSwitch";
  static const String HELP_QUERY_URL_FOR_DOC_HOS = "professional/enquiry";
  static const String HELP_QUERY_URL_FOR_USER = "user/enquiry";
  static const String GET_USER_SPECIFIC_SPECIALITY =
      "user/getProfessionalSpecialities";
  static const String GET_SPECIALITY_RELATED_SERVICE =
      "user/getProfessionalServices?";
  static const String RESET_PASSWORD_URL = "user/updatePassword";
  static const String CHANGE_PASSWORD_URL = "user/changePassword";
  static const String CHANGE_PASSWORD_URL_FOR_PROF =
      "professional/changePassword";
  static const String SET_NOTIFICATION_COUNT_ZERO = "notification";
  static const String GET_NOTIFICATIONS_URL = "notification/0";
  static const String GET_NOTIFICATIONS_URL_FOR_PROF =
      "notification/professional/0";
  static const String GET_HELPLINE_NUMBER_URL = "user/contactSupport";
  static const String GET_COUPON_TEXT_URL = "user/couponText";
  static const String GET_CENTRES_DATA = "professional/getAllCenters";
  static const String RATE_AND_REVIEW = "review";
  static const String MEDIA_CONTENT_URL = "user/getMediaContent";
  static const String REQUEST_INVOICE_URL = 'booking/invoice';
  static const String MORE_FACILITIES_URL = "user/professionalForSpeciality";
  static const String ADD_TO_SOLUTION_URL = "solution/addToSolution";
  static const String GET_FACILITIES_MANUAL_BIDDING = "user/getFacilities";
  static const String CREATE_MANUAL_BIDDING_URL =
      "solution/createManualBidding";
  static const String DELETE_NOTIFICATIONS_URL =
      "notification/deleteNotifications";
  static const String CHANGE_PROFILE_URL = "upload/profilePicture";
  static const String SERVICE_NOTIFICATION_DISABLE_URL =
      "professional/serviceNotificationException/";
  static const String UPDATE_PRICE_IN_CATALOGUE_FROM_REAL_INSIGHT =
      "professional/addServiceToCatalogue";
  static const String EXPLORE_URL = "explore/";
  static const String ADD_TO_CART_URL = "cart/add";
  static const String DELETE_FROM_CART = "cart/delete/";
  static const String GET_CART_ITEMS = "cart/";
  static const String REGENERATE_CART_ITEM_URL = "cart/renegotiate/";
  static const String EDIT_CART_DETAIL_URL = "booking/editPatient";
  static const String PAY_CART_ITEMS_BILL_URL = "cart/checkout";
  static const String UPI_PAYMENT_URL = customBaseUrl + "paymentControl/";
  static const String CAPTURE_UPI_PAYMENT_URL =
      "$UPI_PAYMENT_URL" + "captureUPIPayment";
  static const String CART_COUNT_URL = "cart/count/";

  //////////////////////////////////////////////////////////////////////////////new flow api's
  static const String GET_HOME_SCREEN_CATEGORY_DATA_URL =
      "catalogue/getCategories";
  static const String GET_WHY_US_URL = mcmBaseUrl + "plunes/getWhyus";
  static const String GET_WHY_US_BY_ID_URL = mcmBaseUrl + "plunes/whyus/";
  static const String KNOW_YOUR_PROCEDURE_URL =
      mcmBaseUrl + "mcmCatalogue/getServiceFamily";
  static const String GET_PROFESSIONAL_FOR_SERVICE_URL =
      "user/getProfessionalsFromServices";
  static const String GET_COMMON_SPECIALITIES_URL =
      mcmBaseUrl + "mcmCatalogue/getCommonSpecialities";
  static const String GET_PLUNES_MEDIA_URL =
      mcmBaseUrl + "plunes/getPlunesMedia";
  static const String TOP_SEARCH_URL = "analytics/topSearched";
  static const String SUBMIT_USER_MEDICAL_DETAIL_URL = "user/submitReport";
  static const String UPLOAD_MEDICAL_FILE_URL = "user/userReport";
  static const String DISCOVER_PRICE_API = "solution/discoverSolution";
  static const String GET_INSURANCE_NAMES_URL =
      "professional/insurancesByProfessionalId";
  static const String UPLOAD_INSURANCE_URL = "user/uploadInsurance";
  static const String TOP_FACILITY_URL = "solution/getTopFacilities";
  static const String GET_ALL_SERVICE_BY_SPECIALITY_ID =
      "professional/getProfessionalServiceBySpecilityId";
  static const String FACILITY_HAVE_URL = mcmBaseUrl + "plunes/getcuration";
  static const String PREMIUM_BENEFITS_FOR_USER_URL =
      mcmBaseUrl + "plunes/getPremiumBenefits";
  static const String SPECIALITY_RELATED_SERVICES_URL =
      "catalogue/getServiceBySpecialityId";
  static const String GET_PROFESSIONAL_FOR_COMMON_SPECIALITY =
      "user/getProfessionalsFromCommonSpeciality";
  static const String GET_REPORT_BY_REPORT_ID = "user/getReportByReportId";
  static const String BANK_OFFER_URL = mcmBaseUrl + "plunes/getBankOffers";
  static const String GET_FORM_DATA_ON_FILL_MEDICAL_DETAIL_SCREEN =
      "catalogue/getServiceById";

  ///new professional api's
  static const String profLogin = "professional/login";
  static const String forgotPasswordProf = "professional/forgotPassword";
  static const String resetPasswordProf = "professional/resetPasswordViaOTP";
  static const String profDetails = "professional";
  static const String getServiceByProfessionalId =
      "professional/getServiceByProfessionalId";
  static const String createSolutionFromProfProfile =
      "solution/professionalSolution";
  static const String SEARCH_FACILITY_API = "catalogue/hospitalSearch";
  static const String POPULAR_CITIES_AND_SERVICES_URL =
      "catalogue/getPopularCitesAndService";
  static const String FamilyCatalogueUrl = "catalogue/getServicesbyfamily";
}
