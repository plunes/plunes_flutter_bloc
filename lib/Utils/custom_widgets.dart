import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/actionable_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/models/solution_models/test_and_procedure_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import 'package:share/share.dart';
import 'CommonMethods.dart';
import 'app_config.dart';

///This class holds all the common widgets.
class CustomWidgets {
  static CustomWidgets _instance;

  CustomWidgets._init();

  factory CustomWidgets() {
    if (_instance == null) {
      _instance = CustomWidgets._init();
    }
    return _instance;
  }

  Widget searchBar(
      {@required final TextEditingController searchController,
      @required final String hintText,
      bool hasFocus = false,
      isRounded = true,
      FocusNode focusNode,
      double searchBarHeight = 6}) {
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
                          color: PlunesColors.GREYCOLOR,
                          fontSize: AppConfig.smallFont)),
                ),
              ),
              searchController.text.trim().isEmpty
                  ? Image.asset(
                      PlunesImages.searchIcon,
                      width: AppConfig.verticalBlockSize * 2.0,
                      height: AppConfig.verticalBlockSize * 2.0,
                    )
                  : InkWell(
                      onTap: () {
                        searchController.text = "";
                        newState(() {});
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

  Widget rectangularButtonWithPadding(
      {@required final String buttonText,
      @required final Color buttonColor,
      @required final Color textColor,
      @required final double horizontalPadding,
      @required final double verticalPadding,
      @required final Color borderColor,
      Function onTap,
      Function onDoubleTap}) {
    return Material(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.green,
        onDoubleTap: onDoubleTap ?? () {},
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: buttonColor,
              border: Border.all(color: borderColor)),
          padding: EdgeInsets.symmetric(
              vertical: verticalPadding, horizontal: horizontalPadding),
          child: Center(
            child: Text(
              buttonText,
              maxLines: 1,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSolutionRow(List<CatalogueData> solutionList, int index,
      {Function onButtonTap, TapGestureRecognizer onViewMoreTap}) {
    return StatefulBuilder(builder: (context, newState) {
      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
//              if (solutionList[index].isActive != null &&
//                  !(solutionList[index].isActive)) {
//                return;
//              }
              if (solutionList[index].createdAt != null &&
                  solutionList[index].createdAt != 0) {
                var difference = DateTime.fromMillisecondsSinceEpoch(
                        solutionList[index].createdAt)
                    .difference(DateTime.now());
                if (difference.inHours == 0) {
                  onButtonTap();
                  return;
                }
              }
              newState(() {
                solutionList[index].isSelected =
                    !solutionList[index].isSelected ?? false;
              });
            },
            child: Container(
              color: solutionList[index].isSelected ?? false
                  ? PlunesColors.LIGHTGREENCOLOR
                  : PlunesColors.WHITECOLOR,
              padding: (index == 0)
                  ? EdgeInsets.only(
                      top: AppConfig.verticalBlockSize * 1.5,
                      bottom: AppConfig.verticalBlockSize * 2.5,
                      right: AppConfig.horizontalBlockSize * 3,
                      left: AppConfig.horizontalBlockSize * 3)
                  : EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2.5,
                      horizontal: AppConfig.horizontalBlockSize * 3),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: PlunesColors.WHITECOLOR,
                        height: AppConfig.horizontalBlockSize * 14,
                        width: AppConfig.horizontalBlockSize * 14,
                        child: (solutionList[index] == null ||
                                solutionList[index].speciality == null ||
                                solutionList[index].speciality.isEmpty)
                            ? Image.asset(PlunesImages.basicImage,
                                fit: BoxFit.contain)
                            : getImageFromUrl(
                                "https://specialities.s3.ap-south-1.amazonaws.com/${solutionList[index].speciality}.png",
                                boxFit: BoxFit.contain),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 2)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RichText(
                                text: TextSpan(
                                    text: solutionList[index].service ??
                                        PlunesStrings.NA,
                                    style: TextStyle(
                                      fontSize: AppConfig.smallFont + 1,
                                      color: Colors.black,
                                      //fontWeight: FontWeight.w500
                                    ),
                                    children: [
                                  TextSpan(
                                      text:
                                          "(${solutionList[index].category ?? PlunesStrings.NA})",
                                      style: TextStyle(
                                          fontSize: AppConfig.smallFont,
                                          color: Colors.green))
                                ])),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 1)),
                            (solutionList[index].details == null ||
                                    solutionList[index].details.isEmpty)
                                ? (solutionList[index].createdAt == null ||
                                        solutionList[index].createdAt == 0)
                                    ? Container()
                                    : Text(
                                        DateUtil.getDuration(
                                            solutionList[index].createdAt),
                                        style: TextStyle(
                                            fontSize: AppConfig.smallFont,
                                            color: PlunesColors.GREYCOLOR))
                                : RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: solutionList[index].details ??
                                          PlunesStrings.NA,
                                      style: TextStyle(
                                          fontSize: AppConfig.verySmallFont,
                                          color: Colors.black),
                                    )),
                            (solutionList[index].details == null ||
                                    solutionList[index].details.isEmpty)
                                ? Container()
                                : RichText(
                                    text: TextSpan(
                                        text: "view more",
                                        recognizer: onViewMoreTap,
                                        style: TextStyle(
                                            fontSize: AppConfig.verySmallFont,
                                            color: PlunesColors.GREENCOLOR,
                                            decoration:
                                                TextDecoration.underline)),
                                  ),
                            (!(solutionList[index].isActive) &&
                                    solutionList[index].maxDiscount != null &&
                                    solutionList[index].maxDiscount != 0)
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 1),
                                    child: Text(
                                      "You have missed ${solutionList[index].maxDiscount.toStringAsFixed(0)}% on your ${solutionList[index].service ?? PlunesStrings.NA} Previously",
                                      style: TextStyle(
                                          fontSize: AppConfig.smallFont,
                                          color: Colors.black),
                                    ))
                                : Container()
                          ],
                        ),
                      ),
                      //CustomWidgets().getRightFacingWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          index == solutionList.length - 1
              ? Container()
              : Container(
                  margin: EdgeInsets.only(
                      bottom: AppConfig.verticalBlockSize * 0,
                      right: AppConfig.horizontalBlockSize * 3,
                      left: AppConfig.horizontalBlockSize * 3),
                  width: double.infinity,
                  height: 0.5,
                  color: PlunesColors.GREYCOLOR,
                ),
          solutionList[index].isSelected ?? false
              ? InkWell(
                  onTap: onButtonTap,
                  child: Container(
                      color: PlunesColors.WHITECOLOR,
                      padding: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 32,
                          top: AppConfig.verticalBlockSize * 2,
                          right: AppConfig.horizontalBlockSize * 32),
                      child: getRoundedButton(
                          "Negotiate",
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 0,
                          AppConfig.verticalBlockSize * 2,
                          PlunesColors.WHITECOLOR)))
              : Container(),
          solutionList[index].isSelected ?? true
              ? Container(
                  margin: EdgeInsets.only(
                      top: AppConfig.verticalBlockSize * 1.5,
                      bottom: AppConfig.verticalBlockSize * 1.5),
                  width: double.infinity,
                  height: 0.5,
                  color: PlunesColors.GREYCOLOR,
                )
              : Container()
        ],
      );
    });
  }

