import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
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

  @override
  void initState() {
    _user = widget.user;
    _userBloc = widget.userBloc;
    _rateAndReviewList = [];
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConfig.verticalBlockSize * 32,
      color: PlunesColors.WHITECOLOR,
      child: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(
                "Achievement Book",
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              )),
              Tab(
                  child: Text(
                "Reviews",
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ))
            ],
//            indicatorColor: Colors.transparent,
          ),
          Expanded(
              child: TabBarView(
            children: [
              (_user == null ||
                      _user.achievements == null ||
                      _user.achievements.isEmpty)
                  ? _getEmptyView("No achievements found")
                  : _getAchievementListView(),
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
                        ? _getEmptyView(_failureCause ?? "No reviews found")
                        : _getReviewsListView();
                  })
            ],
            controller: _tabController,
          ))
        ],
      ),
    );
  }

  Widget _getAchievementListView() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: AppConfig.verticalBlockSize * 1,
          horizontal: AppConfig.horizontalBlockSize * 2),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _getAchievementView(index);
        },
        itemCount: _user?.achievements?.length ?? 0,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _getReviewsListView() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _getReviewView(index);
        },
        itemCount: _rateAndReviewList.length,
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
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(AppConfig.horizontalBlockSize * 5))),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: AppConfig.horizontalBlockSize * 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppConfig.horizontalBlockSize * 5)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppConfig.horizontalBlockSize * 5)),
                  child: (_user.achievements[index] == null ||
                          _user.achievements[index].imageUrl.isEmpty)
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 4,
                              horizontal: AppConfig.horizontalBlockSize * 10),
                          child: Image.asset(
                            plunesImages.achievementIcon,
                          ))
                      : CustomWidgets().getImageFromUrl(
                          _user.achievements[index].imageUrl,
                          boxFit: BoxFit.cover),
                ),
              ),
              flex: 4,
            ),
            _user.achievements[index].title.isEmpty
                ? Container()
                : Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 0.5),
                      child: Center(
                        child: Text(
                          _user.achievements[index].title,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      width: AppConfig.horizontalBlockSize * 40,
                    ),
                  ),
            _user.achievements[index].achievement.isEmpty
                ? Container()
                : Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 0.5),
                      child: Center(
                        child: Text(
                          _user.achievements[index]?.achievement,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      width: AppConfig.horizontalBlockSize * 40,
                    ),
                    flex: 1,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _getReviewView(int index) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 3,
          vertical: AppConfig.verticalBlockSize * 1),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              (_rateAndReviewList[index].userImage == null ||
                      _rateAndReviewList[index].userImage.isEmpty ||
                      !_rateAndReviewList[index].userImage.contains("http"))
                  ? CustomWidgets().getBackImageView(
                      _rateAndReviewList[index].userName,
                      width: 45,
                      height: 45)
                  : CircleAvatar(
                      child: Container(
                        height: 45,
                        width: 45,
                        child: ClipOval(
                            child: CustomWidgets().getImageFromUrl(
                                _rateAndReviewList[index].userImage,
                                boxFit: BoxFit.fill)),
                      ),
                      radius: 22.5,
                    ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _rateAndReviewList[index]?.userName ?? PlunesStrings.NA,
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR, fontSize: 18),
                      ),
                      CustomWidgets().showRatingBar(
                          _rateAndReviewList[index].rating?.toDouble() ?? 1.0)
                    ],
                  ),
                ),
                flex: 6,
              ),
//              Expanded(
//                child: Padding(
//                  padding:
//                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
//                  child: Text(_rateAndReviewList[index].),
//                ),
//                flex: 3,
//              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 1.2,
                bottom: AppConfig.verticalBlockSize * 1.2),
//            height: AppConfig.verticalBlockSize * 13,
            width: double.infinity,
            child: Text(
              _rateAndReviewList[index].description ?? PlunesStrings.NA,
              textAlign: TextAlign.start,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: PlunesColors.GREYCOLOR,
          )
        ],
      ),
    );
  }

  Widget _getEmptyView(String message) {
    return Container(
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
