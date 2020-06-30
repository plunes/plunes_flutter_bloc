import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart' as loc;
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/location_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
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
  final String phone;

  Registration({this.phone});

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> implements DialogCallBack {
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

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<dynamic> _selectedItemId = List(),
      _doctorsList = List(),
      _selectedSpecializationData = List();
  String _userType, _latitude, _longitude, gender = plunesStrings.male;
  bool _isHospital = false,
      _isAddManualOpen = false,
      isExperienceValid = true,
      isDoctor = false,
      isLab = false,
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
  UserBloc _userBloc;
  String _failureCause;
  bool _isProcessing;
  Preferences _preferenceObj;
  BuildContext _context;

  @override
  void initState() {
    _userBloc = UserBloc();
    _isProcessing = false;
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    disposeControllers();
    super.dispose();
  }

  void initialize() {
    _dropDownMenuItems = widget.getDropDownMenuItems();
    _userType = _dropDownMenuItems[0].value;
    doc_availability_from.text = "00:00 AM";
    doc_availability_to.text = "00:00 PM";
    if (CommonMethods.catalogueLists == null ||
        CommonMethods.catalogueLists.isEmpty) {
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
        _latitude.isEmpty ||
        _longitude.isEmpty ||
        _latitude == "0.0" ||
        _longitude == "0.0") {
      await Future.delayed(Duration(milliseconds: 400));
      var latLong = await LocationUtil().getCurrentLatLong(_context);
      if (latLong != null) {
        _latitude = latLong.latitude?.toString();
        _longitude = latLong.longitude?.toString();
      }
    }
    _setLocationData();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        appBar: widget.getAppBar(context, plunesStrings.signUp, true),
        backgroundColor: Colors.white,
        body: Builder(builder: (context) {
          _context = context;
          return GestureDetector(
              onTap: () => CommonMethods.hideSoftKeyboard(),
              child: _isProcessing
                  ? CustomWidgets().getProgressIndicator()
                  : _failureCause == null
                      ? bodyView()
                      : CustomWidgets().errorWidget(_failureCause));
        }));
  }

  Widget bodyView() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: <Widget>[
          userTypeDropDown(),
          isLab
              ? getLabView()
              : _isHospital ? getHospitalView() : getUserOrDoctorView(),
        ],
      ),
    );
  }

  Widget userTypeDropDown() {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: DropdownButtonFormField(
        value: _userType,
        items: _dropDownMenuItems,
        icon: Image.asset(
          "assets/images/arrow-down-Icon.png",
          color: PlunesColors.GREYCOLOR,
          width: 20,
          height: 20,
        ),
        onChanged: changedDropDownItem,
        decoration: widget.myInputBoxDecoration(colorsFile.lightGrey1,
            colorsFile.lightGrey1, null, null, true, null),
      ),
    );
  }

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
        _selectedItemId.addAll(val['SelectedId']);
        _selectedSpecializationData.addAll(val['SelectedData']);
        _setState();
      }
    });
  }

