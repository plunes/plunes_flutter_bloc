import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';

/// Created by Manvendra Kumar Singh

final colorsFile = PlunesColors();

class PlunesColors {
  get viewColor => "#CCCCCC";

  get redColor => "#EC2C23";

  get gradientRed => "#E23D2B";

  get gradientYellow => "#E7A925";

  get white => "#ffffff";

  get black => "#000000";

  get black1 => '#262626';

  get lightGrey => "#f5f5f5";

  get darkGrey => "#cc424242";

  get orangeLight => "#E69F25";

  get veryLightGrey => "#999999";

  get greyLight => '#444444';

  get grey => "#F2F2F2";

  get darkBrown => '#272727';

  get darkGrey1 => '#5D5D5D';

  get lightGrey1 => '#B2B2B2';

  get lightGrey2 => '#7E7E7E';

  get lightGrey3 => '#E2E2E2';

  get lightGrey4 => '#F9F9F9';

  get lightGrey5 => '#313131';

  get lightGrey6 => '#B7B7B7';

  get black0 => '#333333';

  get red => '#ff0000';

  get defaultGreen => '#01D35A';

  get lightGreen => '#ccffcc';

  get grey1 => '#8A8A8A';

  get white0 => '#F6F6F6';

  get lightBlue0 => '#F8FFFB';

  get defaultTransGreen => '#0001D35A';

  get lightGrey9 => '#7E7E7E';
  static const Color BLACKCOLOR = Colors.black;
  static const Color GREYCOLOR = Colors.grey;
  static final Color GREENCOLOR =
      Color(CommonMethods.getColorHexFromStr("#01D35A"));
  static const Color LIGHTGREENCOLOR = Color(0xFFF1F8E9);
  static const Color LIGHTGREYCOLOR = Color(0xFFEEEEEE);
  static const Color WHITECOLOR = Colors.white;
  static final Color SPARKLINGGREEN =
      Color(CommonMethods.getColorHexFromStr("#01D35A"));
  static final Color ORANGE =
      Color(CommonMethods.getColorHexFromStr("#E4AA31"));
  static final Color RED = Color(CommonMethods.getColorHexFromStr("#E0825F"));
  static final Color LIGHTESTGREYCOLOR =
      Color(CommonMethods.getColorHexFromStr("#EFEFEF"));
  static final Color PARROTGREEN =
      Color(CommonMethods.getColorHexFromStr("#25B281"));
}

final hexColorCode = HexColorCode();

class HexColorCode {
  var defaultGreen = 0xff01d35a;
  var defaultTransGreen = 0x1aff01d35a;

  var white1 = 0xffd7ffe8;
}
