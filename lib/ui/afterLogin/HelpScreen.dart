import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';

class HelpScreen extends BaseActivity {
  static const tag = '/helpScreen';

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends BaseState<HelpScreen> implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _descriptionController = new TextEditingController();
  var globalHeight, globalWidth, title = '';
  DocHosMainInsightBloc _docHosMainInsightBloc;
  TextEditingController _docHosQueryController;
  UserBloc _userBloc;
  HelpLineNumberModel _helpLineNumberModel;
  final String _helpNumber = "7011311900";

  bool booking = false,
      isOnlineSolution = false,
      isFeedback = false,
      isPopupShowing = false;

  @override
  void initState() {
    _userBloc = UserBloc();
    _docHosQueryController = TextEditingController();
    _docHosMainInsightBloc = DocHosMainInsightBloc();
    _getHelpLineNumber();
    super.initState();
  }

  @override
  void dispose() {
    bloc.disposeHelpApiStream();
    _docHosMainInsightBloc?.dispose();
    _userBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.help, true),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Container(
            child: (UserManager().getUserDetails().userType != Constants.user)
                ? getBodyDocHosView()
                : Stack(
                    children: <Widget>[
                      getBodyUserView(),
                      isPopupShowing
                          ? Container(color: Color(0xff90000000))
                          : Container(),
                      isPopupShowing
                          ? CommonMethods.messageSubmitDialog(
                              context, title, _descriptionController, this)
                          : Container()
                    ],
                  )));
  }

  Widget getHelpContentRow(bool isIcon, String image, String _title,
      double fontSize, FontWeight fontWeight) {
    return InkWell(
      onTap: () => onTapAction(_title),
      child: Container(
        margin: EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            isIcon
                ? Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: image != null
                        ? widget.getAssetIconWidget(image, 20, 20, BoxFit.cover)
                        : Container())
                : Container(),
            Expanded(
                child: widget.createTextViews(_title, fontSize,
                    colorsFile.black0, TextAlign.start, fontWeight)),
            ((plunesStrings.bookingAppointments == _title && booking) ||
                    (plunesStrings.onlineSolution == _title &&
                        isOnlineSolution) ||
                    (plunesStrings.feedBacks == _title && isFeedback))
                ? Icon(Icons.keyboard_arrow_down, color: Colors.black)
                : Icon(Icons.keyboard_arrow_right, color: Colors.black)
          ],
        ),
      ),
    );
  }

  Widget getBodyDocHosView() {
    bool isSuccess = false;
    String failureMessage;
    return SingleChildScrollView(
      child: StreamBuilder<RequestState>(
          stream: _docHosMainInsightBloc.helpQueryDocHosStream,
          builder: (BuildContext context, snapshot) {
            if (snapshot.data != null && snapshot.data is RequestInProgress) {
              return Container(
                child: CustomWidgets().getProgressIndicator(),
                height: AppConfig.verticalBlockSize * 70,
                width: double.infinity,
              );
            }
            if (snapshot.data != null && snapshot.data is RequestSuccess) {
              isSuccess = true;
            }
            if (snapshot.data != null && snapshot.data is RequestFailed) {
              RequestFailed requestFailed = snapshot.data;
              failureMessage = requestFailed.failureCause ??
                  PlunesStrings.helpQueryFailedMessage;
              _docHosMainInsightBloc.addStateInHelpQueryStream(null);
            }
            return isSuccess
                ? Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppConfig.horizontalBlockSize * 5)),
                    child: SingleChildScrollView(
                      child: Column(
//              mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: AppConfig.verticalBlockSize * 3),
                              height: AppConfig.verticalBlockSize * 10,
                              child: Image.asset(PlunesImages.helpThankyou)),
                          Container(
                            margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 6,
                              right: AppConfig.horizontalBlockSize * 6,
                            ),
                            child: Text(
                              PlunesStrings.thankYou,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.BLACKCOLOR),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 6,
                                vertical: AppConfig.verticalBlockSize * 2),
                            child: Text(
                              PlunesStrings.thanksForContacting,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.smallFont,
                                  color: PlunesColors.GREYCOLOR),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            width: double.infinity,
                            color: PlunesColors.GREYCOLOR,
                            margin: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 3),
                          ),
                          FlatButton(
                              splashColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.2),
                              highlightColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.2),
                              focusColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.2),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    "OK",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: AppConfig.mediumFont,
                                        color: PlunesColors.SPARKLINGGREEN),
                                  ))),

