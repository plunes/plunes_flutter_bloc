import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';

// ignore: must_be_immutable
class ViewSolutionsScreen extends BaseActivity {
  @override
  _ViewSolutionsScreenState createState() => _ViewSolutionsScreenState();
}

class _ViewSolutionsScreenState extends BaseState<ViewSolutionsScreen> {
  bool _shouldExpand;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: _getBody(),
        appBar: PreferredSize(
            child: Card(
                color: Colors.white,
                elevation: 3.0,
                margin:
                    EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        padding:
                            EdgeInsets.all(AppConfig.verticalBlockSize * 2),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                            return;
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: PlunesColors.BLACKCOLOR,
                          ),
                        )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Book Your Procedure",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR, fontSize: 16),
                        ),
                        Text(
                          "Laser Hair Removal",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#727272")),
                              fontSize: 14),
                        ),
                      ],
                    ),
                    Container(),
                    Container(),
                    Container(),
                  ],
                )),
            preferredSize:
                Size(double.infinity, AppConfig.verticalBlockSize * 8)),
      ),
    );
  }

  Widget _getBody() {
    return Container(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(28.443, 78.3222)),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, controller) {
              return Card(
                margin: EdgeInsets.all(0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 3.8,
                      vertical: AppConfig.verticalBlockSize * 2.8),
                  child: ListView(
                    controller: controller,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 38,
                            right: AppConfig.horizontalBlockSize * 38),
                        height: 3,
                        decoration: BoxDecoration(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#707070")),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      _getBenefitsWidget(),
                      _getSolutionListWidget(),
                      _getDiscoverPriceButton()
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _getBenefitsWidget() {
    // ?Container(margin: EdgeInsets.only(top: AppConfig.verticalBlockSize*1.8))
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.8),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Premium Benefits for Our Users",
              style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 18,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) =>
                  CommonWidgets().getPremiumBenefitsWidget(),
              itemCount: 5,
            ),
          )
        ],
      ),
    );
  }

  Widget _getSolutionListWidget() {
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 5) {
            return Container(
              padding: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2),
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 20,
                  vertical: AppConfig.verticalBlockSize * 1),
              child: CustomWidgets().getRoundedButton(
                  PlunesStrings.discoverMoreFacilityButtonText,
                  AppConfig.horizontalBlockSize * 8,
                  PlunesColors.WHITECOLOR,
                  AppConfig.horizontalBlockSize * 3,
                  AppConfig.verticalBlockSize * 1,
                  Color(CommonMethods.getColorHexFromStr("#25B281")),
                  borderColor:
                      Color(CommonMethods.getColorHexFromStr("#25B281")),
                  hasBorder: true),
            );
          }
          return CommonWidgets().getSolutionViewWidget();
        },
        itemCount: 6,
        shrinkWrap: true,
      ),
    );
  }

  Widget _getDiscoverPriceButton() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 28,
            right: AppConfig.horizontalBlockSize * 28,
            bottom: AppConfig.verticalBlockSize * 2),
        child: CustomWidgets().getRoundedButton(
            PlunesStrings.discoverPrice,
            AppConfig.horizontalBlockSize * 8,
            PlunesColors.PARROTGREEN,
            AppConfig.horizontalBlockSize * 3,
            AppConfig.verticalBlockSize * 1,
            PlunesColors.WHITECOLOR,
            hasBorder: false),
      ),
    );
  }
}
