import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
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

// ignore: must_be_immutable
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
  final _emailController = new TextEditingController();
  final aboutController = new TextEditingController();
  final docNameController = new TextEditingController();
  final educationController = TextEditingController();
  final collegeController = TextEditingController();
  final manualAddressController = TextEditingController();
  List<dynamic> _selectedItemId = List(), _selectedSpecializationData = List();
  FocusNode nameFocusNode = new FocusNode(),
      educationFocusNode = new FocusNode(),
      professionalFocusNode = new FocusNode(),
      expFocusNode = new FocusNode(),
      practisingFocusNode = new FocusNode(),
      collegeFocusNode = new FocusNode(),
      aboutFocusNode = new FocusNode();

  bool isDoctor = false;
  bool _isValidEmail = true;
  var globalHeight, globalWidth;
  bool profession_valid = true;
  bool specification_valid = true, name_valid = true;
  bool experience_valid = true;
  String _latitude = '0.0', _longitude = '0.0';
  bool progress = false;
  String user_token = "";
  String user_id = "";

  UserBloc _userBloc;
  User _user;
  String _region;

  @override
  void dispose() {
    _emailController?.dispose();
    bloc.disposeEditStream();
    super.dispose();
  }

  @override
  void initState() {
    initialize();
    _userBloc = UserBloc();
    super.initState();
  }

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
          _user.userType == Constants.user
              ? widget.getSpacer(0.0, 20.0)
              : Container(),
          _user.userType == Constants.user
              ? createTextField(
                  _emailController,
                  PlunesStrings.emailIdAsConst,
                  TextInputType.emailAddress,
                  TextCapitalization.none,
                  _isValidEmail,
                  plunesStrings.errorValidEmailMsg)
              : Container(),
          widget.getSpacer(
              0.0,
              (widget.userType != Constants.hospital &&
                      widget.userType != Constants.labDiagnosticCenter)
                  ? 20.0
                  : 0),
          (widget.userType != Constants.hospital &&
                  widget.userType != Constants.labDiagnosticCenter)
              ? createTextField(dobController, plunesStrings.dateOfBirth,
                  TextInputType.datetime, TextCapitalization.none, false, '')
              : Container(),
          (widget.userType != Constants.hospital &&
                  widget.userType != Constants.labDiagnosticCenter)
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
          (widget.userType != Constants.hospital &&
                  widget.userType != Constants.labDiagnosticCenter)
              ? createTextField(collegeController, plunesStrings.college,
                  TextInputType.text, TextCapitalization.words, true, '')
              : Container(),
          widget.getSpacer(0.0, (_user.userType != Constants.user) ? 20.0 : 0),
          (_user.userType != Constants.user)
              ? createTextField(
                  manualAddressController,
                  plunesStrings.fullAddress,
                  TextInputType.text,
                  TextCapitalization.none,
                  true,
                  '')
              : Container(),
          widget.getSpacer(0.0, 20.0),
          createTextField(locationController, plunesStrings.location,
              TextInputType.text, TextCapitalization.none, false, ''),
          progress
              ? SpinKitThreeBounce(
                  color: Color(hexColorCode.defaultGreen), size: 30.0)
              : Container(
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 30,
                      right: AppConfig.horizontalBlockSize * 30),
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    onTap: updateProfileRequest,
                    child: CustomWidgets().getRoundedButton(
                        plunesStrings.update,
                        AppConfig.horizontalBlockSize * 8,
                        PlunesColors.GREENCOLOR,
                        AppConfig.horizontalBlockSize * 0,
                        AppConfig.verticalBlockSize * 1.2,
                        PlunesColors.WHITECOLOR),
                  ),
                ),
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
        if (_user.isCentre != null && _user.isCentre) {
          return;
        }
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
              readOnly: (_user.isCentre != null && _user.isCentre)
                  ? (controller == nameController) ? false : true
                  : false,
              textInputAction: controller == aboutController
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: (String value) {
                setFocus(controller).unfocus();
                FocusScope.of(context).requestFocus(setTargetFocus(controller));
              },
              onChanged: (writtenText) {
                if (controller == _emailController) {
                  if (writtenText.trim().isNotEmpty &&
                      CommonMethods.validateEmail(writtenText)) {
                    _isValidEmail = true;
                  } else {
                    _isValidEmail = false;
                  }
                  _setState();
                }
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
      if (val == null || val.toString().isEmpty) {
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
      _region = locationController.text;
      if (addressControllerList.length == 6 &&
          addressControllerList[5] != null) {
        _region = addressControllerList[5];
      }
    });
  }

  void initialize() {
    _user = UserManager().getUserDetails();
    _isValidEmail = true;
    _emailController.text = _user.email ?? "";
    isDoctor = widget.userType == Constants.doctor ? true : false;
    nameController.text = widget.fullName;
    dobController.text = widget.dateOfBirth;
    educationController.text = widget.education;
    collegeController.text = widget.college;
    professionRegController.text = _user.profRegistrationNumber;
    experienceController.text = _user.experience;
    aboutController.text = _user.about;
    if (_user.userType == Constants.user) {
      locationController.text = widget.location;
    } else {
      locationController.text = _user.googleLocation ?? "";
      manualAddressController.text = widget.location;
    }
  }

  updateProfileRequest() async {
    FocusScope.of(context).requestFocus(FocusNode());
//    List specialistId = new List();
//    for (var item in _selectedItemId)
//      specialistId.add({'specialityId': item});
    var details = UserManager().getUserDetails();
//    if (details.isCentre != null && details.isCentre) {
//      widget.showInSnackBar("Centre details can't be updated",
//          PlunesColors.BLACKCOLOR, _scaffoldKey);
//      return;
//    }
    if (_user.userType == Constants.user && !(_isValidEmail)) {
      widget.showInSnackBar(plunesStrings.errorValidEmailMsg,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
      return;
    } else if (_user.userType != Constants.user) {
      if (manualAddressController.text.trim() == null ||
          manualAddressController.text.trim().isEmpty) {
        widget.showInSnackBar(plunesStrings.errorFullAddressRequired,
            PlunesColors.BLACKCOLOR, _scaffoldKey);
        return;
      }
    }
    var user = User(
        name: nameController.text.trim(),
        latitude: (_latitude == null || _latitude == "0.0")
            ? details.latitude ?? "0.0"
            : _latitude,
        longitude: (_longitude == null || _longitude == "0.0")
            ? details.longitude ?? "0.0"
            : _longitude,
        address: (_user.userType == Constants.user)
            ? locationController.text.trim()
            : manualAddressController.text,
        googleLocation: (_user.userType != Constants.user)
            ? locationController.text.trim()
            : "",
        birthDate: dobController.text.trim(),
        registrationNumber: professionRegController.text.trim(),
        experience: experienceController.text.trim(),
        // about: aboutController.text.trim(),
        biography: aboutController.text.trim(),
        qualification: educationController.text.trim(),
        college: collegeController.text.trim(),
        practising: practisingController.text.trim(),
        email: (_user.userType == Constants.user && _isValidEmail)
            ? _emailController.text.trim()
            : null);
//    print("user.toJson() ${user.toJson()}");
    progress = true;
    _setState();
    var result = await _userBloc.updateUserData(user.toJson());
    if (result is RequestSuccess) {
      if (_user.userType == Constants.user) {
        UserManager().setRegion(_region);
      }
      widget.showInSnackBar(plunesStrings.success, Colors.green, _scaffoldKey);
      Future.delayed(Duration(milliseconds: 550)).then((value) {
        Navigator.pop(context);
      });
    } else if (result is RequestFailed) {
      RequestFailed requestFailed = result;
      widget.showInSnackBar(
          requestFailed.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
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
