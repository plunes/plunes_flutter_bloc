import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';

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
      FocusNode focusNode}) {
    return StatefulBuilder(builder: (context, newState) {
      return Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(),
            side: BorderSide(color: PlunesColors.GREYCOLOR)),
        child: Container(
          height: AppConfig.verticalBlockSize * 7,
          padding: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 2,
              right: AppConfig.horizontalBlockSize * 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
//              Padding(
//                padding: EdgeInsets.only(right: 0.0),
//                child:
//                    Image.asset(HenkelImages.search, color: HenkelColors.grey),
//              ),
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
                          fontSize: AppConfig.mediumFont)),
                ),
              ),
              searchController.text.trim().isEmpty
                  ? Container()
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

  Widget getSolutionRow(List<CatalougeData> solutionList, int index,
      {Function onButtonTap, TapGestureRecognizer onViewMoreTap}) {
    return StatefulBuilder(builder: (context, newState) {
      return InkWell(
        onTap: () {
          newState(() {
            solutionList[index].isSelected =
                !solutionList[index].isSelected ?? false;
          });
        },
        child: Container(
          color: solutionList[index].isSelected ?? false
              ? PlunesColors.LIGHTGREENCOLOR
              : PlunesColors.WHITECOLOR,
          child: Column(
            children: <Widget>[
              index == 0
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.5,
                          bottom: AppConfig.verticalBlockSize * 1.5),
                      width: double.infinity,
                      height: 0.5,
                      color: PlunesColors.GREYCOLOR,
                    ),
              Row(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RichText(
                            text: TextSpan(
                                text: solutionList[index].service ??
                                    PlunesStrings.NA,
                                style: TextStyle(color: Colors.black),
                                children: [
                              TextSpan(
                                  text:
                                      "(${solutionList[index].category ?? PlunesStrings.NA})",
                                  style: TextStyle(color: Colors.green))
                            ])),
                        Padding(
                            padding: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1)),
                        RichText(
                            text: TextSpan(
                                text:
                                    solutionList[0].details ?? PlunesStrings.NA,
                                style: TextStyle(color: Colors.black),
                                children: [
                              TextSpan(
                                  text: "(view more)",
                                  recognizer: onViewMoreTap,
                                  style:
                                      TextStyle(color: PlunesColors.GREENCOLOR))
                            ])),
                      ],
                    ),
                  )
                ],
              ),
              solutionList[index].isSelected ?? false
                  ? Container(
                      color: PlunesColors.WHITECOLOR,
                      padding: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 24,
                          top: AppConfig.verticalBlockSize * 1,
                          right: AppConfig.horizontalBlockSize * 24),
                      child: _getRoundedButton(
                          "Negotiate",
                          AppConfig.horizontalBlockSize * 8,
                          PlunesColors.GREENCOLOR,
                          AppConfig.horizontalBlockSize * 4,
                          AppConfig.verticalBlockSize * 2,
                          PlunesColors.WHITECOLOR))
                  : Container()
            ],
          ),
        ),
      );
    });
  }

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

  Widget _getRoundedButton(
      String buttonName,
      double cornerPadding,
      Color buttonColor,
      double horizontalPadding,
      double verticalPadding,
      Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
          color: buttonColor ?? PlunesColors.WHITECOLOR,
          borderRadius: BorderRadius.all(Radius.circular(cornerPadding))),
      child: Center(
        child: Text(
          buttonName,
          style: TextStyle(color: textColor ?? PlunesColors.BLACKCOLOR),
        ),
      ),
    );
  }
}
