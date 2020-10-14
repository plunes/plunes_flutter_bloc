import 'dart:async';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/achievement_review.dart';
import 'package:readmore/readmore.dart';

// ignore: must_be_immutable
class HospitalProfile extends BaseActivity {
  final String userID;
  final String rating;

  HospitalProfile({this.userID, this.rating});

  @override
  _HospitalProfileState createState() => _HospitalProfileState();
}

class _HospitalProfileState extends BaseState<HospitalProfile> {
  DateTime _currentDate;
  bool _isServiceListOpened = false;
  UserBloc _userBloc;
  LoginPost _profileResponse;
  List<SpecialityModel> specialityList;
  String _specialitySelectedId;
  List<CatalogueData> _catalogueList;
  String _serviceFailureCause;
  BuildContext _context;
  String _failureCause;
  Services _services;

//  Completer<GoogleMapController> _googleMapController = Completer();
//  GoogleMapController _mapController;
//  Set<Marker> _markers = {};

  @override
  void initState() {
    _userBloc = UserBloc();
    _currentDate = DateTime.now();
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
                if (_profileResponse.user != null) {
                  Future.delayed(Duration(milliseconds: 10))
                      .then((value) => _getSpecialities());
                }
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
                    onTap: () => _getUserDetails())
                : _getBody();
          },
          initialData: _profileResponse == null ? RequestInProgress() : null,
        );
      }),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        color: PlunesColors.WHITECOLOR,
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
                          !(_profileResponse.user.coverImageUrl
                              .contains("http")))
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
                  horizontal: AppConfig.horizontalBlockSize * 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  getProfileInfoView(
                      24,
                      24,
                      plunesImages.locationIcon,
                      plunesStrings.locationSep,
                      _profileResponse.user?.address),
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
                  _getTeamOfExpertsWidget(
                    24,
                    24,
                    PlunesImages.expert,
                    plunesStrings.teamOfExperts,
                  ),
                  StreamBuilder<RequestState>(
                    builder: (context, snapshot) {
                      if (snapshot.data is RequestSuccess) {
                        RequestSuccess requestSuccess = snapshot.data;
                        specialityList = requestSuccess.response;
                        _userBloc.addStateInSpecialityStream(null);
                      }
                      if (specialityList != null && specialityList.isNotEmpty) {
                        return _getSpecializationWidget(
                            24,
                            24,
                            PlunesImages.specialization,
                            plunesStrings.specialization);
                      }
                      return Container();
                    },
                    stream: _userBloc.specialityStream,
                  ),
                  StreamBuilder<RequestState>(
                      stream: _userBloc.serviceStream,
                      builder: (context, snapshot) {
                        if (snapshot.data is RequestInProgress) {
                          return Container(
                              height: AppConfig.verticalBlockSize * 16,
                              width: double.infinity,
                              child: CustomWidgets().getProgressIndicator());
                        } else if (snapshot.data is RequestSuccess) {
                          RequestSuccess requestSuccess = snapshot.data;
                          _catalogueList = requestSuccess.response;
                          _userBloc.addStateInServiceStream(null);
                        } else if (snapshot.data is RequestFailed) {
                          RequestFailed _requestFailed = snapshot.data;
                          _serviceFailureCause = _requestFailed.failureCause;
                          _userBloc.addStateInServiceStream(null);
                        }
                        if (specialityList != null &&
                            specialityList.isNotEmpty &&
                            _catalogueList != null) {
                          return _catalogueList.isEmpty
                              ? Container(
                                  height: AppConfig.verticalBlockSize * 20,
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        PlunesImages.noServiceAvailable,
                                        height:
                                            AppConfig.verticalBlockSize * 6.5,
                                        width:
                                            AppConfig.horizontalBlockSize * 20,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: AppConfig.verticalBlockSize *
                                                1.5),
                                        child: Text(
                                          _serviceFailureCause ??
                                              PlunesStrings
                                                  .unableToLoadServices,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: PlunesColors.GREYCOLOR,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ))
                              : _getServiceList();
                        }
                        return Container();
                      }),
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
      ),
    );
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
                  _profileResponse.user?.userType?.toUpperCase() ??
                      _getEmptyString(),
                  style: TextStyle(fontSize: 16),
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
          Padding(
            padding: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 1,
                left: AppConfig.horizontalBlockSize * 8.5),
            child: ReadMoreText(
              _profileResponse.user?.biography ?? _getEmptyString(),
              colorClickableText: PlunesColors.SPARKLINGGREEN,
              trimLines: 10,
              trimMode: TrimMode.Line,
              trimCollapsedText: '  ...read more',
              trimExpandedText: '  read less',
              style: TextStyle(color: PlunesColors.GREYCOLOR, fontSize: 14),
            ),
          ),
        ],
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

  _getEmptyString() {
    return PlunesStrings.NA;
  }

  Widget _getSpecializationWidget(
      double height, double width, String icon, String title) {
    if (specialityList == null || specialityList.isEmpty) {
      return Container();
    }
    List<DropdownMenuItem<String>> itemList = [];
    specialityList.toSet().forEach((item) {
      if (item != null && item.id != null && item.id.isNotEmpty) {
        if (_specialitySelectedId == null) {
          _specialitySelectedId = item.id;
          _getServiceRelatedToSpeciality(_specialitySelectedId);
        }
        itemList.add(DropdownMenuItem(
            value: item.id,
            child: Text(
              CommonMethods.getStringInCamelCase(item?.speciality) ??
                  _getEmptyString(),
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            )));
      }
    });
    Widget dropDown;
    if (itemList != null && itemList.isNotEmpty) {
      dropDown = DropdownButton<String>(
        isDense: true,
        onChanged: (itemId) {
          _specialitySelectedId = itemId;
          _userBloc.addStateInSpecialityStream(null);
          _getServiceRelatedToSpeciality(_specialitySelectedId);
        },
        value: _specialitySelectedId,
        items: itemList,
        isExpanded: true,
        elevation: 0,
      );
    }
    return itemList == null || itemList.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 0.5,
                width: double.infinity,
                color: PlunesColors.GREYCOLOR,
                margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 1.8),
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
//                Text(
//                  plunesStrings.specialization,
//                  style: TextStyle(
//                      color: PlunesColors.BLACKCOLOR,
//                      fontSize: 16,
//                      fontWeight: FontWeight.w500),
//                ),
              ),
              Container(
                padding: EdgeInsets.only(
//                    horizontal: AppConfig.horizontalBlockSize * 5,
                  top: AppConfig.verticalBlockSize * 2,
                  bottom: AppConfig.verticalBlockSize * 1,
                ),
                child: DropdownButtonHideUnderline(child: dropDown),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.5,
                      style: BorderStyle.solid,
                      color: PlunesColors.GREYCOLOR,
                    ),
                  ),
                ),
