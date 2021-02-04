import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/models/booking_models/init_payment_response.dart';
import 'package:plunes/models/cart_models/cart_main_model.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/blocs/booking_blocs/booking_main_bloc.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/booking_models/appointment_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/actionable_insights_response_model.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/models/solution_models/test_and_procedure_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointment_main_screen.dart';
import 'package:plunes/ui/afterLogin/hos_popup_scr/real_insight_popup_scr.dart';
import 'package:plunes/ui/commonView/LocationFetch.dart';
import 'package:share/share.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:upi_pay/upi_pay.dart';
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
      {Function onButtonTap,
      TapGestureRecognizer onViewMoreTap,
      bool isTopSearches = false}) {
    return StatefulBuilder(builder: (context, newState) {
      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
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
                    crossAxisAlignment: isTopSearches
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: Colors.transparent,
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
                                    text: solutionList[index]?.service ??
                                        PlunesStrings.NA,
                                    style: TextStyle(
                                      fontSize: AppConfig.smallFont + 1,
                                      color: Colors.black,
                                      //fontWeight: FontWeight.w500
                                    ),
                                    children: [
//                                  TextSpan(
//                                      text:
//                                          "(${solutionList[index].category ?? PlunesStrings.NA})",
//                                      style: TextStyle(
//                                          fontSize: AppConfig.smallFont,
//                                          color: PlunesColors.GREENCOLOR))
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
                                        text: plunesStrings.viewMore,
                                        recognizer: onViewMoreTap,
                                        style: TextStyle(
                                            fontSize: AppConfig.verySmallFont,
                                            color: PlunesColors.GREENCOLOR)),
                                  ),
                            (!(solutionList[index].isActive) &&
                                    solutionList[index].maxDiscount != null &&
                                    solutionList[index].maxDiscount != 0 &&
                                    (solutionList[index].booked == null ||
                                        !(solutionList[index].booked)))
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
                          PlunesStrings.negotiate,
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 0,
                          AppConfig.verticalBlockSize * 1.5,
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

  Widget getTopSearchesPrevSearchedSolutionRow(
      List<CatalogueData> solutionList, int index,
      {Function onButtonTap,
      TapGestureRecognizer onViewMoreTap,
      bool isTopSearches = false}) {
    return StatefulBuilder(builder: (context, newState) {
      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
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
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Card(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 3,
                  vertical: AppConfig.verticalBlockSize * 0.8),
              color: solutionList[index].isSelected ?? false
                  ? PlunesColors.LIGHTGREENCOLOR
                  : Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Container(
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
                      crossAxisAlignment: isTopSearches
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Colors.transparent,
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
                                      text: solutionList[index]?.service ??
                                          PlunesStrings.NA,
                                      style: TextStyle(
                                        fontSize: AppConfig.smallFont + 1,
                                        color: Colors.black,
                                        //fontWeight: FontWeight.w500
                                      ),
                                      children: [
//                                    TextSpan(
//                                        text:
//                                            "(${solutionList[index].category ?? PlunesStrings.NA})",
//                                        style: TextStyle(
//                                            fontSize: AppConfig.smallFont,
//                                            color: PlunesColors.GREENCOLOR))
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
                                          text: plunesStrings.viewMore,
                                          recognizer: onViewMoreTap,
                                          style: TextStyle(
                                              fontSize: AppConfig.verySmallFont,
                                              color: PlunesColors.GREENCOLOR)),
                                    ),
                              (!(solutionList[index].isActive) &&
                                      solutionList[index].maxDiscount != null &&
                                      solutionList[index].maxDiscount != 0 &&
                                      (solutionList[index].booked == null ||
                                          !(solutionList[index].booked)))
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
                          PlunesStrings.negotiate,
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 0,
                          AppConfig.verticalBlockSize * 1.5,
                          PlunesColors.WHITECOLOR)))
              : Container(),
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
        ],
      );
    });
  }

  Widget getImageFromUrl(final String imageUrl,
      {BoxFit boxFit = BoxFit.contain, String placeHolderPath}) {
//    print("file url is $imageUrl");
    return CachedNetworkImage(
      imageUrl: imageUrl ?? PlunesStrings.NA,
      fit: boxFit,
      errorWidget: (_, str, sds) => Image.asset(
          placeHolderPath ?? PlunesImages.plunesPlaceHolderAndErrorLogo,
          fit: boxFit),
      placeholder: (_, sds) => Image.asset(
          placeHolderPath ?? PlunesImages.plunesPlaceHolderAndErrorLogo,
          fit: boxFit),
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
            fontSize: 15,
            color: textColor ?? PlunesColors.BLACKCOLOR,
          ),
        ),
      ),
    );
  }

  Widget getDoubleCommonButton(BuildContext context, DialogCallBack _callBack,
      String buttonText1, String buttonText2, double height) {
    DialogCallBack callBack = _callBack;
    return Column(
      children: <Widget>[
        Container(
          height: 0.5,
          width: double.infinity,
          color: PlunesColors.GREYCOLOR,
        ),
        Container(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                      focusColor: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(
                            context, false); // showDialog() returns false
                        callBack.dialogCallBackFunction('CANCEL');
                      },
                      child: Container(
                          width: double.infinity,
                          height: height,
                          child: Center(
                            child: Text(
                              buttonText1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.SPARKLINGGREEN),
                            ),
                          ))),
                ),
                Container(
                  height: height,
                  color: PlunesColors.GREYCOLOR,
                  width: 0.5,
                ),
                Expanded(
                  child: FlatButton(
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                      focusColor: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(context);
                        _callBack.dialogCallBackFunction('DONE');
                      },
                      child: Container(
                          width: double.infinity,
                          height: height,
                          alignment: Alignment.center,
                          child: Center(
                            child: Text(
                              buttonText2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.SPARKLINGGREEN),
                            ),
                          ))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getSingleCommonButton(BuildContext context, String text) {
    return Column(children: <Widget>[
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
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                  height: AppConfig.verticalBlockSize * 6,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.mediumFont,
                          color: PlunesColors.SPARKLINGGREEN),
                    ),
                  ))),
        ),
      ),
    ]);
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

  Widget errorWidget(String failureCause,
      {Function onTap,
      String buttonText,
      bool isSizeLess = false,
      bool shouldNotShowImage = false,
      String imagePath}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          shouldNotShowImage
              ? Container()
              : Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2.5),
                  child: Image.asset(
                    imagePath ?? PlunesImages.noServiceAvailable,
                    height: AppConfig.verticalBlockSize * 14,
                    width: AppConfig.horizontalBlockSize * 45,
                  ),
                ),
          Text(
            failureCause ?? plunesStrings.somethingWentWrong,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.w400,
                fontSize: 18),
          ),
          onTap != null
              ? Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 2.5,
                      horizontal: isSizeLess
                          ? AppConfig.horizontalBlockSize * 30
                          : AppConfig.horizontalBlockSize * 35),
                  child: InkWell(
                    onTap: onTap,
                    child: getRoundedButton(
                        buttonText ?? PlunesStrings.refresh,
                        AppConfig.horizontalBlockSize * 8,
                        PlunesColors.GREENCOLOR,
                        AppConfig.horizontalBlockSize * 0,
                        AppConfig.verticalBlockSize * 1.5,
                        PlunesColors.WHITECOLOR),
                  ),
                )
              : Container()
        ],
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
                    testAndProcedures[index]?.sId ?? PlunesStrings.NA,
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontWeight: FontWeight.w500),
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

  Widget getRightFacingWidget() {
    return Icon(
      Icons.chevron_right,
      color: PlunesColors.GREENCOLOR,
    );
  }

  Widget getDocDetailWidget(
      List<Services> solutions,
      int index,
      Function checkAvailability,
      Function onBookingTap,
      CatalogueData catalogueData,
      BuildContext context,
      Function viewProfile,
      int currentStep,
      StreamController timerStream) {
    if (currentStep == null || currentStep >= 33) {
      currentStep = 32;
    }
    return Card(
      elevation: 2.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      margin: EdgeInsets.symmetric(
          vertical: AppConfig.verticalBlockSize * 1.2,
          horizontal: AppConfig.horizontalBlockSize * 1.8),
      child: Container(
//        color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
        padding: EdgeInsets.symmetric(
            vertical: AppConfig.verticalBlockSize * 2.5,
            horizontal: AppConfig.horizontalBlockSize * 2.5),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () => viewProfile(),
                  onDoubleTap: () {},
                  child: (solutions[index].imageUrl != null &&
                          solutions[index].imageUrl.isNotEmpty &&
                          solutions[index].imageUrl.contains("http"))
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            height: AppConfig.horizontalBlockSize * 14,
                            width: AppConfig.horizontalBlockSize * 14,
                            child: ClipOval(
                                child: getImageFromUrl(
                                    solutions[index].imageUrl,
                                    boxFit: BoxFit.fill,
                                    placeHolderPath: (solutions[index]
                                                .userType
                                                .toLowerCase() ==
                                            Constants.doctor
                                                .toString()
                                                .toLowerCase())
                                        ? PlunesImages.doc_placeholder
                                        : PlunesImages.hospitalImage)),
                          ),
                          radius: AppConfig.horizontalBlockSize * 7,
                        )
                      : getProfileIconWithName(
                          solutions[index].name,
                          14,
                          14,
                        ),
                ),
                Flexible(
                    child: Container(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            child: InkWell(
                              onTap: () => viewProfile(),
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * .5),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  solutions[index]?.name ?? PlunesStrings.NA,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: PlunesColors.BLACKCOLOR,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
//                          Flexible(
//                            child: Container(
//                                alignment: Alignment.topLeft,
//                                height: AppConfig.verticalBlockSize * 3,
//                                width: AppConfig.horizontalBlockSize * 5,
//                                child:
//                                    Image.asset(PlunesImages.certifiedImage)),
//                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: AppConfig.horizontalBlockSize * 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            (solutions[index] != null &&
                                    solutions[index].experience != null &&
                                    solutions[index].experience > 0)
                                ? Text(
                                    "${solutions[index].experience > 100 ? "100+" : solutions[index].experience} ${PlunesStrings.yrExp}",
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: PlunesColors.GREYCOLOR,
                                    ),
                                  )
                                : Container(),
                            !(solutions[index] != null &&
                                    solutions[index].experience != null &&
                                    solutions[index].experience > 0)
                                ? Container(
                                    height: AppConfig.verticalBlockSize * 3,
                                    width: AppConfig.horizontalBlockSize * 5,
                                    child:
                                        Image.asset(plunesImages.locationIcon))
                                : Container(),
                            !(solutions[index] != null &&
                                    solutions[index].experience != null &&
                                    solutions[index].experience > 0)
                                ? Text(
                                    "${solutions[index].distance?.toStringAsFixed(1) ?? _getEmptyString()}kms",
                                    style: TextStyle(
                                        color: PlunesColors.GREYCOLOR,
                                        fontSize: 10),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                Container(
                  margin:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 5),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            color: PlunesColors.GREENCOLOR,
                          ),
                          Text(
                            solutions[index].rating?.toStringAsFixed(1) ??
                                _getEmptyString(),
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 14),
                          ),
                        ],
                      ),
                      !(solutions[index] != null &&
                              solutions[index].experience != null &&
                              solutions[index].experience > 0)
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 1),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      height: AppConfig.verticalBlockSize * 3,
                                      width: AppConfig.horizontalBlockSize * 5,
                                      child: Image.asset(
                                          plunesImages.locationIcon)),
                                  Text(
                                    "${solutions[index].distance?.toStringAsFixed(1) ?? _getEmptyString()}kms",
                                    style: TextStyle(
                                        color: PlunesColors.GREYCOLOR,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            )
                    ],
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2,
                  horizontal: AppConfig.horizontalBlockSize * 3),
              child: Row(
                children: List.generate(
                    500 ~/ 4,
                    (index) => Expanded(
                          child: Container(
                            color: index % 2 == 0
                                ? Colors.transparent
                                : PlunesColors.LIGHTGREYCOLOR,
                            height: 2,
                          ),
                        )),
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: RichText(
                                text: TextSpan(
                                    text: (solutions[index].price == null ||
                                            solutions[index].price.isEmpty ||
                                            solutions[index]?.price[0] ==
                                                solutions[index]?.newPrice[0])
                                        ? ""
                                        : "\u20B9${solutions[index].price[0]?.toStringAsFixed(0) ?? PlunesStrings.NA} ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: solutions[index].negotiating
                                            ? PlunesColors.BLACKCOLOR
                                            : PlunesColors.GREYCOLOR,
                                        decoration: solutions[index].negotiating
                                            ? TextDecoration.none
                                            : TextDecoration.lineThrough),
                                    children: <TextSpan>[
                                  TextSpan(
                                    text: solutions[index].negotiating
                                        ? ""
                                        : " \u20B9${solutions[index].newPrice[0]?.toStringAsFixed(2) ?? PlunesStrings.NA}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: PlunesColors.BLACKCOLOR,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none),
                                  )
                                ])),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 1)),
                          solutions[index].negotiating
                              ? Container()
                              : ((solutions[index].price.isEmpty) ||
                                      (solutions[index].newPrice.isEmpty) ||
                                      solutions[index].price[0] ==
                                          solutions[index].newPrice[0])
                                  ? Container()
                                  : Text(
                                      (solutions[index].discount == null ||
                                              solutions[index].discount == 0 ||
                                              solutions[index].discount < 0)
                                          ? ""
                                          : " ${PlunesStrings.save} \u20B9 ${(solutions[index].price[0] - solutions[index].newPrice[0])?.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: PlunesColors.GREENCOLOR),
                                    )
                        ],
                      ),
                      ((solutions[index].homeCollection != null &&
                                  solutions[index].homeCollection) &&
                              !(solutions[index].negotiating))
                          ? Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 4),
                              alignment: Alignment.topLeft,
                              child: Text(
                                PlunesStrings.homeCollectionAvailable,
                                style: TextStyle(
                                    color: PlunesColors.GREYCOLOR,
                                    fontSize: 13.5),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: InkWell(
                      onTap:
                          solutions[index].negotiating ? () {} : onBookingTap,
                      child: getRoundedButton(
                          solutions[index].bookIn == null
                              ? PlunesStrings.book
                              : "${PlunesStrings.bookIn} ${solutions[index].bookIn}",
                          AppConfig.horizontalBlockSize * 8,
                          solutions[index].negotiating
                              ? PlunesColors.GREYCOLOR
                              : PlunesColors.SPARKLINGGREEN,
                          AppConfig.horizontalBlockSize * 3,
                          AppConfig.verticalBlockSize * 1,
                          PlunesColors.WHITECOLOR)),
                ),
              ],
            ),
            solutions[index].negotiating
                ? Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                    child: Text(
                      PlunesStrings.negotiating,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                  )
                : Container(),
            solutions[index].negotiating
                ? Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                    child: StreamBuilder<Object>(
                        stream: timerStream.stream,
                        builder: (context, snapshot) {
                          return StepProgressIndicator(
                            totalSteps: 33,
                            currentStep: currentStep,
                            size: 8,
                            padding: 0,
                            selectedColor: PlunesColors.GREENCOLOR,
                            unselectedColor: Color(
                                CommonMethods.getColorHexFromStr("#E4EAF0")),
                            roundedEdges: Radius.circular(10),
                          );
                        }),
                  )
                : Container(),
          ],
        ),
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
    return SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Container(
        margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
        alignment: Alignment.center,
        child: Text(
          'Details',
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: AppConfig.mediumFont),
        ),
      ),
      SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 7,
              vertical: AppConfig.verticalBlockSize * 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Definition:',
                style: TextStyle(
                    fontSize: AppConfig.smallFont, fontWeight: FontWeight.w600),
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
                    'Duration:',
                    style: TextStyle(
                        fontSize: AppConfig.smallFont,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 5),
                  Text(
                    catalogueData?.duration ?? PlunesStrings.NA,
                    style: TextStyle(
                        color: Colors.black45, fontSize: AppConfig.smallFont),
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
                      fontWeight: FontWeight.w600),
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
                'Do\'s and Don\'ts:',
                style: TextStyle(
                    fontSize: AppConfig.smallFont, fontWeight: FontWeight.w600),
              ),
              Container(
                margin:
                    EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2),
                child: Text(
                  catalogueData?.dnd?.replaceAll(replaceFrom, "") ??
                      PlunesStrings.NA,
                  style: TextStyle(
                    fontSize: AppConfig.smallFont,
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      CustomWidgets().getSingleCommonButton(context, 'Close')
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
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Color(CommonMethods.getColorHexFromStr("#00427B"))),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: ExactAssetImage(
                          PlunesImages.technologyBackground,
                        ),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(16.0)),
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
                        Future.delayed(Duration(milliseconds: 200))
                            .then((value) {
                          Navigator.pop(context, true);
                        });
                      }
                      if (snapShot.data is RequestFailed) {
                        RequestFailed requestFailed = snapShot.data;
                        String failureCause = requestFailed.failureCause;
                        return SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#00427B")),
                                borderRadius: BorderRadius.circular(16.0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 3),
                                  height: AppConfig.verticalBlockSize * 10,
                                  child: Image.asset(
                                      PlunesImages.plunesCommonGreenBgImage),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical:
                                          AppConfig.verticalBlockSize * 2.5),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 3),
                                  child: Text(
                                    failureCause ??
                                        plunesStrings.somethingWentWrong,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: PlunesColors.WHITECOLOR,
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
                                        splashColor: PlunesColors.SPARKLINGGREEN
                                            .withOpacity(.1),
                                        focusColor: Colors.transparent,
                                        onPressed: () => Navigator.pop(context),
                                        child: Container(
                                            height:
                                                AppConfig.verticalBlockSize * 6,
                                            width: double.infinity,
                                            child: Center(
                                              child: Text(
                                                'OK',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize:
                                                        AppConfig.mediumFont,
                                                    color: PlunesColors
                                                        .SPARKLINGGREEN),
                                              ),
                                            ))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        controller: _scrollController,
                        reverse: shouldShowField
                            ? true
                            : (failureCause != null && failureCause.isNotEmpty)
                                ? true
                                : false,
                        child: Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 3),
                                child: Text(PlunesStrings.realTimePrediction,
                                    style: TextStyle(
                                        fontSize: AppConfig.extraLargeFont,
                                        color: PlunesColors.WHITECOLOR,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 3),
                                padding: EdgeInsets.only(
                                    left: AppConfig.horizontalBlockSize * 3,
                                    right: AppConfig.horizontalBlockSize * 3,
                                    top: AppConfig.verticalBlockSize * 4.0,
                                    bottom: AppConfig.verticalBlockSize * 2),
                                child: Text(
                                  'Update your best price for maximum bookings',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: AppConfig.mediumFont),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            AppConfig.horizontalBlockSize * 3),
                                    child: Text(
                                      realInsight?.serviceName ??
                                          PlunesStrings.NA,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppConfig.mediumFont,
                                      ),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: AppConfig.verticalBlockSize * 2,
                                          left:
                                              AppConfig.horizontalBlockSize * 3,
                                          right: AppConfig.horizontalBlockSize *
                                              3),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            (chancesPercent == null ||
                                                    chancesPercent == 0 ||
                                                    chancesPercent < 0)
                                                ? '0%'
                                                : '${chancesPercent.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: AppConfig.mediumFont,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            AppConfig.horizontalBlockSize * 3),
                                    child: Slider(
                                      value: sliderVal,
                                      min:
                                          (realInsight.userPrice.floor() / 2) ??
                                              0,
                                      max: realInsight.userPrice
                                          .floor()
                                          .toDouble(),
                                      divisions: 100,
                                      activeColor: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#F39A83")),
                                      inactiveColor: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#F8F4FF")),
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

                                            chancesPercent = double.tryParse(
                                                (100 - val)
                                                    ?.toStringAsFixed(1));
                                          } catch (e) {
                                            chancesPercent = 50;
                                            reductionInPrice = 50;
                                          }
                                          sliderVal = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            AppConfig.horizontalBlockSize * 3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          ' \u20B9 ${(realInsight.userPrice.floor() / 2)?.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: AppConfig.mediumFont,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          ' \u20B9 ${realInsight.userPrice?.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: AppConfig.mediumFont,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical:
                                              AppConfig.verticalBlockSize * 3,
                                          horizontal:
                                              AppConfig.horizontalBlockSize *
                                                  3),
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              AppConfig.horizontalBlockSize *
                                                  15),
                                      child: (realInsight.suggested != null &&
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
                                                        TextInputType.number,
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .bottom,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                    ),
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
                                                    alignment:
                                                        Alignment.bottomRight,
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
                                              mainAxisAlignment: (realInsight
                                                              .suggested !=
                                                          null &&
                                                      realInsight.suggested &&
                                                      shouldShowField)
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Flexible(
                                                  flex: 2,
                                                  child: Text(
                                                    ' \u20B9 ${sliderVal.toStringAsFixed(1)}',
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize:
                                                            AppConfig.largeFont,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                (realInsight.suggested !=
                                                            null &&
                                                        realInsight.suggested)
                                                    ? Flexible(
                                                        child: InkWell(
                                                        onTap: () {
                                                          shouldShowField =
                                                              true;
                                                          newState(() {});
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child: Icon(
                                                            Icons.mode_edit,
                                                            color: PlunesColors
                                                                .WHITECOLOR,
                                                          ),
                                                        ),
                                                      ))
                                                    : Container()
                                              ],
                                            )),
                                  chancesPercent != null
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  AppConfig.verticalBlockSize *
                                                      2,
                                              left: AppConfig
                                                      .horizontalBlockSize *
                                                  3,
                                              right: AppConfig
                                                      .horizontalBlockSize *
                                                  3),
                                          child: Text(
                                            'Chances of Booking increases by',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: AppConfig.mediumFont,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  Container(
                                    margin: EdgeInsets.only(
                                        bottom:
                                            AppConfig.verticalBlockSize * 3),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            tileMode: TileMode.clamp,
                                            colors: [
                                              Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#EBCB7F")),
                                              Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#F39A83")),
                                              Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#C000A6"))
                                            ])),
                                    padding: EdgeInsets.all(
                                        AppConfig.horizontalBlockSize * 3),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: AppConfig.horizontalBlockSize * 3,
                                        right:
                                            AppConfig.horizontalBlockSize * 3,
                                      ),
                                      child: chancesPercent != null
                                          ? Text(
                                              chancesPercent == 0 ||
                                                      chancesPercent < 0
                                                  ? '0%'
                                                  : '${chancesPercent.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize:
                                                      AppConfig.mediumFont,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          : Container(),
                                      padding: EdgeInsets.all(
                                          AppConfig.horizontalBlockSize * 8),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#23407A"))),
                                    ),
                                  ),
                                  failureCause != null
                                      ? Container(
                                          child: Text(
                                            failureCause,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: AppConfig.smallFont,
                                                color: Color(CommonMethods
                                                    .getColorHexFromStr(
                                                        "#FF9194")),
                                                fontWeight: FontWeight.w600),
                                          ),
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  AppConfig.verticalBlockSize *
                                                      3))
                                      : Container(),
                                  Container(
                                    height: 0.5,
                                    width: double.infinity,
                                    color: PlunesColors.GREYCOLOR,
                                  ),
                                  Container(
                                    height: AppConfig.verticalBlockSize * 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#00427B")),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16)),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            child: FlatButton(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                focusColor: Colors.transparent,
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  return;
                                                },
                                                child: Container(
                                                    height: AppConfig
                                                            .verticalBlockSize *
                                                        8,
                                                    width: double.infinity,
                                                    child: Center(
                                                      child: Text(
                                                        'Cancel',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: AppConfig
                                                                .largeFont,
                                                            color: PlunesColors
                                                                .WHITECOLOR),
                                                      ),
                                                    ))),
                                          ),
                                          Container(
                                            height:
                                                AppConfig.verticalBlockSize * 8,
                                            color: PlunesColors.GREYCOLOR,
                                            width: 0.5,
                                          ),
                                          Expanded(
                                            child: FlatButton(
                                                focusColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onPressed: () {
                                                  if (realInsight.suggested !=
                                                          null &&
                                                      realInsight.suggested &&
                                                      shouldShowField) {
                                                    if (_priceController.text
                                                            .trim()
                                                            .isEmpty ||
                                                        _priceController.text
                                                                .trim()
                                                                .substring(0) ==
                                                            "0" ||
                                                        (double.tryParse(
                                                                _priceController
                                                                    .text
                                                                    .trim()) <
                                                            1)) {
                                                      failureCause =
                                                          'Price must not be lesser than 1 or empty';
                                                      newState(() {});
                                                      return;
                                                    }
                                                    docHosMainInsightBloc
                                                        .updateRealTimeInsightPriceStream(
                                                            RequestInProgress());
                                                    docHosMainInsightBloc
                                                        .getUpdateRealTimeInsightPrice(
                                                            num.tryParse(
                                                                _priceController
                                                                    .text
                                                                    .trim()),
                                                            realInsight
                                                                .solutionId,
                                                            realInsight
                                                                .serviceId,
                                                            isSuggestive: true,
                                                            suggestedPrice:
                                                                num.tryParse(
                                                                    _priceController
                                                                        .text
                                                                        .trim()));
                                                  } else {
                                                    if (sliderVal == null ||
                                                        sliderVal == 0) {
                                                      failureCause =
                                                          'Price must not be 0.';
                                                      newState(() {});
                                                      return;
                                                    } else if (sliderVal ==
                                                        realInsight.userPrice) {
                                                      failureCause =
                                                          'Sorry, Make sure Updated Price is not equal to Original Price !';
                                                      newState(() {});
                                                      return;
                                                    }
                                                    docHosMainInsightBloc
                                                        .updateRealTimeInsightPriceStream(
                                                            RequestInProgress());
                                                    docHosMainInsightBloc
                                                        .getUpdateRealTimeInsightPrice(
                                                            chancesPercent,
                                                            realInsight
                                                                .solutionId,
                                                            realInsight
                                                                .serviceId,
                                                            isSuggestive: (realInsight
                                                                        .suggested !=
                                                                    null &&
                                                                realInsight
                                                                    .suggested),
                                                            suggestedPrice:
                                                                sliderVal);
                                                  }
                                                },
                                                child: Container(
                                                    height: AppConfig
                                                            .verticalBlockSize *
                                                        8,
                                                    width: double.infinity,
                                                    child: Center(
                                                      child: Text(
                                                        'Apply here',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: AppConfig
                                                                .largeFont,
                                                            color: PlunesColors
                                                                .GREENCOLOR),
                                                      ),
                                                    ))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ) ??
          false;
    });
  }

  // ignore: non_constant_identifier_names
  Widget UpdatePricePopUpForActionableInsight(
      {ActionableInsight actionableInsight,
      DocHosMainInsightBloc docHosMainInsightBloc,
      String centreId}) {
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
    TextEditingController _priceController = TextEditingController();
    bool shouldShowField = false;
    ScrollController _scrollController = ScrollController();
    String failureCause;
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
            insetPadding: EdgeInsets.only(top: 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            elevation: 0.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(PlunesImages.insight_bg_img),
                      fit: BoxFit.fill)),
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(16.0),
              //     color: Color(CommonMethods.getColorHexFromStr("#00427B"))),
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
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Container(
                        margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 3,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.topCenter,
                                    margin: EdgeInsets.only(
                                        left:
                                            AppConfig.horizontalBlockSize * 5),
                                    child: Text(
                                      'Update Price in your Catalogue for maximum Bookings',
                                      style: TextStyle(
                                          fontSize: AppConfig.largeFont,
                                          color: PlunesColors.WHITECOLOR),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 5),
                                    child: Icon(
                                      Icons.close,
                                      color: PlunesColors.WHITECOLOR,
                                    ),
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                            Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: AppConfig.verticalBlockSize * 2,
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 3,
                                  ),
                                  child: Text(
                                    actionableInsight?.serviceName ??
                                        PlunesStrings.NA,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: AppConfig.mediumFont,
                                        color: Colors.white70),
                                  ),
                                ),
                                // Container(
                                //     margin: EdgeInsets.symmetric(
                                //         horizontal:
                                //             AppConfig.horizontalBlockSize * 3),
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.end,
                                //       children: <Widget>[
                                //         Text(
                                //           (chancesPercent == null ||
                                //                   chancesPercent == 0 ||
                                //                   chancesPercent < 0)
                                //               ? '0%'
                                //               : '${chancesPercent.toStringAsFixed(0)}%',
                                //           style: TextStyle(
                                //               color: PlunesColors.WHITECOLOR,
                                //               fontSize: AppConfig.mediumFont,
                                //               fontWeight: FontWeight.w600),
                                //         ),
                                //       ],
                                //     )),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 3),
                                  child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Color.lerp(
                                            Color(CommonMethods
                                                .getColorHexFromStr("#CEFFE2")),
                                            Color(CommonMethods
                                                .getColorHexFromStr("#01D35A")),
                                            0.7),
                                        inactiveTrackColor:
                                            PlunesColors.WHITECOLOR,
                                        trackShape:
                                            RoundedRectSliderTrackShape(),
                                        trackHeight: 8.5,
                                        thumbColor:
                                            PlunesColors.LIGHTGREENCOLOR,
                                        thumbShape: SliderThumbShape(
                                          enabledThumbRadius: 8,
                                        ),
                                        overlayColor: PlunesColors.GREENCOLOR
                                            .withAlpha(32),
                                        overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: 28.0),
                                      ),
                                      child: Slider(
                                          value: sliderVal,
                                          min: (actionableInsight.userPrice !=
                                                  null)
                                              ? num.tryParse(
                                                      (num.parse(actionableInsight
                                                                      .userPrice)
                                                                  .floor() /
                                                              2)
                                                          ?.toStringAsFixed(0))
                                                  .toDouble()
                                              : 0,
                                          max: (actionableInsight.userPrice !=
                                                  null)
                                              ? num.tryParse(num.parse(
                                                          actionableInsight.userPrice)
                                                      .toStringAsFixed(0))
                                                  .toDouble()
                                              : 0,
                                          divisions: 100,
                                          onChanged: (newValue) {
                                            if (shouldShowField) {
                                              return;
                                            }
                                            newState(() {
                                              try {
                                                var val = (newValue * 100) /
                                                    num.parse(actionableInsight
                                                            .userPrice)
                                                        .floor()
                                                        .toDouble();
                                                chancesPercent =
                                                    double.tryParse((100 - val)
                                                        ?.toStringAsFixed(1));
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
                                          })),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        ' \u20B9 ${(num.parse(actionableInsight.userPrice).floor() / 2)?.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Expanded(
                                          child: Container(
                                        alignment: Alignment.topCenter,
                                        child: Column(
                                          children: <Widget>[
                                            Icon(
                                              Icons.arrow_drop_up,
                                              color: PlunesColors.GREENCOLOR,
                                              size: AppConfig.extraLargeFont,
                                            ),
                                            Text(
                                              'Recommended',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      AppConfig.mediumFont - 1,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      )),
                                      Text(
                                        ' \u20B9 ${num.parse(actionableInsight.userPrice)?.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: AppConfig.verticalBlockSize * 3,
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 17),
                                  child: shouldShowField
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                              child: TextField(
                                                controller: _priceController,
                                                inputFormatters: [
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                maxLines: 1,
                                                autofocus: true,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlignVertical:
                                                    TextAlignVertical.bottom,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Icon(
                                                  Icons.mode_edit,
                                                  size: AppConfig.largeFont,
                                                  color:
                                                      PlunesColors.GREENCOLOR,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                ' \u20B9 ${sliderVal.toStringAsFixed(1)}',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                shouldShowField = true;
                                                newState(() {});
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                child: Icon(
                                                  Icons.mode_edit,
                                                  size: AppConfig.largeFont,
                                                  color:
                                                      PlunesColors.WHITECOLOR,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                                chancesPercent != null
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            bottom:
                                                AppConfig.verticalBlockSize * 2,
                                            left:
                                                AppConfig.horizontalBlockSize *
                                                    3,
                                            right:
                                                AppConfig.horizontalBlockSize *
                                                    3),
                                        child: Text(
                                          'Chances of Booking increases by',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: AppConfig.mediumFont,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  width: AppConfig.horizontalBlockSize * 40,
                                  height: AppConfig.verticalBlockSize * 12.5,
                                  child: SfRadialGauge(axes: <RadialAxis>[
                                    RadialAxis(
                                        pointers: [
                                          RangePointer(
                                              value: chancesPercent == null ||
                                                      chancesPercent == 0 ||
                                                      chancesPercent < 0
                                                  ? 0
                                                  : double.parse(chancesPercent
                                                      .toStringAsFixed(0)),
                                              width: 0.25,
                                              sizeUnit: GaugeSizeUnit.factor,
                                              cornerStyle: CornerStyle.bothFlat,
                                              gradient: SweepGradient(
                                                  colors: <Color>[
                                                    PlunesColors.GREENCOLOR,
                                                    PlunesColors.GREENCOLOR
                                                  ],
                                                  stops: <double>[
                                                    0.25,
                                                    0.75
                                                  ])),
                                        ],
                                        minimum: 0,
                                        maximum: 50,
                                        showLabels: false,
                                        showTicks: false,
                                        startAngle: 270,
                                        endAngle: 270,
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                              positionFactor: 0.1,
                                              angle: 90,
                                              widget: Text(
                                                chancesPercent == null ||
                                                        chancesPercent == 0 ||
                                                        chancesPercent < 0
                                                    ? "0 %"
                                                    : "${chancesPercent.toStringAsFixed(0)} %",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: PlunesColors
                                                        .WHITECOLOR),
                                              ))
                                        ])
                                  ]),
                                ),

                                // Container(
                                //   margin: EdgeInsets.only(
                                //       bottom: AppConfig.verticalBlockSize * 3),
                                //   child: Container(
                                //     child: chancesPercent != null
                                //         ? Text(
                                //             (chancesPercent == null ||
                                //                     chancesPercent == 0 ||
                                //                     chancesPercent < 0)
                                //                 ? '0%'
                                //                 : '${chancesPercent.toStringAsFixed(0)}%',
                                //             style: TextStyle(
                                //                 color: Colors.white70,
                                //                 fontSize: AppConfig.mediumFont,
                                //                 fontWeight: FontWeight.w600),
                                //           )
                                //         : Container(),
                                //     padding: EdgeInsets.all(
                                //         AppConfig.horizontalBlockSize * 8),
                                //     decoration: BoxDecoration(
                                //         shape: BoxShape.circle,
                                //         color: Color(
                                //             CommonMethods.getColorHexFromStr(
                                //                 "#23407A"))),
                                //   ),
                                //   decoration: BoxDecoration(
                                //       shape: BoxShape.circle,
                                //       gradient: LinearGradient(
                                //           begin: Alignment.topLeft,
                                //           end: Alignment.bottomRight,
                                //           tileMode: TileMode.clamp,
                                //           colors: [
                                //             Color(CommonMethods
                                //                 .getColorHexFromStr("#EBCB7F")),
                                //             Color(CommonMethods
                                //                 .getColorHexFromStr("#F39A83")),
                                //             Color(CommonMethods
                                //                 .getColorHexFromStr("#C000A6"))
                                //           ])),
                                //   padding: EdgeInsets.all(
                                //       AppConfig.horizontalBlockSize * 3),
                                // ),
                                failureCause != null
                                    ? Container(
                                        child: Text(
                                          failureCause,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: AppConfig.smallFont,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#FF9194")),
                                              fontWeight: FontWeight.w600),
                                        ),
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.symmetric(
                                            vertical:
                                                AppConfig.verticalBlockSize *
                                                    1.5))
                                    : Container(),
                                SizedBox(
                                  height: 0.5,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (shouldShowField) {
                                      double value = double.tryParse(
                                          _priceController.text.trim());
                                      if (value == null ||
                                          value == 0 ||
                                          value < 1) {
                                        failureCause =
                                            'Price must be greater than 0';
                                        newState(() {});
                                        return;
                                      }
                                      docHosMainInsightBloc
                                          .getUpdateActionableInsightPrice(
                                              value,
                                              actionableInsight.serviceId,
                                              actionableInsight.specialityId,
                                              centreId: centreId);
                                    } else {
                                      if (sliderVal == null || sliderVal == 0) {
                                        failureCause = 'Price must not be 0';
                                        newState(() {});
                                        return;
                                      } else if (sliderVal.toStringAsFixed(0) ==
                                          num.parse(actionableInsight.userPrice)
                                              .toStringAsFixed(0)) {
                                        failureCause =
                                            'Sorry, Make sure Updated Price is not equal to Original Price !';
                                        newState(() {});
                                        return;
                                      }
                                      docHosMainInsightBloc
                                          .getUpdateActionableInsightPrice(
                                              sliderVal,
                                              actionableInsight.serviceId,
                                              actionableInsight.specialityId,
                                              centreId: centreId);
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                        'Apply here',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: AppConfig.largeFont + 2,
                                            fontWeight: FontWeight.w600,
                                            color: PlunesColors.GREENCOLOR),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ) ??
          false;
    });
  }

  Widget amountProgressBar(AppointmentModel appointmentModel) {
    double percentage = 0;
    if (appointmentModel.paidBookingAmount != null &&
        appointmentModel.paidBookingAmount >= 0 &&
        appointmentModel.totalAmount != null &&
        appointmentModel.totalAmount >= 0) {
      percentage =
          appointmentModel.paidBookingAmount / appointmentModel.totalAmount;
//      print("percentage $percentage");
    }
    if (percentage > 1) {
      percentage = 1.0;
    }
    return (appointmentModel.paidBookingAmount != null &&
            appointmentModel.paidBookingAmount >= 0 &&
            appointmentModel.totalAmount != null &&
            appointmentModel.totalAmount >= 0)
        ? Container(
            child: Column(
              children: <Widget>[
                (appointmentModel.paidBookingAmount != null &&
                        appointmentModel.totalAmount != null &&
                        appointmentModel.paidBookingAmount ==
                            appointmentModel.totalAmount)
                    ? LinearPercentIndicator(
                        percent: 1.0,
                        animationDuration: 800,
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        animation: true,
                        lineHeight: 10.0,
                        progressColor: PlunesColors.GREENCOLOR,
                        backgroundColor:
                            PlunesColors.GREYCOLOR.withOpacity(0.4),
//                  width: double.infinity,
                      )
                    : LinearPercentIndicator(
                        percent: percentage,
                        animationDuration: 800,
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        animation: true,
                        lineHeight: 10.0,
                        progressColor: PlunesColors.GREENCOLOR,
                        backgroundColor:
                            PlunesColors.GREYCOLOR.withOpacity(0.4),
//                  width: double.infinity,
                      ),
                Container(
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 2,
                      right: AppConfig.horizontalBlockSize * 2,
                      top: AppConfig.verticalBlockSize * 1.5),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              PlunesStrings.amountPaidText,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "\u20B9${appointmentModel.paidBookingAmount?.toStringAsFixed(1) ?? 0}",
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                PlunesStrings.totalAmountText,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                "\u20B9${appointmentModel.totalAmount?.toStringAsFixed(1) ?? 0}",
                                maxLines: 2,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : Container();
  }

  refundPopup(BookingBloc bookingBloc, AppointmentModel appointmentModel) {
    TextEditingController textEditingController = TextEditingController();
    bool isSuccess = false;
    String failureMessage;
    return AnimatedContainer(
      padding: AppConfig.getMediaQuery().viewInsets,
      duration: const Duration(milliseconds: 300),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StreamBuilder<RequestState>(
          stream: bookingBloc.refundAppointmentStream,
          builder: (BuildContext context, snapshot) {
            if (snapshot.data != null && snapshot.data is RequestInProgress) {
              return Container(
                  height: AppConfig.horizontalBlockSize * 55,
                  width: AppConfig.horizontalBlockSize * 70,
                  child: CustomWidgets().getProgressIndicator());
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
              child: isSuccess
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 3,
                                horizontal: AppConfig.horizontalBlockSize * 6),
                            height: AppConfig.verticalBlockSize * 10,
                            child: Image.asset(PlunesImages.refundImage)),
                        Container(
                          margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 5,
                              right: AppConfig.horizontalBlockSize * 5,
                              bottom: AppConfig.verticalBlockSize * 5),
                          child: Text(PlunesStrings.refundSuccessMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.GREYCOLOR)),
                        ),
                        CustomWidgets().getSingleCommonButton(context, 'Ok')
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(
                                right: AppConfig.horizontalBlockSize * 6,
                                left: AppConfig.horizontalBlockSize * 6,
                                top: AppConfig.verticalBlockSize * 3),
                            height: AppConfig.verticalBlockSize * 10,
                            child: Image.asset(PlunesImages.refundImage)),
                        Container(
                          margin: EdgeInsets.only(
                              right: AppConfig.horizontalBlockSize * 6,
                              left: AppConfig.horizontalBlockSize * 6,
                              top: AppConfig.verticalBlockSize * 1,
                              bottom: AppConfig.verticalBlockSize * 2),
                          child: Text(PlunesStrings.refund,
                              style: TextStyle(
                                  fontSize: AppConfig.largeFont,
                                  fontWeight: FontWeight.w500,
                                  color: PlunesColors.BLACKCOLOR)),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 6),
                            child: Text(
                                'Kindly Share the reason for your refund so our team can help you better',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: AppConfig.smallFont,
                                    color: PlunesColors.GREYCOLOR))),
                        Container(
                          margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 6,
                              right: AppConfig.horizontalBlockSize * 6,
                              bottom: AppConfig.verticalBlockSize * 1.5),
                          child: TextField(
                            controller: textEditingController,
                            maxLines: 2,
                            autofocus: false,
                            maxLength: 250,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                                hintText: 'Write here',
                                counterText: "",
                                errorText: failureMessage ?? "",
                                errorMaxLines: 2,
                                errorStyle: TextStyle(color: Colors.red),
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red),
                                ),
                                disabledBorder: UnderlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(
                                      width: 1, color: PlunesColors.GREENCOLOR),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.green),
                                ),
                                border: UnderlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    borderSide: BorderSide(
                                      width: 1,
                                    )),
                                errorBorder: UnderlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black)),
                                focusedErrorBorder: UnderlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: PlunesColors.GREENCOLOR)),
                                hintStyle: TextStyle(
                                    fontSize: AppConfig.smallFont,
                                    color: PlunesColors.GREYCOLOR)),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: FlatButton(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: PlunesColors.SPARKLINGGREEN
                                          .withOpacity(.1),
                                      focusColor: Colors.transparent,
                                      onPressed: () {
                                        Navigator.pop(context);
                                        return;
                                      },
                                      child: Container(
                                          height:
                                              AppConfig.verticalBlockSize * 6,
                                          width: double.infinity,
                                          child: Center(
                                            child: Text(
                                              'Cancel',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      AppConfig.mediumFont,
                                                  color: PlunesColors
                                                      .SPARKLINGGREEN),
                                            ),
                                          ))),
                                ),
                                Container(
                                  height: AppConfig.verticalBlockSize * 6,
                                  color: PlunesColors.GREYCOLOR,
                                  width: 0.5,
                                ),
                                Expanded(
                                  child: FlatButton(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: PlunesColors.SPARKLINGGREEN
                                          .withOpacity(.1),
                                      focusColor: Colors.transparent,
                                      onPressed: () {
                                        if (appointmentModel != null &&
                                            textEditingController.text
                                                .trim()
                                                .isNotEmpty) {
                                          bookingBloc.refundAppointment(
                                              appointmentModel.bookingId,
                                              textEditingController.text
                                                  .trim());
                                        } else if (textEditingController.text
                                            .trim()
                                            .isEmpty) {
                                          failureMessage = PlunesStrings
                                              .emptyTextFieldWarning;
                                          bookingBloc
                                              .addStateInRefundProvider(null);
                                        }
                                      },
                                      child: Container(
                                          height:
                                              AppConfig.verticalBlockSize * 6,
                                          width: double.infinity,
                                          child: Center(
                                            child: Text(
                                              'Submit',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      AppConfig.mediumFont,
                                                  color: PlunesColors
                                                      .SPARKLINGGREEN),
                                            ),
                                          ))),
                                ),
                              ],
                            ),
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

  Widget getCancelMessagePopup(BuildContext context) {
    return AlertDialog(
      backgroundColor: null,
      contentPadding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
                height: AppConfig.verticalBlockSize * 10,
                child: Image.asset(PlunesImages.common),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 6,
                    vertical: AppConfig.verticalBlockSize * 3),
                child: Text(
                  "Sorry! your appointment has been cancelled.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConfig.mediumFont,
                  ),
                ),
              ),
              CustomWidgets().getSingleCommonButton(context, 'Ok')
            ]),
      ),
    );
  }

  Widget getTipsConversionsPopup(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 8,
            vertical: AppConfig.verticalBlockSize * 16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 6,
                  vertical: AppConfig.verticalBlockSize * 3),
              child: Text(
                "Tips for more Conversions",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 5,
                  right: AppConfig.horizontalBlockSize * 5,
                  bottom: AppConfig.verticalBlockSize * 2),
              alignment: Alignment.center,
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
            CustomWidgets().getSingleCommonButton(context, 'OK')
          ]),
        ),
      ),
    );
  }

  Widget iconWithText(String textMsg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 8),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: StreamBuilder<Object>(
              stream: bookingBloc.confirmAppointmentByDocHosStream,
              builder: (context, snapshot) {
                if (snapshot.data != null &&
                    snapshot.data is RequestInProgress) {
                  return Container(
                    child: CustomWidgets().getProgressIndicator(),
                    padding: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 5),
                  );
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
                  isSuccess
                      ? Container(
                          margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 2,
                            bottom: AppConfig.verticalBlockSize * 3,
                            left: AppConfig.horizontalBlockSize * 4,
                            right: AppConfig.horizontalBlockSize * 4,
                          ),
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
                      ? CustomWidgets().getSingleCommonButton(context, 'Ok')
                      : Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 1,
                              bottom: AppConfig.verticalBlockSize * 2),
                          child: Column(
                            children: <Widget>[
                              Row(
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
                ]);
              }),
        ),
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

  Widget getBackImageView(String name, {double height, double width}) {
    return Container(
        height: height ?? 60,
        width: width ?? 60,
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
    return Material(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  onDoubleTap: () {},
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Icon(Icons.close, size: 30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    plunesStrings.teamOfExperts,
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontSize: AppConfig.largeFont,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ],
            )),
            Divider(height: 0.5, color: PlunesColors.GREYCOLOR),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(
                left: AppConfig.horizontalBlockSize * 7,
                right: AppConfig.horizontalBlockSize * 7,
                bottom: AppConfig.verticalBlockSize * 4,
              ),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              (doctorsData[itemIndex].imageUrl == null ||
                                      doctorsData[itemIndex].imageUrl.isEmpty ||
                                      !(doctorsData[itemIndex]
                                          .imageUrl
                                          .contains("http")))
                                  ? CustomWidgets().getBackImageView(
                                      doctorsData[itemIndex].name ??
                                          PlunesStrings.NA)
                                  : CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        child: ClipOval(
                                            child: getImageFromUrl(
                                                doctorsData[itemIndex].imageUrl,
                                                boxFit: BoxFit.fill,
                                                placeHolderPath: PlunesImages
                                                    .doc_placeholder)),
                                      ),
                                      radius: 30,
                                    ),
                              SizedBox(
                                width: AppConfig.horizontalBlockSize * 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: AppConfig.horizontalBlockSize * 40,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.2),
                                    child: Text(
                                      CommonMethods.getStringInCamelCase(
                                              doctorsData[itemIndex]?.name) ??
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
                                          PlunesStrings.emptyStr,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.GREYCOLOR,
                                          fontSize: AppConfig.smallFont),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.2),
                                    width: AppConfig.horizontalBlockSize * 64,
                                    child: Text(
                                      doctorsData[itemIndex].education ??
                                          PlunesStrings.emptyStr,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.GREYCOLOR,
                                          fontSize: AppConfig.smallFont),
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
                                          ? PlunesStrings.emptyStr
                                          : "Expr ${doctorsData[itemIndex].experience} years",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: PlunesColors.GREYCOLOR,
                                          fontSize: AppConfig.smallFont),
                                    ),
                                    width: AppConfig.horizontalBlockSize * 40,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Divider(height: 0.5, color: PlunesColors.GREYCOLOR)
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

  Widget hospitalTiming(List<TimeSlots> timeSlots, BuildContext context) {
    print(timeSlots);
    return Material(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  onDoubleTap: () {},
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Icon(Icons.close, size: 30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    plunesStrings.hospitalTiming,
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontSize: AppConfig.largeFont,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ],
            )),
            Divider(height: 0.5, color: PlunesColors.GREYCOLOR),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 4,
                left: AppConfig.horizontalBlockSize * 7,
                right: AppConfig.horizontalBlockSize * 7,
                bottom: AppConfig.verticalBlockSize * 4,
              ),
              child: ListView.builder(
//                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, itemIndex) {
                  return (timeSlots[itemIndex] != null &&
                          timeSlots[itemIndex].closed != null &&
                          timeSlots[itemIndex].closed)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  top: 3, bottom: 2, right: 2, left: 2),
                              child: Text(
                                timeSlots[itemIndex]?.day?.toUpperCase() ??
                                    _getEmptyString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: AppConfig.mediumFont,
                                    decorationThickness: 1,
                                    color: PlunesColors.BLACKCOLOR),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Container(
                                padding: EdgeInsets.only(top: 3, bottom: 10),
                                child: Text(
                                  "CLOSED",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: AppConfig.smallFont,
                                      color: PlunesColors.GREYCOLOR),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  top: 3, bottom: 3, right: 2, left: 2),
                              child: Text(
                                timeSlots[itemIndex]?.day?.toUpperCase() ??
                                    _getEmptyString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: AppConfig.mediumFont,
                                    decorationThickness: 1,
                                    color: PlunesColors.BLACKCOLOR),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, childAspectRatio: 6),
                                itemBuilder: (context, index) {
                                  return Container(
//                                    padding: EdgeInsets.only(bottom: 5,),
                                      child: Text(
                                    "${timeSlots[itemIndex].slots[index]} ",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: AppConfig.smallFont,
                                        color: PlunesColors.GREYCOLOR),
                                  ));
                                },
                                itemCount:
                                    timeSlots[itemIndex]?.slots?.length ?? 0,
                              ),
                            ),
                          ],
                        );
                },
                itemCount: timeSlots?.length ?? 0,
              ),
            ))
          ],
        ),
      ),
    );
  }

  showReviewList(List<RateAndReview> _rateAndReviewList, BuildContext context) {
    return Material(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  onDoubleTap: () {},
                  child: Icon(Icons.close, size: 30),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Check All Reviews",
                    style: TextStyle(
                        color: PlunesColors.BLACKCOLOR,
                        fontSize: AppConfig.largeFont,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(),
              ],
            )),
            Divider(height: 0.5, color: PlunesColors.GREYCOLOR),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 7,
                  right: AppConfig.horizontalBlockSize * 7,
                  bottom: AppConfig.verticalBlockSize * 4,
                  top: AppConfig.verticalBlockSize * 2),
              child: ListView.builder(
                itemBuilder: (context, itemIndex) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 2),
                        margin: EdgeInsets.only(
                            right: AppConfig.horizontalBlockSize * 2),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                (_rateAndReviewList[itemIndex].userImage ==
                                            null ||
                                        _rateAndReviewList[itemIndex]
                                            .userImage
                                            .isEmpty ||
                                        !_rateAndReviewList[itemIndex]
                                            .userImage
                                            .contains("http"))
                                    ? CustomWidgets().getBackImageView(
                                        _rateAndReviewList[itemIndex].userName,
                                        width: 50,
                                        height: 50)
                                    : CircleAvatar(
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          child: ClipOval(
                                              child: CustomWidgets()
                                                  .getImageFromUrl(
                                                      _rateAndReviewList[
                                                              itemIndex]
                                                          .userImage,
                                                      boxFit: BoxFit.fill)),
                                        ),
                                        radius: 25,
                                      ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            AppConfig.horizontalBlockSize * 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            _rateAndReviewList[itemIndex]
                                                    ?.userName ??
                                                PlunesStrings.NA,
                                            style: TextStyle(
                                                color: PlunesColors.BLACKCOLOR,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: CustomWidgets().showRatingBar(
                                              _rateAndReviewList[itemIndex]
                                                      .rating
                                                      ?.toDouble() ??
                                                  1.0),
                                        )
                                      ],
                                    ),
                                  ),
                                  flex: 4,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            AppConfig.horizontalBlockSize * 2),
                                    child: Text(
                                      DateUtil.getDuration(
                                              _rateAndReviewList[itemIndex]
                                                      .createdAt ??
                                                  0) ??
                                          PlunesStrings.NA,
                                      style: TextStyle(
                                          fontSize: AppConfig.smallFont),
                                    ),
                                  ),
                                  flex: 2,
                                )
                              ],
                            ),
                            SizedBox(
                              height: AppConfig.verticalBlockSize * 2,
                            ),
                            Container(
                              width: double.infinity,
                              child: Text(
                                _rateAndReviewList[itemIndex].description ??
                                    PlunesStrings.NA,
                                textAlign: TextAlign.start,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 0.5, color: PlunesColors.GREYCOLOR),
                    ],
                  );
