import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/achievement_review.dart';

// ignore: must_be_immutable
class HospitalProfile extends BaseActivity {
  final String userID;

  HospitalProfile({this.userID});

  @override
  _HospitalProfileState createState() => _HospitalProfileState();
}

class _HospitalProfileState extends BaseState<HospitalProfile> {
  UserBloc _userBloc;
  LoginPost _profileResponse;
  List<SpecialityModel> specialityList;
  String _specialitySelectedId;
  List<CatalogueData> _catalogueList;
  String _serviceFailureCause;

  String _failureCause;

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
                ? CustomWidgets()
                    .errorWidget(_failureCause ?? "Unable to get profile")
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
            Container(
              height: AppConfig.verticalBlockSize * 22,
              width: double.infinity,
              child: (_profileResponse.user.coverImageUrl != null ||
                      _profileResponse.user.coverImageUrl.isEmpty)
                  ? Container(
                      margin: EdgeInsets.symmetric(
                          vertical: AppConfig.verticalBlockSize * 5,
                          horizontal: AppConfig.horizontalBlockSize * 20),
                      child: Image.asset(PlunesImages.hospitalImage),
                    )
                  : SizedBox.expand(
                      child: CustomWidgets().getImageFromUrl(
                          _profileResponse.user.coverImageUrl,
                          boxFit: BoxFit.cover),
                    ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 4),
                    child: _getNameAndImageView(),
                  ),
                  getProfileInfoView(
                      24,
                      24,
                      plunesImages.locationIcon,
                      plunesStrings.locationSep,
                      _profileResponse.user?.address),
                  (_profileResponse.user.latitude != null &&
                          _profileResponse.user.longitude != null)
                      ? InkWell(
                          onTap: () => _getDirections(),
                          onDoubleTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(
                                AppConfig.horizontalBlockSize * 4),
                            margin: EdgeInsets.only(left: 24),
                            child: Text(
                              PlunesStrings.viewOnMap,
                              style: TextStyle(
                                  color: PlunesColors.GREENCOLOR,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        )
                      : Container(),
                  _getIntroductionView(),
                  StreamBuilder<RequestState>(
                    builder: (context, snapshot) {
                      if (snapshot.data is RequestSuccess) {
                        RequestSuccess requestSuccess = snapshot.data;
                        specialityList = requestSuccess.response;
                        _userBloc.addStateInSpecialityStream(null);
                      }
                      if (specialityList != null && specialityList.isNotEmpty) {
                        return _getSpecializationWidget();
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
                                  height: AppConfig.verticalBlockSize * 14,
                                  width: double.infinity,
                                  child: CustomWidgets().errorWidget(
                                      _serviceFailureCause ??
                                          PlunesStrings.unableToLoadServices))
                              : _getServiceList();
                        }
                        return Container();
                      }),
                  _getTeamOfExpertsWidget(),
                  _getBottomView()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getNameAndImageView() {
    return Row(
      children: <Widget>[
        (_profileResponse.user != null &&
                _profileResponse.user.imageUrl != null &&
                _profileResponse.user.imageUrl.isNotEmpty)
            ? CircleAvatar(
                child: Container(
                  height: 60,
                  width: 60,
                  child: ClipOval(
                      child: CustomWidgets().getImageFromUrl(
                          _profileResponse.user.imageUrl,
                          boxFit: BoxFit.fill)),
                ),
                radius: 30,
              )
            : CustomWidgets().getBackImageView(
                _profileResponse.user?.name ?? _getEmptyString()),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _profileResponse.user?.name ?? _getEmptyString(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
            child: Text(_profileResponse.user?.biography ?? _getEmptyString()),
          ),
        ],
      ),
    );
  }

  _getEmptyString() {
    return PlunesStrings.NA;
  }