//                ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
              ),
            ],
          );
  }

  void _getUserDetails() {
    _userBloc.getUserProfile(widget.userID);
  }

  Widget _getTeamOfExpertsWidget(
      double height, double width, String icon, String title) {
    return (_profileResponse.user.doctorsData == null ||
            _profileResponse.user.doctorsData.isEmpty)
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 0.5,
                width: double.infinity,
                color: PlunesColors.GREYCOLOR,
                margin: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 2),
              ),
//              Container(
//                padding:
//                    EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Text(
//                      plunesStrings.teamOfExperts,
//                      style: TextStyle(
//                          color: PlunesColors.BLACKCOLOR,
//                          fontSize: 16,
//                          fontWeight: FontWeight.w500),
//                    ),
//                    _profileResponse.user.doctorsData.length > 3
//                        ? Text(
//                            'See more >>',
//                            style: TextStyle(
//                                color: PlunesColors.GREYCOLOR,
//                                fontSize: 12,
//                                fontWeight: FontWeight.normal),
//                          )
//                        : Container(),
//                  ],
//                ),
//              ),
              Padding(
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
                      plunesStrings.teamOfExperts,
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 1.5),
                height: AppConfig.verticalBlockSize * 20,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
//                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                      crossAxisCount: 2,
//                      crossAxisSpacing: 4.0,
//                      childAspectRatio: 0.8,
//                    ),
                    itemCount: _profileResponse.user.doctorsData.length
