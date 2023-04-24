import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/coupon_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class FillCoupon extends BaseActivity {
  static const tag = '/coupons';

  @override
  _FillCouponState createState() => _FillCouponState();
}

// class _FillCouponState extends BaseState<FillCoupon> {
class _FillCouponState extends State<FillCoupon> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController? _couponController;
  CouponBloc? _couponBloc;
  CouponTextResponseModel? _couponTextResponseModel;
  String? _failureCause;
  late ConfettiController _confettiController;

  @override
  void initState() {
    _couponBloc = CouponBloc();
    _getCouponText();
    _confettiController = ConfettiController(
      duration: const Duration(microseconds: 2),
    );
    _couponController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _couponBloc?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _unFocus();
        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: Colors.black),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                _unFocus();
                Navigator.pop(context, false);
              },
            ),
            title: widget.createTextViews(plunesStrings.coupons, 18,
                colorsFile.black, TextAlign.center, FontWeight.w500)),
        body: Builder(builder: (context) {
          return StreamBuilder<RequestState?>(
              builder: (context, snapShot) {
                if (snapShot.data is RequestInProgress) {
                  return CustomWidgets().getProgressIndicator();
                } else if (snapShot.data is RequestSuccess) {
                  RequestSuccess requestSuccess = snapShot.data as RequestSuccess;
                  _couponTextResponseModel = requestSuccess.response;
                  _couponBloc!.addIntoCouponTextProviderStream(null);
                } else if (snapShot.data is RequestFailed) {
                  RequestFailed requestFailed = snapShot.data as RequestFailed;
                  _failureCause = requestFailed.failureCause;
                  _couponBloc!.addIntoCouponTextProviderStream(null);
                }
                return (_couponTextResponseModel == null ||
                        _couponTextResponseModel!.success == null ||
                        !_couponTextResponseModel!.success!)
                    ? CustomWidgets().errorWidget(_failureCause,
                        onTap: () => _getCouponText())
                    : _getCouponWidget();
              },
              stream: _couponBloc!.couponTextStream,
              initialData: RequestInProgress());
        }),
      ),
    );
  }

  Widget _getCouponWidget() {
    return SingleChildScrollView(
      reverse: true,
      child: Container(
        width: double.infinity,
        margin:
            EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 30,
                  vertical: AppConfig.verticalBlockSize * 5),
              child: CustomWidgets().getRoundedButton(
                  PlunesStrings.hurry,
                  0.0,
                  PlunesColors.GREENCOLOR,
                  AppConfig.horizontalBlockSize * 3,
                  AppConfig.verticalBlockSize * 2,
                  PlunesColors.WHITECOLOR),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 1),
              child: Text(
                _couponTextResponseModel?.data?.message ?? PlunesStrings.NA,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Container(
                  margin: EdgeInsetsDirectional.only(
                      top: AppConfig.verticalBlockSize * 4),
                  width: AppConfig.horizontalBlockSize * 40,
                  height: AppConfig.verticalBlockSize * 18,
                  child: Image.asset(PlunesImages.couponImage)),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 5,
                  bottom: AppConfig.verticalBlockSize * 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: PlunesStrings.enterYourCode,
                          hintStyle: TextStyle(
                              color: PlunesColors.GREYCOLOR,
                              fontSize: AppConfig.largeFont)),
                      controller: _couponController,
                      style: TextStyle(
                          fontSize: AppConfig.largeFont,
                          color: PlunesColors.BLACKCOLOR),
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 4,
              ),
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 30),
              child: StreamBuilder<RequestState>(
                  stream: _couponBloc!.baseStream,
                  builder: (context, snapshot) {
                    if (snapshot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    } else if (snapshot.data is RequestSuccess) {
                      _couponBloc!.addIntoStream(null);
                      Future.delayed(Duration(milliseconds: 200))
                          .then((value) => _openSuccessDialog());
                    } else if (snapshot.data is RequestFailed) {
                      RequestFailed? failedObj = snapshot.data as RequestFailed?;
                      _couponBloc!.addIntoStream(null);
                      Future.delayed(Duration(milliseconds: 200)).then((value) {
                        _openFailureDialog();
                        // _confettiController.play();
                      });
                    }
                    return InkWell(
                      onTap: () {
                        if (_couponController!.text.trim().isEmpty) {
                          _showMessages(PlunesStrings.pleaseEnterYourCoupon);
                          _couponBloc!.addIntoStream(null);
                          return;
                        }
                        _couponBloc!
                            .sendCouponDetails(_couponController!.text.trim());
                      },
                      onDoubleTap: () {},
                      child: CustomWidgets().getRoundedButton(
                          plunesStrings.submit,
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 0,
                          AppConfig.verticalBlockSize * 1.2,
                          PlunesColors.WHITECOLOR),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _unFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _openSuccessDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConfig.horizontalBlockSize * 5)),
            child: Stack(
              children: <Widget>[
                // ConfettiWidget(
                //   confettiController: _confettiController,
                //   numberOfParticles: 10,
                //   // blastDirection: 5,
                //   blastDirectionality: BlastDirectionality.explosive,
                //   shouldLoop: true,
                //   colors: const [
                //     Colors.green,
                //     Colors.blue,
                //     Colors.red,
                //     Colors.amber,
                //     Colors.purple,
                //     Colors.pink,
                //     Colors.orange
                //   ],
                // ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 4,
                              horizontal: AppConfig.horizontalBlockSize * 6),
                          height: AppConfig.verticalBlockSize * 12,
                          child: Image.asset(PlunesImages.couponImage)),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 3,
                            left: AppConfig.horizontalBlockSize * 6,
                            right: AppConfig.horizontalBlockSize * 6),
                        child: Text(
                          "Coupon Applied Successfully!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR,
                              fontSize: AppConfig.smallFont),
                        ),
                      ),
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        color: PlunesColors.GREYCOLOR,
                      ),
                      Container(
                        height: AppConfig.verticalBlockSize * 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16)),
                          child: ElevatedButton(
                              // highlightColor: Colors.transparent,
                              // hoverColor: Colors.transparent,
                              // splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                              // focusColor: Colors.transparent,
                              onPressed: () {
                                Navigator.of(context).pop();
                                // _confettiController.stop();
                              },
                              child: Container(
                                  height: AppConfig.verticalBlockSize * 6,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      "OK",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont,
                                          color: PlunesColors.SPARKLINGGREEN),
                                    ),
                                  ))),
                        ),
                      ),
                      // CustomWidgets().getSingleCommonButton(context, 'Ok')
