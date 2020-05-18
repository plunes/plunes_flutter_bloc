import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/coupon_bloc.dart';
import 'package:plunes/requester/request_states.dart';
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

  @override
  void initState() {
    _couponBloc = CouponBloc();
    _couponController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _couponBloc.dispose();
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
          return SingleChildScrollView(
            reverse: true,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        top: AppConfig.verticalBlockSize * 8,
                        bottom: AppConfig.verticalBlockSize * 1),
                    child: Text(
                      "Enter your coupon here ",
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR, fontSize: 20),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          autofocus: true,
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
                            Future.delayed(Duration(milliseconds: 200))
                                .then((value) => _openSuccessDialog());
                          } else if (snapshot.data is RequestFailed) {
                            RequestFailed failedObj = snapshot.data;
                            _couponBloc.addIntoStream(null);
                            Future.delayed(Duration(milliseconds: 200)).then(
                                (value) =>
                                    _showMessages(failedObj.failureCause));
                          }
                          return InkWell(
                            onTap: () {
                              if (_couponController.text.trim().isEmpty) {
                                _showMessages(
                                    PlunesStrings.pleaseEnterYourCoupon);
                                _couponBloc.addIntoStream(null);
                                return;
                              }
                              _couponBloc.sendCouponDetails(
                                  _couponController.text.trim());
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
        }),
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
                children: <Widget>[
                  Text("Coupon Applied Successfully!"),
                  SizedBox(height: AppConfig.verticalBlockSize * 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            "Ok",
                            style: TextStyle(color: PlunesColors.GREENCOLOR),
                          )),
                    ],
                  )
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
}