//                        > 2
//                        ? _profileResponse.user.doctorsData.length
//                        : 2
                    ,
                    itemBuilder: (context, itemIndex) {
                      return InkWell(
                        splashColor: PlunesColors.GREENCOLOR.withOpacity(0.5),
                        onTap: () => _openDocDetails(
                            _profileResponse.user.doctorsData[itemIndex]),
                        child: Container(
                          width: AppConfig.horizontalBlockSize * 28.2,
                          decoration: ShapeDecoration(
//                            color: PlunesColors.GREYCOLOR,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  color:
                                      PlunesColors.BLACKCOLOR.withOpacity(.2)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                            ),
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal: AppConfig.horizontalBlockSize * 1),
                          padding: EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Container(
//                                  color:
//                                      PlunesColors.GREENCOLOR.withOpacity(0.5),
                                  child: (_profileResponse
                                                  .user
                                                  .doctorsData[itemIndex]
                                                  .imageUrl ==
                                              null ||
                                          _profileResponse
                                              .user
                                              .doctorsData[itemIndex]
                                              .imageUrl
                                              .isEmpty ||
                                          !(_profileResponse.user
                                              .doctorsData[itemIndex].imageUrl
                                              .contains("http")))
                                      ? CustomWidgets().getBackImageView(
                                          _profileResponse
                                                  .user
                                                  .doctorsData[itemIndex]
                                                  .name ??
                                              _getEmptyString(),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: Container(
                                              margin: EdgeInsets.all(1.5),
                                              height: 60,
                                              width: 60,
                                              child: ClipOval(
                                                  child: CustomWidgets()
                                                      .getImageFromUrl(
                                                          _profileResponse
                                                              .user
                                                              .doctorsData[
                                                                  itemIndex]
                                                              .imageUrl,
                                                          boxFit: BoxFit.fill,
                                                          placeHolderPath:
                                                              PlunesImages
                                                                  .doc_placeholder)),
                                            ),
                                          ),
                                          radius: 50,
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
//                                  Row(
//                                    mainAxisAlignment:
//                                        MainAxisAlignment.spaceBetween,
//                                    crossAxisAlignment: CrossAxisAlignment.center,
//                                    children: <Widget>[
//                                  Container(
//                                    width: AppConfig.horizontalBlockSize * 26,
////                                      margin: EdgeInsets.only(
////                                          top: AppConfig.verticalBlockSize * 1),
//                                    padding: EdgeInsets.symmetric(
//                                        horizontal:
//                                            AppConfig.horizontalBlockSize *
//                                                0.8),
//                                    child:
                                    Text(
                                      CommonMethods.getStringInCamelCase(
                                              _profileResponse
                                                  .user
                                                  ?.doctorsData[itemIndex]
                                                  ?.name) ??
                                          _getEmptyString(),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontWeight: FontWeight.w500,
                                          fontSize: AppConfig.verySmallFont),
                                    ),
//                                  ),
//                                    Image.asset(PlunesImages.menuicon,
//                                        height: 9, width: 9),
//                                    ],
//                                  ),
//                                  Container(
//                                    width: AppConfig.horizontalBlockSize * 26,
//                                    padding: EdgeInsets.symmetric(
//                                        horizontal:
//                                            AppConfig.horizontalBlockSize *
//                                                0.8),
//                                    child:
                                    Text(
                                      _profileResponse
                                              .user
                                              ?.doctorsData[itemIndex]
                                              .designation ??
                                          _getEmptyString(),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR
                                              .withOpacity(0.5),
                                          fontSize: 11),
                                    ),
//                                  ),
//                                  Container(
//                                    width: AppConfig.horizontalBlockSize * 26,
//                                    padding: EdgeInsets.symmetric(
//                                        horizontal:
//                                            AppConfig.horizontalBlockSize *
//                                                0.8),
//                                    child:
                                    Text(
                                      _getExpr(itemIndex) ?? _getEmptyString(),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR
                                              .withOpacity(0.5),
                                          fontSize: 11),
                                    ),
