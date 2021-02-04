import 'dart:async';
import 'dart:io';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/new_solution_blocs/user_medical_detail_bloc.dart';
import 'package:plunes/models/new_solution_model/medical_file_upload_response_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';
import 'package:file_picker/file_picker.dart';

// ignore: must_be_immutable
class EnterAdditionalUserDetailScr extends BaseActivity {
  final CatalogueData catalogueData;
  final String searchQuery;

  EnterAdditionalUserDetailScr(this.catalogueData, this.searchQuery);

  @override
  _EnterAdditionalUserDetailScrState createState() =>
      _EnterAdditionalUserDetailScrState();
}

class _EnterAdditionalUserDetailScrState
    extends BaseState<EnterAdditionalUserDetailScr>
    with TickerProviderStateMixin, ImagePickerListener {
  PageController _pageController;
  StreamController _pageStream;
  SubmitUserMedicalDetailBloc _submitUserMedicalDetailBloc;
  TextEditingController _additionalDetailController,
      _previousMedicalConditionController;
  bool _hasTreatedPreviously = false;
  AnimationController _animationController;
  ImagePickerHandler _imagePicker;
  List<Map<String, dynamic>> _docUrls, _imageUrls;

  @override
  void initState() {
    _pageStream = StreamController.broadcast();
    _pageController = PageController(initialPage: 0);
    _submitUserMedicalDetailBloc = SubmitUserMedicalDetailBloc();
    _additionalDetailController = TextEditingController();
    _previousMedicalConditionController = TextEditingController();
    _initializeForImageFetching();
    super.initState();
  }

  _initializeForImageFetching() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _imagePicker = ImagePickerHandler(this, _animationController, false);
    _imagePicker.init();
  }

  @override
  void dispose() {
    _pageStream?.close();
    _pageController?.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  _uploadFile(File file, {String fileType}) async {
    _submitUserMedicalDetailBloc.uploadFile(file, fileType: fileType);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            key: scaffoldKey,
            body: StreamBuilder<RequestState>(
                stream: _submitUserMedicalDetailBloc.uploadFileStream,
                builder: (context, snapshot) {
                  if (snapshot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  } else if (snapshot.data is RequestSuccess) {
                    Future.delayed(Duration(milliseconds: 10)).then((value) {
                      _showMessagePopup(PlunesStrings.uplaodSuccessMessage);
                    });
                    RequestSuccess data = snapshot.data;
                    if (data.additionalData != null &&
                        data.additionalData.toString() == Constants.typeImage) {
                      _setImageUrls(data.response);
                    } else if (data.additionalData != null &&
                        data.additionalData.toString() ==
                            Constants.typeReport) {
                      _setReportUrls(data.response);
                    }
                    _submitUserMedicalDetailBloc.addIntoSubmitFileStream(null);
                  } else if (snapshot.data is RequestFailed) {
                    RequestFailed _reqFailObj = snapshot.data;
                    Future.delayed(Duration(milliseconds: 10)).then((value) {
                      _showMessagePopup(_reqFailObj?.failureCause);
                    });
                    _submitUserMedicalDetailBloc.addIntoSubmitFileStream(null);
                  }
                  return _getBody();
                }),
          ),
        ));
  }

  Widget _getBody() {
    return StreamBuilder<RequestState>(
        stream: _submitUserMedicalDetailBloc.submitDetailStream,
        builder: (context, snapshot) {
          if (snapshot.data is RequestInProgress) {
            return CustomWidgets().getProgressIndicator();
          } else if (snapshot.data is RequestSuccess) {
            RequestSuccess data = snapshot.data;
            if (data.response != null && data.response) {
              _navigateToNextScreen();
            }
            _submitUserMedicalDetailBloc.addIntoSubmitMedicalDetailStream(null);
          } else if (snapshot.data is RequestFailed) {
            RequestFailed _reqFailObj = snapshot.data;
            Future.delayed(Duration(milliseconds: 10)).then((value) {
              _showMessagePopup(_reqFailObj?.failureCause);
            });
            _submitUserMedicalDetailBloc.addIntoSubmitMedicalDetailStream(null);
          }
          return Container(
            margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
            child: Column(
              children: [
                _getAppAndSearchBarWidget(),
                Expanded(
                  child: _getPageViewWidget(),
                ),
                _getNavigatorBar()
              ],
            ),
          );
        });
  }

  Widget _getAppAndSearchBarWidget() {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 2.5,
            right: AppConfig.horizontalBlockSize * 2.5,
            top: AppConfig.verticalBlockSize * 0.6,
            bottom: AppConfig.horizontalBlockSize * 1.8),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(19, 184, 126, 0.19),
            Color.fromRGBO(255, 255, 255, 0),
          ],
        )),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                      return;
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: PlunesColors.BLACKCOLOR,
                    ),
                  )),
              title: Text(
                PlunesStrings.bookYourProcedure,
                textAlign: TextAlign.left,
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 0.8,
                  bottom: AppConfig.verticalBlockSize * 2.8),
              child: Card(
                elevation: 4.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24))),
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 6,
                      vertical: AppConfig.verticalBlockSize * 1.6),
                  child: Text(
                    widget.catalogueData?.service ?? "",
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getPageViewWidget() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [_getFirstPage(), _getSecondPage()],
    );
  }

  Widget _getFirstPage() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 4.2,
          vertical: AppConfig.verticalBlockSize * 2.5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Text(
                PlunesStrings.enterAdditionalDetails,
                textAlign: TextAlign.left,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 18,
                    color: PlunesColors.BLACKCOLOR.withOpacity(0.8)),
              ),
            ),
            Card(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                  Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 3.5,
                      vertical: AppConfig.verticalBlockSize * 1.5),
                  constraints: BoxConstraints(
                      minHeight: AppConfig.verticalBlockSize * 15,
                      maxHeight: AppConfig.verticalBlockSize * 25),
                  child: Row(
                    children: [
                      Flexible(
                          child: TextField(
                        maxLines: 10,
                        controller: _additionalDetailController,
                        style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration.collapsed(
                            hintText: "Enter additional details",
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#979797")))),
                      ))
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2.5),
              child: Text(
                "Upload Pictures of Your Medical Concern (Reports/Videos) to get Best Prices from Medical Professionals",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR.withOpacity(0.8),
                    fontSize: 18),
              ),
            ),
            Container(
              width: double.infinity,
              margin:
                  EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.5),
              child: Row(
                children: [
                  Expanded(child: _getVideoCard()),
                  Expanded(child: _getCameraCard()),
                  Expanded(child: _getUploadReportCard()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getVideoCard() {
    return Card(
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      elevation: 2.5,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            gradient: LinearGradient(colors: [
              Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
              Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Container(
          margin: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 4,
              right: AppConfig.horizontalBlockSize * 4,
              top: AppConfig.verticalBlockSize * 3,
              bottom: AppConfig.verticalBlockSize * 1.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                PlunesImages.videoUploadIcon,
                height: 49,
                width: 49,
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 4),
                child: Text(
                  "Upload Video",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 14),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCameraCard() {
    return Card(
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      elevation: 2.5,
      child: InkWell(
        onTap: () {
          _imagePicker?.showDialog(context);
        },
        onDoubleTap: () {},
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              gradient: LinearGradient(colors: [
                Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 4,
                right: AppConfig.horizontalBlockSize * 4,
                top: AppConfig.verticalBlockSize * 3,
                bottom: AppConfig.verticalBlockSize * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  PlunesImages.imageUploadIcon,
                  height: 49,
                  width: 49,
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 4),
                  child: Text(
                    "Upload Photo",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 14),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getUploadReportCard() {
    return Card(
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      elevation: 2.5,
      child: InkWell(
        onTap: () {
          FilePicker.getFile(type: FileType.any).then((value) {
            if (value != null &&
                value.path != null &&
                value.path.trim().isNotEmpty &&
                value.path.contains(".")) {
              print("path ${value.path}");
              String _fileExtension = value.path.split(".")?.last;
              if (_fileExtension != null &&
                  (_fileExtension.toLowerCase() ==
                      Constants.pdfExtension.toLowerCase())) {
                _uploadFile(value, fileType: Constants.typeReport);
              } else {
                _showMessagePopup(PlunesStrings.selectValidDocWarningText);
              }
            } else {
              _showMessagePopup(PlunesStrings.selectValidDocWarningText);
            }
          });
        },
        onDoubleTap: () {},
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              gradient: LinearGradient(colors: [
                Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 4,
                right: AppConfig.horizontalBlockSize * 4,
                top: AppConfig.verticalBlockSize * 3,
                bottom: AppConfig.verticalBlockSize * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  PlunesImages.docUploadIcon,
                  height: 49,
                  width: 49,
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 4),
                  child: Text(
                    "Upload Report",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 14),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNavigatorBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 3.0,
          margin: EdgeInsets.all(0),
          child: Container(),
        ),
        Card(
          margin: EdgeInsets.all(0),
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4.2,
                vertical: AppConfig.verticalBlockSize * 2),
            child: StreamBuilder<Object>(
                stream: _pageStream.stream,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          if ((_pageController == null ||
                              _pageController.page == null ||
                              _pageController.page.toInt() == 0)) {
                            return;
                          }
                          _pageController
                              .animateToPage(0,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut)
                              .then((value) {
                            _pageStream.add(null);
                          });
                        },
                        child: CustomWidgets().getRoundedButton(
                            PlunesStrings.previousText,
                            AppConfig.horizontalBlockSize * 8,
                            PlunesColors.GREYCOLOR.withOpacity(0.09),
                            AppConfig.horizontalBlockSize * 5,
                            AppConfig.verticalBlockSize * 1,
                            (_pageController == null ||
                                    _pageController.page == null ||
                                    _pageController.page.toInt() == 0)
                                ? PlunesColors.GREYCOLOR.withOpacity(0.09)
                                : PlunesColors.BLACKCOLOR,
                            borderColor: PlunesColors.SPARKLINGGREEN,
                            hasBorder: false),
                      ),
                      DotsIndicator(
                        dotsCount: 2,
                        position: _pageController.page ?? 0,
                        decorator: DotsDecorator(
                            activeColor: PlunesColors.BLACKCOLOR,
                            color: PlunesColors.GREYCOLOR),
                      ),
                      InkWell(
                        onDoubleTap: () {},
                        onTap: () {
                          if (_pageController.page.toInt() == 1) {
                            _submitUserDetail();
                            //submit
                          } else {
                            _pageController
                                .animateToPage(1,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut)
                                .then((value) {
                              _pageStream.add(null);
                            });
                          }
                        },
                        child: CustomWidgets().getRoundedButton(
                            (_pageController == null ||
                                    _pageController.page == null)
                                ? PlunesStrings.next
                                : _pageController.page.toInt() == 1
                                    ? plunesStrings.submit
                                    : PlunesStrings.next,
                            AppConfig.horizontalBlockSize * 8,
                            PlunesColors.PARROTGREEN,
                            AppConfig.horizontalBlockSize * 5,
                            AppConfig.verticalBlockSize * 1,
                            PlunesColors.WHITECOLOR,
                            borderColor: PlunesColors.SPARKLINGGREEN,
                            hasBorder: true),
                      )
                    ],
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget _getSecondPage() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 4.2,
          vertical: AppConfig.verticalBlockSize * 2.5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Text(
                PlunesStrings.haveYouEverBeenTreatedPreviously,
                textAlign: TextAlign.left,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 18,
                    color: PlunesColors.BLACKCOLOR.withOpacity(0.8)),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {},
                    child: _hasTreatedPreviously
                        ? InkWell(
                            child: _getSelectedButton(),
                            onDoubleTap: () {},
                            onTap: () {
                              _hasTreatedPreviously = true;
                              _setState();
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                          )
                        : InkWell(
                            child: _getUnselectedButton(),
                            onDoubleTap: () {},
                            onTap: () {
                              _hasTreatedPreviously = true;
                              _setState();
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                          ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 3),
                    child: Text(
                      "Yes",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#979797"))),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 10),
                  ),
                  InkWell(
                    onTap: () {},
                    child: _hasTreatedPreviously
                        ? InkWell(
                            child: _getUnselectedButton(),
                            onDoubleTap: () {},
                            onTap: () {
                              _hasTreatedPreviously = false;
                              _setState();
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                          )
                        : InkWell(
                            child: _getSelectedButton(),
                            onDoubleTap: () {},
                            onTap: () {
                              _hasTreatedPreviously = false;
                              _setState();
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                          ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 3),
                    child: Text(
                      "No",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#979797"))),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: Text(
                PlunesStrings.pleaseDescribePreviousCondition,
                textAlign: TextAlign.left,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 18,
                    color: PlunesColors.BLACKCOLOR.withOpacity(0.8)),
              ),
            ),
            Card(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                  Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 3.5,
                      vertical: AppConfig.verticalBlockSize * 1.5),
                  constraints: BoxConstraints(
                      minHeight: AppConfig.verticalBlockSize * 15,
                      maxHeight: AppConfig.verticalBlockSize * 25),
                  child: Row(
                    children: [
                      Flexible(
                          child: TextField(
                        maxLines: 10,
                        controller: _previousMedicalConditionController,
                        style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration.collapsed(
                            hintText: "Enter your condition",
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#979797")))),
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedButton() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 4.5,
          vertical: AppConfig.verticalBlockSize * 2.2),
      decoration: BoxDecoration(
          color: PlunesColors.GREENCOLOR,
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }

  Widget _getUnselectedButton() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 4,
          vertical: AppConfig.verticalBlockSize * 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: PlunesColors.GREYCOLOR)),
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  @override
  fetchImageCallBack(File image) {
    if (image != null && image.path != null) {
      print(image.path);
      _uploadFile(image, fileType: Constants.typeImage);
    }
  }

  void _showMessagePopup(String message) {
    if (mounted) {
      showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets()
                .getInformativePopup(globalKey: scaffoldKey, message: message);
          });
    }
  }

  void _setImageUrls(var response) {
    MedicalFileResponseModel _medicalFileResponseModel = response;
    if (_imageUrls == null) {
      _imageUrls = [];
    }
    if (_medicalFileResponseModel.data != null &&
        _medicalFileResponseModel.data.reports != null &&
        _medicalFileResponseModel.data.reports.isNotEmpty) {
      _imageUrls.add(_medicalFileResponseModel.data.reports.first.toJson());
    }
  }

  void _setReportUrls(var response) {
    MedicalFileResponseModel _medicalFileResponseModel = response;
    if (_docUrls == null) {
      _docUrls = [];
    }
    if (_medicalFileResponseModel.data != null &&
        _medicalFileResponseModel.data.reports != null &&
        _medicalFileResponseModel.data.reports.isNotEmpty) {
      _docUrls.add(_medicalFileResponseModel.data.reports.first.toJson());
    }
  }

  void _submitUserDetail() {
    Map<String, dynamic> _postData = {
      "serviceId": widget.catalogueData?.serviceId,
      "reportUrls": _docUrls ?? [],
      "imageUrls": _imageUrls ?? [],
      "videoUrls": [],
      "treatedPreviously": _hasTreatedPreviously,
      "description": _previousMedicalConditionController.text.trim(),
      "additionalDetails": _additionalDetailController.text.trim()
    };
    // print("data $_postData");
    _submitUserMedicalDetailBloc.submitUserMedicalDetail(_postData);
  }

  void _navigateToNextScreen() {
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ViewSolutionsScreen(
                    searchQuery: widget.searchQuery,
                    catalogueData: widget.catalogueData,
                  )));
    });
  }
}