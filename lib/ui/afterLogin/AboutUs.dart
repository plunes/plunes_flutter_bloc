import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/new_solution_model/premium_benefits_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
//import 'package:simple_url_preview/simple_url_preview.dart';

import '../../OpenMap.dart';

// ignore: must_be_immutable
class AboutUs extends BaseActivity {
  static const tag = '/aboutus';
  final userType;

  AboutUs({this.userType});

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends BaseState<AboutUs> {
  List<dynamic> aboutUsUser = new List();
  List<dynamic> aboutUsHosp = new List();
  String _userVideoUrl = "https://youtu.be/QwCxu5BgJQg";
  String _hospVideoUrl = "https://youtu.be/eEQGGzplZ7w";
  PremiumBenefitsModel _premiumBenefitsModel;
  UserBloc _userBloc;

//  YoutubePlayerController _controller;

  @override
  void initState() {
    _userBloc = UserBloc();
    getUserData();
    getHospData();
    _getPremiumBenefitsForUsers();
    super.initState();
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    super.dispose();
  }

  _getPremiumBenefitsForUsers() {
    _userBloc
        .getPremiumBenefitsForUsers(isFromAboutUsScreen: true)
        .then((value) {
      if (value is RequestSuccess) {
        _premiumBenefitsModel = value.response;
      } else if (value is RequestFailed) {}
      _setState();
    });
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    return Scaffold(
      backgroundColor: PlunesColors.WHITECOLOR,
      appBar: widget.getAppBar(context, plunesStrings.aboutUs, true),
      body: _getBody(),
    );
//      WebviewScaffold(
//      clearCache: false,
//      withZoom: true,
//      hidden: true,
//      initialChild: Container(
//        color: Colors.white,
//        child: Center(
//            child: SpinKitThreeBounce(
//          color: Color(hexColorCode.defaultTransGreen),
//          size: 30.0,
//        )),
//      ),
//      url: urls.aboutUs,
//
//      appBar: widget.getAppBar(context, plunesStrings.aboutUs, true),
//    );
  }

  Widget _getBody() {
    if (widget.userType == Constants.user) {
      return _getUserWidget();
    }
    return SingleChildScrollView(
      child: Container(
        color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 5,
                horizontal: AppConfig.horizontalBlockSize * 7,
              ),
              child: Text(
                widget.userType == Constants.user
                    ? PlunesStrings.aboutUsDesc
                    : PlunesStrings.aboutUsHospital,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppConfig.smallFont),
              ),
            ),
            widget.userType == Constants.user
                ? Container()
                : Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 7),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8, bottom: 8),
                          child: Text(PlunesStrings.realTimeInsights,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            PlunesStrings.weUseAI,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: PlunesColors.GREYCOLOR,
                              fontSize: AppConfig.smallFont,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 2),
                          margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 1),
                          child: Column(
                            children: <Widget>[
                              getBulletRow(PlunesStrings.realTimeDecision),
                              getBulletRow(PlunesStrings.takeAction),
                              getBulletRow(PlunesStrings.youCanProvide),
                              getBulletRow(PlunesStrings.directLeadMatching),
                              getBulletRow(PlunesStrings.saveLakhs),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
            Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 7),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                      child: Text(PlunesStrings.perksPrivileges,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppConfig.mediumFont,
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    Text(
                      PlunesStrings.perksDownloading,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConfig.smallFont,
                      ),
                    )
                  ],
                )),
            widget.userType == Constants.user ? _usersCard() : _hospitalCard(),
            Container(
              margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 7,
                right: AppConfig.horizontalBlockSize * 7,
                bottom: AppConfig.verticalBlockSize * 2,
              ),
