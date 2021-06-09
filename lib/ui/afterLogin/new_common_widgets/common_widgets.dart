import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

// import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/models/new_solution_model/premium_benefits_model.dart';
import 'package:plunes/models/new_solution_model/professional_model.dart';
import 'package:plunes/models/new_solution_model/top_facility_model.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:readmore/readmore.dart';

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
  final CarouselController _topFacilityController = CarouselController();

  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

  Widget getPremiumBenefitsWidget(PremiumBenefitData premiumBenefitData) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.only(
          right: AppConfig.horizontalBlockSize * 3.5, bottom: 1.8),
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
                          (service != null &&
                                  service.address != null &&
                                  service.address.trim().isNotEmpty)
                              ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: PlunesColors.BLACKCOLOR,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          service?.address?.trim() ?? '',
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#797979")),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
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
                  getSingleLine(),
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
                          (service != null &&
                                  service.address != null &&
                                  service.address.trim().isNotEmpty)
                              ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: PlunesColors.BLACKCOLOR,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          service?.address?.trim() ?? '',
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#797979")),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
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
                  getSingleLine(),
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
                          (service != null &&
                                  service.address != null &&
                                  service.address.trim().isNotEmpty)
                              ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: PlunesColors.BLACKCOLOR,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          service?.address?.trim() ?? '',
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#797979")),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container()
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
                  getSingleLine(),
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
                          (service != null &&
                                  service.address != null &&
                                  service.address.trim().isNotEmpty)
                              ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: PlunesColors.BLACKCOLOR,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          service?.address?.trim() ?? '',
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(CommonMethods
                                                .getColorHexFromStr("#797979")),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
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
                  getSingleLine(),
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
                          (profData.address != null &&
                                  profData.address.trim().isNotEmpty)
                              ? Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Text(
                                    profData.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#707070")),
                                    ),
                                  ),
                                )
                              : Container(),
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
                  getSingleLine(),
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

  Widget getBookProfessionalWidget(
      Services service,
      Function openProfile,
      Function bookAppointment,
      Function checkInsurance,
      DocHosSolution solution) {
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
                    (service != null &&
                            service.address != null &&
                            service.address.trim().isNotEmpty)
                        ? Container(
                            margin: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: PlunesColors.BLACKCOLOR,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    service?.address?.trim() ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#797979")),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    getSingleLine(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 0.5),
                      child: Row(
                        children: [
                          CommonMethods.shouldShowProgressOnPrice(
                                  service, solution.shouldNegotiate)
                              ? Expanded(
                                  flex: 3,
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      height: 100,
                                      width: 100,
                                      child: Image.asset(
                                          PlunesImages.timeMachineImage)),
                                )
                              : Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                            TextDecoration
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
                                if (CommonMethods.shouldShowProgressOnPrice(
                                    service, solution.shouldNegotiate)) {
                                  return;
                                }
                                if (bookAppointment != null) {
                                  bookAppointment();
                                }
                              },
                              onDoubleTap: () {},
                              child: CustomWidgets().getRoundedButton(
                                  PlunesStrings.book,
                                  AppConfig.horizontalBlockSize * 8,
                                  CommonMethods.shouldShowProgressOnPrice(
                                          service, solution.shouldNegotiate)
                                      ? PlunesColors.GREYCOLOR.withOpacity(0.4)
                                      : PlunesColors.PARROTGREEN,
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
                        ? getSingleLine()
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

  Widget getBookProfessionalPopup(
      Services service,
      Function openProfile,
      Function bookAppointment,
      BuildContext context,
      Function checkInsurance,
      DocHosSolution solution) {
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
                    (service != null &&
                            service.address != null &&
                            service.address.trim().isNotEmpty)
                        ? Container(
                            margin: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: PlunesColors.BLACKCOLOR,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    service?.address?.trim() ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#797979")),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    getSingleLine(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 0.5),
                      child: Row(
                        children: [
                          CommonMethods.shouldShowProgressOnPrice(
                                  service, solution.shouldNegotiate)
                              ? Expanded(
                                  flex: 3,
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      height: 100,
                                      width: 100,
                                      child: Image.asset(
                                          PlunesImages.timeMachineImage)),
                                )
                              : Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                            TextDecoration
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
                                if (CommonMethods.shouldShowProgressOnPrice(
                                    service, solution.shouldNegotiate)) {
                                  return;
                                }
                                if (bookAppointment != null) {
                                  bookAppointment();
                                }
                              },
                              onDoubleTap: () {},
                              child: CustomWidgets().getRoundedButton(
                                  PlunesStrings.book,
                                  AppConfig.horizontalBlockSize * 8,
                                  CommonMethods.shouldShowProgressOnPrice(
                                          service, solution.shouldNegotiate)
                                      ? PlunesColors.GREYCOLOR.withOpacity(0.4)
                                      : PlunesColors.PARROTGREEN,
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
                        ? getSingleLine()
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
      Function checkInsurance,
      DocHosSolution solution) {
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
                    (service != null &&
                            service.address != null &&
                            service.address.trim().isNotEmpty)
                        ? Container(
                            margin: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: PlunesColors.BLACKCOLOR,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    service?.address?.trim() ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#797979")),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    getSingleLine(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 0.5),
                      child: Row(
                        children: [
                          CommonMethods.shouldShowProgressOnPrice(
                                  service, solution.shouldNegotiate)
                              ? Expanded(
                                  flex: 3,
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      height: 100,
                                      width: 100,
                                      child: Image.asset(
                                          PlunesImages.timeMachineImage)),
                                )
                              : Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      (service.doctors[docIndex].price !=
                                                  null &&
                                              service.doctors[docIndex].price
                                                  .isNotEmpty &&
                                              service.doctors[docIndex]
                                                      .newPrice !=
                                                  null &&
                                              service.doctors[docIndex].newPrice
                                                  .isNotEmpty &&
                                              service.doctors[docIndex].price
                                                      .first !=
                                                  service.doctors[docIndex]
                                                      .newPrice.first)
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
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Color(CommonMethods
                                                            .getColorHexFromStr(
                                                                "#A2A2A2")))),
                                              ]))
                                          : Container(),
                                      (service.doctors[docIndex].newPrice !=
                                                  null &&
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
                                if (CommonMethods.shouldShowProgressOnPrice(
                                    service, solution.shouldNegotiate)) {
                                  return;
                                }
                                if (bookAppointment != null) {
                                  bookAppointment();
                                }
                              },
                              onDoubleTap: () {},
                              child: CustomWidgets().getRoundedButton(
                                  PlunesStrings.book,
                                  AppConfig.horizontalBlockSize * 8,
                                  CommonMethods.shouldShowProgressOnPrice(
                                          service, solution.shouldNegotiate)
                                      ? PlunesColors.GREYCOLOR.withOpacity(0.4)
                                      : PlunesColors.PARROTGREEN,
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
                        ? getSingleLine()
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
      Function checkInsurance,
      DocHosSolution solution) {
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
                    (service != null &&
                            service.address != null &&
                            service.address.trim().isNotEmpty)
                        ? Container(
                            margin: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: PlunesColors.BLACKCOLOR,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    service?.address?.trim() ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#797979")),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    getSingleLine(),
                    Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.8),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 0.5),
                      child: Row(
                        children: [
                          CommonMethods.shouldShowProgressOnPrice(
                                  service, solution.shouldNegotiate)
                              ? Expanded(
                                  flex: 3,
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      height: 100,
                                      width: 100,
                                      child: Image.asset(
                                          PlunesImages.timeMachineImage)),
                                )
                              : Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      (service.doctors[docIndex].price !=
                                                  null &&
                                              service.doctors[docIndex].price
                                                  .isNotEmpty &&
                                              service.doctors[docIndex]
                                                      .newPrice !=
                                                  null &&
                                              service.doctors[docIndex].newPrice
                                                  .isNotEmpty &&
                                              service.doctors[docIndex].price
                                                      .first !=
                                                  service.doctors[docIndex]
                                                      .newPrice.first)
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
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Color(CommonMethods
                                                            .getColorHexFromStr(
                                                                "#A2A2A2")))),
                                              ]))
                                          : Container(),
                                      (service.doctors[docIndex].newPrice !=
                                                  null &&
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
                                if (CommonMethods.shouldShowProgressOnPrice(
                                    service, solution.shouldNegotiate)) {
                                  return;
                                }
                                if (bookAppointment != null) {
                                  bookAppointment();
                                }
                              },
                              onDoubleTap: () {},
                              child: CustomWidgets().getRoundedButton(
                                  PlunesStrings.book,
                                  AppConfig.horizontalBlockSize * 8,
                                  CommonMethods.shouldShowProgressOnPrice(
                                          service, solution.shouldNegotiate)
                                      ? PlunesColors.GREYCOLOR.withOpacity(0.4)
                                      : PlunesColors.PARROTGREEN,
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
                        ? getSingleLine()
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
                  autoPlay:
                      (service.professionalPhotos.length == 1) ? false : true,
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

  Widget getEncryptionPopup(GlobalKey<ScaffoldState> globalKey) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
              height: AppConfig.verticalBlockSize * 10,
              child: Image.asset(PlunesImages.encryptionPopupImage),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5,
                  vertical: AppConfig.verticalBlockSize * 2.5),
              child: Text(
                "We follow end to end encryption, Any false/Offensive Data uploading is strictly prohibited and will lead to further action and confiscation of the account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: PlunesColors.GREYCOLOR,
            ),
            Container(
              height: AppConfig.verticalBlockSize * 6,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
                child: FlatButton(
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                    focusColor: Colors.transparent,
                    onPressed: () =>
                        Navigator.of(globalKey.currentState.context).pop(),
                    child: Container(
                        height: AppConfig.verticalBlockSize * 6,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'OK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                                color: PlunesColors.SPARKLINGGREEN),
                          ),
                        ))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getConsultationWidget(int index) {
    return Card(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: index == 4 ? 20 : 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Container(
        margin: EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  height: 130,
                  width: 150,
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: CustomWidgets().getImageFromUrl(
                        "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
                        boxFit: BoxFit.fill),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 7),
                  child: Text(
                    "Next available at",
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Color(CommonMethods.getColorHexFromStr("#107C6F"))),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4, bottom: 7),
                  child: Text(
                    "12 : 30 PM, Today",
                    style:
                        TextStyle(fontSize: 14, color: PlunesColors.BLACKCOLOR),
                  ),
                ),
              ],
            ),
            Flexible(
                child: Container(
              margin: EdgeInsets.only(left: 15, top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      "Dr. Aashish Chaudhry",
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 18, color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      "Neurologist",
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#434343"))),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color:
                            Color(CommonMethods.getColorHexFromStr("#F3F4F9"))),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: RatingBar(
                            initialRating: 5,
                            ignoreGestures: true,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 15,
                            itemPadding: EdgeInsets.symmetric(horizontal: .3),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#FEC30F")),
                            ),
                            unratedColor: PlunesColors.GREYCOLOR,
                            onRatingUpdate: (rating) {},
                          ),
                        ),
                        Container(
                          child: Text("5",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#434343")))),
                          margin: EdgeInsets.only(left: 3),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      "20 year of experience",
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#000000"))),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Consultation Fees ",
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#000000"))),
                          ),
                        ),
                        Text(
                          ": \u20B9 400",
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#000000"))),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 5,
                        vertical: AppConfig.verticalBlockSize * 1.2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        border: Border.all(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#25B281")),
                            width: 1),
                        color: Color(
                            CommonMethods.getColorHexFromStr("#00000033"))),
                    child: Text(PlunesStrings.bookAppointmentText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#107C6F")))),
                  )
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget getBookTestWidget(int index) {
    return Card(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: index == 4 ? 20 : 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Container(
        margin: EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 5),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              color: Colors.transparent,
              child: CustomWidgets().getImageFromUrl(
                  "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
                  boxFit: BoxFit.fill),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("child health checkup",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#595959")))),
                    Text("400",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#2A2A2A"))))
                  ],
                ),
              ),
            ),
            Text(
              PlunesStrings.book,
              style: TextStyle(
                  fontSize: 16,
                  color: Color(CommonMethods.getColorHexFromStr("#25B281"))),
            )
          ],
        ),
      ),
    );
  }

  Widget getBookProcedureWidget(int index) {
    return Card(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: index == 4 ? 20 : 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Container(
        margin: EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 5),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              color: Colors.transparent,
              child: CustomWidgets().getImageFromUrl(
                  "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg",
                  boxFit: BoxFit.fill),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Text("child health checkup",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(
                            CommonMethods.getColorHexFromStr("#595959")))),
              ),
            ),
            Text(
              PlunesStrings.book,
              style: TextStyle(
                  fontSize: 16,
                  color: Color(CommonMethods.getColorHexFromStr("#25B281"))),
            )
          ],
        ),
      ),
    );
  }

  Widget getSearchBarForTestConsProcedureScreens(
      TextEditingController textController,
      String hintText,
      Function onTextClear) {
    return StatefulBuilder(builder: (context, newState) {
      return Card(
        elevation: 3.0,
        color: Color(CommonMethods.getColorHexFromStr("#FAFAFA")),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: Color(CommonMethods.getColorHexFromStr("#DDDDDD")),
                width: 1)),
        child: Container(
          height: AppConfig.verticalBlockSize * 5,
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
                  controller: textController,
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
              textController.text.trim().isEmpty
                  ? Container()
                  : InkWell(
                      onTap: () {
                        textController.text = "";
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

  Widget getSingleLine() {
    return Container(
      height: 0.5,
      width: double.infinity,
      color: PlunesColors.GREYCOLOR,
    );
  }

  Widget getHospitalCard(
      String imageUrl,
      String label,
      String text,
      double rating,
      TopFacility topFacilityData,
      StreamController streamController) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          children: [
            (topFacilityData.achievements != null &&
                    topFacilityData.achievements.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)),
                    child: Stack(
                      children: [
                        CarouselSlider.builder(
                            itemCount: (topFacilityData.achievements.length > 5)
                                ? 5
                                : topFacilityData.achievements?.length,
                            itemBuilder: (context, index) {
                              return CustomWidgets().getImageFromUrl(
                                  topFacilityData.achievements[index].imageUrl,
                                  boxFit: BoxFit.fill);
                            },
                            carouselController: _topFacilityController,
                            options: CarouselOptions(
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                height: AppConfig.verticalBlockSize * 26,
                                viewportFraction: 1.0,
                                onPageChanged: (index, _) {
                                  if (topFacilityData.dotsPositionForTopFacility
                                          .toInt() !=
                                      index) {
                                    topFacilityData.dotsPositionForTopFacility =
                                        index.toDouble();
                                    streamController?.add(null);
                                  }
                                })),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: StreamBuilder<Object>(
                              stream: streamController.stream,
                              builder: (context, snapshot) {
                                return DotsIndicator(
                                  dotsCount:
                                      (topFacilityData.achievements.length > 5)
                                          ? 5
                                          : topFacilityData
                                              .achievements?.length,
                                  position: topFacilityData
                                          .dotsPositionForTopFacility
                                          ?.toDouble() ??
                                      0,
                                  axis: Axis.horizontal,
                                  decorator: _decorator,
                                  onTap: (pos) {
                                    _topFacilityController.animateToPage(
                                        pos.toInt(),
                                        curve: Curves.easeInOut,
                                        duration: Duration(milliseconds: 300));
                                    topFacilityData.dotsPositionForTopFacility =
                                        pos;
                                    streamController?.add(null);
                                    return;
                                  },
                                );
                              }),
                        ),
                        topFacilityData.distance != null
                            ? Positioned(
                                bottom: 0.0,
                                right: AppConfig.horizontalBlockSize * 2,
                                child: Chip(
                                  backgroundColor: Colors.white,
                                  label: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 5),
                                          child: Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: PlunesColors.BLACKCOLOR,
                                          ),
                                        ),
                                        Text(
                                          "${topFacilityData.distance.toStringAsFixed(1).length > 3 ? topFacilityData.distance.toStringAsFixed(1).substring(0, 3) : topFacilityData?.distance?.toStringAsFixed(1) ?? ''} kms",
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: PlunesColors.BLACKCOLOR,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  )
                : Container(
                    child: ClipRRect(
                      child: _imageFittedBox(imageUrl),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10)),
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
                      label ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Text(
                          " ${rating?.toStringAsFixed(1) ?? 4.5}",
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
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 2,
                  right: AppConfig.horizontalBlockSize * 2,
                  top: AppConfig.verticalBlockSize * 0.8),
              child: IgnorePointer(
                ignoring: true,
                child: ReadMoreText(text ?? "",
                    textAlign: TextAlign.left,
                    trimLines: 2,
                    trimCollapsedText: " ..Read More",
                    colorClickableText: Color(0xff107C6F),
                    trimMode: TrimMode.Line,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff444444),
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 2),
              padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
              alignment: Alignment.topLeft,
              child: Text(
                "Multispecialty | New Delhi",
                style: TextStyle(
                    color: Color(CommonMethods.getColorHexFromStr("#434343")),
                    fontSize: 16),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 2),
              padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text("13+ Doctors",
                          style: TextStyle(
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#000000")),
                              fontSize: 16)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text("Check insurance",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationThickness: 3.0,
                              decorationColor: Color(
                                  CommonMethods.getColorHexFromStr("#107C6F")),
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#107C6F")),
                              fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 2),
              padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    alignment: Alignment.centerLeft,
                    child: CustomWidgets().getImageFromUrl(""),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text("   NABH Accredited",
                          style: TextStyle(
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#434343")),
                              fontSize: 14)),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: AppConfig.verticalBlockSize * 6,
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 2),
              padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 2.5,
                        vertical: AppConfig.verticalBlockSize * 0.8),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                            width: 1,
                            color: Color(CommonMethods.getColorHexFromStr(
                                "#D8D8D887")))),
                    child: Text(
                      "Some text",
                      style: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#434343")),
                          fontSize: 14),
                    ),
                  );
                },
                itemCount: 10,
              ),
            ),
            SizedBox(height: 15)
          ],
        ),
      ),
    );
  }

  Widget _imageFittedBox(String imageUrl, {BoxFit boxFit = BoxFit.cover}) {
    return CustomWidgets().getImageFromUrl(imageUrl, boxFit: boxFit);
  }
}
