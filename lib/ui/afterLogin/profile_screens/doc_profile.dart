import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/achievement_review.dart';

import '../../../OpenMap.dart';

// ignore: must_be_immutable
class DocProfile extends BaseActivity {
  final String userId;
  final String rating;

  DocProfile({this.userId, this.rating});

  @override
  _DocProfileState createState() => _DocProfileState();
}

class _DocProfileState extends BaseState<DocProfile> {
  UserBloc _userBloc;
  LoginPost _profileResponse;
  String _failureCause;
  BuildContext _context;

  @override
  void initState() {
    _userBloc = UserBloc();
    _getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.getAppBar(context, plunesStrings.profile, true),
      body: Builder(builder: (context) {
        _context = context;
        return StreamBuilder<RequestState>(
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
                ? CustomWidgets().errorWidget(
                    _failureCause ?? "Unable to get profile",
                    onTap: () => _getUserDetails(),
                    isSizeLess: true)
                : _getBodyView();
          },
          initialData: _profileResponse == null ? RequestInProgress() : null,
        );
      }),
    );
  }

  Widget _getBodyView() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Stack(fit: StackFit.loose, overflow: Overflow.visible, children: <
              Widget>[
            InkWell(
              onTap: () {
                List<Photo> photos = [];
                if ((_profileResponse.user != null &&
                    _profileResponse.user.coverImageUrl != null &&
                    _profileResponse.user.coverImageUrl.isNotEmpty)) {
                  photos.add(
                      Photo(assetName: _profileResponse.user.coverImageUrl));
                }
                if (photos != null && photos.isNotEmpty) {
                  Navigator.push(
                      _context,
                      MaterialPageRoute(
                          builder: (context) => PageSlider(photos, 0)));
                }
              },
              child: Container(
                color: PlunesColors.LIGHTESTGREYCOLOR.withOpacity(.5),
                height: AppConfig.verticalBlockSize * 22,
                width: double.infinity,
                child: (_profileResponse.user.coverImageUrl == null ||
                        _profileResponse.user.coverImageUrl.isEmpty ||
                        !(_profileResponse.user.coverImageUrl.contains("http")))
                    ? Container(
                        margin:
                            EdgeInsets.all(AppConfig.verticalBlockSize * 7.5),
                        // margin: EdgeInsets.symmetric(
                        //     vertical: AppConfig.verticalBlockSize * 5,
                        //     horizontal: AppConfig.horizontalBlockSize * 20),
                        child: Image.asset(
                          PlunesImages.defaultHosBac,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      )
                    : SizedBox.expand(
                        child: CustomWidgets().getImageFromUrl(
                            _profileResponse.user.coverImageUrl,
                            boxFit: BoxFit.cover),
                      ),
              ),
            ),
            Positioned(
              bottom: -AppConfig.verticalBlockSize * 5.5,
              right: 20,
              left: 20,
              child: InkWell(
                  onTap: () {
                    List<Photo> photos = [];
                    if ((_profileResponse.user != null &&
                        _profileResponse.user.imageUrl != null &&
                        _profileResponse.user.imageUrl.isNotEmpty)) {
                      photos.add(
                          Photo(assetName: _profileResponse.user.imageUrl));
                    }
                    if (photos != null && photos.isNotEmpty) {
                      Navigator.push(
                          _context,
                          MaterialPageRoute(
                              builder: (context) => PageSlider(photos, 0)));
                    }
                  },
                  child: (_profileResponse.user != null &&
                          _profileResponse.user.imageUrl != null &&
                          _profileResponse.user.imageUrl.isNotEmpty &&
                          _profileResponse.user.imageUrl.contains("http"))
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            height: 90,
                            width: 90,
                            child: ClipOval(
                                child: CustomWidgets().getImageFromUrl(
                                    _profileResponse.user.imageUrl,
                                    boxFit: BoxFit.fill,
                                    placeHolderPath:
                                        PlunesImages.hospitalImage)),
                          ),
                          radius: 45,
                        )
                      : CustomWidgets().getBackImageView(
                          _profileResponse.user?.name ?? _getEmptyString())),
            ),
          ]),
          Container(
            margin: EdgeInsets.symmetric(
                // vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 5),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 3,
                            top: AppConfig.verticalBlockSize * 7,
                          ),
                          child: _getNameView(),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.star,
                            color: PlunesColors.GREENCOLOR,
                            size: AppConfig.veryExtraLargeFont -
                                AppConfig.extraLargeFont),
                        Text(
                          _profileResponse.user?.rating?.toStringAsFixed(1) ??
                              PlunesStrings.NA,
                          style: TextStyle(
                              color: PlunesColors.GREYCOLOR,
                              fontSize: AppConfig.mediumFont),
                        ),
                      ],
                    ),
                  ],
                ),
                getLocationInfoView(24, 24, plunesImages.locationIcon,
                    plunesStrings.locationSep, _profileResponse.user?.address),
                InkWell(
                  onTap: () => _getDirections(),
                  onDoubleTap: () {},
                  child: Stack(
                      alignment: Alignment.bottomRight,
                      children: <Widget>[
                        (_profileResponse.user.latitude != null &&
                                _profileResponse.user.longitude != null)
                            ? Container(
                                height: AppConfig.verticalBlockSize * 20,
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        AppConfig.horizontalBlockSize * 3),
                                margin: EdgeInsets.only(left: 33),
                                child: Image.asset(
                                  PlunesImages.map,
                                  fit: BoxFit.fill,
                                ),
//                              Row(
//                                children: <Widget>[
//                                  Icon(
//                                    Icons.location_city,
//                                    color: PlunesColors.GREYCOLOR,
//                                  ),
//                                  SizedBox(
//                                    width: AppConfig.horizontalBlockSize * .5,
//                                  ),
//                                  Text(
//                                    PlunesStrings.viewOnMap,
//                                    textAlign: TextAlign.left,
//                                    style: TextStyle(
//                                        color: PlunesColors.GREENCOLOR,
//                                        fontSize: 14,
//                                        fontWeight: FontWeight.normal),
//                                  ),
//                                ],
//                              )
                              )
                            : Container(),
                        Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 8,
                              bottom: AppConfig.verticalBlockSize * 3,
                              right: AppConfig.horizontalBlockSize * 2.5),
                          child: Text(
                            "View on Map",
                            style: TextStyle(
                                color: PlunesColors.SPARKLINGGREEN,
                                fontWeight: FontWeight.w500,
                                fontSize: AppConfig.smallFont),
                          ),
                        )
                      ]),
                ),
                _getTimings(24, 24, PlunesImages.clock, PlunesStrings.timing),
                _getIntroductionView(
                  24,
                  24,
                  plunesImages.introduction,
                ),
                _getBottomView(),
                _getDocDetails(
                  24,
                  24,
                  PlunesImages.expert,
                  PlunesStrings.doctorDetails,
                ),
                _getRegistrationVerification(24, 24, PlunesImages.greenCheck,
                    PlunesStrings.medicalRegistrationVerified),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: PlunesColors.GREENCOLOR,
            child: InkWell(
              onTap: () {
                LauncherUtil.launchUrl("tel://7011311900");
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  PlunesStrings.forAnyQueries,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: PlunesColors.WHITECOLOR,
                      fontSize: AppConfig.mediumFont),
                ),
              ),
            ),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 1.5,
          ),
        ],
      ),
    );
  }

  String _getEmptyString() {
    return PlunesStrings.NA;
  }

  Widget _getNameView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  CommonMethods.getStringInCamelCase(
                          _profileResponse?.user?.name) ??
                      _getEmptyString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _profileResponse.user?.userType ?? _getEmptyString(),
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16, color: PlunesColors.BLACKCOLOR),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget getProfileInfoView(
      double height, double width, String icon, String title, String value) {
    if (value == null || value.isEmpty) {
      return Container();
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Container(
          //     width: width,
          //     height: height,
          //     child: widget.getAssetIconWidget(
          //         icon, height, width, BoxFit.contain)),
          Container(
              margin:
                  EdgeInsets.only(left: AppConfig.horizontalBlockSize * 9.5)),
          Expanded(
            child: RichText(
                maxLines: 3,
                text: TextSpan(
                    text: title ?? _getEmptyString(),
                    style: TextStyle(
                        color: PlunesColors.GREYCOLOR,
                        fontSize: AppConfig.smallFont + 2,
                        fontWeight: FontWeight.normal),
                    children: <InlineSpan>[
                      TextSpan(
                        text: ": ${value ?? _getEmptyString()}",
                        style: TextStyle(
                            fontSize: AppConfig.smallFont,
                            backgroundColor: Colors.transparent,
                            decoration: TextDecoration.none,
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.normal),
                      )
                    ])),
          ),
        ],
      ),
    );
  }

  Widget _getIntroductionView(double height, double width, String icon) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: width,
                  height: height,
                  child: widget.getAssetIconWidget(
                      icon, height, width, BoxFit.contain)),
              SizedBox(width: 10),
              Text(
                plunesStrings.introduction,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
//          Text(
//            plunesStrings.introduction,
//            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
//          ),
          Padding(
            padding: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 1,
                left: AppConfig.horizontalBlockSize * 8.5),
            child: Text(_profileResponse.user?.biography ?? _getEmptyString(),
                style: TextStyle(color: PlunesColors.GREYCOLOR, fontSize: 14)),
          ),
