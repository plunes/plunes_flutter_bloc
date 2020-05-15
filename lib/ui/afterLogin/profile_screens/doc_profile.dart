import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/achievement_review.dart';

// ignore: must_be_immutable
class DocProfile extends BaseActivity {
  final String userId;

  DocProfile({this.userId});

  @override
  _DocProfileState createState() => _DocProfileState();
}

class _DocProfileState extends BaseState<DocProfile> {
  UserBloc _userBloc;
  LoginPost _profileResponse;
  String _failureCause;

  @override
  void initState() {
    _userBloc = UserBloc();
    _getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.getAppBar(context, plunesStrings.profile, true),
      body: Builder(builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
              vertical: AppConfig.verticalBlockSize * 2,
              horizontal: AppConfig.horizontalBlockSize * 6),
          child: StreamBuilder<RequestState>(
            stream: _userBloc.baseStream,
            builder: (context, snapshot) {
              if (snapshot.data is RequestInProgress) {
                return CustomWidgets().getProgressIndicator();
              } else if (snapshot.data is RequestSuccess) {
                RequestSuccess requestSuccess = snapshot.data;
                if (requestSuccess != null && requestSuccess.response != null) {
                  _profileResponse = requestSuccess.response;
                }
                _userBloc.addIntoStream(null);
              } else if (snapshot.data is RequestFailed) {
                RequestFailed requestFailed = snapshot.data;
                _failureCause = requestFailed.failureCause;
                _userBloc.addIntoStream(null);
              }
              return _profileResponse == null
                  ? CustomWidgets()
                      .errorWidget(_failureCause ?? "Unable to get profile")
                  : _getBodyView();
            },
            initialData: _profileResponse == null ? RequestInProgress() : null,
          ),
        );
      }),
    );
  }

  Widget _getBodyView() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _getNameAndImageView(),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 4),
            child: getProfileInfoView(24, 24, plunesImages.locationIcon,
                plunesStrings.locationSep, _profileResponse.user?.address),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            child: getProfileInfoView(22, 22, plunesImages.emailIcon,
                PlunesStrings.emailIdText, _profileResponse.user?.email),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            child: getProfileInfoView(22, 22, plunesImages.expertiseIcon,
                plunesStrings.areaExpertise, _profileResponse.user?.speciality),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            child: getProfileInfoView(22, 22, plunesImages.clockIcon,
                plunesStrings.expOfPractice, _profileResponse.user?.experience),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            child: getProfileInfoView(22, 22, plunesImages.practisingIcon,
                plunesStrings.practising, _profileResponse.user?.practising),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            child: getProfileInfoView(
                22,
                22,
                plunesImages.eduIcon,
                plunesStrings.qualification,
                _profileResponse.user?.qualification),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            child: getProfileInfoView(22, 22, plunesImages.uniIcon,
                plunesStrings.college, _profileResponse.user?.college),
          ),
          _getIntroductionView(),
          _getBottomView()
        ],
      ),
    );
  }

  String _getEmptyString() {
    return PlunesStrings.NA;
  }

  Widget _getNameAndImageView() {
    return Row(
      children: <Widget>[
        CustomWidgets()
            .getBackImageView(_profileResponse.user?.name ?? _getEmptyString()),
        Padding(
          padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _profileResponse.user?.name ?? _getEmptyString(),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                "Doctor" ?? _getEmptyString(),
                style: TextStyle(fontSize: 16),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget getProfileInfoView(
      double height, double width, String icon, String title, String value) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              width: width,
              height: height,
              child: widget.getAssetIconWidget(
                  icon, height, width, BoxFit.contain)),
          Padding(
              padding:
                  EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3)),
          Expanded(
            child: RichText(
                maxLines: 3,
                text: TextSpan(
                    text: "${title ?? _getEmptyString()}:",
                    style: TextStyle(
                        color: PlunesColors.GREYCOLOR,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    children: <InlineSpan>[
                      TextSpan(
                        text: value ?? _getEmptyString(),
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      )
                    ])),
          ),
        ],
      ),
    );
  }

  Widget _getIntroductionView() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 0.5,
            width: double.infinity,
            color: PlunesColors.GREYCOLOR,
            margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 3),
          ),
          Text(
            plunesStrings.introduction,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
            child: Text(_profileResponse.user?.biography ?? _getEmptyString()),
          ),
          Container(
            height: 0.5,
            width: double.infinity,
            color: PlunesColors.GREYCOLOR,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
          ),
        ],
      ),
    );
  }

  Widget _getBottomView() {
    return AchievementAndReview();
  }

  void _getUserDetails() {
    _userBloc.getUserProfile("5de421b96a2be815b9e220c6");
  }
}