//  Widget getPrevMissSolutionRow(List<CatalogueData> solutionList, int index,
//      {Function onButtonTap, TapGestureRecognizer onViewMoreTap}) {
//    return StatefulBuilder(builder: (context, newState) {
//      return Column(
//        children: <Widget>[
//          InkWell(
//            onTap: () {
//              newState(() {
//                solutionList[index].isSelected =
//                    !solutionList[index].isSelected ?? false;
//              });
//            },
//            child: Container(
//              color: solutionList[index].isSelected ?? false
//                  ? PlunesColors.LIGHTGREENCOLOR
//                  : PlunesColors.WHITECOLOR,
//              padding: EdgeInsets.symmetric(
//                  vertical: AppConfig.verticalBlockSize * 1,
//                  horizontal: AppConfig.horizontalBlockSize * 5),
//              child: Column(
//                children: <Widget>[
//                  Row(
//                    children: <Widget>[
//                      CircleAvatar(
//                        child: Container(
//                          height: AppConfig.horizontalBlockSize * 14,
//                          width: AppConfig.horizontalBlockSize * 14,
//                          child: ClipOval(
//                              child: getImageFromUrl(
//                                  "https://plunes.co/v4/data/5e6cda3106e6765a2d08ce24_1584192397080.jpg")),
//                        ),
//                        radius: AppConfig.horizontalBlockSize * 7,
//                      ),
//                      Padding(
//                          padding: EdgeInsets.only(
//                              left: AppConfig.horizontalBlockSize * 2)),
//                      Expanded(
//                        child: Column(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          mainAxisSize: MainAxisSize.min,
//                          children: <Widget>[
//                            RichText(
//                                text: TextSpan(
//                                    text: solutionList[index].serviceName ??
//                                        PlunesStrings.NA,
//                                    style: TextStyle(color: Colors.black),
//                                    children: [
//                                  TextSpan(
//                                      text:
//                                          "(${solutionList[index].serviceCategory ?? PlunesStrings.NA})",
//                                      style: TextStyle(color: Colors.green))
//                                ])),
//                            Padding(
//                                padding: EdgeInsets.only(
//                                    top: AppConfig.verticalBlockSize * 1)),
//                            Text((solutionList[index].createdAt != null)
//                                ? DateUtil.getDuration(
//                                    solutionList[index].createdAt)
//                                : PlunesStrings.NA)
////                            RichText(
////                                text: TextSpan(
////                                    text: solutionList[0].details ??
////                                        PlunesStrings.NA,
////                                    style: TextStyle(color: Colors.black),
////                                    children: [
////                                  TextSpan(
////                                      text: "(view more)",
////                                      recognizer: onViewMoreTap,
////                                      style: TextStyle(
////                                          color: PlunesColors.GREENCOLOR))
////                                ])),
//                          ],
//                        ),
//                      )
//                    ],
//                  ),
//                ],
//              ),
//            ),
//          ),
//          index == solutionList.length - 1
//              ? Container()
//              : Container(
//                  margin: EdgeInsets.only(
//                      bottom: AppConfig.verticalBlockSize * 1.5),
//                  width: double.infinity,
//                  height: 0.5,
//                  color: PlunesColors.GREYCOLOR,
//                ),
//          solutionList[index].isSelected ?? false
//              ? InkWell(
//                  onTap: onButtonTap,
//                  child: Container(
//                      color: PlunesColors.WHITECOLOR,
//                      padding: EdgeInsets.only(
//                          left: AppConfig.horizontalBlockSize * 24,
//                          top: AppConfig.verticalBlockSize * 1,
//                          right: AppConfig.horizontalBlockSize * 24),
//                      child: getRoundedButton(
//                          "Negotiate",
//                          AppConfig.horizontalBlockSize * 8,
//                          PlunesColors.GREENCOLOR,
//                          AppConfig.horizontalBlockSize * 4,
//                          AppConfig.verticalBlockSize * 2,
//                          PlunesColors.WHITECOLOR)))
//              : Container(),
//          solutionList[index].isSelected ?? true
//              ? Container(
//                  margin: EdgeInsets.only(
//                      top: AppConfig.verticalBlockSize * 1.5,
//                      bottom: AppConfig.verticalBlockSize * 1.5),
//                  width: double.infinity,
//                  height: 0.5,
//                  color: PlunesColors.GREYCOLOR,
//                )
//              : Container()
//        ],
//      );
//    });
//  }

  Widget getImageFromUrl(final String imageUrl,
      {BoxFit boxFit = BoxFit.contain}) {
//    print("file url is $imageUrl");
    return CachedNetworkImage(
      imageUrl: imageUrl ?? PlunesStrings.NA,
      fit: boxFit,
      errorWidget: (_, str, sds) =>
          Image.asset(PlunesImages.defaultImage, fit: boxFit),
      placeholder: (_, sds) =>
          Image.asset(PlunesImages.defaultImage, fit: boxFit),
    );
  }

  Widget getRoundedButton(
      String buttonName,
      double cornerPadding,
      Color buttonColor,
      double horizontalPadding,
      double verticalPadding,
      Color textColor,
      {bool hasBorder = false,
      Color borderColor = PlunesColors.GREYCOLOR,
      double borderWidth = 0.8}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
          color: buttonColor ?? PlunesColors.WHITECOLOR,
          border: hasBorder
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          borderRadius: BorderRadius.all(Radius.circular(cornerPadding))),
      child: Center(
        child: Text(
          buttonName,
          style: TextStyle(
            fontSize: AppConfig.smallFont,
            color: textColor ?? PlunesColors.BLACKCOLOR,
          ),
        ),
      ),
    );
  }

  Widget getProgressIndicator({Color color}) {
    return Container(
      child: Center(
        child: SpinKitCircle(
          color: color ?? PlunesColors.GREENCOLOR,
        ),
      ),
    );
  }

  Widget errorWidget(String failureCause) {
    return Container(
      child: Center(
        child: Text(
          failureCause ?? plunesStrings.somethingWentWrong,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: PlunesColors.BLACKCOLOR,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

  EdgeInsetsGeometry getDefaultPaddingForScreens() {
    return EdgeInsets.symmetric(
        horizontal: AppConfig.horizontalBlockSize * 6,
        vertical: AppConfig.verticalBlockSize * 3);
  }

  EdgeInsetsGeometry getDefaultPaddingForScreensVertical(double size) {
    return EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * size);
  }

  Widget getTestAndProcedureWidget(
      List<TestAndProcedureResponseModel> testAndProcedures,
      int index,
      Function onButtonTap) {
    return InkWell(
      onTap: onButtonTap,
      child: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: PlunesColors.WHITECOLOR,
                  height: AppConfig.horizontalBlockSize * 14,
                  width: AppConfig.horizontalBlockSize * 14,
                  child: getImageFromUrl(
                      "https://specialities.s3.ap-south-1.amazonaws.com/${testAndProcedures[index].sId}.png",
                      boxFit: BoxFit.contain),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 2)),
                Expanded(
                  child: Text(
                    testAndProcedures[index].sId,
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontWeight: FontWeight.bold),
                  ),
                  flex: 3,
                ),
                getRightFacingWidget()
              ],
            ),
            index == testAndProcedures.length - 1
                ? Container()
                : Container(
                    margin: EdgeInsets.only(
                        top: AppConfig.verticalBlockSize * 1.5,
                        bottom: AppConfig.verticalBlockSize * 1.5),
                    width: double.infinity,
                    height: 0.5,
                    color: PlunesColors.GREYCOLOR,
                  )
          ],
        ),
      ),
    );
  }

  Widget getAppointmentList(
      AppointmentResponseModel appointments, int index, Function onButtonTap) {
    return InkWell(
      onTap: onButtonTap,
      child: Container(
        width: double.infinity,
//        padding: EdgeInsets.only(
//          top: AppConfig.verticalBlockSize * 1.5,
//        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  child: ClipOval(
                      child: getImageFromUrl(
                          appointments.bookings[index].professionalImageUrl)),
                  radius: AppConfig.horizontalBlockSize * 7,
                ),
                Padding(
                    padding: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 2)),
                Expanded(
                  child: Text(
                    appointments.bookings[index].professionalName,
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontWeight: FontWeight.bold),
                  ),
                  flex: 3,
                ),
                getRightFacingWidget()
              ],
            ),