//                  FlatButton(
//                      onPressed: () {},
//                      color: PlunesColors.GREENCOLOR,
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(50)),
//                      child: Container(
//                        width: AppConfig.horizontalBlockSize * 20,
//                        child: Text(
//                          "Update",
//                          style: TextStyle(color: PlunesColors.WHITECOLOR),
//                          textAlign: TextAlign.center,
//                        ),
//                      )),
//                    ],
//                  )
                        ],
                      ),
                    ),
                  )
//              Container(
//                      padding: EdgeInsets.symmetric(
//                          horizontal: AppConfig.horizontalBlockSize * 6,
//                          vertical: AppConfig.verticalBlockSize * 2),
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        crossAxisAlignment: CrossAxisAlignment.center,
//                        children: <Widget>[
//                          Container(
//                              margin: EdgeInsets.symmetric(
//                                  vertical: AppConfig.verticalBlockSize * 3),
//                              height: AppConfig.verticalBlockSize * 25,
//                              child: Image.asset(PlunesImages.helpThankyou)),
//                          Center(
//                            child: Text(PlunesStrings.thankYouMessage,
//                                style: TextStyle(
//                                    fontSize: AppConfig.veryExtraLargeFont,
//                                    fontWeight: FontWeight.w500,
//                                    color: PlunesColors.BLACKCOLOR)),
//                          ),
//                          Container(
//                            margin: EdgeInsets.symmetric(
//                                vertical: AppConfig.verticalBlockSize * 3,
//                                horizontal: AppConfig.horizontalBlockSize * 3),
//                            child: Text(PlunesStrings.helpQuerySuccessMessage,
//                                textAlign: TextAlign.center,
//                                style: TextStyle(
//                                    fontSize: AppConfig.extraLargeFont,
//                                    fontWeight: FontWeight.w500,
//                                    color: PlunesColors.GREYCOLOR)),
//                          ),
//                        ],
//                      ),
//                    )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        PlunesImages.hospHelp,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 6,
                            vertical: AppConfig.verticalBlockSize * 3),
                        child: Text(
                          PlunesStrings.ourTeamWillContactYou,
                          style: TextStyle(
                              fontSize: AppConfig.largeFont,
                              color: PlunesColors.GREYCOLOR),
                          textAlign: TextAlign.center,
                        ),
                      ),
//                      Container(
//                          alignment: Alignment.topLeft,
//                          padding: EdgeInsets.only(
//                              top: AppConfig.verticalBlockSize * 4),
//                          child: Text(PlunesStrings.writeYourConcern,
//                              textAlign: TextAlign.start,
//                              style: TextStyle(
//                                fontSize: AppConfig.mediumFont,
//                              ))),

                      Container(
                        margin: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 5,
                          right: AppConfig.horizontalBlockSize * 5,
                        ),
                        height: AppConfig.verticalBlockSize * 10,
                        child: TextField(
                          style: TextStyle(fontSize: AppConfig.mediumFont),
                          decoration: InputDecoration(
                              alignLabelWithHint: true,
                              hintText: plunesStrings.description,
                              hintStyle: TextStyle(
                                  fontSize: AppConfig.largeFont - 3,
                                  decorationStyle: TextDecorationStyle.wavy)),
                          controller: _docHosQueryController,
                          keyboardType: TextInputType.text,
                          textDirection: TextDirection.ltr,
                          maxLines: null,
                          expands: true,
                          autofocus: true,
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 4,
                        ),
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 30,
                            right: AppConfig.horizontalBlockSize * 30),
                        child: InkWell(
                            onTap: () {
                              if (_docHosQueryController.text
                                  .trim()
                                  .isNotEmpty) {
                                _docHosMainInsightBloc.helpDocHosQuery(
                                    _docHosQueryController.text.trim());
                              } else if (_docHosQueryController.text
                                  .trim()
                                  .isEmpty) {
                                failureMessage =
                                    PlunesStrings.emptyQueryFieldMessage;
                                _docHosMainInsightBloc
                                    .addStateInHelpQueryStream(null);
                              }
                            },
                            onDoubleTap: () {},
                            child: CustomWidgets().getRoundedButton(
                                plunesStrings.submit,
                                AppConfig.horizontalBlockSize * 8,
                                PlunesColors.GREENCOLOR,
                                AppConfig.horizontalBlockSize * 0,
                                AppConfig.verticalBlockSize * 1.2,
                                PlunesColors.WHITECOLOR)),
                      ),
