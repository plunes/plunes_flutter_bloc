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
import 'package:plunes/Utils/video_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/new_solution_blocs/user_medical_detail_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/new_solution_model/form_data_response_model.dart';
import 'package:plunes/models/new_solution_model/medical_file_upload_response_model.dart';
import 'package:plunes/models/new_solution_model/premium_benefits_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plunes/ui/afterLogin/upload_video_for_treatment.dart';

// ignore: must_be_immutable
class EnterAdditionalUserDetailScr extends BaseActivity {
  final CatalogueData catalogueData;
  final String searchQuery;
  bool consultation;

  EnterAdditionalUserDetailScr(this.catalogueData, this.searchQuery, {this.consultation=false});

  @override
  _EnterAdditionalUserDetailScrState createState() =>
      _EnterAdditionalUserDetailScrState();
}

class _EnterAdditionalUserDetailScrState
    extends BaseState<EnterAdditionalUserDetailScr>
    with TickerProviderStateMixin, ImagePickerListener {
  PageController _pageController;
  StreamController _pageStream;
  UserMedicalDetailBloc _submitUserMedicalDetailBloc;
  TextEditingController _additionalDetailController,
      _previousMedicalConditionController;
  bool _hasTreatedPreviously = false;
  bool _isInsuranceCovered = false;
  AnimationController _animationController;
  ImagePickerHandler _imagePicker;
  List<Map<String, dynamic>> _docUrls, _imageUrls;
  List<UploadedReportUrl> _videoUrls;
  UserBloc _userBloc;
  PremiumBenefitsModel _premiumBenefitsModel;
  List<MedicalFormData> _formItemList;
  bool _isBodyPartListOpened;
  FormDataModel _formDataModel;
  String _failedMessage;
  MedicalSession _medicalSessionModel;

  @override
  void initState() {
    _isBodyPartListOpened = false;
    _formItemList = [];
    _userBloc = UserBloc();
    _submitUserMedicalDetailBloc = UserMedicalDetailBloc();
    _getFormData();
    _getPremiumBenefitsForUsers();
    _pageStream = StreamController.broadcast();
    _pageController = PageController(initialPage: 0);
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
    _userBloc?.dispose();
    _formItemList?.forEach((element) {
      element?.valueController?.dispose();
    });
    super.dispose();
  }

  _getPremiumBenefitsForUsers() {
    _userBloc.getPremiumBenefitsForUsers().then((value) {
      if (value is RequestSuccess) {
        _premiumBenefitsModel = value.response;
        _setState();
      }
    });
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
                    RequestInProgress requestInProgress = snapshot.data;
                    if (requestInProgress != null &&
                        requestInProgress.data == null) {
                      return CustomWidgets().getProgressIndicator();
                    }
                  } else if (snapshot.data is RequestSuccess) {
                    RequestSuccess data = snapshot.data;
                    Future.delayed(Duration(milliseconds: 10)).then((value) {
                      if (data.additionalData != null &&
                          (data.additionalData.toString() ==
                                  Constants.typeImage ||
                              data.additionalData.toString() ==
                                  Constants.typeReport)) {
                        _showMessagePopup(PlunesStrings.uplaodSuccessMessage);
                      }
                    });
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
                      if (_reqFailObj.response != null &&
                          (_reqFailObj.response.toString() ==
                                  Constants.typeImage ||
                              _reqFailObj.response.toString() ==
                                  Constants.typeReport))
                        _showMessagePopup(_reqFailObj?.failureCause);
                    });
                    _submitUserMedicalDetailBloc.addIntoSubmitFileStream(null);
                  }
                  return _getBodyData();
                }),
          ),
        ));
  }

  Widget _getBodyData() {
    return StreamBuilder<RequestState>(
        stream: _submitUserMedicalDetailBloc.fetchDetailStream,
        initialData: _formDataModel == null ? RequestInProgress() : null,
        builder: (context, snapshot) {
          if (snapshot.data is RequestSuccess) {
            RequestSuccess successObject = snapshot.data;
            _formDataModel = successObject.response;
            _initFormData();
            _submitUserMedicalDetailBloc?.addIntoFetchMedicalDetailStream(null);
          } else if (snapshot.data is RequestFailed) {
            RequestFailed _failedObj = snapshot.data;
            _failedMessage = _failedObj?.failureCause;
            _submitUserMedicalDetailBloc?.addIntoFetchMedicalDetailStream(null);
          } else if (snapshot.data is RequestInProgress) {
            return CustomWidgets().getProgressIndicator();
          }

          return (_formDataModel == null ||
                  (_formDataModel.success != null && !_formDataModel.success))
              ? CustomWidgets().errorWidget(_failedMessage,
                  onTap: () => _getFormData(), isSizeLess: true)
              : _getBody();
        });
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
              _navigateToNextScreen(data?.additionalData?.toString());
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
            Row(
              children: [
                Container(
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
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 28),
                    child: Text(
                     widget.consultation ? "Book your Consultation" :
                      PlunesStrings.bookYourProcedure,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 0.8,
                  bottom: AppConfig.verticalBlockSize * 2.8),
              child: Card(
                elevation: 4.0,
                color: Colors.white,
                shadowColor: Color(CommonMethods.getColorHexFromStr("#E7E7E7")),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 6),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 3,
                      vertical: AppConfig.verticalBlockSize * 1.6),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            right: AppConfig.horizontalBlockSize * 3),
                        child: Image.asset(
                          PlunesImages.searchIcon,
                          color: Color(
                            CommonMethods.getColorHexFromStr("#B1B1B1"),
                          ),
                          width: AppConfig.verticalBlockSize * 2.0,
                          height: AppConfig.verticalBlockSize * 2.0,
                        ),
                      ),
                      Expanded(
                          child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: widget.catalogueData?.family ?? "",
                            // children: [
                            //   TextSpan(
                            //       text:
                            //           "${widget.catalogueData.service == null ? "" : " (${widget.catalogueData.service})"}",
                            //       style: TextStyle(
                            //           color: CommonMethods
                            //               .getColorForSpecifiedCode(
                            //                   "#444444"),
                            //           fontSize: 14))
                            // ],
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 18)),
                      )
                          // Text(
                          //   widget.catalogueData?.service ?? "",
                          //   textAlign: TextAlign.left,
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(
                          //       color: PlunesColors.BLACKCOLOR, fontSize: 16)
                          // ),
                          ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _hasFormDataList() {
    return (_formItemList != null && _formItemList.isNotEmpty) ||
        (_medicalSessionModel != null &&
            _medicalSessionModel.sessions != null &&
            _medicalSessionModel.sessions.isNotEmpty);
  }

  Widget _getPageViewWidget() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [
        _getFirstPage(),
        _hasFormDataList() ? _getConditionalPage() : _getSecondPage(),
        _getSecondPage()
      ],
    );
  }

  Widget _getConditionalPage() {
    return _medicalSessionModel != null && _medicalSessionModel.sessions != null
        ? _getMedicalSessionWidget()
        : Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4.2,
                vertical: AppConfig.verticalBlockSize * 2.5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        "${(_formDataModel.data != null && _formDataModel?.data?.childrenKeys != null && _formDataModel.data.childrenKeys.isNotEmpty) ? _formDataModel.data.childrenKeys.first : ""}",
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: PlunesColors.BLACKCOLOR
                                                .withOpacity(0.8)),
                                      ),
                                    ),
                                    _getDropDownOfBodyParts()
                                  ],
                                )),
                            _formItemList.first.sessionValues == null ||
                                    _formItemList.first.sessionValues.isEmpty
                                ? Container()
                                : Expanded(
                                    flex: 5,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            child: Text(
                                              "${(_formDataModel.data != null && _formDataModel.data.childrenKeys != null && _formDataModel.data.childrenKeys.length > 1) ? _formDataModel?.data?.childrenKeys[1] : ""}",
                                              textAlign: TextAlign.left,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: PlunesColors.BLACKCOLOR
                                                      .withOpacity(0.8)),
                                            ),
                                          ),
                                          _formItemList.first.sessionValues ==
                                                      null ||
                                                  _formItemList.first
                                                      .sessionValues.isEmpty
                                              ? Container()
                                              : _getSessionDropDown()
                                        ],
                                      ),
                                    )),
                          ],
                        ),
                      ),
                      _getAddButton()
                    ],
                  ),
                  Column(
                    children: [
                      _getSeparatorLine(),
                      Container(
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 1),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            if (_formItemList[index].isItemSeparated) {
                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: AppConfig.verticalBlockSize * 1),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 7,
                                              child: Container(
                                                  child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                margin: EdgeInsets.zero,
                                                elevation: 2,
                                                child: Container(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                            horizontal: 5,
                                                            vertical: 5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5)),
                                                        gradient: LinearGradient(
                                                            colors: [
                                                              Color(CommonMethods
                                                                  .getColorHexFromStr(
                                                                      "#FEFEFE")),
                                                              Color(CommonMethods
                                                                  .getColorHexFromStr(
                                                                      "#F6F6F6"))
                                                            ],
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter)),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 1),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  _formItemList[
                                                                              index]
                                                                          .bodyPartName ??
                                                                      "",
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: PlunesColors
                                                                          .BLACKCOLOR),
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_drop_down,
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            1),
                                                              )
                                                            ],
                                                          ),
                                                          Text(
                                                            "${(_formDataModel.data != null && _formDataModel.data.childrenKeys != null && _formDataModel.data.childrenKeys.isNotEmpty) ? _formDataModel.data.childrenKeys.first : ""}",
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    CommonMethods
                                                                        .getColorHexFromStr(
                                                                            "#797979"))),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ))),
                                          _formItemList[index].sessionValues ==
                                                      null ||
                                                  _formItemList[index]
                                                      .sessionValues
                                                      .isEmpty
                                              ? Container()
                                              : Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 10),
                                                    child: _formItemList[index]
                                                                    .sessionValues ==
                                                                null ||
                                                            _formItemList[index]
                                                                .sessionValues
                                                                .isEmpty
                                                        ? Container()
                                                        : Container(
                                                            child: Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                            margin:
                                                                EdgeInsets.zero,
                                                            elevation: 2,
                                                            child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            5),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(
                                                                                5)),
                                                                        gradient: LinearGradient(
                                                                            colors: [
                                                                              Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                                                                              Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
                                                                            ],
                                                                            begin:
                                                                                Alignment.topCenter,
                                                                            end: Alignment.bottomCenter)),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    ListView
                                                                        .builder(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              5),
                                                                      itemBuilder:
                                                                          (context,
                                                                              innerIndex) {
                                                                        if (innerIndex !=
                                                                                0 &&
                                                                            !_formItemList[index].isSessionListOpened) {
                                                                          return Container();
                                                                        }
                                                                        return InkWell(
                                                                          onTap:
                                                                              () {
                                                                            _formItemList[index].isSessionListOpened =
                                                                                !_formItemList[index].isSessionListOpened;
                                                                            _setState();
                                                                            if (_formItemList[index].sessionValues[innerIndex] ==
                                                                                _enterManually) {
                                                                              _openTextEditingPopup(_formItemList[index]);
                                                                              return;
                                                                            }
                                                                            _formItemList[index].sessionValue =
                                                                                _formItemList[index].sessionValues[innerIndex] ?? "";
                                                                            _setState();
                                                                          },
                                                                          onDoubleTap:
                                                                              () {},
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.only(top: 4.0),
                                                                                  child: _formItemList[index].isSessionListOpened && _formItemList[index].sessionValues[innerIndex] == _enterManually
                                                                                      ? Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Text(
                                                                                                "Enter",
                                                                                                style: TextStyle(fontSize: 16, color: PlunesColors.BLACKCOLOR),
                                                                                              ),
                                                                                            ),
                                                                                            Icon(Icons.mode_edit, size: 18),
                                                                                          ],
                                                                                        )
                                                                                      : Text(
                                                                                          _formItemList[index].isSessionListOpened ? _formItemList[index].sessionValues[innerIndex] ?? "" : _formItemList[index].sessionValue ?? _formItemList[index].sessionValues.first ?? "",
                                                                                          maxLines: 1,
                                                                                          style: TextStyle(fontSize: 16, color: PlunesColors.BLACKCOLOR),
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                              innerIndex == 0 && _formItemList[index].sessionValues.isNotEmpty && _formItemList[index].sessionValues.length > 1
                                                                                  ? InkWell(
                                                                                      onTap: () {
                                                                                        _formItemList[index].isSessionListOpened = !_formItemList[index].isSessionListOpened;
                                                                                        _setState();
                                                                                      },
                                                                                      onDoubleTap: () {},
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                                                        child: Icon(Icons.arrow_drop_down),
                                                                                      ),
                                                                                    )
                                                                                  : Container()
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemCount: _formItemList[
                                                                              index]
                                                                          .sessionValues
                                                                          .length,
                                                                    ),
                                                                    Text(
                                                                      "${(_formDataModel.data != null && _formDataModel.data.childrenKeys != null && _formDataModel.data.childrenKeys.length > 1) ? _formDataModel?.data?.childrenKeys[1] : ""}",
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Color(CommonMethods.getColorHexFromStr("#797979"))),
                                                                    ),
                                                                  ],
                                                                )),
                                                          )),
                                                  ))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: InkWell(
                                        child: Icon(Icons.close),
                                        onDoubleTap: () {},
                                        onTap: () {
                                          _formItemList[index].isItemSeparated =
                                              !_formItemList[index]
                                                  .isItemSeparated;
                                          _formItemList[index]
                                              .isSessionListOpened = false;
                                          _isBodyPartListOpened = false;
                                          _setState();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                          itemCount: _formItemList.length,
                          shrinkWrap: true,
                        ),
                      ),
                    ],
                  ),
                  _getPremiumBenefitsForUserWidget()
                ],
              ),
            ),
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
            (widget.catalogueData.service != null &&
                    widget.catalogueData.family != null &&
                    (widget.catalogueData.service.trim().toLowerCase() !=
                        widget.catalogueData.family.trim().toLowerCase()))
                ? Container(
                    margin: EdgeInsets.only(bottom: 7),
                    width: double.infinity,
                    child: Text(
                      "${widget.catalogueData.service.trim()}",
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 20, color: PlunesColors.BLACKCOLOR),
                    ),
                  )
                : Container(),
            Container(
              width: double.infinity,
              child: Text(
                "${PlunesStrings.enterAdditionalDetails + "medical treatment"}",
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                      minHeight: AppConfig.verticalBlockSize * 10,
                      maxHeight: AppConfig.verticalBlockSize * 20),
                  child: Row(
                    children: [
                      Flexible(
                          child: TextField(
                        maxLines: 10,
                        controller: _additionalDetailController,
                        maxLength: 500,
                        style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration.collapsed(
                            hintText: "Enter additional details" +
                                "${_isProcedure() ? "*" : ""}",
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
                "Upload pictures of your medical concern to get best prices from medical professionals",
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
                  Expanded(
                      child: (_videoUrls != null && _videoUrls.isNotEmpty)
                          ? _getVideoWithBackground()
                          : _getVideoCard()),
                  Expanded(
                      child: (_imageUrls != null && _imageUrls.isNotEmpty)
                          ? _getCameraCardWithBackground()
                          : _getCameraCard()),
                  Expanded(
                      child: (_docUrls != null && _docUrls.isNotEmpty)
                          ? _getReportWithBackground()
                          : _getUploadReportCard()),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin:
                  EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.5),
              child: Text(
                "Note* - Make sure to upload your correct medical reports & pictures as we share them with medical professionals to get best treatment details for you.",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 11.5),
              ),
            ),
            _getPremiumBenefitsForUserWidget()
          ],
        ),
      ),
    );
  }

  Widget _getReportWithBackground() {
    return Card(
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      elevation: 2.5,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          // _showReportDialog();
        },
        onDoubleTap: () {},
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                child: Image.asset(
                  plunesImages.pdfIcon1,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18))),
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
                      margin:
                          EdgeInsets.only(top: AppConfig.verticalBlockSize * 7),
                      child: Text(
                        "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.WHITECOLOR, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getVideoWithBackground() {
    return Card(
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      elevation: 2.5,
      child: InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          if (_videoUrls.first.url != null &&
              _videoUrls.first.url.trim().isNotEmpty) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoUtil(_videoUrls.first.url)));
          } else {
            _showMessagePopup(PlunesStrings.unableToPlayVideo);
          }
        },
        onDoubleTap: () {},
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                child: (_videoUrls.first.thumbnail == null ||
                        _videoUrls.first.thumbnail.isEmpty)
                    ? Image.asset(
                        PlunesImages.docUploadIcon,
                        fit: BoxFit.fill,
                      )
                    : CustomWidgets().getImageFromUrl(
                        _videoUrls.first.thumbnail ?? "",
                        boxFit: BoxFit.fill),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18))),
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
                      margin:
                          EdgeInsets.only(top: AppConfig.verticalBlockSize * 7),
                      child: Text(
                        "Video",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.WHITECOLOR, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
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
      child: InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          _showEncryptionPopup(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UploadVideoForTreatment(
                          submitUserMedicalDetailBloc:
                              _submitUserMedicalDetailBloc,
                        ))).then((value) {
              _submitUserMedicalDetailBloc?.addIntoSubmitFileStream(null);
              if (value != null) {
                if (_videoUrls == null) {
                  _videoUrls = [];
                }
                if (_videoUrls.isNotEmpty) {
                  _videoUrls.addAll(value);
                } else {
                  _videoUrls = value;
                }
              }
            });
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
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          _showEncryptionPopup(() {
            if (_imageUrls == null ||
                _imageUrls.isEmpty ||
                _imageUrls.length < 4) {
              _imagePicker?.showDialog(context);
            } else {
              _showMessagePopup("You can upload up to 3 pictures");
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

  Widget _getCameraCardWithBackground() {
    return Card(
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      elevation: 2.5,
      child: InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          _showImagesDialog();
        },
        onDoubleTap: () {},
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                child: CustomWidgets().getImageFromUrl(
                    _imageUrls?.first["url"] ?? "",
                    boxFit: BoxFit.fill),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18))),
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
                      margin:
                          EdgeInsets.only(top: AppConfig.verticalBlockSize * 7),
                      child: Text(
                        "Image",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.WHITECOLOR, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagesDialog() {
    showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.black54,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 3.38),
                height: AppConfig.verticalBlockSize * 6.5,
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Image",
                          style: TextStyle(
                              color: PlunesColors.WHITECOLOR, fontSize: 18),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: PlunesColors.WHITECOLOR,
                          ),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      height: AppConfig.verticalBlockSize * 82,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _showSelectedImages(),
                        ),
                      ),
                    ),
                    (_imageUrls.isNotEmpty && _imageUrls.length == 3)
                        ? Container()
                        : FlatButton(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Container(
                              height: AppConfig.verticalBlockSize * 3,
                              width: AppConfig.horizontalBlockSize * 30,
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: PlunesColors.GREENCOLOR,
                                    size: 15,
                                  ),
                                  Text(
                                    "Add More",
                                    style: TextStyle(
                                        color: PlunesColors.GREENCOLOR,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context, false);
                              _imagePicker.showDialog(context);
                            },
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showReportDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (_) => Material(
  //       type: MaterialType.transparency,
  //       child: Container(
  //         color: Colors.black54,
  //         child: Column(
  //           children: [
  //             Container(
  //               margin: EdgeInsets.symmetric(
  //                   horizontal: AppConfig.horizontalBlockSize * 3.38),
  //               height: AppConfig.verticalBlockSize * 6.5,
  //               child: Row(
  //                 children: [
  //                   Expanded(child: Container()),
  //                   Expanded(
  //                     child: Container(
  //                       alignment: Alignment.center,
  //                       child: Text(
  //                         "Report",
  //                         style: TextStyle(
  //                             color: PlunesColors.WHITECOLOR, fontSize: 18),
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Container(
  //                       alignment: Alignment.centerRight,
  //                       child: IconButton(
  //                         icon: Icon(
  //                           Icons.cancel,
  //                           color: PlunesColors.WHITECOLOR,
  //                         ),
  //                         onPressed: () => Navigator.pop(context, false),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Container(
  //               child: Column(
  //                 children: [
  //                   Container(
  //                     height: AppConfig.verticalBlockSize * 82,
  //                     child: FutureBuilder<RequestState>(
  //                       builder: (context, snapShot) {
  //                         if (snapShot.data is RequestInProgress) {
  //                           return CustomWidgets().getProgressIndicator();
  //                         } else if (snapShot.data is RequestFailed) {
  //                           RequestFailed _reqFailedObj = snapShot.data;
  //                           return Center(
  //                               child: Text(_reqFailedObj?.failureCause ??
  //                                   "Unable to downlaod pdf"));
  //                         } else if (snapShot.data is RequestSuccess) {
  //                           RequestSuccess reqSuccess = snapShot.data;
  //                           PDFDocument doc = reqSuccess.response;
  //                           return Column(
  //                             children: [
  //                               Expanded(
  //                                   child: PDFViewer(
  //                                       document: doc, lazyLoad: true)),
  //                               Container(
  //                                 margin: EdgeInsets.only(
  //                                     left:
  //                                         AppConfig.horizontalBlockSize * 3.38,
  //                                     top: AppConfig.verticalBlockSize * 1),
  //                                 alignment: Alignment.centerLeft,
  //                                 child: FlatButton(
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(18.0),
  //                                     side: BorderSide(
  //                                         color: PlunesColors.WHITECOLOR),
  //                                   ),
  //                                   onPressed: () {
  //                                     if (mounted)
  //                                       setState(() {
  //                                         _docUrls.removeAt(0);
  //                                         Navigator.pop(context, false);
  //                                       });
  //                                   },
  //                                   child: Container(
  //                                     width: AppConfig.horizontalBlockSize * 21,
  //                                     child: Row(
  //                                       children: [
  //                                         Icon(
  //                                           Icons.delete,
  //                                           color: PlunesColors.WHITECOLOR,
  //                                         ),
  //                                         Text(
  //                                           "Delete",
  //                                           style: TextStyle(
  //                                               color: PlunesColors.WHITECOLOR,
  //                                               fontSize: 12),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           );
  //                         } else {
  //                           return Container();
  //                         }
  //                       },
  //                       initialData: RequestInProgress(),
  //                       future: _getDownloadedPdf(_docUrls?.first["url"] ?? ''),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  List<Widget> _showSelectedImages() {
    List<Widget> images = List<Widget>();
    for (int i = 0; i < _imageUrls.length; i++) {
      images.add(_getUploadedImage(i));
    }
    return images;
  }

  Widget _getUploadedImage(int index) {
    return Container(
      height: AppConfig.verticalBlockSize * 40,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3.38),
            height: AppConfig.verticalBlockSize * 27,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CustomWidgets().getImageFromUrl(
                  _imageUrls[index]["url"] ?? '',
                  boxFit: BoxFit.fill),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 3.38,
                top: AppConfig.verticalBlockSize * 1),
            alignment: Alignment.centerLeft,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: PlunesColors.WHITECOLOR),
              ),
              onPressed: () {
                if (mounted)
                  setState(() {
                    _imageUrls.removeAt(index);
                    Navigator.pop(context, false);
                    if (_imageUrls.isNotEmpty) {
                      _showImagesDialog();
                    }
                  });
              },
              child: Container(
                width: AppConfig.horizontalBlockSize * 21,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: PlunesColors.WHITECOLOR,
                    ),
                    Text(
                      "Delete",
                      style: TextStyle(
                          color: PlunesColors.WHITECOLOR, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3.38),
            child: Divider(
              color: PlunesColors.WHITECOLOR,
              thickness: 1.0,
            ),
          ),
        ],
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
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          _showEncryptionPopup(() {
            try {
              _imagePicker
                  .pickFile(context, fileType: FileType.any)
                  .then((value) {
                if (value != null &&
                    value.path != null &&
                    value.path.trim().isNotEmpty &&
                    value.path.contains(".")) {
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
              }).catchError((e) {
                // print(e);
              });
            } catch (e) {
              // print(e);
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
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          if ((_pageController == null ||
                              _pageController.page == null ||
                              _pageController.page.toInt() == 0)) {
                            return;
                          }
                          _removeFocus();
                          _pageController
                              .previousPage(
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
                                ? Color(
                                    CommonMethods.getColorHexFromStr("#767676"))
                                : PlunesColors.BLACKCOLOR,
                            borderColor: PlunesColors.SPARKLINGGREEN,
                            hasBorder: false),
                      ),
                      DotsIndicator(
                        dotsCount: _hasFormDataList() ? 3 : 2,
                        position: _pageController.page ?? 0,
                        decorator: DotsDecorator(
                            activeColor: PlunesColors.BLACKCOLOR,
                            color: PlunesColors.GREYCOLOR),
                      ),
                      InkWell(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onDoubleTap: () {},
                        onTap: () {
                          if (_hasFormDataList() && _pageController.page.toInt() == 2) {

                            _submitUserDetail();
                          } else if (!_hasFormDataList() && _pageController.page.toInt() == 1) {

                            _submitUserDetail();
                          } else {

                            _removeFocus();
                            _pageController
                                .nextPage(
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
                                : _hasFormDataList()
                                    ? (_pageController.page.toInt() == 1 ||
                                            _pageController.page.toInt() == 0)
                                        ? PlunesStrings.next
                                        : plunesStrings.submit
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
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
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
                          left: AppConfig.horizontalBlockSize * 10)),
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
            _hasTreatedPreviously
                ? Container(
                    width: double.infinity,
                    child: Text(
                      PlunesStrings.pleaseDescribePreviousCondition,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 18,
                          color: PlunesColors.BLACKCOLOR.withOpacity(0.8)),
                    ),
                  )
                : Container(),
            _hasTreatedPreviously
                ? Card(
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                            Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
                          ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
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
                              maxLength: 500,
                              style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration.collapsed(
                                  hintText: "Enter your condition",
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#979797")))),
                            ))
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
            Container(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.3),
              width: double.infinity,
              child: Text(
                PlunesStrings.isInsuranceCovered,
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
                    child: _isInsuranceCovered
                        ? InkWell(
                            child: _getSelectedButton(),
                            onDoubleTap: () {},
                            onTap: () {
                              _isInsuranceCovered = true;
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
                              _isInsuranceCovered = true;
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
                    child: _isInsuranceCovered
                        ? InkWell(
                            child: _getUnselectedButton(),
                            onDoubleTap: () {},
                            onTap: () {
                              _isInsuranceCovered = false;
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
                              _isInsuranceCovered = false;
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
              child: _getPremiumBenefitsForUserWidget(),
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 2.5,
                  bottom: AppConfig.verticalBlockSize * 1.5),
            )
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
    if (!_isNecessaryDataFilled()) {
      _pageController
          .animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut)
          .then((value) {
        _pageStream.add(null);
      });
      return;
    }
    List<Map<String, dynamic>> _formSubmissionList = [];
    Map<String, dynamic> formDataReq = Map();
    if (_hasFormDataList()) {
      if (_medicalSessionModel != null &&
          _medicalSessionModel.sessions != null &&
          _medicalSessionModel.sessions.isNotEmpty) {
        formDataReq[FormDataModel.sessionGraftKey] =
            _medicalSessionModel.selectedSession ??
                _medicalSessionModel.sessions.first;
        _formSubmissionList.add(formDataReq);
      } else {
        if (_formItemList != null && _formItemList.isNotEmpty) {
          for (int index = 0; index < _formItemList.length; index++) {
            if (_formItemList[index].isItemSeparated != null &&
                _formItemList[index].isItemSeparated) {
              Map<String, dynamic> _formDataReq = Map();
              _formDataReq[FormDataModel.bodyPartKey] =
                  _formItemList[index].bodyPartName;
              _formDataReq[FormDataModel.sessionGraftKey] =
                  _formItemList[index].sessionValue;
              _formSubmissionList.add(_formDataReq);
            }
          }
          if (_formSubmissionList == null || _formSubmissionList.isEmpty) {
            _showMessagePopup(
                "Please select ${_formItemList?.last?.firstKey ?? "body part"}");
            _pageController
                .animateToPage(1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut)
                .then((value) {
              _pageStream.add(null);
            });
            return;
          }
        }
      }
    }
    Map<String, dynamic> _postData = {
      "serviceId": widget.catalogueData?.serviceId,
      "reportUrls": _docUrls ?? [],
      "imageUrls": _imageUrls ?? [],
      "videoUrls":
          _videoUrls?.map((e) => e.toJson())?.toList(growable: true) ?? [],
      "treatedPreviously": _hasTreatedPreviously,
      "description": _hasTreatedPreviously
          ? _previousMedicalConditionController.text.trim()
          : null,
      "additionalDetails": _additionalDetailController.text.trim(),
      "insurance": _isInsuranceCovered,
      "serviceChildren": _formSubmissionList
    };
    // print("data $_postData");
    _submitUserMedicalDetailBloc.submitUserMedicalDetail(_postData);
  }

  bool isFromProfileScreenAndPriceAvailable() {
    return (widget.catalogueData != null &&
        widget.catalogueData.isFromProfileScreen != null &&
        widget.catalogueData.isFromProfileScreen &&
        widget.catalogueData.servicePrice != null &&
        widget.catalogueData.servicePrice > 0);
  }

  void _navigateToNextScreen(String reportId) {
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      widget.catalogueData.userReportId = reportId;
      if (isFromProfileScreenAndPriceAvailable()) {
        print("report id is iffffff -> $reportId");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SolutionShowPriceScreen(
                    searchQuery: widget.searchQuery,
                    catalogueData: widget.catalogueData)));
        return;
      }
      print("report id is elseelse -> $reportId");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ViewSolutionsScreen(
                    searchQuery: widget.searchQuery,
                    catalogueData: widget.catalogueData,
                    reportId: reportId,
                  )));
    });
  }

  Widget _getPremiumBenefitsForUserWidget() {
    if (_premiumBenefitsModel == null ||
        _premiumBenefitsModel.data == null ||
        _premiumBenefitsModel.data.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "Premium benefits for our users",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
        ),
        Container(
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => CommonWidgets()
                .getPremiumBenefitsWidget(_premiumBenefitsModel.data[index]),
            itemCount: _premiumBenefitsModel.data.length,
          ),
        ),
      ],
    );
  }

  _showEncryptionPopup(Function func) {
    if (UserManager().isEncryptionPopupShown()) {
      func();
      return;
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              CommonWidgets().getEncryptionPopup(scaffoldKey)).then((value) {
        UserManager().setEncryptionPopupStatus(true);
        func();
      });
    }
  }

  bool _isProcedure() {
    return (widget.catalogueData != null &&
        widget.catalogueData.category != null &&
        widget.catalogueData.category.isNotEmpty &&
        widget.catalogueData.category.trim().toLowerCase() ==
            Constants.procedureKey.toLowerCase());
  }

  bool _isNecessaryDataFilled() {
    bool hasAppropriateData = true;
    String errorMessage;
    if (widget.catalogueData != null &&
        widget.catalogueData.category != null &&
        widget.catalogueData.category.isNotEmpty &&
        widget.catalogueData.category.trim().toLowerCase() ==
            Constants.procedureKey.toLowerCase()) {
      if (_additionalDetailController.text.trim().isEmpty) {
        errorMessage = "Please fill additional detail for treatment";
        hasAppropriateData = false;
      }
      // else if ((_imageUrls == null || _imageUrls.isEmpty) &&
      //     (_docUrls == null || _docUrls.isEmpty)) {
      //   errorMessage = "Please upload your photos/report for treatment";
      //   hasAppropriateData = false;
      // }
    }
    // else {
    //   if (_additionalDetailController.text.trim().isEmpty) {
    //     errorMessage = "Please fill additional detail for treatment";
    //     hasAppropriateData = false;
    //   }
    // }
    if (!hasAppropriateData) {
      _showMessagePopup(errorMessage);
    }
    return hasAppropriateData;
  }

  Widget _getDropDownOfBodyParts() {
    return Container(
        margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          elevation: 2,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              constraints: BoxConstraints(
                  maxHeight: AppConfig.verticalBlockSize * 40,
                  minHeight: AppConfig.verticalBlockSize * 1),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  gradient: LinearGradient(colors: [
                    Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                    Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (context, index) {
                  if (index != 0 && !_isBodyPartListOpened) {
                    return Container();
                  } else if (_formItemList[index].isItemSeparated) {
                    return Container();
                  }
                  return InkWell(
                    onTap: () {
                      _isBodyPartListOpened = !_isBodyPartListOpened;
                      _setState();
                      if (index != 0) {
                        var medicalObj = _formItemList[index];
                        if (_formItemList
                            .contains(_medicalFormDataSelectionObj)) {
                          _formItemList.remove(_medicalFormDataSelectionObj);
                        }
                        _formItemList.remove(medicalObj);
                        _formItemList.insert(0, medicalObj);
                        // _formItemList[index].isItemSeparated = true;
                        _setState();
                      }
                    },
                    onDoubleTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                            child: Text(
                              _formItemList[index].bodyPartName ?? "",
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 16, color: PlunesColors.BLACKCOLOR),
                            ),
                          ),
                        ),
                        index == 0 &&
                                _formItemList.isNotEmpty &&
                                _formItemList.length > 1
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                child: Icon(Icons.arrow_drop_down))
                            : Container()
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: _formItemList.length,
              )),
        ));
  }

  Widget _getSessionDropDown() {
    return Container(
        margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          elevation: 2,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  gradient: LinearGradient(colors: [
                    Color(CommonMethods.getColorHexFromStr("#FEFEFE")),
                    Color(CommonMethods.getColorHexFromStr("#F6F6F6"))
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (context, index) {
                  if (!_formItemList.first.isSessionListOpened && index != 0) {
                    return Container();
                  }
                  return InkWell(
                    onTap: () {
                      _formItemList.first.isSessionListOpened =
                          !_formItemList.first.isSessionListOpened;
                      _setState();
                      if (_formItemList.first.sessionValues[index] ==
                          _enterManually) {
                        _openTextEditingPopup(_formItemList.first);
                        return;
                      }
                      _formItemList.first.sessionValue =
                          _formItemList.first.sessionValues[index] ?? "";
                      _setState();
                    },
                    onDoubleTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                            child: _formItemList.first.isSessionListOpened &&
                                    _formItemList.first.sessionValues[index] ==
                                        _enterManually
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Enter ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: PlunesColors.BLACKCOLOR),
                                        ),
                                      ),
                                      Icon(Icons.mode_edit, size: 18),
                                    ],
                                  )
                                : Text(
                                    _formItemList.first.isSessionListOpened
                                        ? _formItemList
                                                .first.sessionValues[index] ??
                                            ""
                                        : _formItemList.first.sessionValue ??
                                            _formItemList
                                                .first.sessionValues.first ??
                                            "",
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.BLACKCOLOR),
                                  ),
                          ),
                        ),
                        index == 0 &&
                                _formItemList.first.sessionValues.isNotEmpty &&
                                _formItemList.first.sessionValues.length > 1
                            ? InkWell(
                                onTap: () {
                                  _formItemList.first.isSessionListOpened =
                                      !_formItemList.first.isSessionListOpened;
                                  _setState();
                                },
                                onDoubleTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  child: Icon(Icons.arrow_drop_down),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: _formItemList.first.sessionValues.length,
              )),
        ));
  }

  final String _enterManually = "Enter manually";
  MedicalFormData _medicalFormDataSelectionObj = MedicalFormData(
      bodyPartName: "Select",
      sessionValues: [],
      valueController: TextEditingController(),
      isItemSeparated: false,
      firstKey: "Select",
      secondKey: "Select",
      isSessionListOpened: false);

  void _initFormData() {
    if (_formDataModel != null &&
        _formDataModel.data != null &&
        _formDataModel.data.children != null &&
        _formDataModel.data.children.isNotEmpty) {
      if (_formItemList == null || _formItemList.isEmpty) {
        _formItemList = [];
      }
      _formItemList.add(_medicalFormDataSelectionObj);
      _formDataModel.data.children.forEach((element) {
        List<String> _possibleValues = [];
        if (element.possibleValues != null &&
            element.possibleValues.isNotEmpty) {
          _possibleValues.addAll(element.possibleValues);
          _possibleValues.add(_enterManually);
        }
        String firstKey = "";
        String secondKey = '';
        if (_formDataModel.data != null &&
            _formDataModel.data.childrenKeys != null &&
            _formDataModel.data.childrenKeys.isNotEmpty) {
          firstKey = _formDataModel.data.childrenKeys.first;
          if (_formDataModel.data.childrenKeys.length > 1) {
            secondKey = _formDataModel.data.childrenKeys[1];
          }
        }
        _formItemList.add(MedicalFormData(
            bodyPartName: element.bodyPart ?? "",
            sessionValues: _possibleValues,
            valueController: TextEditingController(),
            isItemSeparated: false,
            firstKey: firstKey,
            secondKey: secondKey,
            isSessionListOpened: false));
      });
    } else if (_formDataModel != null &&
        _formDataModel.data != null &&
        _formDataModel.data.sessions != null &&
        _formDataModel.data.sessions.isNotEmpty) {
      _medicalSessionModel = MedicalSession(
          key: _formDataModel.data.sessionKey,
          isListOpened: false,
          sessions: _formDataModel?.data?.sessions ?? []);
    }
  }

  Widget _getAddButton() {
    if (_formItemList.length == 1) {
      return Container(
        margin:
            EdgeInsets.only(left: 10, top: AppConfig.verticalBlockSize * 4.85),
        child: InkWell(
          child: Icon(Icons.close),
          onDoubleTap: () {},
          onTap: () {
            _formItemList.first.isItemSeparated = false;
            _formItemList.insert(0, _medicalFormDataSelectionObj);
            _isBodyPartListOpened = false;
            _setState();
          },
        ),
      );
    }
    bool shouldShowButton = false;
    // _formItemList.forEach((element) {
    if (_formItemList != null &&
        _formItemList.isNotEmpty &&
        !(_formItemList.first == _medicalFormDataSelectionObj)) {
      shouldShowButton = true;
    }
    // });
    return Container(
      margin:
          EdgeInsets.only(left: 10, top: AppConfig.verticalBlockSize * 4.85),
      child: InkWell(
        onDoubleTap: () {},
        onTap: () {
          if (!shouldShowButton) {
            return;
          }
          _formItemList.first.isItemSeparated = true;
          _formItemList.insert(0, _medicalFormDataSelectionObj);
          _setState();
        },
        child: CustomWidgets().getRoundedButton(
            "Add",
            6,
            shouldShowButton
                ? PlunesColors.PARROTGREEN
                : PlunesColors.GREYCOLOR,
            8,
            8,
            PlunesColors.WHITECOLOR),
      ),
    );
  }

  Widget _getSeparatorLine() {
    if (_formItemList.length == 1) {
      return Container(
          margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1));
    }
    bool shouldShowButton = false;
    _formItemList.forEach((element) {
      if (element.isItemSeparated && element != _formItemList.first) {
        shouldShowButton = true;
      }
    });
    if (!shouldShowButton) {
      return Container(
          margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1));
    }
    return Container(
      margin: EdgeInsets.only(
          top: AppConfig.verticalBlockSize * 1 + 10, bottom: 10),
      width: double.infinity,
      height: 0.8,
      color: PlunesColors.GREYCOLOR,
    );
  }

  _getFormData() {
    _failedMessage = null;
    _submitUserMedicalDetailBloc.fetchUserMedicalDetail(widget.catalogueData);
  }

  _openTextEditingPopup(MedicalFormData medicalFormData) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            child: Container(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2.5,
                      horizontal: AppConfig.horizontalBlockSize * 1.4),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Enter number of ${medicalFormData?.secondKey ?? "session"}",
                          style: TextStyle(
                              fontSize: 18, color: PlunesColors.BLACKCOLOR),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 8),
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#B3B3B38A")),
                                width: 1)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: medicalFormData.valueController,
                                autofocus: true,
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontSize: 15),
                                inputFormatters: [
                                  // FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration.collapsed(
                                    hintText: "Enter Number"),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (medicalFormData.valueController != null &&
                                    medicalFormData.valueController.text
                                            .trim() !=
                                        null &&
                                    medicalFormData.valueController.text
                                        .trim()
                                        .isNotEmpty) {
                                  medicalFormData.sessionValue = medicalFormData
                                      .valueController.text
                                      .trim();
                                  Navigator.maybePop(context).then((value) {
                                    _setState();
                                  });
                                } else {
                                  _showMessagePopup(
                                      "Please enter valid session");
                                  return;
                                }
                              },
                              onDoubleTap: () {},
                              child: CustomWidgets().getRoundedButton(
                                  "OK",
                                  6,
                                  PlunesColors.SPARKLINGGREEN,
                                  8,
                                  8,
                                  PlunesColors.WHITECOLOR),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }).then((value) {
      medicalFormData.valueController.clear();
    });
  }

  Widget _getMedicalSessionWidget() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 4.2,
          vertical: AppConfig.verticalBlockSize * 2.5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _getSelectSessionWidget(),
            _getPremiumBenefitsForUserWidget()
          ],
        ),
      ),
    );
  }

  Widget _getSelectSessionWidget() {
    return Row(
      children: [
        Expanded(
            child: Container(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "${_medicalSessionModel?.key ?? "Session"}",
                  style:
                      TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Color(CommonMethods.getColorHexFromStr(
                                        "#FEFEFE")),
                                    Color(CommonMethods.getColorHexFromStr(
                                        "#F6F6F6"))
                                  ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)),
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                itemBuilder: (context, index) {
                                  if (index != 0 &&
                                      !_medicalSessionModel.isListOpened) {
                                    return Container();
                                  }
                                  return InkWell(
                                    onTap: () {
                                      _medicalSessionModel.isListOpened =
                                          !_medicalSessionModel.isListOpened;
                                      _setState();
                                      // if (_formItemList[index]
                                      //         .sessionValues[innerIndex] ==
                                      //     _enterManually) {
                                      //   _openTextEditingPopup(_formItemList[index]);
                                      //   return;
                                      // }
                                      _medicalSessionModel.selectedSession =
                                          _medicalSessionModel
                                                  .sessions[index] ??
                                              "";
                                      _setState();
                                    },
                                    onDoubleTap: () {},
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: _medicalSessionModel
                                                        .isListOpened &&
                                                    _medicalSessionModel
                                                            .sessions[index] ==
                                                        _enterManually
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "Enter",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: PlunesColors
                                                                  .BLACKCOLOR),
                                                        ),
                                                      ),
                                                      Icon(Icons.mode_edit,
                                                          size: 18),
                                                    ],
                                                  )
                                                : Text(
                                                    _medicalSessionModel
                                                            .isListOpened
                                                        ? _medicalSessionModel
                                                                    .sessions[
                                                                index] ??
                                                            ""
                                                        : _medicalSessionModel
                                                                .selectedSession ??
                                                            _medicalSessionModel
                                                                .sessions
                                                                .first ??
                                                            "",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: PlunesColors
                                                            .BLACKCOLOR),
                                                  ),
                                          ),
                                        ),
                                        index == 0 &&
                                                _medicalSessionModel
                                                        .sessions.length >
                                                    1
                                            ? InkWell(
                                                onTap: () {
                                                  _medicalSessionModel
                                                          .isListOpened =
                                                      !_medicalSessionModel
                                                          .isListOpened;
                                                  _setState();
                                                },
                                                onDoubleTap: () {},
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 1),
                                                  child: Icon(
                                                      Icons.arrow_drop_down),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  );
                                },
                                shrinkWrap: true,
                                itemCount: _medicalSessionModel.sessions.length,
                              )),
                        ),
                      ),
                      Expanded(child: Container())
                    ],
                  )),
            ],
          ),
        ))
      ],
    );
  }

  void _removeFocus() {
    if (mounted) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }
}

class MedicalFormData {
  String bodyPartName, sessionValue, firstKey, secondKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalFormData &&
          runtimeType == other.runtimeType &&
          bodyPartName == other.bodyPartName;

  @override
  int get hashCode => bodyPartName.hashCode;
  TextEditingController valueController;
  List<String> sessionValues;
  bool isItemSeparated, isSessionListOpened;

  MedicalFormData(
      {this.bodyPartName,
      this.sessionValue,
      this.sessionValues,
      this.valueController,
      this.isItemSeparated,
      this.isSessionListOpened,
      this.firstKey,
      this.secondKey});
}

class MedicalSession {
  String key, selectedSession;
  List<String> sessions;
  bool isListOpened;

  MedicalSession(
      {this.sessions, this.key, this.selectedSession, this.isListOpened});
}
