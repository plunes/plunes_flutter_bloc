import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/blocs/booking_blocs/appointment_bloc.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/actionable_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/models/solution_models/test_and_procedure_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/FontFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
import 'package:share/share.dart';

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
//              Icon(
//                      Icons.search,
//                      size: AppConfig.verticalBlockSize * 2.8,
//                      color: PlunesColors.GREYCOLOR,
//                    )
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
      String _imageUrl = '';
      if (solutionList[index].category == "Consultation") {
        _imageUrl = PlunesImages.consultationImage;
      } else if (solutionList[index].category == "Procedure") {
        _imageUrl = PlunesImages.procedureImage;
      } else if (solutionList[index].category == "Test") {
        _imageUrl = PlunesImages.testImage;
      }else if (solutionList[index].category == "NA") {
        _imageUrl = PlunesImages.consultationImage;
      }

      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              if (solutionList[index].isActive != null &&
                  !(solutionList[index].isActive)) {
                return;
              } else if (solutionList[index].createdAt != null &&
                  solutionList[index].createdAt != 0) {
                var difference = DateTime.fromMillisecondsSinceEpoch(
                        solutionList[index].createdAt)
                    .difference(DateTime.now());
                if (difference.inHours >= 1) return;
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
              padding: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2.5,
                  horizontal: AppConfig.horizontalBlockSize * 3),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: Container(
                          color: PlunesColors.WHITECOLOR,
                          height: AppConfig.horizontalBlockSize * 14,
                          width: AppConfig.horizontalBlockSize * 14,
                          child: ClipOval(
                            child: Image.asset(
                              _imageUrl,
                            ),
//                              child: getImageFromUrl(
//                                  "https://plunes.co/v4/data/5e6cda3106e6765a2d08ce24_1584192397080.jpg"
//                              )
                          ),
                        ),
                        radius: AppConfig.horizontalBlockSize * 7,
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
                                         fontSize: AppConfig.smallFont +1,
                                       color: Colors.black,
                                        //fontWeight: FontWeight.w500
                                    ),
                                    children: [
                                  TextSpan(
                                      text:
                                          "(${solutionList[index].category ?? PlunesStrings.NA})",
                                      style: TextStyle( fontSize: AppConfig.smallFont,color: Colors.green))
                                ])),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 1)),
                            (solutionList[index].details == null ||
                                    solutionList[index].details.isEmpty)
                                ? (solutionList[index].createdAt == null ||
                                        solutionList[index].createdAt == 0)
                                    ? Container()
                                    : Text(DateUtil.getDuration(
                                        solutionList[index].createdAt), style: TextStyle(fontSize: AppConfig.smallFont))
                                : RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: solutionList[index].details ??
                                          PlunesStrings.NA,
                                      style: TextStyle(fontSize: AppConfig.verySmallFont,color: Colors.black),
