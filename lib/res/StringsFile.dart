/// Created by Manvendra Kumar Singh

final plunesStrings = PlunesStrings();

class PlunesStrings {
  static const String exceptionMsg =
      'An error occurred when converting a color';
  static const String noInternetMsg = 'No Internet';
  static const String cantConnectInternet = 'Can\'t connect to the Internet ';
  static const String tryAgain = 'Try Again';

  static const String cancelError = "Request cancelled";

  static const String pleaseCheckInternetConnection =
      "Slow or no internet connection";

  static const String noInternet = noInternetMsg;

  static const String receiveTimeOut = "Server timeout, please try again later";

  static const String pleaseSelectLocation =
      "We are not able to find you, please select a location first";

  /////
  ///Solution strings
  static const String solutionSearched = "Solution Searched";
  static const String consultations = "Consultations";
  static const String tests = "Tests";
  static const String procedures = "Procedures";
  static const String NA = "NA";
  static const String negotiateForBestPrice =
      "Negotiate for the best price solution near you";
  static const String previousActivities = "Previous Activities";
  static const String noSolutionsAvailable = "No solutions available";
  static const String consultationNotAvailable = "Consultation not available";
  static const String proceduresNotAvailable = "Procedures not available";
  static const String testsNotAvailable = "Tests not available";
  static const String serviceNotAvailable =
      "Currently this service is not available";
  static const String weAreGettingBestSolution =
      'WE ARE GETTING THE BEST SOLUTIONS FOR YOU';
  static const String weAreNegotiatingBestSolution =
      'WE ARE NEGOTIATING THE BEST SOLUTIONS FOR YOU';
  static const String receiving = "Receiving...";
  static const String checkAvailability = "Check Availability";
  static const String bookIn = "Book in";
  static const String homeCollectionAvailable = "Home Collection Available";
  static const String oopsServiceNotAvailable =
      "Oops, seems like we are not providing services in your area, kindly search in gurgaon location.";
  static const String save = "Save";
  static const String kmsAway = "kms away";
  static const String book = "Book";
  static const String viewDetails = 'View Details';
  static const String confirmYourBooking = "Confirm your Booking";
  static const String negotiating = "Negotiating. . .";
  static const String topSearches = "Top Searches";
  static const String switchToGurLoc =
      "Kindly switch to Gurgaon location, currently we are not providing service in your area";
  static const String setYourTime = "Set your Time";
  static const String choose = "Choose";
  static const String locationNotAvailable = "Location not available";
  static const String weAreNotAvailableInYourArea =
      "Sorry, We are currently not available in your area.";
  static const String pleaseSelectValidSlot =
      "Please select a valid appointment time";
  static const String pleaseMakeSureText =
      "Please make sure you book within a short time, keeping in mind it is valid for only 1 hour.";
  static const String chooseLocation = "Choose Location";

  ///Booking strings
  static const String whyPlunes = "Why Plunes?";
  static const String getDirection = "Get Direction";
  static const String addressInSmall = "Address";
  static const String availableSlots = "Available Slots";
  static const String slot1 = "Slot 1";
  static const String slot2 = "Slot 2";
  static const String appointmentTime = "Appointment Time";
  static const String tcApply = "T&C Apply.";
  static const String payNow = "PAY NOW";
  static const String availableCash = "Available Cash";
  static const String closed = "Closed";
  static const String reschedule = "Reschedule";
  static const String requestInvoice = "Request Invoice";
  static const String refund = "Refund";
  static const String visitAgain = "Visit Again";
  static const String appointmentScreenError = "Appointment Screen Error";
  static const String paymentStatus = "Payment Status";
  static const String rescheduledSuccessMessage =
      "Appointment rescheduled sucessfully!";
  static const String rescheduledFailedMessage =
      "Appointment rescheduled failed!";
  static const String cancelSuccessMessage =
      "Appointment cancelled sucessfully!";
  static const String cancelFailedMessage = "Appointment cancellation failed!";
  static const String refundFailedMessage =
      "Refund Request has been failed! try agian Later.";
  static const String emptyTextFieldWarning = "Please Enter the Refund Reason";
  static const String thankYouMessage = "Thank You!";
  static const String refundSuccessMessage =
      "Your Refund has been initiated, Amount will be creadited in 3-4 business days.";
  static String uplaodSuccessMessage = "Report uploaded successfully!";