//                        Column(
//                          children: <Widget>[
//                            Padding(
//                              padding: EdgeInsets.symmetric(
//                                  vertical: AppConfig.verticalBlockSize * 1.5),
//                              child: Row(
//                                mainAxisAlignment: MainAxisAlignment.start,
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                children: <Widget>[
//                                  (doctorsData[itemIndex].imageUrl == null ||
//                                      doctorsData[itemIndex].imageUrl.isEmpty ||
//                                      !(doctorsData[itemIndex]
//                                          .imageUrl
//                                          .contains("http")))
//                                      ? CustomWidgets().getBackImageView(
//                                      doctorsData[itemIndex].name ??
//                                          PlunesStrings.NA)
//                                      : CircleAvatar(
//                                    child: Container(
//                                      height: 60,
//                                      width: 60,
//                                      child: ClipOval(
//                                          child: getImageFromUrl(
//                                              doctorsData[itemIndex].imageUrl,
//                                              boxFit: BoxFit.fill)),
//                                    ),
//                                    radius: 30,
//                                  ),
//                                  SizedBox(
//                                    width: AppConfig.horizontalBlockSize * 5,
//                                  ),
//                                  Column(
//                                    crossAxisAlignment: CrossAxisAlignment.start,
//                                    children: <Widget>[
//                                      Container(
//                                        width: AppConfig.horizontalBlockSize * 40,
//                                        padding:
//                                        EdgeInsets.symmetric(vertical: 0.2),
//                                        child: Text(
//                                          CommonMethods.getStringInCamelCase(
//                                              doctorsData[itemIndex]?.name) ??
//                                              PlunesStrings.NA,
//                                          textAlign: TextAlign.start,
//                                          overflow: TextOverflow.ellipsis,
//                                          maxLines: 1,
//                                          style: TextStyle(
//                                              color: PlunesColors.BLACKCOLOR,
//                                              fontSize: 15),
//                                        ),
//                                      ),
//                                      Container(
//                                        padding:
//                                        EdgeInsets.symmetric(vertical: 0.2),
//                                        width: AppConfig.horizontalBlockSize * 40,
//                                        child: Text(
//                                          doctorsData[itemIndex].designation ??
//                                              PlunesStrings.NA,
//                                          textAlign: TextAlign.start,
//                                          overflow: TextOverflow.ellipsis,
//                                          maxLines: 1,
//                                          style: TextStyle(
//                                              color: PlunesColors.GREYCOLOR,
//                                              fontSize: AppConfig.smallFont),
//                                        ),
//                                      ),
//                                      Container(
//                                        padding:
//                                        EdgeInsets.symmetric(vertical: 0.2),
//                                        width: AppConfig.horizontalBlockSize * 64,
//                                        child: Text(
//                                          doctorsData[itemIndex].education ??
//                                              PlunesStrings.NA,
//                                          textAlign: TextAlign.start,
//                                          overflow: TextOverflow.ellipsis,
//                                          maxLines: 1,
//                                          style: TextStyle(
//                                              color: PlunesColors.GREYCOLOR,
//                                              fontSize: AppConfig.smallFont),
//                                        ),
//                                      ),
//                                      Container(
//                                        padding:
//                                        EdgeInsets.symmetric(vertical: 0.2),
//                                        child: Text(
//                                          doctorsData[itemIndex].experience ==
//                                              null ||
//                                              doctorsData[itemIndex]
//                                                  .experience ==
//                                                  "0"
//                                              ? PlunesStrings.NA
//                                              : "Expr ${doctorsData[itemIndex].experience} years",
//                                          textAlign: TextAlign.start,
//                                          overflow: TextOverflow.ellipsis,
//                                          maxLines: 1,
//                                          style: TextStyle(
//                                              color: PlunesColors.GREYCOLOR,
//                                              fontSize: AppConfig.smallFont),
//                                        ),
//                                        width: AppConfig.horizontalBlockSize * 40,
//                                      ),
//                                    ],
//                                  )
//                                ],
//                              ),
//                            ),
//                            Divider(height: 0.5, color: PlunesColors.GREYCOLOR)
//                          ],
//                        );
                },
                itemCount: _rateAndReviewList?.length ?? 0,
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
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 4.5,
                    vertical: AppConfig.verticalBlockSize * 3),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                List<Photo> photos = [];
                                if ((doctorsData != null &&
                                    doctorsData.imageUrl != null &&
                                    doctorsData.imageUrl.isNotEmpty &&
                                    doctorsData.imageUrl.contains("http"))) {
                                  photos.add(
                                      Photo(assetName: doctorsData.imageUrl));
                                }
                                if (photos != null && photos.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PageSlider(photos, 0)));
                                }
                              },
                              child: (doctorsData != null &&
                                      doctorsData.imageUrl != null &&
                                      doctorsData.imageUrl.isNotEmpty &&
                                      doctorsData.imageUrl.contains("http"))
                                  ? CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        child: ClipOval(
                                            child: CustomWidgets()
                                                .getImageFromUrl(
                                                    doctorsData.imageUrl,
                                                    boxFit: BoxFit.fill,
                                                    placeHolderPath:
                                                        PlunesImages
                                                            .doc_placeholder)),
                                      ),
                                      radius: 30,
                                    )
                                  : CustomWidgets().getBackImageView(
                                      doctorsData?.name ?? _getEmptyString())),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    CommonMethods.getStringInCamelCase(
                                            doctorsData?.name) ??
                                        _getEmptyString(),
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
                      doctorsData.department == null ||
                              doctorsData.department.trim().isEmpty
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 3),
                              child: getProfileInfoView(
                                  22,
                                  22,
                                  plunesImages.expertiseIcon,
                                  plunesStrings.areaExpertise,
                                  doctorsData?.department ?? _getEmptyString()),
                            ),
                      doctorsData.experience == null ||
                              doctorsData.experience.trim().isEmpty ||
                              doctorsData.experience == "0"
                          ? Container()
                          : Padding(
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
                      hospitalName == null || hospitalName.trim().isEmpty
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 3),
                              child: getProfileInfoView(
                                  22,
                                  22,
                                  plunesImages.practisingIcon,
                                  plunesStrings.practising,
                                  CommonMethods.getStringInCamelCase(
                                          hospitalName) ??
                                      _getEmptyString()),
                            ),
                      doctorsData.education == null ||
                              doctorsData.education.trim().isEmpty
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 3),
                              child: getProfileInfoView(
                                  22,
                                  22,
                                  plunesImages.eduIcon,
                                  plunesStrings.qualification,
                                  doctorsData?.education ?? _getEmptyString()),
                            ),
                    ],
                  ),
                )),
            CustomWidgets().getSingleCommonButton(context, 'Close')
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

  Widget fetchLocationPopUp(BuildContext context,
      {bool isCalledFromHomeScreen = false}) {
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
        return SingleChildScrollView(
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
                  // height: AppConfig.verticalBlockSize * 34,
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
                                    isCalledFromHomeScreen
                                        ? "Please select your location to discover nearest facilities"
                                        : PlunesStrings
                                            .pleaseSelectLocationPopup,
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
                                          AppConfig.horizontalBlockSize * 15.5),
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
                                          var _latitude =
                                              addressControllerList[3];
                                          var _longitude =
                                              addressControllerList[4];
                                          String region = addr;
                                          if (addressControllerList.length ==
                                                  6 &&
                                              addressControllerList[5] !=
                                                  null) {
                                            region = addressControllerList[5];
                                          }
                                          isProgressing = true;
                                          newState(() {});
                                          UserBloc()
                                              .isUserInServiceLocation(
                                                  _latitude, _longitude,
                                                  address: addr,
                                                  isFromPopup: true,
                                                  region: region)
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
                                      AppConfig.horizontalBlockSize * 8,
                                      AppConfig.verticalBlockSize * 1.2,
                                      PlunesColors.WHITECOLOR,
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
                                    ),
                                  ),
                                )
                              ],
                            )))
            ],
          ),
        );
      }),
    );
  }

  Widget appointmentCancellationPopup(
      String message, GlobalKey<ScaffoldState> globalKey) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 3,
                    horizontal: AppConfig.horizontalBlockSize * 6),
                height: AppConfig.verticalBlockSize * 10,
                child: Image.asset(PlunesImages.bdSupportImage)),
            Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 5,
                  right: AppConfig.horizontalBlockSize * 5,
                  bottom: AppConfig.verticalBlockSize * 3),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: AppConfig.mediumFont,
                      color: PlunesColors.GREYCOLOR)),
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

  Widget requestInvoiceSuccessPopup(
      String message, GlobalKey<ScaffoldState> globalKey) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 4,
                    horizontal: AppConfig.horizontalBlockSize * 6),
                height: AppConfig.verticalBlockSize * 10,
                child: Image.asset(PlunesImages.invoiceSuccessImage)),
            Container(
              margin: EdgeInsets.only(
                  right: AppConfig.horizontalBlockSize * 6,
                  left: AppConfig.horizontalBlockSize * 6,
                  bottom: AppConfig.verticalBlockSize * 5),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: AppConfig.mediumFont),
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

  helpThankYou(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConfig.horizontalBlockSize * 5)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: AppConfig.verticalBlockSize * 3),
                      height: AppConfig.verticalBlockSize * 10,
                      child: Image.asset(PlunesImages.helpThankyou)),
                  Container(
                    margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 6,
                      right: AppConfig.horizontalBlockSize * 6,
                    ),
                    child: Text(
                      PlunesStrings.thankYou,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppConfig.mediumFont,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 6,
                        right: AppConfig.horizontalBlockSize * 6,
                        top: AppConfig.verticalBlockSize * 2,
                        bottom: AppConfig.horizontalBlockSize * 5),
                    child: Text(
                      PlunesStrings.thanksForContacting,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.smallFont,
                          color: PlunesColors.GREYCOLOR),
                    ),
                  ),
                  CustomWidgets().getSingleCommonButton(context, 'Ok')
                ],
              ),
            ),
          );
        });
  }

  showScrollableDialog(BuildContext context, AppointmentModel appointmentModel,
      BookingBloc bookingBloc) async {
    TextEditingController _reviewController = TextEditingController();
    double rating = 1;
    return await showDialog(
        context: context,
        builder: (context) {
          String failureCause;
          return AnimatedContainer(
            padding: AppConfig.getMediaQuery().viewInsets,
            duration: const Duration(milliseconds: 300),
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: StreamBuilder<Object>(
                  stream: bookingBloc.rateReviewStream,
                  builder: (context, snapshot) {
                    if (snapshot.data is RequestInProgress) {
                      return Container(
                        height: AppConfig.verticalBlockSize * 40,
                        width: AppConfig.horizontalBlockSize * 70,
                        child: getProgressIndicator(),
                      );
                    } else if (snapshot.data is RequestSuccess) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: AppConfig.verticalBlockSize * 15,
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(
                                  vertical: AppConfig.verticalBlockSize * 3),
                              child:
                                  Image.asset(PlunesImages.reviewSubmitImage),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 15,
                                  right: AppConfig.horizontalBlockSize * 15,
                                  bottom: AppConfig.verticalBlockSize * 3),
                              child: Text(
                                PlunesStrings.thankYouForValuableFeedback,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: AppConfig.largeFont,
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            CustomWidgets().getSingleCommonButton(context, 'Ok')
                          ],
                        ),
                      );
                    } else if (snapshot.data is RequestFailed) {
                      RequestFailed requestFailed = snapshot.data;
                      failureCause = requestFailed.failureCause;
                    }
                    return SingleChildScrollView(
                        reverse: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: AppConfig.horizontalBlockSize * 2,
                                  vertical: AppConfig.verticalBlockSize * 3),
                              child: Text(
                                PlunesStrings.thanksForService,
                                style:
                                    TextStyle(fontSize: AppConfig.mediumFont),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: AppConfig.horizontalBlockSize * 2,
                                right: AppConfig.horizontalBlockSize * 2,
                              ),
                              child: (appointmentModel.service == null ||
                                      appointmentModel.service.imageUrl ==
                                          null ||
                                      appointmentModel.service.imageUrl.isEmpty)
                                  ? CustomWidgets().getBackImageView(
                                      appointmentModel.professionalName ??
                                          _getEmptyString(),
                                      width: 60,
                                      height: 60)
                                  : CircleAvatar(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xFFE0E0E0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        child: Container(
                                          margin: EdgeInsets.all(1.5),
                                          height: 60,
                                          width: 60,
                                          child: ClipOval(
                                              child: CustomWidgets()
                                                  .getImageFromUrl(
                                                      appointmentModel
                                                          .service.imageUrl,
                                                      boxFit: BoxFit.fill)),
                                        ),
                                      ),
                                      radius: 30,
                                    ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 2,
                                  right: AppConfig.horizontalBlockSize * 2,
                                  top: AppConfig.verticalBlockSize * 0.8),
                              child: Text(
                                CommonMethods.getStringInCamelCase(
                                        appointmentModel?.professionalName) ??
                                    _getEmptyString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: PlunesColors.BLACKCOLOR),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 2,
                                  right: AppConfig.horizontalBlockSize * 2,
                                  top: AppConfig.verticalBlockSize * 0.8),
                              child: Text(
                                appointmentModel?.serviceName ??
                                    _getEmptyString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 2,
                                  right: AppConfig.horizontalBlockSize * 2,
                                  top: AppConfig.verticalBlockSize * 5),
                              child: Text(
                                "Rate your experience",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 2,
                                  right: AppConfig.horizontalBlockSize * 2,
                                  top: AppConfig.verticalBlockSize * 1.5),
                              child: RatingBar(
                                onRatingUpdate: (currentRating) {
                                  rating = currentRating;
                                },
                                direction: Axis.horizontal,
                                itemCount: 5,
                                allowHalfRating: true,
                                minRating: 1,
                                initialRating: rating,
                                maxRating: 5,
                                itemSize: AppConfig.horizontalBlockSize * 7,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: .7),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.green,
                                ),
                                unratedColor: PlunesColors.GREYCOLOR,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 2,
                                  bottom: AppConfig.verticalBlockSize * 2,
                                  left: AppConfig.horizontalBlockSize * 5,
                                  right: AppConfig.horizontalBlockSize * 5),
                              child: TextField(
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontSize: AppConfig.mediumFont),
                                decoration: InputDecoration(
                                    hintText: "Leave your comments",
                                    errorText: failureCause ?? "",
                                    errorMaxLines: 2,
                                    errorStyle: TextStyle(color: Colors.red),
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.red),
                                    ),
                                    disabledBorder: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: PlunesColors.GREENCOLOR),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.green),
                                    ),
                                    border: UnderlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                          width: 1,
                                        )),
                                    errorBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.black)),
                                    focusedErrorBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: PlunesColors.GREENCOLOR)),
                                    hintStyle: TextStyle(
                                        color: PlunesColors.GREYCOLOR,
                                        fontSize: AppConfig.mediumFont)),
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                maxLines: 2,
                                controller: _reviewController,
                                maxLength: 150,
                              ),
                            ),
                            Container(
                              height: 0.5,
                              width: double.infinity,
                              color: PlunesColors.GREYCOLOR,
                            ),
                            Container(
                              height: AppConfig.verticalBlockSize * 8,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: FlatButton(
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          splashColor: PlunesColors
                                              .SPARKLINGGREEN
                                              .withOpacity(.1),
                                          focusColor: Colors.transparent,
                                          onPressed: () {
                                            Navigator.pop(context);
                                            return;
                                          },
                                          child: Container(
                                              height:
                                                  AppConfig.verticalBlockSize *
                                                      8,
                                              width: double.infinity,
                                              child: Center(
                                                child: Text(
                                                  'Cancel',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize:
                                                          AppConfig.mediumFont,
                                                      color: PlunesColors
                                                          .SPARKLINGGREEN),
                                                ),
                                              ))),
                                    ),
                                    Container(
                                      height: AppConfig.verticalBlockSize * 8,
                                      color: PlunesColors.GREYCOLOR,
                                      width: 0.5,
                                    ),
                                    Expanded(
                                      child: FlatButton(
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          splashColor: PlunesColors
                                              .SPARKLINGGREEN
                                              .withOpacity(.1),
                                          focusColor: Colors.transparent,
                                          onPressed: () {
                                            if (_reviewController.text
                                                .trim()
                                                .isEmpty) {
                                              failureCause = PlunesStrings
                                                  .pleaseFillYourReview;
                                              bookingBloc
                                                  .addStateInRateAndReviewProvider(
                                                      null);
                                              return;
                                            }
                                            bookingBloc.submitRateAndReview(
                                                rating,
                                                _reviewController.text.trim(),
                                                appointmentModel
                                                    .professionalId);
                                          },
                                          child: Container(
                                              height:
                                                  AppConfig.verticalBlockSize *
                                                      8,
                                              width: double.infinity,
                                              child: Center(
                                                child: Text(
                                                  'Submit',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize:
                                                          AppConfig.mediumFont,
                                                      color: PlunesColors
                                                          .SPARKLINGGREEN),
                                                ),
                                              ))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ));
                  }),
            ),
          );
        });
  }

  Widget getMoreFacilityWidget(List<MoreFacility> catalogues, int index,
      {bool isSelected = false, Function onTap, Function onProfileTap}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
      elevation: 3.0,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        child: Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              isSelected
                  ? Container(
                      decoration: BoxDecoration(
                          color: PlunesColors.GREENCOLOR,
                          shape: BoxShape.circle),
                      padding: EdgeInsets.all(4),
                      width: AppConfig.horizontalBlockSize * 8,
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: 18,
                          color: PlunesColors.WHITECOLOR,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1.2, color: PlunesColors.GREYCOLOR)),
                      width: AppConfig.horizontalBlockSize * 8,
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.transparent,
                        ),
                      ),
                      padding: EdgeInsets.all(4),
                    ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        if (onProfileTap != null) {
                          onProfileTap();
                        }
                      },
                      child: Container(
                        child: (catalogues[index].imageUrl != null &&
                                catalogues[index].imageUrl.isNotEmpty &&
                                catalogues[index].imageUrl.contains("http"))
                            ? CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  child: ClipOval(
                                      child: CustomWidgets().getImageFromUrl(
                                          catalogues[index].imageUrl,
                                          boxFit: BoxFit.fill,
                                          placeHolderPath:
                                              PlunesImages.doc_placeholder)),
                                ),
                                radius: 22.5,
                              )
                            : CustomWidgets().getBackImageView(
                                catalogues[index].name ?? PlunesStrings.NA,
                                width: 45,
                                height: 45),
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 3),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                if (onProfileTap != null) {
                                  onProfileTap();
                                }
                              },
                              child: Text(
                                catalogues[index].name ?? _getEmptyString(),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * .3),
                              child: Text(
                                catalogues[index].locality ?? _getEmptyString(),
                                style: TextStyle(
                                    color: PlunesColors.GREENCOLOR,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            (catalogues[index].experience != null &&
                                    catalogues[index].experience > 0)
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: AppConfig.verticalBlockSize * .3),
                                    child: Text(
                                      "Expr ${catalogues[index].experience.toStringAsFixed(0)} years",
                                      style: TextStyle(
                                          color: Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#5D5D5D")),
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  )
                                : Container(),
                            Container(
                              padding: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * .3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: PlunesColors.GREENCOLOR,
                                  ),
                                  Text(
                                    catalogues[index]
                                            .rating
                                            ?.toStringAsFixed(1) ??
                                        PlunesStrings.NA,
                                    style: TextStyle(
                                        color: PlunesColors.GREYCOLOR,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: AppConfig.verticalBlockSize * 3,
                            width: AppConfig.horizontalBlockSize * 5,
                            child: Image.asset(plunesImages.locationIcon)),
                        Text(
                          "${catalogues[index].distance?.toStringAsFixed(1) ?? PlunesStrings.NA}kms",
                          style: TextStyle(
                              color: PlunesColors.GREYCOLOR, fontSize: 10),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getManualBiddingEnterDetailsPopup(
      {GlobalKey<ScaffoldState> globalKey,
      SearchSolutionBloc searchSolutionBloc,
      List<MoreFacility> selectedItemList}) {
    return AnimatedContainer(
      padding: AppConfig.getMediaQuery().viewInsets,
      duration: const Duration(milliseconds: 300),
      child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0.0,
          child: StreamBuilder<RequestState>(
              stream: null,
              //searchSolutionBloc.getManualBiddingAdditionStream(),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 2,
                            horizontal: AppConfig.horizontalBlockSize * 5),
                        child: Image.asset(
                          PlunesImages.enterTestAndProcedureDetailsImage,
                          width: AppConfig.horizontalBlockSize * 42,
                          height: AppConfig.verticalBlockSize * 12,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: AppConfig.horizontalBlockSize * 5),
                          child: Text(
                            "We have received your Query",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                        "#575757"))
                                    .withOpacity(1),
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          )),
                      Container(
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 2.5,
                              horizontal: AppConfig.horizontalBlockSize * 5),
                          child: Text(
                            "We will be negotiating with the selected facilities on your behalf and will get in touch with you soon",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#575757")),
                                fontSize: 15.5,
                                fontWeight: FontWeight.normal),
                          )),
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
                              splashColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                              focusColor: Colors.transparent,
                              onPressed: () =>
                                  Navigator.of(globalKey.currentState.context)
                                      .pop(),
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
                );
              })),
    );
  }

  Widget getSingleButtonForPopup(
      {Function onTap,
      Color textColor,
      Color buttonBackground,
      String buttonText,
      double roundedValue}) {
    return InkWell(
      onTap: onTap,
      onDoubleTap: () {},
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: buttonBackground ?? PlunesColors.WHITECOLOR,
            borderRadius: roundedValue != null
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(roundedValue),
                    bottomRight: Radius.circular(roundedValue),
                  )
                : null),
        child: Column(
          children: <Widget>[
            Container(
              height: 0.5,
              width: double.infinity,
              color: PlunesColors.GREYCOLOR,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 1.5),
              child: Center(
                child: Text(
                  buttonText ?? "Ok",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor ?? PlunesColors.GREENCOLOR,
                      fontWeight: FontWeight.normal,
                      fontSize: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  updateAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConfig.horizontalBlockSize * 5)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: AppConfig.verticalBlockSize * 3),
                      height: AppConfig.verticalBlockSize * 10,
                      child: Image.asset(PlunesImages.updateApp)),
                  Container(
                    margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 6,
                      right: AppConfig.horizontalBlockSize * 6,
                    ),
                    child: Text(
                      PlunesStrings.newVersionAvailable,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppConfig.mediumFont,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: AppConfig.horizontalBlockSize * 6,
                        right: AppConfig.horizontalBlockSize * 6,
                        bottom: AppConfig.verticalBlockSize * 5,
                        top: AppConfig.verticalBlockSize * 2),
                    child: Text(
                      PlunesStrings.usingOlderVersion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppConfig.smallFont,
                          color: PlunesColors.GREYCOLOR),
                    ),
                  ),
                  CustomWidgets().getSingleCommonButton(context, 'Update')
                ],
              ),
            ),
          );
        });
  }

  Widget getShowCase(GlobalKey globalKey,
      {Widget child, String description, String title, Function onTap}) {
    return Showcase(
      showcaseBackgroundColor: PlunesColors.GREENCOLOR,
      textColor: Colors.white,
      shapeBorder: CircleBorder(),
      key: globalKey,
      description: description,
      title: title,
      showArrow: true,
      child: child ?? Container(),
    );
  }

