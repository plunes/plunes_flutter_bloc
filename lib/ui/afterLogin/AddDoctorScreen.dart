import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import 'package:plunes/ui/commonView/SelectSpecialization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AvailabilitySelectionScreen.dart';

class AddDoctorScreen extends BaseActivity {
  static const tag = '/addDoctor';

  @override
  _AddDoctorScreenState createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen>
    with TickerProviderStateMixin, ImagePickerListener
    implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  final specializationController = TextEditingController();
  final professionRegController = TextEditingController();
  final experienceController = TextEditingController();
  final practisingController = TextEditingController();
  final docEducationController = new TextEditingController();
  final docDesignationController = new TextEditingController();
  final docDepartmentController = new TextEditingController();
  final aboutController = new TextEditingController();
  final docNameController = new TextEditingController();
  final educationController = TextEditingController();
  final collegeController = TextEditingController();

  FocusNode nameFocusNode = new FocusNode(),
      educationFocusNode = new FocusNode(),
      professionalFocusNode = new FocusNode(),
      expFocusNode = new FocusNode(),
      practisingFocusNode = new FocusNode(),
      collegeFocusNode = new FocusNode(),
      aboutFocusNode = new FocusNode();
  String image;
  AnimationController _animationController;
  ImagePickerHandler imagePicker;
  bool isDoctor = false, isSpecificationValid = true;
  bool emain_valid = true;
  var globalHeight, globalWidth;
  bool profession_valid = true;
  bool specification_valid = true, name_valid = true;
  bool experience_valid = true, isExperienceValid = true;
  String _userType, _latitude = '', _longitude = '';
  bool progress = false;
  String user_token = "";
  String user_id = "", errorMessage = '';
  File _image;

  List<dynamic> _selectedItemId = List(), _selectedSpecializationData = List();

  @override
  void dispose() {
    bloc.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {
      user_token = token;
      user_id = uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        key: _scaffoldKey,
        appBar: widget.getAppBar(context, '', true),
        backgroundColor: Colors.white,
        body: GestureDetector(
            onTap: () => CommonMethods.hideSoftKeyboard(), child: bodyView()));
  }