//                                  ),
                                  ],
                                ),
                              ),
//                              Padding(
//                                padding:
//                                    const EdgeInsets.symmetric(horizontal: 14),
//                                child: Container(
//                                  margin: EdgeInsets.only(
//                                      right: AppConfig.verticalBlockSize * 1),
//                                  height: 50,
//                                  color: PlunesColors.GREYCOLOR,
//                                  width: 0.5,
//                                ),
//                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              (_profileResponse.user.doctorsData != null &&
                      _profileResponse.user.doctorsData.isNotEmpty &&
                      _profileResponse.user.doctorsData.length > 2)
                  ? InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => CustomWidgets()
                                .showDoctorList(
                                    _profileResponse.user.doctorsData,
                                    context,
                                    _profileResponse?.user?.name),
                            barrierDismissible: true);
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 5),
                        alignment: Alignment.center,
                        child: Text(
                          PlunesStrings.view_More,
                          style: TextStyle(
                            color: PlunesColors.GREENCOLOR,
                            fontSize: 14,
                            decorationThickness: 2.0,
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          );
  }

  Widget _getBottomView() {
    return AchievementAndReview(_profileResponse.user, _context, _userBloc);
  }

//  _showMapview() {
//    return (_profileResponse.user?.latitude == null ||
//            _profileResponse.user.latitude.isEmpty ||
//            _profileResponse.user.latitude == null ||
//            _profileResponse.user.latitude.isEmpty)
//        ? widget.showInSnackBar(PlunesStrings.locationNotAvailable,
//            PlunesColors.BLACKCOLOR, scaffoldKey)
//        : Stack(children: <Widget>[
//            Positioned(
//              left: 0,
//              right: 0,
//              bottom: 0,
//              top: 0,
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: <Widget>[
//                  Flexible(
//                    child: GoogleMap(
//                      onMapCreated: (mapController) {
//                        if (_googleMapController != null &&
//                            _googleMapController.isCompleted) {
//                          return;
//                        }
//                        _mapController = mapController;
//                        _googleMapController.complete(_mapController);
//                      },
//                      markers: _markers,
//                      // _hasAnimated ? _markers : _bigMarkers,
//                      initialCameraPosition: CameraPosition(
//                          target: LatLng(
//                              double.parse(_profileResponse.user.latitude),
//                              double.parse(_profileResponse.user.longitude)),
//                          zoom: 10),
//
//                      padding: EdgeInsets.all(0.0),
////                      myLocationEnabled: false,
////                      zoomControlsEnabled: false,
////                      zoomGesturesEnabled: false,
////                      myLocationButtonEnabled: false,
////                      buildingsEnabled: false,
////                      trafficEnabled: false,
////                      indoorViewEnabled: false,
//                      mapType: MapType.terrain,
//                    ),
//                  ),
//                ],
//              ),
//            ),
//            Positioned(
//              left: 0,
//              right: 0,
//              bottom: 0,
//              top: 0,
//              child: IgnorePointer(
//                child: Container(color: Colors.black12),
//                ignoring: true,
//
//              ),
//            ),
//          ]);
//  }

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

  String _getExpr(int itemIndex) {
    return _profileResponse.user.doctorsData[itemIndex].experience == null ||
            _profileResponse.user.doctorsData[itemIndex].experience == "0"
        ? null
        : "Expr ${_profileResponse.user.doctorsData[itemIndex].experience} years";
  }

  Widget _getServiceList() {
    return Container(
      margin: EdgeInsets.only(bottom: 5, left: 1, right: 1),
//      decoration: BoxDecoration(
//        color: PlunesColors.GREYCOLOR.withOpacity(.2),
//        borderRadius: BorderRadius.only(
//          bottomLeft: Radius.circular(25),
//          bottomRight: Radius.circular(25),
//        ),
//      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 2,
                bottom: AppConfig.verticalBlockSize * 0.2),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                PlunesStrings.serviceList,
                style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
//            decoration: BoxDecoration(
//              border: Border(
//                top: BorderSide(
//                  width: 1,
//                  style: BorderStyle.solid,
//                  color: PlunesColors.GREYCOLOR.withOpacity(.5),
//                ),
//                bottom: _isServiceListOpened
//                    ? BorderSide(
//                        width: 1,
//                        style: BorderStyle.solid,
//                        color: PlunesColors.GREYCOLOR.withOpacity(.5),
//                      )
//                    : BorderSide(
//                        width: 0,
//                        style: BorderStyle.none,
//                      ),
//              ),
//            ),
            height: _isServiceListOpened
                ? _catalogueList.length <= 8
                    ? AppConfig.verticalBlockSize * 32
                    : AppConfig.verticalBlockSize * 45
                : AppConfig.verticalBlockSize * 16,
            width: double.infinity,
            child: ListView.builder(
              physics: _isServiceListOpened
                  ? AlwaysScrollableScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => CustomWidgets()
                          .buildViewMoreDialog(
                              catalogueData: _catalogueList[index]),
                    );
                  },
                  onDoubleTap: () {},
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 0.8),
                            child: Text(
                              CommonMethods.getStringInCamelCase(
                                      _catalogueList[index]?.service) ??
                                  _getEmptyString(),
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      PlunesColors.BLACKCOLOR.withOpacity(0.7)),
                            ),
                          ),
                          flex: 5,
                        ),
                        Icon(
                          Icons.navigate_next,
                          color: PlunesColors.BLACKCOLOR.withOpacity(0.7),
                        )

