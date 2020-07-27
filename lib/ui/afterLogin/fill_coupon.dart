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

class _FillCouponState extends BaseState<FillCoupon> {
  TextEditingController _couponController;
  CouponBloc _couponBloc;
  CouponTextResponseModel _couponTextResponseModel;
  String _failureCause;

  @override
  void initState() {
    _couponBloc = CouponBloc();
    _getCouponText();
    _couponController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _couponBloc?.dispose();
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
          return StreamBuilder<RequestState>(
              builder: (context, snapShot) {
                if (snapShot.data is RequestInProgress) {
                  return CustomWidgets().getProgressIndicator();
                } else if (snapShot.data is RequestSuccess) {
                  RequestSuccess requestSuccess = snapShot.data;
                  _couponTextResponseModel = requestSuccess.response;
                  _couponBloc.addIntoCouponTextProviderStream(null);
                } else if (snapShot.data is RequestFailed) {
                  RequestFailed requestFailed = snapShot.data;
                  _failureCause = requestFailed.failureCause;
                  _couponBloc.addIntoCouponTextProviderStream(null);
                }
                return (_couponTextResponseModel == null ||
                        _couponTextResponseModel.success == null ||
                        !(_couponTextResponseModel.success))
                    ? CustomWidgets().errorWidget(_failureCause)
                    : _getCouponWidget();
              },
              stream: _couponBloc.couponTextStream,
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
                  top: AppConfig.verticalBlockSize * 8,
                  bottom: AppConfig.verticalBlockSize * 1),
              child: Text(
                PlunesStrings.enterYourCode,
                style: TextStyle(color: PlunesColors.GREYCOLOR, fontSize: 20),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 4,
              ),
              child: StreamBuilder<RequestState>(
                  stream: _couponBloc.baseStream,
                  builder: (context, snapshot) {
                    if (snapshot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    } else if (snapshot.data is RequestSuccess) {
                      _couponBloc.addIntoStream(null);
                      Future.delayed(Duration(milliseconds: 200)).then(
                          (value) => _showMessages('failedObj.failureCause'));
                    } else if (snapshot.data is RequestFailed) {
                      RequestFailed failedObj = snapshot.data;
                      _couponBloc.addIntoStream(null);
                      Future.delayed(Duration(milliseconds: 200))
                          .then((value) => _openSuccessDialog());
                    }
                    return InkWell(
                      onTap: () {
                        if (_couponController.text.trim().isEmpty) {
                          _showMessages(PlunesStrings.pleaseEnterYourCoupon);
                          _couponBloc.addIntoStream(null);
                          return;
                        }
                        _couponBloc
                            .sendCouponDetails(_couponController.text.trim());
                      },
                      onDoubleTap: () {},
                      child: CustomWidgets().getRoundedButton(
                          plunesStrings.submit,
                          AppConfig.horizontalBlockSize * 6,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 1,
                          AppConfig.verticalBlockSize * 1.5,
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
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConfig.horizontalBlockSize * 5)),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      onDoubleTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.close,
                          color: PlunesColors.GREYCOLOR,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      width: AppConfig.horizontalBlockSize * 30,
                      height: AppConfig.verticalBlockSize * 15,
                      child: Image.asset(PlunesImages.couponImage)),
                  SizedBox(height: 10),
                  Text("Coupon Applied Successfully!"),
                  SizedBox(height: 20),
                  SizedBox(height: AppConfig.verticalBlockSize * 1),
                  FlatButton(
                      onPressed: () => Navigator.pop(context, true),
                      color: PlunesColors.GREENCOLOR,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: Container(
                        width: AppConfig.horizontalBlockSize * 20,
                        child: Text(
                          "Ok",
                          style: TextStyle(color: PlunesColors.WHITECOLOR),
                          textAlign: TextAlign.center,
                        ),
                      )),
//                    ],
//                  )
                ],
              ),
            ),
          );
        }).then((value) {
      _couponController.clear();
    });
  }

  _showMessages(String message) {
    widget.showInSnackBar(message, PlunesColors.BLACKCOLOR, scaffoldKey);
  }

  void _getCouponText() {
    _couponBloc.getCouponText();
  }
}
