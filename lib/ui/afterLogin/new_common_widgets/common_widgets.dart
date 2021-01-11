import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

class CommonWidgets {
  static CommonWidgets _instance;

  CommonWidgets._init();

  factory CommonWidgets() {
    if (_instance == null) {
      _instance = CommonWidgets._init();
    }
    return _instance;
  }

  Widget getPremiumBenefitsWidget() {
    return Card(
      margin: EdgeInsets.only(
          right: AppConfig.horizontalBlockSize * 3.5, bottom: 1.8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
      child: Container(
        width: AppConfig.horizontalBlockSize * 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      "https://media.istockphoto.com/photos/doctor-holding-digital-tablet-at-meeting-room-picture-id1189304032?k=6&m=1189304032&s=612x612&w=0&h=SJPF2M715kIFAKoYHGbb1uAyptbz6Tn7-LxPsm5msPE=",
                      boxFit: BoxFit.cover),
                ),
              ),
            ),
            Expanded(
                flex: 7,
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 4),
                  child: Text(
                    "Get upto 50% off ",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 15),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget getSolutionViewWidget() {
    return Card(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2.8,
          left: AppConfig.horizontalBlockSize * 1.2,
          right: AppConfig.horizontalBlockSize * 1.2),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        children: [
          Container(
            height: AppConfig.verticalBlockSize * 20,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: SizedBox.expand(
                child: CustomWidgets().getImageFromUrl(
                    "https://media.istockphoto.com/photos/doctor-holding-digital-tablet-at-meeting-room-picture-id1189304032?k=6&m=1189304032&s=612x612&w=0&h=SJPF2M715kIFAKoYHGbb1uAyptbz6Tn7-LxPsm5msPE=",
                    boxFit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 3.2,
                right: AppConfig.horizontalBlockSize * 3.2,
                top: AppConfig.verticalBlockSize * 1.2,
                bottom: AppConfig.verticalBlockSize * 2.5),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dr. Atul Mishra",
                          style: TextStyle(
                            fontSize: 20,
                            color: PlunesColors.BLACKCOLOR,
                          ),
                        ),
                        Text(
                          "Fortis Healthcare",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#707070")),
                          ),
                        ),
                      ],
                    )),
                    Container(
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          Text(
                            " 4.5",
                            style: TextStyle(
                              fontSize: 18,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.8),
                ),
                DottedLine(
                  dashColor: Colors.grey,
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Specialization",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#707070"))),
                          ),
                          Text(
                            "Leaser Hair Reduction",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, color: PlunesColors.BLACKCOLOR),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            PlunesStrings.experienceText,
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#707070"))),
                          ),
                          Text(
                            "20 year",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, color: PlunesColors.BLACKCOLOR),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getManualBiddingProfessionalWidget() {
    Widget profWidget = _getProfessionalDetailWidget();
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(2))),
      child: Container(
        child: Stack(
          children: [
            Row(children: [profWidget]),
            Positioned.fill(child: Container(color: Colors.white)),
            Positioned.fill(
              child: Row(
                children: [
                  Container(
                    width: AppConfig.horizontalBlockSize * 25,
                    child: SizedBox.expand(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12)),
                        child: CustomWidgets().getImageFromUrl(
                            "https://media.istockphoto.com/photos/doctor-holding-digital-tablet-at-meeting-room-picture-id1189304032?k=6&m=1189304032&s=612x612&w=0&h=SJPF2M715kIFAKoYHGbb1uAyptbz6Tn7-LxPsm5msPE=",
                            boxFit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: AppConfig.horizontalBlockSize * 25),
                profWidget
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getProfessionalDetailWidget() {
    return Expanded(
        flex: 7,
        child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4,
                vertical: AppConfig.verticalBlockSize * 1.2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dr. Atul Mishra",
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 20,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                          Text(
                            "Fortis Healthcare",
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#707070")),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Image.asset(PlunesImages.greenCheck),
                      height: 20,
                      width: 40,
                    ),
                  ],
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PlunesStrings.experienceText,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#707070"))),
                            ),
                            Text(
                              "20 year",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: PlunesColors.BLACKCOLOR),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                            Text(
                              " 4.5",
                              style: TextStyle(
                                fontSize: 18,
                                color: PlunesColors.BLACKCOLOR,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )));
  }

  Widget getHorizontalProfessionalWidget() {
    Widget profWidget = _getProfessionalDetailWidget();
    return Card(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2.5,
          right: AppConfig.horizontalBlockSize * 3),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(2))),
      child: Container(
        width: AppConfig.horizontalBlockSize * 93,
        child: Stack(
          children: [
            Row(children: [profWidget]),
            Positioned.fill(child: Container(color: Colors.white)),
            Positioned.fill(
              child: Row(
                children: [
                  Container(
                    width: AppConfig.horizontalBlockSize * 25,
                    child: SizedBox.expand(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12)),
                        child: CustomWidgets().getImageFromUrl(
                            "https://media.istockphoto.com/photos/doctor-holding-digital-tablet-at-meeting-room-picture-id1189304032?k=6&m=1189304032&s=612x612&w=0&h=SJPF2M715kIFAKoYHGbb1uAyptbz6Tn7-LxPsm5msPE=",
                            boxFit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppConfig.horizontalBlockSize * 25,
                ),
                profWidget
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getSearchBarForManualBidding(
      {@required final TextEditingController searchController,
      @required final String hintText,
      bool hasFocus = false,
      isRounded = true,
      FocusNode focusNode,
      double searchBarHeight = 6,
      Function onTextClear}) {
    return StatefulBuilder(builder: (context, newState) {
      return Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
            borderRadius: isRounded
                ? BorderRadius.circular(AppConfig.horizontalBlockSize * 10)
                : BorderRadius.horizontal(),
            side: BorderSide(color: PlunesColors.GREYCOLOR, width: 0.2)),
        child: Container(
          height: AppConfig.verticalBlockSize * searchBarHeight,
          padding: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 4,
              right: AppConfig.horizontalBlockSize * 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: Image.asset(
                  PlunesImages.searchIcon,
                  color: PlunesColors.BLACKCOLOR,
                  width: AppConfig.verticalBlockSize * 3.0,
                  height: AppConfig.verticalBlockSize * 3.25,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  focusNode: focusNode,
                  autofocus: hasFocus,
                  maxLines: 1,
                  style: TextStyle(
                      color: PlunesColors.BLACKCOLOR,
                      fontSize: AppConfig.mediumFont),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#B1B1B1")),
                          fontSize: 16)),
                ),
              ),
              searchController.text.trim().isEmpty
                  ? Container()
                  : InkWell(
                      onTap: () {
                        searchController.text = "";
                        newState(() {});
                        if (onTextClear != null) {
                          onTextClear();
                        }
                      },
                      child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.clear,
                            color: Colors.green,
                          )),
                    )
            ],
          ),
        ),
      );
    });
  }
}
