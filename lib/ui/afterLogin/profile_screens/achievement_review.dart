import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';

// ignore: must_be_immutable
class AchievementAndReview extends BaseActivity {
  User user;
  BuildContext context;
  final UserBloc userBloc;

  AchievementAndReview(this.user, this.context, this.userBloc);

  @override
  _AchievementAndReviewState createState() => _AchievementAndReviewState();
}

class _AchievementAndReviewState extends BaseState<AchievementAndReview>
    with TickerProviderStateMixin {
  TabController _tabController;
  User _user;
  UserBloc _userBloc;
  List<RateAndReview> _rateAndReviewList = [];
  String _failureCause;
  bool _hasHitOnce = false;
  StreamController _streamController;
  Timer _timer;

  @override
  void initState() {
    _user = widget.user;
    _userBloc = widget.userBloc;
    _rateAndReviewList = [];
    _streamController = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _streamController?.add(null);
      _timer = timer;
    });
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    _streamController?.close();
    _tabController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
//      Container(
//      margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
//      height: AppConfig.verticalBlockSize * 35,
//      color: PlunesColors.WHITECOLOR,
//      child:
        Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
//          TabBar(
//            controller: _tabController,
//            tabs: [
//              Tab(
//                child: Text(
//                  "Achievement Book",
//                  style: TextStyle(
//                      color: PlunesColors.BLACKCOLOR,
//                      fontWeight: FontWeight.w500,
//                      fontSize: 15),
//                ),
//              ),
//              Tab(
//                child: Text(
//                  "Check Reviews",
//                  style: TextStyle(
//                      color: PlunesColors.BLACKCOLOR,
//                      fontWeight: FontWeight.w500,
//                      fontSize: 15),
//                ),
//              )
//            ],
//            indicator: BoxDecoration(
//              color: PlunesColors.GREYCOLOR.withOpacity(.2),
//              borderRadius: BorderRadius.only(
//                topLeft: Radius.circular(15),
//                topRight: Radius.circular(15),
//              ),
//            ),
////            indicatorColor: Colors.transparent,
//          ),
//          SizedBox(height: AppConfig.verticalBlockSize * 1),

//        Container(
//          height: AppConfig.verticalBlockSize * 20,
//          child:
        (_user == null ||
                _user.achievements == null ||
                _user.achievements.isEmpty)
            ? Container()
//        _getEmptyView("No achievements found")
            : _getAchievementListView(
                24,
                24,
                plunesImages.achievement,
              ),
//        Container(
//          margin:
//              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
//          height: 0.7,
//          color: PlunesColors.GREYCOLOR,
//          width: double.infinity,
//        ),
//        ),
//          Expanded(
//              child:
//              TabBarView(
//            children: [
//              (_user == null ||
//                      _user.achievements == null ||
//                      _user.achievements.isEmpty)
//                  ? _getEmptyView("No achievements found")
//                  : _getAchievementListView(),
        StreamBuilder<RequestState>(
            stream: _userBloc.rateAndReviewStream,
            builder: (context, snapshot) {
              if (_hasHitOnce == null || !_hasHitOnce) {
                _hasHitOnce = true;
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
                _failureCause = _requestFailed.failureCause;
                _userBloc.addStateInReviewStream(null);
              }
              return (_failureCause != null ||
                      _rateAndReviewList == null ||
                      _rateAndReviewList.isEmpty)
                  ? Container()
//              _getEmptyView(_failureCause ?? "No reviews found")
                  : _getReviewsListView(
                      24, 24, PlunesImages.review, PlunesStrings.checkReviews);
            }),
//            ],
//            controller: _tabController,
//          ))
      ],
    );