  ///Catalogue View Screen
  static String youHaveNotAddedAnyServicesYet =
      "You haven't added any services in your catalogue yet.";

  static const String toChangePriceOrVarianceString =
      "To change price or variance in catalogue, please add again with new price and variance. ";

  static const String testName = "Test Name";
  static const String price = "Price";
  static const String editVariance = "Variance";

  ///Insight main screen
  static const String realTimeInsights = 'Real Time Insights';
  static const String noRealTimeInsights =
      "You don't have any real time insights yet";
  static const String noBusinessDataFound = 'No business data found';
  static const String kindlyUpdateYourPrice = 'Kindly Update your price';
  static const String noActionableInsightAvailable =
      "No Actionable insights yet";

  static const String solutionExpired =
      "Solution you looking for has been Expired!";

  static const String noReportAvailabelMessage =
      "You don't have any reports yet";
  static const String noMatchReport = "No Match Found!";

  static const String unableToOpen = "Unable to open the file!";

  static const String dataNotFound = "Data is not found!";

  static const String unableToDelete = "Unable to delele!";
  static const String appointmentFailedMessage = "Confirmation request failed";

  static const String deleteSuccessfully = "Deleted Successfully!";

  static const String priceUpdateSuccessMessage = "Price updated successfully!";

  static const String noAppointmentAvailable =
      "You don't have appointment yet!";

  static const String invalidOtp = "Invalid OTP";

  static const String  confirmFailedMessage = 'booking confirmation failed';

  static const String pleaseSelectALocation = "Please select a location.";

  static const String pay = "Pay";

  static const String paymentDone = "Payment Done!";

  get healthSolInfoArray => [
        'Root Canal Treatment (RCT)\n Teeth Whitening\n Scaling & Polishing\n Dental Filling\n Wisdom Tooth Removal\n Braces & Aligners\n Dentures\n Bridges & Crowns\n Smile Makeover\n Gum Treatment\n',
        'Acne Scar Treatment\n Anti-Aging\n Acne Scars\n Pigmentation\n Hairfall\n Dermoscopy\n Chemical Peel\n Wart Removal\n Wart Removal\n Baldness Treatment\n Skin Polishing\n Wrinkle Treatment\n Mole Removal\n Melasma\n Eczema',
        'Caesarean Section\n Colposcopy\n Cervical Cerclage\n Ovary Removal Surgery\n Female Infertility Treatment\n PCOD & Fibroids Management\n Hyteroscopy\n Dilation & Curettage\n Iud Placement\n',
        'Lasik Surgery\n Refractive Surgery\n Cataract Eye Surgery\n Oculoplasty\n Glaucoma Treatment\n Keratoconus Treatment\n Laser Photocoagulation\n Phacoemulsification\n Vitreoretinal Surgery\n',
        'Joint Replacement\n Spinal Disc Problem\n Fracture Treatment\n Revision Surgery\n Asthoscopic Surgery\n Osteoporosis\n Sports Injuries\n Spondylitis\n Arthritis\n Trauma Injuries\n',
        'Full Body Check-Up\n Complete Blood Count (CBC)\n Lipid Profile\n Fasting Blood Sugar Test (FBS)\n Thyroid Stimulating Harmone (TSH)\n Liver Function Tests (LFT)\n H1n1 Test (Swine Flu)\n Mp Test (Malarial Parasite)\n Haemoglobin Test\n Hiv Antibody Test\n Kft (Kidney Funtion Test)\n Hba1c (Sugar Test)\n Vitamin D / B12 Test\n',
        'Electro Therapy\n Laser Therapy\n Speech Therapy\n Neck Pain\n Back Pain\n Shoulder Pain & Frozen Shoulder\n Paralysis\n Sports Injury\n Spine Correction',
        'Cognitive Behavioural Therapy (CBT)\n De-Addiction\n Marriage Counselling\n Obsessive Compulsive Disorder (OCD)\n Mood Disorders\n Stress Management Counselling\n Psychoanalysis\n Anger Management\n Life Skill Training',
        'CT Scan\n MRI\n X-Ray\n Ultrasound\n ECG\n Colour Doppler\n ECHO\n Ultrasonography\n Carotid Ultrasound'
      ];

