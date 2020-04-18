import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/res/ColorsFile.dart';

import 'EnterPhoneScreen.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - GuidedTour class is for showing most of the feature of the application using slide and it'll show only first and after login it'll not come up again.
 */

class GuidedTour extends StatefulWidget {
  static const tag = '/guided';

  @override
  GuidedTourState createState() => GuidedTourState();
}

class GuidedTourState extends State<GuidedTour> {
  onDonePress() {
    Navigator.pushNamed(context, EnterPhoneScreen.tag);
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    return
        Container(
          alignment: Alignment.center,
            child: WillPopScope(
              onWillPop: () async => false,
              child:new IntroSlider(
              slides: CommonMethods.addSlideImages(),
              colorDoneBtn: Color(hexColorCode.defaultGreen),
              colorActiveDot: Color(hexColorCode.defaultGreen),
              colorDot: Color(hexColorCode.white1),
              onDonePress: this.onDonePress),

        )
        );
  }
}