//                        FlatButton(
//                            focusColor:
//                                PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                            splashColor:
//                                PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                            highlightColor:
//                                PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                            onPressed: () {
//                              if (_docHosQueryController.text
//                                  .trim()
//                                  .isNotEmpty) {
//                                _docHosMainInsightBloc.helpDocHosQuery(
//                                    _docHosQueryController.text.trim());
//                              } else if (_docHosQueryController.text
//                                  .trim()
//                                  .isEmpty) {
//                                failureMessage =
//                                    PlunesStrings.emptyQueryFieldMessage;
//                                _docHosMainInsightBloc
//                                    .addStateInHelpQueryStream(null);
//                              }
//                            },
//                            child: Container(
//                                width: double.infinity,
//                                padding: EdgeInsets.symmetric(
////                                      vertical:
////                                          AppConfig.verticalBlockSize * 1.5,
//                                    horizontal:
//                                        AppConfig.horizontalBlockSize * 7),
//                                child: Text(
//                                  'Submit',
//                                  textAlign: TextAlign.center,
//                                  style: TextStyle(
//                                      fontSize: AppConfig.largeFont,
//                                      fontWeight: FontWeight.w500,
//                                      color: PlunesColors.SPARKLINGGREEN),
//                                ))),
                      failureMessage == null || failureMessage.isEmpty
                          ? Container()
                          : Container(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 1),
                              child: Text(failureMessage,
                                  style: TextStyle(color: Colors.red))),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 4),
                        child: Text('OR',
                            style: TextStyle(fontSize: AppConfig.mediumFont)),
                      ),
                      _callWidget()
                    ],
                  );
          }),
    );
  }

  Widget getBodyUserView() {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          width: globalWidth,
          color: Color(CommonMethods.getColorHexFromStr(colorsFile.grey)),
          child: widget.createTextViews(plunesStrings.iHaveIssueWith, 14,
              colorsFile.black0, TextAlign.start, FontWeight.normal),
        ),
        Column(
          children: <Widget>[
            getHelpContentRow(true, plunesImages.appointCalIcon,
                plunesStrings.bookingAppointments, 15, FontWeight.w600),
            widget.getDividerRow(context, 0, 0, 0),
            Visibility(
                visible: booking,
                child: Container(
                    color: Color(
                        CommonMethods.getColorHexFromStr(colorsFile.grey)),
                    child: Column(children: <Widget>[
                      getHelpContentRow(false, null,
                          plunesStrings.bookingFailure, 14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          plunesStrings.wrongContactDetails,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          plunesStrings.appointmentDelayed,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          plunesStrings.cancellingAppointment,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null, plunesStrings.smsOtpIssues,
                          14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                    ])))
          ],
        ),
        widget.getDividerRow(context, 0, 0, 0),
        Column(
          children: <Widget>[
            getHelpContentRow(true, plunesImages.onlineSolIcon,
                plunesStrings.onlineSolution, 15, FontWeight.w600),
            widget.getDividerRow(context, 0, 0, 0),
            Visibility(
                visible: isOnlineSolution,
                child: Container(
                    color: Color(
                        CommonMethods.getColorHexFromStr(colorsFile.grey)),
                    child: Column(children: <Widget>[
                      getHelpContentRow(false, null,
                          plunesStrings.questionsNotAns, 14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null,
                          plunesStrings.notHappyWithRes, 14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null,
                          plunesStrings.paymentIssues, 14, FontWeight.normal),
                    ])))
          ],
        ),
        widget.getDividerRow(context, 0, 0, 0),
        Column(
          children: <Widget>[
            getHelpContentRow(true, plunesImages.feedbackIcon,
                plunesStrings.feedBacks, 15, FontWeight.w600),
            widget.getDividerRow(context, 0, 0, 0),
            Visibility(
                visible: isFeedback,
                child: Container(
                    color: Color(
                        CommonMethods.getColorHexFromStr(colorsFile.grey)),
                    child: Column(children: <Widget>[
                      getHelpContentRow(
                          false,
                          null,
                          plunesStrings.feedBackNotPublished,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          plunesStrings.unableWriteFeedBack,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null,
                          plunesStrings.bookingFailure, 14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          plunesStrings.wantEditFeedBack,
                          14,
                          FontWeight.normal),
                    ])))
          ],
        ),
        widget.getDividerRow(context, 0, 0, 0),
        Container(
          alignment: Alignment.topCenter,
          padding:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 4),
          child: Text('OR',
              style: TextStyle(
                fontSize: AppConfig.mediumFont,
              )),
        ),
        Container(child: _callWidget(), alignment: Alignment.topCenter)
      ],
    );
  }

  onTapAction(String _title) {
    setState(() {
      if (_title == plunesStrings.bookingAppointments) {
        booking = !booking;
        isOnlineSolution = false;
        isFeedback = false;
      } else if (_title == plunesStrings.onlineSolution) {
        isOnlineSolution = !isOnlineSolution;
        booking = false;
        isFeedback = false;
      } else if (_title == plunesStrings.feedBacks) {
        isFeedback = !isFeedback;
        isOnlineSolution = false;
        booking = false;
      } else if (_title == plunesStrings.bookingFailure) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.bookingFailure;
      } else if (_title == plunesStrings.wrongContactDetails) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.wrongContactDetails;
      } else if (_title == plunesStrings.appointmentDelayed) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.appointmentDelayed;
      } else if (_title == plunesStrings.cancellingAppointment) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.cancellingAppointment;
      } else if (_title == plunesStrings.smsOtpIssues) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.smsOtpIssues;
      } else if (_title == plunesStrings.questionsNotAns) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.questionsNotAns;
      } else if (_title == plunesStrings.notHappyWithRes) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.notHappyWithRes;
      } else if (_title == plunesStrings.paymentIssues) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.paymentIssues;
      } else if (_title == plunesStrings.feedBackNotPublished) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.feedBackNotPublished;
      } else if (_title == plunesStrings.unableWriteFeedBack) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.unableWriteFeedBack;
      } else if (_title == plunesStrings.wantEditFeedBack) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = plunesStrings.wantEditFeedBack;
      }
    });
  }

  submit() async {
    if (_descriptionController.text.trim().isEmpty) {
      widget.showInSnackBar(PlunesStrings.queryCantBeEmpty,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
      return;
    }
    isPopupShowing = false;
    _setState();
    var result = await _docHosMainInsightBloc
        .helpDocHosQuery("$title : ${_descriptionController.text.trim()}");
    if (result is RequestSuccess && mounted) {
      CustomWidgets().helpThankYou(context);
    } else if (result is RequestFailed && mounted) {
      showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets().getInformativePopup(
                message:
                    result.failureCause ?? plunesStrings.somethingWentWrong,
                globalKey: _scaffoldKey);
          });
    }
  }

  @override
  dialogCallBackFunction(String action) {
    if (action == 'CANCEL') {
      setState(() {
        isPopupShowing = false;
        _descriptionController.text = '';
      });
    } else
      submit();
  }

  Widget _callWidget() {
    return InkWell(
      onTap: () {
        String num = _helpNumber;
        if (_helpLineNumberModel != null &&
            _helpLineNumberModel.number != null &&
            _helpLineNumberModel.number.isNotEmpty) {
          num = _helpLineNumberModel.number;
        }
        LauncherUtil.launchUrl("tel://$num");
        return;
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Call us at: ',
                style: TextStyle(
                  fontSize: AppConfig.largeFont,
                )),
            Text(_helpLineNumberModel?.number ?? _helpNumber,
                style: TextStyle(
                    fontSize: AppConfig.largeFont,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                    color: PlunesColors.SPARKLINGGREEN)),
          ],
        ),
      ),
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  void _getHelpLineNumber() async {
    var result = await _userBloc.getHelplineNumber();
    if (result is RequestSuccess) {
      _helpLineNumberModel = result.response;
    }
    _setState();
  }
}