  get healthSolSpecialistArray => [
        'Dentist',
        'Dermatology',
        'Gynaecology',
        'Opthalmologist',
        'Orthopedic',
        'Pathology',
        'Physiotherapy',
        'Phychotherapy',
        'Radiology'
      ];

  get healthSolProcedureArray => [
        'Dental',
        'Dermatology',
        'Gynae',
        'Ophthalmology',
        'Orthopedic',
        'Pathology Tests',
        'Physiotherapy Treatments',
        'Psychotherapy Treatments',
        'Radiology Tests'
      ];

  get enterANewEra => 'Enter a new Era of \n Healthcare';

  get enterEmailOrPhone => 'Please enter your Email id or Mobile Number';

  get phoneNumber => 'Phone Number';

  get countryCode => '+91';

  get enterNumber => 'Enter Number';

  get enterValidNumber => 'Please enter valid phone number';

  get enter => 'ENTER';

  get checkOTP => 'Check OTP';

  get wrongOTPError => 'Wrong OTP Please Try Again!';

  get enterYourOTPMsg =>
      'Enter your 4 digit code that \n you received on your phone';

  get resendCodeIn => 'Resend code in ';

  get resendCode => 'Resend code';

  get signUp => 'Sign up';

  get login => 'Login';

  get male => 'Male';

  get female => 'Female';

  get name => 'Name*';

  get phoneNo => 'Phone No';

  get alternatePhoneNo => 'Alternate Phone No';

  get EmailOrMobileNumber => 'Email id or Mobile Number';

  get emailId => 'Email Id*';

  get dateOfBirth => 'Date of Birth';

  get location => 'Location*';

  get referralCode => 'Enter Referral Code (Optional)';

  get errorMsgEnterFullName => 'Please enter your full name';

  get errorMsgEnterDocName => 'Please enter doctor name';

  get errorMsgEnterHosName => 'Please enter hospital name';

  get errorValidEmailMsg => 'Please enter valid email id';

  get errorEmptyEmailMsg => 'Please enter email id';

  get password => 'Password*';

  get errorMsgPassword => 'Please enter atleast 8 character password';

  get setLocation => 'Set Location';

  get address => 'ADDRESS';

  get houseFlatNo => 'HOUSE/FLAT NO.';

  get landMark => 'LANDMARK';

  get signUpBtn => 'Signup';

  get submit => 'Submit';

  get proceed => 'PROCEED';

  get signUpMsg => 'By registering, you agree to our';

  get termsServices => 'Terms of Service.';

  get professionalRegNo => 'Professional Reg. No*';

  get specialization => 'Specialization';

  get errorMsgEnterProfRegNo => 'Please enter professional reg. no';

  get errorMsgEnterDocDep => 'Please enter department';

  get errorMsgEnterRegNo => 'Please enter registration. no';

  get errorMsgEnterEducation => 'Please enter education qualification';

  get errorMsgEnterSpecialization => 'Please select specialization';

  get errorMsgEnterExp => 'Please enter experience in number';

  get errorMsgAddDoctor => 'Please add atleast one doctor for the registration';

  get experienceInNo => 'Experience (in number)*';

  get profileInformation => 'Profile Information';

  get hospitalName => 'Hospital Name';

