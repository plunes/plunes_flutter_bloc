import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';

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
                            "Experience",
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
}
