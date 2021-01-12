import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:readmore/readmore.dart';

// ignore: must_be_immutable
class SolutionShowPriceScreen extends BaseActivity {
  @override
  _SolutionShowPriceScreenState createState() =>
      _SolutionShowPriceScreenState();
}

class _SolutionShowPriceScreenState extends BaseState<SolutionShowPriceScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: PlunesColors.WHITECOLOR,
          key: scaffoldKey,
          appBar: _getAppBar(),
          body: _getBody(),
        ),
      ),
      top: false,
      bottom: false,
    );
  }

  PreferredSize _getAppBar() {
    String value = "Valid for 1 hour only";
    return PreferredSize(
        child: Card(
            color: Colors.white,
            elevation: 3.0,
            margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
            child: ListTile(
              leading: Container(
                  padding: EdgeInsets.all(5),
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
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    PlunesStrings.negotiatedSolutions,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        PlunesImages.validForOneHourOnlyWatch,
                        scale: 3,
                      ),
                      Padding(
                        child: RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "7 days" ?? "",
                                    style: TextStyle(
                                        color: PlunesColors.GREENCOLOR,
                                        fontSize: 16)),
                                TextSpan(
                                    text: " only",
                                    style: TextStyle(
                                        color: PlunesColors.GREYCOLOR,
                                        fontSize: 15)),
                              ],
                              text: PlunesStrings.validForOneHour,
                              style: TextStyle(
                                  color: PlunesColors.GREYCOLOR, fontSize: 15)),
                        ),
                        padding: EdgeInsets.only(left: 4.0),
                      )
                    ],
                  )
                ],
              ),
            )),
        preferredSize: Size(double.infinity, AppConfig.verticalBlockSize * 8));
  }

  Widget _getBody() {
    return Container(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(28.443, 78.3222)),
            zoomControlsEnabled: false,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, controller) {
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 1.2,
                  ),
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
                              bottom: AppConfig.verticalBlockSize * 2.8,
                              left: AppConfig.horizontalBlockSize * 38,
                              right: AppConfig.horizontalBlockSize * 38),
                          height: 3,
                          decoration: BoxDecoration(
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#707070")),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        _getTypeOfFacilityWidget(),
                        _getFacilityDefinitionWidget(),
                        _getProfessionalListWidget(),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getProfessionalListWidget() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return CommonWidgets().getBookProfessionalWidget();
        },
        itemCount: 6,
      ),
    );
  }

  Widget _getTypeOfFacilityWidget() {
    return Card(
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shadowColor: Color(CommonMethods.getColorHexFromStr("#00000029")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 5.9,
            vertical: AppConfig.verticalBlockSize * 1.8),
        child: Row(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Laser hair removal",
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
              ),
            )),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      PlunesStrings.viewOnMap,
                      style: TextStyle(
                          color: PlunesColors.GREENCOLOR, fontSize: 16),
                    ),
                    Container(
                      height: AppConfig.verticalBlockSize * 3,
                      width: AppConfig.horizontalBlockSize * 5,
                      child: Image.asset(plunesImages.locationIcon),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getFacilityDefinitionWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.5),
            child: Text(
              "Definition",
              style: TextStyle(
                  fontSize: 14,
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.normal),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.5),
                  child: ReadMoreText(
                    "A Botox treatment is a minimally invasive, safe, effective treatment for fine lines and wrinkles around the eyes. It can also be used on the forehead between the eyes. Botox is priced per unit.",
                    colorClickableText: PlunesColors.SPARKLINGGREEN,
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '  ...read more',
                    trimExpandedText: '  read less',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Color(CommonMethods.getColorHexFromStr("#515151")),
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "2-5 minutes",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.normal),
                      ),
                      Text(
                        "Duration",
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#515151")),
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Depends on case",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.normal),
                      ),
                      Text(
                        "Session",
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#515151")),
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
