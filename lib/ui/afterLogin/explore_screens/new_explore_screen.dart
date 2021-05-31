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
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/explore/explore_main_model.dart';
import 'package:plunes/models/new_solution_model/media_content_model.dart';
import 'package:plunes/models/new_solution_model/top_facility_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';
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
  String _failedMessageTopFacility, _specialityApiFailureCause;
  bool _hasCalledTopFacilityApi;
  TopFacilityModel _topFacilityModel;
  String _userTypeFilter;
  String _locationFilter = _nearMeKey;
  String _selectedSpeciality;
  static final String _nearMeKey = "Near me";
  static final String _allKey = "All";
  String _selectedSpecialityName;
  String _userTypeFilterName;
  String _locationFilterName;
  List<SpecialityModel> _specialityItems = [];

  List<SpecialityModel> _facilityTypeList = [
    SpecialityModel(speciality: "Hospital", id: Constants.hospital.toString()),
    SpecialityModel(speciality: "Doctor", id: Constants.doctor.toString()),
    SpecialityModel(
        speciality: "Lab", id: Constants.labDiagnosticCenter.toString()),
    SpecialityModel(speciality: "All", id: _allKey),
  ];

  List<SpecialityModel> _selectedLocationList = [
    SpecialityModel(speciality: "Near me", id: _nearMeKey),
    SpecialityModel(speciality: "All", id: _allKey)
  ];

  @override
  void initState() {
    FirebaseNotification.setScreenName(FirebaseNotification.exploreScreen);
    _cartBloc = CartMainBloc();
    _exploreMainBloc = ExploreMainBloc();
    _homeScreenMainBloc = HomeScreenMainBloc();
    _streamController = StreamController.broadcast();
    _currentDotPosition = 0.0;
    _getData();
    _getSpecialities();
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == FirebaseNotification.exploreScreen &&
          mounted) {
        _getData();
      }
    });
    super.initState();
  }

  void _getSpecialities() {
    _homeScreenMainBloc.getCommonSpecialities();
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
        color: CommonMethods.getColorForSpecifiedCode("#F7F8FA"),
        padding: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 2.5,
            right: AppConfig.horizontalBlockSize * 2.5,
            top: AppConfig.verticalBlockSize * 0.6,
            bottom: AppConfig.horizontalBlockSize * 1.8),
        child: Column(
          children: [
            ListTile(
              title: Text(
                PlunesStrings.knowYourProcedure,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 23,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 0.8,
                  bottom: AppConfig.verticalBlockSize * 2.8),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2.0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 3),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SolutionBiddingScreen()));
                        },
                        onDoubleTap: () {},
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: AppConfig.horizontalBlockSize * 4,
                              vertical: AppConfig.verticalBlockSize * 1.6),
                          child: Row(
                            children: [
                              Image.asset(
                                PlunesImages.searchIcon,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#B1B1B1")),
                                width: AppConfig.verticalBlockSize * 2.0,
                                height: AppConfig.verticalBlockSize * 2.0,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                child: Text(
                                  "Search Disease ,Test or Medical Procedure",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(
                                          CommonMethods.getColorHexFromStr(
                                              "#B1B1B1")),
                                      fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: CommonMethods.getColorForSpecifiedCode("#FFFFFF"),
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () {
                        _getModelBottomSheetForFacilityType(context);
                      },
                      onDoubleTap: () {},
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 2.5,
                            vertical: AppConfig.verticalBlockSize * 1.8),
                        child: Column(
                          children: [
                            Container(
                              height: 1,
                              width: 20,
                              color: CommonMethods.getColorForSpecifiedCode(
                                  "#107C6F"),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 3, bottom: 3),
                              height: 1,
                              width: 14,
                              color: CommonMethods.getColorForSpecifiedCode(
                                  "#107C6F"),
                            ),
                            Container(
                              height: 1,
                              width: 8,
                              color: CommonMethods.getColorForSpecifiedCode(
                                  "#107C6F"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<RequestState> _getSpecialityList() async {
    if (CommonMethods.catalogueLists == null ||
        CommonMethods.catalogueLists.isEmpty) {
      var result = await UserManager().getSpecialities();
      return result;
    } else {
      return RequestSuccess();
    }
  }

  Widget _getTopFacilitiesWidget() {
    return Container(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 1.4,
          left: AppConfig.horizontalBlockSize * 2.8,
          right: AppConfig.horizontalBlockSize * 2.8),
      child: Column(
        children: [
          StatefulBuilder(builder: (context, newState) {
            return FutureBuilder<RequestState>(
                future: _getSpecialityList(),
                builder: (context, snapShot) {
                  if (snapShot.data is RequestInProgress) {
                    return Container(
                      child: CustomWidgets().getProgressIndicator(),
                      height: AppConfig.verticalBlockSize * 25,
                    );
                  } else if (snapShot.data is RequestFailed) {
                    RequestFailed _failedObj = snapShot.data;
                    _specialityApiFailureCause = _failedObj?.response;
                  } else if (snapShot.data is RequestSuccess) {
                    if (_hasCalledTopFacilityApi == null)
                      _getTopFacilities(isInitialRequest: true);
                    _hasCalledTopFacilityApi = true;
                  }
                  return CommonMethods.catalogueLists == null ||
                          CommonMethods.catalogueLists.isEmpty
                      ? Container(
                          height: AppConfig.verticalBlockSize * 38,
                          child: CustomWidgets().errorWidget(
                              _specialityApiFailureCause ??
                                  "Unable to load data", onTap: () {
                            newState(() {});
                          }, isSizeLess: true),
                        )
                      : _getTopFacilityStreamBuilderWidget();
                },
                initialData: (CommonMethods.catalogueLists == null ||
                        CommonMethods.catalogueLists.isEmpty)
                    ? RequestInProgress()
                    : null);
          }),
        ],
      ),
    );
  }

  Widget _getScrollableBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _getSectionTwoWidget(),
          _getTopFacilitiesWidget()
          // _getVideosSection()
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
              _exploreModel?.data?.first?.section2?.heading ??
                  " Get Exclusive Offers Now!",
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
              _mediaContentPlunes?.exploreDocTitle ??
                  "Watch Doctors Talk About Us",
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
              _mediaContentPlunes?.exploreCustomerTitle ??
                  "Watch our Happy Customers",
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

  void _getTopFacilities({bool isInitialRequest = false}) {
    _homeScreenMainBloc.getTopFacilities(
        specialityId: _selectedSpeciality,
        shouldSortByNearest: (_locationFilter == _allKey) ? false : true,
        facilityType: _userTypeFilter,
        isInitialRequest: isInitialRequest);
  }

  Widget _getTopFacilityStreamBuilderWidget() {
    return StreamBuilder<RequestState>(
        stream: _homeScreenMainBloc.topFacilityStream,
        initialData: (_topFacilityModel == null) ? RequestInProgress() : null,
        builder: (context, snapshot) {
          if (snapshot.data is RequestSuccess) {
            RequestSuccess successObject = snapshot.data;
            _topFacilityModel = successObject.response;
            _homeScreenMainBloc?.addIntoTopFacilityStream(null);
          } else if (snapshot.data is RequestFailed) {
            RequestFailed _failedObj = snapshot.data;
            _failedMessageTopFacility = _failedObj?.failureCause;
            _homeScreenMainBloc?.addIntoTopFacilityStream(null);
          } else if (snapshot.data is RequestInProgress) {
            return Container(
              child: CustomWidgets().getProgressIndicator(),
              height: AppConfig.verticalBlockSize * 25,
            );
          }
          return (_topFacilityModel == null ||
                  (_topFacilityModel.success != null &&
                      !_topFacilityModel.success) ||
                  _topFacilityModel.data == null ||
                  _topFacilityModel.data.isEmpty)
              ? Container(
                  height: AppConfig.verticalBlockSize * 38,
                  child: CustomWidgets().errorWidget(_failedMessageTopFacility,
                      onTap: () {
                    _selectedSpeciality = null;
                    _userTypeFilter = null;
                    _locationFilter = _nearMeKey;
                    _getTopFacilities(isInitialRequest: true);
                  }, isSizeLess: true))
              : Container(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (_topFacilityModel.data[index] != null &&
                              _topFacilityModel.data[index].userType != null &&
                              _topFacilityModel.data[index].professionalId !=
                                  null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DoctorInfo(
                                        _topFacilityModel
                                            .data[index].professionalId,
                                        isDoc: (_topFacilityModel
                                                .data[index].userType
                                                .toLowerCase() ==
                                            Constants.doctor
                                                .toString()
                                                .toLowerCase()))));
                          }
                        },
                        onDoubleTap: () {},
                        child: CommonWidgets().getHospitalCard(
                            _topFacilityModel.data[index]?.imageUrl ?? '',
                            CommonMethods.getStringInCamelCase(
                                _topFacilityModel.data[index].name),
                            _topFacilityModel.data[index].biography ?? '',
                            _topFacilityModel.data[index]?.rating,
                            _topFacilityModel.data[index]),
                      );
                    },
                    itemCount: _topFacilityModel.data.length,
                  ),
                );
        });
  }

  _getModelBottomSheetForFacilityType(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17), topRight: Radius.circular(17))),
        builder: (anotherContext) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17)),
                border: Border.all(
                    color: Color(CommonMethods.getColorHexFromStr("#26AF78")),
                    width: 1)),
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              bottom: AppConfig.verticalBlockSize * 3,
                              top: AppConfig.verticalBlockSize * 1.5),
                          height: 3,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#707070")),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Text(
                      "Search For",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 1.5),
                  ),
                  Container(
                    height: 45,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // _userTypeFilter = _facilityTypeList[index].id;
                            // _userTypeFilterName =
                            //     _facilityTypeList[index].speciality;
                            // _doFilterAndGetFacilities();
                            // Navigator.maybePop(context);
                          },
                          onDoubleTap: () {},
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.7),
                                borderRadius: BorderRadius.circular(4),
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#FAFBFD"))),
                            padding: EdgeInsets.symmetric(
                                horizontal: AppConfig.horizontalBlockSize * 4),
                            child: Text(
                              _facilityTypeList[index].speciality ?? "NA",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                        );
                      },
                      itemCount: _facilityTypeList.length,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Find",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 1.5,
                            top: AppConfig.verticalBlockSize * 3.5),
                      ),
                      Container(
                        height: 45,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                // _userTypeFilter = _facilityTypeList[index].id;
                                // _userTypeFilterName =
                                //     _facilityTypeList[index].speciality;
                                // _doFilterAndGetFacilities();
                                // Navigator.maybePop(context);
                              },
                              onDoubleTap: () {},
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#FAFBFD"))),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        AppConfig.horizontalBlockSize * 4),
                                child: Text(
                                  _selectedLocationList[index].speciality ??
                                      "NA",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            );
                          },
                          itemCount: _selectedLocationList.length,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Service",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 1.5,
                            top: AppConfig.verticalBlockSize * 3.5),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0.1,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 3.7),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              _selectedSpeciality =
                                  _getSpecialityItems()[index].id;
                              _selectedSpecialityName =
                                  _getSpecialityItems()[index].speciality;
                              _doFilterAndGetFacilities();
                              Navigator.maybePop(context);
                            },
                            onDoubleTap: () {},
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    (_selectedSpeciality != null &&
                                            _selectedSpeciality ==
                                                _getSpecialityItems()[index]
                                                    .speciality)
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off,
                                    color: (_selectedSpeciality != null &&
                                            _selectedSpeciality ==
                                                _getSpecialityItems()[index]
                                                    .speciality)
                                        ? PlunesColors.GREENCOLOR
                                        : null,
                                  ),
                                  Flexible(
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(left: 2, right: 3),
                                      child: Text(
                                        _getSpecialityItems()[index]
                                                .speciality ??
                                            "NA",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: _getSpecialityItems().length,
                      )
                    ],
                  )
                ],
              ),
            ),
            constraints: BoxConstraints(
                minWidth: 10,
                maxWidth: double.infinity,
                minHeight: AppConfig.verticalBlockSize * 2,
                maxHeight: AppConfig.verticalBlockSize * 50),
          );
        });
  }

  List<SpecialityModel> _getSpecialityItems() {
    if (_specialityItems != null && _specialityItems.isNotEmpty) {
      return _specialityItems;
    }
    _specialityItems = [];
    CommonMethods.catalogueLists.forEach((element) {
      if (element.speciality != null &&
          element.speciality.trim().isNotEmpty &&
          element.id != null &&
          element.id.trim().isNotEmpty) {
        _specialityItems.add(element);
      }
    });
    return _specialityItems;
  }

  void _doFilterAndGetFacilities() {
    _getTopFacilities();
  }
}