//          Container(
//            height: 0.5,
//            width: double.infinity,
//            color: PlunesColors.GREYCOLOR,
//            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
//          ),
        ],
      ),
    );
  }

  Widget _getBottomView() {
//      (_profileResponse.user == null ||
//            _profileResponse.user.achievements == null ||
//            _profileResponse.user.achievements.isEmpty)
//        ? Container()
//        :
    return AchievementAndReview(_profileResponse.user, _context, _userBloc);
  }

  void _getUserDetails() {
    _userBloc.getUserProfile(widget.userId);
  }

  Widget _getTimings(double height, double width, String icon, String title) {
    return (_profileResponse.user == null ||
            _profileResponse.user.timeSlots == null ||
            _profileResponse.user.timeSlots.isEmpty)
        ? Container()
        : Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: width,
                      height: height,
                      child: widget.getAssetIconWidget(
                          icon, height, width, BoxFit.contain)),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => CustomWidgets().hospitalTiming(
                          _profileResponse.user.timeSlots, context),
                      barrierDismissible: true);
                },
                child: Container(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return _getSlotInfo(
                          _profileResponse?.user?.timeSlots[index]);
                    },
                    itemCount: _profileResponse?.user?.timeSlots?.length ?? 0,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                  ),
                  width: double.infinity,
                  height: AppConfig.verticalBlockSize * 10,
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => CustomWidgets().hospitalTiming(
                          _profileResponse.user.timeSlots, context),
                      barrierDismissible: true);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "All Timings",
                    style: TextStyle(
                      color: PlunesColors.GREENCOLOR,
                      fontSize: 14,
                      decorationThickness: 2.0,
                    ),
                  ),
                ),
              )
            ],
          );
  }

  Widget _getSlotInfo(TimeSlotsData timeSlot) {
    return Container(
      margin: EdgeInsets.only(
          top: AppConfig.verticalBlockSize * 1,
          bottom: AppConfig.verticalBlockSize * 1,
          right: AppConfig.horizontalBlockSize * 3),
      decoration: BoxDecoration(
        border:
            Border.all(color: PlunesColors.GREYCOLOR, style: BorderStyle.solid),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: (timeSlot != null && timeSlot.closed != null && timeSlot.closed)
          ? Container(
              color: Colors.red.withOpacity(0.5),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.only(top: 3, bottom: 2, right: 2, left: 2),
                    child: Text(
                      timeSlot?.day?.toUpperCase() ?? _getEmptyString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.smallFont,
                          decorationThickness: 1.5,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
                  Text(
                    "Closed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: AppConfig.verySmallFont,
                        color: PlunesColors.WHITECOLOR),
                  ),
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.only(top: 3, bottom: 2, right: 2, left: 2),
                    child: Text(
                      timeSlot?.day?.toUpperCase() ?? _getEmptyString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.smallFont,
                          decorationThickness: 1.5,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
//                Container(
//                  margin:
//                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
//                  padding: EdgeInsets.all(2),
//                  child:
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      (timeSlot != null &&
                              timeSlot.slots != null &&
                              timeSlot.slots.isNotEmpty)
                          ? timeSlot.slots.first
                          : _getEmptyString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.verySmallFont,
                          color: PlunesColors.GREYCOLOR),
                    ),
                  ),
//                ),
                ],
              ),
            ),
    );
  }

  Widget _getRegistrationVerification(
      double height, double width, String icon, String title) {
    return Container(
//      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 0.5,
            width: double.infinity,
            color: PlunesColors.GREYCOLOR,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: width,
                    height: height,
                    child: widget.getAssetIconWidget(
                        icon, height, width, BoxFit.contain)),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      color: PlunesColors.BLACKCOLOR,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getLocationInfoView(
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
//          Padding(
//              padding:
//                  EdgeInsets.only(left: AppConfig.horizontalBlockSize * 1)),
          Expanded(
            child: RichText(
                textAlign: TextAlign.left,
                maxLines: 3,
                softWrap: true,
                text: TextSpan(
                    text: "${title ?? _getEmptyString()}:",
                    style: TextStyle(
                      color: PlunesColors.GREYCOLOR,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decorationThickness: 1.5,
                    ),
                    children: <InlineSpan>[
                      TextSpan(text: "  "),
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

  Widget _getDocDetails(
      double height, double width, String icon, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 0.5,
          width: double.infinity,
          color: PlunesColors.GREYCOLOR,
          margin:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: width,
                  height: height,
                  child: widget.getAssetIconWidget(
                      icon, height, width, BoxFit.contain)),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              getProfileInfoView(16, 16, plunesImages.emailIcon,
                  PlunesStrings.emailIdText, _profileResponse.user?.email),
              SizedBox(
                height: 8,
              ),
              getProfileInfoView(
                  16,
                  16,
                  plunesImages.expertiseIcon,
                  plunesStrings.areaExpertise,
                  _profileResponse.user?.speciality),
              SizedBox(
                height: 8,
              ),
              (_profileResponse.user == null ||
                      _profileResponse.user.experience == null ||
                      _profileResponse.user.experience == "0")
                  ? Container()
                  : getProfileInfoView(
                      16,
                      16,
                      plunesImages.clockIcon,
                      plunesStrings.expOfPractice,
                      _profileResponse.user.experience),
              SizedBox(
                height: 8,
              ),
              getProfileInfoView(16, 16, plunesImages.practisingIcon,
                  plunesStrings.practising, _profileResponse.user?.practising),
              SizedBox(
                height: 8,
              ),
              getProfileInfoView(
                  16,
                  16,
                  plunesImages.eduIcon,
                  plunesStrings.qualification,
                  _profileResponse.user?.qualification),
              SizedBox(
                height: 8,
              ),
              getProfileInfoView(16, 16, plunesImages.uniIcon,
                  plunesStrings.college, _profileResponse.user?.college),
            ],
          ),
        ),
      ],
    );
  }

  void _getDirections() {
    (_profileResponse.user?.latitude == null ||
            _profileResponse.user.latitude.isEmpty ||
            _profileResponse.user.latitude == null ||
            _profileResponse.user.latitude.isEmpty)
        ? widget.showInSnackBar(PlunesStrings.locationNotAvailable,
            PlunesColors.BLACKCOLOR, scaffoldKey)
        : LauncherUtil.openMap(double.tryParse(_profileResponse.user.latitude),
            double.tryParse(_profileResponse.user.longitude));
  }
}
