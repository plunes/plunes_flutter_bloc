import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';

import '../GalleryScreen.dart';

// ignore: must_be_immutable
class AchievementItemAdapter extends BaseActivity {
  var from, globalWidth, globalHeight;

  AchievementItemAdapter(this.from, this.globalWidth, this.globalHeight);

  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<AchievementItemAdapter>
    implements DialogCallBack {
  BuildContext screenContext;

  @override
  Widget build(BuildContext context) {
    screenContext = context;
    return Container(
        height: 170,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount:
                5 /*utilityNetList.length > 4? 4: utilityNetList.length*/,
            itemBuilder: (context, index) {
              return Container(
                  width: (widget.globalWidth / 2) - 22,
                  padding: EdgeInsets.only(left: 5, right: 0),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                          onTap: () {
//                  CommonMethods.goToPage(context, GalleryScreen());
                            Navigator.pushNamed(context, GalleryScreen.tag);
                          },
                          child: Container(
                            height: 130,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                    height: 120,
                                    margin: EdgeInsets.only(top: 3),
                                    child: Card(
                                        elevation: 5,
                                        semanticContainer: true,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: <Widget>[
                                            widget.getAssetImageWidget(
                                                'assets/images/achievments/gradient/6.jpg'),
                                            Align(
                                              alignment:
                                                  FractionalOffset.bottomCenter,
                                              child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  height: 30,
                                                  child: widget.createTextViews(
                                                      '+3',
                                                      14,
                                                      colorsFile.white,
                                                      TextAlign.center,
                                                      FontWeight.normal),
                                                  decoration: BoxDecoration(
                                                      border: new Border.all(
                                                          color: Colors
                                                              .transparent),
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                              bottomLeft:
                                                                  const Radius.circular(
                                                                      10.0),
                                                              bottomRight:
                                                                  const Radius.circular(
                                                                      10.0)),
                                                      color: Colors.black
                                                          .withOpacity(0.5))),
                                            )
                                          ],
                                        ))),
                                Align(
                                    alignment: FractionalOffset.topRight,
                                    child: InkWell(
                                        onTap: () =>
                                            CommonMethods.confirmationDialog(
                                                context,
                                                plunesStrings
                                                    .deleteAchievementMsg,
                                                this),
                                        child: widget.getCrossButton())),
                              ],
                            ),
                          )),
                      widget.getSpacer(0.0, 10),
                      Container(
                          padding: EdgeInsets.only(left: 3, right: 3),
                          child: widget.createTextViews(
                              'Name shdj scvsdsdc dshgsdsd sscscsdsc cscsdccscs',
                              10,
                              colorsFile.lightGrey2,
                              TextAlign.center,
                              FontWeight.normal))
                    ],
                  ));
            }));
  }

  @override
  dialogCallBackFunction(String action) {}
}