//                    Expanded(
//                      child: Text(
//                        PlunesStrings.knowMore,
//                        style: TextStyle(
//                            fontSize: 16,
//                            color: Colors.grey[400],
//                            fontWeight: FontWeight.bold),
//                        textAlign: TextAlign.end,
//                      ),
//                      flex: 1,
//                    )
                      ],
                    ),
                  ),
                );
              },
              itemCount: _isServiceListOpened
                  ? _catalogueList?.length
                  : _catalogueList.length < 4 ? _catalogueList?.length : 4,
            ),
          ),
          (_catalogueList != null && _catalogueList.length <= 3)
              ? Container()
              : InkWell(
                  onTap: () {
                    setState(() {
                      _isServiceListOpened = !_isServiceListOpened;
                    });
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
                    padding: EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _isServiceListOpened
                              ? "See less Services"
                              : "See more Services",
                          style: TextStyle(
                              color: PlunesColors.GREENCOLOR, fontSize: 14),
                        ),
                        Icon(
                          _isServiceListOpened
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: PlunesColors.GREENCOLOR,
                        )
                      ],
                    ),
                  ),
                ),
          (_profileResponse.user.doctorsData == null ||
                  _profileResponse.user.doctorsData.isEmpty)
              ? Container()
              : Container(
//                  height: 0.5,
//                  width: double.infinity,
//                  color: PlunesColors.GREYCOLOR,
//                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                  ),
        ],
      ),
    );
  }

  void _getSpecialities() {
    _userBloc.getUserSpecificSpecialities(widget.userID);
  }

  void _getServiceRelatedToSpeciality(String specialityId) {
    _catalogueList = [];
    _userBloc..getSpecialityRelatedService(widget.userID, specialityId);
  }

  _openDocDetails(DoctorsData doctorsData) {
    showDialog(
        context: context,
        builder: (_) => CustomWidgets()
            .showDocPopup(doctorsData, context, _profileResponse?.user?.name));
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
}