//    )
  }

  Widget _getAchievementListView(double height, double width, String icon) {
    return Column(
      children: <Widget>[
        Container(
          margin:
              EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
          height: 0.7,
          color: PlunesColors.GREYCOLOR,
          width: double.infinity,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: width,
                  height: height,
                  child: widget.getAssetIconWidget(
                      icon, height, width, BoxFit.contain)),
              SizedBox(width: 10),
              Text(
                plunesStrings.achievementBook,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                height: AppConfig.verticalBlockSize * 17,
//      color: PlunesColors.GREYCOLOR.withOpacity(.2),
//      padding: EdgeInsets.only(
//        top: AppConfig.verticalBlockSize * 2,
//        left: AppConfig.horizontalBlockSize * 1,
//        right: AppConfig.horizontalBlockSize * 1,
//        bottom: AppConfig.horizontalBlockSize * 2,
//      ),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _getAchievementView(index);
                  },
                  itemCount:
                      // _user.achievements.length > 3
                      //     ? 3
                      //     :
                      _user.achievements.length ?? 0,
                  scrollDirection: Axis.horizontal,
//                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getReviewsListView(
      double height, double width, String icon, String title) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            margin:
                EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
            height: 0.7,
            color: PlunesColors.GREYCOLOR,
            width: double.infinity,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: width,
                    height: height,
                    child: widget.getAssetIconWidget(
                        icon, height, width, BoxFit.contain)),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      color: PlunesColors.BLACKCOLOR,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
//            color: PlunesColors.GREYCOLOR.withOpacity(.2),
//      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1),
            padding: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 1,
                horizontal: AppConfig.horizontalBlockSize * 1),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _getReviewView(index);
              },
              itemCount: 1,
//              _rateAndReviewList.length,
            ),
          ),
          _rateAndReviewList.length > 1
              ? InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => CustomWidgets().showReviewList(
                              _rateAndReviewList,
                              context,
                            ),
                        barrierDismissible: true);
