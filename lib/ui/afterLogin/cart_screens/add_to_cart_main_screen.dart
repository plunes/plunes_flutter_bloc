import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/cart_screens/patient_details_edit_popup_screen.dart';

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
          key: scaffoldKey),
      top: false,
      bottom: false,
    );
  }

  Widget _showBody() {
    return Container(
      color: PlunesColors.WHITECOLOR,
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
        return getCartCard(index);
      },
      itemCount: 6,
    );
  }

  Widget _getButtonView() {
    return Card(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.all(0),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 2,
                  left: AppConfig.horizontalBlockSize * 32,
                  right: AppConfig.horizontalBlockSize * 32),
              child: InkWell(
                onTap: () {},
                onDoubleTap: () {},
                child: CustomWidgets().getRoundedButton(
                    PlunesStrings.payNow,
                    AppConfig.horizontalBlockSize * 8,
                    PlunesColors.GREENCOLOR,
                    AppConfig.horizontalBlockSize * 3,
                    AppConfig.verticalBlockSize * 1,
                    PlunesColors.WHITECOLOR,
                    borderColor: PlunesColors.SPARKLINGGREEN,
                    hasBorder: true),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getCartCard(int index) {
    return Card(
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 3.0,
      margin: EdgeInsets.only(
          left: AppConfig.horizontalBlockSize * 2.5,
          right: AppConfig.horizontalBlockSize * 2.5,
          top: AppConfig.verticalBlockSize * 1.8),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 2.5,
                vertical: AppConfig.verticalBlockSize * 1.6),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: AppConfig.verticalBlockSize * 10.5,
                      width: AppConfig.horizontalBlockSize * 16.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Colors.red),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            gradient: new LinearGradient(
                                colors: [Color(0xffababab), Color(0xff686868)],
                                begin: FractionalOffset.topCenter,
                                end: FractionalOffset.bottomCenter,
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp)),
                        child: Text(
                            ("name" != ''
                                    ? CommonMethods.getInitialName("name")
                                    : '')
                                .toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: AppConfig.extraLargeFont - 4,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Dr. Nikita Tyagi",
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR, fontSize: 16),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 1.1),
                              child: Text(
                                "Botox Treatment",
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontSize: 15),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 1.1),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      height: AppConfig.verticalBlockSize * 3,
                                      width: AppConfig.horizontalBlockSize * 5,
                                      child: Image.asset(
                                          plunesImages.locationIcon)),
                                  Text(
                                    "3.6 kms",
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: PlunesColors.GREYCOLOR,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      flex: 4,
                    ),
                    Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Icon(
                                  Icons.star,
                                  color: PlunesColors.GREENCOLOR,
                                ),
                                Text(
                                  "4.0" ?? PlunesStrings.NA,
                                  style: TextStyle(
                                      color: PlunesColors.BLACKCOLOR,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 2),
                              child: Text("\u20B9 1140.00",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: PlunesColors.BLACKCOLOR,
                                      fontSize: 17)),
                            )
                          ],
                        ))
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: Row(
                    children: List.generate(
                        500 ~/ 4,
                        (index) => Expanded(
                              child: Container(
                                color: index % 2 == 0
                                    ? Colors.transparent
                                    : PlunesColors.LIGHTGREYCOLOR,
                                height: 2,
                              ),
                            )),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Botox Treatment",
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 15),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1.1),
                            child: Text(
                              "29/2/2020, 11:30 AM",
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR, fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.all(2.5),
                            height: AppConfig.verticalBlockSize * 4,
                            width: AppConfig.horizontalBlockSize * 6,
                            child: Image.asset(
                              PlunesImages.binImage,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return EditPatientDetailScreen();
                              });
                        },
                        onDoubleTap: () {},
                        child: Container(
                          margin: EdgeInsets.all(2.5),
                          height: AppConfig.verticalBlockSize * 4,
                          width: AppConfig.horizontalBlockSize * 6,
                          child:
                              Image.asset(PlunesImages.availability_edit_image),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          index % 2 == 0
              ? Container(
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 1.8,
                      vertical: AppConfig.verticalBlockSize * 1.5),
                  decoration: BoxDecoration(
                      color: Color(CommonMethods.getColorHexFromStr("#EFEFEF")),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0))),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                          child: Container(
                              margin: EdgeInsets.only(right: 3),
                              child: Text(
                                  PlunesStrings.priceExpiredNegotiateAgain))),
                      InkWell(
                        onTap: () {},
                        onDoubleTap: () {},
                        child: CustomWidgets().getRoundedButton(
                            PlunesStrings.negotiate,
                            AppConfig.horizontalBlockSize * 8,
                            PlunesColors.GREENCOLOR,
                            AppConfig.horizontalBlockSize * 3,
                            AppConfig.verticalBlockSize * 1,
                            PlunesColors.WHITECOLOR,
                            borderColor: PlunesColors.SPARKLINGGREEN,
                            hasBorder: true),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 2.5,
                      vertical: AppConfig.verticalBlockSize * 1.5),
                  decoration: BoxDecoration(
                      color: Color(CommonMethods.getColorHexFromStr("#EFEFEF")),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0))),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        PlunesImages.validForOneHourOnlyWatch,
                        scale: 3,
                      ),
                      Text("  valid for 53:00 only")
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                )
        ],
      ),
    );
  }
}
