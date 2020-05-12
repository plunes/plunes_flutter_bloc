import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import 'package:plunes/ui/commonView/SelectSpecialization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends BaseActivity {
  static const tag = '/editprofile';
  final fullName,
      dateOfBirth,
      education,
      college,
      location,
      userType,
      userEducation,
      userCollege,
      profRegNo,
      practising,
      introduction,
      specializations,
      experience;

  EditProfileScreen(
      {this.userType,
      this.fullName,
      this.dateOfBirth,
      this.education,
      this.college,
      this.location,
      this.userEducation,
      this.userCollege,
      this.profRegNo,
      this.practising,
      this.introduction,
      this.specializations,
      this.experience});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileScreen>
    implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final specializationController = TextEditingController();
  final professionRegController = TextEditingController();
  final experienceController = TextEditingController();
  final practisingController = TextEditingController();

  final aboutController = new TextEditingController();
  final docNameController = new TextEditingController();
  final educationController = TextEditingController();
  final collegeController = TextEditingController();
  List<dynamic> _selectedItemId = List(), _selectedSpecializationData = List();
  FocusNode nameFocusNode = new FocusNode(),
      educationFocusNode = new FocusNode(),
      professionalFocusNode = new FocusNode(),
      expFocusNode = new FocusNode(),
      practisingFocusNode = new FocusNode(),
      collegeFocusNode = new FocusNode(),
      aboutFocusNode = new FocusNode();

  bool isDoctor = false;
  bool emain_valid = true;
  var globalHeight, globalWidth;
  bool profession_valid = true;
  bool specification_valid = true, name_valid = true;
  bool experience_valid = true;
  String _latitude = '', _longitude = '';
  bool progress = false;
  String user_token = "";
  String user_id = "";

  UserBloc _userBloc;

  @override
  void dispose() {
    bloc.disposeEditStream();
    super.dispose();
  }

  @override
  void initState() {
    initialize();
    _userBloc = UserBloc();
    super.initState();
  }

