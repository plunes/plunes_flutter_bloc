import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class AddToCartMainScreen extends BaseActivity {
  @override
  _AddToCartMainScreenState createState() => _AddToCartMainScreenState();
}

class _AddToCartMainScreenState extends BaseState<AddToCartMainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: widget.getAppBar(context, PlunesStrings.myCart, true),
        body: _showBody(),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget _showBody() {
    return Container(
      child: _getMainView(),
    );
  }

  Widget _getMainView() {
    return Column(
      children: <Widget>[Expanded(child: _getCartListView()), _getButtonView()],
    );
  }

  Widget _getCartListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return CustomWidgets().getCartCard();
      },
      itemCount: 6,
    );
  }

  Widget _getButtonView() {
    return Card(
      color: PlunesColors.WHITECOLOR,
      margin: null,
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "Subtotal (4 items): ",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: PlunesColors.BLACKCOLOR,
                      fontSize: 15),
                ),
                Text("\u20B9 1140",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: PlunesColors.GREENCOLOR,
                        fontSize: 15))
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
              child: InkWell(
                onTap: () {},
                onDoubleTap: () {},
                child: CustomWidgets().getRoundedButton(
                    PlunesStrings.payNow,
                    AppConfig.horizontalBlockSize * 8,
                    PlunesColors.WHITECOLOR,
                    AppConfig.horizontalBlockSize * 3,
                    AppConfig.verticalBlockSize * 1,
                    PlunesColors.SPARKLINGGREEN,
                    borderColor: PlunesColors.SPARKLINGGREEN,
                    hasBorder: true),
              ),
            )
          ],
        ),
      ),
    );
  }
}
