import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';

// ignore: must_be_immutable
class AchievementAndReview extends BaseActivity {
  User user;
  BuildContext context;

  AchievementAndReview(this.user, this.context);

  @override
  _AchievementAndReviewState createState() => _AchievementAndReviewState();
}

class _AchievementAndReviewState extends BaseState<AchievementAndReview>
    with TickerProviderStateMixin {
  TabController _tabController;
  User _user;

  @override
  void initState() {
    _user = widget.user;
    _tabController = TabController(length: 1, vsync: this, initialIndex: 0);
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
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2.0),
              )),
//                Tab(child: Text("Reviews"))
            ],
            indicatorColor: Colors.transparent,
          ),
          Expanded(
              child: TabBarView(
            children: [
              (_user == null ||
                      _user.achievements == null ||
                      _user.achievements.isEmpty)
                  ? _getEmptyView("No achievements found")
                  : _getAchievementListView(),
//            _getReviewsListView()
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
          return _getReviewView();
        },
        itemCount: 50 ?? 0,
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

  Widget _getReviewView() {
    int x;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 3,
          vertical: AppConfig.verticalBlockSize * 1),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              x == null
                  ? CustomWidgets().getBackImageView("sd dd")
                  : CircleAvatar(
                      child: Container(
                        height: 60,
                        width: 60,
                        child: ClipOval(
                            child: CustomWidgets().getImageFromUrl(
                                "https://image.shutterstock.com/z/stock-photo-bright-spring-view-of-the-cameo-island-picturesque-morning-scene-on-the-port-sostis-zakinthos-1048185397.jpg",
                                boxFit: BoxFit.fill)),
                      ),
                      radius: 30,
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
                        "Sonam Singhdsjkfkasdhs",
                        style: TextStyle(
                            color: PlunesColors.BLACKCOLOR, fontSize: 18),
                      ),
                      CustomWidgets().showRatingBar(4.0)
                    ],
                  ),
                ),
                flex: 6,
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2),
                  child: Text("10 m Ago"),
                ),
                flex: 3,
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 1.2,
                bottom: AppConfig.verticalBlockSize * 1.2),
            height: AppConfig.verticalBlockSize * 13,
            width: double.infinity,
            child: Text(
              "review here",
              textAlign: TextAlign.start,
              maxLines: 4,
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
}