  Widget bodyView() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          getAddDoctorsView(),
        ],
      ),
    );
  }

  Widget getAddDoctorsView() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.getSpacer(20.0, 0.0),
          widget.createTextViews(stringsFile.profileImage, 18,
              colorsFile.black0, TextAlign.left, FontWeight.normal),
          widget.getSpacer(0.0, 20.0),
          Row(
            children: <Widget>[
              InkWell(
                onTap: () {},
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          color: Color(0x90ffBDBDBD)),
                      height: 80,
                      width: 80,
                    ),
                    Align(
                      child: Icon(
                        Icons.camera_enhance,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    Align(
                        child: image != null
                            ? CircleAvatar(
                                radius: 40,
                                backgroundImage: ExactAssetImage(image))
                            : Container()),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              widget.getDefaultButton(stringsFile.upload, 100, 35, _pickImage),
            ],
          ),
          widget.getSpacer(0.0, 30.0),
          createTextField(docNameController, stringsFile.fullName,
              TextInputType.text, TextCapitalization.words, true, ''),
          widget.getSpacer(0.0, 20.0),
          createTextField(
              docEducationController,
              stringsFile.educationQualification,
              TextInputType.text,
              TextCapitalization.characters,
              true,
              ''),
          widget.getSpacer(0.0, 20.0),
          createTextField(docDesignationController, stringsFile.designation,
              TextInputType.text, TextCapitalization.characters, true, ''),
          widget.getSpacer(0.0, 20.0),
          createTextField(docDepartmentController, stringsFile.department,
              TextInputType.text, TextCapitalization.words, true, ''),
          widget.getSpacer(0.0, 20.0),
          createTextField(
              specializationController,
              stringsFile.speciality,
              TextInputType.text,
              TextCapitalization.words,
              isSpecificationValid,
              stringsFile.errorMsgEnterSpecialization),
          widget.getSpacer(0.0, 20.0),
          createTextField(
              experienceController,
              stringsFile.experienceInNo,
              TextInputType.numberWithOptions(decimal: true),
              TextCapitalization.none,
              isExperienceValid,
              stringsFile.errorMsgEnterExp),
          widget.getSpacer(0.0, 20.0),
          /*     widget.createTextViews(stringsFile.availability, 18, colorsFile.black0, TextAlign.left, FontWeight.normal),
          widget.getSpacer(0.0, 10.0),
          Row(
            children: <Widget>[
              Expanded(child: getSlotsRow(doc_availability_from, "00:00 AM")),
              SizedBox(
                width: 10,
              ),
              Expanded(child: getSlotsRow(doc_availability_to, "00:00 PM")),
            ],
          ),*/
          widget.getSpacer(0.0, 20.0),
          widget.getDefaultButton(stringsFile.availability, globalWidth - 40,
              42, goToAvailabilityScreen),
          widget.getSpacer(0.0, 20.0),
          widget.getDefaultButton(
              stringsFile.add, globalWidth - 40, 42, addDoctorsInRow),
          widget.getSpacer(0.0, 40.0),
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
    return InkWell(
      onTap: () {
        if (controller == dobController)
          CommonMethods.selectDate(context).then((value) {
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
    isDoctor = widget.usersType == Constants.doctor ? true : false;
    initializeForImageFetching();
  }

  initializeForImageFetching() {
    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {});
    imagePicker = new ImagePickerHandler(this, _animationController, false);
    imagePicker.init();
  }

  updateProfileRequest() {
    var body = {};
    body['name'] = nameController.text;
    body['latitude'] = _latitude;
    body['longitude'] = _longitude;
    body['address'] = locationController.text;

    progress = true;
    bloc.updateRequest(context, this, body);
    bloc.updateProfileFetcher.listen((data) async {
      progress = false;
      if (data != null && data['success'] != null && data['success']) {
        await bloc.saveEditProfileDataInPreferences(context, body);
        widget.showInSnackBar(stringsFile.success, Colors.green, _scaffoldKey);
      } else {
        widget.showInSnackBar(data.message, Colors.red, _scaffoldKey);
      }
    });
  }

  @override
  dialogCallBackFunction(String action) {}

  addDoctorsInRow() {
    if (validationAddDoctors()) {
      setState(() {
        var doctors = {};
        doctors['name'] = docNameController.text;
        doctors['education'] = docEducationController.text;
        doctors['designation'] = docDesignationController.text;
        doctors['department'] = docDepartmentController.text;
        doctors['experience'] = experienceController.text;
        doctors['specialities'] = _selectedItemId;
//        _doctorsList.add(doctors);
        docNameController.text = '';
        docEducationController.text = '';
        docDesignationController.text = '';
        docDepartmentController.text = '';
        experienceController.text = '';
        specializationController.text = '';
        _selectedItemId = [];
      });
    } else {
      widget.showInSnackBar((errorMessage), Colors.red, _scaffoldKey);
    }
  }

  bool validationAddDoctors() {
    if (docNameController.text.trim().isEmpty) {
      errorMessage = stringsFile.errorMsgEnterDocName;
      return false;
    } else if (docEducationController.text.trim().isEmpty) {
      errorMessage = stringsFile.errorMsgEnterEducation;
      return false;
    } else if (docDepartmentController.text.trim().isEmpty) {
      errorMessage = stringsFile.errorMsgEnterDocDep;
      return false;
    } else if (specializationController.text.trim().isEmpty) {
      errorMessage = stringsFile.errorMsgEnterSpecialization;
      return false;
    } else if (experienceController.text.trim().isEmpty) {
      errorMessage = stringsFile.errorMsgEnterExp;
      return false;
    } else {
      return true;
    }
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

  _pickImage() {
    imagePicker.showDialog(context);
  }

  @override
  fetchImageCallBack(File _image) {
    if (_image != null) {
      print("image==" + base64Encode(_image.readAsBytesSync()).toString());
      this._image = _image;
      image = _image.path;
      setState(() {});
    }
  }

  void goToAvailabilityScreen() {
    CommonMethods.goToPage(context, AvailabilitySelectionScreen());
  }
}
