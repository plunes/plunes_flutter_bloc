import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:video_player/video_player.dart';

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
  _onDonePress() {
    Navigator.pushNamed(context, EnterPhoneScreen.tag);
  }

  PageController _pageController;
  StreamController _pageStream;
  VideoPlayerController _controller;
  bool _isProcessing;

  _setState() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _pageStream = StreamController.broadcast();
    _pageController = PageController(initialPage: 0);
    _isProcessing = true;
    _controller = VideoPlayerController.asset(PlunesImages.firstTutorialVideo)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _isProcessing = false;
        _controller.play();
        _setState();
      });
    _controller?.setLooping(false);
    super.initState();
  }

  @override
  void dispose() {
    _pageStream?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    return _getBody();
    return Container(
        alignment: Alignment.center,
        child: WillPopScope(
          onWillPop: () async => false,
          child: new IntroSlider(
              slides: CommonMethods.addSlideImages(),
              colorDoneBtn: Color(hexColorCode.defaultGreen),
              colorActiveDot: Color(hexColorCode.defaultGreen),
              colorDot: Color(hexColorCode.white1),
              onDonePress: this._onDonePress),
        ));
  }

  Widget _getBody() {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          body: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Stack(
              children: [
                _getPageWidget(),
                Positioned(
                  bottom: AppConfig.verticalBlockSize * 3,
                  left: 0,
                  right: 0,
                  child: _getButtons(),
                )
              ],
            ),
          ),
        ));
  }

  Widget _getButtons() {
    return Container(
      child: StreamBuilder<Object>(
          stream: _pageStream.stream,
          builder: (context, snapshot) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin:
                      EdgeInsets.only(right: AppConfig.horizontalBlockSize * 8),
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () async {
                      if ((_pageController == null ||
                          _pageController.page == null ||
                          _pageController.page.toInt() == 0)) {
                        return;
                      }
                      _isProcessing = true;
                      await _pauseVideo();
                      _setState();
                      _pageController
                          .previousPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut)
                          .then((value) {
                        _initVideo();
                        _pageStream.add(null);
                      });
                    },
                    onDoubleTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1,
                              color: Color(CommonMethods.getColorHexFromStr(
                                  "#48B957")))),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_left,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#48B957")),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 8),
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () async {
                      if (_pageController.page.toInt() == 3) {
                        _onDonePress();
                      } else {
                        _isProcessing = true;
                        await _pauseVideo();
                        _setState();
                        _pageController
                            .nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut)
                            .then((value) {
                          _initVideo();
                          _pageStream.add(null);
                        });
                      }
                    },
                    onDoubleTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1,
                              color: Color(CommonMethods.getColorHexFromStr(
                                  "#48B957")))),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Center(
                            child: Icon(
                          Icons.keyboard_arrow_right,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#48B957")),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget _getPageWidget() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 3),
      child: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          _getFirstPage(),
          _getSecondPage(),
          _getThirdPage(),
          _getForthPage()
        ],
      ),
    );
  }

  Widget _getFirstPage() {
    return SingleChildScrollView(
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 3.5,
              vertical: AppConfig.verticalBlockSize * 2.2),
          child: Column(
            children: [
              _getVideoPlayer(),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Welcome to ",
                      children: [
                        TextSpan(
                            text: "Plunes",
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#48B957")),
                                fontSize: 26))
                      ],
                      style: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#111111")),
                          fontSize: 26))),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
                child: Text("India’s Largest Network Of Hospitals",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Color(CommonMethods.getColorHexFromStr("#111111")),
                        fontSize: 20)),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
                child: Text(
                    "Our AI helps you discover world class hospitals having PAN India presence with instant solutions to all your health care problems.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Color(CommonMethods.getColorHexFromStr("#565656")),
                        fontSize: 18)),
              ),
              _getDotIndicator()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSecondPage() {
    return SingleChildScrollView(
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 3.5,
              vertical: AppConfig.verticalBlockSize * 2.2),
          child: Column(
            children: [
              _getVideoPlayer(),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Top- Rated Doctors",
                      style: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#111111")),
                          fontSize: 26))),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
                child: Text(
                    "Find Best Doctors near you for your treatment and have a hassle free walk in and walk out experience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Color(CommonMethods.getColorHexFromStr("#565656")),
                        fontSize: 18)),
              ),
              _getDotIndicator()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getThirdPage() {
    return SingleChildScrollView(
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 3.5,
              vertical: AppConfig.verticalBlockSize * 2.2),
          child: Column(
            children: [
              _getVideoPlayer(),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Compare prices",
                      style: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#111111")),
                          fontSize: 26))),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
                child: Text(
                    "Compare prices from the medical facilities in just one click and book your treatment from NABH/ NABL accredited hospitals & Labs.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Color(CommonMethods.getColorHexFromStr("#565656")),
                        fontSize: 18)),
              ),
              _getDotIndicator()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getForthPage() {
    return SingleChildScrollView(
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 3.5,
              vertical: AppConfig.verticalBlockSize * 2.2),
          child: Column(
            children: [
              _getVideoPlayer(),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Cost Efficient Treatments",
                      style: TextStyle(
                          color: Color(
                              CommonMethods.getColorHexFromStr("#111111")),
                          fontSize: 26))),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.2),
                child: Text(
                    "Get exclusive discounts up to 50% off on all the medical procedures and diagnostic tests. Avail Medical loans at 0 cost EMI and claim insurance online.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Color(CommonMethods.getColorHexFromStr("#565656")),
                        fontSize: 18)),
              ),
              _getDotIndicator()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getVideoPlayer() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Center(
        child: (!(_isProcessing) && _controller.value.initialized)
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CustomWidgets().getProgressIndicator(),
      ),
    );
  }

  Widget _getDotIndicator() {
    return StreamBuilder<Object>(
        stream: _pageStream?.stream,
        builder: (context, snapshot) {
          return Container(
            margin: EdgeInsets.only(top: 40),
            child: DotsIndicator(
              decorator: DotsDecorator(
                  size: const Size(19.0, 6.0),
                  activeSize: const Size(19.0, 6.0),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)),
                  color: Color(CommonMethods.getColorHexFromStr("#BDBDBD")),
                  activeColor:
                      Color(CommonMethods.getColorHexFromStr("#47BB5B")),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0))),
              dotsCount: 4,
              position: _pageController?.page ?? 0.0,
            ),
          );
        });
  }

  void _initVideo() {
    if (mounted) {
      if (_controller != null) {
        _controller = null;
        String videoName =
            _pageController == null || _pageController.page == null
                ? PlunesImages.firstTutorialVideo
                : (_pageController.page.toInt() == 0)
                    ? PlunesImages.firstTutorialVideo
                    : (_pageController.page.toInt() == 1)
                        ? PlunesImages.secondTutorialVideo
                        : (_pageController.page.toInt() == 2)
                            ? PlunesImages.thirdTutorialVideo
                            : PlunesImages.forthTutorialVideo;
        _controller = VideoPlayerController.asset(videoName)
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            _isProcessing = false;
            _controller.play();
            _setState();
          });
        _controller?.setLooping(false);
      }
    }
  }

  Future<void> _pauseVideo() async {
    return await _controller?.pause();
  }
}
