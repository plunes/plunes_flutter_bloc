import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';

// ignore: must_be_immutable
class FacilityDetailScreen extends BaseActivity {
  @override
  _FacilityDetailScreenState createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends BaseState<FacilityDetailScreen> {
  bool _isExpanded;

  @override
  void initState() {
    _isExpanded = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: widget.getAppBar(context, "Dentist", true),
        body: _getBody(),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget _getBody() {
    return Container(
      color: Color(CommonMethods.getColorHexFromStr("#FFFFFF")),
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 2.5,
          vertical: AppConfig.verticalBlockSize * 1.5),
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
            color: Color(CommonMethods.getColorHexFromStr("#FCFCFC")),
            child: Container(
              color: Color(CommonMethods.getColorHexFromStr("#FCFCFC")),
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 1.5,
                  vertical: AppConfig.verticalBlockSize * 1.2),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      _isExpanded = !_isExpanded;
                      _setState();
                    },
                    child: Row(
                      children: [
                        Text(
                          "Braces",
                          style: TextStyle(
                              fontSize: 18,
                              color: PlunesColors.BLACKCOLOR,
                              fontWeight: FontWeight.normal),
                        ),
                        Expanded(child: Container()),
                        Icon(
                          Icons.arrow_drop_down,
                          color: PlunesColors.BLACKCOLOR,
                        )
                      ],
                    ),
                  ),
                  _isExpanded
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 1.4),
                          width: double.infinity,
                          height: 0.6,
                          color: PlunesColors.GREYCOLOR,
                        )
                      : Container(),
                  _isExpanded
                      ? Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "2-5 minutes",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: PlunesColors.BLACKCOLOR,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "Duration",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Depends on case",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: PlunesColors.BLACKCOLOR,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "Session",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2.5),
                                child: Text(
                                  "Definition",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: PlunesColors.BLACKCOLOR,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(
                                            top: AppConfig.verticalBlockSize *
                                                2.5),
                                        child: Text(
                                          "A Botox treatment is a minimally invasive, safe, effective treatment for fine lines and wrinkles around the eyes. It can also be used on the forehead between the eyes. Botox is priced per unit.",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        )),
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2.5),
                                child: Text(
                                  "Dos And Don'ts",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: PlunesColors.BLACKCOLOR,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(
                                            top: AppConfig.verticalBlockSize *
                                                2.5),
                                        child: Text(
                                          "Describe the problem when it began, how it bothers you, and what treatments you have tried for it. Tell doctor about any medications you are taking or about any allergies you may have. Make your medication list. Make sure you have any prescriptions necessary and that you have the dosage requirements. Ask about any side effects.",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          );
        },
        itemCount: 5,
      ),
    );
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
