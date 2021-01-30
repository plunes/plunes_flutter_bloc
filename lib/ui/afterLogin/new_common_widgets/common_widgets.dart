import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/models/new_solution_model/professional_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
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

  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

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

  Widget getSolutionViewWidget(
      Services service, CatalogueData catalogueData, Function openProfile) {
    return Card(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2.8,
          left: AppConfig.horizontalBlockSize * 1.2,
          right: AppConfig.horizontalBlockSize * 1.2),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: InkWell(
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          if (openProfile != null) {
            openProfile();
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
              height: AppConfig.verticalBlockSize * 20,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      service?.imageUrl ?? "",
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
                            CommonMethods.getStringInCamelCase(service?.name),
                            style: TextStyle(
                              fontSize: 20,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                          // Text(
                          //   CommonMethods.getStringInCamelCase(service?),
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     color: Color(
                          //         CommonMethods.getColorHexFromStr("#707070")),
                          //   ),
                          // ),
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
                              " ${service?.rating?.toStringAsFixed(1) ?? 4.5}",
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
                              catalogueData?.speciality ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: PlunesColors.BLACKCOLOR),
                            )
                          ],
                        ),
                      ),
                      (service.experience == null || service.experience <= 0)
                          ? Container()
                          : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    PlunesStrings.experienceText,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#707070"))),
                                  ),
                                  Text(
                                    "${service?.experience} year",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.BLACKCOLOR),
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
      ),
    );
  }

  Widget getSolutionViewWidgetPopUp(Services service,
      CatalogueData catalogueData, Function openProfile, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2.8,
          left: AppConfig.horizontalBlockSize * 1.2,
          right: AppConfig.horizontalBlockSize * 1.2),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: InkWell(
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          if (openProfile != null) {
            openProfile();
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
              height: AppConfig.verticalBlockSize * 20,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      service?.imageUrl ?? "",
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
                            CommonMethods.getStringInCamelCase(service?.name),
                            style: TextStyle(
                              fontSize: 20,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                          // Text(
                          //   CommonMethods.getStringInCamelCase(service?),
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     color: Color(
                          //         CommonMethods.getColorHexFromStr("#707070")),
                          //   ),
                          // ),
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
                              " ${service?.rating?.toStringAsFixed(1) ?? 4.5}",
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
                              catalogueData?.speciality ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: PlunesColors.BLACKCOLOR),
                            )
                          ],
                        ),
                      ),
                      (service.experience == null || service.experience <= 0)
                          ? Container()
                          : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    PlunesStrings.experienceText,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#707070"))),
                                  ),
                                  Text(
                                    "${service?.experience} year",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.BLACKCOLOR),
                                  )
                                ],
                              ),
                            ),
                    ],
                  )
                ],
              ),
            ),
            CustomWidgets().getSingleCommonButton(context, PlunesStrings.close)
          ],
        ),
      ),
    );
  }

  Widget getSolutionViewWidgetForHospitalDoc(Services service,
      CatalogueData catalogueData, Function openProfile, int docIndex) {
    return Card(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2.8,
          left: AppConfig.horizontalBlockSize * 1.2,
          right: AppConfig.horizontalBlockSize * 1.2),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: InkWell(
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          if (openProfile != null) {
            openProfile();
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
              height: AppConfig.verticalBlockSize * 20,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      service.doctors[docIndex].imageUrl ?? "",
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
                            CommonMethods.getStringInCamelCase(
                                service.doctors[docIndex].name),
                            style: TextStyle(
                              fontSize: 20,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                          Text(
                            CommonMethods.getStringInCamelCase(service.name),
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
                              " ${service?.rating?.toStringAsFixed(1) ?? 4.5}",
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
                              catalogueData?.speciality ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: PlunesColors.BLACKCOLOR),
                            )
                          ],
                        ),
                      ),
                      (service.doctors[docIndex].experience == null ||
                              service.doctors[docIndex].experience <= 0)
                          ? Container()
                          : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    PlunesStrings.experienceText,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#707070"))),
                                  ),
                                  Text(
                                    "${service.doctors[docIndex]?.experience} year",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.BLACKCOLOR),
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
      ),
    );
  }

  Widget getSolutionViewWidgetForHospitalDocPopup(
      Services service,
      CatalogueData catalogueData,
      Function openProfile,
      int docIndex,
      BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2.8,
          left: AppConfig.horizontalBlockSize * 1.2,
          right: AppConfig.horizontalBlockSize * 1.2),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: InkWell(
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          if (openProfile != null) {
            openProfile();
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
              height: AppConfig.verticalBlockSize * 20,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      service.doctors[docIndex].imageUrl ?? "",
                      placeHolderPath: PlunesImages.doc_placeholder,
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
                            CommonMethods.getStringInCamelCase(
                                service.doctors[docIndex].name),
                            style: TextStyle(
                              fontSize: 20,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                          Text(
                            CommonMethods.getStringInCamelCase(service.name),
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
                              " ${service?.rating?.toStringAsFixed(1) ?? 4.5}",
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
                              catalogueData?.speciality ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: PlunesColors.BLACKCOLOR),
                            )
                          ],
                        ),
                      ),
                      (service.doctors[docIndex].experience == null ||
                              service.doctors[docIndex].experience <= 0)
                          ? Container()
                          : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    PlunesStrings.experienceText,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#707070"))),
                                  ),
                                  Text(
                                    "${service.doctors[docIndex]?.experience} year",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.BLACKCOLOR),
                                  )
                                ],
                              ),
                            ),
                    ],
                  )
                ],
              ),
            ),
            CustomWidgets().getSingleCommonButton(context, PlunesStrings.close)
          ],
        ),
      ),
    );
  }

  Widget getProfessionalWidgetForSearchDesiredServiceScreen(
      int index, ProfData profData, String specialization,
      {Function onTap}) {
    return Card(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2.8,
          left: AppConfig.horizontalBlockSize * 1.2,
          right: AppConfig.horizontalBlockSize * 1.2),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: InkWell(
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
              height: AppConfig.verticalBlockSize * 20,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      profData?.imageUrl ?? "",
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
                            CommonMethods.getStringInCamelCase(profData?.name),
                            style: TextStyle(
                              fontSize: 20,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                          Text(
                            "",
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
                              " ${profData?.rating?.toStringAsFixed(1) ?? 4.5}",
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
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Specialization",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#707070"))),
                              ),
                              Text(
                                specialization ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: PlunesColors.BLACKCOLOR),
                              )
                            ],
                          ),
                        ),
                        (profData != null &&
                                profData.userType != null &&
                                profData.userType.toLowerCase() ==
                                    Constants.doctor.toString().toLowerCase())
                            ? Container()
                            : Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "View Profile",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.GREENCOLOR),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  (profData != null &&
                          profData.userType != null &&
                          profData.userType.toLowerCase() ==
                              Constants.doctor.toString().toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 2.1),
                        )
                      : Container(),
                  (profData != null &&
                          profData.userType != null &&
                          profData.userType.toLowerCase() ==
                              Constants.doctor.toString().toLowerCase())
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Experience",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#707070"))),
                                  ),
                                  Text(
                                    "${(profData.experience != null && profData.experience > 0) ? profData.experience : 1} year",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.BLACKCOLOR),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "View Profile",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: PlunesColors.GREENCOLOR),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container()
                ],
              ),
            )
          ],
        ),
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

  Widget getBookProfessionalWidget(
      Services service, Function openProfile, Function bookAppointment) {
    int _currentIndex = 0;
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (openProfile != null) {
                openProfile();
              }
            },
            onDoubleTap: () {},
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Container(
              height: AppConfig.verticalBlockSize * 25,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(service.imageUrl ?? "",
                      boxFit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 3.2,
                right: AppConfig.horizontalBlockSize * 3.2,
                top: AppConfig.verticalBlockSize * 1.2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        CommonMethods.getStringInCamelCase(service?.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          color: PlunesColors.BLACKCOLOR,
                        ),
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
                            " ${service?.rating?.toStringAsFixed(1) ?? 4.5}",
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      ),
                    ),
                    (service.experience != null && service.experience > 0)
                        ? Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(left: 3),
                              child: Text(
                                "${service.experience} Years Experience",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: PlunesColors.BLACKCOLOR,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                DottedLine(dashColor: Colors.grey),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: AppConfig.verticalBlockSize * 0.5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (service.price != null &&
                                    service.price.isNotEmpty &&
                                    service.newPrice != null &&
                                    service.newPrice.isNotEmpty &&
                                    service.price.first !=
                                        service.newPrice.first)
                                ? RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: "MRP \u20B9",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr(
                                                    "#A2A2A2"))),
                                      ),
                                      TextSpan(
                                          text:
                                              "${service.price.first?.toStringAsFixed(1) ?? ""}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#A2A2A2")))),
                                    ]))
                                : Container(),
                            (service.newPrice != null &&
                                    service.newPrice.isNotEmpty)
                                ? Container(
                                    margin: EdgeInsets.only(top: 2.5),
                                    child: RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: "\u20B9",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                          TextSpan(
                                              text:
                                                  "${service.newPrice.first?.toStringAsFixed(1) ?? ""}",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                        ])),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.only(left: 3),
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            if (bookAppointment != null) {
                              bookAppointment();
                            }
                          },
                          onDoubleTap: () {},
                          child: CustomWidgets().getRoundedButton(
                              PlunesStrings.book,
                              AppConfig.horizontalBlockSize * 8,
                              PlunesColors.PARROTGREEN,
                              AppConfig.horizontalBlockSize * 4,
                              AppConfig.verticalBlockSize * 1,
                              PlunesColors.WHITECOLOR,
                              hasBorder: false),
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: (service.homeCollection != null &&
                                service.homeCollection)
                            ? Container(
                                child: Text(
                                  PlunesStrings.homeCollectionAvailable,
                                  style: TextStyle(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#A2A2A2")),
                                      fontSize: 12),
                                ),
                              )
                            : Container(),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 2),
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {},
                            onDoubleTap: () {},
                            child: Padding(
                              child: Text(
                                "Check Insurance",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#25B281"))),
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                DottedLine(dashColor: Colors.grey),
                Container(
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 1.8)),
                1 == 1
                    ? StatefulBuilder(builder: (context, newState) {
                        return Column(
                          children: [
                            Container(
                              height: AppConfig.verticalBlockSize * 10,
                              child: CarouselSlider.builder(
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        border: Border.all(
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#25B281")),
                                            width: 0.8)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            AppConfig.horizontalBlockSize * 4,
                                        vertical:
                                            AppConfig.verticalBlockSize * 1.5),
                                    margin: EdgeInsets.only(
                                        right: AppConfig.horizontalBlockSize *
                                            2.3),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("FUI",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: PlunesColors.BLACKCOLOR,
                                                fontSize: 18)),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(top: 3),
                                          child: Text("Technique",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#515151")),
                                                  fontSize: 16)),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                    height: AppConfig.verticalBlockSize * 12,
                                    aspectRatio: 16 / 9,
                                    initialPage: 0,
                                    enableInfiniteScroll: false,
                                    pageSnapping: true,
                                    reverse: false,
                                    enlargeCenterPage: true,
                                    viewportFraction: 1.0,
                                    autoPlay: true,
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (index, _) {
                                      // if (_currentDotPosition.toInt() != index) {
                                      //   _currentDotPosition = index.toDouble();
                                      //   _streamController?.add(null);
                                      // }
                                      newState(() {
                                        _currentIndex = index;
                                      });
                                    }),
                                itemCount: 4,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 0.5),
                              child: DotsIndicator(
                                dotsCount: 4,
                                position: _currentIndex?.toDouble(),
                                axis: Axis.horizontal,
                                decorator: _decorator,
                              ),
                            )
                          ],
                        );
                      })
                    : Container(),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: 1 != 1
                      ? InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "View More ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#01D35A"))),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#01D35A")),
                                    size: 15)
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("View Less ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#01D35A")))),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#01D35A")),
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getBookProfessionalPopup(Services service, Function openProfile,
      Function bookAppointment, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (openProfile != null) {
                openProfile();
              }
            },
            onDoubleTap: () {},
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Container(
              height: AppConfig.verticalBlockSize * 25,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(service.imageUrl ?? "",
                      boxFit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 3.2,
                right: AppConfig.horizontalBlockSize * 3.2,
                top: AppConfig.verticalBlockSize * 1.2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        CommonMethods.getStringInCamelCase(service?.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          color: PlunesColors.BLACKCOLOR,
                        ),
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
                            " ${service?.rating?.toStringAsFixed(1) ?? 4.5}",
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      ),
                    ),
                    (service.experience != null && service.experience > 0)
                        ? Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(left: 3),
                              child: Text(
                                "${service.experience} Years Experience",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: PlunesColors.BLACKCOLOR,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                DottedLine(
                  dashColor: Colors.grey,
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: AppConfig.verticalBlockSize * 0.5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (service.price != null &&
                                    service.price.isNotEmpty &&
                                    service.newPrice != null &&
                                    service.newPrice.isNotEmpty &&
                                    service.price.first !=
                                        service.newPrice.first)
                                ? RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: "MRP \u20B9",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr(
                                                    "#A2A2A2"))),
                                      ),
                                      TextSpan(
                                          text:
                                              "${service.price.first?.toStringAsFixed(1) ?? ""}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#A2A2A2")))),
                                    ]))
                                : Container(),
                            (service.newPrice != null &&
                                    service.newPrice.isNotEmpty)
                                ? Container(
                                    margin: EdgeInsets.only(top: 2.5),
                                    child: RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: "\u20B9",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                          TextSpan(
                                              text:
                                                  "${service.newPrice.first?.toStringAsFixed(1) ?? ""}",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                        ])),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.only(left: 3),
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            if (bookAppointment != null) {
                              bookAppointment();
                            }
                          },
                          onDoubleTap: () {},
                          child: CustomWidgets().getRoundedButton(
                              PlunesStrings.book,
                              AppConfig.horizontalBlockSize * 8,
                              PlunesColors.PARROTGREEN,
                              AppConfig.horizontalBlockSize * 4,
                              AppConfig.verticalBlockSize * 1,
                              PlunesColors.WHITECOLOR,
                              hasBorder: false),
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: (service.homeCollection != null &&
                                service.homeCollection)
                            ? Container(
                                child: Text(
                                  PlunesStrings.homeCollectionAvailable,
                                  style: TextStyle(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#A2A2A2")),
                                      fontSize: 12),
                                ),
                              )
                            : Container(),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 2),
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {},
                            onDoubleTap: () {},
                            child: Padding(
                              child: Text(
                                "Check Insurance",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#25B281"))),
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                DottedLine(dashColor: Colors.grey),
                Container(
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 1.8)),
                1 == 1
                    ? Container(
                        height: AppConfig.verticalBlockSize * 10,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  border: Border.all(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#25B281")),
                                      width: 0.8)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppConfig.horizontalBlockSize * 4,
                                  vertical: AppConfig.verticalBlockSize * 1.5),
                              margin: EdgeInsets.only(
                                  right: AppConfig.horizontalBlockSize * 2.3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("FUI",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 18)),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 3),
                                    child: Text("Technique",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#515151")),
                                            fontSize: 16)),
                                  )
                                ],
                              ),
                            );
                          },
                          itemCount: 4,
                        ),
                      )
                    : Container(),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: 1 != 1
                      ? InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "View More ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#01D35A"))),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#01D35A")),
                                    size: 15)
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("View Less ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#01D35A")))),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#01D35A")),
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                )
              ],
            ),
          ),
          CustomWidgets().getSingleCommonButton(context, PlunesStrings.close)
        ],
      ),
    );
  }

  Widget getBookProfessionalWidgetForHospitalDocs(Services service,
      Function openProfile, int docIndex, Function bookAppointment) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        children: [
          Container(
            height: AppConfig.verticalBlockSize * 25,
            child: InkWell(
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onDoubleTap: () {},
              onTap: () {
                if (openProfile != null) {
                  openProfile();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      service.doctors[docIndex]?.imageUrl ?? "",
                      placeHolderPath: PlunesImages.doc_placeholder,
                      boxFit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 3.2,
                right: AppConfig.horizontalBlockSize * 3.2,
                top: AppConfig.verticalBlockSize * 1.2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        CommonMethods.getStringInCamelCase(
                            service.doctors[docIndex].name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      ),
                    ),
                    (service.doctors[docIndex].rating != null &&
                            service.doctors[docIndex].rating > 0)
                        ? Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Text(
                                  "${service.doctors[docIndex].rating?.toStringAsFixed(1) ?? 4.5}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: PlunesColors.BLACKCOLOR,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container()
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        CommonMethods.getStringInCamelCase(service.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      ),
                    ),
                    (service.doctors[docIndex].experience != null &&
                            service.doctors[docIndex].experience > 0)
                        ? Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(left: 3),
                              child: Text(
                                "${service.doctors[docIndex].experience} Years Experience",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: PlunesColors.BLACKCOLOR,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                DottedLine(
                  dashColor: Colors.grey,
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: AppConfig.verticalBlockSize * 0.5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (service.doctors[docIndex].price != null &&
                                    service
                                        .doctors[docIndex].price.isNotEmpty &&
                                    service.doctors[docIndex].newPrice !=
                                        null &&
                                    service.doctors[docIndex].newPrice
                                        .isNotEmpty &&
                                    service.doctors[docIndex].price.first !=
                                        service
                                            .doctors[docIndex].newPrice.first)
                                ? RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: "MRP \u20B9",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr(
                                                    "#A2A2A2"))),
                                      ),
                                      TextSpan(
                                          text:
                                              "${service.doctors[docIndex].price.first?.toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#A2A2A2")))),
                                    ]))
                                : Container(),
                            (service.doctors[docIndex].newPrice != null &&
                                    service
                                        .doctors[docIndex].newPrice.isNotEmpty)
                                ? Container(
                                    margin: EdgeInsets.only(top: 2.5),
                                    child: RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: "\u20B9",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                          TextSpan(
                                              text:
                                                  "${service.doctors[docIndex].newPrice.first?.toStringAsFixed(1)}",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                        ])),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.only(left: 3),
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            if (bookAppointment != null) {
                              bookAppointment();
                            }
                          },
                          onDoubleTap: () {},
                          child: CustomWidgets().getRoundedButton(
                              PlunesStrings.book,
                              AppConfig.horizontalBlockSize * 8,
                              PlunesColors.PARROTGREEN,
                              AppConfig.horizontalBlockSize * 4,
                              AppConfig.verticalBlockSize * 1,
                              PlunesColors.WHITECOLOR,
                              hasBorder: false),
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child:
                            (service.doctors[docIndex].homeCollection != null &&
                                    service.doctors[docIndex].homeCollection)
                                ? Container(
                                    margin: EdgeInsets.only(top: 2.5),
                                    child: Text(
                                      PlunesStrings.homeCollectionAvailable,
                                      style: TextStyle(
                                          color: Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#A2A2A2")),
                                          fontSize: 12),
                                    ),
                                  )
                                : Container(),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 2),
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {},
                            onDoubleTap: () {},
                            child: Padding(
                              child: Text(
                                "Check Insurance",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#25B281"))),
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                DottedLine(dashColor: Colors.grey),
                Container(
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 1.8)),
                1 == 1
                    ? Container(
                        height: AppConfig.verticalBlockSize * 10,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  border: Border.all(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#25B281")),
                                      width: 0.8)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppConfig.horizontalBlockSize * 4,
                                  vertical: AppConfig.verticalBlockSize * 1.5),
                              margin: EdgeInsets.only(
                                  right: AppConfig.horizontalBlockSize * 2.3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("FUI",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 18)),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 3),
                                    child: Text("Technique",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#515151")),
                                            fontSize: 16)),
                                  )
                                ],
                              ),
                            );
                          },
                          itemCount: 4,
                        ),
                      )
                    : Container(),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: 1 != 1
                      ? InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "View More ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#01D35A"))),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#01D35A")),
                                    size: 15)
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("View Less ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#01D35A")))),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#01D35A")),
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getBookProfessionalPopupForHospitalDoc(
      Services service,
      Function openProfile,
      int docIndex,
      Function bookAppointment,
      BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        children: [
          Container(
            height: AppConfig.verticalBlockSize * 25,
            child: InkWell(
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onDoubleTap: () {},
              onTap: () {
                if (openProfile != null) {
                  openProfile();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: SizedBox.expand(
                  child: CustomWidgets().getImageFromUrl(
                      service.doctors[docIndex]?.imageUrl ?? "",
                      placeHolderPath: PlunesImages.doc_placeholder,
                      boxFit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 3.2,
                right: AppConfig.horizontalBlockSize * 3.2,
                top: AppConfig.verticalBlockSize * 1.2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        CommonMethods.getStringInCamelCase(
                            service.doctors[docIndex].name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      ),
                    ),
                    (service.doctors[docIndex].rating != null &&
                            service.doctors[docIndex].rating > 0)
                        ? Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Text(
                                  "${service.doctors[docIndex].rating?.toStringAsFixed(1) ?? 4.5}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: PlunesColors.BLACKCOLOR,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container()
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        CommonMethods.getStringInCamelCase(service.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      ),
                    ),
                    (service.doctors[docIndex].experience != null &&
                            service.doctors[docIndex].experience > 0)
                        ? Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(left: 3),
                              child: Text(
                                "${service.doctors[docIndex].experience} Years Experience",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: PlunesColors.BLACKCOLOR,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                DottedLine(
                  dashColor: Colors.grey,
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.8),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: AppConfig.verticalBlockSize * 0.5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (service.doctors[docIndex].price != null &&
                                    service
                                        .doctors[docIndex].price.isNotEmpty &&
                                    service.doctors[docIndex].newPrice !=
                                        null &&
                                    service.doctors[docIndex].newPrice
                                        .isNotEmpty &&
                                    service.doctors[docIndex].price.first !=
                                        service
                                            .doctors[docIndex].newPrice.first)
                                ? RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: "MRP \u20B9",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr(
                                                    "#A2A2A2"))),
                                      ),
                                      TextSpan(
                                          text:
                                              "${service.doctors[docIndex].price.first?.toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#A2A2A2")))),
                                    ]))
                                : Container(),
                            (service.doctors[docIndex].newPrice != null &&
                                    service
                                        .doctors[docIndex].newPrice.isNotEmpty)
                                ? Container(
                                    margin: EdgeInsets.only(top: 2.5),
                                    child: RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: "\u20B9",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                          TextSpan(
                                              text:
                                                  "${service.doctors[docIndex].newPrice.first?.toStringAsFixed(1)}",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color:
                                                      PlunesColors.BLACKCOLOR)),
                                        ])),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.only(left: 3),
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            if (bookAppointment != null) {
                              bookAppointment();
                            }
                          },
                          onDoubleTap: () {},
                          child: CustomWidgets().getRoundedButton(
                              PlunesStrings.book,
                              AppConfig.horizontalBlockSize * 8,
                              PlunesColors.PARROTGREEN,
                              AppConfig.horizontalBlockSize * 4,
                              AppConfig.verticalBlockSize * 1,
                              PlunesColors.WHITECOLOR,
                              hasBorder: false),
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child:
                            (service.doctors[docIndex].homeCollection != null &&
                                    service.doctors[docIndex].homeCollection)
                                ? Container(
                                    margin: EdgeInsets.only(top: 2.5),
                                    child: Text(
                                      PlunesStrings.homeCollectionAvailable,
                                      style: TextStyle(
                                          color: Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#A2A2A2")),
                                          fontSize: 12),
                                    ),
                                  )
                                : Container(),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(left: 2),
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {},
                            onDoubleTap: () {},
                            child: Padding(
                              child: Text(
                                "Check Insurance",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#25B281"))),
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                DottedLine(dashColor: Colors.grey),
                Container(
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 1.8)),
                1 == 1
                    ? Container(
                        height: AppConfig.verticalBlockSize * 10,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  border: Border.all(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#25B281")),
                                      width: 0.8)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppConfig.horizontalBlockSize * 4,
                                  vertical: AppConfig.verticalBlockSize * 1.5),
                              margin: EdgeInsets.only(
                                  right: AppConfig.horizontalBlockSize * 2.3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("FUI",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 18)),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 3),
                                    child: Text("Technique",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#515151")),
                                            fontSize: 16)),
                                  )
                                ],
                              ),
                            );
                          },
                          itemCount: 4,
                        ),
                      )
                    : Container(),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: 1 != 1
                      ? InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "View More ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#01D35A"))),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#01D35A")),
                                    size: 15)
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("View Less ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#01D35A")))),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#01D35A")),
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                )
              ],
            ),
          ),
          CustomWidgets().getSingleCommonButton(context, PlunesStrings.close)
        ],
      ),
    );
  }
}