//  Widget getAddDoctorsView() {
//    return Container(
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          /*      widget.getSpacer(0.0, 20.0),
//          widget.createTextViews(stringsFile.profileImage, 18, colorsFile.black0, TextAlign.left, FontWeight.normal),
//          widget.getSpacer(0.0, 20.0),
//          Row(
//            children: <Widget>[
//              InkWell(
//                onTap: () {
//
//                },
//                child: Stack(
//                  alignment: Alignment.center,
//                  children: <Widget>[
//                    Container(
//                      decoration: BoxDecoration(
//                          borderRadius: BorderRadius.all(Radius.circular(40)),
//                          color: Color(0x90ffBDBDBD)),
//                      height: 80,
//                      width: 80,
//                    ),
//                    Align(
//                      child: Icon(
//                        Icons.camera_enhance,
//                        color: Colors.white,
//                      ),
//                    ),
//                    Align(
//                        child: image != null
//                            ? CircleAvatar(
//                                radius: 40,
//                                backgroundImage: FileImage(image),
//                              )
//                            : Container()),
//                  ],
//                ),
//              ),
//              SizedBox(
//                width: 20,
//              ),
//              widget.getDefaultButton(
//                  stringsFile.upload, 100, _pickImage),
//            ],
//          ),*/
//          widget.getSpacer(0.0, 30.0),
//          createTextField(docNameController, plunesStrings.fullName,
//              TextInputType.text, TextCapitalization.words, true, ''),
//          widget.getSpacer(0.0, 20.0),
//          createTextField(
//              docEducationController,
//              plunesStrings.educationQualification,
//              TextInputType.text,
//              TextCapitalization.characters,
//              true,
//              ''),
//          widget.getSpacer(0.0, 20.0),
//          createTextField(docDesignationController, plunesStrings.designation,
//              TextInputType.text, TextCapitalization.characters, true, ''),
//          widget.getSpacer(0.0, 20.0),
//          createTextField(docDepartmentController, plunesStrings.department,
//              TextInputType.text, TextCapitalization.words, true, ''),
//          widget.getSpacer(0.0, 20.0),
//          createTextField(
//              specializationController,
//              plunesStrings.speciality,
//              TextInputType.text,
//              TextCapitalization.words,
//              isSpecificationValid,
//              plunesStrings.errorMsgEnterSpecialization),
//          widget.getSpacer(0.0, 20.0),
//          createTextField(
//              experienceController,
//              plunesStrings.experienceInNo,
//              TextInputType.numberWithOptions(decimal: true),
//              TextCapitalization.none,
//              isExperienceValid,
//              plunesStrings.errorMsgEnterExp),
//          widget.getSpacer(0.0, 20.0),
//          /*     widget.createTextViews(stringsFile.availability, 18, colorsFile.black0, TextAlign.left, FontWeight.normal),
//          widget.getSpacer(0.0, 10.0),
//          Row(
//            children: <Widget>[
//              Expanded(child: getSlotsRow(doc_availability_from, "00:00 AM")),
//              SizedBox(
//                width: 10,
//              ),
//              Expanded(child: getSlotsRow(doc_availability_to, "00:00 PM")),
//            ],
//          ),*/
//          widget.getSpacer(0.0, 20.0),
//          widget.getDefaultButton(
//              plunesStrings.add, globalWidth - 40, 42, addDoctorsInRow),
//          widget.getSpacer(0.0, 10.0),
//        ],
//      ),
//    );
//  }

  Widget getSlotsRow(TextEditingController controller, String hint) {
    return Container(
      height: 45,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(
              width: 1,
              color: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.lightGrey1)))),
      child: InkWell(
        onTap: () {
          CommonMethods.selectTime(context, controller.text).then((value) {
            if (controller == doc_availability_from)
              doc_availability_from.text = value;
            else
              doc_availability_to.text = value;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            enabled: false,
            controller: controller,
            decoration: InputDecoration.collapsed(hintText: hint),
          ),
        ),
      ),
    );
  }

  Widget getHospitalView() {
    return Expanded(
        child: Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                widget.getSpacer(0.0, 20.0),
                widget.createTextViews(plunesStrings.profileInformation, 18,
                    colorsFile.black0, TextAlign.center, FontWeight.bold),
                widget.getSpacer(0.0, 20.0),
                createTextField(nameController, plunesStrings.hospitalName,
                    TextInputType.text, TextCapitalization.words, true, ''),
                widget.getSpacer(0.0, 20.0),
                createTextField(locationController, plunesStrings.location,
                    TextInputType.text, TextCapitalization.none, false, ''),
                createTextField(phoneController, plunesStrings.phoneNo,
                    TextInputType.number, TextCapitalization.none, false, ''),
                createTextField(
                    alternatePhoneController,
                    plunesStrings.alternatePhoneNo,
                    TextInputType.number,
                    TextCapitalization.none,
                    true,
                    ''),
                createTextField(aboutController, plunesStrings.aboutHospital,
                    TextInputType.text, TextCapitalization.none, true, ''),
                widget.getSpacer(0.0, 20.0),
                createTextField(
                    professionRegController,
                    plunesStrings.registrationNo,
                    TextInputType.text,
                    TextCapitalization.characters,
                    true,
                    ''),
                widget.getSpacer(0.0, 40.0),
                widget.getDividerRow(context, 0.0, 0.0, 0.0),
                widget.getSpacer(0.0, 30.0),
                widget.createTextViews(plunesStrings.addSpecialization, 18,
                    colorsFile.black0, TextAlign.center, FontWeight.bold),
                widget.getSpacer(0.0, 5.0),
                widget.createTextViews(
                    plunesStrings.addSpecializationServices,
                    16,
                    colorsFile.lightGrey2,
                    TextAlign.center,
                    FontWeight.w100),
                widget.getSpacer(0.0, 20.0),
                widget.getDefaultButton(plunesStrings.add, globalWidth - 40, 42,
                    getHospitalSpecializationData),
                getSpecializationRow(),
//                widget.getSpacer(0.0, 40.0),
//                widget.getDividerRow(context, 0.0, 0.0, 0.0),
//                widget.getSpacer(0.0, 40.0),
//                widget.createTextViews(plunesStrings.addDoctors, 18,
//                    colorsFile.black0, TextAlign.center, FontWeight.bold),
//                getAddManualButton(),
//                _isAddManualOpen ? getAddDoctorsView() : Container(),
//                widget.getSpacer(0.0, 10.0),
              ],
            ),
          ),
