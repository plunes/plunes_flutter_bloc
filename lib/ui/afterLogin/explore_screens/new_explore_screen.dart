import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/youtube_player.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/blocs/explore_bloc/explore_main_bloc.dart';
import 'package:plunes/blocs/new_solution_blocs/sol_home_screen_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/explore/explore_main_model.dart';
import 'package:plunes/models/new_solution_model/media_content_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_main_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class NewExploreScreen extends BaseActivity {
  final Function func;

  NewExploreScreen(this.func);

  @override
  _NewExploreScreenState createState() => _NewExploreScreenState();
}

class _NewExploreScreenState extends BaseState<NewExploreScreen> {
  String kDefaultImageUrl =
      'https://goqii.com/blog/wp-content/uploads/Doctor-Consultation.jpg';
  ExploreMainBloc _exploreMainBloc;
  ExploreOuterModel _exploreModel;
  String _failedMessageForExploreData;
  StreamController _streamController;
  double _currentDotPosition = 0.0;
  final CarouselController _controller = CarouselController();
  String _mediaFailedMessage;
  HomeScreenMainBloc _homeScreenMainBloc;
  MediaContentPlunes _mediaContentPlunes;
  List<MediaData> _doctorVideos, _customerVideos;
  CartMainBloc _cartBloc;

