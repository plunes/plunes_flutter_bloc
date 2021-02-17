import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/models/new_solution_model/premium_benefits_model.dart';
import 'package:plunes/models/new_solution_model/professional_model.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
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

  final CarouselController _controller = CarouselController();

  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

  Widget getPremiumBenefitsWidget(PremiumBenefitData premiumBenefitData) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.only(
          right: AppConfig.horizontalBlockSize * 3.5, bottom: 1.8),
      // shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //         topLeft: Radius.circular(16),
      //         topRight: Radius.circular(16),
      //         bottomLeft: Radius.circular(16),
      //         bottomRight: Radius.circular(16))),
      child: Container(
        color: Colors.transparent,
        width: 230,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          child: CustomWidgets().getImageFromUrl(
              premiumBenefitData?.titleImage ?? '',
              boxFit: BoxFit.fill),
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
              child: (service != null &&
                      service.professionalPhotos != null &&
                      service.professionalPhotos.isNotEmpty)
                  ? _getImageArrayOfProfessional(service)
                  : ClipRRect(
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
                    dashColor:
                        Color(CommonMethods.getColorHexFromStr("#7070703B")),
                    lineThickness: 1,
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
              child: (service != null &&
                      service.professionalPhotos != null &&
                      service.professionalPhotos.isNotEmpty)
                  ? _getImageArrayOfProfessional(service)
                  : ClipRRect(
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
                    dashColor:
                        Color(CommonMethods.getColorHexFromStr("#7070703B")),
                    lineThickness: 1,
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
              child: (service != null &&
                      service.professionalPhotos != null &&
                      service.professionalPhotos.isNotEmpty)
                  ? _getImageArrayOfProfessional(service)
                  : ClipRRect(
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
                    dashColor:
                        Color(CommonMethods.getColorHexFromStr("#7070703B")),
                    lineThickness: 1,
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
              child: (service != null &&
                      service.professionalPhotos != null &&
                      service.professionalPhotos.isNotEmpty)
                  ? _getImageArrayOfProfessional(service)
                  : ClipRRect(
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
                    dashColor:
                        Color(CommonMethods.getColorHexFromStr("#7070703B")),
                    lineThickness: 1,
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
                    dashColor:
                        Color(CommonMethods.getColorHexFromStr("#7070703B")),
                    lineThickness: 1,
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

  Widget getManualBiddingProfessionalWidget(
      List<MoreFacility> catalogues, int index,
      {bool isSelected = false, Function onTap, Function onProfileTap}) {
    Widget profWidget = _getProfessionalDetailWidget(
        catalogues, index, PlunesImages.unselectedFacilityIcon);
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(2))),
      child: InkWell(
        onDoubleTap: () {},
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
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
                          child: InkWell(
                            onTap: () {
                              if (onProfileTap != null) {
                                onProfileTap();
                              }
                            },
                            onDoubleTap: () {},
                            child: CustomWidgets().getImageFromUrl(
                                catalogues[index]?.imageUrl ?? "",
                                boxFit: BoxFit.cover,
                                placeHolderPath: PlunesImages.doc_placeholder),
                          ),
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
      ),
    );
  }

  Widget _getProfessionalDetailWidget(
      List<MoreFacility> catalogues, int index, String icon) {
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
                            catalogues[index]?.name ?? "",
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 20,
                              color: PlunesColors.BLACKCOLOR,
                            ),
                          ),
                          // Text(
                          //   "Fortis Healthcare",
                          //   maxLines: 2,
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     color: Color(
                          //         CommonMethods.getColorHexFromStr("#707070")),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        icon,
                        height: 30,
                        width: 40,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.8),
                  child: Row(
                    children: [
                      Expanded(
                        child: (catalogues[index].experience != null &&
                                catalogues[index].experience > 0)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    "${catalogues[index].experience} year",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: PlunesColors.BLACKCOLOR),
                                  )
                                ],
                              )
                            : Container(),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                            Text(
                              " ${catalogues[index]?.rating?.toStringAsFixed(1) ?? 4.5}",
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

  Widget getHorizontalProfessionalWidget(
      List<MoreFacility> catalogues, int index,
      {bool isSelected = false, Function onTap, Function onProfileTap}) {
    Widget profWidget = _getProfessionalDetailWidget(
        catalogues, index, PlunesImages.selectedFacilityIcon);
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
      child: InkWell(
        onDoubleTap: () {},
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
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
                              catalogues[index]?.imageUrl ?? "",
                              placeHolderPath: PlunesImages.doc_placeholder,
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

  Widget getBookProfessionalWidget(Services service, Function openProfile,
      Function bookAppointment, Function checkInsurance) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: StatefulBuilder(
        builder: (context, newState) {
          return Column(
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
                    child: (service != null &&
                            service.professionalPhotos != null &&
                            service.professionalPhotos.isNotEmpty)
                        ? _getImageArrayOfProfessional(service)
                        : SizedBox.expand(
                            child: CustomWidgets().getImageFromUrl(
                                service.imageUrl ?? "",
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
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    DottedLine(
                      dashColor:
                          Color(CommonMethods.getColorHexFromStr("#7070703B")),
                      lineThickness: 1,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
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
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
                                              TextSpan(
                                                  text:
                                                      "${service.newPrice.first?.toStringAsFixed(1) ?? ""}",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
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
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 1),
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
                          (service.insuranceAvailable == null ||
                                  !(service.insuranceAvailable))
                              ? Container()
                              : Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 2),
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (checkInsurance != null) {
                                          checkInsurance();
                                        }
                                      },
                                      onDoubleTap: () {},
                                      child: Padding(
                                        child: Text(
                                          "Check Insurance",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
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
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? DottedLine(
                            dashColor: Color(
                                CommonMethods.getColorHexFromStr("#7070703B")),
                            lineThickness: 1,
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Container(
                            margin: EdgeInsets.only(
                                bottom: AppConfig.verticalBlockSize * 1.8))
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Column(
                            children: [
                              Container(
                                height: AppConfig.verticalBlockSize * 10,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: service.specialOffers?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              AppConfig.horizontalBlockSize * 4,
                                          vertical:
                                              AppConfig.verticalBlockSize *
                                                  1.5),
                                      margin: EdgeInsets.only(
                                          right: AppConfig.horizontalBlockSize *
                                              2.3),
                                      child: Row(
                                        children: [
                                          index == 0
                                              ? Container()
                                              : Container(
                                                  margin: EdgeInsets.only(
                                                      top: 8,
                                                      bottom: 8,
                                                      right: 20),
                                                  width: 1,
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#333333")),
                                                ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  service.specialOffers[index]
                                                          ?.values?.first ??
                                                      "",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: PlunesColors
                                                          .BLACKCOLOR,
                                                      fontSize: 18)),
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                margin: EdgeInsets.only(top: 3),
                                                child: Text(
                                                    service.specialOffers[index]
                                                            ?.keys?.first ??
                                                        "",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Color(CommonMethods
                                                            .getColorHexFromStr(
                                                                "#515151")),
                                                        fontSize: 16)),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 2),
                            child: !service.isExpanded
                                ? InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "View More ",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(CommonMethods
                                                    .getColorHexFromStr(
                                                        "#01D35A"))),
                                          ),
                                          Icon(Icons.keyboard_arrow_down,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#01D35A")),
                                              size: 15)
                                        ],
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("View Less ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#01D35A")))),
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#01D35A")),
                                            size: 15,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                        : Container()
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget getBookProfessionalPopup(Services service, Function openProfile,
      Function bookAppointment, BuildContext context, Function checkInsurance) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: StatefulBuilder(
        builder: (context, newState) {
          return Column(
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
                  child: (service != null &&
                          service.professionalPhotos != null &&
                          service.professionalPhotos.isNotEmpty)
                      ? _getImageArrayOfProfessional(service)
                      : ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16)),
                          child: SizedBox.expand(
                            child: CustomWidgets().getImageFromUrl(
                                service.imageUrl ?? "",
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
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    DottedLine(
                      dashColor:
                          Color(CommonMethods.getColorHexFromStr("#7070703B")),
                      lineThickness: 1,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
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
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
                                              TextSpan(
                                                  text:
                                                      "${service.newPrice.first?.toStringAsFixed(1) ?? ""}",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
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
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 1),
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
                          (service.insuranceAvailable == null ||
                                  !(service.insuranceAvailable))
                              ? Container()
                              : Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 2),
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (checkInsurance != null) {
                                          checkInsurance();
                                        }
                                      },
                                      onDoubleTap: () {},
                                      child: Padding(
                                        child: Text(
                                          "Check Insurance",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
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
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? DottedLine(
                            dashColor: Color(
                                CommonMethods.getColorHexFromStr("#7070703B")),
                            lineThickness: 1,
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Container(
                            margin: EdgeInsets.only(
                                bottom: AppConfig.verticalBlockSize * 1.8))
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Container(
                            height: AppConfig.verticalBlockSize * 10,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 4,
                                      vertical:
                                          AppConfig.verticalBlockSize * 1.5),
                                  margin: EdgeInsets.only(
                                      right:
                                          AppConfig.horizontalBlockSize * 2.3),
                                  child: Row(
                                    children: [
                                      index == 0
                                          ? Container()
                                          : Container(
                                              margin: EdgeInsets.only(
                                                  top: 8, bottom: 8, right: 20),
                                              width: 1,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#333333"))),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              service.specialOffers[index]
                                                      ?.values?.first ??
                                                  "",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      PlunesColors.BLACKCOLOR,
                                                  fontSize: 18)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.only(top: 3),
                                            child: Text(
                                                service.specialOffers[index]
                                                        ?.keys?.first ??
                                                    "",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Color(CommonMethods
                                                        .getColorHexFromStr(
                                                            "#515151")),
                                                    fontSize: 16)),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              itemCount: service.specialOffers?.length ?? 0,
                            ),
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 2),
                            child: !service.isExpanded
                                ? InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "View More ",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(CommonMethods
                                                    .getColorHexFromStr(
                                                        "#01D35A"))),
                                          ),
                                          Icon(Icons.keyboard_arrow_down,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#01D35A")),
                                              size: 15)
                                        ],
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("View Less ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#01D35A")))),
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#01D35A")),
                                            size: 15,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                        : Container()
                  ],
                ),
              ),
              CustomWidgets()
                  .getSingleCommonButton(context, PlunesStrings.close)
            ],
          );
        },
      ),
    );
  }

  Widget getBookProfessionalWidgetForHospitalDocs(
      Services service,
      Function openProfile,
      int docIndex,
      Function bookAppointment,
      Function checkInsurance) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: StatefulBuilder(
        builder: (context, newState) {
          return Column(
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
                    child: (service != null &&
                            service.professionalPhotos != null &&
                            service.professionalPhotos.isNotEmpty)
                        ? _getImageArrayOfProfessional(service)
                        : SizedBox.expand(
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
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    DottedLine(
                      dashColor:
                          Color(CommonMethods.getColorHexFromStr("#7070703B")),
                      lineThickness: 1,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
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
                                        service.doctors[docIndex].price
                                            .isNotEmpty &&
                                        service.doctors[docIndex].newPrice !=
                                            null &&
                                        service.doctors[docIndex].newPrice
                                            .isNotEmpty &&
                                        service.doctors[docIndex].price.first !=
                                            service.doctors[docIndex].newPrice
                                                .first)
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#A2A2A2")))),
                                        ]))
                                    : Container(),
                                (service.doctors[docIndex].newPrice != null &&
                                        service.doctors[docIndex].newPrice
                                            .isNotEmpty)
                                    ? Container(
                                        margin: EdgeInsets.only(top: 2.5),
                                        child: RichText(
                                            textAlign: TextAlign.left,
                                            text: TextSpan(children: [
                                              TextSpan(
                                                  text: "\u20B9",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
                                              TextSpan(
                                                  text:
                                                      "${service.doctors[docIndex].newPrice.first?.toStringAsFixed(1)}",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
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
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: (service.doctors[docIndex].homeCollection !=
                                        null &&
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
                          (service.insuranceAvailable == null ||
                                  !(service.insuranceAvailable))
                              ? Container()
                              : Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 2),
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (checkInsurance != null) {
                                          checkInsurance();
                                        }
                                      },
                                      onDoubleTap: () {},
                                      child: Padding(
                                        child: Text(
                                          "Check Insurance",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
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
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? DottedLine(
                            dashColor: Color(
                                CommonMethods.getColorHexFromStr("#7070703B")),
                            lineThickness: 1,
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Container(
                            margin: EdgeInsets.only(
                                bottom: AppConfig.verticalBlockSize * 1.8))
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Container(
                            height: AppConfig.verticalBlockSize * 10,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 4,
                                      vertical:
                                          AppConfig.verticalBlockSize * 1.5),
                                  margin: EdgeInsets.only(
                                      right:
                                          AppConfig.horizontalBlockSize * 2.3),
                                  child: Row(
                                    children: [
                                      index == 0
                                          ? Container()
                                          : Container(
                                              margin: EdgeInsets.only(
                                                  top: 8, bottom: 8, right: 20),
                                              width: 1,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#333333")),
                                            ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              service.specialOffers[index]
                                                      ?.values?.first ??
                                                  "",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      PlunesColors.BLACKCOLOR,
                                                  fontSize: 18)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.only(top: 3),
                                            child: Text(
                                                service.specialOffers[index]
                                                        ?.keys?.first ??
                                                    "",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Color(CommonMethods
                                                        .getColorHexFromStr(
                                                            "#515151")),
                                                    fontSize: 16)),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              itemCount: service.specialOffers?.length ?? 0,
                            ),
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 2),
                            child: !service.isExpanded
                                ? InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "View More ",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(CommonMethods
                                                    .getColorHexFromStr(
                                                        "#01D35A"))),
                                          ),
                                          Icon(Icons.keyboard_arrow_down,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#01D35A")),
                                              size: 15)
                                        ],
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("View Less ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#01D35A")))),
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#01D35A")),
                                            size: 15,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                        : Container()
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget getBookProfessionalPopupForHospitalDoc(
      Services service,
      Function openProfile,
      int docIndex,
      Function bookAppointment,
      BuildContext context,
      Function checkInsurance) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: StatefulBuilder(
        builder: (context, newState) {
          return Column(
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
                    child: (service != null &&
                            service.professionalPhotos != null &&
                            service.professionalPhotos.isNotEmpty)
                        ? _getImageArrayOfProfessional(service)
                        : SizedBox.expand(
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
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    DottedLine(
                      dashColor:
                          Color(CommonMethods.getColorHexFromStr("#7070703B")),
                      lineThickness: 1,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
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
                                        service.doctors[docIndex].price
                                            .isNotEmpty &&
                                        service.doctors[docIndex].newPrice !=
                                            null &&
                                        service.doctors[docIndex].newPrice
                                            .isNotEmpty &&
                                        service.doctors[docIndex].price.first !=
                                            service.doctors[docIndex].newPrice
                                                .first)
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#A2A2A2")))),
                                        ]))
                                    : Container(),
                                (service.doctors[docIndex].newPrice != null &&
                                        service.doctors[docIndex].newPrice
                                            .isNotEmpty)
                                    ? Container(
                                        margin: EdgeInsets.only(top: 2.5),
                                        child: RichText(
                                            textAlign: TextAlign.left,
                                            text: TextSpan(children: [
                                              TextSpan(
                                                  text: "\u20B9",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
                                              TextSpan(
                                                  text:
                                                      "${service.doctors[docIndex].newPrice.first?.toStringAsFixed(1)}",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: PlunesColors
                                                          .BLACKCOLOR)),
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
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: (service.doctors[docIndex].homeCollection !=
                                        null &&
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
                          (service.insuranceAvailable == null ||
                                  !(service.insuranceAvailable))
                              ? Container()
                              : Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 2),
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (checkInsurance != null) {
                                          checkInsurance();
                                        }
                                      },
                                      onDoubleTap: () {},
                                      child: Padding(
                                        child: Text(
                                          "Check Insurance",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
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
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? DottedLine(
                            dashColor: Color(
                                CommonMethods.getColorHexFromStr("#7070703B")),
                            lineThickness: 1,
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Container(
                            margin: EdgeInsets.only(
                                bottom: AppConfig.verticalBlockSize * 1.8))
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty &&
                            service.isExpanded)
                        ? Container(
                            height: AppConfig.verticalBlockSize * 10,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 4,
                                      vertical:
                                          AppConfig.verticalBlockSize * 1.5),
                                  margin: EdgeInsets.only(
                                      right:
                                          AppConfig.horizontalBlockSize * 2.3),
                                  child: Row(
                                    children: [
                                      index == 0
                                          ? Container()
                                          : Container(
                                              margin: EdgeInsets.only(
                                                  top: 8, bottom: 8, right: 20),
                                              width: 1,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#333333")),
                                            ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              service.specialOffers[index]
                                                      ?.values?.first ??
                                                  "",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      PlunesColors.BLACKCOLOR,
                                                  fontSize: 18)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.only(top: 3),
                                            child: Text(
                                                service.specialOffers[index]
                                                        ?.keys?.first ??
                                                    "",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Color(CommonMethods
                                                        .getColorHexFromStr(
                                                            "#515151")),
                                                    fontSize: 16)),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              itemCount: service.specialOffers?.length ?? 0,
                            ),
                          )
                        : Container(),
                    (service.specialOffers != null &&
                            service.specialOffers.isNotEmpty)
                        ? Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 2),
                            child: !service.isExpanded
                                ? InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "View More ",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(CommonMethods
                                                    .getColorHexFromStr(
                                                        "#01D35A"))),
                                          ),
                                          Icon(Icons.keyboard_arrow_down,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#01D35A")),
                                              size: 15)
                                        ],
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      service.isExpanded = !service.isExpanded;
                                      newState(() {});
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("View Less ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(CommonMethods
                                                      .getColorHexFromStr(
                                                          "#01D35A")))),
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#01D35A")),
                                            size: 15,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                        : Container()
                  ],
                ),
              ),
              CustomWidgets()
                  .getSingleCommonButton(context, PlunesStrings.close)
            ],
          );
        },
      ),
    );
  }

  Widget _getImageArrayOfProfessional(Services service) {
    double _currentDotPosition = 0.0;
    return StatefulBuilder(
      builder: (context, newState) {
        return Stack(
          children: [
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: service.professionalPhotos.length > 10
                  ? 10
                  : service.professionalPhotos.length,
              options: CarouselOptions(
                  height: AppConfig.verticalBlockSize * 28,
                  aspectRatio: 16 / 9,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  pageSnapping: true,
                  autoPlay: true,
                  reverse: false,
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                  onPageChanged: (index, _) {
                    if (_currentDotPosition.toInt() != index) {
                      _currentDotPosition = index.toDouble();
                    }
                    newState(() {});
                  },
                  scrollDirection: Axis.horizontal),
              itemBuilder: (BuildContext context, int itemIndex) => Container(
                width: double.infinity,
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    child: CustomWidgets().getImageFromUrl(
                        service.professionalPhotos[itemIndex] ?? '',
                        boxFit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 5,
              child: DotsIndicator(
                dotsCount: service.professionalPhotos.length > 10
                    ? 10
                    : service.professionalPhotos.length,
                position: _currentDotPosition,
                axis: Axis.horizontal,
                decorator: _decorator,
              ),
            )
          ],
        );
      },
    );
  }
}
