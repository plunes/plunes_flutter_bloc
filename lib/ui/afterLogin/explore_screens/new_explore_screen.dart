import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/explore/explore_main_model.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class NewExploreScreen extends BaseActivity {
  @override
  _NewExploreScreenState createState() => _NewExploreScreenState();
}

class _NewExploreScreenState extends BaseState<NewExploreScreen> {
  String kDefaultImageUrl =
      'https://goqii.com/blog/wp-content/uploads/Doctor-Consultation.jpg';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            key: scaffoldKey,
            body: _getBody(),
          ),
        ));
  }

  Widget _getBody() {
    return Container(
      child: Column(
        children: [
          _getAppAndSearchBarWidget(),
          Expanded(
              child: Container(
            child: _getScrollableBody(),
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
          )),
        ],
      ),
    );
  }

  Widget _getAppAndSearchBarWidget() {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 2.5,
            right: AppConfig.horizontalBlockSize * 2.5,
            top: AppConfig.verticalBlockSize * 0.6,
            bottom: AppConfig.horizontalBlockSize * 1.8),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(19, 184, 126, 0.19),
            Color.fromRGBO(255, 255, 255, 0),
          ],
        )),
        child: Column(
          children: [
            ListTile(
              // leading: Container(
              //     padding: EdgeInsets.all(5),
              //     child: IconButton(
              //       onPressed: () {
              //         Navigator.pop(context, false);
              //         return;
              //       },
              //       icon: Icon(
              //         Icons.arrow_back_ios,
              //         color: PlunesColors.BLACKCOLOR,
              //       ),
              //     )),
              title: Text(
                PlunesStrings.knowYourProcedure,
                textAlign: TextAlign.center,
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 0.8,
                  bottom: AppConfig.verticalBlockSize * 2.8),
              child: Card(
                elevation: 4.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24))),
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 6,
                      vertical: AppConfig.verticalBlockSize * 1.6),
                  child: Text(
                    "Search Service",
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getScrollableBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _getSectionTwoWidget(null),
          _getDoctorVideoSection(),
          _getCustomerVideos(),
          _getReviewSection()
        ],
      ),
    );
  }

  Widget _getSectionTwoWidget(Section3 sectionTwo) {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              sectionTwo?.heading ?? "Offers",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          CarouselSlider.builder(
            itemCount: 3,
            options: CarouselOptions(
                height: AppConfig.verticalBlockSize * 28,
                aspectRatio: 16 / 9,
                initialPage: 0,
                enableInfiniteScroll: false,
                pageSnapping: true,
                reverse: false,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                scrollDirection: Axis.horizontal),
            itemBuilder: (BuildContext context, int itemIndex) => Container(
              width: double.infinity,
              child: InkWell(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomWidgets()
                        .getImageFromUrl(kDefaultImageUrl, boxFit: BoxFit.fill),
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<Object>(
              // stream: _streamController.stream,
              builder: (context, snapshot) {
            return Container(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 0.5),
              child: DotsIndicator(
                dotsCount: 3,
                // dotsCount: sectionTwo.elements.length > 8
                //     ? 8
                //     : sectionTwo.elements.length,
                position: 0,
                axis: Axis.horizontal,
                decorator: _decorator,
                onTap: (pos) {
                  // _controller.animateToPage(pos.toInt(),
                  //     curve: Curves.easeInOut,
                  //     duration: Duration(milliseconds: 300));
                  // _currentDotPosition = pos;
                  // _streamController?.add(null);
                  // return;
                },
              ),
            );
          })
        ],
      ),
    );
  }

  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

  Widget _getDoctorVideoSection() {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "See What Doctor's saying about us",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          Container(
            child: _getVideoWidget(),
            height: AppConfig.verticalBlockSize * 38,
          ),
        ],
      ),
    );
  }

  Widget _getCustomerVideos() {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Happy customers",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          Container(
            child: _getVideoWidget(),
            height: AppConfig.verticalBlockSize * 38,
          ),
        ],
      ),
    );
  }

  Widget _getReviewSection() {
    return Container(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "People availing Discount",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          Card(
              elevation: 10.0,
              margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                height: AppConfig.verticalBlockSize * 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        flex: 3,
                        child: Column(
                          children: [
                            Flexible(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: AppConfig.verticalBlockSize * 0.2,
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 0.8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12)),
                                  child: CustomWidgets()
                                      .getImageFromUrl(kDefaultImageUrl),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: AppConfig.verticalBlockSize * 2,
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 3),
                              child: CustomWidgets().getRoundedButton(
                                  PlunesStrings.book,
                                  AppConfig.horizontalBlockSize * 8,
                                  PlunesColors.GREENCOLOR,
                                  AppConfig.horizontalBlockSize * 5,
                                  AppConfig.verticalBlockSize * 1,
                                  PlunesColors.WHITECOLOR,
                                  borderColor: PlunesColors.SPARKLINGGREEN,
                                  hasBorder: false),
                            )
                          ],
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 0.2),
                            child: Text(
                              CommonMethods.getStringInCamelCase(
                                  "Rahul Shukla"),
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                color: Color(0xff4E4E4E),
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "PRP",
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(
                                color: Color(0xff4E4E4E),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Flexible(
                            child: Container(
                              child: Text(
                                "dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda",
                                softWrap: true,
                                maxLines: 4,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xff4E4E4E),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _getVideoWidget() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        children: [
          Container(
            child: ClipRRect(
              child: CustomWidgets()
                  .getImageFromUrl(kDefaultImageUrl, boxFit: BoxFit.fill),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10)),
            ),
            height: AppConfig.verticalBlockSize * 26,
            width: double.infinity,
          ),
          Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 2,
                right: AppConfig.horizontalBlockSize * 2,
                top: AppConfig.verticalBlockSize * 0.3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "An Introduction to PLUNES",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: AppConfig.mediumFont,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 2,
                  right: AppConfig.horizontalBlockSize * 2,
                  top: AppConfig.verticalBlockSize * 0.3),
              child: Text(
                "Discover the best prices from top rated doctors for any medical treatment in Delhi, Noida, Gurgaon, Dwarka at exclusive discounts.",
                maxLines: 2,
                style: TextStyle(
                  fontSize: AppConfig.verySmallFont,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