//            index == appointments.bookings.length +1
//                ? Container()
//                :
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 1.5,
                  bottom: AppConfig.verticalBlockSize * 1.5),
              width: double.infinity,
              height: 0.5,
              color: PlunesColors.GREYCOLOR,
            )
          ],
        ),
      ),
    );
  }

  Widget getRightFacingWidget() {
    return Icon(
      Icons.chevron_right,
      color: PlunesColors.GREENCOLOR,
    );
  }

  Widget getDocOrHospitalDetailWidget(
      List<Services> solutions,
      int index,
      Function checkAvailability,
      Function onBookingTap,
      CatalogueData catalogueData,
      BuildContext context,
      Function viewProfile) {
    return Container(
      padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () => viewProfile(),
                onDoubleTap: () {},
                child: (solutions[index].imageUrl != null &&
                        solutions[index].imageUrl.isNotEmpty)
                    ? CircleAvatar(
                        child: Container(
                          height: AppConfig.horizontalBlockSize * 14,
                          width: AppConfig.horizontalBlockSize * 14,
                          child: ClipOval(
                              child: getImageFromUrl(solutions[index].imageUrl,
                                  boxFit: BoxFit.fill)),
                        ),
                        radius: AppConfig.horizontalBlockSize * 7,
                      )
                    : getProfileIconWithName(
                        solutions[index].name,
                        14,
                        14,
                      ),
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3)),
              Expanded(
                child: InkWell(
                  onTap: () => viewProfile(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        solutions[index].name ?? PlunesStrings.NA,
                        style: TextStyle(
                            fontSize: AppConfig.mediumFont,
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.bold),
                      ),
                      (solutions[index] != null &&
                              solutions[index].experience != null &&
                              solutions[index].experience > 0)
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.horizontalBlockSize * 1),
                              child: Text(
                                "${solutions[index].experience} ${PlunesStrings.yrExp}",
                                style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.GREYCOLOR,
                                ),
                              ))
                          : Container()
                    ],
                  ),
                ),
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2)),
              solutions[index].negotiating
                  ? getLinearIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RichText(
                            text: TextSpan(
                                text: (solutions[index]?.price[0] ==
                                        solutions[index]?.newPrice[0])
                                    ? ""
                                    : "\u20B9${solutions[index].price[0]?.toStringAsFixed(2) ?? PlunesStrings.NA} ",
                                style: TextStyle(
                                    fontSize: AppConfig.smallFont,
                                    color: PlunesColors.GREYCOLOR,
                                    decoration: TextDecoration.lineThrough),
                                children: <TextSpan>[
                              TextSpan(
                                text:
                                    " \u20B9${solutions[index].newPrice[0]?.toStringAsFixed(2) ?? PlunesStrings.NA}",
                                style: TextStyle(
                                    fontSize: AppConfig.smallFont,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none),
                              )
                            ])),
                        Padding(
                            padding: EdgeInsets.only(
                                top: AppConfig.horizontalBlockSize * 1)),
                        (solutions[index].price[0] ==
                                solutions[index].newPrice[0])
                            ? Container()
                            : Text(
                                solutions[index].discount == null
                                    ? ""
                                    : "${PlunesStrings.save} ${solutions[index].discount.toStringAsFixed(2)}%",
                                style: TextStyle(
                                    fontSize: AppConfig.verySmallFont,
                                    color: PlunesColors.GREENCOLOR),
                              )
                      ],
                    ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(
                  top: solutions[index].negotiating
                      ? 0.0
                      : AppConfig.verticalBlockSize * 2)),
          solutions[index].negotiating
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  // crossAxisAlignment: CrossAxisAlignment.,
                  children: <Widget>[
                    Container(
                        width: AppConfig.horizontalBlockSize * 11,
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 1.5)),
                    Padding(
                        padding: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 1.5)),
                    Flexible(
                        child: showRatingBar(
                            solutions[index].rating?.toDouble() ?? 3.0)),
                    Expanded(child: Container()),
                    Text(
                        solutions[index].distance == null
                            ? ""
                            : "${solutions[index].distance.toStringAsFixed(2)} ${PlunesStrings.kmsAway}",
                        style: TextStyle(fontSize: AppConfig.verySmallFont))
                  ],
                ),
          Padding(
              padding: EdgeInsets.only(
                  top: solutions[index].negotiating
                      ? 0.0
                      : AppConfig.verticalBlockSize * 2)),
          solutions[index].negotiating
              ? Container(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    PlunesStrings.negotiating,
                    style: TextStyle(
                        fontSize: AppConfig.mediumFont,
                        fontWeight: FontWeight.w400),
                  ))
              : Row(
                  children: <Widget>[
                    Container(
                        width: AppConfig.horizontalBlockSize * 11,
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 5)),
                    Padding(
                        padding: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 1.5)),
                    Expanded(
                        flex: 6,
                        child: Text(PlunesStrings.validForOneHour,
                            style: TextStyle(
                              fontSize: AppConfig.smallFont,
                              color: PlunesColors.GREENCOLOR,
                            ))),
                    Expanded(child: Container(), flex: 1),
                    InkWell(
                      onTap: checkAvailability,
                      child: getRoundedButton(
                          PlunesStrings.checkAvailability,
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.WHITECOLOR,
                          AppConfig.horizontalBlockSize * 3,
                          AppConfig.verticalBlockSize * 1,
                          PlunesColors.BLACKCOLOR,
                          hasBorder: true),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 2)),
                    InkWell(
                        onTap: onBookingTap,
                        child: getRoundedButton(
                            solutions[index].bookIn == null
                                ? PlunesStrings.book
                                : "${PlunesStrings.bookIn} ${solutions[index].bookIn}",
                            AppConfig.horizontalBlockSize * 8,
                            PlunesColors.GREENCOLOR,
                            AppConfig.horizontalBlockSize * 3,
                            AppConfig.verticalBlockSize * 1,
                            PlunesColors.WHITECOLOR)),
                  ],
                ),
          (solutions[index] != null &&
                  solutions[index].homeCollection != null &&
                  solutions[index].homeCollection)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                      Container(
                          width: AppConfig.horizontalBlockSize * 11,
                          margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 5,
                              top: AppConfig.verticalBlockSize * 10)),
                      Padding(
                          padding: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 1.5)),
                      Flexible(
                          child: Image.asset(
                        PlunesImages.homeCollectionImage,
                        scale: 0.5,
                      ))
                    ])
              : Container(),
          index == solutions.length - 1 ? Container() : getSeparatorLine()
        ],
      ),
    );
  }

  Widget buttonWithImageAhead(
      {String imageName,
      final String buttonText,
      Color textColor,
      Color backgroundColor,
      double verticalPadding,
      double horizontalPadding}) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: verticalPadding, horizontal: horizontalPadding),
      decoration: BoxDecoration(
          color: backgroundColor ?? PlunesColors.WHITECOLOR,
          shape: BoxShape.rectangle),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.enhanced_encryption),
          Padding(
            padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 1),
            child: Text(
              buttonText,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor ?? PlunesColors.BLACKCOLOR),
            ),
          )
        ],
      ),
    );
  }

  Widget getSeparatorLine() {
    return Container(
      margin: EdgeInsets.only(
          top: AppConfig.verticalBlockSize * 1.5,
          bottom: AppConfig.verticalBlockSize * 1.5),
      width: double.infinity,
      height: 0.5,
      color: PlunesColors.GREYCOLOR,
    );
  }

  Widget showRatingBar(num rating) {
    return RatingBar(
      initialRating: rating,
      ignoreGestures: true,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: AppConfig.horizontalBlockSize * 4.5,
      itemPadding: EdgeInsets.symmetric(horizontal: .3),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.green,
      ),
      unratedColor: PlunesColors.GREYCOLOR,
      onRatingUpdate: (rating) {
//        print(rating);
      },
    );
  }

  Widget getLinearIndicator({Color color}) {
    return Container(
      child: Center(
        child: SpinKitThreeBounce(
          color: color ?? PlunesColors.GREENCOLOR,
          size: 20.0,
          // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
        ),
      ),
    );
  }

  Widget buildViewMoreDialog({
    CatalogueData catalogueData,
  }) {
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        child: viewMoreContent(context, catalogueData),
      );
    });
  }

  Widget viewMoreContent(
    BuildContext context,
    CatalogueData catalogueData,
  ) {
    String replaceFrom = "\\n";
    return Container(
        height: AppConfig.verticalBlockSize * 50,
        width: double.infinity,
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              onDoubleTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.close),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              'Details',
              style: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: AppConfig.mediumFont),
            ),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 35,
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 7,
                vertical: AppConfig.verticalBlockSize * 1),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Definition:',
                    style: TextStyle(
                        fontSize: AppConfig.smallFont,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    catalogueData?.details ?? PlunesStrings.NA,
                    style: TextStyle(
                        color: Colors.black38, fontSize: AppConfig.smallFont),
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Duration',
                        style: TextStyle(
                            fontSize: AppConfig.smallFont,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text(
                        catalogueData?.duration ?? PlunesStrings.NA,
                        style: TextStyle(
                            color: Colors.black45,
                            fontSize: AppConfig.smallFont),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                  Row(children: <Widget>[
                    Text(
                      'Sittings:',
                      style: TextStyle(
                          fontSize: AppConfig.smallFont,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    Text(
                      catalogueData?.sitting ?? PlunesStrings.NA,
                      style: TextStyle(
                          color: Colors.black38, fontSize: AppConfig.smallFont),
                    ),
                  ]),
                  Divider(
                    color: Colors.black45,
                  ),
                  Text(
                    'Do\'s and Don\'t:',
                    style: TextStyle(
                        fontSize: AppConfig.smallFont,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    catalogueData?.dnd?.replaceAll(replaceFrom, "") ??
                        PlunesStrings.NA,
                    style: TextStyle(
                      fontSize: AppConfig.smallFont,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  // ignore: non_constant_identifier_names
  Widget updatePricePopUp(
      {RealInsight realInsight, DocHosMainInsightBloc docHosMainInsightBloc}) {
    var sliderVal = (realInsight.userPrice.toDouble() / 2) +
        (((realInsight.userPrice.toDouble() / 2)) / 2);
    num chancesPercent = 25,
        reductionInPrice =
            ((((realInsight.userPrice.toDouble() / 2)) / 2) * 100) /
                realInsight.userPrice.toDouble();
    if (sliderVal == 0) {
      chancesPercent = 0;
      reductionInPrice = 0;
    }
    TextEditingController _priceController = TextEditingController();
    ScrollController _scrollController = ScrollController();
    String failureCause;
    bool shouldShowField = false;
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            elevation: 0.0,
            child: StreamBuilder<RequestState>(
                stream: docHosMainInsightBloc.realTimePriceUpdateStream,
                builder: (context, snapShot) {
                  if (snapShot.data is RequestInProgress) {
                    return Container(
                        height: AppConfig.verticalBlockSize * 60,
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 5.5,
                            right: AppConfig.horizontalBlockSize * 5.5,
                            top: AppConfig.verticalBlockSize * 5),
                        child: CustomWidgets().getProgressIndicator());
                  }
                  if (snapShot.data is RequestSuccess) {
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      Navigator.pop(context, true);
                    });
                  }
                  if (snapShot.data is RequestFailed) {
                    RequestFailed requestFailed = snapShot.data;
                    failureCause = requestFailed.failureCause;
                  }
                  return Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Stack(
                      children: <Widget>[
                        Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: AppConfig.verticalBlockSize * 60,
                          margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 5.5,
                              right: AppConfig.horizontalBlockSize * 5.5,
                              top: AppConfig.verticalBlockSize * 5),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            reverse: shouldShowField ? true : false,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(PlunesStrings.realTimePrediction,
                                      style: TextStyle(
                                          fontSize: AppConfig.extraLargeFont,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 4.0),
                                    child: Text(
                                      'Update your best price for maximum bookings}',
                                      style: TextStyle(
                                          fontSize: AppConfig.mediumFont),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Text(
                                        realInsight?.serviceName ??
                                            PlunesStrings.NA,
                                        style: TextStyle(
                                            fontSize: AppConfig.mediumFont,
                                            color: Colors.black54),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "${reductionInPrice?.toStringAsFixed(1)}% ",
                                            style: TextStyle(
                                                color: PlunesColors.BLACKCOLOR,
                                                fontSize: AppConfig.mediumFont,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )),
                                      Slider(
                                        value: sliderVal,
                                        min: (realInsight.userPrice.floor() /
                                                2) ??
                                            0,
                                        max: realInsight.userPrice
                                            .floor()
                                            .toDouble(),
                                        divisions: 10,
                                        activeColor: Colors.green,
                                        onChanged: (newValue) {
                                          if (shouldShowField) {
                                            return;
                                          }
                                          newState(() {
                                            try {
                                              var val = (newValue * 100) /
                                                  realInsight.userPrice
                                                      .floor()
                                                      .toDouble();
                                              reductionInPrice =
                                                  ((newValue) * 100) /
                                                      realInsight.userPrice
                                                          .toDouble();
                                              reductionInPrice =
                                                  100 - reductionInPrice;

                                              chancesPercent =
                                                  (100 - val)?.toInt();
                                            } catch (e) {
                                              chancesPercent = 50;
                                              reductionInPrice = 50;
                                            }
                                            sliderVal = newValue;
                                          });
                                        },
                                      ),
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              ' \u20B9 ${(realInsight.userPrice.floor() / 2)?.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                  fontSize:
                                                      AppConfig.mediumFont,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(child: Container()),
                                            Text(
                                              ' \u20B9 ${realInsight.userPrice?.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                  fontSize:
                                                      AppConfig.mediumFont,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: AppConfig.verticalBlockSize *
                                                  3,
                                              bottom:
                                                  AppConfig.verticalBlockSize *
                                                      3),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: AppConfig
                                                      .horizontalBlockSize *
                                                  15),
                                          child: (realInsight.suggested !=
                                                      null &&
                                                  realInsight.suggested &&
                                                  shouldShowField)
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: TextField(
                                                        controller:
                                                            _priceController,
                                                        inputFormatters: [
                                                          WhitelistingTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        maxLines: 1,
                                                        autofocus: true,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .bottom,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        shouldShowField = false;
                                                        newState(() {});
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: AppConfig
                                                                    .horizontalBlockSize *
                                                                3),
                                                        padding:
                                                            EdgeInsets.all(5.0),
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Icon(
                                                          Icons.mode_edit,
                                                          color: PlunesColors
                                                              .GREENCOLOR,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      (realInsight.suggested !=
                                                                  null &&
                                                              realInsight
                                                                  .suggested &&
                                                              shouldShowField)
                                                          ? MainAxisAlignment
                                                              .end
                                                          : MainAxisAlignment
                                                              .center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                      ' \u20B9 ${sliderVal.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                          fontSize: AppConfig
                                                              .largeFont,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    (realInsight.suggested !=
                                                                null &&
                                                            realInsight
                                                                .suggested)
                                                        ? InkWell(
                                                            onTap: () {
                                                              shouldShowField =
                                                                  true;
                                                              newState(() {});
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets.only(
                                                                  left: AppConfig
                                                                          .horizontalBlockSize *
                                                                      3),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5.0),
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: Icon(
                                                                Icons.mode_edit,
                                                                color: PlunesColors
                                                                    .BLACKCOLOR,
                                                              ),
                                                            ),
                                                          )
                                                        : Container()
                                                  ],
                                                )),
                                      chancesPercent != null
                                          ? Text(
                                              'Chances of Booking increases by',
                                              style: TextStyle(
                                                fontSize: AppConfig.mediumFont,
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(height: 10),
                                      chancesPercent != null
                                          ? Text(
                                              chancesPercent == 0
                                                  ? '0%'
                                                  : '${chancesPercent - 5}% to $chancesPercent%',
                                              style: TextStyle(
                                                  fontSize:
                                                      AppConfig.mediumFont,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Container(),
                                      SizedBox(height: 20),
                                      FlatButton(
                                        child: Text(
                                          'Apply here',
                                          style: TextStyle(
                                              fontSize: AppConfig.largeFont,
                                              color: Colors.green,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        onPressed: () {
                                          if (realInsight.suggested != null &&
                                              realInsight.suggested &&
                                              shouldShowField) {
                                            if (_priceController.text
                                                    .trim()
                                                    .isEmpty ||
                                                _priceController.text
                                                        .trim()
                                                        .substring(0) ==
                                                    "0") {
                                              failureCause =
                                                  'price must not be 0 or empty';
                                              newState(() {});
                                              return;
                                            }
                                            docHosMainInsightBloc
                                                .updateRealTimeInsightPriceStream(
                                                    RequestInProgress());
                                            docHosMainInsightBloc
                                                .getUpdateRealTimeInsightPrice(
                                                    num.tryParse(
                                                        _priceController.text
                                                            .trim()),
                                                    realInsight.solutionId,
                                                    realInsight.serviceId);
                                          } else {
                                            if (sliderVal == null ||
                                                sliderVal == 0) {
                                              failureCause =
                                                  'price must not be 0';
                                              newState(() {});
                                              return;
                                            }
                                            docHosMainInsightBloc
                                                .updateRealTimeInsightPriceStream(
                                                    RequestInProgress());
                                            docHosMainInsightBloc
                                                .getUpdateRealTimeInsightPrice(
                                                    sliderVal,
                                                    realInsight.solutionId,
                                                    realInsight.serviceId);
                                          }
                                        },
                                      ),
                                      Text(
                                        failureCause ?? "",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0.0,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop()),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ) ??
          false;
    });
  }

  // ignore: non_constant_identifier_names
  Widget UpdatePricePopUpForActionableInsight(
      {ActionableInsight actionableInsight,
      DocHosMainInsightBloc docHosMainInsightBloc}) {
    var sliderVal = (num.parse(actionableInsight.userPrice).toDouble() / 2) +
        (((num.parse(actionableInsight.userPrice).toDouble() / 2)) / 2);
    num chancesPercent = 25;
    num reductionInPrice =
        ((((num.parse(actionableInsight.userPrice).toDouble() / 2)) / 2) *
                100) /
            num.parse(actionableInsight.userPrice).toDouble();
    if (sliderVal == 0) {
      chancesPercent = 0;
      reductionInPrice = 0;
    }
    ScrollController _scrollController = ScrollController();
    String failureCause;
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            elevation: 0.0,
            child: StreamBuilder<RequestState>(
                stream: docHosMainInsightBloc.actionablePriceUpdateStream,
                builder: (context, snapShot) {
                  if (snapShot.data is RequestInProgress) {
                    return Container(
                        height: AppConfig.verticalBlockSize * 60,
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 5.5,
                            right: AppConfig.horizontalBlockSize * 5.5,
                            top: AppConfig.verticalBlockSize * 5),
                        child: CustomWidgets().getProgressIndicator());
                  }
                  if (snapShot.data is RequestSuccess) {
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      Navigator.pop(context, true);
                    });
                  }
                  if (snapShot.data is RequestFailed) {
                    RequestFailed requestFailed = snapShot.data;
                    failureCause = requestFailed.failureCause;
                  }
                  return Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Stack(
                      children: <Widget>[
                        Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: AppConfig.verticalBlockSize * 60,
                          margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 5.5,
                              right: AppConfig.horizontalBlockSize * 5.5,
                              top: AppConfig.verticalBlockSize * 5),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(
                                    'Update Price in your Catalogue for maximum Bookings',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Text(
                                        actionableInsight?.serviceName ??
                                            PlunesStrings.NA,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "${reductionInPrice?.toStringAsFixed(1)}% ",
                                            style: TextStyle(
                                                color: PlunesColors.BLACKCOLOR,
                                                fontSize: AppConfig.mediumFont,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )),
                                      Slider(
                                          value: sliderVal,
                                          min: (num.parse(actionableInsight
                                                          .userPrice)
                                                      .floor() /
                                                  2) ??
                                              0,
                                          max: num.parse(
                                                  actionableInsight.userPrice)
                                              .floor()
                                              .toDouble(),
                                          divisions: 10,
                                          activeColor: Colors.green,
                                          onChanged: (newValue) {
                                            newState(() {
                                              try {
                                                var val = (newValue * 100) /
                                                    num.parse(actionableInsight
                                                            .userPrice)
                                                        .floor()
                                                        .toDouble();
                                                chancesPercent =
                                                    (100 - val)?.toInt();
                                                reductionInPrice = ((newValue) *
                                                        100) /
                                                    num.parse(actionableInsight
                                                            .userPrice)
                                                        .toDouble();
                                                reductionInPrice =
                                                    100 - (reductionInPrice);
                                              } catch (e) {
                                                chancesPercent = 50;
                                              }
                                              sliderVal = newValue;
                                            });
                                          }),
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              ' \u20B9 ${(num.parse(actionableInsight.userPrice).floor() / 2)?.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(child: Container()),
                                            Text(
                                              ' \u20B9 ${num.parse(actionableInsight.userPrice)?.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top:
                                                AppConfig.verticalBlockSize * 3,
                                            bottom:
                                                AppConfig.verticalBlockSize *
                                                    3),
                                        child: Text(
                                          ' \u20B9 ${sliderVal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      chancesPercent != null
                                          ? Text(
                                              'Chances of Booking increases by',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(height: 10),
                                      chancesPercent != null
                                          ? Text(
                                              chancesPercent == 0
                                                  ? '0%'
                                                  : '${chancesPercent - 5}% to $chancesPercent%',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Container(),
                                      SizedBox(height: 20),
                                      FlatButton(
                                        child: Text(
                                          'Apply here',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.green,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        onPressed: () {
                                          if (sliderVal == null ||
                                              sliderVal == 0) {
                                            failureCause =
                                                'price must not be 0';
                                            newState(() {});
                                            return;
                                          }
                                          docHosMainInsightBloc
                                              .getUpdateActionableInsightPrice(
                                                  sliderVal,
                                                  actionableInsight.serviceId,
                                                  actionableInsight
                                                      .specialityId);
                                        },
                                      ),
                                      Text(
                                        failureCause ?? "",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0.0,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop()),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ) ??
          false;
    });
  }

  Widget amountProgressBar(AppointmentModel appointmentModel) {
    return (appointmentModel.paymentStatus == null ||
            appointmentModel.paymentStatus.isEmpty)
        ? Container()
        : Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: AppConfig.verticalBlockSize * 15,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
//                      print(
//                          "appointmentModel.paymentStatus[index] ${appointmentModel.paymentStatus[index].toString()}");
                      return Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              index == 0
                                  ? Container()
                                  : Container(
                                      height: 1.5,
                                      width: (appointmentModel
                                                  .paymentStatus.length ==
                                              2)
                                          ? AppConfig.horizontalBlockSize * 50
                                          : AppConfig.horizontalBlockSize * 15,
                                      color: PlunesColors.GREENCOLOR,
                                    ),
                              (appointmentModel.paymentStatus[index].status)
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: PlunesColors.GREENCOLOR,
                                          shape: BoxShape.circle),
                                      height: AppConfig.verticalBlockSize * 8,
                                      width: AppConfig.horizontalBlockSize * 18,
                                      child: Center(
                                          child: Icon(
                                        Icons.check,
                                        color: PlunesColors.WHITECOLOR,
                                      )),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: PlunesColors.WHITECOLOR,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: AppConfig
                                                      .horizontalBlockSize *
                                                  0.5,
                                              color:
                                                  PlunesColors.LIGHTGREYCOLOR)),
                                      height: AppConfig.verticalBlockSize * 8,
                                      width: AppConfig.horizontalBlockSize * 18,
                                      child: Center(
                                        child: Text(
                                          appointmentModel
                                                  .paymentStatus[index].title ??
                                              PlunesStrings.NA,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              index == 0
                                  ? Container()
                                  : Container(
                                      width: (appointmentModel
                                                  .paymentStatus.length ==
                                              2)
                                          ? AppConfig.horizontalBlockSize * 50
                                          : AppConfig.horizontalBlockSize * 15,
                                      color: PlunesColors.LIGHTGREYCOLOR,
                                    ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2.5),
                                child: Center(
                                    child: Text(
                                  (appointmentModel.paymentStatus.length == 3 &&
                                          index == 0)
                                      ? appointmentModel
                                          .paymentStatus[index].title
                                      : ' \u20B9 ${appointmentModel.paymentStatus[index].amount}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: AppConfig.smallFont,
                                      fontWeight: FontWeight.bold),
                                )),
                              )
                            ],
                          ),
                        ],
                      );
                    },
                    itemCount: appointmentModel.paymentStatus?.length ?? 0,
                  ),
                ),
              ],
            ),
          );
  }

  refundPopup(BookingBloc bookingBloc, AppointmentModel appointmentModel) {
    TextEditingController textEditingController = TextEditingController();
    bool isSuccess = false;
    String failureMessage;
    return AnimatedContainer(
      padding: AppConfig.getMediaQuery().viewInsets,
      duration: const Duration(milliseconds: 300),
      child: Dialog(
        child: Card(
          elevation: 0.0,
          child: StreamBuilder<RequestState>(
            stream: bookingBloc.refundAppointmentStream,
            builder: (BuildContext context, snapshot) {
              if (snapshot.data != null && snapshot.data is RequestInProgress) {
                return CustomWidgets().getProgressIndicator();
              }
              if (snapshot.data != null && snapshot.data is RequestSuccess) {
                isSuccess = true;
              }
              if (snapshot.data != null && snapshot.data is RequestFailed) {
                RequestFailed requestFailed = snapshot.data;
                failureMessage = requestFailed.failureCause ??
                    PlunesStrings.refundFailedMessage;
                bookingBloc.addStateInRefundProvider(null);
              }
              return SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          return;
                        },
                        onDoubleTap: () {},
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.close,
                            color: PlunesColors.GREYCOLOR,
                          ),
                        ),
                      ),
                    ),
                    isSuccess
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 6,
                                vertical: AppConfig.verticalBlockSize * 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(PlunesStrings.thankYouMessage,
                                    style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w600,
                                        color: PlunesColors.BLACKCOLOR)),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.horizontalBlockSize * 6),
                                ),
                                Text(PlunesStrings.refundSuccessMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: AppConfig.extraLargeFont,
                                        fontWeight: FontWeight.w600,
                                        color: PlunesColors.GREYCOLOR)),
                              ],
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(PlunesStrings.refund,
                                    style: TextStyle(
                                        fontSize: AppConfig.extraLargeFont,
                                        fontWeight: FontWeight.w600,
                                        color: PlunesColors.GREYCOLOR)),
                                Container(
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 4),
                                    child: Text(
                                        'Kindly Share the reason for your refund',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: AppConfig.largeFont,
                                            fontWeight: FontWeight.w600,
                                            color: PlunesColors.GREYCOLOR))),
                                Container(
                                    alignment: Alignment.topLeft,
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 4),
                                    child: Text('Write here',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: AppConfig.mediumFont,
                                            fontWeight: FontWeight.w600,
                                            color: PlunesColors.GREYCOLOR))),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        controller: textEditingController,
                                        keyboardType: TextInputType.text,
                                        maxLines: 1,
                                        autofocus: true,
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 6,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 20,
                                      vertical:
                                          AppConfig.verticalBlockSize * 3),
                                  child: InkWell(
                                    onTap: () {
                                      if (appointmentModel != null &&
                                          textEditingController.text
                                              .trim()
                                              .isNotEmpty) {
                                        bookingBloc.refundAppointment(
                                            appointmentModel.bookingId,
                                            textEditingController.text.trim());
                                      } else if (textEditingController.text
                                          .trim()
                                          .isEmpty) {
                                        failureMessage =
                                            PlunesStrings.emptyTextFieldWarning;
                                        bookingBloc
                                            .addStateInRefundProvider(null);
                                      }
                                    },
                                    onDoubleTap: () {},
                                    child: CustomWidgets().getRoundedButton(
                                        plunesStrings.submit,
                                        AppConfig.horizontalBlockSize * 6,
                                        PlunesColors.GREENCOLOR,
                                        AppConfig.horizontalBlockSize * 1,
                                        AppConfig.verticalBlockSize * 1,
                                        PlunesColors.WHITECOLOR),
                                  ),
                                ),
                                failureMessage == null || failureMessage.isEmpty
                                    ? Container()
                                    : Container(
                                        padding: EdgeInsets.only(
                                            top: AppConfig.verticalBlockSize *
                                                1),
                                        child: Text(
                                          failureMessage,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void share(String shareableContent) {
    Share.share(shareableContent);
  }

  Widget getCancelMessagePopup(BuildContext context) {
    return AlertDialog(
      backgroundColor: null,
      contentPadding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Container(
        child: Card(
          elevation: 0.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      return;
                    },
                    onDoubleTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close,
                        color: PlunesColors.GREYCOLOR,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 6,
                      vertical: AppConfig.verticalBlockSize * 2),
                  child: Text(
                    "Sorry! your appointment has been cancelled.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConfig.smallFont,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.all(20),
                    child: Container()),
              ]),
        ),
      ),
    );
  }

  Widget getTipsConversionsPopup(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 8,
          vertical: AppConfig.verticalBlockSize * 15),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(children: <Widget>[
          Container(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              onDoubleTap: () {},
              child: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.close,
                  color: PlunesColors.GREYCOLOR,
                  size: 30,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 6,
                vertical: AppConfig.verticalBlockSize * 2),
            child: Text(
              "Tips for more Conversions",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: AppConfig.mediumFont, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 40,
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 5,
                vertical: AppConfig.verticalBlockSize * 2),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  iconWithText("Call up the Patients"),
                  iconWithText("Make Them Comfortable"),
                  iconWithText(
                      "Please respect the time of patients as they care about it most"),
                  iconWithText("Introduce proper communication with Patients"),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget iconWithText(String textMsg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Image.asset(
          PlunesImages.bulbIconForTips,
          width: 40,
        ),
        SizedBox(
          width: AppConfig.horizontalBlockSize * 3,
        ),
        Expanded(
            child: Text(
          textMsg,
          style: TextStyle(fontSize: AppConfig.smallFont),
        )),
        SizedBox(
          height: AppConfig.verticalBlockSize * 10,
        ),
      ],
    );
  }

  Widget getDocHosConfirmAppointmentPopUp(BuildContext context,
      BookingBloc bookingBloc, AppointmentModel appointmentModel) {
    bool isSuccess = false;
    String failureMessage;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 8,
          vertical: AppConfig.verticalBlockSize * 33),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: StreamBuilder<Object>(
            stream: bookingBloc.confirmAppointmentByDocHosStream,
            builder: (context, snapshot) {
              if (snapshot.data != null && snapshot.data is RequestInProgress) {
                return CustomWidgets().getProgressIndicator();
              }
              if (snapshot.data != null && snapshot.data is RequestSuccess) {
                isSuccess = true;
              }
              if (snapshot.data != null && snapshot.data is RequestFailed) {
                RequestFailed requestFailed = snapshot.data;
                failureMessage = requestFailed.failureCause ??
                    PlunesStrings.confirmFailedMessage;
                bookingBloc.addStateInConfirmProvider(null);
              }
              return Column(children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    return;
                  },
                  onDoubleTap: () {},
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      color: PlunesColors.GREYCOLOR,
                      size: AppConfig.extraLargeFont,
                    ),
                  ),
                ),
                isSuccess
                    ? Container(
                        margin: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 2,
                            horizontal: AppConfig.horizontalBlockSize * 4),
                        child: Text(
                            "Appointment has been successfully Confirmed.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: AppConfig.mediumFont)),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 2),
                        child: Text("Confirm Appointment for Patient?",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: AppConfig.mediumFont)),
                      ),
                isSuccess
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 4,
                            bottom: AppConfig.verticalBlockSize * 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                if (appointmentModel != null) {
                                  bookingBloc.confirmAppointmentByDocHos(
                                      appointmentModel.bookingId);
                                }
                              },
                              onDoubleTap: () {},
                              child: getRoundedButton(
                                  "Yes",
                                  AppConfig.horizontalBlockSize * 5,
                                  PlunesColors.GREENCOLOR,
                                  AppConfig.horizontalBlockSize * 10,
                                  AppConfig.verticalBlockSize * 1,
                                  PlunesColors.WHITECOLOR),
                            ),
                            failureMessage == null || failureMessage.isEmpty
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * 1),
                                    child: Text(
                                      failureMessage,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                            SizedBox(
                              width: AppConfig.horizontalBlockSize * 10,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context, "No");
                                return;
                              },
                              onDoubleTap: () {},
                              child: getRoundedButton(
                                "No",
                                AppConfig.horizontalBlockSize * 5,
                                PlunesColors.WHITECOLOR,
                                AppConfig.horizontalBlockSize * 10,
                                AppConfig.verticalBlockSize * 1,
                                PlunesColors.BLACKCOLOR,
                                hasBorder: true,
                              ),
                            )
                          ],
                        ),
                      ),
              ]);
            }),
      ),
    );
  }

  Widget showLocationPermissionPopUp(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Allow Plunes to access your location."),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("No")),
                FlatButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "Yes",
                      style: TextStyle(color: PlunesColors.GREENCOLOR),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getProfileIconWithName(String name, double height, double width) {
    return Container(
        height: AppConfig.horizontalBlockSize * height,
        width: AppConfig.horizontalBlockSize * width,
        alignment: Alignment.center,
        child: Text(
            (name != '' ? CommonMethods.getInitialName(name) : '')
                .toUpperCase(),
            style: TextStyle(
                color: Colors.white,
                fontSize: AppConfig.extraLargeFont - 4,
                fontWeight: FontWeight.bold)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(AppConfig.horizontalBlockSize * 7)),
          gradient: new LinearGradient(
              colors: [Color(0xffababab), Color(0xff686868)],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ));
  }

  Widget getBackImageView(String name) {
    return Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        child: createTextViews(
            (name != null && name != '')
                ? CommonMethods.getInitialName(name).toUpperCase()
                : '',
            22,
            colorsFile.white,
            TextAlign.center,
            FontWeight.normal),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          gradient: LinearGradient(
              colors: [Color(0xffababab), Color(0xff686868)],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ));
  }

  Widget createTextViews(String label, double fontSize, String colorCode,
      TextAlign textAlign, FontWeight fontWeight) {
    return Text(label,
        textAlign: textAlign,
        style: TextStyle(
            fontSize: fontSize,
            decoration: label == plunesStrings.solutionNearYouMsg
                ? TextDecoration.underline
                : TextDecoration.none,
            color: Color(CommonMethods.getColorHexFromStr(colorCode)),
            fontWeight: fontWeight));
  }

  showDoctorList(List<DoctorsData> doctorsData, BuildContext context,
      String hospitalName) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      child: Container(
        height: AppConfig.verticalBlockSize * 80,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                onDoubleTap: () {},
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.close),
                ),
              ),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 7,
                  vertical: AppConfig.verticalBlockSize * 2),
              child: ListView.builder(
                itemBuilder: (context, itemIndex) {
                  return InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => showDocPopup(
                              doctorsData[itemIndex], context, hospitalName));
                    },
                    onDoubleTap: () {},
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 1.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              (doctorsData[itemIndex].imageUrl == null ||
                                      doctorsData[itemIndex].imageUrl.isEmpty)
                                  ? CustomWidgets().getBackImageView(
                                      doctorsData[itemIndex].name ??
                                          PlunesStrings.NA)
                                  : CircleAvatar(
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        child: ClipOval(
                                            child: getImageFromUrl(
                                                doctorsData[itemIndex].imageUrl,
                                                boxFit: BoxFit.fill)),
                                      ),
                                      radius: 30,
                                    ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: AppConfig.horizontalBlockSize * 40,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.2),
                                    child: Text(
                                      doctorsData[itemIndex].name ??
                                          PlunesStrings.NA,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.2),
                                    width: AppConfig.horizontalBlockSize * 40,
                                    child: Text(
                                      doctorsData[itemIndex].designation ??
                                          PlunesStrings.NA,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.GREYCOLOR,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.2),
                                    child: Text(
                                      doctorsData[itemIndex].experience ==
                                                  null ||
                                              doctorsData[itemIndex]
                                                      .experience ==
                                                  "0"
                                          ? PlunesStrings.NA
                                          : "Expr ${doctorsData[itemIndex].experience} years",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.GREYCOLOR,
                                          fontSize: 15),
                                    ),
                                    width: AppConfig.horizontalBlockSize * 40,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Divider(height: 0.5, color: PlunesColors.LIGHTGREYCOLOR)
                      ],
                    ),
                  );
                },
                itemCount: doctorsData?.length ?? 0,
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget showDocPopup(
      DoctorsData doctorsData, BuildContext context, String hospitalName) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      child: Container(
        height: AppConfig.verticalBlockSize * 50,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                onDoubleTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.close),
                ),
              ),
            ),
            Container(
                width: double.infinity,
                height: AppConfig.verticalBlockSize * 39,
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 4.5),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          (doctorsData != null &&
                                  doctorsData.imageUrl != null &&
                                  doctorsData.imageUrl.isNotEmpty)
                              ? CircleAvatar(
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    child: ClipOval(
                                        child: CustomWidgets().getImageFromUrl(
                                            doctorsData.imageUrl,
                                            boxFit: BoxFit.fill)),
                                  ),
                                  radius: 30,
                                )
                              : CustomWidgets().getBackImageView(
                                  doctorsData?.name ?? _getEmptyString()),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    doctorsData?.name ?? _getEmptyString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    "Doctor" ?? _getEmptyString(),
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3),
                        child: getProfileInfoView(
                            22,
                            22,
                            plunesImages.expertiseIcon,
                            plunesStrings.areaExpertise,
                            doctorsData?.department ?? _getEmptyString()),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3),
                        child: getProfileInfoView(
                            22,
                            22,
                            plunesImages.clockIcon,
                            plunesStrings.expOfPractice,
                            (doctorsData.experience == null ||
                                    doctorsData?.experience == "0")
                                ? _getEmptyString()
                                : doctorsData.experience),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3),
                        child: getProfileInfoView(
                            22,
                            22,
                            plunesImages.practisingIcon,
                            plunesStrings.practising,
                            hospitalName ?? _getEmptyString()),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3),
                        child: getProfileInfoView(
                            22,
                            22,
                            plunesImages.eduIcon,
                            plunesStrings.qualification,
                            doctorsData?.education ?? _getEmptyString()),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getEmptyString() {
    return PlunesStrings.NA;
  }

  Widget getProfileInfoView(
      double height, double width, String icon, String title, String value) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              width: width,
              height: height,
              child: Image.asset(icon,
                  fit: BoxFit.contain, height: height, width: width)),
          Padding(
              padding:
                  EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3)),
          Expanded(
            child: RichText(
                maxLines: 3,
                text: TextSpan(
                    text: "${title ?? _getEmptyString()}:",
                    style: TextStyle(
                        color: PlunesColors.GREYCOLOR,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    children: <InlineSpan>[
                      TextSpan(
                        text: value ?? _getEmptyString(),
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      )
                    ])),
          ),
        ],
      ),
    );
  }

  Widget fetchLocationPopUp(BuildContext context) {
    String message;
    bool isProgressing = false;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: EdgeInsets.symmetric(
          vertical: AppConfig.verticalBlockSize * 25,
          horizontal: AppConfig.horizontalBlockSize * 14),
      child: StatefulBuilder(builder: (context, newState) {
        if (isProgressing) {
          return getProgressIndicator();
        }
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  onDoubleTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
              Container(
                  height: AppConfig.verticalBlockSize * 34,
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 1),
                  child: SingleChildScrollView(
                      reverse: true,
                      child: message == null
                          ? Column(
                              children: <Widget>[
                                Image.asset(PlunesImages.setLocationMap),
                                Container(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1.5),
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 5),
                                  child: Text(
                                    PlunesStrings.pleaseSelectLocationPopup,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: PlunesColors.BLACKCOLOR,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1.5),
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 16),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder:
                                                  (BuildContext context, _,
                                                          __) =>
                                                      LocationFetch()))
                                          .then((val) async {
                                        if (val != null) {
                                          var addressControllerList =
                                              new List();
                                          addressControllerList =
                                              val.toString().split(":");
                                          String addr =
                                              addressControllerList[0] +
                                                  ' ' +
                                                  addressControllerList[1] +
                                                  ' ' +
                                                  addressControllerList[2];
//                          print("addr is $addr");
                                          var _latitude =
                                              addressControllerList[3];
                                          var _longitude =
                                              addressControllerList[4];
//                          print("_latitude $_latitude");
//                          print("_longitude $_longitude");
                                          isProgressing = true;
                                          newState(() {});
                                          UserBloc()
                                              .isUserInServiceLocation(
                                                  _latitude, _longitude,
                                                  address: addr,
                                                  isFromPopup: true)
                                              .then((value) {
                                            if (value is RequestSuccess) {
                                              CheckLocationResponse
                                                  checkLocationResponse =
                                                  value.response;
                                              if (checkLocationResponse !=
                                                      null &&
                                                  checkLocationResponse.msg !=
                                                      null &&
                                                  checkLocationResponse
                                                      .msg.isNotEmpty) {
                                                message =
                                                    checkLocationResponse.msg;
                                              }
                                              if (UserManager()
                                                  .getIsUserInServiceLocation()) {
                                                Navigator.of(context).pop();
                                                return;
                                              } else if (message == null) {
                                                message =
                                                    "Seems like we are not available in your area";
                                              }
                                            } else if (value is RequestFailed) {
                                              message = value.failureCause;
                                            }
                                            isProgressing = false;
                                            newState(() {});
                                          });
                                        }
                                      });
                                    },
                                    child: getRoundedButton(
                                      "Set Location",
                                      AppConfig.horizontalBlockSize * 5,
                                      PlunesColors.GREENCOLOR,
                                      AppConfig.horizontalBlockSize * 10,
                                      AppConfig.verticalBlockSize * 1,
                                      PlunesColors.WHITECOLOR,
                                      hasBorder: true,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            AppConfig.horizontalBlockSize * 20,
                                        vertical:
                                            AppConfig.verticalBlockSize * 5),
                                    child: Image.asset(
                                        PlunesImages.setLocationFailImage)),
                                Container(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1.5),
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 5),
                                  child: Text(
                                    message.isEmpty
                                        ? plunesStrings.somethingWentWrong
                                        : message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: PlunesColors.BLACKCOLOR,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1.5),
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 23),
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: getRoundedButton(
                                      "Ok",
                                      AppConfig.horizontalBlockSize * 5,
                                      PlunesColors.GREENCOLOR,
                                      AppConfig.horizontalBlockSize * 10,
                                      AppConfig.verticalBlockSize * 1,
                                      PlunesColors.WHITECOLOR,
                                      hasBorder: true,
                                    ),
                                  ),
                                )
//                      Padding(
//                        padding: EdgeInsets.only(
//                            top: AppConfig.verticalBlockSize * 8),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.end,
//                          children: <Widget>[
//                            FlatButton(
//                                onPressed: () =>
//                                    Navigator.pop(context, false),
//                                child: Text(
//                                  "OK",
//                                  style: TextStyle(
//                                      color: PlunesColors.GREENCOLOR),
//                                )),
//                          ],
//                        ),
//                      )
                              ],
                            )))
            ],
          ),
        );
      }),
    );
  }
}