//          _doctorsList.length == 0
//              ? Container()
//              : Container(
//                  margin: EdgeInsets.only(top: 10, bottom: 10),
//                  height: 150,
//                  child: ListView.builder(
//                    shrinkWrap: true,
//                    scrollDirection: Axis.horizontal,
//                    itemCount: _doctorsList.length,
//                    itemBuilder: (context, index) {
//                      return Container(
//                        padding: EdgeInsets.only(left: 10),
//                        margin: EdgeInsets.only(bottom: 10),
//                        child: Card(
//                          elevation: 3,
//                          semanticContainer: true,
//                          child: Container(
//                            padding: EdgeInsets.only(left: 10, right: 10),
//                            width: MediaQuery.of(context).size.width - 80,
//                            margin: EdgeInsets.only(top: 10, bottom: 5),
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.start,
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Container(
//                                  height: 50,
//                                  width: 50,
//                                  decoration: BoxDecoration(
//                                    borderRadius:
//                                        BorderRadius.all(Radius.circular(25)),
//                                    gradient: new LinearGradient(
//                                        colors: [
//                                          Color(0xffababab),
//                                          Color(0xff686868)
//                                        ],
//                                        begin: FractionalOffset.topCenter,
//                                        end: FractionalOffset.bottomCenter,
//                                        stops: [0.0, 1.0],
//                                        tileMode: TileMode.clamp),
//                                  ),
//                                  alignment: Alignment.center,
//                                  child: Text(
//                                    CommonMethods.getInitialName(
//                                        _doctorsList[index]['name']
//                                            .toString()
//                                            .toUpperCase()),
//                                    style: TextStyle(
//                                        color: Colors.white, fontSize: 14),
//                                  ),
//                                ),
//                                SizedBox(
//                                  width: 10,
//                                ),
//                                Expanded(
//                                    child: Container(
//                                  child: Column(
//                                    crossAxisAlignment:
//                                        CrossAxisAlignment.start,
//                                    children: <Widget>[
//                                      Text(
//                                        _doctorsList[index]['name'],
//                                        maxLines: 1,
//                                        style: TextStyle(
//                                            fontSize: 18,
//                                            fontWeight: FontWeight.normal,
//                                            color: Color(CommonMethods
//                                                .getColorHexFromStr(
//                                                    colorsFile.black0))),
//                                      ),
//                                      Text(_doctorsList[index]['education'],
//                                          maxLines: 1,
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.w100,
//                                              color: Color(CommonMethods
//                                                  .getColorHexFromStr(
//                                                      colorsFile.lightGrey1)),
//                                              fontSize: 16)),
//                                      Text(_doctorsList[index]['designation'],
//                                          maxLines: 1,
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.w100,
//                                              color: Color(CommonMethods
//                                                  .getColorHexFromStr(
//                                                      colorsFile.lightGrey1)),
//                                              fontSize: 16)),
//                                      Text(
//                                        _doctorsList[index]['department'],
//                                        maxLines: 1,
//                                        style: TextStyle(
//                                            fontWeight: FontWeight.w100,
//                                            color: Color(CommonMethods
//                                                .getColorHexFromStr(
//                                                    colorsFile.lightGrey1)),
//                                            fontSize: 16),
//                                      ),
//                                      Text(
//                                        _doctorsList[index]['experience'] +
//                                            ' years of Experience',
//                                        maxLines: 1,
//                                        style: TextStyle(
//                                            fontWeight: FontWeight.w100,
//                                            color: Color(CommonMethods
//                                                .getColorHexFromStr(
//                                                    colorsFile.lightGrey1)),
//                                            fontSize: 16),
//                                      ),
//                                    ],
//                                  ),
//                                )),
//                                InkWell(
//                                  child: Padding(
//                                    padding: const EdgeInsets.only(
//                                        left: 8.0, bottom: 8, right: 8),
//                                    child: Icon(
//                                      Icons.close,
//                                      size: 18,
//                                    ),
//                                  ),
//                                  onTap: () {
//                                    setState(() {
//                                      _doctorsList.removeAt(index);
//                                    });
//                                  },
//                                ),
//                              ],
//                            ),
//                          ),
//                        ),
//                      );
//                    },
//                  ),
//                ),
          widget.getSpacer(0.0, 20.0),
          widget.getDividerRow(context, 0.0, 30.0, 0.0),
          widget.getSpacer(0.0, 0.0),
          widget.createTextViews(plunesStrings.manageAccount, 18,
              colorsFile.black0, TextAlign.center, FontWeight.bold),
          widget.getSpacer(0.0, 5.0),
          widget.createTextViews(plunesStrings.addUsers, 16,
              colorsFile.lightGrey2, TextAlign.center, FontWeight.w100),
          widget.getSpacer(0.0, 20.0),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.createTextViews(plunesStrings.admin, 18,
                    colorsFile.black0, TextAlign.left, FontWeight.bold),
                widget.getSpacer(0.0, 10.0),
                widget.createTextViews(
                    plunesStrings.addUsers.toString().substring(
                        0, plunesStrings.addUsers.toString().length - 1),
                    18,
                    colorsFile.black0,
                    TextAlign.left,
                    FontWeight.normal),
                widget.getSpacer(0.0, 20.0),
                createTextField(
                    emailController,
                    plunesStrings.userEmail,
                    TextInputType.emailAddress,
                    TextCapitalization.none,
                    isEmailValid,
                    plunesStrings.errorValidEmailMsg),
                widget.getSpacer(0.0, 20.0),
                getPasswordRow(plunesStrings.userPassword),
                widget.getSpacer(0.0, 20.0),
                widget.createTextViews(plunesStrings.errorMsgPassword, 16,
                    colorsFile.black0, TextAlign.center, FontWeight.normal),
                widget.getSpacer(0.0, 20.0),
                progress
                    ? SpinKitThreeBounce(
                        color: Color(hexColorCode.defaultGreen), size: 30.0)
                    : widget.getDefaultButton(plunesStrings.submit,
                        globalWidth - 40, 42, submitRegistrationRequest),
                widget.getSpacer(0.0, 30.0),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget getUserOrDoctorView() {
    return Expanded(
        child: Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          getGenderRow(),
          widget.getSpacer(0.0, 15.0),
          createTextField(
              nameController,
              plunesStrings.name,
              TextInputType.text,
              TextCapitalization.words,
              isNameValid,
              plunesStrings.errorMsgEnterFullName),
          widget.getSpacer(0.0, 15.0),
          createTextField(phoneController, plunesStrings.phoneNo,
              TextInputType.number, TextCapitalization.none, false, ''),
          //widget.getSpacer(0.0, 20.0),
          _userType == Constants.doctor
              ? createTextField(
                  alternatePhoneController,
                  plunesStrings.alternatePhoneNo,
                  TextInputType.number,
                  TextCapitalization.none,
                  true,
                  '')
              : Container(),
          widget.getSpacer(0.0, 15.0),
          createTextField(
              emailController,
              plunesStrings.emailId,
              TextInputType.emailAddress,
              TextCapitalization.none,
              isEmailValid,
              plunesStrings.errorValidEmailMsg),
          widget.getSpacer(0.0, 15.0),
          createTextField(dobController, plunesStrings.dateOfBirth,
              TextInputType.datetime, TextCapitalization.none, false, ''),
          getPasswordRow(plunesStrings.password),
          widget.getSpacer(0.0, 15.0),
          _userType == Constants.generalUser
              ? Container()
              : createTextField(locationController, plunesStrings.location,
                  TextInputType.text, TextCapitalization.none, false, ''),
          Visibility(
              visible: isDoctor,
              child: Column(children: <Widget>[
                createTextField(
                    professionRegController,
                    plunesStrings.professionalRegNo,
                    TextInputType.text,
                    TextCapitalization.words,
                    isProfessionValid,
                    plunesStrings.errorMsgEnterProfRegNo),
                widget.getSpacer(0.0, 15.0),
                createTextField(
                    specializationController,
                    '${plunesStrings.specialization}*',
                    TextInputType.text,
                    TextCapitalization.words,
                    isSpecificationValid,
                    plunesStrings.errorMsgEnterSpecialization),
                widget.getSpacer(0.0, 15.0),
                createTextField(
                    experienceController,
                    plunesStrings.experienceInNo,
                    TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    TextCapitalization.none,
                    isExperienceValid,
                    plunesStrings.errorMsgEnterExp),
                widget.getSpacer(0.0, 15.0)
              ])),
          _userType == Constants.doctor
              ? Container()
              : createTextField(referralController, plunesStrings.referralCode,
                  TextInputType.text, TextCapitalization.none, true, ''),
          widget.getSpacer(0.0, 15.0),
          progress
              ? SpinKitThreeBounce(
                  color: Color(hexColorCode.defaultGreen), size: 30.0)
              : widget.getDefaultButton(plunesStrings.signUpBtn,
                  globalWidth - 40, 42, submitRegistrationRequest),
          widget.getSpacer(0.0, 15.0),
          widget.getTermsOfUseRow(),
          widget.getSpacer(0.0, 30.0),
        ],
      ),
    ));
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
      var addressControllerList = new List();
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
                      _selectedSpecializationData[index],
                      18,
                      colorsFile.black0,
                      TextAlign.start,
                      FontWeight.normal),
                ),
                InkWell(
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
                      _selectedSpecializationData.removeAt(index);
                      _selectedItemId.removeAt(index);
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
      itemCount: _selectedSpecializationData.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }

  Widget getAddManualButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isAddManualOpen = !_isAddManualOpen;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget.createTextViews(plunesStrings.addManually, 16,
              colorsFile.lightGrey2, TextAlign.center, FontWeight.w100),
          Container(
              margin: EdgeInsets.only(top: 5),
              child: _isAddManualOpen
                  ? Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 30)
                  : Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey, size: 30))
        ],
      ),
    );
  }

