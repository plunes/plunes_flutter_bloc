import 'dart:async';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/Utils/youtube_player.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/doc_hos_models/common_models/media_content_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:readmore/readmore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class DoctorInfo extends BaseActivity {
  final String userID;

  bool isDoc;

  DoctorInfo(this.userID, {this.isDoc});

  @override
  _DoctorInfoState createState() => _DoctorInfoState();
}

class _DoctorInfoState extends BaseState<DoctorInfo>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  double _currentDotPosition = 0.0;
  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));
  UserBloc _userBloc;
  LoginPost _profileResponse;
  String _failureCause, _failureCauseForMediaContent, _failureForReview;
  final CarouselController _controller = CarouselController();
  StreamController _streamController;
  MediaContentModel _mediaContent;
  List<RateAndReview> _rateAndReviewList = [];
  bool _reviewApiHitOnce = false, _mediaContentApiHitOnce = false, _isDoc;

  List<Widget> _tabsForDoc = [
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          child: Text(
        'Photos/Videos',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          child: Text(
        'Review',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          child: Text(
        'Achievements',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
  ];

  List<Widget> _tabsForHospital = [
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          child: Text(
        'Photos/Videos',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          child: Text(
        'Review',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          child: Text(
        'Achievements',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          child: Text(
        'Team of Experts',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      )),
    ),
  ];

  @override
  void initState() {
    _isDoc = widget.isDoc ?? false;
    _rateAndReviewList = [];
    _streamController = StreamController.broadcast();
    _userBloc = UserBloc();
    _getUserDetails();
    super.initState();
  }

  void _getReviews() {
    _userBloc.getRateAndReviews(widget.userID);
  }

  @override
  void dispose() {
    _streamController?.close();
    _userBloc?.dispose();
    super.dispose();
  }

  void _getUserDetails() {
    _userBloc.getUserProfile(widget.userID);
  }

  void _getDirections() {
    (_profileResponse.user?.latitude == null ||
            _profileResponse.user.latitude.isEmpty ||
            _profileResponse.user.latitude == null ||
            _profileResponse.user.latitude.isEmpty)
        ? widget.showInSnackBar(PlunesStrings.locationNotAvailable,
            PlunesColors.BLACKCOLOR, scaffoldKey)
        : LauncherUtil.openMap(double.tryParse(_profileResponse.user.latitude),
            double.tryParse(_profileResponse.user.longitude));
  }

  Widget _getBodyWidget() {
    return StreamBuilder<RequestState>(
      stream: _userBloc.baseStream,
      builder: (context, snapshot) {
        if (snapshot.data is RequestInProgress) {
          return CustomWidgets().getProgressIndicator();
        } else if (snapshot.data is RequestSuccess) {
          RequestSuccess requestSuccess = snapshot.data;
          if (requestSuccess != null && requestSuccess.response != null) {
            _profileResponse = requestSuccess.response;
            // if (_profileResponse.user != null) {
            //   Future.delayed(Duration(milliseconds: 10))
            //       .then((value) => _getSpecialities());
            // }
          }
          _userBloc.addIntoStream(null);
        } else if (snapshot.data is RequestFailed) {
          RequestFailed requestFailed = snapshot.data;
          _failureCause = requestFailed.failureCause;
          _userBloc.addIntoStream(null);
        }
        return _profileResponse == null
            ? CustomWidgets().errorWidget(
                _failureCause ?? "Unable to get profile",
                onTap: () => _getUserDetails())
            : _getMainBody();
      },
      initialData: _profileResponse == null ? RequestInProgress() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.profile, true),
        body: _getBodyWidget());
  }

  Widget _getMainBody() {
    return SingleChildScrollView(
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (_profileResponse.user.achievements != null &&
                  _profileResponse.user.achievements.isNotEmpty)
              ? Stack(
                  children: [
                    CarouselSlider.builder(
                        itemCount:
                            (_profileResponse.user.achievements.length > 5)
                                ? 5
                                : _profileResponse?.user?.achievements?.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              List<Photo> photos = [];
                              _profileResponse.user.achievements
                                  .forEach((element) {
                                if (_profileResponse.user.achievements[index] ==
                                        null ||
                                    _profileResponse.user.achievements[index]
                                        .imageUrl.isEmpty ||
                                    !(_profileResponse
                                        .user.achievements[index].imageUrl
                                        .contains("http"))) {
                                  photos.add(Photo(
                                      assetName: plunesImages.achievementIcon));
                                } else {
                                  photos
                                      .add(Photo(assetName: element.imageUrl));
                                }
                              });
                              if (photos != null && photos.isNotEmpty) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PageSlider(photos, index)));
                              }
                            },
                            child: CustomWidgets().getImageFromUrl(
                                _profileResponse
                                    .user.achievements[index].imageUrl,
                                boxFit: BoxFit.fill),
                          );
                        },
                        carouselController: _controller,
                        options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 5),
                            height: AppConfig.verticalBlockSize * 35,
                            viewportFraction: 1.0,
                            onPageChanged: (index, _) {
                              if (_currentDotPosition.toInt() != index) {
                                _currentDotPosition = index.toDouble();
                                _streamController?.add(null);
                              }
                            })),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: StreamBuilder<Object>(
                          stream: _streamController.stream,
                          builder: (context, snapshot) {
                            return DotsIndicator(
                              dotsCount:
                                  (_profileResponse.user.achievements.length >
                                          5)
                                      ? 5
                                      : _profileResponse
                                          ?.user?.achievements?.length,
                              position: _currentDotPosition?.toDouble() ?? 0,
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
                            );
                          }),
                    ),
                    Positioned(
                      bottom: 0.0,
                      right: AppConfig.horizontalBlockSize * 5,
                      child: StreamBuilder<Object>(
                          stream: _streamController.stream,
                          builder: (context, snapshot) {
                            return Chip(
                                backgroundColor: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#000000"))
                                    .withOpacity(0.5),
                                label: Container(
                                  child: Center(
                                    child: Text(
                                      "${_currentDotPosition.toInt() + 1}/${(_profileResponse.user.achievements.length > 5) ? 5 : _profileResponse?.user?.achievements?.length}",
                                      style: TextStyle(
                                          color: PlunesColors.WHITECOLOR,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.all(3));
                          }),
                    )
                  ],
                )
              : InkWell(
                  onTap: () {
                    List<Photo> photos = [];
                    if ((_profileResponse.user != null &&
                        _profileResponse.user.imageUrl != null &&
                        _profileResponse.user.imageUrl.isNotEmpty)) {
                      photos.add(
                          Photo(assetName: _profileResponse.user.imageUrl));
                    }
                    if (photos != null && photos.isNotEmpty) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PageSlider(photos, 0)));
                    }
                  },
                  child: Container(
                    color: PlunesColors.LIGHTESTGREYCOLOR.withOpacity(.5),
                    height: AppConfig.verticalBlockSize * 35,
                    width: double.infinity,
                    child: (_profileResponse.user.imageUrl == null ||
                            _profileResponse.user.imageUrl.isEmpty ||
                            !(_profileResponse.user.imageUrl.contains("http")))
                        ? Container(
                            margin: EdgeInsets.all(
                                AppConfig.verticalBlockSize * 7.5),
                            child: Image.asset(
                              PlunesImages.defaultHosBac,
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          )
                        : SizedBox.expand(
                            child: CustomWidgets().getImageFromUrl(
                                _profileResponse.user.imageUrl,
                                boxFit: BoxFit.cover),
                          ),
                  ),
                ),
          Container(
            margin: EdgeInsets.all(13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        CommonMethods.getStringInCamelCase(
                            _profileResponse.user?.name),
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Color(0xffFDCC0D)),
                        Text(
                          _profileResponse.user?.rating?.toStringAsFixed(1) ??
                              '4.5',
                          style: TextStyle(color: Colors.black, fontSize: 25.0),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  _profileResponse.user?.qualification ?? _getEmptyString(),
                  style: TextStyle(color: Color(0xff4F4F4F)),
                ),
                SizedBox(height: 15),
                DottedLine(),
                SizedBox(height: 15),
                Text(
                  plunesStrings.introduction,
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                SizedBox(
                  height: 13,
                ),
                ReadMoreText(
                  _profileResponse.user?.biography ?? _getEmptyString(),
                  colorClickableText: PlunesColors.SPARKLINGGREEN,
                  trimLines: 4,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: '  ...read more',
                  trimExpandedText: '  read less',
                  style: TextStyle(color: PlunesColors.GREYCOLOR, fontSize: 14),
                ),
                SizedBox(
                  height: 22,
                ),
                DottedLine(),
                SizedBox(
                  height: 22,
                ),
                Container(
                  height: 126,
                  child: InkWell(
                    onTap: () => _getDirections(),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            PlunesImages.setLocationMap,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          right: AppConfig.horizontalBlockSize * 3.8,
                          bottom: AppConfig.verticalBlockSize * 0.9,
                          child: Chip(
                              backgroundColor: PlunesColors.WHITECOLOR,
                              padding: EdgeInsets.all(3.0),
                              label: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        height: AppConfig.verticalBlockSize * 3,
                                        width:
                                            AppConfig.horizontalBlockSize * 5,
                                        child: Image.asset(
                                            plunesImages.locationIcon,
                                            color: PlunesColors.BLACKCOLOR)),
                                    Text(
                                      " 2.3 Kms",
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR),
                                    )
                                  ],
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
                DottedLine(),
                SizedBox(
                  height: 22,
                ),
                Text(
                  'Facility have',
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Container(
                            margin: EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                        topLeft: Radius.circular(13),
                                        topRight: Radius.circular(13)),
                                    child: Container(
                                      child: CustomWidgets().getImageFromUrl(
                                        'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'covid safe',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                  topLeft: Radius.circular(13),
                                  topRight: Radius.circular(13))));
                    },
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: TabBar(
                      unselectedLabelColor: Colors.black,
                      isScrollable: true,
                      labelPadding: EdgeInsets.all(12.0),
                      labelColor: Colors.white,
                      controller: TabController(
                        length: _isDoc
                            ? _tabsForDoc.length
                            : _tabsForHospital.length,
                        vsync: this,
                        initialIndex: _selectedIndex,
                      ),
                      indicator: new BubbleTabIndicator(
                        indicatorHeight: 40.0,
                        indicatorColor: Color(0xff01D25A),
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                      ),
                      onTap: (i) {
                        setState(() {
                          _selectedIndex = i;
                        });
                      },
                      tabs: _isDoc ? _tabsForDoc : _tabsForHospital,
                    ),
                  ),
                ),
                _isDoc
                    ? [
                        _getPhotoWidget(),
                        _getRateAndReviewWidget(),
                        AchievementWidget(_profileResponse?.user?.achievements),
                      ][_selectedIndex]
                    : [
                        _getPhotoWidget(),
                        _getRateAndReviewWidget(),
                        AchievementWidget(_profileResponse?.user?.achievements),
                        _getTeamOfExpertsWidget()
                      ][_selectedIndex],
                SizedBox(
                  height: 10,
                ),
                DottedLine(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Time Slots',
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
          ),
          _getTimeSlotWidget(),
          SizedBox(
            height: 25,
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              child: DottedLine()),
          SizedBox(
            height: 25,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 13),
            child: Text(
              'Specialization',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          Container(
            child: SpecialisationWidget(),
            margin: EdgeInsets.symmetric(horizontal: 13),
          )
        ],
      )),
    );
  }

  String _getEmptyString() {
    return PlunesStrings.NA;
  }

  Widget _getTimeSlotWidget() {
    List<String> _slotArray = [];
    if (_profileResponse.user == null ||
        _profileResponse.user.timeSlots == null ||
        _profileResponse.user.timeSlots.isEmpty) {
      return Container(
        height: 40,
        alignment: Alignment.center,
        child: Text("Slots not available",
            style: TextStyle(color: PlunesColors.RED, fontSize: 15)),
      );
    }
    var now = DateTime.now();
    _profileResponse.user.timeSlots.forEach((slot) {
      if (slot.day
          .toLowerCase()
          .contains(DateUtil.getDayAsString(now).toLowerCase())) {
        if (!slot.closed &&
            slot.slotArray != null &&
            slot.slotArray.isNotEmpty) {
          _slotArray = slot.slotArray;
        }
      }
    });
    return _slotArray == null || _slotArray.isEmpty
        ? Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              "Closed",
              style: TextStyle(color: PlunesColors.RED, fontSize: 15),
            ),
          )
        : Container(
            height: 40,
            child: ListView.builder(
              itemCount: _slotArray.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Container(
                padding: EdgeInsets.all(8),
                margin:
                    EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
                decoration: BoxDecoration(
                    color: PlunesColors.WHITECOLOR,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    border:
                        Border.all(color: PlunesColors.BLACKCOLOR, width: .8)),
                alignment: Alignment.center,
                child: Text(
                  _slotArray[index] ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: PlunesColors.BLACKCOLOR,
                      fontWeight: FontWeight.normal,
                      fontSize: AppConfig.smallFont - 1),
                ),
              ),
            ),
          );
  }

  void _getMediaContent() {
    _userBloc.getMediaContent(widget.userID);
  }

  Widget _getPhotoWidget() {
    return StreamBuilder<RequestState>(
        stream: _userBloc.mediaContentStream,
        builder: (context, snapshot) {
          if (_mediaContentApiHitOnce == null || !_mediaContentApiHitOnce) {
            _mediaContentApiHitOnce = true;
            _getMediaContent();
          }
          if (snapshot.data is RequestInProgress) {
            return CustomWidgets().getProgressIndicator();
          } else if (snapshot.data is RequestSuccess) {
            RequestSuccess _requestSuccess = snapshot.data;
            _mediaContent = _requestSuccess.response;
            _userBloc.addStateInMediaContentStream(null);
          } else if (snapshot.data is RequestFailed) {
            RequestFailed _requestFailed = snapshot.data;
            _failureCauseForMediaContent = _requestFailed.failureCause;
            _userBloc.addStateInMediaContentStream(null);
          }
          return (_failureCauseForMediaContent != null ||
                  _mediaContent == null ||
                  _mediaContent.success == null ||
                  !_mediaContent.success)
              ? Container(
                  height: AppConfig.verticalBlockSize * 10,
                  child: Center(
                    child: Text(_failureCauseForMediaContent ??
                        "No photos/videos available yet"),
                  ),
                )
              : PhotosWidget(_mediaContent);
        });
  }

  Widget _getRateAndReviewWidget() {
    return StreamBuilder<RequestState>(
        stream: _userBloc.rateAndReviewStream,
        builder: (context, snapshot) {
          if (_reviewApiHitOnce == null || !_reviewApiHitOnce) {
            _reviewApiHitOnce = true;
            _getReviews();
          }
          if (snapshot.data is RequestInProgress) {
            return CustomWidgets().getProgressIndicator();
          } else if (snapshot.data is RequestSuccess) {
            RequestSuccess _requestSuccess = snapshot.data;
            _rateAndReviewList = _requestSuccess.response;
            _userBloc.addStateInReviewStream(null);
          } else if (snapshot.data is RequestFailed) {
            RequestFailed _requestFailed = snapshot.data;
            _failureForReview = _requestFailed.failureCause;
            _userBloc.addStateInReviewStream(null);
          }
          return ReviewWidget(_rateAndReviewList);
        });
  }

  _openDocDetails(DoctorsData doctorsData) {
    showDialog(
        context: context,
        builder: (_) => CustomWidgets()
            .showDocPopup(doctorsData, context, _profileResponse?.user?.name));
  }

  Widget _getTeamOfExpertsWidget() {
    return (_profileResponse.user.doctorsData == null ||
            _profileResponse.user.doctorsData.isEmpty)
        ? Container()
        : Container(
            height: 250,
            child: ListView.builder(
              itemCount: _profileResponse.user.doctorsData.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Card(
                    margin: EdgeInsets.only(right: 15, bottom: 10, top: 10),
                    child: InkWell(
                      splashColor: PlunesColors.GREENCOLOR.withOpacity(0.5),
                      onTap: () => _openDocDetails(
                          _profileResponse.user.doctorsData[index]),
                      child: Container(
                        width: AppConfig.horizontalBlockSize * 42,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16)),
                                  child: CustomWidgets().getImageFromUrl(
                                      _profileResponse
                                          .user.doctorsData[index].imageUrl,
                                      boxFit: BoxFit.fill,
                                      placeHolderPath:
                                          PlunesImages.doc_placeholder),
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 2),
                              child: Text(
                                CommonMethods.getStringInCamelCase(
                                        _profileResponse
                                            .user?.doctorsData[index]?.name) ??
                                    _getEmptyString(),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#4E4E4E")),
                                    fontSize: 16.0),
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 2),
                              child: Text(
                                _profileResponse
                                        .user?.doctorsData[index].designation ??
                                    PlunesStrings.emptyStr,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#969696")),
                                    fontSize: 14.0),
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 2),
                              child: Text(
                                _getExpr(index) ?? PlunesStrings.emptyStr,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#4E4E4E")),
                                    fontSize: 16.0),
                              ),
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16))));
              },
            ),
          );
  }

  String _getExpr(int itemIndex) {
    return _profileResponse.user.doctorsData[itemIndex].experience == null ||
            _profileResponse.user.doctorsData[itemIndex].experience == "0"
        ? null
        : "Expr ${_profileResponse.user.doctorsData[itemIndex].experience} years";
  }
}

