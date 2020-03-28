import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';

class HelpScreen extends BaseActivity {
  static const tag = '/helpScreen';

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _descriptionController = new TextEditingController();
  var globalHeight, globalWidth, title = '';

  bool booking = false,
      isOnlineSolution = false,
      isFeedback = false,
      isPopupShowing = false;

  @override
  void dispose() {
    bloc.disposeHelpApiStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: widget.getAppBar(context, stringsFile.help, true),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            getBodyView(),
            isPopupShowing
                ? CommonMethods.messageSubmitDialog(
                    context, title, _descriptionController, this)
                : Container()
          ],
        ));
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
                        : Container(),
                  )
                : Container(),
            Expanded(
                child: widget.createTextViews(_title, fontSize,
                    colorsFile.black0, TextAlign.start, fontWeight)),
            ((stringsFile.bookingAppointments == _title && booking) ||
                    (stringsFile.onlineSolution == _title &&
                        isOnlineSolution) ||
                    (stringsFile.feedBacks == _title && isFeedback))
                ? Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  )
                : Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.black,
                  )
          ],
        ),
      ),
    );
  }

  Widget getBodyView() {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          width: globalWidth,
          color: Color(CommonMethods.getColorHexFromStr(colorsFile.grey)),
          child: widget.createTextViews(stringsFile.iHaveIssueWith, 14,
              colorsFile.black0, TextAlign.start, FontWeight.normal),
        ),
        Column(
          children: <Widget>[
            getHelpContentRow(true, assetsImageFile.appointCalIcon,
                stringsFile.bookingAppointments, 15, FontWeight.w600),
            widget.getDividerRow(context, 0, 0, 0),
            Visibility(
                visible: booking,
                child: Container(
                    color: Color(
                        CommonMethods.getColorHexFromStr(colorsFile.grey)),
                    child: Column(children: <Widget>[
                      getHelpContentRow(false, null, stringsFile.bookingFailure,
                          14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          stringsFile.wrongContactDetails,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          stringsFile.appointmentDelayed,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          stringsFile.cancellingAppointment,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null, stringsFile.smsOtpIssues,
                          14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                    ])))
          ],
        ),
        widget.getDividerRow(context, 0, 0, 0),
        Column(
          children: <Widget>[
            getHelpContentRow(true, assetsImageFile.onlineSolIcon,
                stringsFile.onlineSolution, 15, FontWeight.w600),
            widget.getDividerRow(context, 0, 0, 0),
            Visibility(
                visible: isOnlineSolution,
                child: Container(
                    color: Color(
                        CommonMethods.getColorHexFromStr(colorsFile.grey)),
                    child: Column(children: <Widget>[
                      getHelpContentRow(false, null,
                          stringsFile.questionsNotAns, 14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null,
                          stringsFile.notHappyWithRes, 14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null, stringsFile.paymentIssues,
                          14, FontWeight.normal),
                    ])))
          ],
        ),
        widget.getDividerRow(context, 0, 0, 0),
        Column(
          children: <Widget>[
            getHelpContentRow(true, assetsImageFile.feedbackIcon,
                stringsFile.feedBacks, 15, FontWeight.w600),
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
                          stringsFile.feedBackNotPublished,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(
                          false,
                          null,
                          stringsFile.unableWriteFeedBack,
                          14,
                          FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null, stringsFile.bookingFailure,
                          14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null,
                          stringsFile.wantEditFeedBack, 14, FontWeight.normal),
                    ])))
          ],
        ),
        widget.getDividerRow(context, 0, 0, 0),
      ],
    );
  }

  onTapAction(String _title) {
    setState(() {
      if (_title == stringsFile.bookingAppointments) {
        booking = !booking;
        isOnlineSolution = false;
        isFeedback = false;
      } else if (_title == stringsFile.onlineSolution) {
        isOnlineSolution = !isOnlineSolution;
        booking = false;
        isFeedback = false;
      } else if (_title == stringsFile.feedBacks) {
        isFeedback = !isFeedback;
        isOnlineSolution = false;
        booking = false;
      } else if (_title == stringsFile.bookingFailure) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.bookingFailure;
      } else if (_title == stringsFile.wrongContactDetails) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.wrongContactDetails;
      } else if (_title == stringsFile.appointmentDelayed) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.appointmentDelayed;
      } else if (_title == stringsFile.cancellingAppointment) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.cancellingAppointment;
      } else if (_title == stringsFile.smsOtpIssues) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.smsOtpIssues;
      } else if (_title == stringsFile.questionsNotAns) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.questionsNotAns;
      } else if (_title == stringsFile.notHappyWithRes) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.notHappyWithRes;
      } else if (_title == stringsFile.paymentIssues) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.paymentIssues;
      } else if (_title == stringsFile.feedBackNotPublished) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.feedBackNotPublished;
      } else if (_title == stringsFile.unableWriteFeedBack) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.unableWriteFeedBack;
      } else if (_title == stringsFile.wantEditFeedBack) {
        isPopupShowing = true;
        _descriptionController.text = '';
        title = stringsFile.wantEditFeedBack;
      }
    });
  }

  submit() async {
    bloc.fetchHelpResult(
        context, this, '$title : ${_descriptionController.text}');
    bloc.helpApiFetcher.listen((_result) {
      delay(_result);
    });
  }

  Future delay(result) async {
    if (result['success'] != null && result['success']) {
      isPopupShowing = false;
      CommonMethods.commonDialog(
          context, this, stringsFile.success, stringsFile.successfullySent);
    } else
      widget.showInSnackBar(
          result['message'] != null
              ? result['message']
              : stringsFile.somethingWentWrong,
          Colors.red,
          _scaffoldKey);
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
}