//  addDoctorsInRow() {
//    if (validationAddDoctors()) {
//      setState(() {
//        var doctors = {};
//        doctors['name'] = docNameController.text;
//        doctors['education'] = docEducationController.text;
//        doctors['designation'] = docDesignationController.text;
//        doctors['department'] = docDepartmentController.text;
//        doctors['experience'] = experienceController.text;
//        doctors['specialities'] = _selectedItemId;
//        _doctorsList.add(doctors);
//        docNameController.text = '';
//        docEducationController.text = '';
//        docDesignationController.text = '';
//        docDepartmentController.text = '';
//        experienceController.text = '';
//        specializationController.text = '';
//        _selectedItemId = [];
//      });
//    } else {
//      widget.showInSnackBar(
//          errorMessage, PlunesColors.BLACKCOLOR, _scaffoldKey);
//    }
//  }

  submitRegistrationRequest() async {
    if (validation()) {
      List specialistId = new List();
      for (var item in _selectedItemId)
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
          this._latitude.isNotEmpty &&
          this._longitude.isNotEmpty &&
          _userType != Constants.generalUser) {
        body['location'] = Location(type: 'Point', coordinates: [
          double.parse(this._longitude),
          double.parse(this._latitude)
        ]).toJson();
      }
      body['userType'] =
          _userType == Constants.generalUser ? 'User' : _userType;
      if (_userType != Constants.generalUser) {
        body['address'] = locationController.text;
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
      var result = await _userBloc.signUp(body);
      progress = false;
      _setState();
      await Future.delayed(Duration(milliseconds: 50));
      if (result is RequestSuccess) {
        LoginPost data = result.response;
        if (data.success) {
          await bloc.saveDataInPreferences(
              data, context, plunesStrings.registration);
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

  bool validation() {
    if (nameController.text.trim().isEmpty ||
        (isDoctor && nameController.text.toString().length == 4)) {
      errorMessage = _userType == Constants.hospital
          ? plunesStrings.errorMsgEnterHosName
          : plunesStrings.errorMsgEnterFullName;
      return false;
    } else if ((_userType == Constants.hospital ||
            _userType == Constants.labDiagnosticCenter) &&
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
    } else if (_userType != Constants.generalUser &&
        (locationController.text.isEmpty ||
            _latitude == null ||
            _latitude.isEmpty ||
            _latitude == "0.0" ||
            _longitude == null ||
            _longitude.isEmpty ||
            _longitude == "0.0")) {
      errorMessage = PlunesStrings.pleaseSelectALocation;
      return false;
    } else if (isDoctor && professionRegController.text.trim().isEmpty) {
      errorMessage = plunesStrings.errorMsgEnterProfRegNo;
      return false;
    } else if (isDoctor && specializationController.text.trim().isEmpty) {
      errorMessage = plunesStrings.errorMsgEnterSpecialization;
      return false;
    } else if ((isLab || _isHospital) &&
        (_selectedItemId == null || _selectedItemId.isEmpty)) {
      errorMessage = plunesStrings.errorMsgEnterSpecialization;
      return false;
    } else if (isDoctor && experienceController.text.trim().isEmpty) {
      errorMessage = plunesStrings.errorMsgEnterExp;
      return false;
    } else if (_userType != Constants.user &&
        alternatePhoneController.text.trim().isNotEmpty &&
        alternatePhoneController.text.trim().length != 10) {
      errorMessage = plunesStrings.invalidPhoneNumber;
      return false;
    }
//    else if (_userType == Constants.hospital && _doctorsList.length == 0) {
//      errorMessage = plunesStrings.errorMsgAddDoctor;
//      return false;
//    }
    else {
      return true;
    }
  }

//  bool validationAddDoctors() {
//    if (docNameController.text.trim().isEmpty) {
//      errorMessage = plunesStrings.errorMsgEnterDocName;
//      return false;
//    } else if (docEducationController.text.trim().isEmpty) {
//      errorMessage = plunesStrings.errorMsgEnterEducation;
//      return false;
//    } else if (docDepartmentController.text.trim().isEmpty) {
//      errorMessage = plunesStrings.errorMsgEnterDocDep;
//      return false;
//    } else if (specializationController.text.trim().isEmpty) {
//      errorMessage = plunesStrings.errorMsgEnterSpecialization;
//      return false;
//    } else if (experienceController.text.trim().isEmpty) {
//      errorMessage = plunesStrings.errorMsgEnterExp;
//      return false;
//    } else {
//      return true;
//    }
//  }

  @override
  dialogCallBackFunction(String action) {}

  resetFormData() {
    _selectedItemId = [];
    experienceController.text = '';
    specializationController.text = '';
    professionRegController.text = '';
    passwordController.text = '';
    emailController.text = '';
    alternatePhoneController.text = '';
    _selectedSpecializationData = [];
  }

  changedDropDownItem(String selectedCity) {
    print(selectedCity);
    setState(() {
      _userType = selectedCity;
      if (_userType == 'Doctor') {
        isDoctor = true;
        nameController.text = "Dr. ";
        _isHospital = false;
        isLab = false;
      } else if (_userType == 'Hospital') {
        _isHospital = true;
        isDoctor = false;
        isLab = false;
        nameController.text = '';
        dobController.text = '';
      } else if (_userType == Constants.labDiagnosticCenter) {
        isLab = true;
        _isHospital = false;
        isDoctor = false;
        nameController.text = '';
        dobController.text = '';
      } else {
        nameController.text = '';
        isDoctor = false;
        isLab = false;
        _isHospital = false;
      }
      resetFormData();
    });
  }

  Widget getGenderRow() {
    return Container(
      child: _userType == Constants.hospital
          ? Container()
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Radio(
                  value: female,
                  activeColor: Color(hexColorCode.defaultGreen),
                  groupValue: data,
                  onChanged: (val) {
                    setState(() {
                      male = 0;
                      female = 1;
                      gender = plunesStrings.male;
                    });
                  },
                ),
                Container(
                    margin: EdgeInsets.only(right: 50),
                    child: widget.createTextViews(plunesStrings.male, 18,
                        colorsFile.black0, TextAlign.left, FontWeight.normal)),
                Radio(
                  value: male,
                  activeColor: Color(hexColorCode.defaultGreen),
                  groupValue: data,
                  onChanged: (val) {
                    setState(() {
                      male = 1;
                      female = 0;
                      gender = plunesStrings.female;
                    });
                  },
                ),
                widget.createTextViews(plunesStrings.female, 18,
                    colorsFile.black0, TextAlign.left, FontWeight.normal)
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
      String errorMsg) {
    if (controller == phoneController) controller.text = widget.phone;
    return InkWell(
      onTap: () {
        if (controller == dobController)
          CommonMethods.selectHoloTypeDate(context).then((value) {
            dobController.text = value;
          });
        else if (controller == locationController)
          fetchLocation();
        else if (controller == specializationController)
          getSpecializationData();
      },
      child: Container(
          padding: EdgeInsets.zero,
          width: MediaQuery.of(context).size.width,
          child: TextField(
              maxLines:
                  (controller == locationController || controller == aboutController)
                      ? 2
                      : 1,
              maxLength: (controller == aboutController)
                  ? 250
                  : (controller != null && controller == alternatePhoneController)
                      ? 10
                      : null,
              textCapitalization: textCapitalization,
              obscureText:
                  (controller == passwordController ? _passwordVisible : false),
              keyboardType: inputType,
              inputFormatters: (controller != null && controller == alternatePhoneController)
                  ? <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ]
                  : (controller != null &&
                          controller == nameController &&
                          _userType == Constants.generalUser)
                      ? [WhitelistingTextInputFormatter(RegExp("[a-zA-Z ]"))]
                      : null,
              textInputAction: controller == referralController
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: (String value) {
                setFocus(controller).unfocus();
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
                      controller == specializationController)
                  ? false
                  : true,
              style: TextStyle(
                fontSize: 15.0,
              ),
              decoration: widget.myInputBoxDecoration(
                  colorsFile.defaultGreen,
                  colorsFile.lightGrey1,
                  placeHolder,
                  errorMsg,
                  fieldFlag,
                  controller,
                  passwordController))),
    );
  }

  FocusNode setFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == nameController) {
      focusNode = nameFocusNode;
    } else if (controller == phoneController) {
      focusNode = phoneFocusNode;
    } else if (controller == emailController) {
      focusNode = emailFocusNode;
    } else if (controller == passwordController) {
      focusNode = passwordFocusNode;
    } else if (isDoctor && controller == professionRegController) {
      focusNode = profRegNoFocusNode;
    } else if (isDoctor && controller == experienceController) {
      focusNode = expFocusNode;
    } else if (controller == referralController) {
      focusNode = referralFocusNode;
    }
    return focusNode;
  }

  FocusNode setTargetFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == nameController) {
      focusNode = emailFocusNode;
    } else if (controller == emailController) {
      focusNode = passwordFocusNode;
    } else if (controller == passwordController && !isDoctor) {
      focusNode = referralFocusNode;
    } else if (controller == passwordController && isDoctor) {
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
  }

  Widget getLabView() {
    return Expanded(
        child: Container(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                widget.getSpacer(0.0, 20.0),
                widget.createTextViews(plunesStrings.profileInformation, 18,
                    colorsFile.black0, TextAlign.center, FontWeight.bold),
                widget.getSpacer(0.0, 20.0),
                createTextField(nameController, plunesStrings.labName,
                    TextInputType.text, TextCapitalization.words, true, ''),
                widget.getSpacer(0.0, 20.0),
                createTextField(locationController, plunesStrings.location,
                    TextInputType.text, TextCapitalization.none, false, ''),
                createTextField(phoneController, plunesStrings.phoneNo,
                    TextInputType.number, TextCapitalization.none, false, ''),
                createTextField(
                    alternatePhoneController,
                    plunesStrings.alternatePhoneNo,
                    TextInputType.number,
                    TextCapitalization.none,
                    true,
                    ''),
                createTextField(aboutController, plunesStrings.aboutLab,
                    TextInputType.text, TextCapitalization.none, true, ''),
                widget.getSpacer(0.0, 20.0),
                createTextField(
                    professionRegController,
                    plunesStrings.registrationNo,
                    TextInputType.text,
                    TextCapitalization.characters,
                    true,
                    ''),
                widget.getSpacer(0.0, 40.0),
                widget.getDividerRow(context, 0.0, 0.0, 0.0),
                widget.getSpacer(0.0, 30.0),
                widget.createTextViews(plunesStrings.addSpecialization, 18,
                    colorsFile.black0, TextAlign.center, FontWeight.bold),
                widget.getSpacer(0.0, 5.0),
                widget.createTextViews(
                    plunesStrings.addSpecializationServices,
                    16,
                    colorsFile.lightGrey2,
                    TextAlign.center,
                    FontWeight.w100),
                widget.getSpacer(0.0, 20.0),
                widget.getDefaultButton(plunesStrings.add, globalWidth - 40, 42,
                    getHospitalSpecializationData),
                getSpecializationRow(),
              ],
            ),
          ),
          widget.getSpacer(0.0, 20.0),
          widget.getDividerRow(context, 0.0, 30.0, 0.0),
          widget.getSpacer(0.0, 0.0),
          widget.createTextViews(plunesStrings.manageAccount, 18,
              colorsFile.black0, TextAlign.center, FontWeight.bold),
          widget.getSpacer(0.0, 5.0),
          widget.createTextViews(plunesStrings.addUsers, 16,
              colorsFile.lightGrey2, TextAlign.center, FontWeight.w100),
          widget.getSpacer(0.0, 20.0),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.createTextViews(plunesStrings.admin, 18,
                    colorsFile.black0, TextAlign.left, FontWeight.bold),
                widget.getSpacer(0.0, 10.0),
                widget.createTextViews(
                    plunesStrings.addUsers.toString().substring(
                        0, plunesStrings.addUsers.toString().length - 1),
                    18,
                    colorsFile.black0,
                    TextAlign.left,
                    FontWeight.normal),
                widget.getSpacer(0.0, 20.0),
                createTextField(
                    emailController,
                    plunesStrings.userEmail,
                    TextInputType.emailAddress,
                    TextCapitalization.none,
                    isEmailValid,
                    plunesStrings.errorValidEmailMsg),
                widget.getSpacer(0.0, 20.0),
                getPasswordRow(plunesStrings.userPassword),
                widget.getSpacer(0.0, 20.0),
                widget.createTextViews(plunesStrings.errorMsgPassword, 16,
                    colorsFile.black0, TextAlign.center, FontWeight.normal),
                widget.getSpacer(0.0, 20.0),
                progress
                    ? SpinKitThreeBounce(
                        color: Color(hexColorCode.defaultGreen), size: 30.0)
                    : widget.getDefaultButton(plunesStrings.submit,
                        globalWidth - 40, 42, submitRegistrationRequest),
                widget.getSpacer(0.0, 30.0),
              ],
            ),
          )
        ],
      ),
    ));
  }

  void _getSpecialities() async {
    if (!_isProcessing) {
      _isProcessing = true;
      _setState();
    }
    var result = await _userBloc.getSpeciality();
    if (result is RequestSuccess) {
      if (CommonMethods.catalogueLists == null ||
          CommonMethods.catalogueLists.isEmpty) {
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
        _latitude.isNotEmpty &&
        _longitude.isNotEmpty &&
        _latitude != "0.0" &&
        _longitude != "0.0") {
//      _preferenceObj.setPreferencesString(Constants.LATITUDE, _latitude);
//      _preferenceObj.setPreferencesString(Constants.LONGITUDE, _longitude);
      print('$_latitude , $_longitude');
      final coordinates =
          new Coordinates(double.parse(_latitude), double.parse(_longitude));
      var addressController =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var addr = addressController.first;
      String fullAddressController = addr.addressLine;
      if (mounted) locationController.text = fullAddressController;
    }
    _setState();
  }
}