// ignore: must_be_immutable
class PhotosWidget extends StatefulWidget {
  MediaContentModel mediaContent;

  PhotosWidget(this.mediaContent);

  @override
  _PhotosWidgetState createState() => _PhotosWidgetState();
}

class _PhotosWidgetState extends State<PhotosWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                'Photos',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Card(
                        child: Container(
                          margin: EdgeInsets.only(right: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13)),
                            child: CustomWidgets().getImageFromUrl(
                                'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                                boxFit: BoxFit.fill),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13))));
                  },
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                'Videos',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 8,
              ),
              (widget.mediaContent == null ||
                      widget.mediaContent.data == null ||
                      widget.mediaContent.data.serviceVideo == null ||
                      widget.mediaContent.data.serviceVideo.isEmpty)
                  ? Container(
                      alignment: Alignment.topLeft,
                      height: AppConfig.verticalBlockSize * 8,
                      child: Text(
                        "No videos available",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: PlunesColors.RED, fontSize: 16),
                      ),
                    )
                  : Container(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.mediaContent.data.serviceVideo.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: Container(
                                margin: EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(6),
                                            topLeft: Radius.circular(13),
                                            topRight: Radius.circular(13)),
                                        child: InkWell(
                                          child: CustomWidgets().getImageFromUrl(
                                              "https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(widget.mediaContent.data.serviceVideo[index].videoUrl)}/0.jpg",
                                              boxFit: BoxFit.cover),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        YoutubePlayerProvider(
                                                          widget
                                                              .mediaContent
                                                              .data
                                                              .serviceVideo[
                                                                  index]
                                                              .videoUrl,
                                                          title: "Video",
                                                        )));
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(13))));
                        },
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ReviewWidget extends StatefulWidget {
  List<RateAndReview> rateAndReviewList;

  ReviewWidget(this.rateAndReviewList);

  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8,
          ),
          Text(
            'Patient review',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 8,
          ),
          (widget.rateAndReviewList == null || widget.rateAndReviewList.isEmpty)
              ? Container(
                  height: AppConfig.verticalBlockSize * 10,
                  child: Center(
                    child: Text("No reviews yet"),
                  ),
                )
              : Container(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.rateAndReviewList?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            width: c_width,
                            margin: EdgeInsets.only(right: 20),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(6),
                                              bottomRight: Radius.circular(6),
                                              topLeft: Radius.circular(13),
                                              topRight: Radius.circular(13)),
                                          child: CustomWidgets()
                                              .getImageFromUrl(
                                                  widget
                                                      .rateAndReviewList[index]
                                                      .userImage,
                                                  boxFit: BoxFit.cover),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          CommonMethods.getStringInCamelCase(
                                              widget.rateAndReviewList[index]
                                                  .userName),
                                          softWrap: true,
                                          style: TextStyle(
                                            color: Color(0xff4E4E4E),
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width: c_width * 0.5,
                                        child: Text(
                                          widget.rateAndReviewList[index]
                                                  .description ??
                                              "",
                                          softWrap: true,
                                          maxLines: 4,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xff4E4E4E),
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                  topLeft: Radius.circular(13),
                                  topRight: Radius.circular(13))));
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class AchievementWidget extends StatefulWidget {
  final List<AchievementsData> achievements;

  AchievementWidget(this.achievements);

  @override
  _AchievementWidgetState createState() => _AchievementWidgetState();
}

