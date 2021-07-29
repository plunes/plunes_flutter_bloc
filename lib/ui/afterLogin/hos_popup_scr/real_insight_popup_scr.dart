import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/video_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/doc_hos_bloc/doc_hos_main_screen_bloc.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/afterLogin/graphs/real_insight_graph.dart';
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
  num half;
  TextEditingController _priceController = TextEditingController();
  TextEditingController _offeredPriceController = TextEditingController();

  // ScrollController _scrollController = ScrollController();
  String failureCause;
  bool shouldShowField = false, _hasPrice;
  RealInsight _realInsight;
  DocHosMainInsightBloc _docHosMainInsightBloc;
  Timer _timer;
  double _topMargin = 0;
  StreamController _streamForIcon;
  TextEditingController _techniqueController = TextEditingController();
  TextEditingController _addOnController = TextEditingController();
  TextEditingController _specialOfferController = TextEditingController();

  @override
  void initState() {
    _realInsight = widget.realInsight;
    _streamForIcon = StreamController.broadcast();
    _docHosMainInsightBloc = widget.docHosMainInsightBloc;
    _init();
    super.initState();
  }

  _init() {
    if (_realInsight.isPrice != null && !_realInsight.isPrice) {
      _hasPrice = false;
    } else {
      _hasPrice = true;
      // if (_realInsight.recommendation != null &&
      //     _realInsight.recommendation > 0) {
      //   var recommendation = 100 - _realInsight.recommendation;
      //   if (_realInsight.userPrice <= 5) {
      //     sliderVal =
      //         ((_realInsight.userPrice / 100) * recommendation)?.toDouble();
      //     half = ((_realInsight.userPrice / 100) * recommendation)?.toDouble();
      //     _offeredPriceController.text = half?.toStringAsFixed(1) ?? '';
      //   } else {
      //     sliderVal =
      //         ((_realInsight.userPrice / 100) * recommendation)?.toDouble();
      //     half = ((_realInsight.userPrice / 100) * recommendation)?.toDouble();
      //     sliderVal = sliderVal - (sliderVal % 5);
      //     half = half - (half % 5);
      //     _offeredPriceController.text = half?.toStringAsFixed(1) ?? '';
      //   }
      //   if (sliderVal < _realInsight.min) {
      //     sliderVal = _realInsight.min;
      //     half = _realInsight.min;
      //     _offeredPriceController.text =
      //         _realInsight.min?.toStringAsFixed(1) ?? '';
      //   }
      // } else if (_realInsight.suggested != null && _realInsight.suggested) {
      //   sliderVal = _realInsight.userPrice.toInt().toDouble();
      //   half = _realInsight.userPrice.toInt().toDouble();
      //   _offeredPriceController.text = half?.toStringAsFixed(1) ?? '';
      // } else {
      //   Navigator.pop(context);
      // }
      // _setChancesOfConversion();
      // if (sliderVal == null || sliderVal == 0) {
      //   chancesPercent = 0;
      // }
      // _timer = Timer.periodic(Duration(milliseconds: 1200), (timer) {
      //   if (_topMargin == 0) {
      //     _topMargin = 3;
      //   } else {
      //     _topMargin = 0;
      //   }
      //   _streamForIcon.add(null);
      // });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamForIcon?.close();
    _priceController?.dispose();
    _techniqueController?.dispose();
    _addOnController?.dispose();
    _specialOfferController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar:
            widget.getAppBar(context, PlunesStrings.realTimePrediction, true),
        key: scaffoldKey,
        body: Builder(
          builder: (context) {
            return Container(
              width: double.infinity,
              padding: MediaQuery.of(context).padding,
              decoration: BoxDecoration(
                  color: Colors.black45,
                  image: DecorationImage(
                      image: ExactAssetImage(PlunesImages.insight_bg_img),
                      fit: BoxFit.fill)),
              child: _getBody(),
            );
          },
        ),
      ),
    );
  }

  void _setChancesOfConversion() {
    try {
      var firstVal = (_realInsight.max - _realInsight.min) / 70;
      var secVal = (sliderVal - _realInsight.min) / firstVal;
      var thirdVal = 70 - secVal;
      chancesPercent = thirdVal?.floor()?.toDouble() ?? 0;
      if (chancesPercent >= 70) {
        chancesPercent = 70;
      }
    } catch (e) {
      // print("Breaking here val");
    }
  }

  _showSnackBar(String message) {
    if (mounted)
      showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets()
                .getInformativePopup(globalKey: scaffoldKey, message: message);
          });
  }

  Widget _getBody() {
    return StreamBuilder<RequestState>(
        stream: _docHosMainInsightBloc.realTimePriceUpdateStream,
        builder: (context, snapShot) {
          if (snapShot.data is RequestInProgress) {
            return CustomWidgets().getProgressIndicator();
          }
          if (snapShot.data is RequestSuccess) {
            Future.delayed(Duration(milliseconds: 200)).then((value) {
              Navigator.pop(context, true);
            });
          }
          if (snapShot.data is RequestFailed) {
            RequestFailed requestFailed = snapShot.data;
            final String message = requestFailed.failureCause;
            _docHosMainInsightBloc?.updateRealTimeInsightPriceStream(null);
            Future.delayed(Duration(milliseconds: 10)).then((value) {
              _showSnackBar(message);
            });
          }
          return Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 2.5),
            child: ListView(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      CommonMethods.getStringInCamelCase(
                          _realInsight?.userName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 28, color: PlunesColors.WHITECOLOR)),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "is looking for ${_realInsight?.serviceName ?? ''}",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 21, color: PlunesColors.WHITECOLOR)),
                ),
                _realInsight?.userReport?.haveInsurance ?? false
                    ? Container(
                        alignment: Alignment.centerLeft,
                        child: Text("(Have insurance)",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14, color: PlunesColors.WHITECOLOR)),
                      )
                    : Container(),
                _getBodyPartsSessionWidget(),
                // _getInsuranceDetailsSection(),
                1 == 1
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Price Insight",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 21,
                                    color: PlunesColors.WHITECOLOR)),
                            Expanded(
                                child: Container(
                              margin: EdgeInsets.only(
                                  left: AppConfig.horizontalBlockSize * 2),
                              height: 0.8,
                              width: double.infinity,
                              color: Colors.white38,
                            ))
                          ],
                        ),
                      ),
                _getSliderWidget(),
                _getGraphWidget(),
                _getAddonAndSpecialOfferProviderWidget(),
                (_realInsight.category != null &&
                        _realInsight.category.toLowerCase() ==
                            Constants.procedureKey.toLowerCase())
                    ? _getFacilityProvidingOffersWidget()
                    : Container(),
                _getSubmitButton()
              ],
            ),
          );
        });
  }

  Widget _getInsuranceDetailsSection() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Insurance details",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 21, color: PlunesColors.WHITECOLOR)),
                Expanded(
                    child: Container(
                  margin:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
                  height: 0.8,
                  width: double.infinity,
                  color: Colors.white38,
                ))
              ],
            ),
          ),
          (_realInsight.userReport != null &&
                      _realInsight.userReport.imageUrl != null &&
                      _realInsight.userReport.imageUrl.isNotEmpty) ||
                  (_realInsight.userReport != null &&
                      _realInsight.userReport.reportUrl != null &&
                      _realInsight.userReport.reportUrl.isNotEmpty)
              ? Container(
                  margin: EdgeInsets.only(top: 10),
                  height: AppConfig.verticalBlockSize * 25,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (_realInsight.userReport != null &&
                              _realInsight.userReport.imageUrl != null &&
                              _realInsight.userReport.imageUrl.isNotEmpty)
                          ? Flexible(
                              child: Container(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 8, bottom: 8),
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#2D2C3E"))),
                              child: InkWell(
                                onTap: () {
                                  List<Photo> photos = [];
                                  _realInsight.userReport.imageUrl
                                      .forEach((element) {
                                    if (element == null ||
                                        element.isEmpty ||
                                        !(element.contains("http"))) {
                                    } else {
                                      photos.add(Photo(assetName: element));
                                    }
                                  });
                                  if (photos != null && photos.isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PageSlider(photos, 0)));
                                  }
                                },
                                onDoubleTap: () {},
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Insurance Photo",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: PlunesColors.WHITECOLOR
                                                .withOpacity(0.8)),
                                      ),
                                    ),
                                    Flexible(
                                        child: Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(top: 5),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)),
                                                child: CustomWidgets()
                                                    .getImageFromUrl(
                                                        _realInsight
                                                                .userReport
                                                                .imageUrl
                                                                ?.first ??
                                                            "",
                                                        boxFit: BoxFit.fill),
                                              ),
                                            ),
                                          ),
                                          _realInsight.userReport.imageUrl
                                                      .length >
                                                  1
                                              ? Positioned.fill(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "+${_realInsight.userReport.imageUrl.length}",
                                                      style: TextStyle(
                                                          color: PlunesColors
                                                              .GREYCOLOR,
                                                          fontSize: 60),
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ))
                          : Container(),
                      (_realInsight.userReport != null &&
                              _realInsight.userReport.reportUrl != null &&
                              _realInsight.userReport.reportUrl.isNotEmpty)
                          ? Flexible(
                              child: Container(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 8, bottom: 8),
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#2D2C3E"))),
                              child: InkWell(
                                onTap: () {
                                  if (_realInsight.userReport.reportUrl.first !=
                                      null) {
                                    _launch(_realInsight
                                        .userReport.reportUrl.first);
                                  }
                                },
                                onDoubleTap: () {},
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Insurance Documents",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: PlunesColors.WHITECOLOR
                                                .withOpacity(0.8)),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.only(top: 5),
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)),
                                                child: Image.asset(
                                                  plunesImages.pdfIcon1,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                          : Container(),
                    ],
                  ),
                )
              : Container(),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 8, right: 12, top: 12, bottom: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Color(CommonMethods.getColorHexFromStr("#2D2C3E"))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Insurance provider",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: PlunesColors.WHITECOLOR.withOpacity(0.8)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    "Insurance provider name here",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        color: PlunesColors.WHITECOLOR.withOpacity(0.8)),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 8, right: 12, top: 12, bottom: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Color(CommonMethods.getColorHexFromStr("#2D2C3E"))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Insurance number",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: PlunesColors.WHITECOLOR.withOpacity(0.8)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    "473567436483246823694832684",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        color: PlunesColors.WHITECOLOR.withOpacity(0.8)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getUserUploadedMediaWidget() {
    return _hasMediaData()
        ? Container(
            margin: EdgeInsets.only(top: 10),
            height: AppConfig.verticalBlockSize * 25,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                (_realInsight.userReport != null &&
                        _realInsight.userReport.videoUrl != null &&
                        _realInsight.userReport.videoUrl.isNotEmpty)
                    ? Flexible(
                        child: Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 8, bottom: 8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color(
                                CommonMethods.getColorHexFromStr("#2D2C3E"))),
                        child: InkWell(
                          onTap: () {
                            // print(
                            //     "_realInsight.userReport.videoUrl.first.url ${_realInsight.userReport.videoUrl.first.url}");
                            if (_realInsight.userReport.videoUrl.first.url !=
                                null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VideoUtil(
                                          _realInsight
                                              .userReport.videoUrl.first.url)));
                            }
                          },
                          onDoubleTap: () {},
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Video",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: PlunesColors.WHITECOLOR
                                          .withOpacity(0.8)),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(top: 5),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          child: CustomWidgets()
                                              .getImageFromUrl(
                                                  _realInsight
                                                          .userReport
                                                          .videoUrl
                                                          ?.first
                                                          ?.thumbnail ??
                                                      "",
                                                  boxFit: BoxFit.cover),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Image.asset(
                                            PlunesImages.pauseVideoIcon,
                                            height: 28,
                                            width: 28,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                    : Container(),
                (_realInsight.userReport != null &&
                        _realInsight.userReport.imageUrl != null &&
                        _realInsight.userReport.imageUrl.isNotEmpty)
                    ? Flexible(
                        child: Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 8, bottom: 8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color(
                                CommonMethods.getColorHexFromStr("#2D2C3E"))),
                        child: InkWell(
                          onTap: () {
                            List<Photo> photos = [];
                            _realInsight.userReport.imageUrl.forEach((element) {
                              if (element == null ||
                                  element.isEmpty ||
                                  !(element.contains("http"))) {
                              } else {
                                photos.add(Photo(assetName: element));
                              }
                            });
                            if (photos != null && photos.isNotEmpty) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PageSlider(photos, 0)));
                            }
                          },
                          onDoubleTap: () {},
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Photos",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: PlunesColors.WHITECOLOR
                                          .withOpacity(0.8)),
                                ),
                              ),
                              Flexible(
                                  child: Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(top: 5),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          child: CustomWidgets()
                                              .getImageFromUrl(
                                                  _realInsight.userReport
                                                          .imageUrl?.first ??
                                                      "",
                                                  boxFit: BoxFit.fill),
                                        ),
                                      ),
                                    ),
                                    _realInsight.userReport.imageUrl.length > 1
                                        ? Positioned.fill(
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "+${_realInsight.userReport.imageUrl.length}",
                                                style: TextStyle(
                                                    color:
                                                        PlunesColors.GREYCOLOR,
                                                    fontSize: 60),
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ))
                    : Container(),
                (_realInsight.userReport != null &&
                        _realInsight.userReport.reportUrl != null &&
                        _realInsight.userReport.reportUrl.isNotEmpty)
                    ? Flexible(
                        child: Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 8, bottom: 8),
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color(
                                CommonMethods.getColorHexFromStr("#2D2C3E"))),
                        child: InkWell(
                          onTap: () {
                            if (_realInsight.userReport.reportUrl.first !=
                                null) {
                              _launch(_realInsight.userReport.reportUrl.first);
                            }
                          },
                          onDoubleTap: () {},
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Reports",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: PlunesColors.WHITECOLOR
                                          .withOpacity(0.8)),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(top: 5),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          child: Image.asset(
                                            plunesImages.pdfIcon1,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                    : Container(),
              ],
            ),
          )
        : Container();
  }

  Widget _getAddonAndSpecialOfferProviderWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Details",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 21, color: PlunesColors.WHITECOLOR)),
                Expanded(
                    child: Container(
                  margin:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
                  height: 0.8,
                  width: double.infinity,
                  color: Colors.white38,
                ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Color(CommonMethods.getColorHexFromStr("#2D2C3E"))),
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      "Provide your best price to beat the competition",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: PlunesColors.WHITECOLOR.withOpacity(0.8),
                          fontSize: 22),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Package Price  ",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20, color: PlunesColors.WHITECOLOR)),
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CustomWidgets().getInformativePopup(
                                      globalKey: scaffoldKey,
                                      message:
                                          "Package Price is the Total amount for the Service at your Facility.");
                                });
                            return;
                          },
                          onDoubleTap: () {},
                          child: Icon(
                            Icons.info_outline,
                            color: PlunesColors.WHITECOLOR.withOpacity(0.8),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        color:
                            Color(CommonMethods.getColorHexFromStr("#535264")),
                        border: Border.all(
                            color: PlunesColors.WHITECOLOR, width: 0.8)),
                    child: TextField(
                      textAlign: TextAlign.left,
                      controller: _priceController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                          fontSize: 12, color: PlunesColors.WHITECOLOR),
                      decoration: InputDecoration.collapsed(
                          hintText: "Enter price",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              fontSize: 12,
                              color: Color(CommonMethods.getColorHexFromStr(
                                  "#9B9B9B")))),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 5, top: AppConfig.verticalBlockSize * 1.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Offered Price  ",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20, color: PlunesColors.WHITECOLOR)),
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CustomWidgets().getInformativePopup(
                                      globalKey: scaffoldKey,
                                      message:
                                          "Offered Price is the discounted price of the service you're providing to your potential Patient.");
                                });
                            return;
                          },
                          onDoubleTap: () {},
                          child: Icon(
                            Icons.info_outline,
                            color: PlunesColors.WHITECOLOR.withOpacity(0.8),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        color:
                            Color(CommonMethods.getColorHexFromStr("#535264")),
                        border: Border.all(
                            color: PlunesColors.WHITECOLOR, width: 0.8)),
                    child: TextField(
                      textAlign: TextAlign.left,
                      controller: _offeredPriceController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                          fontSize: 12, color: PlunesColors.WHITECOLOR),
                      decoration: InputDecoration.collapsed(
                          hintText: "Enter price",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              fontSize: 12,
                              color: Color(CommonMethods.getColorHexFromStr(
                                  "#9B9B9B")))),
                    ),
                  ),
                  (_realInsight.category != null &&
                          _realInsight.category.toLowerCase() ==
                              Constants.procedureKey.toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              left: 5, top: AppConfig.verticalBlockSize * 1.5),
                          child: Text("Technology/Technique",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: PlunesColors.WHITECOLOR)),
                        )
                      : Container(),
                  (_realInsight.category != null &&
                          _realInsight.category.toLowerCase() ==
                              Constants.procedureKey.toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 1.5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#535264")),
                              border: Border.all(
                                  color: PlunesColors.WHITECOLOR, width: 0.8)),
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: _techniqueController,
                            style: TextStyle(
                                fontSize: 12, color: PlunesColors.WHITECOLOR),
                            decoration: InputDecoration.collapsed(
                                hintText:
                                    "Enter Technology Ex. Dual Accento laser",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#9B9B9B")))),
                          ),
                        )
                      : Container(),
                  (_realInsight.category != null &&
                          _realInsight.category.toLowerCase() ==
                              Constants.procedureKey.toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              left: 5, top: AppConfig.verticalBlockSize * 1.5),
                          child: Text("Add on's",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: PlunesColors.WHITECOLOR)),
                        )
                      : Container(),
                  (_realInsight.category != null &&
                          _realInsight.category.toLowerCase() ==
                              Constants.procedureKey.toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              left: 5, top: AppConfig.verticalBlockSize * 1.2),
                          child: Text(
                              "Enter add on's for better conversion chances",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: PlunesColors.WHITECOLOR)),
                        )
                      : Container(),
                  (_realInsight.category != null &&
                          _realInsight.category.toLowerCase() ==
                              Constants.procedureKey.toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 1.5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#535264")),
                              border: Border.all(
                                  color: PlunesColors.WHITECOLOR, width: 0.8)),
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: _addOnController,
                            style: TextStyle(
                                fontSize: 12, color: PlunesColors.WHITECOLOR),
                            decoration: InputDecoration.collapsed(
                                hintText: "Enter Add on's Ex. 2PRP",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#9B9B9B")))),
                          ),
                        )
                      : Container(),
                  (_realInsight.category != null &&
                          _realInsight.category.toLowerCase() ==
                              Constants.procedureKey.toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              left: 5, top: AppConfig.verticalBlockSize * 1.5),
                          child: Text("Special offers",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: PlunesColors.WHITECOLOR)),
                        )
                      : Container(),
                  (_realInsight.category != null &&
                          _realInsight.category.toLowerCase() ==
                              Constants.procedureKey.toLowerCase())
                      ? Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 1.5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#535264")),
                              border: Border.all(
                                  color: PlunesColors.WHITECOLOR, width: 0.8)),
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: _specialOfferController,
                            style: TextStyle(
                                fontSize: 12, color: PlunesColors.WHITECOLOR),
                            decoration: InputDecoration.collapsed(
                                hintText:
                                    "Enter special offers Ex. Dual Accento laser",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#9B9B9B")))),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getFacilityProvidingOffersWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Color(CommonMethods.getColorHexFromStr("#2D2C3E"))),
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Facility providing offers",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16, color: PlunesColors.WHITECOLOR)),
                  ),
                  (_realInsight.specialOffers == null ||
                          _realInsight.specialOffers.isEmpty)
                      ? _getAddSpecialOfferEmptyWidget()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 1.5),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#535264")),
                                  border: Border.all(
                                      color: PlunesColors.WHITECOLOR,
                                      width: 0.8)),
                              child: Row(
                                children: [
                                  Container(
                                    child: Image.asset(
                                        PlunesImages.specialInsightOfferImage),
                                    height: 40,
                                    width: 40,
                                    margin: EdgeInsets.only(right: 15),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _realInsight.specialOffers[index]?.values
                                              ?.first ??
                                          "",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: PlunesColors.WHITECOLOR),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: _realInsight.specialOffers?.length ?? 0,
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getSubmitButton() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: AppConfig.verticalBlockSize * 1.8,
          horizontal: AppConfig.horizontalBlockSize * 30),
      child: InkWell(
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          if (_priceController.text.trim().isEmpty ||
              _priceController.text.trim().substring(0) == "0" ||
              (double.tryParse(_priceController.text.trim()) < 1)) {
            _showSnackBar('Package price must not be lesser than 1 or empty');
            return;
          } else if (_offeredPriceController.text.trim().isEmpty ||
              _offeredPriceController.text.trim().substring(0) == "0" ||
              (double.tryParse(_offeredPriceController.text.trim()) < 1)) {
            _showSnackBar('Offered price must not be lesser than 1 or empty');
            return;
          } else if (double.tryParse(_priceController.text.trim()) <
              double.tryParse(_offeredPriceController.text.trim())) {
            _showSnackBar(
                'Offered price must not be lesser than Package price');
            return;
          }
          _docHosMainInsightBloc.getUpdateRealTimeInsightPrice(
              chancesPercent, _realInsight.solutionId, _realInsight.serviceId,
              isSuggestive:
                  (_realInsight.suggested != null && _realInsight.suggested),
              packagePrice: num.tryParse(_priceController.text.trim()),
              realInsight: _realInsight,
              offeredPrice: num.tryParse(_offeredPriceController.text.trim()),
              addOnText: _addOnController.text.trim(),
              specialOfferText: _specialOfferController.text.trim(),
              techniqueText: _techniqueController.text.trim());
        },
        onDoubleTap: () {},
        child: CustomWidgets().getRoundedButton(
            plunesStrings.submit,
            AppConfig.horizontalBlockSize * 8,
            Color(CommonMethods.getColorHexFromStr("#25B281")),
            AppConfig.horizontalBlockSize * 3,
            AppConfig.verticalBlockSize * 1,
            PlunesColors.WHITECOLOR,
            borderColor: PlunesColors.SPARKLINGGREEN,
            hasBorder: true),
      ),
    );
  }

  Widget _getSliderWidget() {
    if (1 == 1) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Color(CommonMethods.getColorHexFromStr("#2D2C3E"))),
      child: StatefulBuilder(builder: (context, newState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 3,
                      right: AppConfig.horizontalBlockSize * 3,
                      bottom: AppConfig.verticalBlockSize * 1.5),
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 12.0,
                    animationDuration: 2000,
                    percent: 0.5,
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: PlunesColors.GREENCOLOR,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        ' \u20B9 ${(_realInsight.min)?.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: AppConfig.mediumFont - 1,
                            fontWeight: FontWeight.w600),
                      ),
                      (half != null && half != 0)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${half?.toStringAsFixed(1) ?? ""}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppConfig.mediumFont - 1,
                                      fontWeight: FontWeight.w600),
                                ),
                                StreamBuilder<Object>(
                                    stream: _streamForIcon?.stream,
                                    builder: (context, snapshot) {
                                      return Container(
                                        height: 15,
                                        child: AnimatedContainer(
                                          margin:
                                              EdgeInsets.only(top: _topMargin),
                                          duration: Duration(milliseconds: 600),
                                          curve: Curves.easeInOut,
                                          child: Icon(
                                            Icons.arrow_drop_up,
                                            color: PlunesColors.GREENCOLOR,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    }),
                                Text(
                                  'Recommendation',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppConfig.mediumFont - 1,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          : Container(),
                      Text(
                        ' \u20B9 ${_realInsight.max?.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: AppConfig.mediumFont - 1,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                chancesPercent != null
                    ? Container(
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3,
                            bottom: AppConfig.verticalBlockSize * 3,
                            left: AppConfig.horizontalBlockSize * 3,
                            right: AppConfig.horizontalBlockSize * 3),
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
                  height: AppConfig.verticalBlockSize * 12.5,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                        pointers: [
                          RangePointer(
                              value: chancesPercent == null ||
                                      chancesPercent == 0 ||
                                      chancesPercent < 0
                                  ? 0
                                  : double.parse(
                                      chancesPercent.toStringAsFixed(0)),
                              width: 0.25,
                              sizeUnit: GaugeSizeUnit.factor,
                              cornerStyle: CornerStyle.bothFlat,
                              gradient: SweepGradient(colors: <Color>[
                                PlunesColors.GREENCOLOR,
                                PlunesColors.GREENCOLOR
                              ], stops: <double>[
                                0.25,
                                0.75
                              ])),
                        ],
                        minimum: 0,
                        maximum: 70,
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
                                    color: PlunesColors.WHITECOLOR),
                              ))
                        ])
                  ]),
                ),
                (_realInsight.compRate == null || _realInsight.compRate <= 0)
                    ? Container()
                    : Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 10),
                        margin: EdgeInsets.only(
                            top: AppConfig.verticalBlockSize * 3),
                        child: LinearPercentIndicator(
                          animation: true,
                          lineHeight: 12.0,
                          animationDuration: 2000,
                          percent: (_realInsight.compRate != null &&
                                  _realInsight.compRate != 0)
                              ? _realInsight.compRate / 100
                              : 0,
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          center: Text(
                            "${_realInsight.compRate?.toStringAsFixed(0) ?? 0} %",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 10),
                          ),
                          progressColor: Color(
                              CommonMethods.getColorHexFromStr("#F3CF3D")),
                        ),
                      ),
                (_realInsight.compRate == null || _realInsight.compRate <= 0)
                    ? Container()
                    : Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.arrow_drop_up,
                                color: PlunesColors.GREENCOLOR, size: 20),
                            Text(
                              'Competition Rate',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppConfig.mediumFont - 1,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 3))
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _getGraphWidget() {
    if (1 == 1) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Color(CommonMethods.getColorHexFromStr("#2D2C3E"))),
      child: (_realInsight != null &&
              _realInsight.dataPoints != null &&
              _realInsight.dataPoints.isNotEmpty)
          ? Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 2),
              height: 324,
              width: double.infinity,
              child: StaticallyProvidedTicks.withSampleData(
                  _realInsight.dataPoints, _realInsight.userPrice),
            )
          : Container(),
    );
  }

  _launch(String url) {
    LauncherUtil.launchUrl(url);
  }

  Widget _getAddSpecialOfferEmptyWidget() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            alignment: Alignment.center,
            height: 88,
            width: 117,
            child: Image.asset(
              PlunesImages.add_special_offer_insight,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 3),
            alignment: Alignment.center,
            child: Text(
              "Be first to provide offers and Add on's to increase your chances of getting a patient",
              textAlign: TextAlign.center,
              style: TextStyle(color: PlunesColors.WHITECOLOR, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  bool _hasMediaData() {
    bool hasMediaData = false;
    if (_realInsight.userReport != null &&
        _realInsight.userReport.videoUrl != null &&
        _realInsight.userReport.videoUrl.isNotEmpty) {
      hasMediaData = true;
    } else if (_realInsight.userReport != null &&
        _realInsight.userReport.imageUrl != null &&
        _realInsight.userReport.imageUrl.isNotEmpty) {
      hasMediaData = true;
    } else if (_realInsight.userReport != null &&
        _realInsight.userReport.reportUrl != null &&
        _realInsight.userReport.reportUrl.isNotEmpty) {
      hasMediaData = true;
    }
    return hasMediaData;
  }

  bool _hasTextData() {
    bool hasTextData = false;
    if (_realInsight.userReport != null &&
        _realInsight.userReport.additionalDetails != null &&
        _realInsight.userReport.additionalDetails.trim().isNotEmpty) {
      hasTextData = true;
    } else if (_realInsight.userReport != null &&
        _realInsight.userReport.description != null &&
        _realInsight.userReport.description.trim().isNotEmpty) {
      hasTextData = true;
    }
    return hasTextData;
  }

  Widget _getBodyPartsSessionWidget() {
    if (1 != 1) {
      return Container();
    }
    return Container(
      height: AppConfig.verticalBlockSize * 8,
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2,
          top: AppConfig.verticalBlockSize * 2),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Text("Body Part",
                          style: TextStyle(
                              fontSize: 15, color: PlunesColors.BLACKCOLOR)),
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        child: Text(
                          "Beard",
                          style: TextStyle(
                              fontSize: 18, color: PlunesColors.BLACKCOLOR),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    Text("Session",
                        style: TextStyle(
                            fontSize: 15, color: PlunesColors.BLACKCOLOR)),
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Text(
                        "* 3",
                        style: TextStyle(
                            fontSize: 18, color: PlunesColors.BLACKCOLOR),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 5,
      ),
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
