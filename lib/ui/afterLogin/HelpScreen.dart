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
        appBar: widget.getAppBar(context, plunesStrings.help, true),
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
            ((plunesStrings.bookingAppointments == _title && booking) ||
                    (plunesStrings.onlineSolution == _title &&
                        isOnlineSolution) ||
                    (plunesStrings.feedBacks == _title && isFeedback))
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
                      getHelpContentRow(false, null, plunesStrings.bookingFailure,
                          14, FontWeight.normal),
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
                      getHelpContentRow(false, null, plunesStrings.paymentIssues,
                          14, FontWeight.normal),
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
                      getHelpContentRow(false, null, plunesStrings.bookingFailure,
                          14, FontWeight.normal),
                      widget.getDividerRow(context, 0, 0, 0),
                      getHelpContentRow(false, null,
                          plunesStrings.wantEditFeedBack, 14, FontWeight.normal),
                    ])))
          ],
        ),
        widget.getDividerRow(context, 0, 0, 0),
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
          context, this, plunesStrings.success, plunesStrings.successfullySent);
    } else
      widget.showInSnackBar(
          result['message'] != null
              ? result['message']
              : plunesStrings.somethingWentWrong,
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