//              padding: const EdgeInsets.all(8.0),
              child: Text(
                  widget.userType == Constants.user
                      ? PlunesStrings.seeHowItWorks
                      : PlunesStrings.seeHowItWorksHospital,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            _getWatchVideoSection(),
          ],
        ),
      ),
    );
  }

  Widget _usersCard() {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
        child: GridView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: aboutUsUser.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color: PlunesColors.WHITECOLOR,
                margin: EdgeInsets.all(5),
                child: Card(
                  elevation: 2.5,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * .5),
                              child: widget.getAssetIconWidget(
                                  aboutUsUser[index]['Image'],
                                  70,
                                  70,
                                  BoxFit.contain)),
                        ),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * .5),
                                child: widget.createTextViews(
                                    aboutUsUser[index]['Info'],
                                    AppConfig.verySmallFont,
                                    colorsFile.black0,
                                    TextAlign.center,
                                    FontWeight.normal))),
                      ],
                    ),
                  ),
                ),
              );
            },
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1)));
  }

  Widget _hospitalCard() {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
        child: GridView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: 6,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color: PlunesColors.WHITECOLOR,
                margin: EdgeInsets.all(5),
                child: Card(
                  elevation: 2.5,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * .5),
                                child: widget.getAssetIconWidget(
                                    aboutUsHosp[index]['Image'],
                                    70,
                                    70,
                                    BoxFit.contain))),
                        Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: widget.createTextViews(
                                  aboutUsHosp[index]['Info'],
                                  AppConfig.verySmallFont,
                                  colorsFile.black0,
                                  TextAlign.center,
                                  FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1)));
  }

  Widget getBulletRow(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              height: 5,
              width: 5,
              margin: EdgeInsets.only(left: 10, right: 10, top: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: PlunesColors.GREYCOLOR)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: AppConfig.verySmallFont,
                  fontWeight: FontWeight.normal,
                  color: PlunesColors.GREYCOLOR),
            ),
          )
        ],
      ),
    );
  }

  void getUserData() {
    for (int i = 0; i < 5; i++) {
      Map map = new Map();
      map['Image'] = plunesImages.aboutUsUserArray[i];
      map['Info'] = plunesStrings.aboutUsUser[i];
      aboutUsUser.add(map);
    }
  }

  void getHospData() {
    for (int i = 0; i < 6; i++) {
      Map map = new Map();
      map['Image'] = plunesImages.aboutUsHospArray[i];
      map['Info'] = plunesStrings.aboutUsHosp[i];
      aboutUsHosp.add(map);
    }
  }

  Widget _getUserWidget() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                PlunesImages.home_screen_image,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 4),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: "India's ",
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#000000")),
                                fontSize: 30,
                                fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text: "Largest ",
                                style: TextStyle(
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#01D35A")),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: "Network Of Hospitals",
                                style: TextStyle(
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#000000")),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                            ])),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 3),
                    child: Text(
                      "Plunes is India’s largest network of world class hospitals and doctors. Our AI helps you connect with f top-rated professionals in your vicinity and get you the best prices for your treatment in just one click. Find instant solutions for all your medical tests and procedures in Delhi-NCR.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#565656")),
                          fontSize: 18,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  _getPremiumBenefitsWidget(),
                  Container(
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 5),
                    child: _getWatchVideoSection(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getPremiumBenefitsWidget() {
    if (_premiumBenefitsModel == null ||
        _premiumBenefitsModel.data == null ||
        _premiumBenefitsModel.data.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
          alignment: Alignment.center,
          child: Text(
            "Premium Benefits for Our Users",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(CommonMethods.getColorHexFromStr("#000000")),
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 6),
            itemBuilder: (context, index) {
              return Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: Container(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: CustomWidgets().getImageFromUrl(
                        _premiumBenefitsModel.data[index]?.titleImage ?? '',
                        boxFit: BoxFit.cover),
                  ),
                ),
              );
            },
            itemCount: _premiumBenefitsModel.data.length,
          ),
        )
      ],
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getWatchVideoSection() {
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        widget.userType == Constants.user
            ? LauncherUtil.launchUrl(_userVideoUrl)
            : LauncherUtil.launchUrl(_hospVideoUrl);
      },
      onDoubleTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 5),
        child: Column(
          children: <Widget>[
            Text(
              'Watch our video',
              style: TextStyle(
                  fontSize: AppConfig.largeFont,
                  color: PlunesColors.SPARKLINGGREEN),
            ),
          ],
        ),
      ),
    );
  }
}
