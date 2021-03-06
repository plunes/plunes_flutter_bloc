/// Created by Manvendra Kumar Singh


final stringsFile = StringsFile();

class StringsFile {
  static String exceptionMsg = 'An error occurred when converting a color';
  static String noInternetMsg = 'No Internet';
  static String cantConnectInternet = 'Can\'t connect to the Internet ';
  static String tryAgain = 'Try Again';

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

  get healthSolSpecialistArray => ['Dentist', 'Dermatology', 'Gynaecology', 'Opthalmologist', 'Orthopedic', 'Pathology', 'Physiotherapy', 'Phychotherapy', 'Radiology'];

  get healthSolProcedureArray => ['Dental', 'Dermatology', 'Gynae', 'Ophthalmology', 'Orthopedic', 'Pathology Tests', 'Physiotherapy Treatments', 'Psychotherapy Treatments', 'Radiology Tests'];

  get enterANewEra => 'Enter a new Era of \n Healthcare';
  get enterEmailOrPhone => 'Please enter your Email id or Mobile Number';
  get phoneNumber => 'Phone Number';
  get countryCode => '+91';
  get enterNumber => 'Enter Number';
  get enterValidNumber => 'Please enter valid phone number';
  get enter => 'ENTER';
  get checkOTP => 'Check OTP';
  get wrongOTPError => 'Wrong OTP Please Try Again!';
  get enterYourOTPMsg => 'Enter your 4 digit code that \n you received on your phone';
  get resendCodeIn => 'Resend code in ';
  get resendCode => 'Resend code';
  get signUp => 'Sign up';
  get login => 'Login';
  get male => 'Male';
  get female=> 'Female';
  get name =>'Name*';
  get phoneNo =>'Phone No';
  get emailId => 'Email Id*';
  get dateOfBirth => 'Date of Birth';
  get location => 'Location*';
  get referralCode => 'Enter Referral Code (Optional)';
  get errorMsgEnterFullName=> 'Please enter your full name';
  get errorMsgEnterDocName=> 'Please enter doctor name';

  get errorMsgEnterHosName=> 'Please enter hospital name';

  get errorValidEmailMsg => 'Please enter valid email id';
  get errorEmptyEmailMsg => 'Please enter email id';

  get password => 'Password*';
  get errorMsgPassword => 'Please enter atleast 8 character password';
  get setLocation => 'Set Location';
  get address =>'ADDRESS';
  get houseFlatNo => 'HOUSE/FLAT NO.';
  get landMark => 'LANDMARK';
  get signUpBtn=> 'Signup';
  get submit => 'Submit';
  get proceed => 'PROCEED';
  get signUpMsg => 'By registering, you agree to our';
  get termsServices => 'Terms of Service.';
  get professionalRegNo =>'Professional Reg. No*';
  get specialization =>'Specialization';
  get errorMsgEnterProfRegNo => 'Please enter professional reg. no';
  get errorMsgEnterDocDep => 'Please enter department';

  get errorMsgEnterRegNo => 'Please enter registration. no';
  get errorMsgEnterEducation => 'Please enter education qualification';

  get errorMsgEnterSpecialization => 'Please select specialization';
  get errorMsgEnterExp =>'Please enter experience in number';
  get errorMsgAddDoctor =>'Please add atleast one doctor for the registration';

  get experienceInNo => 'Experience (in number)*';
  get profileInformation => 'Profile Information';
  get hospitalName => 'Hospital Name';
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
  get forgotPassword =>'Forgot password?';
  get dontHaveAccount =>'Don\'t have an account? ';
  get somethingWentWrong => 'Somehting went wrong!';
  get success => 'Success';
  get forgotPasswordTitle =>'Forgot Password';
  get cancel => 'Cancel';
  get resetPassword => 'Reset Password';
  get createPassword => 'Create Password';
  get changePasswordMsg => 'Enter your old password once and the new password twice to confirm';
  get createPasswordMsg => 'Enter your New password twice to confirm';
  get currentPassword => 'Current Password';
  get newPassword => 'New Password';
  get reEnterPassword => 'Re-enter New Password';
  get changePassword => 'Change Password';
  get reset => 'Reset';
  get change => 'Change';
  get create => 'Create';
  get emptyOldPasswordError => "Please enter your current password";
  get emptyConfirmPasswordError => "Please Re-enter new password.";
  get emptyNewPasswordError => "Please enter new password.";
  get emptyPasswordError => "Please enter password.";

  get passwordMismatchError => "New Password and Re-enter New Password do not match.";
  get profile => 'PROFILE';
  get notification => 'NOTIFICATION';
  get enquiry => 'ENQUIRY';
  get plockr => 'PLOCKR';
  get plocker => 'Plockr';

  get solution => 'SOLUTION';
  get appointments => 'Appointments';
  get help => 'Help';
  get logout => 'Log Out';
  get settings => 'Settings';
  get aboutUs => 'About Us';
  get generalUser => 'General User';
  get myAvailability => 'My Availability';
  get managePayment => 'Manage Payment';
  get availOfferMsg => 'People availing offers near you';
  get solutionNearYouMsg => 'Health Solutions Near you \n Avail upto 50% discount on this';
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
  get expOfPractice =>'Experience of Practice';
  get practising => 'Practising';
  get qualification => 'Qualification';
  get introduction => 'Introduction';
  get achievementBook => 'Achievement Book';
  get deleteAchievementMsg => 'Do you want to delete this Achievement?';
  get shareYourAchievement => 'Share your Achievement';
  get removeImageMsg => 'Do you want to remove this image?';
  get update => 'Update';
  get speciality => 'Speciality';
  get logoutMsg  => 'Do you want to logout?';
  get logoutAllMsg  => 'Do you want to logout from all devices?';
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
  get smsOtpIssues=> 'SMS/OTP issues';
  get onlineSolution => 'Online Solution';
  get questionsNotAns => 'Questions not answered';
  get notHappyWithRes => 'Not happy with response';
  get paymentIssues => 'Payment issues';
  get feedBacks => 'Feedbacks';
  get feedBackNotPublished => 'My feedback is not getting published';
  get unableWriteFeedBack => 'Unable to write a feedback';
get wantEditFeedBack =>'I want to edit my feedback';
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
get cashCanBeUsed => 'Cash can be used on all the medical procedures, appointments & tests';
get inviteYourFriends => 'Invite your friends & get\nRs 100 each';
get text1Referral => 'Share the code below or ask them to enter it when they sign up';
  get text2Referral => 'You will get instant cash as soon as your friend registers successfully';










}
