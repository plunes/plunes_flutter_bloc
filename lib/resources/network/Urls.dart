import 'package:plunes/Utils/Constants.dart';

/*
 * Created by - Plunes Technologies .
 * Description - This class is all the network url which will be used throughout the application.
 */

final urls = Urls();

class Urls {
  get otpConfig => '&sender=Plunes&otp=' + Constants.OTP;
  static final int CONNECTION_TIMEOUT = 60000;
  static final int RECEIVE_TIMEOUT = 60000;
  static final int SEND_TIMEOUT = 120000;

  ///'Plunes is the sender id'
  get sendOTPUrl =>
      'https://control.msg91.com/api/sendotp.php?authkey=278069AIdfPwGj5ce79990&mobile=91';
  static String googleApiKey = 'AIzaSyAXz9PuBzPhMjAdUZmlyFdst6J8v6Vx1IU';

//  static const String baseUrl = 'https://plunes.co/v4/'; // production server
  static const String baseUrl =
      'https://devapi.plunes.com/v5/'; // staging server

  get catalogue => baseUrl + 'catalogue';

  get logout => baseUrl + 'user/logout';

  get logoutAll => baseUrl + 'user/logout_all';

  get userUpdate => baseUrl + 'user';

  get checkUserExistence => baseUrl + 'user?mobileNumber=';

  get whoAmI => baseUrl + 'user/whoami';

  get login => baseUrl + 'user/login';

  get signUp => baseUrl + 'user/register';

  get changePassword => baseUrl + 'user/update_password';

  get terms => 'https://plunes-html.s3.amazonaws.com/resources/tnc.html';

  get aboutUs => 'https://plunes-html.s3.amazonaws.com/resources/about-us.html';

  get help => baseUrl + "enquiry/help";

  get notification => baseUrl + "notification/0";
  static const String SEARCH_SOLUTION_API = "catalogue/search/";
  static const String GET_CONSULTATION_API = "catalogue/category/consultations";
  static const String GET_PROCEDURES_API = "catalogue/category/procedures";
  static const String GET_TESTS_API = "catalogue/category/tests";
  static const String GET_TEST_AND_PROCEDURES_CATALOGUE_API =
      "catalogue/serviceList";
  static const String CHECK_LOCATION_API = "user/checkLocation";
  static const String GET_DOCHOS_API = "solution";
}
