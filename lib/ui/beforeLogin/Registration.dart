import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geocoder_location/geocoder.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart' as loc;
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/analytics.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/beforeLogin/Login.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import 'package:plunes/ui/commonView/SelectSpecialization.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - Registration class is for sign up into the application for all User Type: General User, Doctor and Hospital.
 */

typedef PasswordCallback = void Function(bool flag);

// ignore: must_be_immutable
class Registration extends BaseActivity {
  static const tag = "/registration";
  final String? phone;

  Registration({this.phone});

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration>
    with SingleTickerProviderStateMixin
    implements DialogCallBack {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final specializationController = TextEditingController();
  final professionRegController = TextEditingController();
  final experienceController = TextEditingController();
  final passwordController = TextEditingController();
  final locationController = TextEditingController();
  final referralController = TextEditingController();
  final phoneController = TextEditingController();
  final alternatePhoneController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final dobController = TextEditingController();

  /// Hospital Controllers ******************************************

  final docDesignationController = new TextEditingController();
  final docDepartmentController = new TextEditingController();
  final docEducationController = new TextEditingController();
  final doc_availability_from = new TextEditingController();
  final doc_availability_to = new TextEditingController();
  final docNameController = new TextEditingController();
  final aboutController = new TextEditingController();
  final fullAddressController = new TextEditingController();

  List<DropdownMenuItem<String>>? _dropDownMenuItems;
  List<dynamic>? _selectedItemId = [],
      _doctorsList = [],
      _selectedSpecializationData = [];
  String? _userType, _latitude, _longitude, gender = plunesStrings.male;
  bool isExperienceValid = true,
      _passwordVisible = true,
      progress = false,
      isNameValid = true,
      isEmailValid = true,
      isPasswordValid = true,
      isProfessionValid = true,
      isLocationValid = true,
      isSpecificationValid = true;
  var location = new loc.Location(),
      globalHeight,
      globalWidth,
      errorMessage = '';
  FocusNode nameFocusNode = new FocusNode(),
      phoneFocusNode = new FocusNode(),
      emailFocusNode = new FocusNode(),
      passwordFocusNode = new FocusNode(),
      referralFocusNode = new FocusNode(),
      profRegNoFocusNode = new FocusNode(),
      expFocusNode = new FocusNode();
  int data = 1, male = 0, female = 1;
  var image;
  UserBloc? _userBloc;
  String? _failureCause;
  late bool _isProcessing;
  late Preferences _preferenceObj;
  BuildContext? _context;
  TabController? _tabController;
  int? _previousTabIndex;

  @override
  void initState() {
    _previousTabIndex = 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _userBloc = UserBloc();
    _isProcessing = false;
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _userBloc?.dispose();
    disposeControllers();
    super.dispose();
  }

  void initialize() {
    _dropDownMenuItems = widget.getDropDownMenuItems();
    _userType = Constants.generalUser.toString();
    doc_availability_from.text = "00:00 AM";
    doc_availability_to.text = "00:00 PM";
    if (CommonMethods.catalogueLists == null ||
        CommonMethods.catalogueLists!.isEmpty) {
      _isProcessing = true;
      _getSpecialities();
    }
    _getLocation();
  }

  void _getLocation() async {
    _preferenceObj = new Preferences();
    _latitude = _preferenceObj.getPreferenceString(Constants.LATITUDE);
    _longitude = _preferenceObj.getPreferenceString(Constants.LONGITUDE);
    if (_latitude == null ||
        _longitude == null ||
        _latitude!.isEmpty ||
        _longitude!.isEmpty ||
        _latitude == "0.0" ||
        _longitude == "0.0") {
      await Future.delayed(Duration(milliseconds: 400));
      var latLong = await LocationUtil().getCurrentLatLong(_context);
      if (latLong != null) {
        _latitude = latLong.latitude.toString();
        _longitude = latLong.longitude.toString();
      }
    }
    _setLocationData();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Material(
        child: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(),
            child: _isProcessing
                ? CustomWidgets().getProgressIndicator()
                : _failureCause == null
                    ? Scaffold(
                        key: _scaffoldKey,
                        appBar: AppBar(
                          automaticallyImplyLeading: true,
                          backgroundColor: Colors.white,
                          brightness: Brightness.light,
                          iconTheme: IconThemeData(color: Colors.black),
                          centerTitle: true,
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              Navigator.pop(context, false);
                              return;
                            },
                          ),
                          title: Text(plunesStrings.signUp,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.none,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      colorsFile.black)),
                                  fontWeight: FontWeight.w500)),
                          bottom: TabBar(
                            controller: _tabController,
                            onTap: (int selectedIndex) {
                              if (selectedIndex == _previousTabIndex) {
                                return;
                              } else if (selectedIndex == 0) {
                                _userType = Constants.generalUser.toString();
                              } else if (selectedIndex == 1) {
                                _userType = Constants.hospital.toString();
                              }
                              _previousTabIndex = selectedIndex;
                              Future.delayed(Duration(milliseconds: 500))
                                  .then((value) {
                                _onTabChange();
                              });
                            },
                            indicatorColor:
                                CommonMethods.getColorForSpecifiedCode(
                                    "#107C6F"),
                            tabs: [
                              Tab(
                                child: Text(
                                  "Personal",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: PlunesColors.BLACKCOLOR),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "Medical",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: PlunesColors.BLACKCOLOR),
                                ),
                              ),
                            ],
                          ),
                        ),
                        backgroundColor: Colors.white,
                        body: Builder(builder: (context) {
                          _context = context;
                          return bodyView();
                        }))
                    : CustomWidgets().errorWidget(_failureCause,
                        onTap: () => _getSpecialities())));
  }

  Widget bodyView() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _getUserView(),
          Column(
            children: [
              _professionalTypeSelectionWidget(),
              Expanded(
                  child: (_userType == Constants.hospital.toString())
                      ? _getHospitalView()
                      : (_userType == Constants.doctor.toString())
                          ? _getDoctorView()
                          : _getLabView()),
            ],
          )
        ],
      ),
    );
  }

  // Widget userTypeDropDown() {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
  //     child: DropdownButtonFormField(
  //       value: _userType,
  //       items: _dropDownMenuItems,
  //       icon: Image.asset(
  //         "assets/images/arrow-down-Icon.png",
  //         color: PlunesColors.GREYCOLOR,
  //         width: 20,
  //         height: 20,
  //       ),
  //       onChanged: changedDropDownItem,
  //       decoration: widget.myInputBoxDecoration(colorsFile.lightGrey1,
  //           colorsFile.lightGrey1, null, null, true, null),
  //     ),
  //   );
  // }

  getHospitalSpecializationData() {
    showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) =>
            SelectSpecialization(
                spec: CommonMethods.catalogueLists,
                from: Constants.hospital,
                selectedItemId: _selectedItemId,
                selectedItemData: _selectedSpecializationData)).then((val) {
      if (val != '' && val != null) {
        _selectedItemId = [];
        _selectedSpecializationData = [];
        _selectedItemId!.addAll(val['SelectedId']);
        _selectedSpecializationData!.addAll(val['SelectedData']);
        _setState();
      }
    });
  }

  Widget _getHospitalView() {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                _getProfileInformationTextWidget(),
                _getSpacer(),
                createTextField(nameController, plunesStrings.hospitalName,
                    TextInputType.text, TextCapitalization.words, true, ''),
                _getSpacer(),
                createTextField(locationController, plunesStrings.location,
                    TextInputType.text, TextCapitalization.none, false, ''),
                _getSpacer(),
                createTextField(
                    fullAddressController,
                    plunesStrings.fullAddress,
                    TextInputType.text,
                    TextCapitalization.none,
                    true,
                    ''),
                _getSpacer(),
                createTextField(phoneController, plunesStrings.phoneNo,
                    TextInputType.number, TextCapitalization.none, false, ''),
                _getSpacer(),
                createTextField(
                    alternatePhoneController,
                    plunesStrings.alternatePhoneNo,
                    TextInputType.number,
                    TextCapitalization.none,
                    true,
                    ''),
                _getSpacer(),
                createTextField(aboutController, plunesStrings.aboutHospital,
                    TextInputType.text, TextCapitalization.none, true, ''),
                _getSpacer(),
                createTextField(
                    professionRegController,
                    plunesStrings.registrationNo,
                    TextInputType.text,
                    TextCapitalization.characters,
                    true,
                    ''),
                _getSpacer(),
                _getProfileInformationTextWidget(
                    text: plunesStrings.addSpecialization),
                _getSpacer(),
                widget.getSpacer(0.0, 10.0),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 5,
                      vertical: AppConfig.verticalBlockSize * 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                          color:
                              CommonMethods.getColorForSpecifiedCode("#707070"),
                          width: 0.4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.createTextViews(
                          plunesStrings.addSpecializationServices,
                          16,
                          colorsFile.lightGrey2,
                          TextAlign.center,
                          FontWeight.w100),
                      widget.getSpacer(0.0, 8.0),
                      Container(
                        margin: EdgeInsets.only(
                            right: AppConfig.horizontalBlockSize * 58),
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: getHospitalSpecializationData,
                          child: CustomWidgets().getRoundedButton(
                              plunesStrings.add,
                              5,
                              CommonMethods.getColorForSpecifiedCode("#BCDAD7"),
                              AppConfig.horizontalBlockSize * 0,
                              AppConfig.verticalBlockSize * 1.2,
                              CommonMethods.getColorForSpecifiedCode("#107C6F"),
                              hasBorder: true,
                              borderWidth: 0.4,
                              borderColor:
                                  CommonMethods.getColorForSpecifiedCode(
                                      "#107C6F")),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.getSpacer(0.0, 5.0),
                Container(
                  child: getSpecializationRow(),
                  margin: EdgeInsets.only(left: 8),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _getSpacer(),
                widget.getDividerRow(context, 0.0, 1.0, 0.0),
                _getProfileInformationTextWidget(
                    text: plunesStrings.addUsers.toString().substring(
                        0, plunesStrings.addUsers.toString().length - 1)),
                _getSpacer(),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: widget.createTextViews(plunesStrings.admin, 18,
                      "#000000", TextAlign.left, FontWeight.w500),
                ),
                widget.getSpacer(0.0, 10.0),
                createTextField(
                    emailController,
                    plunesStrings.userEmail,
                    TextInputType.emailAddress,
                    TextCapitalization.none,
                    isEmailValid,
                    plunesStrings.errorValidEmailMsg),
                widget.getSpacer(0.0, 20.0),
                getPasswordRow(plunesStrings.userPassword),
                _getSubmitButtonView()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getUserView() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: <Widget>[
          _getGenderRow(),
          _getSpacer(),
          createTextField(
              nameController,
              plunesStrings.name,
              TextInputType.text,
              TextCapitalization.words,
              isNameValid,
              plunesStrings.errorMsgEnterFullName),
          _getSpacer(),
          createTextField(phoneController, plunesStrings.phoneNo,
              TextInputType.number, TextCapitalization.none, false, ''),
          _getSpacer(),
          createTextField(
              emailController,
              plunesStrings.emailId,
              TextInputType.emailAddress,
              TextCapitalization.none,
              isEmailValid,
              plunesStrings.errorValidEmailMsg),
          _getSpacer(),
          createTextField(dobController, plunesStrings.dateOfBirth,
              TextInputType.datetime, TextCapitalization.none, false, ''),
          _getSpacer(),
          getPasswordRow(plunesStrings.password),
          _getSpacer(),
          createTextField(referralController, plunesStrings.referralCode,
              TextInputType.text, TextCapitalization.none, true, ''),
          _getSpacer(),
          _getSubmitButtonView()
        ],
      ),
    );
  }

  Widget _getSpacer() {
    return widget.getSpacer(0.0, 20.0);
  }

  Widget _getDoctorView() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _getProfileInformationTextWidget(),
          _getSpacer(),
          _getGenderRow(),
          _getSpacer(),
          createTextField(
              nameController,
              plunesStrings.name,
              TextInputType.text,
              TextCapitalization.words,
              isNameValid,
              plunesStrings.errorMsgEnterFullName),
          _getSpacer(),
          createTextField(phoneController, plunesStrings.phoneNo,
              TextInputType.number, TextCapitalization.none, false, ''),
          _getSpacer(),
          createTextField(
              alternatePhoneController,
              plunesStrings.alternatePhoneNo,
              TextInputType.number,
              TextCapitalization.none,
              true,
              ''),
          _getSpacer(),
          createTextField(
              emailController,
              plunesStrings.emailId,
              TextInputType.emailAddress,
              TextCapitalization.none,
              isEmailValid,
              plunesStrings.errorValidEmailMsg,
              hasOutlinedBorder: true),
          _getSpacer(),
          createTextField(dobController, plunesStrings.dateOfBirth,
              TextInputType.datetime, TextCapitalization.none, false, '',
              hasOutlinedBorder: true),
          _getSpacer(),
          createTextField(locationController, plunesStrings.location,
              TextInputType.text, TextCapitalization.none, false, '',
              hasOutlinedBorder: true),
          _getSpacer(),
          createTextField(fullAddressController, plunesStrings.fullAddress,
              TextInputType.text, TextCapitalization.none, true, '',
              hasOutlinedBorder: true),
          _getSpacer(),
          Column(children: <Widget>[
            createTextField(
                professionRegController,
                plunesStrings.professionalRegNo,
                TextInputType.text,
                TextCapitalization.words,
                isProfessionValid,
                plunesStrings.errorMsgEnterProfRegNo,
                hasOutlinedBorder: true),
            _getSpacer(),
            createTextField(
                specializationController,
                '${plunesStrings.specialization}*',
                TextInputType.text,
                TextCapitalization.words,
                isSpecificationValid,
                plunesStrings.errorMsgEnterSpecialization,
                hasOutlinedBorder: true),
            _getSpacer(),
            createTextField(
                experienceController,
                plunesStrings.experienceInNo,
                TextInputType.numberWithOptions(signed: true, decimal: true),
                TextCapitalization.none,
                isExperienceValid,
                plunesStrings.errorMsgEnterExp,
                hasOutlinedBorder: true),
            _getSpacer(),
            getPasswordRow(plunesStrings.password),
          ]),
          _getSubmitButtonView()
        ],
      ),
    );
  }

  Widget getPasswordRow(title) {
    return Stack(
      children: <Widget>[
        createTextField(
            passwordController,
            title,
            TextInputType.text,
            TextCapitalization.none,
            isPasswordValid,
            plunesStrings.errorMsgPassword),
        Container(
          margin: EdgeInsets.only(right: 10, top: 10),
          child: Align(
              alignment: FractionalOffset.centerRight,
              child: InkWell(
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                child: _passwordVisible
                    ? Image.asset(
                        "assets/images/eye-with-a-diagonal-line3x.png",
                        width: 24,
                        height: 24,
                      )
                    : Icon(Icons.visibility),
              )),
        ),
      ],
    );
  }

  fetchLocation() {
    Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => LocationFetch()))
        .then((val) {
      if (val == null) {
        return;
      }
      var addressControllerList = [];
      addressControllerList = val.toString().split(":");
      locationController.text = addressControllerList[0] +
          ' ' +
          addressControllerList[1] +
          ' ' +
          addressControllerList[2];
      _latitude = addressControllerList[3];
      _longitude = addressControllerList[4];
      _setState();
    });
  }

  getSpecializationData() {
    showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) =>
            SelectSpecialization(
                spec: CommonMethods.catalogueLists,
                from: Constants.doctor,
                selectedItemId: _selectedItemId,
                selectedItemData: _selectedSpecializationData)).then((val) {
      if (val != '' && val != null) {
        _selectedItemId = val['SelectedId'];
        specializationController.text = val['SelectedData']
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '');
      }
    });
  }

  Widget getSpecializationRow() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.getSpacer(0.0, 12.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: widget.createTextViews(
                      _selectedSpecializationData![index],
                      18,
                      colorsFile.black0,
                      TextAlign.start,
                      FontWeight.normal),
                ),
                InkWell(
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSpecializationData!.removeAt(index);
                      _selectedItemId!.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            widget.getSpacer(0.0, 12.0),
            Container(
              height: 0.3,
              color: Colors.grey,
            ),
          ],
        );
      },
      itemCount: _selectedSpecializationData!.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }

  _showProfessionalRegistrationSuccessPopup(LoginPost data) async {
    showDialog(
        context: _context!,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: AppConfig.verticalBlockSize * 1.5,
                        left: AppConfig.horizontalBlockSize * 2.5,
                        right: AppConfig.horizontalBlockSize * 2.5),
                    child: Image.asset(
                      PlunesImages.profVerificationImage,
                      height: 74,
                      width: 122,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: AppConfig.verticalBlockSize * 1.5,
                        left: AppConfig.horizontalBlockSize * 2.5,
                        right: AppConfig.horizontalBlockSize * 2.5),
                    child: Text(
                      "Thank You for Submitting your details.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 1.5,
                        horizontal: AppConfig.horizontalBlockSize * 2.5),
                    child: Text(
                      "Our Team will get in touch with you soon regarding the Verification of your Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Container(
                    child: CustomWidgets().getSingleButtonForPopup(
                        onTap: () {
                          Navigator.maybePop(context);
                        },
                        roundedValue: 9,
                        buttonBackground: Colors.white,
                        buttonText: "OK",
                        textColor: PlunesColors.GREENCOLOR),
                  )
                ],
              ),
            ),
          );
        }).then((value) async {
      await bloc.saveDataInPreferences(
          data, context, plunesStrings.registration);
    });
  }

  _submitRegistrationRequest() async {
    if (validation()) {
      List specialistId = [];
      for (var item in _selectedItemId!)
        specialistId.add({'specialityId': item});
      Map<String, dynamic> body = {};
      body['name'] = nameController.text;
      body['gender'] = gender == 'Male' ? 'M' : 'F';
      body['mobileNumber'] = phoneController.text;
      body['alternateNumber'] = alternatePhoneController.text;
      body['email'] = emailController.text.trim();
      body['verifiedUser'] = 'true';
      body['password'] = passwordController.text;
      if (this._latitude != null &&
          this._longitude != null &&
          this._latitude!.isNotEmpty &&
          this._longitude!.isNotEmpty &&
          _userType != Constants.generalUser) {

        // body['location'] = Location('Point', coordinates: [
        //   double.parse(this._longitude!),
        //   double.parse(this._latitude!)
        // ]).toJson();
      }
      body['userType'] =
          _userType == Constants.generalUser ? 'User' : _userType;
      if (_userType != Constants.generalUser) {
        body['address'] = fullAddressController.text.trim();
        body['googleAddress'] = locationController.text.trim();
      }
      body['deviceId'] = Constants.DEVICE_TOKEN;
      if (_userType != Constants.hospital &&
          _userType != Constants.labDiagnosticCenter) {
        body['birthDate'] = dobController.text;
        body['referralCode'] = referralController.text;
      }
      if (_userType == Constants.doctor ||
          _userType == Constants.hospital ||
          _userType == Constants.labDiagnosticCenter) {
        body['registrationNumber'] = professionRegController.text;
        body["specialities"] = specialistId;
        if (_userType == Constants.doctor) {
          body['experience'] = experienceController.text;
        }
        if (_userType == Constants.hospital ||
            _userType == Constants.labDiagnosticCenter) {
          body['biography'] = aboutController.text;
          body['doctors'] = _doctorsList;
        }
      }
      progress = true;
      _setState();
      await Future.delayed(Duration(milliseconds: 50));
      var result = await _userBloc!.signUp(body);
      progress = false;
      _setState();
      await Future.delayed(Duration(milliseconds: 50));
      if (result is RequestSuccess) {
        LoginPost data = result.response;
        if (data.success!) {
          _setShowCaseStatus();
          AnalyticsProvider().registerEvent(AnalyticsKeys.signUpKey);
          if (_userType != Constants.generalUser) {
            _showProfessionalRegistrationSuccessPopup(data);
          } else {
            await bloc.saveDataInPreferences(
                data, context, plunesStrings.registration);
          }
        } else {
          widget.showInSnackBar(
              data.message, PlunesColors.BLACKCOLOR, _scaffoldKey);
        }
      } else if (result is RequestFailed) {
        widget.showInSnackBar(
            result.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
      } else {
        widget.showInSnackBar(plunesStrings.somethingWentWrong,
            PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    } else {
      widget.showInSnackBar(
          errorMessage, PlunesColors.BLACKCOLOR, _scaffoldKey);
    }
  }

  bool _isDoctorType() {
    return _userType != null && _userType == Constants.doctor.toString();
  }

  bool _isUserType() {
    return _userType != null && _userType == Constants.generalUser.toString();
  }

  bool _isHospitalType() {
    return _userType != null && _userType == Constants.hospital.toString();
  }

  bool _isLabType() {
    return _userType != null &&
        _userType == Constants.labDiagnosticCenter.toString();
  }

  bool validation() {
    if (nameController.text.trim().isEmpty ||
        (_isDoctorType() && nameController.text.toString().length < 6) ||
        (nameController.text.toString().length < 2)) {
      errorMessage = _isDoctorType()
          ? plunesStrings.errorMsgEnterDoctorName
          : PlunesStrings.nameMustBeGreaterThanTwoChar;
      return false;
    } else if ((_isHospitalType() || _isLabType()) &&
        professionRegController.text.isEmpty) {
      errorMessage = plunesStrings.errorMsgEnterRegNo;
      return false;
    } else if (emailController.text.trim().isEmpty) {
      errorMessage = plunesStrings.errorEmptyEmailMsg;
      return false;
    } else if (!CommonMethods.validateEmail(emailController.text.trim())) {
      errorMessage = plunesStrings.errorValidEmailMsg;
      return false;
    } else if (passwordController.text.isEmpty) {
      errorMessage = plunesStrings.emptyPasswordError;
      return false;
    } else if (passwordController.text.length < 8) {
      errorMessage = plunesStrings.errorMsgPassword;
      return false;
    } else if (_isUserType() &&
        (locationController.text.isEmpty ||
            _latitude == null ||
            _latitude!.isEmpty ||
            _latitude == "0.0" ||
            _longitude == null ||
            _longitude!.isEmpty ||
            _longitude == "0.0")) {
      errorMessage = PlunesStrings.pleaseSelectALocation;
      return false;
    } else if (_userType != Constants.generalUser &&
        (fullAddressController.text.trim().isEmpty)) {
      errorMessage = plunesStrings.errorFullAddressRequired;
      return false;
    } else if (_isDoctorType() && professionRegController.text.trim().isEmpty) {
      errorMessage = plunesStrings.errorMsgEnterProfRegNo;
      return false;
    } else if (_isDoctorType() &&
        specializationController.text.trim().isEmpty) {
      errorMessage = plunesStrings.errorMsgEnterSpecialization;
      return false;
    } else if ((_isLabType() || _isHospitalType()) &&
        (_selectedItemId == null || _selectedItemId!.isEmpty)) {
      errorMessage = plunesStrings.errorMsgEnterSpecialization;
      return false;
    } else if (_isDoctorType() && experienceController.text.trim().isEmpty) {
      errorMessage = plunesStrings.errorMsgEnterExp;
      return false;
    } else if (_userType != Constants.user &&
        alternatePhoneController.text.trim().isNotEmpty &&
        alternatePhoneController.text.trim().length != 10) {
      errorMessage = plunesStrings.invalidPhoneNumber;
      return false;
    } else {
      return true;
    }
  }

  @override
  dialogCallBackFunction(String action) {}

  _resetFormData() {
    _selectedItemId = [];
    experienceController.text = '';
    specializationController.text = '';
    professionRegController.text = '';
    passwordController.text = '';
    emailController.text = '';
    alternatePhoneController.text = '';
    aboutController.clear();
    _selectedSpecializationData = [];
    gender = plunesStrings.male.toString();
  }

  _onTabChange() {
    if (mounted)
      setState(() {
        if (_userType == 'Doctor') {
          nameController.text = "Dr. ";
        } else if (_userType == 'Hospital') {
          nameController.text = '';
          dobController.text = '';
        } else if (_userType == Constants.labDiagnosticCenter) {
          nameController.text = '';
          dobController.text = '';
        } else {
          nameController.text = '';
        }
        _resetFormData();
      });
  }

  Widget _getGenderRow() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                    width: 0.4,
                    color: CommonMethods.getColorForSpecifiedCode("#707070")),
                color: gender == plunesStrings.male
                    ? CommonMethods.getColorForSpecifiedCode("#107C6F")
                    : Colors.white),
            child: InkWell(
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onDoubleTap: () {},
              onTap: () {
                gender = plunesStrings.male;
                _setState();
              },
              child: Text(
                "${plunesStrings.male}",
                style: TextStyle(
                    fontSize: 16,
                    color: gender == plunesStrings.male
                        ? PlunesColors.WHITECOLOR
                        : PlunesColors.BLACKCOLOR),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                    width: 0.4,
                    color: CommonMethods.getColorForSpecifiedCode("#707070")),
                color: gender == plunesStrings.female
                    ? CommonMethods.getColorForSpecifiedCode("#107C6F")
                    : Colors.white),
            child: InkWell(
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onDoubleTap: () {},
              onTap: () {
                gender = plunesStrings.female;
                _setState();
              },
              child: Text(
                "${plunesStrings.female}",
                style: TextStyle(
                    fontSize: 16,
                    color: gender == plunesStrings.female
                        ? PlunesColors.WHITECOLOR
                        : PlunesColors.BLACKCOLOR),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _professionalTypeSelectionWidget() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                    width: 0.4,
                    color: CommonMethods.getColorForSpecifiedCode("#707070")),
                color: _userType == Constants.hospital.toString()
                    ? CommonMethods.getColorForSpecifiedCode("#107C6F")
                    : Colors.white),
            child: InkWell(
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onDoubleTap: () {},
              onTap: () {
                if (_userType == Constants.hospital.toString()) {
                  return;
                }
                _userType = Constants.hospital.toString();
                _onTabChange();
              },
              child: Text(
                "${Constants.hospital.toString()}",
                style: TextStyle(
                    fontSize: 16,
                    color: _userType == Constants.hospital.toString()
                        ? PlunesColors.WHITECOLOR
                        : PlunesColors.BLACKCOLOR),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                    width: 0.4,
                    color: CommonMethods.getColorForSpecifiedCode("#707070")),
                color: _userType == Constants.doctor.toString()
                    ? CommonMethods.getColorForSpecifiedCode("#107C6F")
                    : Colors.white),
            child: InkWell(
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onDoubleTap: () {},
              onTap: () {
                if (_userType == Constants.doctor.toString()) {
                  return;
                }
                _userType = Constants.doctor.toString();
                _onTabChange();
              },
              child: Text(
                "${Constants.doctor.toString()}",
                style: TextStyle(
                    fontSize: 16,
                    color: _userType == Constants.doctor.toString()
                        ? PlunesColors.WHITECOLOR
                        : PlunesColors.BLACKCOLOR),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                    width: 0.4,
                    color: CommonMethods.getColorForSpecifiedCode("#707070")),
                color: _userType == Constants.labDiagnosticCenter.toString()
                    ? CommonMethods.getColorForSpecifiedCode("#107C6F")
                    : Colors.white),
            child: InkWell(
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onDoubleTap: () {},
              onTap: () {
                if (_userType == Constants.labDiagnosticCenter.toString()) {
                  return;
                }
                _userType = Constants.labDiagnosticCenter.toString();
                _onTabChange();
              },
              child: Text(
                "${Constants.labDiagnosticCenter.toString()}",
                style: TextStyle(
                    fontSize: 16,
                    color: _userType == Constants.labDiagnosticCenter.toString()
                        ? PlunesColors.WHITECOLOR
                        : PlunesColors.BLACKCOLOR),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget createTextField(
      TextEditingController controller,
      String placeHolder,
      TextInputType inputType,
      TextCapitalization textCapitalization,
      bool fieldFlag,
      String errorMsg,
      {bool hasOutlinedBorder = false}) {
    if (controller == phoneController) controller.text = widget.phone!;
    return InkWell(
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        if (controller == dobController)
          CommonMethods.selectHoloTypeDate(context, isDoc: _isDoctorType())
              .then((value) {
            if (value != null && value.isNotEmpty) {
              dobController.text = value;
            }
          });
        else if (controller == locationController)
          fetchLocation();
        else if (controller == specializationController)
          getSpecializationData();
      },
      child: IgnorePointer(
        ignoring: (_userType != null &&
            _userType == Constants.doctor.toString() &&
            hasOutlinedBorder),
        child: Container(
            padding: EdgeInsets.zero,
            width: MediaQuery.of(context).size.width,
            child: TextField(
              maxLines: (controller == locationController ||
                      controller == aboutController)
                  ? 2
                  : 1,
              maxLength: (controller == aboutController)
                  ? 250
                  : (controller != null &&
                          controller == alternatePhoneController)
                      ? 10
                      : null,
              textCapitalization: textCapitalization,
              obscureText:
                  (controller == passwordController ? _passwordVisible : false),
              keyboardType: inputType,
              inputFormatters: (controller != null &&
                      controller == alternatePhoneController)
                  ? <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                      // WhitelistingTextInputFormatter.digitsOnly
                    ]
                  : (controller != null &&
                          controller == nameController &&
                          _userType == Constants.generalUser)
                      ? [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
              ]
                      : null,
              textInputAction: controller == referralController
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: (String value) {
                setFocus(controller)!.unfocus();
                FocusScope.of(context).requestFocus(setTargetFocus(controller));
              },
              onChanged: (text) {
                setState(() {
                  if (controller == emailController) {
                    isEmailValid = text.length > 0
                        ? CommonMethods.validateEmail(text)
                        : true;
                  } else if (controller == passwordController) {
                    isPasswordValid = text.length > 7 ? true : false;
                  }
                });
              },
              controller: controller,
              cursorColor: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
              focusNode: setFocus(controller),
              enabled: (controller == phoneController ||
                      controller == dobController ||
                      controller == locationController ||
                      (controller == specializationController))
                  ? (_isDoctorType() && hasOutlinedBorder)
                      ? true
                      : false
                  : true,
              style: TextStyle(
                fontSize: 15.0,
              ),
              decoration: hasOutlinedBorder
                  ? widget.myInputBoxDecorationWithOutlinedBorder(
                      colorsFile.defaultGreen,
                      colorsFile.lightGrey1,
                      placeHolder,
                      errorMsg,
                      fieldFlag,
                      controller,
                      passwordController)
                  : widget.myInputBoxDecoration(
                      colorsFile.defaultGreen,
                      colorsFile.lightGrey1,
                      placeHolder,
                      errorMsg,
                      fieldFlag,
                      controller,
                      passwordController),
            )),
      ),
    );
  }

  FocusNode? setFocus(TextEditingController controller) {
    FocusNode? focusNode;
    if (controller == nameController) {
      focusNode = nameFocusNode;
    } else if (controller == phoneController) {
      focusNode = phoneFocusNode;
    } else if (controller == emailController) {
      focusNode = emailFocusNode;
    } else if (controller == passwordController) {
      focusNode = passwordFocusNode;
    } else if (_isDoctorType() && controller == professionRegController) {
      focusNode = profRegNoFocusNode;
    } else if (_isDoctorType() && controller == experienceController) {
      focusNode = expFocusNode;
    } else if (controller == referralController) {
      focusNode = referralFocusNode;
    }
    return focusNode;
  }

  FocusNode? setTargetFocus(TextEditingController controller) {
    FocusNode? focusNode;
    if (controller == nameController) {
      focusNode = emailFocusNode;
    } else if (controller == emailController) {
      focusNode = passwordFocusNode;
    } else if (controller == passwordController && !_isDoctorType()) {
      focusNode = referralFocusNode;
    } else if (controller == passwordController && _isDoctorType()) {
      focusNode = profRegNoFocusNode;
    } else if (controller == professionRegController) {
      focusNode = expFocusNode;
    } else if (controller == experienceController) {
      focusNode = referralFocusNode;
    }
    return focusNode;
  }

  disposeControllers() {
    specializationController.dispose();
    professionRegController.dispose();
    experienceController.dispose();
    profRegNoFocusNode.dispose();
    passwordController.dispose();
    locationController.dispose();
    referralController.dispose();
    passwordFocusNode.dispose();
    referralFocusNode.dispose();
    phoneController.dispose();
    alternatePhoneController.dispose();
    emailController.dispose();
    nameController.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    dobController.dispose();
    nameFocusNode.dispose();
    expFocusNode.dispose();
    fullAddressController.dispose();
  }

  Widget _getLabView() {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                _getProfileInformationTextWidget(),
                _getSpacer(),
                createTextField(nameController, plunesStrings.labName,
                    TextInputType.text, TextCapitalization.words, true, ''),
                _getSpacer(),
                createTextField(locationController, plunesStrings.location,
                    TextInputType.text, TextCapitalization.none, false, ''),
                _getSpacer(),
                createTextField(
                    fullAddressController,
                    plunesStrings.fullAddress,
                    TextInputType.text,
                    TextCapitalization.none,
                    true,
                    ''),
                _getSpacer(),
                createTextField(phoneController, plunesStrings.phoneNo,
                    TextInputType.number, TextCapitalization.none, false, ''),
                _getSpacer(),
                createTextField(
                    alternatePhoneController,
                    plunesStrings.alternatePhoneNo,
                    TextInputType.number,
                    TextCapitalization.none,
                    true,
                    ''),
                _getSpacer(),
                createTextField(aboutController, plunesStrings.aboutHospital,
                    TextInputType.text, TextCapitalization.none, true, ''),
                _getSpacer(),
                createTextField(
                    professionRegController,
                    plunesStrings.registrationNo,
                    TextInputType.text,
                    TextCapitalization.characters,
                    true,
                    ''),
                _getSpacer(),
                _getProfileInformationTextWidget(
                    text: plunesStrings.addSpecialization),
                _getSpacer(),
                widget.getSpacer(0.0, 10.0),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 5,
                      vertical: AppConfig.verticalBlockSize * 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                          color:
                              CommonMethods.getColorForSpecifiedCode("#707070"),
                          width: 0.4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.createTextViews(
                          plunesStrings.addSpecializationServices,
                          16,
                          colorsFile.lightGrey2,
                          TextAlign.center,
                          FontWeight.w100),
                      widget.getSpacer(0.0, 8.0),
                      Container(
                        margin: EdgeInsets.only(
                            right: AppConfig.horizontalBlockSize * 58),
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: getHospitalSpecializationData,
                          child: CustomWidgets().getRoundedButton(
                              plunesStrings.add,
                              5,
                              CommonMethods.getColorForSpecifiedCode("#BCDAD7"),
                              AppConfig.horizontalBlockSize * 0,
                              AppConfig.verticalBlockSize * 1.2,
                              CommonMethods.getColorForSpecifiedCode("#107C6F"),
                              hasBorder: true,
                              borderWidth: 0.4,
                              borderColor:
                                  CommonMethods.getColorForSpecifiedCode(
                                      "#107C6F")),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.getSpacer(0.0, 5.0),
                Container(
                  child: getSpecializationRow(),
                  margin: EdgeInsets.only(left: 8),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _getSpacer(),
                widget.getDividerRow(context, 0.0, 1.0, 0.0),
                _getProfileInformationTextWidget(
                    text: plunesStrings.addUsers.toString().substring(
                        0, plunesStrings.addUsers.toString().length - 1)),
                _getSpacer(),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: widget.createTextViews(plunesStrings.admin, 18,
                      "#000000", TextAlign.left, FontWeight.w500),
                ),
                widget.getSpacer(0.0, 10.0),
                createTextField(
                    emailController,
                    plunesStrings.userEmail,
                    TextInputType.emailAddress,
                    TextCapitalization.none,
                    isEmailValid,
                    plunesStrings.errorValidEmailMsg),
                widget.getSpacer(0.0, 20.0),
                getPasswordRow(plunesStrings.userPassword),
                _getSubmitButtonView()
              ],
            ),
          )
        ],
      ),
    );
  }

  void _getSpecialities() async {
    if (!_isProcessing) {
      _isProcessing = true;
      _setState();
    }
    var result = await _userBloc!.getSpeciality();
    if (result is RequestSuccess) {
      if (CommonMethods.catalogueLists == null ||
          CommonMethods.catalogueLists!.isEmpty) {
        _failureCause = "No Data Available";
      }
    } else if (result is RequestFailed) {
      _failureCause = result.failureCause;
    }
    _isProcessing = false;
    _setState();
  }

  _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  Future _setLocationData() async {
    if (_latitude != null &&
        _longitude != null &&
        _latitude!.isNotEmpty &&
        _longitude!.isNotEmpty &&
        _latitude != "0.0" &&
        _longitude != "0.0") {
      // final coordinates = new Coordinates(double.parse(_latitude!), double.parse(_longitude!));
      // var addressController = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var addressController = await GeocodingPlatform.instance.placemarkFromCoordinates(double.parse(_latitude!), double.parse(_longitude!));
      // var addressController = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var addr = addressController.first;
      String? fullAddressController = addr.locality;
      // String? fullAddressController = addr.addressLine;
      if (mounted) locationController.text = fullAddressController!;
    }
    _setState();
  }

  void _setShowCaseStatus() {
    UserManager()
        .setWidgetShownStatus(Constants.BIDDING_MAIN_SCREEN, status: false);
    UserManager()
        .setWidgetShownStatus(Constants.SOLUTION_SCREEN, status: false);
    UserManager()
        .setWidgetShownStatus(Constants.INSIGHT_MAIN_SCREEN, status: false);
    UserManager()
        .setWidgetShownStatus(Constants.VIDEO_STATUS_FOR_USER, status: false);
    UserManager()
        .setWidgetShownStatus(Constants.VIDEO_STATUS_FOR_PROF, status: false);
  }

  Widget _getSubmitButtonView() {
    return Container(
      child: Column(
        children: [
          widget.getSpacer(0.0, 20.0),
          progress
              ? SpinKitThreeBounce(
                  color: Color(hexColorCode.defaultGreen), size: 30.0)
              : Container(
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    onTap: _submitRegistrationRequest,
                    child: CustomWidgets().getRoundedButton(
                        plunesStrings.signUpBtn.toString().toUpperCase(),
                        5,
                        CommonMethods.getColorForSpecifiedCode("#107C6F"),
                        AppConfig.horizontalBlockSize * 0,
                        AppConfig.verticalBlockSize * 1.5,
                        PlunesColors.WHITECOLOR),
                  ),
                ),
          widget.getSpacer(0.0, 10.0),
          InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (_) => false);
            },
            onDoubleTap: () {},
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: EdgeInsets.all(5),
              child: Container(
                  child: Text("Already have an account",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: CommonMethods.getColorForSpecifiedCode(
                              "#107C6F")))),
            ),
          ),
          widget.getSpacer(0.0, 15.0),
          widget.getTermsOfUseRow(),
          widget.getSpacer(0.0, 30.0),
        ],
      ),
    );
  }

  Widget _getProfileInformationTextWidget({String? text}) {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 8),
      child: Row(
        children: [
          Container(
            child: Text(
              text ?? "Profile Information",
              style: TextStyle(
                  fontSize: 18,
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              height: 0.6,
              color: CommonMethods.getColorForSpecifiedCode("#DBDBDB"),
            ),
          )
        ],
      ),
    );
  }
}
