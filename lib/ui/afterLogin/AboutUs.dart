import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
//import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

//  YoutubePlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState

    getUserData();
    getHospData();
//    _controller = YoutubePlayerController(
//        initialVideoId: YoutubePlayer.convertUrlToId(
//            widget.userType == Constants.user ? _userVideoUrl : _hospVideoUrl));
    super.initState();
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
    return SingleChildScrollView(
      child: Container(
        color: PlunesColors.WHITECOLOR,
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
//                maxLines: 5,
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
//            Container(
//              child: YoutubePlayer(
//                controller: _controller,
//                showVideoProgressIndicator: true,
//              ),
//            ),

            InkWell(
              onTap: () {
                widget.userType == Constants.user
                    ? LauncherUtil.launchUrl(_userVideoUrl)
                    : LauncherUtil.launchUrl(_hospVideoUrl);
              },
              child: Container(
                margin:
                    EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 5),
//                decoration: BoxDecoration(
//                  border: Border.all(
//                      color: PlunesColors.SPARKLINGGREEN,
//                      style: BorderStyle.solid,
//                      width: 1.5),
//                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Watch the Video',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: AppConfig.largeFont,
                        color: PlunesColors.SPARKLINGGREEN),
                  ),
                ),
              ),
            )
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
            itemCount: 6,
            itemBuilder: (BuildContext context, int index) {
              return Container(
//                  decoration: ShapeDecoration(
//                      color: PlunesColors.WHITECOLOR,
//                      shape: RoundedRectangleBorder(
//                          borderRadius:
//                              BorderRadius.all(Radius.elliptical(50, 50)))),
                color: PlunesColors.WHITECOLOR,
                margin: EdgeInsets.all(5),
                child: Card(
                  elevation: 2.5,
                  child: Padding(
//                    height: AppConfig.verticalBlockSize * 5,
//                    width: double.infinity,
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
//                crossAxisCount: 2,
//                childAspectRatio: AppConfig.verticalBlockSize *
//                    .5 /
//                    AppConfig.horizontalBlockSize *
//                    1.42)));
                crossAxisCount: 2,
                childAspectRatio: 1)));
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
//                  decoration: ShapeDecoration(
//                      color: PlunesColors.WHITECOLOR,
//                      shape: RoundedRectangleBorder(
//                          borderRadius:
//                              BorderRadius.all(Radius.elliptical(50, 50)))),
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
//                            flex: 2,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * .5),
                                child: widget.getAssetIconWidget(
                                    aboutUsHosp[index]['Image'],
                                    70,
                                    70,
                                    BoxFit.contain))),
                        Expanded(
//                          flex: 1,
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

//                crossAxisCount: 2,
//                childAspectRatio: AppConfig.verticalBlockSize *
//                    .5 /
//                    AppConfig.horizontalBlockSize *
//                    1.38)));
                crossAxisCount: 2,
                childAspectRatio: 1)));
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
    for (int i = 0; i < 6; i++) {
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
}