//                  Container(
//                    height: 0.5,
//                    width: double.infinity,
//                    color: PlunesColors.GREYCOLOR,
//                    margin:
//                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 5),
//                  ),
//                  FlatButton(
//                      splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                      highlightColor:
//                          PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                      focusColor: PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                      onPressed: () => Navigator.pop(context, true),
//                      child: Container(
//                          width: double.infinity,
//                          child: Text(
//                            'OK',
//                            textAlign: TextAlign.center,
//                            style: TextStyle(
//                                fontSize: AppConfig.mediumFont,
//                                color: PlunesColors.SPARKLINGGREEN),
//                          ))),
                    ],
                  ),
                ),
              ],
            ),
//            Container(
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Container(
//                    alignment: Alignment.topRight,
//                    child: InkWell(
//                      onTap: () => Navigator.of(context).pop(),
//                      onDoubleTap: () {},
//                      child: Padding(
//                        padding: const EdgeInsets.all(10),
//                        child: Icon(
//                          Icons.close,
//                          color: PlunesColors.GREYCOLOR,
//                        ),
//                      ),
//                    ),
//                  ),
//                  Container(
//                      width: AppConfig.horizontalBlockSize * 30,
//                      height: AppConfig.verticalBlockSize * 15,
//                      child: Image.asset(PlunesImages.couponImage)),
//                  SizedBox(height: 10),
//                  Text("Coupon Applied Successfully!"),
//                  SizedBox(height: AppConfig.verticalBlockSize * 1),
//                  FlatButton(
//                      onPressed: () => Navigator.pop(context, true),
//                      color: PlunesColors.GREENCOLOR,
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(50)),
//                      child: Container(
//                        width: AppConfig.horizontalBlockSize * 20,
//                        child: Text(
//                          "Ok",
//                          style: TextStyle(color: PlunesColors.WHITECOLOR),
//                          textAlign: TextAlign.center,
//                        ),
//                      )),
//                ],
//              ),
//            ),
          );
        }).then((value) {
      _couponController!.clear();
    });
  }

  _openFailureDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConfig.horizontalBlockSize * 5)),
            child: SingleChildScrollView(
              child: Column(
//              mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: AppConfig.verticalBlockSize * 3),
                      height: AppConfig.verticalBlockSize * 10,
                      child: Image.asset(PlunesImages.cardExpired)),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 6,
                        right: AppConfig.horizontalBlockSize * 6,
                        bottom: AppConfig.verticalBlockSize * 3),
                    child: Text(
                      PlunesStrings.oops,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppConfig.mediumFont,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 3,
                        right: AppConfig.horizontalBlockSize * 3,
                        bottom: AppConfig.verticalBlockSize * 5,
                        top: AppConfig.verticalBlockSize * 2),
                    child: Text(
                      PlunesStrings.couponExpired,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.smallFont,
                          color: PlunesColors.GREYCOLOR),
                    ),
                  ),
                  CustomWidgets().getSingleCommonButton(context, 'Ok')