//  Widget getDocOrHospitalDetailWidget(
//      List<Services> solutions,
//      int index,
//      Function checkAvailability,
//      Function onBookingTap,
//      CatalogueData catalogueData,
//      BuildContext context,
//      Function viewProfile) {
//    return Container(
//      padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
//      child: Column(
//        children: <Widget>[
//          Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              InkWell(
//                onTap: () => viewProfile(),
//                onDoubleTap: () {},
//                child: (solutions[index].imageUrl != null &&
//                    solutions[index].imageUrl.isNotEmpty)
//                    ? CircleAvatar(
//                  child: Container(
//                    height: AppConfig.horizontalBlockSize * 14,
//                    width: AppConfig.horizontalBlockSize * 14,
//                    child: ClipOval(
//                        child: getImageFromUrl(solutions[index].imageUrl,
//                            boxFit: BoxFit.fill)),
//                  ),
//                  radius: AppConfig.horizontalBlockSize * 7,
//                )
//                    : getProfileIconWithName(
//                  solutions[index].name,
//                  14,
//                  14,
//                ),
//              ),
//              Padding(
//                  padding:
//                  EdgeInsets.only(left: AppConfig.horizontalBlockSize * 3)),
//              Expanded(
//                child: InkWell(
//                  onTap: () => viewProfile(),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Text(
//                        CommonMethods.getStringInCamelCase(
//                            solutions[index]?.name) ??
//                            PlunesStrings.NA,
//                        style: TextStyle(
//                            fontSize: AppConfig.mediumFont,
//                            color: PlunesColors.BLACKCOLOR,
//                            fontWeight: FontWeight.bold),
//                      ),
//                      (solutions[index] != null &&
//                          solutions[index].experience != null &&
//                          solutions[index].experience > 0)
//                          ? Padding(
//                          padding: EdgeInsets.only(
//                              top: AppConfig.horizontalBlockSize * 1),
//                          child: Text(
//                            "${solutions[index].experience} ${PlunesStrings.yrExp}",
//                            style: TextStyle(
//                              fontSize: AppConfig.mediumFont,
//                              color: PlunesColors.GREYCOLOR,
//                            ),
//                          ))
//                          : Container()
//                    ],
//                  ),
//                ),
//              ),
//              Padding(
//                  padding:
//                  EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2)),
//              solutions[index].negotiating
//                  ? getLinearIndicator()
//                  : Column(
//                crossAxisAlignment: CrossAxisAlignment.end,
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  RichText(
//                      text: TextSpan(
//                          text: (solutions[index]?.price[0] ==
//                              solutions[index]?.newPrice[0])
//                              ? ""
//                              : "\u20B9${solutions[index].price[0]?.toStringAsFixed(0) ?? PlunesStrings.NA} ",
//                          style: TextStyle(
//                              fontSize: AppConfig.smallFont,
//                              color: PlunesColors.GREYCOLOR,
//                              decoration: TextDecoration.lineThrough),
//                          children: <TextSpan>[
//                            TextSpan(
//                              text:
//                              " \u20B9${solutions[index].newPrice[0]?.toStringAsFixed(2) ?? PlunesStrings.NA}",
//                              style: TextStyle(
//                                  fontSize: AppConfig.smallFont,
//                                  color: PlunesColors.BLACKCOLOR,
//                                  fontWeight: FontWeight.bold,
//                                  decoration: TextDecoration.none),
//                            )
//                          ])),
//                  Padding(
//                      padding: EdgeInsets.only(
//                          top: AppConfig.horizontalBlockSize * 1)),
//                  (solutions[index].price[0] ==
//                      solutions[index].newPrice[0])
//                      ? Container()
//                      : Text(
//                    solutions[index].discount == null
//                        ? ""
//                        : "${PlunesStrings.save} ${solutions[index].discount.toStringAsFixed(0)}%",
//                    style: TextStyle(
//                        fontSize: AppConfig.verySmallFont,
//                        color: PlunesColors.GREENCOLOR),
//                  )
//                ],
//              ),
//            ],
//          ),
//          Padding(
//              padding: EdgeInsets.only(
//                  top: solutions[index].negotiating
//                      ? 0.0
//                      : AppConfig.verticalBlockSize * 2)),
//          solutions[index].negotiating
//              ? Container()
//              : Row(
//            mainAxisAlignment: MainAxisAlignment.spaceAround,
//            // crossAxisAlignment: CrossAxisAlignment.,
//            children: <Widget>[
//              Container(
//                  width: AppConfig.horizontalBlockSize * 11,
//                  margin: EdgeInsets.only(
//                      left: AppConfig.horizontalBlockSize * 1.5)),
//              Padding(
//                  padding: EdgeInsets.only(
//                      left: AppConfig.horizontalBlockSize * 1.5)),
//              Flexible(
//                  child: showRatingBar(
//                      solutions[index].rating?.toDouble() ?? 3.0)),
//              Expanded(child: Container()),
//              Text(
//                  solutions[index].distance == null
//                      ? ""
//                      : "${solutions[index].distance.toStringAsFixed(1)} ${PlunesStrings.kmsAway}",
//                  style: TextStyle(fontSize: AppConfig.verySmallFont))
//            ],
//          ),
//          Padding(
//              padding: EdgeInsets.only(
//                  top: solutions[index].negotiating
//                      ? 0.0
//                      : AppConfig.verticalBlockSize * 2)),
//          solutions[index].negotiating
//              ? Container(
//              alignment: Alignment.bottomRight,
//              child: Text(
//                PlunesStrings.negotiating,
//                style: TextStyle(
//                    fontSize: AppConfig.mediumFont,
//                    fontWeight: FontWeight.w400),
//              ))
//              : Row(
//            children: <Widget>[
//              Container(
//                  width: AppConfig.horizontalBlockSize * 11,
//                  margin: EdgeInsets.only(
//                      left: AppConfig.horizontalBlockSize * 5)),
//              Padding(
//                  padding: EdgeInsets.only(
//                      left: AppConfig.horizontalBlockSize * 1.5)),
////                    Expanded(
////                        flex: 6,
////                        child: Text(PlunesStrings.validForOneHour,
////                            style: TextStyle(
////                              fontSize: AppConfig.smallFont,
////                              color: PlunesColors.GREENCOLOR,
////                            ))),
//              Expanded(child: Container(), flex: 1),
//              InkWell(
//                onTap: checkAvailability,
//                child: getRoundedButton(
//                    PlunesStrings.checkAvailability,
//                    AppConfig.horizontalBlockSize * 8,
//                    PlunesColors.WHITECOLOR,
//                    AppConfig.horizontalBlockSize * 3,
//                    AppConfig.verticalBlockSize * 1,
//                    PlunesColors.BLACKCOLOR,
//                    hasBorder: true),
//              ),
//              Padding(
//                  padding: EdgeInsets.only(
//                      left: AppConfig.horizontalBlockSize * 2)),
//              InkWell(
//                  onTap: onBookingTap,
//                  child: getRoundedButton(
//                      solutions[index].bookIn == null
//                          ? PlunesStrings.book
//                          : "${PlunesStrings.bookIn} ${solutions[index].bookIn}",
//                      AppConfig.horizontalBlockSize * 8,
//                      PlunesColors.GREENCOLOR,
//                      AppConfig.horizontalBlockSize * 3,
//                      AppConfig.verticalBlockSize * 1,
//                      PlunesColors.WHITECOLOR)),
//            ],
//          ),
//          (solutions[index] != null &&
//              solutions[index].homeCollection != null &&
//              solutions[index].homeCollection)
//              ? Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                Container(
//                    width: AppConfig.horizontalBlockSize * 11,
//                    margin: EdgeInsets.only(
//                        left: AppConfig.horizontalBlockSize * 5,
//                        top: AppConfig.verticalBlockSize * 10)),
//                Padding(
//                    padding: EdgeInsets.only(
//                        left: AppConfig.horizontalBlockSize * 1.5)),
//                Flexible(
//                    child: Image.asset(
//                      PlunesImages.homeCollectionImage,
//                      scale: 0.5,
//                    ))
//              ])
//              : Container(),
//          index == solutions.length - 1 ? Container() : getSeparatorLine()
//        ],
//      ),
//    );
//  }

  Widget savePriceInCatalogue(RealInsight realInsight, GlobalKey globalKey,
      DocHosMainInsightBloc docHosMainInsightBloc) {
    TextEditingController _priceController = TextEditingController();
    String error;
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        child: SingleChildScrollView(
          child: StreamBuilder<RequestState>(
              stream: docHosMainInsightBloc
                  .updatePriceInCatalogueFromRealInsightStream,
              builder: (context, snapshot) {
                if (snapshot.data is RequestFailed) {
                  RequestFailed requestFailed = snapshot.data;
                  return getInformativeWidget(
                      globalKey, requestFailed?.failureCause);
                } else if (snapshot.data is RequestInProgress) {
                  return Container(
                    child: getProgressIndicator(),
                    height: AppConfig.verticalBlockSize * 34,
                  );
                } else if (snapshot.data is RequestSuccess) {
                  return getInformativeWidget(
                      globalKey, PlunesStrings.priceUpdateSuccessMessage);
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
                      height: AppConfig.verticalBlockSize * 10,
                      child: Image.asset(PlunesImages.savePriceInCatalogueImage,
                          fit: BoxFit.fitHeight),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 2,
                          right: AppConfig.horizontalBlockSize * 2,
                          top: AppConfig.verticalBlockSize * 2.5),
                      child: Text(
                        PlunesStrings.savePriceInCataloge,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 2,
                            left: AppConfig.horizontalBlockSize * 3,
                            right: AppConfig.horizontalBlockSize * 3),
                        padding: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 15),
                        child: Container(
                          margin: EdgeInsets.only(
                              bottom: AppConfig.verticalBlockSize * 1.5),
                          child: SizedBox(
                            width: AppConfig.horizontalBlockSize * 15,
                            child: TextField(
                              controller: _priceController,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              maxLines: 1,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.bottom,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                              ),
                            ),
                          ),
                        )),
                    error == null
                        ? Container()
                        : Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Text(error,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.red)),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: FlatButton(
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: PlunesColors.SPARKLINGGREEN
                                      .withOpacity(.1),
                                  focusColor: Colors.transparent,
                                  onPressed: () {
                                    Navigator.pop(context,
                                        false); // showDialog() returns false
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      height: AppConfig.verticalBlockSize * 6,
                                      child: Center(
                                        child: Text(
                                          "No",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: AppConfig.mediumFont,
                                              color:
                                                  PlunesColors.SPARKLINGGREEN),
                                        ),
                                      ))),
                            ),
                            Container(
                              height: AppConfig.verticalBlockSize * 6,
                              color: PlunesColors.GREYCOLOR,
                              width: 0.5,
                            ),
                            Expanded(
                              child: FlatButton(
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: PlunesColors.SPARKLINGGREEN
                                      .withOpacity(.1),
                                  focusColor: Colors.transparent,
                                  onPressed: () {
                                    double value = double.tryParse(
                                        _priceController.text.trim());
                                    if (value == null ||
                                        value == 0 ||
                                        value < 1) {
                                      error = 'Price must be greater than 0';
                                      newState(() {});
                                      return;
                                    }
                                    docHosMainInsightBloc
                                        .updatePriceInCatalogueFromRealInsight(
                                            realInsight.serviceId,
                                            value,
                                            realInsight.professionalId);
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      height: AppConfig.verticalBlockSize * 6,
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: Text(
                                          "Yes",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: AppConfig.mediumFont,
                                              color:
                                                  PlunesColors.SPARKLINGGREEN),
                                        ),
                                      ))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      );
    });
  }

  Widget getInformativePopup(
      {GlobalKey<ScaffoldState> globalKey, String message}) {
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
              child: Image.asset(PlunesImages.common),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5,
                  vertical: AppConfig.verticalBlockSize * 2.5),
              child: Text(
                message ?? plunesStrings.somethingWentWrong,
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

  Widget getInvoiceSuccessPopup(
      {GlobalKey<ScaffoldState> globalKey, String message, String pdfUrl}) {
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
              child: Image.asset(PlunesImages.common),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5,
                  vertical: AppConfig.verticalBlockSize * 2.5),
              child: Text(
                message ?? plunesStrings.somethingWentWrong,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor:
                              PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                          focusColor: Colors.transparent,
                          onPressed: () {
                            Navigator.of(globalKey.currentState.context).pop();
                          },
                          child: Container(
                              width: double.infinity,
                              height: AppConfig.verticalBlockSize * 6,
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: AppConfig.mediumFont,
                                      color: PlunesColors.SPARKLINGGREEN),
                                ),
                              ))),
                    ),
                    Container(
                      height: AppConfig.verticalBlockSize * 6,
                      color: PlunesColors.GREYCOLOR,
                      width: 0.5,
                    ),
                    Expanded(
                      child: FlatButton(
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor:
                              PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                          focusColor: Colors.transparent,
                          onPressed: () {
                            if (pdfUrl != null) {
                              LauncherUtil.launchUrl(pdfUrl);
                            }
                            Navigator.of(globalKey.currentState.context).pop();
                          },
                          child: Container(
                              width: double.infinity,
                              height: AppConfig.verticalBlockSize * 6,
                              alignment: Alignment.center,
                              child: Center(
                                child: Text(
                                  "Show",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: AppConfig.mediumFont,
                                      color: PlunesColors.SPARKLINGGREEN),
                                ),
                              ))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentStatusPopup(
      String text, String message, String icon, BuildContext context,
      {String bookingId}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5,
                  vertical: AppConfig.verticalBlockSize * 1.5),
              child: Text(
                text ?? plunesStrings.somethingWentWrong,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              // margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
              height: AppConfig.verticalBlockSize * 10,
              child: Image.asset(icon),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 5,
                  right: AppConfig.horizontalBlockSize * 5,
                  top: AppConfig.verticalBlockSize * 1.5,
                  bottom: AppConfig.verticalBlockSize * 2.5),
              child: Text(
                message ?? plunesStrings.somethingWentWrong,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: AppConfig.mediumFont,
                    fontWeight: FontWeight.w600),
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
                    onPressed: () {
                      if (bookingId != null && bookingId.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AppointmentMainScreen())).then((value) {
                          Navigator.pop(context, "pop");
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
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

  Widget getVideoPopupForUser(
      {GlobalKey<ScaffoldState> globalKey, String message}) {
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
              child: Image.asset(PlunesImages.common),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 5,
                  vertical: AppConfig.verticalBlockSize * 2.5),
              child: Text(
                message ?? plunesStrings.somethingWentWrong,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor:
                              PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                          focusColor: Colors.transparent,
                          onPressed: () {
                            Navigator.of(globalKey.currentState.context).pop();
                            return;
                          },
                          child: Container(
                              height: AppConfig.verticalBlockSize * 6,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: AppConfig.mediumFont,
                                      color: PlunesColors.SPARKLINGGREEN),
                                ),
                              ))),
                    ),
                    Container(
                      height: AppConfig.verticalBlockSize * 6,
                      color: PlunesColors.GREYCOLOR,
                      width: 0.5,
                    ),
                    Expanded(
                      child: FlatButton(
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor:
                              PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                          focusColor: Colors.transparent,
                          onPressed: () {
                            Navigator.of(globalKey.currentState.context)
                                .pop(PlunesStrings.watch);
                            return;
                          },
                          child: Container(
                              height: AppConfig.verticalBlockSize * 6,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  PlunesStrings.watch,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: AppConfig.mediumFont,
                                      color: PlunesColors.SPARKLINGGREEN),
                                ),
                              ))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget turnOffNotificationPopup(GlobalKey globalKey, RealInsight realInsight,
      DocHosMainInsightBloc docHosMainInsightBloc) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: SingleChildScrollView(
        child: StreamBuilder<RequestState>(
            stream: docHosMainInsightBloc.realTimeInsightStopNotificationStream,
            builder: (context, snapshot) {
              if (snapshot.data is RequestFailed) {
                RequestFailed requestFailed = snapshot.data;
                return getInformativeWidget(
                    globalKey, requestFailed?.failureCause);
              } else if (snapshot.data is RequestInProgress) {
                return Container(
                  child: getProgressIndicator(),
                  height: AppConfig.verticalBlockSize * 34,
                );
              } else if (snapshot.data is RequestSuccess) {
                return getInformativeWidget(
                    globalKey, PlunesStrings.notificationDisabled);
              }
              return Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
                child: Column(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 25,
                            vertical: AppConfig.verticalBlockSize * 3),
                        child: Image.asset(PlunesImages.turnOffNotification)),
                    Container(
                      padding: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 1.5),
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 10),
                      child: Text(
                        PlunesStrings.serviceNotAvailableAtFacility,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          bottom: AppConfig.verticalBlockSize * 3),
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 13),
                      child: Text(
                        PlunesStrings.doNotNotifyForThisService,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#575757")),
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: FlatButton(
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: PlunesColors.SPARKLINGGREEN
                                      .withOpacity(.1),
                                  focusColor: Colors.transparent,
                                  onPressed: () {
                                    docHosMainInsightBloc
                                        .stopNotificationsForSuggestedInsight(
                                            realInsight.serviceId);
                                    return;
                                  },
                                  child: Container(
                                      height: AppConfig.verticalBlockSize * 6,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          PlunesStrings.yes,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: AppConfig.mediumFont,
                                              color:
                                                  PlunesColors.SPARKLINGGREEN),
                                        ),
                                      ))),
                            ),
                            Container(
                              height: AppConfig.verticalBlockSize * 6,
                              color: PlunesColors.GREYCOLOR,
                              width: 0.5,
                            ),
                            Expanded(
                              child: FlatButton(
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: PlunesColors.SPARKLINGGREEN
                                      .withOpacity(.1),
                                  focusColor: Colors.transparent,
                                  onPressed: () {
                                    Navigator.of(globalKey.currentState.context)
                                        .pop();
                                    return;
                                  },
                                  child: Container(
                                      height: AppConfig.verticalBlockSize * 6,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          plunesStrings.cancel,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: AppConfig.mediumFont,
                                              color:
                                                  PlunesColors.SPARKLINGGREEN),
                                        ),
                                      ))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget getInformativeWidget(GlobalKey globalKey, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
          height: AppConfig.verticalBlockSize * 10,
          child: Image.asset(PlunesImages.common),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 5,
              vertical: AppConfig.verticalBlockSize * 2.5),
          child: Text(
            message ?? plunesStrings.somethingWentWrong,
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
    );
  }

  Widget getUpiBasedPaymentOptionView(InitPaymentResponse initPaymentResponse,
      List<ApplicationMeta> availableUpiApps, GlobalKey globalKey) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: Color(CommonMethods.getColorHexFromStr("#FFFFFF")),
      insetPadding:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 5),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 1.2,
                  horizontal: AppConfig.horizontalBlockSize * 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Pay through",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: PlunesColors.BLACKCOLOR),
                    ),
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                  ),
                  Expanded(
                      child: Container(
                    height: 0.5,
                    width: double.infinity,
                    color: PlunesColors.BLACKCOLOR,
                    margin: EdgeInsets.only(left: 5.0),
                  ))
                ],
              ),
            ),
            Container(
              color: Color(CommonMethods.getColorHexFromStr("#FFFFFF")),
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 1.2,
                  horizontal: AppConfig.horizontalBlockSize * 2),
              child: ListView(
                shrinkWrap: true,
                children: availableUpiApps
                        .map((it) => Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 2.5,
                                  vertical: AppConfig.verticalBlockSize * 1),
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#F9F9F9")),
                                  borderRadius: BorderRadius.circular(16.0)),
                              child: InkWell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.memory(
                                      it.icon,
                                      width: AppConfig.horizontalBlockSize * 15,
                                      height: AppConfig.verticalBlockSize * 6,
                                    ),
                                    Flexible(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left:
                                                AppConfig.horizontalBlockSize *
                                                    4),
                                        child: Text(
                                          it.upiApplication?.getAppName() ??
                                              "Pay",
                                          style: TextStyle(
                                              color: PlunesColors.BLACKCOLOR,
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Map<String, dynamic> result = Map();
                                  result[PlunesStrings.payUpi] = it;
                                  Navigator.of(globalKey.currentState.context)
                                      .pop(result);
                                },
                              ),
                            ))
                        ?.toList() ??
                    <Widget>[],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2),
              child: InkWell(
                onTap: () {
                  Map<String, String> result = Map();
                  result[PlunesStrings.payOnWeb] = PlunesStrings.payOnWeb;
                  Navigator.of(globalKey.currentState.context).pop(result);
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: Container(
                  child: Text(
                    "More payment options",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: PlunesColors.GREENCOLOR),
                  ),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showAddToCartSuccessPopup(GlobalKey globalKey, String message) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
                height: AppConfig.verticalBlockSize * 10,
                child: Image.asset(PlunesImages.addToCartSuccessImage),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 5,
                    vertical: AppConfig.verticalBlockSize * 2.5),
                child: Text(
                  message ?? PlunesStrings.successfullyAddedToCart,
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
                          Navigator.of(globalKey.currentState.context)
                              .pop(true),
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
        ));
  }

  Widget openCartPaymentBillPopup(
      List<BookingIds> bookingIds, GlobalKey globalKey, num price,
      {num credits}) {
    bool useCredits = false;
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 2,
                    vertical: AppConfig.verticalBlockSize * 1.5),
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: AppConfig.horizontalBlockSize * 2,
                                  vertical: AppConfig.verticalBlockSize * 1),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            CommonMethods.getStringInCamelCase(
                                                bookingIds[index]
                                                    ?.service
                                                    ?.name),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: PlunesColors.BLACKCOLOR,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: AppConfig.verticalBlockSize *
                                                  2.0),
                                          child: Text(
                                            "${bookingIds[index]?.serviceName ?? PlunesStrings.NA}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: PlunesColors.BLACKCOLOR,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "\u20B9${bookingIds[index]?.service?.newPrice?.first ?? 0}",
                                        style: TextStyle(
                                            color: PlunesColors.BLACKCOLOR,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 0.5,
                              width: double.infinity,
                              color: PlunesColors.GREYCOLOR,
                            ),
                          ],
                        );
                      },
                      itemCount: bookingIds?.length ?? 0,
                    ),
                    (credits != null && credits > 0)
                        ? Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 2,
                                      vertical:
                                          AppConfig.verticalBlockSize * 0.1),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          PlunesStrings.useCredits,
                                          style: TextStyle(
                                              color: PlunesColors.BLACKCOLOR,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18),
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      Container(
                                        child: Text(
                                          "${credits?.toStringAsFixed(1)}",
                                          style: TextStyle(
                                              color: PlunesColors.BLACKCOLOR,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 3),
                                        child: StatefulBuilder(
                                          builder: (context, newState) {
                                            return Checkbox(
                                                value: useCredits,
                                                onChanged: (credits) {
                                                  useCredits = credits;
                                                  newState(() {});
                                                });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: PlunesColors.GREYCOLOR,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 2,
                    vertical: AppConfig.verticalBlockSize * 2.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: Text(
                        "Subtotal (${bookingIds.length ?? 0} ${(bookingIds.length == 1) ? "item" : "items"}): ",
                        maxLines: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: PlunesColors.BLACKCOLOR,
                            fontSize: 20),
                      ),
                    ),
                    Flexible(
                      child: Text("\u20B9 $price",
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: PlunesColors.GREENCOLOR,
                              fontSize: 15)),
                    )
                  ],
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor:
                                PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                            focusColor: Colors.transparent,
                            onPressed: () {
                              Navigator.of(globalKey.currentState.context)
                                  .pop();
                              return;
                            },
                            child: Container(
                                height: AppConfig.verticalBlockSize * 6,
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    plunesStrings.cancel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: AppConfig.mediumFont,
                                        color: PlunesColors.SPARKLINGGREEN),
                                  ),
                                ))),
                      ),
                      Container(
                        height: AppConfig.verticalBlockSize * 6,
                        color: PlunesColors.GREYCOLOR,
                        width: 0.5,
                      ),
                      Expanded(
                        child: FlatButton(
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor:
                                PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                            focusColor: Colors.transparent,
                            onPressed: () {
                              Navigator.of(globalKey.currentState.context)
                                  .pop(useCredits);
                              return;
                            },
                            child: Container(
                                height: AppConfig.verticalBlockSize * 6,
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    PlunesStrings.proceedText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: AppConfig.mediumFont,
                                        color: PlunesColors.SPARKLINGGREEN),
                                  ),
                                ))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
