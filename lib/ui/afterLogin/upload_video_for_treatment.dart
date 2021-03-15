import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/new_solution_blocs/user_medical_detail_bloc.dart';
import 'package:plunes/models/new_solution_model/medical_file_upload_response_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class UploadVideoForTreatment extends BaseActivity {
  SubmitUserMedicalDetailBloc submitUserMedicalDetailBloc;

  UploadVideoForTreatment({this.submitUserMedicalDetailBloc});

  @override
  _UploadVideoForTreatmentState createState() =>
      _UploadVideoForTreatmentState();
}

class _UploadVideoForTreatmentState extends BaseState<UploadVideoForTreatment>
    with TickerProviderStateMixin, ImagePickerListener {
  AnimationController _animationController;
  ImagePickerHandler _imagePicker;
  List<UploadedReportUrl> _videoUrls;

  @override
  void initState() {
    _videoUrls = [];
    _initializeForImageFetching();
    super.initState();
  }

  _initializeForImageFetching() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _imagePicker = ImagePickerHandler(this, _animationController, true);
    _imagePicker.init();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _showMessagePopup(String message, {bool shouldPop = false}) {
    if (mounted) {
      showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets()
                .getInformativePopup(globalKey: scaffoldKey, message: message);
          }).then((value) {
        if (shouldPop) {
          if (mounted) {
            Navigator.pop(context, _videoUrls);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: StreamBuilder<RequestState>(
            stream: widget?.submitUserMedicalDetailBloc?.uploadFileStream,
            builder: (context, snapshot) {
              if (snapshot.data is RequestInProgress) {
                RequestInProgress requestInProgress = snapshot.data;
                print("hello ${requestInProgress?.data?.toString()}");
                double progressValue = 0.0;
                if (requestInProgress != null &&
                    requestInProgress.data != null) {
                  progressValue = double.tryParse(
                    requestInProgress?.data?.toString() ?? "0",
                  );
                }
                return Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          minHeight: 22,
                          value: progressValue / 100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              PlunesColors.GREENCOLOR),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        child: Text(
                          "${progressValue?.toStringAsFixed(1)} % Uploaded",
                          style: TextStyle(
                              color: PlunesColors.GREENCOLOR,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                      )
                    ],
                  ),
                );
              } else if (snapshot.data is RequestSuccess) {
                Future.delayed(Duration(milliseconds: 10)).then((value) {
                  _showMessagePopup(PlunesStrings.uplaodSuccessMessage,
                      shouldPop: true);
                });
                RequestSuccess data = snapshot.data;
                if (data.additionalData != null &&
                    data.additionalData.toString() == Constants.typeVideo) {
                  _setImageUrls(data.response);
                }
                widget?.submitUserMedicalDetailBloc
                    ?.addIntoSubmitFileStream(null);
              } else if (snapshot.data is RequestFailed) {
                RequestFailed _reqFailObj = snapshot.data;
                Future.delayed(Duration(milliseconds: 10)).then((value) {
                  _showMessagePopup(_reqFailObj?.failureCause);
                });
                widget?.submitUserMedicalDetailBloc
                    ?.addIntoSubmitFileStream(null);
              }
              return WillPopScope(
                onWillPop: () async {
                  Navigator.pop(context, _videoUrls);
                  return true;
                },
                child: Scaffold(
                  appBar: getAppBar(context, "Upload Video", true),
                  key: scaffoldKey,
                  body: Builder(
                    builder: (context) {
                      return _getBody();
                    },
                  ),
                ),
              );
            }),
        bottom: false,
        top: false,
      ),
    );
  }

  Widget getAppBar(BuildContext context, String title, bool isIosBackButton,
      {Function func}) {
    return AppBar(
        automaticallyImplyLeading: isIosBackButton,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        leading: isIosBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  if (func != null) {
                    func();
                  }
                  Navigator.pop(context, _videoUrls);
                  return;
                },
              )
            : Container(),
        title: widget.createTextViews(
            title, 18, colorsFile.black, TextAlign.center, FontWeight.w500));
  }

  _uploadVideo(File _image) {
    widget.submitUserMedicalDetailBloc.uploadFile(_image,
        fileType: Constants.typeVideo, shouldShowUploadProgress: true);
  }

  @override
  fetchImageCallBack(File video) {
    if (video != null) {
      _uploadVideo(video);
    } else {
      if (mounted && widget.submitUserMedicalDetailBloc != null) {
        widget.submitUserMedicalDetailBloc.addIntoSubmitFileStream(null);
      }
    }
    // print("_image ${video?.path}");
  }

  Widget _getBody() {
    return InkWell(
      onTap: () {
        _imagePicker?.showDialog(context);
        return;
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
          alignment: Alignment.center,
          margin: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 4,
              right: AppConfig.horizontalBlockSize * 4,
              top: AppConfig.verticalBlockSize * 3,
              bottom: AppConfig.verticalBlockSize * 1.5),
          child:
              Image.asset(PlunesImages.videoUploadIcon, height: 49, width: 49),
        ),
      ),
    );
  }

  void _setImageUrls(var response) {
    MedicalFileResponseModel _medicalFileResponseModel = response;
    if (_videoUrls == null) {
      _videoUrls = [];
    }
    if (_medicalFileResponseModel.data != null &&
        _medicalFileResponseModel.data.reports != null &&
        _medicalFileResponseModel.data.reports.isNotEmpty) {
      _videoUrls.add(_medicalFileResponseModel.data.reports.first);
    }
  }
}
