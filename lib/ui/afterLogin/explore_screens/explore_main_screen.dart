import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';

// ignore: must_be_immutable
class ExploreMainScreen extends BaseActivity {
  @override
  _ExploreMainScreenState createState() => _ExploreMainScreenState();
}

class _ExploreMainScreenState extends BaseState<ExploreMainScreen> {
  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

  double _currentDotPosition = 0.0;
  final CarouselController _controller = CarouselController();
  StreamController _streamController;

  @override
  void initState() {
    _currentDotPosition = 0.0;
    _streamController = StreamController.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    _whyPlunesWidgets = [];
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      appBar: widget.getAppBar(context, PlunesStrings.explore, true),
    );
  }

  List<Widget> _whyPlunesWidgets = [
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(PlunesImages.zeroCostEmiIcon),
            height: AppConfig.verticalBlockSize * 3,
            width: AppConfig.horizontalBlockSize * 6,
            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
          ),
          Text(
            "Zero cost EMI",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
          )
        ],
      ),
    ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(PlunesImages.paymentRefIcon),
            height: AppConfig.verticalBlockSize * 3,
            width: AppConfig.horizontalBlockSize * 6,
            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
          ),
          Text(
            "100% Payment Refundable",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
          )
        ],
      ),
    ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(PlunesImages.firstConslFree),
            height: AppConfig.verticalBlockSize * 3,
            width: AppConfig.horizontalBlockSize * 6,
            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
          ),
          Text(
            "First consultation free",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
          )
        ],
      ),
    ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(PlunesImages.prefTimeIcon),
            height: AppConfig.verticalBlockSize * 3,
            width: AppConfig.horizontalBlockSize * 6,
            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
          ),
          Text(
            "Preferred timing as per your availability",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
          )
        ],
      ),
    ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(PlunesImages.freeTeleConsImg),
            height: AppConfig.verticalBlockSize * 3,
            width: AppConfig.horizontalBlockSize * 6,
            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
          ),
          Text(
            "Free telephonic consultation",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
          )
        ],
      ),
    ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(PlunesImages.plunesVerifiedImg),
            height: AppConfig.verticalBlockSize * 3,
            width: AppConfig.horizontalBlockSize * 6,
            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
          ),
          Text(
            "Plunes verified",
            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
          )
        ],
      ),
    ),
  ];

  Widget _getBody() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _getWhyPlunesView(),
          _getFestiveOfferWidget(),
          _getTopFacilityWidget(),
          _bookFacilityDirectlyWidget(),
          _getPeopleAvailingDiscountWidget(),
        ],
      ),
    );
  }

  Widget _getWhyPlunesView() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
          left: AppConfig.horizontalBlockSize * 4,
          right: AppConfig.horizontalBlockSize * 4,
          top: AppConfig.verticalBlockSize * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            PlunesStrings.whyPlunes,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 8,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return _whyPlunesWidgets[index];
              },
              itemCount: _whyPlunesWidgets.length,
            ),
          )
        ],
      ),
    );
  }

  Widget _getFestiveOfferWidget() {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Grand Festive offers",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 4),
          ),
          CarouselSlider.builder(
            itemCount: 5,
            carouselController: _controller,
            options: CarouselOptions(
                height: AppConfig.verticalBlockSize * 25,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                pageSnapping: true,
                reverse: false,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, _) {
                  if (_currentDotPosition.toInt() != index) {
                    _currentDotPosition = index.toDouble();
                    _streamController?.add(null);
                  }
                }),
            itemBuilder: (BuildContext context, int itemIndex) => Container(
              color: Colors.grey,
              child: Stack(
                children: <Widget>[
                  CustomWidgets().getImageFromUrl(
                      'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80'),
                  Center(child: Text(itemIndex.toString()))
                ],
              ),
            ),
          ),
          StreamBuilder<Object>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                return Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
                  child: DotsIndicator(
                    dotsCount: 5,
                    position: _currentDotPosition,
                    axis: Axis.horizontal,
                    decorator: _decorator,
                    onTap: (pos) {
                      _controller.animateToPage(pos.toInt(),
                          curve: Curves.easeInOut,
                          duration: Duration(milliseconds: 300));
                      _currentDotPosition = pos;
                      _streamController?.add(null);
                      return;
                    },
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget _getTopFacilityWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Top facilities Today Near You",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 1.5,
                horizontal: AppConfig.horizontalBlockSize * 4),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 35,
            margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Card(
                  color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    width: AppConfig.horizontalBlockSize * 48,
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 3,
                        vertical: AppConfig.verticalBlockSize * 1.2),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: AppConfig.horizontalBlockSize * 40,
                          height: AppConfig.verticalBlockSize * 15,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomWidgets().getImageFromUrl(
                                'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
                                boxFit: BoxFit.fill),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Fortis Hospital Price dropped by some percent Price dropped by some percent Price dropped by some percent",
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 1.5,
                              horizontal: AppConfig.horizontalBlockSize * 4),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Price dropped by some percent Price dropped by some percent Price dropped by some percent Price dropped by some percent",
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 13),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 0.4,
                              horizontal: AppConfig.horizontalBlockSize * 4),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: 5,
            ),
          )
        ],
      ),
    );
  }

  Widget _bookFacilityDirectlyWidget() {
    return Container(
      padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
      height: AppConfig.verticalBlockSize * 10,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: AppConfig.horizontalBlockSize * 90,
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 4),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      return;
                    },
                    onDoubleTap: () {},
                    child: 1 == 1
                        ? CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              height: AppConfig.horizontalBlockSize * 14,
                              width: AppConfig.horizontalBlockSize * 14,
                              child: ClipOval(
                                  child: CustomWidgets().getImageFromUrl(
                                      'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
                                      boxFit: BoxFit.fill,
                                      placeHolderPath:
                                          PlunesImages.doc_placeholder)),
                            ),
                            radius: AppConfig.horizontalBlockSize * 7,
                          )
                        : CustomWidgets().getProfileIconWithName(
                            "name",
                            14,
                            14,
                          ),
                  ),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Hair Transplant",
                          maxLines: 1,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "5 slots booked 8 remaining !",
                          maxLines: 1,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  )),
                  Text(
                    "View",
                    style: TextStyle(
                        color: PlunesColors.GREENCOLOR,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )
                ],
              ),
            ),
          );
        },
        itemCount: 4,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _getPeopleAvailingDiscountWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "People Availing Discounts",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 1.5,
                horizontal: AppConfig.horizontalBlockSize * 4),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 35,
            margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SolutionBiddingScreen(
                                searchQuery: "Botox Treatment")));
                  },
                  child: Card(
                    color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      width: AppConfig.horizontalBlockSize * 48,
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 3,
                          vertical: AppConfig.verticalBlockSize * 1.2),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            color: Colors.transparent,
                            child: CustomWidgets().getImageFromUrl(
                                'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
                                boxFit: BoxFit.fill),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Botox Treatment",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 1.5,
                                horizontal: AppConfig.horizontalBlockSize * 4),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Price dropped by some percent Price dropped by some percent Price dropped by some percent Price dropped by some percent",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13),
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 0.4,
                                horizontal: AppConfig.horizontalBlockSize * 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: 5,
            ),
          )
        ],
      ),
    );
  }
}
