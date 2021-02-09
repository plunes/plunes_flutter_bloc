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
  List<Map<String, dynamic>> _videoUrls;

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
                return CustomWidgets().getProgressIndicator();
              } else if (snapshot.data is RequestSuccess) {
                Future.delayed(Duration(milliseconds: 10)).then((value) {
                  _showMessagePopup(PlunesStrings.uplaodSuccessMessage,
                      shouldPop: false);
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
                  appBar: widget.getAppBar(context, "Upload Video", true),
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

  _uploadVideo(File _image) {
    widget.submitUserMedicalDetailBloc
        .uploadFile(_image, fileType: Constants.typeVideo);
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
      _videoUrls.add(_medicalFileResponseModel.data.reports.first.toJson());
    }
  }
}
