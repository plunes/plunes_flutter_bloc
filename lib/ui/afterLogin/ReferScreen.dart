import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:share/share.dart';

class ReferScreen extends BaseActivity {
  static const tag = '/referscreen';

  @override
  _ReferScreenState createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth, _credit = '0', _referralCode = '';
  Preferences _preferences;
  bool progress = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    _preferences = Preferences();
    _credit = _preferences.getPreferenceString(Constants.PREF_CREDITS) != ''
        ? _preferences.getPreferenceString(Constants.PREF_CREDITS)
        : '0';
    _referralCode =
        _preferences.getPreferenceString(Constants.PREF_REFERRAL_CODE);
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.referAndEarn, true),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: getBodyView());
  }

  Widget getBodyView() {
    return Container(
      margin: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.createTextViews(plunesStrings.inviteYourFriends, 22,
              colorsFile.black1, TextAlign.start, FontWeight.bold),
          widget.getSpacer(0.0, 20.0),
          getBulletRow(plunesStrings.text1Referral),
          getBulletRow(plunesStrings.text2Referral),
          getBulletRow(plunesStrings.cashCanBeUsed),
          Expanded(
            child: Image.asset(
              plunesImages.coverIcon,
              height: 200,
              width: double.infinity,
            ),
          ),
          widget.getSpacer(0.0, 10.0),
          widget.createTextViews(plunesStrings.availableCredits, 14,
              colorsFile.darkGrey1, TextAlign.start, FontWeight.normal),
          widget.getSpacer(0.0, 10.0),
          Container(
            child: Row(
              children: <Widget>[
                Image.asset(
                  plunesImages.creditIcon,
                  height: 30,
                  width: 30,
                ),
                SizedBox(
                  width: 5,
                ),
                widget.createTextViews(_credit, 16, colorsFile.darkGrey1,
                    TextAlign.start, FontWeight.bold),
              ],
            ),
          ),
          widget.getSpacer(0.0, 30.0),
          widget.createTextViews(plunesStrings.shareYourInviteCode, 14,
              colorsFile.darkGrey1, TextAlign.start, FontWeight.normal),
          widget.getSpacer(0.0, 10.0),
          InkWell(
            onTap: () {
              Clipboard.setData(new ClipboardData(text: _referralCode));
              CommonMethods.showLongToast(plunesStrings.copyToClipboard);
            },
            child: Container(
              color: Color(0xffF9F9F9),
              height: 45,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    widget.createTextViews(
                        _referralCode,
                        15,
                        colorsFile.lightGrey5,
                        TextAlign.start,
                        FontWeight.normal),
                    Expanded(child: Container()),
                    widget.createTextViews(
                        plunesStrings.copyCode,
                        15,
                        colorsFile.defaultGreen,
                        TextAlign.start,
                        FontWeight.normal),
                  ],
                ),
              ),
            ),
          ),
          Container(
              height: 1,
              color: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.lightGrey6))),
          widget.getSpacer(0.0, 30.0),
          InkWell(
            onTap: () {
              Share.share(
                  "Join me on Plunes and get upto 50% discount instantly!Use my invite code: $_referralCode and get Rs. 100/- as free referral cash.Download Plunes now: https://plunes.com");
            },
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Container(
              height: 45,
              alignment: Alignment.center,
              child: widget.createTextViews(plunesStrings.inviteFriends, 18,
                  colorsFile.white, TextAlign.center, FontWeight.normal),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Color(0xff01D35A)),
            ),
          )
        ],
      ),
    );
  }

  Widget getBulletRow(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              height: 5,
              width: 5,
              margin: EdgeInsets.only(left: 10, right: 10, top: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.black)),
          Expanded(
              child: widget.createTextViews(text, 15, colorsFile.greyLight,
                  TextAlign.start, FontWeight.normal)),
        ],
      ),
    );
  }
}