class _AchievementWidgetState extends State<AchievementWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 8,
        ),
        Text(
          'Achievements',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 8,
        ),
        (widget.achievements == null || widget.achievements.isEmpty)
            ? Container(
                height: AppConfig.verticalBlockSize * 10,
                child: Center(
                  child: Text("No achievements yet"),
                ),
              )
            : Container(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.achievements?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Card(
                        margin: EdgeInsets.only(right: 20),
                        child: Container(
                          child: InkWell(
                            onTap: () {
                              List<Photo> photos = [];
                              widget.achievements.forEach((element) {
                                if (widget.achievements[index] == null ||
                                    widget
                                        .achievements[index].imageUrl.isEmpty ||
                                    !(widget.achievements[index].imageUrl
                                        .contains("http"))) {
                                  photos.add(Photo(
                                      assetName: plunesImages.achievementIcon));
                                } else {
                                  photos
                                      .add(Photo(assetName: element.imageUrl));
                                }
                              });
                              if (photos != null && photos.isNotEmpty) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PageSlider(photos, index)));
                              }
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                        topLeft: Radius.circular(13),
                                        topRight: Radius.circular(13)),
                                    child: (widget.achievements[index] ==
                                                null ||
                                            widget.achievements[index].imageUrl
                                                    .isEmpty &&
                                                !(widget.achievements[index]
                                                    .imageUrl
                                                    .contains("http")))
                                        ? Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: AppConfig
                                                        .verticalBlockSize *
                                                    4,
                                                horizontal: AppConfig
                                                        .horizontalBlockSize *
                                                    10),
                                            child: Image.asset(
                                              plunesImages.achievementIcon,
                                            ))
                                        : CustomWidgets().getImageFromUrl(
                                            widget.achievements[index].imageUrl,
                                            boxFit: BoxFit.cover),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13))));
                  },
                ),
              ),
      ],
    );
  }
}

class SpecialisationWidget extends StatefulWidget {
  @override
  _SpecialisationWidgetState createState() => _SpecialisationWidgetState();
}

class _SpecialisationWidgetState extends State<SpecialisationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: 20,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Card(
              child: Container(
                margin: EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13)),
                        child: CustomWidgets().getImageFromUrl(
                            'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                            boxFit: BoxFit.fill),
                      ),
                    ),
                    Text(
                      'Covid safe',
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13))));
        },
      ),
    );
  }
}
