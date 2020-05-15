import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';

// ignore: must_be_immutable
class AchievementAndReview extends BaseActivity {
  @override
  _AchievementAndReviewState createState() => _AchievementAndReviewState();
}

class _AchievementAndReviewState extends BaseState<AchievementAndReview>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConfig.verticalBlockSize * 50,
      color: PlunesColors.LIGHTGREENCOLOR,
      child: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(child: Text("Achievement Book")),
              Tab(child: Text("Reviews"))
            ],
            indicatorColor: PlunesColors.GREENCOLOR,
          ),
          Expanded(
              child: TabBarView(
            children: [_getAchievementListView(), _getReviewsListView()],
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
          return _getAchievementView();
        },
        itemCount: 50 ?? 0,
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

  Widget _getAchievementView() {
    return Card(
      elevation: 1.0,
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(AppConfig.horizontalBlockSize * 5))),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: AppConfig.horizontalBlockSize * 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(AppConfig.horizontalBlockSize * 5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                    Radius.circular(AppConfig.horizontalBlockSize * 5)),
                child: CustomWidgets().getImageFromUrl(
                    "https://image.shutterstock.com/z/stock-photo-bright-spring-view-of-the-cameo-island-picturesque-morning-scene-on-the-port-sostis-zakinthos-1048185397.jpg",
                    boxFit: BoxFit.fill),
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Container(
              child: Center(
                child: Text(
                  "bduhasdhasidashd dsajgdasudgasud",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              width: AppConfig.horizontalBlockSize * 55,
            ),
            flex: 1,
          ),
        ],
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
}