//  getSharedPreferences() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String token = prefs.getString("token");
//    String uid = prefs.getString("uid");
//    setState(() {
//      user_token = token;
//      user_id = uid;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        key: _scaffoldKey,
        appBar: widget.getAppBar(context, plunesStrings.editProfile, true),
        backgroundColor: Colors.white,
        body: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(), child: bodyView()));
  }

  Widget bodyView() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: <Widget>[
          getUserOrDoctorView(),
        ],
      ),
    );
  }

  Widget getUserOrDoctorView() {
    return Expanded(
        child: Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          widget.getSpacer(0.0, 10.0),
          createTextField(
              nameController,
              plunesStrings.fullName,
              TextInputType.text,
              TextCapitalization.words,
              name_valid,
              plunesStrings.errorMsgEnterFullName),
          widget.getSpacer(0.0, 20.0),
          widget.userType != Constants.hospital
              ? createTextField(dobController, plunesStrings.dateOfBirth,
                  TextInputType.datetime, TextCapitalization.none, false, '')
              : Container(),
          widget.userType != Constants.hospital
              ? createTextField(
                  educationController,
                  isDoctor
                      ? plunesStrings.qualification
                      : plunesStrings.education,
                  TextInputType.text,
                  TextCapitalization.words,
                  true,
                  '')
              : Container(),
          widget.getSpacer(
              0.0, widget.userType != Constants.hospital ? 20.0 : 0),
//          isDoctor
//              ? createTextField(
//                  professionRegController,
//                  plunesStrings.professionalRegNo,
//                  TextInputType.text,
//                  TextCapitalization.characters,
//                  true,
//                  '')
//              : Container(),
         // widget.getSpacer(0.0, isDoctor ? 20.0 : 0),
//          isDoctor
//              ? createTextField(
//                  specializationController,
//                  '${plunesStrings.specialization}*',
//                  TextInputType.text,
//                  TextCapitalization.words,
//                  true,
//                  '')
//              : Container(),
//          widget.getSpacer(0.0, isDoctor ? 20.0 : 0),
//          isDoctor
//              ? createTextField(
//                  experienceController,
//                  plunesStrings.experienceInNo,
//                  TextInputType.numberWithOptions(decimal: true),
//                  TextCapitalization.none,
//                  true,
//                  '')
//              : Container(),
//          widget.getSpacer(0.0, isDoctor ? 20.0 : 0),
//          isDoctor
//              ? createTextField(practisingController, plunesStrings.practising,
//                  TextInputType.text, TextCapitalization.words, true, '')
//              : Container(),
          widget.getSpacer(0.0, isDoctor ? 20.0 : 0),
          widget.userType != Constants.hospital
              ? createTextField(collegeController, plunesStrings.college,
                  TextInputType.text, TextCapitalization.words, true, '')
              : Container(),
//          widget.getSpacer(0.0, isDoctor ? 20.0 : 0),
//          isDoctor
//              ? createTextField(aboutController, plunesStrings.introduction,
//                  TextInputType.text, TextCapitalization.words, true, '')
//              : Container(),
          widget.getSpacer(
              0.0, widget.userType != Constants.hospital ? 20.0 : 0),
          createTextField(locationController, plunesStrings.location,
              TextInputType.text, TextCapitalization.none, false, ''),
          progress
              ? SpinKitThreeBounce(
                  color: Color(hexColorCode.defaultGreen), size: 30.0)
              : widget.getDefaultButton(plunesStrings.update, globalWidth - 40,
                  42, updateProfileRequest),
          widget.getSpacer(0.0, 30.0),
        ],
      ),
    ));
  }

  Widget createTextField(
      TextEditingController controller,
      String placeHolder,
      TextInputType inputType,
      TextCapitalization textCapitalization,
      bool fieldFlag,
      String errorMsg) {
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
              maxLines: (controller == locationController) ||
                      (controller == aboutController)
                  ? 4
                  : null,
              maxLength: (controller == aboutController)
                  ? 250
                  : ((controller == experienceController) ? 2 : null),
              textCapitalization: textCapitalization,
              keyboardType: inputType,
              textInputAction: controller == aboutController
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: (String value) {
                setFocus(controller).unfocus();
                FocusScope.of(context).requestFocus(setTargetFocus(controller));
              },
              controller: controller,
              cursorColor: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
              focusNode: setFocus(controller),
              enabled: (controller == dobController ||
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
                  null))),
    );
  }

  FocusNode setFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == nameController) {
      focusNode = nameFocusNode;
    } else if (controller == educationController) {
      focusNode = educationFocusNode;
    } else if (controller == professionRegController) {
      focusNode = professionalFocusNode;
    } else if (controller == experienceController) {
      focusNode = expFocusNode;
    } else if (controller == practisingController) {
      focusNode = practisingFocusNode;
    } else if (controller == collegeController) {
      focusNode = collegeFocusNode;
    } else if (controller == aboutController) {
      focusNode = aboutFocusNode;
    }
    return focusNode;
  }

  FocusNode setTargetFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == nameController) {
      focusNode = educationFocusNode;
    } else if (controller == educationController) {
      focusNode = professionalFocusNode;
    } else if (controller == professionRegController) {
      focusNode = expFocusNode;
    } else if (controller == experienceController) {
      focusNode = practisingFocusNode;
    } else if (controller == practisingController) {
      focusNode = collegeFocusNode;
    } else if (controller == collegeController) {
      focusNode = aboutFocusNode;
    }
    return focusNode;
  }

  fetchLocation() {
    Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => LocationFetch()))
        .then((val) {
      var addressControllerList = new List();
      addressControllerList = val.toString().split(":");
      locationController.text = addressControllerList[0] +
          ' ' +
          addressControllerList[1] +
          ' ' +
          addressControllerList[2];
      _latitude = addressControllerList[3];
      _longitude = addressControllerList[4];
    });
  }

  void initialize() {
    isDoctor = widget.userType == Constants.doctor ? true : false;
    nameController.text = widget.fullName;
    dobController.text = widget.dateOfBirth;
    locationController.text = widget.location;
   // specializationController.text = widget.specializations;
    educationController.text = widget.education;
    collegeController.text = widget.college;
    var user = UserManager().getUserDetails();
    professionRegController.text = user.profRegistrationNumber;
    experienceController.text = user.experience;
    aboutController.text = user.about;


  }

  updateProfileRequest() async {
    FocusScope.of(context).requestFocus (FocusNode());
//    List specialistId = new List();
//    for (var item in _selectedItemId)
//      specialistId.add({'specialityId': item});
    var body = {};
    var user = User(
      name: nameController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      address: locationController.text.trim(),
      birthDate: dobController.text.trim(),
      registrationNumber: professionRegController.text.trim(),
      experience: experienceController.text.trim(),
     // about: aboutController.text.trim(),
      biography: aboutController.text.trim(),
      qualification: educationController.text.trim(),
      college: collegeController.text.trim(),
      practising: practisingController.text.trim(),
    );

//    body['name'] = nameController.text;
//    body['latitude'] = _latitude;
//    body['longitude'] = _longitude;
//    body['address'] = locationController.text;
/*    if (_userType != Constants.hospital) {
      body['birthDate'] = dobController.text;
      body['referralCode'] = referralController.text;
    }
    if (_userType == Constants.doctor || _userType == Constants.hospital) {
      body['registrationNumber'] = professionRegController.text;
      body["specialities"] = specialistId;

      if (_userType == Constants.doctor) {
        body['experience'] = experienceController.text;
      }
      if (_userType == Constants.hospital) {
        body['biography'] = aboutController.text;
        body['doctors'] = _doctorsList;
      }
    }*/

//    progress = true;
//    bloc.updateRequest(context, this, body);
//    bloc.updateProfileFetcher.listen((data) async {
//      progress = false;
//      if (data != null && data['success'] != null && data['success']) {
//        await bloc.saveEditProfileDataInPreferences(context, body);
//        widget.showInSnackBar(plunesStrings.success, Colors.green, _scaffoldKey);
//      } else {
//        widget.showInSnackBar(data.message, Colors.red, _scaffoldKey);
//      }
//    });
    progress = true;
    _setState();
   // print(user.toString());
    var result = await _userBloc.updateUserData(user.toJson());
    if (result is RequestSuccess) {
      widget.showInSnackBar(plunesStrings.success, Colors.green, _scaffoldKey);
      Future.delayed(Duration(milliseconds: 550)).then((value){
        Navigator.pop(context);
      });
    } else if (result is RequestFailed) {
      RequestFailed requestFailed = result;
      widget.showInSnackBar(
          requestFailed.failureCause, Colors.red, _scaffoldKey);
    }
    progress = false;
    _setState();
  }

  getSpecializationData() {
    showDialog(
        context: context,
        builder: (BuildContext context) => SelectSpecialization(
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

  @override
  dialogCallBackFunction(String action) {}

  _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
