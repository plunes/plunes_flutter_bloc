import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'dart:math' as math;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';

// ignore: must_be_immutable
class RealInsightPopup extends BaseActivity {
  RealInsight realInsight;
  DocHosMainInsightBloc docHosMainInsightBloc;

  RealInsightPopup({this.realInsight, this.docHosMainInsightBloc});

  @override
  _RealInsightPopupState createState() => _RealInsightPopupState();
}

class _RealInsightPopupState extends BaseState<RealInsightPopup> {
  num sliderVal;
  num chancesPercent = 25;
  num reductionInPrice, half;
  TextEditingController _priceController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  String failureCause;
  bool shouldShowField = false;
  RealInsight _realInsight;
  DocHosMainInsightBloc _docHosMainInsightBloc;

  @override
  void initState() {
    _realInsight = widget.realInsight;
    _docHosMainInsightBloc = widget.docHosMainInsightBloc;
    sliderVal = (_realInsight.userPrice.toDouble() / 2) +
        (((_realInsight.userPrice.toDouble() / 2)) / 2);
    half = (_realInsight.userPrice.toDouble() / 2) +
        (((_realInsight.userPrice.toDouble() / 2)) / 2);
    reductionInPrice = ((((_realInsight.userPrice.toDouble() / 2)) / 2) * 100) /
        _realInsight.userPrice.toDouble();
    if (sliderVal == null || sliderVal == 0) {
      chancesPercent = 0;
      reductionInPrice = 0;
    }
    super.initState();
  }

