import 'dart:math';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/src/text_element.dart' as tseee;

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      Color fillColor,
      FillPatternType fillPattern,
      Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        fillPattern: fillPattern,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    var textStyle = style.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 13;
    var t = tseee.TextElement(
      "You are here",
      style: textStyle,
    );
    canvas.drawRect(
        Rectangle(
            bounds.left - 34,
            bounds.top - 30,
            bounds.width + t.measurement.horizontalSliceWidth,
            bounds.height + 10),
        fill: Color.white);
    canvas.drawText(
        tseee.TextElement(
          "You are here",
          style: textStyle,
        ),
        (bounds.left - 30).round(),
        (bounds.top - 28).round());
  }
}