//                  Container(
//                    height: 0.5,
//                    width: double.infinity,
//                    color: PlunesColors.GREYCOLOR,
//                    margin:
//                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
//                  ),
//                  FlatButton(
//                      splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                      highlightColor:
//                          PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                      focusColor: PlunesColors.SPARKLINGGREEN.withOpacity(.2),
//                      onPressed: () => Navigator.of(context).pop(),
//                      child: Container(
//                          width: double.infinity,
//                          child: Text(
//                            "OK",
//                            textAlign: TextAlign.center,
//                            style: TextStyle(
//                                fontSize: AppConfig.mediumFont,
//                                color: PlunesColors.SPARKLINGGREEN),
//                          ))),

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
//            Container(
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Container(
//                    alignment: Alignment.topRight,
//                    child: InkWell(
//                      onTap: () => Navigator.of(context).pop(),
//                      onDoubleTap: () {},
//                      child: Padding(
//                        padding: const EdgeInsets.all(10),
//                        child: Icon(
//                          Icons.close,
//                          color: PlunesColors.GREYCOLOR,
//                        ),
//                      ),
//                    ),
//                  ),
//                  Container(
//                      width: AppConfig.horizontalBlockSize * 30,
//                      height: AppConfig.verticalBlockSize * 15,
//                      child: Image.asset(PlunesImages.couponImage)),
//                  SizedBox(height: 10),
//                  Text("Coupon Applied Successfully!"),
//                  SizedBox(height: AppConfig.verticalBlockSize * 1),
//                  FlatButton(
//                      onPressed: () => Navigator.pop(context, true),
//                      color: PlunesColors.GREENCOLOR,
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(50)),
//                      child: Container(
//                        width: AppConfig.horizontalBlockSize * 20,
//                        child: Text(
//                          "Ok",
//                          style: TextStyle(color: PlunesColors.WHITECOLOR),
//                          textAlign: TextAlign.center,
//                        ),
//                      )),
//                ],
//              ),
//            ),
          );
        }).then((value) {
      _couponController!.clear();
    });
  }

  _showMessages(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey!);
  }

  void _getCouponText() {
    _failureCause = null;
    _couponBloc!.getCouponText();
  }
}
