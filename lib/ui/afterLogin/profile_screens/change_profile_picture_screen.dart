import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';

// ignore: must_be_immutable
class ChangeProfileScreen extends BaseActivity {
  @override
  _ChangeProfileScreenState createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends BaseState<ChangeProfileScreen>
    with TickerProviderStateMixin, ImagePickerListener {
  User _user;
  AnimationController _animationController;
  ImagePickerHandler imagePicker;
  UserBloc _userBloc;

  @override
  void initState() {
    _userBloc = UserBloc();
    _user = UserManager().getUserDetails();
    _initializeForImageFetching();
    super.initState();
  }

  _initializeForImageFetching() {
    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {});
    imagePicker = new ImagePickerHandler(this, _animationController, false);
    imagePicker.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: widget.getAppBar(context, "Edit Profile", true),
        body: Builder(builder: (context) {
          return StreamBuilder<RequestState>(
              stream: _userBloc.profileStream,
              builder: (context, snapshot) {
                if (snapshot.data is RequestInProgress) {
                  return Center(child: CustomWidgets().getProgressIndicator());
                } else if (snapshot.data is RequestSuccess) {
                  _user = UserManager().getUserDetails();
                }
                return Container(
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                              child: GridPhotoViewer(
                            photo: Photo(
                                assetName: _user.imageUrl ??
                                    PlunesImages.userProfileIcon),
                          )),
                        ],
                      ),
                      Positioned(
                          left: 0.0,
                          right: 0.0,
                          bottom: AppConfig.verticalBlockSize * 10,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 32),
                            child: InkWell(
                              onTap: () {
                                imagePicker.showDialog(context);
                                return;
                              },
                              child: CustomWidgets().getRoundedButton(
                                  "Edit Profile Pic",
                                  AppConfig.horizontalBlockSize * 6,
                                  PlunesColors.GREENCOLOR,
                                  AppConfig.horizontalBlockSize * 3.2,
                                  AppConfig.verticalBlockSize * 1,
                                  PlunesColors.WHITECOLOR),
                            ),
                          )),
                    ],
                  ),
                );
              });
        }),
      ),
      top: true,
      bottom: true,
    );
  }

  @override
  fetchImageCallBack(File file) {
    if (file != null) {
      _userBloc.uploadPicture(file).then((value) async {
        await Future.delayed(Duration(milliseconds: 30));
        if (value is RequestSuccess) {
          _showMessage("Profile picture updated successfully", shouldPop: true);
        } else if (value is RequestFailed) {
          _showMessage(value?.failureCause);
        }
      });
    }
  }

  void _showMessage(String message, {bool shouldPop = false}) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets()
              .getInformativePopup(globalKey: scaffoldKey, message: message);
        }).then((value) {
      if (shouldPop) {
        Navigator.pop(context, shouldPop);
      }
    });
  }
}