//              showDialog(
//                  context: context,
//                  builder: (context) => CustomWidgets()
//                      .showDoctorList(
//                      _profileResponse.user.doctorsData,
//                      context,
//                      _profileResponse?.user?.name),
//                  barrierDismissible: true);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 5),
                    alignment: Alignment.center,
                    child: Text(
                      PlunesStrings.view_More,
                      style: TextStyle(
                        color: PlunesColors.GREENCOLOR,
                        fontSize: 14,
                        decorationThickness: 2.0,
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget _getAchievementView(int index) {
    return InkWell(
      onTap: () {
        List<Photo> photos = [];
        _user.achievements.forEach((element) {
          if (_user.achievements[index] == null ||
              _user.achievements[index].imageUrl.isEmpty ||
              !(_user.achievements[index].imageUrl.contains("http"))) {
            photos.add(Photo(assetName: plunesImages.achievementIcon));
          } else {
            photos.add(Photo(assetName: element.imageUrl));
          }
        });
        if (photos != null && photos.isNotEmpty) {
          Navigator.push(
              widget.context,
              MaterialPageRoute(
                  builder: (context) => PageSlider(photos, index)));
        }
      },
      child:
//       index == 2
//           ? Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: AppConfig.horizontalBlockSize * 1.5,
//                   vertical: AppConfig.verticalBlockSize * 1),
//               height: 0.5,
// //              AppConfig.verticalBlockSize * 15,
//               width: AppConfig.horizontalBlockSize * 27,
//               decoration: ShapeDecoration(
//                 shape: RoundedRectangleBorder(
//                   side: BorderSide(
//                       width: 1.0,
//                       style: BorderStyle.solid,
//                       color: PlunesColors.GREYCOLOR),
//                   borderRadius: BorderRadius.all(
//                       Radius.circular(AppConfig.horizontalBlockSize * 2)),
//                 ),
// //                      borderRadius: BorderRadius.all(
// //                          Radius.circular(AppConfig.horizontalBlockSize * 5)),
//               ),
//               child: Center(
//                   child: Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: Text(
//                   "View more",
//                   // "${_user.achievements.length - 2} More Photos",
//                   maxLines: 2,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: AppConfig.smallFont,
//                       fontWeight: FontWeight.normal,
//                       decoration: TextDecoration.underline),
//                 ),
//               )),
//             )
//           :
          Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 1.5,
            vertical: AppConfig.verticalBlockSize * 1),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(AppConfig.horizontalBlockSize * 2))),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: AppConfig.horizontalBlockSize * 29,
                height: 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppConfig.horizontalBlockSize * 2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppConfig.horizontalBlockSize * 2)),
                  child: (_user.achievements[index] == null ||
                          _user.achievements[index].imageUrl.isEmpty &&
                              !(_user.achievements[index].imageUrl
                                  .contains("http")))
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 4,
                              horizontal: AppConfig.horizontalBlockSize * 10),
                          child: Image.asset(
                            plunesImages.achievementIcon,
                          ))
                      : CustomWidgets().getImageFromUrl(
                          _user.achievements[index].imageUrl,
                          boxFit: BoxFit.fill,
                          placeHolderPath:
                              PlunesImages.achievement_placeholder),
                ),
              ),
              flex: 4,
            ),
            // _user.achievements[index].title.isEmpty
            //     ? Container()
            //     : Expanded(
            //         child: Container(
            //           padding: EdgeInsets.symmetric(
            //               horizontal:
            //                   AppConfig.horizontalBlockSize * 0.5),
            //           child: Padding(
            //             padding: EdgeInsets.only(
            //                 top: AppConfig.verticalBlockSize * .5),
            //             child: Text(
            //               _user.achievements[index].title,
            //               maxLines: 1,
            //               overflow: TextOverflow.clip,
            //               textAlign: TextAlign.center,
            //               style: TextStyle(fontSize: 14),
            //             ),
            //           ),
            //           width: AppConfig.horizontalBlockSize * 40,
            //         ),
            //       ),
            // _user.achievements[index].achievement.isEmpty
            //     ? Container()
            //     : Flexible(
            //         child: Container(
            //           padding: EdgeInsets.symmetric(
            //               horizontal:
            //                   AppConfig.horizontalBlockSize * 0.5),
            //           child: Center(
            //             child: Text(
            //               _user.achievements[index]?.achievement,
            //               maxLines: 1,
            //               overflow: TextOverflow.clip,
            //               textAlign: TextAlign.start,
            //               style: TextStyle(fontSize: 14),
            //             ),
            //           ),
            //           width: AppConfig.horizontalBlockSize * 40,
            //         ),
            //         flex: 1,
            //       ),
          ],
        ),
      ),
    );
  }

  Widget _getReviewView(int index) {
    return Container(
      margin: EdgeInsets.only(
        right: AppConfig.horizontalBlockSize * 2,
//          vertical: AppConfig.verticalBlockSize * 1
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (_rateAndReviewList[index].userImage == null ||
                      _rateAndReviewList[index].userImage.isEmpty ||
                      !_rateAndReviewList[index].userImage.contains("http"))
                  ? CustomWidgets().getBackImageView(
                      _rateAndReviewList[index].userName,
                      width: 50,
                      height: 50)
                  : CircleAvatar(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: ClipOval(
                            child: CustomWidgets().getImageFromUrl(
                                _rateAndReviewList[index].userImage,
                                boxFit: BoxFit.fill)),
                      ),
                      radius: 25,
                    ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          _rateAndReviewList[index]?.userName ??
                              PlunesStrings.NA,
                          style: TextStyle(
                              color: PlunesColors.BLACKCOLOR, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: CustomWidgets().showRatingBar(
                            _rateAndReviewList[index].rating?.toDouble() ??
                                1.0),
                      )
                    ],
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
                  child: StreamBuilder<Object>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        return Text(
                          DateUtil.getDuration(
                                  _rateAndReviewList[index].createdAt ?? 0) ??
                              PlunesStrings.NA,
                          style: TextStyle(fontSize: AppConfig.smallFont),
                        );
                      }),
                ),
                flex: 2,
              )
            ],
          ),
          SizedBox(
            height: AppConfig.verticalBlockSize * 2,
          ),
          Container(
//            margin: EdgeInsets.only(
//                top: AppConfig.verticalBlockSize * 1.2,
//                bottom: AppConfig.verticalBlockSize * 1.2),
//            height: AppConfig.verticalBlockSize * 13,
            width: double.infinity,
            child: Text(
              _rateAndReviewList[index].description ?? PlunesStrings.NA,
              textAlign: TextAlign.start,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
          ),
//          Container(
//            margin: EdgeInsets.only(
//                left: AppConfig.horizontalBlockSize * 12,
//                right: AppConfig.horizontalBlockSize * 5,
//                top: AppConfig.verticalBlockSize * .5,
//                bottom: AppConfig.verticalBlockSize * 1),
//            width: double.infinity,
//            height: 0.5,
//            color: PlunesColors.GREYCOLOR,
//          )
        ],
      ),
    );
  }

  Widget _getEmptyView(String message) {
    return Container(
      color: PlunesColors.GREYCOLOR.withOpacity(.2),
      height: AppConfig.verticalBlockSize * 15,
      width: double.infinity,
      child: Center(
        child: Text(message),
      ),
    );
  }

  void _getReviews() {
    _userBloc.getRateAndReviews(_user.uid);
  }
}