  @override
  void initState() {
    FirebaseNotification.setScreenName(FirebaseNotification.exploreScreen);
    _cartBloc = CartMainBloc();
    _exploreMainBloc = ExploreMainBloc();
    _homeScreenMainBloc = HomeScreenMainBloc();
    _streamController = StreamController.broadcast();
    _currentDotPosition = 0.0;
    _getData();
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == FirebaseNotification.exploreScreen &&
          mounted) {
        _getData();
      }
    });
    super.initState();
  }

  void _getCartCount() {
    _cartBloc.getCartCount();
  }

  _getData() {
    _getExploreData();
    _getVideos();
  }

  _getVideos() {
    _homeScreenMainBloc.getMediaContent();
  }

  @override
  void dispose() {
    FirebaseNotification.setScreenName(null);
    _getCartCount();
    _exploreMainBloc?.dispose();
    _streamController?.close();
    _cartBloc?.dispose();
    super.dispose();
  }

  void _getExploreData() {
    _failedMessageForExploreData = null;
    _exploreMainBloc.getExploreData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            key: scaffoldKey,
            body: Column(
              children: [
                Container(
                  child: HomePageAppBar(
                    widget.func,
                    () {},
                    () {},
                    one: null,
                    two: null,
                  ),
                  margin: EdgeInsets.only(
                      top: AppConfig.getMediaQuery().padding.top),
                ),
                Expanded(child: _getBody()),
              ],
            ),
          ),
        ));
  }

  Widget _getBody() {
    return Container(
      child: Column(
        children: [
          _getAppAndSearchBarWidget(),
          Expanded(
              child: Container(
            child: _getScrollableBody(),
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
          )),
        ],
      ),
    );
  }

  Widget _getAppAndSearchBarWidget() {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 2.5,
            right: AppConfig.horizontalBlockSize * 2.5,
            top: AppConfig.verticalBlockSize * 0.6,
            bottom: AppConfig.horizontalBlockSize * 1.8),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(19, 184, 126, 0.19),
            Color.fromRGBO(255, 255, 255, 0),
          ],
        )),
        child: Column(
          children: [
            ListTile(
              title: Text(
                PlunesStrings.knowYourProcedure,
                textAlign: TextAlign.center,
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
              ),
            ),
            // Container(
            //   margin: EdgeInsets.only(
            //       top: AppConfig.verticalBlockSize * 0.8,
            //       bottom: AppConfig.verticalBlockSize * 2.8),
            //   child: Card(
            //     elevation: 2.0,
            //     color: Colors.white,
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.all(Radius.circular(24))),
            //     margin: EdgeInsets.symmetric(
            //         horizontal: AppConfig.horizontalBlockSize * 8),
            //     child: InkWell(
            //       splashColor: Colors.transparent,
            //       highlightColor: Colors.transparent,
            //       onTap: () {
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) => SolutionBiddingScreen()));
            //       },
            //       onDoubleTap: () {},
            //       child: Container(
            //         width: double.infinity,
            //         padding: EdgeInsets.symmetric(
            //             horizontal: AppConfig.horizontalBlockSize * 6,
            //             vertical: AppConfig.verticalBlockSize * 1.6),
            //         child: Text(
            //           "Search Service",
            //           textAlign: TextAlign.left,
            //           style: TextStyle(
            //               color: PlunesColors.BLACKCOLOR, fontSize: 18),
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget _getScrollableBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _getSectionTwoWidget(),
          _getVideosSection()
          // _getReviewSection()
        ],
      ),
    );
  }

  Widget _getSectionTwoWidget() {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              _exploreModel?.data?.first?.section2?.heading ?? "Offers",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          _getOfferMainWidget()
        ],
      ),
    );
  }

  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

  Widget _getDoctorVideoSection(videos) {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "See What Doctors saying about us",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          Container(
            child: _getVideoWidget(videos),
            height: AppConfig.verticalBlockSize * 38,
          ),
        ],
      ),
    );
  }

  Widget _getCustomerVideos(List<MediaData> videos) {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Happy customers",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          Container(
            child: _getVideoWidget(videos),
            height: AppConfig.verticalBlockSize * 38,
          ),
        ],
      ),
    );
  }

  Widget _getReviewSection() {
    return Container(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "People availing Discount",
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          Card(
              elevation: 2.0,
              margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                height: AppConfig.verticalBlockSize * 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        flex: 3,
                        child: Column(
                          children: [
                            Flexible(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: AppConfig.verticalBlockSize * 0.2,
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 0.8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12)),
                                  child: CustomWidgets()
                                      .getImageFromUrl(kDefaultImageUrl),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: AppConfig.verticalBlockSize * 2,
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 3),
                              child: CustomWidgets().getRoundedButton(
                                  PlunesStrings.book,
                                  AppConfig.horizontalBlockSize * 8,
                                  PlunesColors.GREENCOLOR,
                                  AppConfig.horizontalBlockSize * 5,
                                  AppConfig.verticalBlockSize * 1,
                                  PlunesColors.WHITECOLOR,
                                  borderColor: PlunesColors.SPARKLINGGREEN,
                                  hasBorder: false),
                            )
                          ],
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 0.2),
                            child: Text(
                              CommonMethods.getStringInCamelCase(
                                  "Rahul Shukla"),
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                color: Color(0xff4E4E4E),
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "PRP",
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(
                                color: Color(0xff4E4E4E),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Flexible(
                            child: Container(
                              child: Text(
                                "dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda",
                                softWrap: true,
                                maxLines: 4,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xff4E4E4E),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _getVideoWidget(List<MediaData> videos) {
    return ListView.builder(
        itemCount: videos?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            width: AppConfig.horizontalBlockSize * 88,
            margin: EdgeInsets.only(right: 3, bottom: 3),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: InkWell(
                onTap: () {
                  String mediaUrl = videos[index]?.mediaUrl;
                  if (mediaUrl == null || mediaUrl.trim().isEmpty) {
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => YoutubePlayerProvider(
                                mediaUrl,
                                title: videos[index]?.service ?? "Video",
                              )));
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          child: ClipRRect(
                            child: CustomWidgets().getImageFromUrl(
                                "https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(videos[index].mediaUrl ?? "")}/0.jpg",
                                boxFit: BoxFit.fill),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10)),
                          ),
                          height: AppConfig.verticalBlockSize * 26,
                          width: double.infinity,
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Image.asset(
                              PlunesImages.pauseVideoIcon,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: AppConfig.horizontalBlockSize * 2,
                          right: AppConfig.horizontalBlockSize * 2,
                          top: AppConfig.verticalBlockSize * 0.3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              videos[index]?.service ??
                                  videos[index]?.name ??
                                  "Video",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: AppConfig.mediumFont,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 2,
                            right: AppConfig.horizontalBlockSize * 2,
                            top: AppConfig.verticalBlockSize * 0.3),
                        child: Text(
                          videos[index]?.testimonial ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppConfig.verySmallFont,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _getOfferMainWidget() {
    return Container(
      child: StreamBuilder<RequestState>(
          stream: _exploreMainBloc.baseStream,
          initialData: (_exploreModel == null || _exploreModel.data == null)
              ? RequestInProgress()
              : null,
          builder: (context, snapshot) {
            if (snapshot.data is RequestSuccess) {
              RequestSuccess successObject = snapshot.data;
              _exploreModel = successObject.response;
            } else if (snapshot.data is RequestFailed) {
              RequestFailed _failedObj = snapshot.data;
              _failedMessageForExploreData = _failedObj?.failureCause;
            } else if (snapshot.data is RequestInProgress) {
              return Container(
                child: CustomWidgets().getProgressIndicator(),
                height: AppConfig.verticalBlockSize * 35,
              );
            }
            return (_exploreModel == null ||
                    _exploreModel.data == null ||
                    _exploreModel.data.isEmpty ||
                    _exploreModel.data.first == null ||
                    _exploreModel.data.first.section2 == null ||
                    _exploreModel.data.first.section2.elements == null ||
                    _exploreModel.data.first.section2.elements.isEmpty)
                ? Container(
                    child: CustomWidgets().errorWidget(
                        _failedMessageForExploreData,
                        onTap: () => _getExploreData(),
                        isSizeLess: true),
                    height: AppConfig.verticalBlockSize * 35,
                  )
                : Column(
                    children: [
                      CarouselSlider.builder(
                        carouselController: _controller,
                        itemCount: (_exploreModel
                                    .data.first.section2.elements.length >
                                8)
                            ? 8
                            : _exploreModel.data.first.section2.elements.length,
                        options: CarouselOptions(
                            height: AppConfig.verticalBlockSize * 28,
                            aspectRatio: 16 / 9,
                            initialPage: 0,
                            enableInfiniteScroll: false,
                            pageSnapping: true,
                            autoPlay: true,
                            reverse: false,
                            enlargeCenterPage: true,
                            viewportFraction: 1.0,
                            onPageChanged: (index, _) {
                              if (_currentDotPosition.toInt() != index) {
                                _currentDotPosition = index.toDouble();
                                _streamController?.add(null);
                              }
                            },
                            scrollDirection: Axis.horizontal),
                        itemBuilder: (BuildContext context, int itemIndex) =>
                            Container(
                          width: double.infinity,
                          child: InkWell(
                            onTap: () {
                              if (_exploreModel.data.first.section2
                                          .elements[itemIndex].serviceName !=
                                      null &&
                                  _exploreModel.data.first.section2
                                      .elements[itemIndex].serviceName
                                      .trim()
                                      .isNotEmpty) {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SolutionBiddingScreen(
                                                    searchQuery: _exploreModel
                                                        .data
                                                        .first
                                                        .section2
                                                        .elements[itemIndex]
                                                        .serviceName)))
                                    .then((value) {
                                  // _getCartCount();
                                });
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomWidgets().getImageFromUrl(
                                    _exploreModel.data.first.section2
                                            .elements[itemIndex].imgUrl ??
                                        "",
                                    boxFit: BoxFit.fill),
                              ),
                            ),
                          ),
                        ),
                      ),
                      StreamBuilder<Object>(
                          stream: _streamController.stream,
                          builder: (context, snapshot) {
                            return Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 0.5),
                              child: DotsIndicator(
                                dotsCount: (_exploreModel.data.first.section2
                                            .elements.length >
                                        8)
                                    ? 8
                                    : _exploreModel
                                        .data.first.section2.elements.length,
                                position: _currentDotPosition,
                                axis: Axis.horizontal,
                                decorator: _decorator,
                                onTap: (pos) {
                                  _controller.animateToPage(pos.toInt(),
                                      curve: Curves.easeInOut,
                                      duration: Duration(milliseconds: 300));
                                  _currentDotPosition = pos;
                                  _streamController?.add(null);
                                  return;
                                },
                              ),
                            );
                          })
                    ],
                  );
          }),
    );
  }

  Widget _getVideosSection() {
    return StreamBuilder<RequestState>(
        stream: _homeScreenMainBloc.mediaStream,
        initialData: _mediaContentPlunes == null ? RequestInProgress() : null,
        builder: (context, snapshot) {
          if (snapshot.data is RequestSuccess) {
            RequestSuccess successObject = snapshot.data;
            _mediaContentPlunes = successObject.response;
            _filterVideos();
            _homeScreenMainBloc?.addIntoMediaStream(null);
          } else if (snapshot.data is RequestFailed) {
            RequestFailed _failedObj = snapshot.data;
            _mediaFailedMessage = _failedObj?.failureCause;
            _homeScreenMainBloc?.addIntoMediaStream(null);
          } else if (snapshot.data is RequestInProgress) {
            return Container(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Videos",
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    margin: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 2,
                        horizontal: AppConfig.horizontalBlockSize * 2),
                  ),
                  CustomWidgets().getProgressIndicator(),
                ],
              ),
              height: AppConfig.verticalBlockSize * 28,
            );
          }
          return (_mediaContentPlunes == null ||
                  _mediaContentPlunes.data == null ||
                  _mediaContentPlunes.data.isEmpty)
              ? Container()
              : Container(
                  child: Column(
                    children: [
                      (_doctorVideos == null || _doctorVideos.isEmpty)
                          ? Container()
                          : _getDoctorVideoSection(_doctorVideos),
                      (_customerVideos == null || _customerVideos.isEmpty)
                          ? Container()
                          : _getCustomerVideos(_customerVideos),
                    ],
                  ),
                );
        });
  }

  void _filterVideos() {
    _doctorVideos = [];
    _customerVideos = [];
    if (_mediaContentPlunes != null &&
        _mediaContentPlunes.data != null &&
        _mediaContentPlunes.data.isNotEmpty) {
      _mediaContentPlunes.data.forEach((element) {
        if (element.mediaType != null && element.mediaType.trim().isNotEmpty) {
          if (element.mediaType.toLowerCase() ==
              Constants.USER_TESTIMONIAL.toString().toLowerCase()) {
            _customerVideos.add(element);
          } else if (element.mediaType.toLowerCase() ==
              Constants.PROFESSIONAL_TESTIMONIAL.toString().toLowerCase()) {
            _doctorVideos.add(element);
          }
        }
      });
    }
  }
}