  Widget _getSpecializationWidget() {
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
              item.speciality ?? _getEmptyString(),
              style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
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
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 1.8),
                child: Text(
                  plunesStrings.specialization,
                  style:
                      TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 5,
                    vertical: AppConfig.verticalBlockSize * 2),
                child: DropdownButtonHideUnderline(child: dropDown),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ],
          );
  }

  void _getUserDetails() {
    _userBloc.getUserProfile(widget.userID);
  }

  Widget _getTeamOfExpertsWidget() {
    return (_profileResponse.user.doctorsData == null ||
            _profileResponse.user.doctorsData.isEmpty)
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 2),
                child: Text(
                  plunesStrings.teamOfExperts,
                  style:
                      TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
                ),
              ),
              Container(
                height: AppConfig.verticalBlockSize * 42,
                width: double.infinity,
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _profileResponse.user.doctorsData.length > 5
                        ? 5
                        : _profileResponse.user.doctorsData.length,
                    itemBuilder: (context, itemIndex) {
                      return Container(
//              height: AppConfig.verticalBlockSize * 30,
//              width: AppConfig.horizontalBlockSize * 60,
                        margin: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 0.5,
                            horizontal: AppConfig.horizontalBlockSize * 0.5),
                        padding: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 0.5),
                        decoration: BoxDecoration(
//                  borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Color(0xffababab)
//                gradient: new LinearGradient(
//                    colors: [, Color(0xffababab)],
//                    begin: FractionalOffset.topCenter,
//                    end: FractionalOffset.bottomCenter,
//                    stops: [0.0, 1.0],
//                    tileMode: TileMode.clamp),
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            (_profileResponse.user.doctorsData[itemIndex]
                                            .imageUrl ==
                                        null ||
                                    _profileResponse.user.doctorsData[itemIndex]
                                        .imageUrl.isEmpty)
                                ? CustomWidgets().getBackImageView(
                                    _profileResponse
                                            .user.doctorsData[itemIndex].name ??
                                        _getEmptyString())
                                : CircleAvatar(
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      child: ClipOval(
                                          child: CustomWidgets()
                                              .getImageFromUrl(
                                                  _profileResponse
                                                      .user
                                                      .doctorsData[itemIndex]
                                                      .imageUrl,
                                                  boxFit: BoxFit.fill)),
                                    ),
                                    radius: 30,
                                  ),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 0.8),
                              child: Text(
                                _profileResponse
                                        .user.doctorsData[itemIndex].name ??
                                    _getEmptyString(),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: PlunesColors.WHITECOLOR,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                            )),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 0.8),
                              child: Text(
                                _profileResponse.user.doctorsData[itemIndex]
                                        .designation ??
                                    _getEmptyString(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    color: PlunesColors.WHITECOLOR,
                                    fontSize: 15),
                              ),
                            )),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 0.8),
                              child: Text(
                                _getExpr(itemIndex) ?? _getEmptyString(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    color: PlunesColors.WHITECOLOR,
                                    fontSize: 15),
                              ),
                            )),
                          ],
                        ),
                      );
                    }),
              ),
              (_profileResponse.user.doctorsData != null &&
                      _profileResponse.user.doctorsData.isNotEmpty &&
                      _profileResponse.user.doctorsData.length > 5)
                  ? InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => CustomWidgets()
                                .showDoctorList(
                                    _profileResponse.user.doctorsData, context),
                            barrierDismissible: true);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 0.1),
                        padding:
                            EdgeInsets.all(AppConfig.horizontalBlockSize * 5),
                        child: Text(
                          PlunesStrings.seeMoreDoctors,
                          style: TextStyle(
                            color: PlunesColors.GREENCOLOR,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          );
  }

  Widget _getBottomView() {
    return AchievementAndReview(_profileResponse.user);
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

  String _getExpr(int itemIndex) {
    return _profileResponse.user.doctorsData[itemIndex].experience == null
        ? null
        : "Expr ${_profileResponse.user.doctorsData[itemIndex].experience} years";
  }

  Widget _getServiceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2.5),
          child: Text(
            PlunesStrings.serviceList,
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
          ),
        ),
        Container(
          height: AppConfig.verticalBlockSize * 20,
          width: double.infinity,
          child: ListView.builder(
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
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 0.8,
                            horizontal: AppConfig.horizontalBlockSize * 5),
                        child: Text(
                          _catalogueList[index].service ?? _getEmptyString(),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      flex: 3,
                    ),
                    Expanded(
                      child: Container(),
                      flex: 1,
                    ),
                    Expanded(
                      child: Text(
                        PlunesStrings.knowMore,
                        style: TextStyle(fontSize: 16),
                      ),
                      flex: 2,
                    )
                  ],
                ),
              );
            },
            itemCount: _catalogueList?.length ?? 0,
          ),
        ),
        Container(
          height: 0.5,
          width: double.infinity,
          color: PlunesColors.GREYCOLOR,
          margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
        ),
      ],
    );
  }

  void _getSpecialities() {
    _userBloc.getUserSpecificSpecialities(widget.userID);
  }

  void _getServiceRelatedToSpeciality(String specialityId) {
    _catalogueList = [];
    _userBloc..getSpecialityRelatedService(widget.userID, specialityId);
  }
}
