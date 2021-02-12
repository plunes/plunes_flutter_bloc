import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/new_solution_blocs/sol_home_screen_bloc.dart';
import 'package:plunes/models/new_solution_model/why_us_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';

const kDefaultImageUrl =
    'https://goqii.com/blog/wp-content/uploads/Doctor-Consultation.jpg';

// ignore: must_be_immutable
class WhyUsCardsByIdScreen extends BaseActivity {
  String id;

  WhyUsCardsByIdScreen(this.id);

  @override
  _WhyUsCardsByIdScreenState createState() => _WhyUsCardsByIdScreenState();
}

class _WhyUsCardsByIdScreenState extends BaseState<WhyUsCardsByIdScreen> {
  HomeScreenMainBloc _homeScreenMainBloc;
  WhyUsByIdModel _whyUsByIdModel;
  int _currentPage;
  String _failedMessage;
  StreamController _dotStreamUpdater;

  @override
  void initState() {
    _dotStreamUpdater = StreamController.broadcast();
    _currentPage = 0;
    _homeScreenMainBloc = HomeScreenMainBloc();
    _getCardsData();
    super.initState();
  }

  @override
  void dispose() {
    _homeScreenMainBloc?.dispose();
    _dotStreamUpdater?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.getAppBar(context, PlunesStrings.whyUs, true),
      body: StreamBuilder<RequestState>(
          initialData: RequestInProgress(),
          stream: _homeScreenMainBloc.getWhyUsCardByIdStream,
          builder: (context, snapshot) {
            if (snapshot.data is RequestSuccess) {
              RequestSuccess successObject = snapshot.data;
              _whyUsByIdModel = successObject.response;
              _homeScreenMainBloc?.addIntoGetWhyUsDataStream(null);
            } else if (snapshot.data is RequestFailed) {
              RequestFailed _failedObj = snapshot.data;
              _failedMessage = _failedObj?.failureCause;
              _homeScreenMainBloc?.addIntoGetWhyUsDataStream(null);
            } else if (snapshot.data is RequestInProgress) {
              return CustomWidgets().getProgressIndicator();
            }
            return (_whyUsByIdModel == null ||
                    (_whyUsByIdModel.success != null &&
                        !_whyUsByIdModel.success) ||
                    _whyUsByIdModel.data == null ||
                    _whyUsByIdModel.data.description == null ||
                    _whyUsByIdModel.data.description.isEmpty)
                ? CustomWidgets().errorWidget(_failedMessage,
                    onTap: () => _getCardsData(), isSizeLess: true)
                : _getBody();
          }),
    );
  }

  Widget _getPager() {
    return PageView(
      onPageChanged: (index) {
        _currentPage = index;
        _dotStreamUpdater?.add(null);
      },
      children:
          _whyUsByIdModel.data.description.map((e) => _getPage(e)).toList(),
    );
  }

  Widget _getPage(Description desc) {
    // print(desc.image);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: AppConfig.verticalBlockSize * 40,
            width: double.infinity,
            child: _imageFittedBox(desc?.image ?? ""),
          ),

          // text label
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 4,
                left: AppConfig.horizontalBlockSize * 4,
                right: AppConfig.horizontalBlockSize * 4),
            // width: AppConfig.horizontalBlockSize * 80,
            child: Text(
              _whyUsByIdModel.data.title ?? "",
              // maxLines: 3,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: AppConfig.extraLargeFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // paragraph text
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 3,
                left: AppConfig.horizontalBlockSize * 4,
                right: AppConfig.horizontalBlockSize * 4),
            child: Text(
              desc?.content ?? "",
              textAlign: TextAlign.left,
              // maxLines: 4,
              style: TextStyle(
                fontSize: AppConfig.largeFont,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    return Column(
      children: [
        Expanded(child: _getPager()),
        Container(
          margin: EdgeInsets.only(
            bottom: AppConfig.verticalBlockSize * 1,
          ),
          child: StreamBuilder<Object>(
              stream: _dotStreamUpdater.stream,
              builder: (context, snapshot) {
                return DotsIndicator(
                    position: _currentPage?.toDouble(),
                    decorator: DotsDecorator(
                        activeColor: PlunesColors.BLACKCOLOR,
                        color: PlunesColors.GREYCOLOR),
                    dotsCount: _whyUsByIdModel?.data?.description?.length ?? 0);
              }),
        ),
        Container(
          margin: EdgeInsets.only(
            bottom: AppConfig.verticalBlockSize * 3,
          ),
          child:
              _roundedButton('Book Your Procedure', Color(0xff25B281), context),
        ),
      ],
    );
  }

  void _getCardsData() {
    _homeScreenMainBloc.getWhyUsDataById(widget.id);
  }
}

Widget _roundedButton(String text, Color color, BuildContext context) {
  return Container(
    margin:
        EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 20),
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SolutionBiddingScreen()));
        },
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

Widget _imageFittedBox(String imageUrl) {
  return ClipRRect(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(25.0),
      bottomRight: Radius.circular(25.0),
    ),
    child: CustomWidgets().getImageFromUrl(imageUrl, boxFit: BoxFit.cover),
  );
}