  get labName => 'Labs/Diagnostic Center Name';

  get aboutLab => 'About Lab';

  get addressSmall => 'Address';

  get mobileNumber => 'Mobile Number';

  get aboutHospital => 'About Hospital';

  get registrationNo => 'Registration No';

  get addSpecialization => 'Add Specialization';

  get addSpecializationServices => 'Add Specialization & Service';

  get add => 'Add';

  get addDoctors => 'Add Doctors';

  get addManually => 'Add Manually';

  get manageAccount => 'Manage Account';

  get addUsers => 'Add Users';

  get admin => 'Admin';

  get userEmail => 'User Email';

  get userPassword => 'User Password';

  get profileImage => 'Profile Image';

  get upload => 'Upload';

  get fullName => 'Full Name';

  get educationQualification => 'Education Qualification';

  get designation => 'Designation';

  get department => 'Department';

  get availability => 'Availability';

  get forgotPassword => 'Forgot password?';

  get dontHaveAccount => 'Don\'t have an account? ';

  get somethingWentWrong => 'Somehting went wrong!';

  get success => 'Success';

  get forgotPasswordTitle => 'Forgot Password';

  get cancel => 'Cancel';

  get resetPassword => 'Reset Password';

  get reset => 'Reset';

  get createPassword => 'Create Password';

  get changePasswordMsg =>
      'Enter your old password once and the new password twice to confirm';

  get createPasswordMsg => 'Enter your New password twice to confirm';

  get currentPassword => 'Current Password';

  get newPassword => 'New Password';

  get reEnterPassword => 'Re-enter New Password';

  get changePassword => 'Change Password';

  get change => 'Change';

  get create => 'Create';

  get emptyOldPasswordError => "Please enter your current password";

  get emptyConfirmPasswordError => "Please Re-enter new password.";

  get emptyNewPasswordError => "Please enter new password.";

  get emptyPasswordError => "Please enter password.";

  get passwordMismatchError =>
      "New Password and Re-enter New Password do not match.";

  get profile => 'PROFILE';

  get notification => 'NOTIFICATION';

  get enquiry => 'ENQUIRY';

  get plockr => 'PLOCKR';

  get plocker => 'Plockr';

  get solution => 'SOLUTION';

  get home => 'HOME';

  get appointments => 'Appointments';

  get help => 'Help';

  get logout => 'Log Out';

  get settings => 'Settings';

  get aboutUs => 'About Us';

  get generalUser => 'General User';

  get myAvailability => 'My Availability';

  get managePayment => 'Manage Payment';

  get availOfferMsg => 'People availing offers near you';

  get solutionNearYouMsg =>
      'Health Solutions Near you \n Avail upto 50% discount on this';

  get searchNearByMsg => 'Search for the best price \n solution near you';

  get searchHint => 'Procedures, Medical Tests, Appointments';

  get solutionActivity => 'Solution Activities';

  get availUpTo => 'Avail upto 50% discount';

  get ok => 'OK';

  get viewMore => 'View more';

  get editProfile => 'Edit Profile';

  get profiles => 'Profile';

  get locationSep => 'Location';

  get gender => 'Gender';

  get education => 'Education';

  get college => 'College/University';

  get achievements => 'Achievements';

  get achievement => 'Achievement';

  get utilityNetwork => 'Utility Network';

  get more => 'More';

  get catalogue => 'Catalogue';

  get areaExpertise => 'Area of Expertise';

  get expOfPractice => 'Experience of Practice';

  get practising => 'Practising';

  get qualification => 'Qualification';

  get introduction => 'Introduction';

  get achievementBook => 'Achievement Book';

  get deleteAchievementMsg => 'Do you want to delete this Achievement?';

  get shareYourAchievement => 'Share your Achievement';

  get removeImageMsg => 'Do you want to remove this image?';

  get update => 'Update';

  get speciality => 'Speciality';

  get logoutMsg => 'Do you want to logout?';

