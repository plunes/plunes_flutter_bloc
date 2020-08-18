import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
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
import 'package:share/share.dart';

// ignore: must_be_immutable
class ReferScreen extends BaseActivity {
  static const tag = '/referscreen';

  @override
  _ReferScreenState createState() => _ReferScreenState();
}

class _ReferScreenState extends BaseState<ReferScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth, _credit = '0', _referralCode = '';
  Preferences _preferences;
  bool progress = true, _hasUsedCodeThrice = false;
  UserBloc _userBloc;
  LoginPost _userProfileInfo;
  String _failureCause;

  @override
  void initState() {
    _userBloc = UserBloc();
    _initialize();
    super.initState();
  }

  void _initialize() {
    _preferences = Preferences();
    _credit = _preferences.getPreferenceString(Constants.PREF_CREDITS) != ''
        ? _preferences.getPreferenceString(Constants.PREF_CREDITS)
        : '0';
    _referralCode =
        _preferences.getPreferenceString(Constants.PREF_REFERRAL_CODE);
    _getCurrentCredits();
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
        body: Container(
            child: progress
                ? CustomWidgets().getProgressIndicator()
                : _failureCause != null
                    ? CustomWidgets().errorWidget(_failureCause)
                    : _hasUsedCodeThrice
                        ? _bodyForCodeUsedThrice()
                        : getBodyView()));
  }

  Widget getBodyView() {
    return Container(
      margin: EdgeInsets.all(30),
      height: AppConfig.verticalBlockSize * 90,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: widget.createTextViews(plunesStrings.inviteYourFriends, 22,
                  colorsFile.black1, TextAlign.center, FontWeight.w500),
            ),
            widget.getSpacer(0.0, 20.0),
            getBulletRow(plunesStrings.text1Referral),
            getBulletRow(plunesStrings.text2Referral),
            getBulletRow(plunesStrings.cashCanBeUsed),
            getBulletRow(PlunesStrings.codeCanBeUsedThreeTimes,
                textInGreen: PlunesStrings.hurryAndRefer),
            Container(
              width: double.infinity,
              child: Image.asset(
                plunesImages.coverIcon,
                height: AppConfig.verticalBlockSize * 30,
                alignment: Alignment.center,
              ),
            ),
            widget.createTextViews(plunesStrings.availableCredits, 14,
                colorsFile.darkGrey1, TextAlign.start, FontWeight.w500),
            widget.getSpacer(0.0, 10.0),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      TextAlign.start, FontWeight.w500),
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
                CommonMethods.showLongToast(plunesStrings.copyToClipboard,
                    centerGravity: false,
                    bgColor: PlunesColors.LIGHTGREENCOLOR);
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
            Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 22,
                  right: AppConfig.horizontalBlockSize * 22),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onTap: () {
                  Share.share(
                      "Join me on Plunes and get upto 50% discount instantly!Use my invite code: $_referralCode and get Rs. 100/- as free referral cash.Download Plunes now: https://plunes.com");
                },
                child: CustomWidgets().getRoundedButton(
                    plunesStrings.inviteFriends,
                    AppConfig.horizontalBlockSize * 8,
                    PlunesColors.GREENCOLOR,
                    AppConfig.horizontalBlockSize * 0,
                    AppConfig.verticalBlockSize * 1.2,
                    PlunesColors.WHITECOLOR),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBulletRow(String text, {String textInGreen}) {
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
          (textInGreen == null)
              ? Expanded(
                  child: widget.createTextViews(text, 15, colorsFile.greyLight,
                      TextAlign.start, FontWeight.normal))
              : Expanded(
                  child: RichText(
                    text: TextSpan(
                        text: text,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color(CommonMethods.getColorHexFromStr(
                                colorsFile.greyLight))),
                        children: [
                          TextSpan(
                            text: textInGreen,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: PlunesColors.GREENCOLOR),
                          )
                        ]),
                  ),
                )
        ],
      ),
    );
  }

  void _getCurrentCredits() async {
    var requestState =
        await _userBloc.getUserProfile(UserManager().getUserDetails().uid);
    if (requestState is RequestSuccess) {
      _userProfileInfo = requestState.response;
      if (_userProfileInfo != null &&
          _userProfileInfo.user != null &&
          _userProfileInfo.user.credits != null &&
          _userProfileInfo.user.credits != "") {
        _credit = _userProfileInfo.user.credits;
        _preferences.setPreferencesString(Constants.PREF_CREDITS, _credit);
      }
      if (_userProfileInfo != null &&
          _userProfileInfo.user != null &&
          _userProfileInfo.user.referralCode != null &&
          _userProfileInfo.user.referralCode != "") {
        _referralCode = _userProfileInfo.user.referralCode;
        _preferences.setPreferencesString(
            Constants.PREF_REFERRAL_CODE, _referralCode);
      }
      if (_userProfileInfo != null &&
          _userProfileInfo.user != null &&
          _userProfileInfo.user.referralExpired != null) {
        _hasUsedCodeThrice = _userProfileInfo.user.referralExpired;
      }
    } else if (requestState is RequestFailed) {
      _failureCause =
          requestState.failureCause ?? plunesStrings.somethingWentWrong;
    }
    progress = false;
    _setState();
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _bodyForCodeUsedThrice() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 10),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(PlunesImages.refCodeUsedThrice),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
            child: Text(
              "Oops,",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontSize: AppConfig.extraLargeFont,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
            child: Text(
              PlunesStrings.looksLikeReferralCodeIsExpired,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: PlunesColors.GREYCOLOR,
                  fontSize: AppConfig.largeFont,
                  fontWeight: FontWeight.w500),
            ),
          ),
          widget.getSpacer(0.0, AppConfig.verticalBlockSize * 8),
          widget.createTextViews(plunesStrings.availableCredits, 14,
              colorsFile.darkGrey1, TextAlign.start, FontWeight.normal),
          widget.getSpacer(0.0, 10.0),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    TextAlign.start, FontWeight.w500),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
