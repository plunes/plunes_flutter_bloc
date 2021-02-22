import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/cart_models/cart_main_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class CartProceedScreen extends BaseActivity {
  List<BookingIds> bookingIds;
  num price, credits;

  CartProceedScreen(this.price, this.bookingIds, {this.credits});

  @override
  _CartProceedScreenState createState() => _CartProceedScreenState();
}

class _CartProceedScreenState extends BaseState<CartProceedScreen> {
  User _userData;

  @override
  void initState() {
    _userData = UserManager().getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: widget.getAppBar(context, "Checkout", true),
        body: _getBody(),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget _getBody() {
    return Container(
      color: Color(CommonMethods.getColorHexFromStr("#F9FAFB")),
      child: SingleChildScrollView(
          child: Column(
        children: [
          _getUserNameAndPriceView(),
          _getOtherWidgets(),
        ],
      )),
    );
  }

  Widget _getUserNameAndPriceView() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(CommonMethods.getColorHexFromStr("#4FBF67")),
        Color(CommonMethods.getColorHexFromStr("#88E1A4"))
      ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
      padding: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 5,
          vertical: AppConfig.verticalBlockSize * 2.5),
      child: Row(
        children: [
          Flexible(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Container(
                      height: 55,
                      width: 55,
                      child: ClipOval(
                          child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                        child: CustomWidgets().getImageFromUrl(
                            _userData?.imageUrl ?? "",
                            boxFit: BoxFit.fill),
                      )),
                    ),
                    radius: 27.5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3),
                    child: Text(
                      "Hello, ${_getFirstName()}",
                      style: TextStyle(
                          fontSize: 23,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#FFFFFF"))),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        "Your Total is",
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#FFFFFF"))),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        "\u20B9 ${widget.price}",
                        style: TextStyle(
                            fontSize: 38,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#FFFFFF"))),
                      ),
                    ),
                  ]),
            ),
          )
        ],
      ),
    );
  }

  String _getFirstName() {
    String userName = "User";
    if (_userData.name != null && _userData.name.trim().isNotEmpty) {
      if (_userData.name.split(" ") != null &&
          _userData.name.split(" ").isNotEmpty) {
        userName = _userData.name.split(" ").first;
      } else {
        userName = "";
      }
    }
    return userName;
  }

  Widget _offerWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "Confirm your order and pay",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              "Please make the payment after that you can enjoy the service and benefit of Plunes",
              style: TextStyle(
                  fontSize: 14,
                  color: Color(CommonMethods.getColorHexFromStr("#464646"))),
            ),
          ),
          Container(
            height: 148,
            width: double.infinity,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6))),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              child: CustomWidgets().getImageFromUrl(
                  "https://www.fujixerox.com.vn/-/media/0,-d-,-Global-Assets/Solutions-and-Services/Security/Document-Audit-Trail_web.jpg?h=614&w=932&la=en&hash=64E1FBE5E13B0BAA2A067030184B87CC0B2F1D3F",
                  boxFit: BoxFit.fill),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getOtherWidgets() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 2.5,
          vertical: AppConfig.verticalBlockSize * 1.5),
      child: Column(
        children: [_offerWidget(), _getCartItemsWidget()],
      ),
    );
  }

  Widget _getCartItemsWidget() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: AppConfig.verticalBlockSize * 2.5,
            horizontal: AppConfig.horizontalBlockSize * 4.5),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Id",
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#646464"))),
                    ),
                    Container(
                      child: Text(
                        "PLU23JDJF34",
                        style: TextStyle(
                            fontSize: 18, color: PlunesColors.BLACKCOLOR),
                      ),
                    )
                  ],
                ),
                Expanded(child: Container()),
                Container(
                  child: CustomWidgets().getRoundedButton(
                      "Unpaid",
                      AppConfig.horizontalBlockSize * 8,
                      Color(CommonMethods.getColorHexFromStr("#ECF4F7")),
                      AppConfig.horizontalBlockSize * 5,
                      AppConfig.verticalBlockSize * 1,
                      Color(CommonMethods.getColorHexFromStr("#646464")),
                      borderColor: PlunesColors.SPARKLINGGREEN,
                      hasBorder: false),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 1.4),
              child: DottedLine(
                dashColor: Color(CommonMethods.getColorHexFromStr("#7070706E")),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Services",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(CommonMethods.getColorHexFromStr("#646464"))),
              ),
            ),
            _getCartItemList()
          ],
        ),
      ),
    );
  }

  Widget _getCartItemList() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            CommonMethods.getStringInCamelCase(
                                widget.bookingIds[index]?.service?.name),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 2.0),
                          child: Text(
                            "${widget.bookingIds[index]?.serviceName ?? PlunesStrings.NA}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "\u20B9${widget.bookingIds[index]?.service?.newPrice?.first ?? 0}",
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                    ),
                  )
                ],
              ),
            ),
            widget.bookingIds.length == index
                ? Container()
                : Container(
                    height: 0.5,
                    width: double.infinity,
                    color: PlunesColors.GREYCOLOR,
                  ),
          ],
        );
      },
      itemCount: widget.bookingIds?.length ?? 0,
    );
  }
}