  get logoutAllMsg => 'Do you want to logout from all devices?';

  get deleteReportMsg => 'Do you want to delete this report?';

  get deleteNotificationMsg => 'Do you want to delete notification?';

  get edit => 'Edit';

  get chooseSpeciality => 'Choose Speciality';

  get teamOfExperts => 'Team of Experts';

  get registration => 'Registration';

  get accountSettings => 'Account Settings';

  get securitySettings => 'Security Settings';

  get notifications => 'Notifications';

  get logoutFromAllDevices => 'Logout from all devices';

  get iHaveIssueWith => 'I have an issue with';

  get bookingAppointments => 'Booking Appointments';

  get bookingFailure => 'Booking failure';

  get wrongContactDetails => 'Wrong lab/contact details';

  get appointmentDelayed => 'Appointment delayed or cancelled';

  get cancellingAppointment => 'Cancelling/rescheduling an appointment';

  get smsOtpIssues => 'SMS/OTP issues';

  get onlineSolution => 'Online Solution';

  get questionsNotAns => 'Questions not answered';

  get notHappyWithRes => 'Not happy with response';

  get paymentIssues => 'Payment issues';

  get feedBacks => 'Feedbacks';

  get feedBackNotPublished => 'My feedback is not getting published';

  get unableWriteFeedBack => 'Unable to write a feedback';

  get wantEditFeedBack => 'I want to edit my feedback';

  get description => 'Description';

  get successfullySent => 'Successfully Sent..';

  get uploadReports => 'Upload Reports';

  get search => 'Search';

  get reportName => 'Report Name';

  get addNotes => 'Add Notes';

  get noRecordsFound => 'No Record(s) Found';

  get referAndEarn => 'Refer & Earn';

  get coupons => 'Coupons';

  get copyToClipboard => 'Copy to clipboard';

  get inviteFriends => 'Invite Friends';

  get copyCode => 'Copy code';

  get shareYourInviteCode => 'Share Your Invite Code';

  get availableCredits => 'Available Credits';

  get cashCanBeUsed =>
      'Cash can be used on all the medical procedures, appointments & tests';

  get inviteYourFriends => 'Invite your friends & get\nRs 100 each';

  get text1Referral =>
      'Share the code below or ask them to enter it when they sign up';

  get text2Referral =>
      'You will get instant cash as soon as your friend registers successfully';

//  ///Solution strings
//  static const String solutionSearched = "Solution Searched";
//  static const String consultations = "Consultations";
//  static const String tests = "Tests";
//  static const String procedures = "Procedures";
//  static const String NA = "NA";
//  static const String negotiateForBestPrice =
//      "Negotiate for the best price solution near you";
//  static const String previousActivities = "Previous Activities";
//  static const String noSolutionsAvailable = "No solutions available";
//  static const String consultationNotAvailable = "Consultation not available";
//  static const String proceduresNotAvailable = "Procedures not available";
//  static const String testsNotAvailable = "Tests not available";
//  static const String serviceNotAvailable =
//      "Currently this service is not available";
//  static const String weAreGettingBestSolution =
//      "WE ARE GETTING THE BEST SOLUTIONS FOR YOU";
//  static const String receiving = "Receiving...";
//  static const String checkAvailability = "Check Availability";
//  static const String bookIn = "Book in ";
//  static const String homeCollectionAvailable = "Home Collection Available";
//  static const String oopsServiceNotAvailable =
//      "Oops, seems like we are not providing services in your area, kindly search in gurgoun location.";
//  static const String save = "Save";
//  static const String kmsAway = "kms away";
//  static const String book = "Book";
//  static const String viewDetails = 'View Details';
//  static const String confirmYourBooking = "Confirm your Booking";
//  static const String negotiating = "Negotiating. . .";

  static const String prePayConfirmBooking =
      "Make a payment of  300/- to confirm the booking";

  String get invalidPhoneNumber =>
      'Valid phone number is required. Digit must be equals to 10';
}