//<<<<<<< HEAD
////                                        children: [
////                                        TextSpan(
////                                            text: "(view more)",
////                                            recognizer: onViewMoreTap,
////                                            style: TextStyle(
////                                                color: PlunesColors.GREENCOLOR))
////                                      ]
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
                                      style: TextStyle( fontSize: AppConfig.smallFont,
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
      errorWidget: (_, str, sds) => Icon(Icons.account_circle),
      placeholder: (_, sds) => Icon(Icons.all_inclusive),
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
              color: PlunesColors.BLACKCOLOR, fontWeight: FontWeight.bold),
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
                          "https://plunes.co/v4/data/5e6cda3106e6765a2d08ce24_1584192397080.jpg")),
                  radius: AppConfig.horizontalBlockSize * 7,
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
      CatalogueData catalogueData) {
    return Container(
      padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                child: Container(
                  height: AppConfig.horizontalBlockSize * 14,
                  width: AppConfig.horizontalBlockSize * 14,
                  child: ClipOval(
                      child: getImageFromUrl(solutions[index].imageUrl,
                          boxFit: BoxFit.fill)),
                ),
                radius: AppConfig.horizontalBlockSize * 7,
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2)),
              Expanded(
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
                    Padding(
                        padding: EdgeInsets.only(
                            top: AppConfig.horizontalBlockSize * 1)),
                    Text(
                      catalogueData.category ?? PlunesStrings.NA,
                      style: TextStyle(
                        fontSize: AppConfig.mediumFont,
                        color: PlunesColors.GREYCOLOR,
                      ),
                    )
                  ],
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
                                text:
                                    "\u20B9${solutions[index].price[0]?.toStringAsFixed(2) ?? PlunesStrings.NA} ",
                                style: TextStyle(
                                    fontSize: AppConfig.smallFont,
                                    color: PlunesColors.GREYCOLOR,
                                    decoration: TextDecoration.lineThrough),
                                children: <TextSpan>[
                              TextSpan(
                                text:
                                    " \u20B9${solutions[index].newPrice[0]?.toStringAsFixed(2) ?? PlunesStrings.NA}",
                                style: TextStyle(
                                    fontSize: AppConfig.mediumFont,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none),
                              )
                            ])),
                        Padding(
                            padding: EdgeInsets.only(
                                top: AppConfig.horizontalBlockSize * 1)),
                        Text(
                          solutions[index].discount == null
                              ? ""
                              : "${PlunesStrings.save} ${solutions[index].discount.toStringAsFixed(2)}%",
                          style: TextStyle(fontSize: AppConfig.verySmallFont, color: PlunesColors.GREENCOLOR),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(width: AppConfig.horizontalBlockSize * 14),
                    Padding(
                        padding: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 1.5)),
                    Flexible(
                        child: _showRatingBar(
                            solutions[index].rating?.toDouble() ?? 3.0)),
                    Expanded(child: Container()),
                    Text(solutions[index].distance == null
                        ? ""
                        : "${solutions[index].distance.toStringAsFixed(2)} ${PlunesStrings.kmsAway}",style: TextStyle(fontSize: AppConfig.verySmallFont) )
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
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
//              Expanded(
//                  flex: 2,
//                  child: buttonWithImageAhead(
//                      textColor: PlunesColors.GREENCOLOR,
//                      buttonText: PlunesStrings.homeCollectionAvailable,
//                      backgroundColor: PlunesColors.LIGHTGREYCOLOR,
//                      verticalPadding: AppConfig.verticalBlockSize * 1,
//                      horizontalPadding: AppConfig.horizontalBlockSize * 3)),
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
                          PlunesColors.WHITECOLOR),
                    ),
                  ],
                ),
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

  Widget _showRatingBar(num rating) {
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
        print(rating);
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
      if (catalogueData.service == null) {
        catalogueData.service = 'NA';
      }
      if (catalogueData.dnd == null) {
        catalogueData.dnd = 'NA';
      }
      if (catalogueData.sitting == null) {
        catalogueData.sitting = 'NA';
      }
      if (catalogueData.duration == null) {
        catalogueData.duration = 'NA';
      }
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
    return Container(
        height: AppConfig.verticalBlockSize * 50,
        width: double.infinity,
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                child: Icon(Icons.close),
                onTap: () => Navigator.of(context).pop(),
                onDoubleTap: () {},
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              'Details',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: AppConfig.mediumFont),
            ),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 40,
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 7,
                vertical: AppConfig.verticalBlockSize * 1),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Defination:',
                    style: TextStyle(fontSize: AppConfig.smallFont,fontWeight: FontWeight.bold),
                  ),
                  Text(
                    catalogueData.service,
                    style: TextStyle(
                      color: Colors.black38,
                        fontSize: AppConfig.smallFont
                    ),
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Duration',
                        style: TextStyle(fontSize: AppConfig.smallFont,fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text(
                        catalogueData.duration,
                        style: TextStyle(
                          color: Colors.black45,
                            fontSize: AppConfig.smallFont
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                  Row(children: <Widget>[
                    Text(
                      'Sittings:',
                      style: TextStyle(fontSize: AppConfig.smallFont,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    Text(
                      catalogueData.sitting,
                      style: TextStyle(
                        color: Colors.black38,
                          fontSize: AppConfig.smallFont
                      ),
                    ),
                  ]),
                  Divider(
                    color: Colors.black45,
                  ),
                  Text(
                    'Do\'s and Don\'t:',
                    style: TextStyle(fontSize: AppConfig.smallFont,fontWeight: FontWeight.bold),
                  ),
                  Text(
                    catalogueData.dnd,
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
  Widget UpdatePricePopUp(
      {RealInsight realInsight, DocHosMainInsightBloc docHosMainInsightBloc}) {
    var sliderVal = (realInsight.userPrice.toDouble() / 2) +
        (((realInsight.userPrice.toDouble() / 2)) / 2);
    String failureCause;
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            elevation: 0.0,
            child: StreamBuilder<RequestState>(
                stream: docHosMainInsightBloc.realTimePriceUpdateStream,
                builder: (context, snapShot) {
                  if (snapShot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  if (snapShot.data is RequestSuccess) {
                    print('success req');
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      Navigator.pop(context, true);
                    });
                  }
                  if (snapShot.data is RequestFailed) {
                    RequestFailed requestFailed = snapShot.data;
                    failureCause = requestFailed.failureCause;
                    print('failure req');
                  }
                  return SingleChildScrollView(
                    reverse: true,
                    child: Container(
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
                                        realInsight?.serviceName ??
                                            PlunesStrings.NA,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54),
                                      ),
                                      SizedBox(height: 20),
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
                                            newState(() {
                                              sliderVal = newValue;
                                            });
                                          }),
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              ' \u20B9 ${(realInsight.userPrice.floor() / 2)?.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(child: Container()),
                                            Text(
                                              ' \u20B9 ${realInsight.userPrice?.toStringAsFixed(1)}',
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
                                      Text(
                                        'Chances of Booking increases by',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '20 to 25%',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
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
                                              .updateRealTimeInsightPriceStream(
                                                  RequestInProgress());
                                          docHosMainInsightBloc
                                              .getUpdateRealTimeInsightPrice(
                                                  sliderVal,
                                                  realInsight.solutionId,
                                                  realInsight.serviceId);
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
                    return CustomWidgets().getProgressIndicator();
                  }
                  if (snapShot.data is RequestSuccess) {
                    print('success req');
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      Navigator.pop(context, true);
                    });
                  }
                  if (snapShot.data is RequestFailed) {
                    RequestFailed requestFailed = snapShot.data;
                    failureCause = requestFailed.failureCause;
                    print('failure req');
                  }
                  return SingleChildScrollView(
                    reverse: true,
                    child: Container(
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
                                      Text(
                                        'Chances of Booking increases by',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '20 to 25%',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
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
                                              .updateRealTimeInsightPriceStream(
                                                  RequestInProgress());
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
                    ),
                  );
                }),
          ) ??
          false;
    });
  }

  Widget amountProgressBar(
    AppointmentModel appointmentModel,
  ) {
    num val = appointmentModel.amountPaid + appointmentModel.amountPaidCredits;
    double sliderVal = val.toDouble();
    return Container(
      child: Column(
        children: <Widget>[
          Slider(
              value: sliderVal,
              min: (0.0) ?? 0,
              max: appointmentModel.service.newPrice.first.toDouble(),
              divisions: 100,
              activeColor: Colors.green,
              onChanged: (newValue) {
                sliderVal = newValue;
              }),
          Container(
            child: Row(
              children: <Widget>[
                Text(
                  ' \u20B9 ${(0.0.floor() / 2)?.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: AppConfig.smallFont, fontWeight: FontWeight.bold),
                ),
                Expanded(child: Container()),
                Text(
                  ' \u20B9 ${appointmentModel.service.newPrice.first.toDouble()?.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: AppConfig.smallFont, fontWeight: FontWeight.bold),
                ),
              ],
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
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 8,
          vertical: AppConfig.verticalBlockSize * 21),
      child: Card(
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
              child: Column(
                children: <Widget>[
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
                                        AppConfig.horizontalBlockSize * 20),
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
                                      print("hello");
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
                                          top: AppConfig.verticalBlockSize * 1),
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
    );
  }

  void share(String shareableContent) {
    Share.share(shareableContent);
  }
}
