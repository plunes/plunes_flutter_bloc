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
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 7,
            vertical: AppConfig.verticalBlockSize * 5),
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
                  ? Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 6,
                          vertical: AppConfig.verticalBlockSize * 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(PlunesStrings.thankYouMessage,
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                  color: PlunesColors.BLACKCOLOR)),
                          Padding(
                            padding: EdgeInsets.only(
                                top: AppConfig.horizontalBlockSize * 6),
                          ),
                          Text(PlunesStrings.helpQuerySuccessMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.extraLargeFont,
                                  fontWeight: FontWeight.w600,
                                  color: PlunesColors.GREYCOLOR)),
                        ],
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        Container(
                          height: AppConfig.verticalBlockSize * 15,
                          width: AppConfig.horizontalBlockSize * 50,
                          child: Image.asset(PlunesImages.bdSupportImage),
                        ),
                        Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 4),
                            child: Text(PlunesStrings.writeYourConcern,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                ))),
                        SizedBox(
                          height: AppConfig.verticalBlockSize * 1,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _docHosQueryController,
                                keyboardType: TextInputType.text,
                                maxLines: 2,
                                autofocus: true,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 2),
                          child: Text(
                            PlunesStrings.ourTeamWillContactYou,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 4,
                          ),
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
                                  AppConfig.horizontalBlockSize * 6,
                                  PlunesColors.GREENCOLOR,
                                  AppConfig.horizontalBlockSize * 1,
                                  AppConfig.verticalBlockSize * 1.5,
                                  PlunesColors.WHITECOLOR)),
                        ),
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
      ),
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
      widget.showInSnackBar(
          plunesStrings.success, PlunesColors.BLACKCOLOR, _scaffoldKey);
    } else if (result is RequestFailed && mounted) {
      widget.showInSnackBar(
          result.failureCause ?? plunesStrings.somethingWentWrong,
          PlunesColors.BLACKCOLOR,
          _scaffoldKey);
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
        child: Text('Call at: ${_helpLineNumberModel?.number ?? _helpNumber}',
            style: TextStyle(
                fontSize: AppConfig.mediumFont,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.solid,
                decorationThickness: 2.0,
                decorationColor: PlunesColors.BLACKCOLOR)),
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
