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
class DiscoverMoreFacility extends BaseActivity {
  @override
  _DiscoverMoreFacilityState createState() => _DiscoverMoreFacilityState();
}

class _DiscoverMoreFacilityState extends BaseState<DiscoverMoreFacility> {
  TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: widget.getAppBar(
              context, PlunesStrings.discoverFacilityNearYou, true),
          body: _getBody(),
        ),
        top: false,
        bottom: false);
  }

  Widget _getBody() {
    return Container(
      child: Column(
        children: [
          // Container(
          //   margin: EdgeInsets.symmetric(
          //       vertical: AppConfig.verticalBlockSize * 1.5,
          //       horizontal: AppConfig.horizontalBlockSize * 5),
          //   child: CommonWidgets().getSearchBarForManualBidding(
          //       searchController: _searchController,
          //       isRounded: true,
          //       hintText: "Search the desired service"),
          // ),
          Expanded(
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
                    maxChildSize: 0.88,
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
                                        CommonMethods.getColorHexFromStr(
                                            "#CDCDCD")),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              SizedBox(
                                  height: AppConfig.verticalBlockSize * 2.8),
                              _getProfessionalsWidget(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          _getContinueButton()
        ],
      ),
    );
  }

  Widget _getContinueButton() {
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

  Widget _getProfessionalsWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 0.8,
                bottom: AppConfig.verticalBlockSize * 1.2),
            child: Text(
              PlunesStrings.selectedFacilities,
              style: TextStyle(fontSize: 20, color: PlunesColors.BLACKCOLOR),
            ),
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getChildren(),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 0.8,
                bottom: AppConfig.verticalBlockSize * 1.2),
            child: Text(
              PlunesStrings.chooseFacilities,
              style: TextStyle(fontSize: 20, color: PlunesColors.BLACKCOLOR),
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // return CommonWidgets().getManualBiddingProfessionalWidget();
            },
            itemCount: 6,
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }

  List<Widget> _getChildren() {
    List<Widget> widgets = [];
    for (int index = 0; index < 6; index++) {
      // widgets.add(CommonWidgets().getHorizontalProfessionalWidget());
    }
    return widgets;
  }
}