  @override
  void dispose() {
    _priceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: ExactAssetImage(PlunesImages.insight_bg_img),
              fit: BoxFit.fill)),
      child: StreamBuilder<RequestState>(
          stream: _docHosMainInsightBloc.realTimePriceUpdateStream,
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
              String failureCause = requestFailed.failureCause;
              return SingleChildScrollView(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3),
                        height: AppConfig.verticalBlockSize * 10,
                        child:
                            Image.asset(PlunesImages.plunesCommonGreenBgImage),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: AppConfig.verticalBlockSize * 2.5),
                        padding: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 3),
                        child: Text(
                          failureCause ?? plunesStrings.somethingWentWrong,
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
                              splashColor:
                                  PlunesColors.SPARKLINGGREEN.withOpacity(.1),
                              focusColor: Colors.transparent,
                              onPressed: () => Navigator.pop(context),
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
            return SingleChildScrollView(
              controller: _scrollController,
//              reverse: shouldShowField
//                  ? true
//                  : (failureCause != null && failureCause.isNotEmpty)
//                      ? true
//                      : false,
              child: Container(
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1),
                child: Column(
                  children: <Widget>[
                    StatefulBuilder(builder: (context, newState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: AppConfig.horizontalBlockSize * 5),
                                  child: Text(PlunesStrings.realTimePrediction,
                                      style: TextStyle(
                                          fontSize: AppConfig.extraLargeFont,
                                          color: PlunesColors.WHITECOLOR,
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center),
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.close,
                                    color: PlunesColors.WHITECOLOR,
                                  ),
                                ),
                              )
                            ],
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 3),
                            child: Text(
                              _realInsight?.serviceName ?? PlunesStrings.NA,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppConfig.mediumFont,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 3),
                            padding: EdgeInsets.only(
                                left: AppConfig.horizontalBlockSize * 3,
                                right: AppConfig.horizontalBlockSize * 3,
                                top: AppConfig.verticalBlockSize * 4.0,
                                bottom: AppConfig.verticalBlockSize * 2),
                            child: Text(
                              'Update your best price for maximum bookings',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppConfig.mediumFont),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Column(
                            children: <Widget>[
//                              Container(
//                                margin: EdgeInsets.symmetric(
//                                    horizontal:
//                                        AppConfig.horizontalBlockSize * 10),
//                                child: Row(
//                                  mainAxisAlignment:
//                                      MainAxisAlignment.spaceBetween,
//                                  children: <Widget>[
//                                    Text(
//                                      '',
//                                      style: TextStyle(
//                                          color: Colors.white,
//                                          fontSize: AppConfig.mediumFont - 1,
//                                          fontWeight: FontWeight.w600),
//                                    ),
//                                    (half != null && half != 0)
//                                        ? Column(
//                                            mainAxisAlignment:
//                                                MainAxisAlignment.center,
//                                            crossAxisAlignment:
//                                                CrossAxisAlignment.center,
//                                            children: <Widget>[
//                                              Text(
//                                                '${half?.toStringAsFixed(1) ?? ""}',
//                                                style: TextStyle(
//                                                    color: Colors.white,
//                                                    fontSize:
//                                                        AppConfig.mediumFont -
//                                                            1,
//                                                    fontWeight:
//                                                        FontWeight.w600),
//                                              ),
//                                              Icon(
//                                                Icons.arrow_drop_down,
//                                                color: Colors.white,
//                                                size: 20,
//                                              )
//                                            ],
//                                          )
//                                        : Container(),
//                                    Text(
//                                      '',
//                                      style: TextStyle(
//                                          color: Colors.white,
//                                          fontSize: AppConfig.mediumFont - 1,
//                                          fontWeight: FontWeight.w600),
//                                    ),
//                                  ],
//                                  crossAxisAlignment: CrossAxisAlignment.start,
//                                ),
//                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 3),
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Color.lerp(
                                        Color(CommonMethods.getColorHexFromStr(
                                            "#CEFFE2")),
                                        Color(CommonMethods.getColorHexFromStr(
                                            "#01D35A")),
                                        0.7),
                                    inactiveTrackColor: PlunesColors.WHITECOLOR,
                                    trackShape: RoundedRectSliderTrackShape(),
                                    trackHeight: 8.5,
                                    thumbColor: PlunesColors.LIGHTGREENCOLOR,
                                    thumbShape: SliderThumbShape(
                                      enabledThumbRadius: 12,
                                    ),
                                    overlayColor:
                                        PlunesColors.GREENCOLOR.withAlpha(32),
                                    overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 28.0),
                                  ),
                                  child: Slider(
                                    value: sliderVal,
                                    min: (_realInsight.userPrice.floor() / 2) ??
                                        0,
                                    max: _realInsight.userPrice
                                        .floor()
                                        .toDouble(),
                                    divisions: 100,
                                    onChanged: (newValue) {
                                      if (shouldShowField) {
                                        return;
                                      }
                                      newState(() {
                                        try {
                                          var val = (newValue * 100) /
                                              _realInsight.userPrice
                                                  .floor()
                                                  .toDouble();
                                          reductionInPrice = ((newValue) *
                                                  100) /
                                              _realInsight.userPrice.toDouble();
                                          reductionInPrice =
                                              100 - reductionInPrice;

                                          chancesPercent = double.tryParse(
                                              (100 - val)?.toStringAsFixed(1));
                                        } catch (e) {
                                          chancesPercent = 50;
                                          reductionInPrice = 50;
                                        }
                                        sliderVal = newValue;
                                      });
                                    },
                                    label: "${sliderVal.toStringAsFixed(1)}",
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      ' \u20B9 ${(_realInsight.userPrice.floor() / 2)?.toStringAsFixed(0)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppConfig.mediumFont - 1,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    (half != null && half != 0)
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '${half?.toStringAsFixed(1) ?? ""}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        AppConfig.mediumFont -
                                                            1,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Icon(
                                                Icons.arrow_drop_up,
                                                color: PlunesColors.GREENCOLOR,
                                                size: 20,
                                              ),
                                              Text(
                                                'Recommended',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        AppConfig.mediumFont -
                                                            1,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    Text(
                                      ' \u20B9 ${_realInsight.userPrice?.toStringAsFixed(0)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppConfig.mediumFont - 1,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical:
                                          AppConfig.verticalBlockSize * 1.2,
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 3),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 15),
                                  child: (_realInsight.suggested != null &&
                                          _realInsight.suggested &&
                                          shouldShowField)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
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
                                                padding: EdgeInsets.all(5.0),
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Icon(
                                                  Icons.mode_edit,
                                                  color:
                                                      PlunesColors.GREENCOLOR,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              (_realInsight.suggested != null &&
                                                      _realInsight.suggested &&
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
                                            (_realInsight.suggested != null &&
                                                    _realInsight.suggested)
                                                ? Flexible(
                                                    child: InkWell(
                                                    onTap: () {
                                                      shouldShowField = true;
                                                      newState(() {});
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(5.0),
                                                      alignment:
                                                          Alignment.topCenter,
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
                              FlatButton(
                                  focusColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    if (_realInsight.suggested != null &&
                                        _realInsight.suggested &&
                                        shouldShowField) {
                                      if (_priceController.text
                                              .trim()
                                              .isEmpty ||
                                          _priceController.text
                                                  .trim()
                                                  .substring(0) ==
                                              "0" ||
                                          (double.tryParse(_priceController.text
                                                  .trim()) <
                                              1)) {
                                        failureCause =
                                            'Price must not be lesser than 1 or empty';
                                        newState(() {});
                                        return;
                                      }
                                      _docHosMainInsightBloc
                                          .updateRealTimeInsightPriceStream(
                                              RequestInProgress());
                                      _docHosMainInsightBloc
                                          .getUpdateRealTimeInsightPrice(
                                              num.tryParse(
                                                  _priceController.text.trim()),
                                              _realInsight.solutionId,
                                              _realInsight.serviceId,
                                              isSuggestive: true,
                                              suggestedPrice: num.tryParse(
                                                  _priceController.text
                                                      .trim()));
                                    } else {
                                      if (sliderVal == null || sliderVal == 0) {
                                        failureCause = 'Price must not be 0.';
                                        newState(() {});
                                        return;
                                      } else if (sliderVal ==
                                          _realInsight.userPrice) {
                                        failureCause =
                                            'Sorry, Make sure Updated Price is not equal to Original Price !';
                                        newState(() {});
                                        return;
                                      }
                                      _docHosMainInsightBloc
                                          .updateRealTimeInsightPriceStream(
                                              RequestInProgress());
                                      _docHosMainInsightBloc
                                          .getUpdateRealTimeInsightPrice(
                                              chancesPercent,
                                              _realInsight.solutionId,
                                              _realInsight.serviceId,
                                              isSuggestive:
                                                  (_realInsight.suggested !=
                                                          null &&
                                                      _realInsight.suggested),
                                              suggestedPrice: sliderVal);
                                    }
                                  },
                                  child: Container(
                                      height: AppConfig.verticalBlockSize * 4,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          'Apply here',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: AppConfig.mediumFont,
                                              color: PlunesColors.GREENCOLOR),
                                        ),
                                      ))),
                              chancesPercent != null
                                  ? Container(
                                      margin: EdgeInsets.only(
                                          top:
                                              AppConfig.verticalBlockSize * 1.2,
                                          bottom:
                                              AppConfig.verticalBlockSize * 2,
                                          left:
                                              AppConfig.horizontalBlockSize * 3,
                                          right: AppConfig.horizontalBlockSize *
                                              3),
                                      child: Text(
                                        'Chances of Conversion increases by',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppConfig.mediumFont,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Container(
                                width: AppConfig.horizontalBlockSize * 40,
                                height: AppConfig.verticalBlockSize * 16,
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
                                            width: 0.2,
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
                                                  fontSize: 18,
                                                  color:
                                                      PlunesColors.WHITECOLOR),
                                            ))
                                      ])
                                ]),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 10),
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2),
                                child: LinearPercentIndicator(
                                  animation: true,
                                  lineHeight: 12.0,
                                  animationDuration: 2000,
                                  percent: 0.6,
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  center: Text(
                                    "63 %",
                                    style: TextStyle(
                                        color: PlunesColors.BLACKCOLOR,
                                        fontSize: 10),
                                  ),
                                  progressColor: Color(
                                      CommonMethods.getColorHexFromStr(
                                          "#F3CF3D")),
                                ),
                              ),
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_drop_up,
                                      color: PlunesColors.GREENCOLOR,
                                      size: 20,
                                    ),
                                    Text(
                                      'Competition Rate',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppConfig.mediumFont - 1,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
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
                                                .getColorHexFromStr("#FF9194")),
                                            fontWeight: FontWeight.w600),
                                      ),
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                          bottom:
                                              AppConfig.verticalBlockSize * 3))
                                  : Container(),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class SliderThumbShape extends SliderComponentShape {
  /// Create a slider thumb that draws a circle.

  const SliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
  });

  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default of 10 is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is equal to the
  /// [enabledThumbRadius]
  final double disabledThumbRadius;

  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  /// The resting elevation adds shadow to the unpressed thumb.
  ///
  /// The default is 1.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  ///
  final double elevation;

  /// The pressed elevation adds shadow to the pressed thumb.
  ///
  /// The default is 6.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    double textScaleFactor,
    Size sizeWithOverflow,
  }) {
    assert(context != null);
    assert(center != null);
    assert(enableAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);
//    assert(!sizeWithOverflow.isEmpty);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );

    final double radius = radiusTween.evaluate(enableAnimation);

    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    final double evaluatedElevation =
        elevationTween.evaluate(activationAnimation);

    {
      final Path path = Path()
        ..addArc(
            Rect.fromCenter(
                center: center, width: 1 * radius, height: 1 * radius),
            0,
            math.pi * 2);

      Paint paint = Paint()..color = PlunesColors.GREENCOLOR;
//      paint.strokeWidth = 1;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(
        center,
        radius,
        paint,
      );
      {
        Paint paint = Paint()..color = PlunesColors.LIGHTGREYCOLOR;
        paint.strokeWidth = 4;
        paint.style = PaintingStyle.stroke;
        canvas.drawCircle(
          center,
          radius,
          paint,
        );
      }
    }
  }
}
