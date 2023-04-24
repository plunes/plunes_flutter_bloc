import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/video_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/blocs/solution_blocs/prev_missed_solution_bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_main_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';

// ignore: must_be_immutable
class PreviousActivity extends BaseActivity {
  final Function func;

  PreviousActivity(this.func);

  @override
  _PreviousActivityState createState() => _PreviousActivityState();
}

// class _PreviousActivityState extends BaseState<PreviousActivity> {
class _PreviousActivityState extends State<PreviousActivity> {
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  PrevMissSolutionBloc? _prevMissSolutionBloc;
  PrevSearchedSolution? _prevSearchedSolution;
  List<CatalogueData> _prevSolutions = [], _missedSolutions = [];
  String? _failureCause;
  late bool _isProcessing;
  StreamController? _streamController;
  Timer? _timerForTimeUpdation;
  CartMainBloc? _cartBloc;
  User? _user;

  @override
  void initState() {
    _user = UserManager().getUserDetails();
    FirebaseNotification.setScreenName(FirebaseNotification.activityScreen);
    _cartBloc = CartMainBloc();
    _streamController = StreamController.broadcast();
    _timerForTimeUpdation = Timer.periodic(Duration(seconds: 1), (timer) {
      _timerForTimeUpdation = timer;
      _streamController?.add(null);
    });
    _isProcessing = true;
    _prevSolutions = [];
    _missedSolutions = [];
    _prevMissSolutionBloc = PrevMissSolutionBloc();
    _getPreviousSolutions();
    EventProvider().getSessionEventBus()!.on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == FirebaseNotification.activityScreen &&
          mounted) {
        _getPreviousSolutions();
      }
    });
    super.initState();
  }

  void _getCartCount() {
    _cartBloc!.getCartCount();
  }

  @override
  void dispose() {
    FirebaseNotification.setScreenName(null);
    _getCartCount();
    _streamController?.close();
    _prevMissSolutionBloc?.dispose();
    _timerForTimeUpdation?.cancel();
    _cartBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          (_user != null && _user!.userType != null &&
                  _user!.userType!.toLowerCase() == Constants.user.toString().toLowerCase())
              ? Container(
                  child: HomePageAppBar(
                    widget.func,
                    () {},
                    () {},
                    one: null,
                    two: null,
                    hasSearchBar: true,
                    searchBarText: "Your Activity",
                  ),
                  margin: EdgeInsets.only(
                      top: AppConfig.getMediaQuery()!.padding.top),
                )
              : Container(),
          Expanded(
            child: _isProcessing
                ? CustomWidgets().getProgressIndicator()
                : (_failureCause != null && _failureCause == PlunesStrings.noInternet)
                    ? CustomWidgets().errorWidget(_failureCause,
                        buttonText: PlunesStrings.refresh,
                        onTap: () => _getPreviousSolutions())
                    : _getWidgetBody(),
          ),
        ],
      ),
    );
  }

  Widget _getWidgetBody() {
    return Column(
      children: <Widget>[
        _getPreviousView(),
      ],
    );
  }

//   _getMissedNegotiationView() {
//     return Expanded(
//         child: Card(
//             margin: EdgeInsets.all(0.0),
//             child: Container(
//               width: double.infinity,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   (_prevSearchedSolution == null ||
//                           _prevSearchedSolution.data == null ||
//                           _prevSearchedSolution.data.isEmpty ||
//                           _missedSolutions == null ||
//                           _missedSolutions.isEmpty)
//                       ? Expanded(
//                           child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             Container(
//                               margin: EdgeInsets.symmetric(
//                                   vertical: AppConfig.verticalBlockSize * 2.5),
//                               child: Image.asset(
//                                 PlunesImages.prev_missed_act_icon,
//                                 height: AppConfig.verticalBlockSize * 12,
//                                 width: AppConfig.horizontalBlockSize * 40,
//                               ),
//                             ),
//                             Text(
//                               "You don't have any missed prices",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: AppConfig.smallFont),
//                             ),
//                           ],
//                         ))
//                       : Expanded(
//                           child: ListView.builder(
//                             padding: EdgeInsets.all(0.0),
//                             itemBuilder: (context, index) {
//                               if ((_missedSolutions[index].topSearch != null &&
//                                       _missedSolutions[index].topSearch) ||
//                                   (_missedSolutions[index].toShowSearched !=
//                                           null &&
//                                       _missedSolutions[index].toShowSearched)) {
//                                 return Container();
//                               }
//                               TapGestureRecognizer tapRecognizer =
//                                   TapGestureRecognizer()
//                                     ..onTap = () => _onViewMoreTap(index);
//                               return Stack(
//                                 children: <Widget>[
//                                   CustomWidgets().getSolutionRow(
//                                       _missedSolutions, index,
//                                       onButtonTap: () => _onSolutionItemTap(
//                                           _missedSolutions[index]),
//                                       onViewMoreTap: tapRecognizer),
// //                              Positioned.fill(
// //                                child: Container(
// //                                  decoration: BoxDecoration(
// //                                      gradient: LinearGradient(
// //                                          begin: FractionalOffset.topCenter,
// //                                          end: FractionalOffset.bottomCenter,
// //                                          colors: [
// //                                        Colors.white10,
// //                                        Colors.white70
// //                                        // I don't know what Color this will be, so I can't use this
// //                                      ])),
// //                                  width: double.infinity,
// //                                ),
// //                              ),
//                                 ],
//                               );
//                             },
//                             itemCount: _missedSolutions?.length ?? 0,
//                           ),
//                         ),
//                   // _reminderView(),
//                 ],
//               ),
//             )));
//   }

  Widget _getPreviousView() {
    return Expanded(
        child: Card(
            margin: const EdgeInsets.all(0.0),
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (_prevSearchedSolution == null ||
                          _prevSearchedSolution!.data == null ||
                          _prevSearchedSolution!.data!.isEmpty ||
                          _prevSolutions == null ||
                          _prevSolutions.isEmpty)
                      ? Expanded(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: AppConfig.verticalBlockSize * 2.5),
                              child: Image.asset(
                                PlunesImages.prev_missed_act_icon,
                                height: AppConfig.verticalBlockSize * 12,
                                width: AppConfig.horizontalBlockSize * 40,
                              ),
                            ),
                            Text(
                              "You don't have any previous activities",
                              style: TextStyle(fontSize: AppConfig.smallFont),
                            ),
                          ],
                        ))
                      : Expanded(
                          child: Column(
                            children: [
                              _getTitleWidget(),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(0.0),
                                  itemBuilder: (context, index) {
                                    if ((_prevSolutions[index].topSearch !=
                                                null &&
                                            _prevSolutions[index].topSearch!) ||
                                        (_prevSolutions[index].toShowSearched !=
                                                null &&
                                            _prevSolutions[index]
                                                .toShowSearched!)) {
                                      return Container();
                                    }
                                    return _getPreviousActivityCard(
                                        _prevSolutions[index]);
                                  },
                                  itemCount: _prevSolutions.length ?? 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            )));
  }

  void _getPreviousSolutions() async {
    _failureCause = null;
    if (!_isProcessing) {
      _isProcessing = true;
      _setState();
    }
    _prevMissSolutionBloc!.getPreviousSolutions().then((requestState) {
      if (requestState is RequestSuccess) {
        _prevSearchedSolution = requestState.response;
        if (_prevSearchedSolution != null &&
            _prevSearchedSolution!.data != null &&
            _prevSearchedSolution!.data!.isNotEmpty) {
          _prevSolutions = [];
          _missedSolutions = [];
          _prevSearchedSolution!.data!.forEach((solution) {
            _prevSolutions.add(solution);
          });
        }
      } else if (requestState is RequestFailed) {
        _failureCause = requestState.failureCause ?? plunesStrings.somethingWentWrong;
      }
      _isProcessing = false;
      _setState();
    });
  }

  void _onSolutionItemTap(CatalogueData catalogueData) async {
    catalogueData.isFromNotification = true;
    var nowTime = DateTime.now();
    if (catalogueData.solutionExpiredAt != null &&
        catalogueData.solutionExpiredAt != 0) {
      var solExpireTime =
          DateTime.fromMillisecondsSinceEpoch(catalogueData.solutionExpiredAt!);
      var diff = nowTime.difference(solExpireTime);
      if (diff.inSeconds < 5) {
        ///when price discovered and solution is active
        if (catalogueData.priceDiscovered != null &&
            catalogueData.priceDiscovered!) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SolutionShowPriceScreen(
                      catalogueData: catalogueData, searchQuery: "")));
        } else {
          ///when price not discovered but solution is active
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewSolutionsScreen(
                      catalogueData: catalogueData, searchQuery: "")));
        }
        _getPreviousSolutions();
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SolutionBiddingScreen(
                      searchQuery: catalogueData?.service,
                    ))).then((value) {
          _getPreviousSolutions();
        });
      }
    } else {
      catalogueData.isFromNotification = false;
      if (!UserManager().getIsUserInServiceLocation()) {
        await showDialog(
            context: context,
            builder: (context) {
              return CustomWidgets().fetchLocationPopUp(context);
            },
            barrierDismissible: false);
        if (!UserManager().getIsUserInServiceLocation()) {
          return;
        }
      }
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SolutionBiddingScreen(searchQuery: catalogueData?.service)));
      _getPreviousSolutions();
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getPreviousActivityCard(CatalogueData catalogueData) {
    return Card(
        elevation: 2.0,
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 4,
            vertical: AppConfig.verticalBlockSize * 1),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: InkWell(
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          onDoubleTap: () {},
          onTap: () => _onSolutionItemTap(catalogueData),
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 2,
                vertical: AppConfig.horizontalBlockSize * 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.transparent,
                  height: AppConfig.horizontalBlockSize * 14,
                  width: AppConfig.horizontalBlockSize * 14,
                  child: (catalogueData == null ||
                          catalogueData.speciality == null ||
                          catalogueData.speciality!.isEmpty)
                      ? Image.asset(PlunesImages.basicImage,
                          fit: BoxFit.contain)
                      : CustomWidgets().getImageFromUrl(
                          "https://specialities.s3.ap-south-1.amazonaws.com/new-specialization_icons/${catalogueData.speciality}.png",
                          boxFit: BoxFit.contain),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 3),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            catalogueData?.service ?? "",
                            maxLines: 2,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        StreamBuilder<Object?>(
                            stream: _streamController?.stream,
                            builder: (context, snapshot) {
                              if (_getRemainingTimeOfSolutionExpiration(
                                      catalogueData) ==
                                  null) {
                                return Container();
                              }
                              return Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 1),
                                child: Text(
                                  _getRemainingTimeOfSolutionExpiration(
                                      catalogueData)!,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          (_getRemainingTimeOfSolutionExpiration(
                                                          catalogueData) ==
                                                      catalogueData
                                                          ?.expirationMessage ??
                                                  _expirationMessage as bool)
                                              ? Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#CEDD00"))
                                              : Color(
                                                  CommonMethods
                                                      .getColorHexFromStr(
                                                          "#1D3861"))),
                                ),
                              );
                            }),
                        _getDiscoverButton(catalogueData),
                        Container(
                          alignment: Alignment.topLeft,
                          child: (!catalogueData.isActive! &&
                                      catalogueData.maxDiscount != null &&
                                      catalogueData.maxDiscount != 0 &&
                                      (catalogueData.booked == null ||
                                          !catalogueData.booked!)) &&
                                  (_getRemainingTimeOfSolutionExpiration(
                                              catalogueData) ==
                                          catalogueData?.expirationMessage ??
                                      _expirationMessage as bool)
                              ? Container(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 2),
                                  child: Text(
                                    "You have missed ${catalogueData.maxDiscount!.toStringAsFixed(0)}% on your ${catalogueData.service ?? PlunesStrings.NA} Previously",
                                    maxLines: 4,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ))
                              : Container(),
                        ),
                        (catalogueData != null &&
                                ((catalogueData.hasUserReport != null &&
                                        catalogueData.hasUserReport! &&
                                        catalogueData.userReportId != null &&
                                        catalogueData.userReportId!
                                            .trim()
                                            .isNotEmpty) ||
                                    (catalogueData.isServiceChildrenAvailable !=
                                            null &&
                                        catalogueData
                                            .isServiceChildrenAvailable!)) &&
                                (!_isCardExpired(catalogueData)))
                            ? Container(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: InkWell(
                                        focusColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          if (catalogueData != null &&
                                              catalogueData.userReportId !=
                                                  null &&
                                              catalogueData.userReportId!
                                                  .trim()
                                                  .isNotEmpty)
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PreviousActivityReport(
                                                            catalogueData
                                                                .userReportId,
                                                            catalogueData)));
                                        },
                                        onDoubleTap: () {},
                                        child: Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              top: AppConfig.verticalBlockSize *
                                                  1,
                                              bottom:
                                                  AppConfig.verticalBlockSize *
                                                      1,
                                              right:
                                                  AppConfig.verticalBlockSize *
                                                      1),
                                          child: Text(
                                            "View Details",
                                            style: TextStyle(
                                                color: Color(CommonMethods
                                                    .getColorHexFromStr(
                                                        "#01D35A")),
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Container())
                                  ],
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  final String _expirationMessage = "Prices are Expired now, Discover to Book";

  String? _getRemainingTimeOfSolutionExpiration(CatalogueData solution) {
    String timeRemaining = "";
    if (solution.solutionExpiredAt == null) {
      return solution.expirationMessage ?? _expirationMessage;
    } else if (solution.priceDiscovered != null &&
        !solution.priceDiscovered! &&
        solution.isActive != null &&
        solution.isActive!) {
      return null;
    }
    var now = DateTime.now();
    String priceExpireText = "Your prices will expire in ";
    var expireTime =
        DateTime.fromMillisecondsSinceEpoch(solution?.solutionExpiredAt ?? 0);
    var duration = expireTime.difference(now);
    if (duration.inDays > 1) {
      timeRemaining = "$priceExpireText${duration.inDays + 1} days";
    } else if (duration.inHours >= 24) {
      timeRemaining = "$priceExpireText 2 days";
    } else if (duration.inHours > 1) {
      timeRemaining = "$priceExpireText${duration.inHours} hours";
    } else if (duration.inMinutes >= 60) {
      timeRemaining = "$priceExpireText 2 hours";
    } else if (duration.inMinutes > 1) {
      timeRemaining = "$priceExpireText${duration.inMinutes} minutes";
    } else if (duration.inSeconds >= 60) {
      timeRemaining = "$priceExpireText 2 minutes";
    } else if (duration.inSeconds > 1) {
      timeRemaining = "$priceExpireText${duration.inSeconds} seconds";
    } else {
      timeRemaining = solution.expirationMessage ?? _expirationMessage;
    }
    return timeRemaining;
  }

  _isCardExpired(CatalogueData solution) {
    if (solution.solutionExpiredAt == null) {
      return true;
    }
    bool isCardExpired = false;
    var now = DateTime.now();
    var expireTime =
        DateTime.fromMillisecondsSinceEpoch(solution?.solutionExpiredAt ?? 0);
    var duration = expireTime.difference(now);
    if (duration.inSeconds < 1) {
      isCardExpired = true;
    }
    return isCardExpired;
  }

  Widget _getDiscoverButton(CatalogueData catalogueData) {
    String? buttonName = _getDiscoverButtonText(catalogueData);
    return buttonName == null
        ? Container()
        : Container(
            width: double.infinity,
            child: Row(
              children: [
                Flexible(
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () => _onSolutionItemTap(catalogueData),
                    onDoubleTap: () {},
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(
                          top: AppConfig.verticalBlockSize * 1.1),
                      child: Text(
                        buttonName,
                        style: TextStyle(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#01D35A")),
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container())
              ],
            ),
          );
    // Container(
    //         width: double.infinity,
    //         child: Container(
    //           alignment: Alignment.topLeft,
    //           margin: EdgeInsets.only(
    //               right: AppConfig.horizontalBlockSize * 32,
    //               top: AppConfig.verticalBlockSize * 1.1),
    //           child: InkWell(
    //             focusColor: Colors.transparent,
    //             highlightColor: Colors.transparent,
    //             hoverColor: Colors.transparent,
    //             splashColor: Colors.transparent,
    //             onTap: () => _onSolutionItemTap(catalogueData),
    //             onDoubleTap: () {},
    //             child: CustomWidgets().getRoundedButton(
    //                 buttonName,
    //                 AppConfig.horizontalBlockSize * 8,
    //                 PlunesColors.GREENCOLOR,
    //                 AppConfig.horizontalBlockSize * 0,
    //                 AppConfig.verticalBlockSize * 1.5,
    //                 PlunesColors.WHITECOLOR),
    //           ),
    //         ),
    //       );
  }

  String? _getDiscoverButtonText(CatalogueData catalogueData) {
    String? buttonName;
    var nowTime = DateTime.now();
    if (catalogueData.solutionExpiredAt != null &&
        catalogueData.solutionExpiredAt != 0) {
      var solExpireTime =
          DateTime.fromMillisecondsSinceEpoch(catalogueData.solutionExpiredAt!);
      var diff = nowTime.difference(solExpireTime);
      if (diff.inSeconds < 5) {
        if (catalogueData.priceDiscovered != null &&
            catalogueData.priceDiscovered!) {
        } else {
          // buttonName = "Discover Prices";
        }
      } else {
        buttonName = "Discover";
      }
    }
    return buttonName;
  }

  Widget _getTitleWidget() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 4,
          vertical: AppConfig.verticalBlockSize * 1),
      child: Text(
        _prevSearchedSolution?.subTitle ??
            "Prices for your Treatments are Real Time & Valid for 7 Days",
        style: TextStyle(
            fontSize: 18,
            color: Color(CommonMethods.getColorHexFromStr("#111111"))),
      ),
    );
  }
}

// ignore: must_be_immutable
class PreviousActivityReport extends BaseActivity {
  String? userReportId;
  CatalogueData catalogueData;

  PreviousActivityReport(this.userReportId, this.catalogueData);

  @override
  _PreviousActivityReportState createState() => _PreviousActivityReportState();
}

// class _PreviousActivityReportState extends BaseState<PreviousActivityReport> {
class _PreviousActivityReportState extends State<PreviousActivityReport> {
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  PrevMissSolutionBloc? _prevMissSolutionBloc;
  late bool _isProcessing;
  UserReportOuterModel? _userReport;

  String? _failureCause;

  @override
  void initState() {
    if ((widget.catalogueData.hasUserReport == null ||
        !widget.catalogueData.hasUserReport!)) {
      _isProcessing = false;
    } else {
      _isProcessing = true;
    }
    _prevMissSolutionBloc = PrevMissSolutionBloc();
    _getReport();
    super.initState();
  }

  _setState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _prevMissSolutionBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: scaffoldKey,
        appBar:
            widget.getAppBar(context, PlunesStrings.previousActivities, true) as PreferredSizeWidget?,
        body: _isProcessing
            ? CustomWidgets().getProgressIndicator()
            : _getWidgetBody(),
      ),
    );
  }

  void _getReport() {
    if ((widget.catalogueData.hasUserReport == null ||
        !widget.catalogueData.hasUserReport!)) {
      return;
    }
    _failureCause = null;
    if (!_isProcessing) {
      _isProcessing = true;
      _setState();
    }
    _prevMissSolutionBloc!
        .getUserReport(widget.userReportId)
        .then((requestState) {
      if (requestState is RequestSuccess) {
        _userReport = requestState.response;
      } else if (requestState is RequestFailed) {
        _failureCause =
            requestState.failureCause ?? plunesStrings.somethingWentWrong;
      }
      _isProcessing = false;
      _setState();
    });
  }

  Widget _getWidgetBody() {
    return Container(
      color: Color(CommonMethods.getColorHexFromStr("#FAF9F9")),
      margin: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: PlunesColors.WHITECOLOR),
              child: Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      alignment: Alignment.topLeft,
                      child: Text(widget.catalogueData.service ?? "",
                          maxLines: 2,
                          style: const TextStyle(
                              color: PlunesColors.BLACKCOLOR, fontSize: 20))),
                  _getBodyPartsSessionWidget(),
                ],
              ),
            ),
            widget.catalogueData.hasUserReport == null ||
                    !widget.catalogueData.hasUserReport!
                ? Container()
                : (_userReport == null ||
                        _userReport!.success == null ||
                        !_userReport!.success! ||
                        _userReport!.data == null ||
                        _userReport!.data!.additionalDetails == null ||
                        _userReport!.data!.additionalDetails!.isEmpty)
                    ? CustomWidgets().errorWidget(
                        _userReport?.message ?? _failureCause,
                        buttonText: PlunesStrings.refresh,
                        onTap: () => _getReport())
                    : Column(
                        children: [
                          _getAdditionalDetailWidget(),
                          _getPreviousDetailWidget(),
                          _getPhotosWidget(),
                          _getVideoWidget(),
                          _getDocWidget()
                        ],
                      )
          ],
        ),
      ),
    );
  }

  Widget _getBodyPartsSessionWidget() {
    if (widget.catalogueData.serviceChildren == null ||
        widget.catalogueData.serviceChildren!.isEmpty) {
      return Container();
    }
    return Container(
      height: AppConfig.verticalBlockSize * 8,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2,
          top: AppConfig.verticalBlockSize * 2),
      child: ListView.builder(
        itemBuilder: (context, index) {
          var bodyObj = widget.catalogueData.serviceChildren![index];
          if ((bodyObj == null ||
                  bodyObj.bodyPart == null ||
                  bodyObj.bodyPart!.trim().isEmpty) &&
              (bodyObj == null ||
                  bodyObj.sessionGrafts == null ||
                  bodyObj.sessionGrafts!.trim().isEmpty)) {
            return Container();
          }
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              border: Border.all(
                  color: PlunesColors.GREYCOLOR.withOpacity(0.6), width: 0.8),
              color: PlunesColors.WHITECOLOR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (bodyObj != null &&
                        bodyObj.bodyPart != null &&
                        bodyObj.bodyPart!.trim().isNotEmpty)
                    ? Container(
                        margin: EdgeInsets.only(right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Body Part",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: PlunesColors.BLACKCOLOR)),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: Text(
                                bodyObj.bodyPart ?? "",
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: PlunesColors.BLACKCOLOR),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                (bodyObj != null &&
                        bodyObj.sessionGrafts != null &&
                        bodyObj.sessionGrafts!.trim().isNotEmpty)
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Session",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: PlunesColors.BLACKCOLOR)),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: Text(
                              "* ${bodyObj.sessionGrafts!}",
                              style: const TextStyle(
                                  fontSize: 18, color: PlunesColors.BLACKCOLOR),
                            ),
                          )
                        ],
                      )
                    : Container(),
              ],
            ),
          );
        },
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.catalogueData.serviceChildren!.length,
      ),
    );
  }

  Widget _getAdditionalDetailWidget() {
    return (_userReport!.data!.additionalDetails == null ||
            _userReport!.data!.additionalDetails!.trim().isEmpty)
        ? Container()
        : Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: PlunesColors.WHITECOLOR),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("Additional Details for the required service",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18, color: PlunesColors.BLACKCOLOR)),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8),
                  child: Text(_userReport!.data!.additionalDetails ?? "",
                      style: const TextStyle(
                          fontSize: 16, color: PlunesColors.BLACKCOLOR)),
                ),
              ],
            ),
          );
  }

  Widget _getPreviousDetailWidget() {
    return (_userReport!.data!.description == null ||
            _userReport!.data!.description!.trim().isEmpty)
        ? Container()
        : Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: PlunesColors.WHITECOLOR),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("Condition of previous treatment",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18, color: PlunesColors.BLACKCOLOR)),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 8),
                  child: Text(_userReport!.data!.description ?? "",
                      style: const TextStyle(
                          fontSize: 16, color: PlunesColors.BLACKCOLOR)),
                ),
              ],
            ),
          );
  }

  Widget _getPhotosWidget() {
    return (_userReport!.data!.imageUrl == null ||
            _userReport!.data!.imageUrl!.isEmpty)
        ? Container()
        : Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: PlunesColors.WHITECOLOR),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("Photos",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18, color: PlunesColors.BLACKCOLOR)),
                ),
                Container(
                  height: AppConfig.verticalBlockSize * 27,
                  margin: EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          List<Photo> photos = [];
                          _userReport!.data!.imageUrl!.forEach((picData) {
                            var element = picData?.imageUrl;
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
                                        PageSlider(photos, index)));
                          }
                        },
                        onDoubleTap: () {},
                        child: Container(
                          margin: EdgeInsets.only(
                              right: AppConfig.horizontalBlockSize * 1.5),
                          child: ClipRRect(
                            child: CustomWidgets().getImageFromUrl(
                                _userReport!.data!.imageUrl![index].imageUrl,
                                boxFit: BoxFit.fill),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          height: AppConfig.verticalBlockSize * 26,
                          width: AppConfig.horizontalBlockSize * 88,
                        ),
                      );
                    },
                    itemCount: _userReport!.data!.imageUrl?.length ?? 0,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _getVideoWidget() {
    return (_userReport!.data!.videoUrl == null ||
            _userReport!.data!.videoUrl!.isEmpty)
        ? Container()
        : Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: PlunesColors.WHITECOLOR),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("Video",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18, color: PlunesColors.BLACKCOLOR)),
                ),
                Container(
                  height: AppConfig.verticalBlockSize * 27,
                  margin: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () {
                      if (_userReport!.data!.videoUrl!.first.videoUrl != null &&
                          _userReport!.data!.videoUrl!.first.videoUrl!
                              .trim()
                              .isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoUtil(
                                    _userReport!.data!.videoUrl!.first.videoUrl)));
                      } else {
                        _showSnackBar(PlunesStrings.unableToPlayVideo);
                      }
                    },
                    onDoubleTap: () {},
                    child: Stack(
                      children: [
                        Container(
                          child: ClipRRect(
                            child: CustomWidgets().getImageFromUrl(
                                _userReport!.data!.videoUrl?.first?.thumbnail ??
                                    '',
                                boxFit: BoxFit.fitWidth),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                  ),
                ),
              ],
            ),
          );
  }

  Widget _getDocWidget() {
    return (_userReport!.data!.reportUrl == null ||
            _userReport!.data!.reportUrl!.isEmpty)
        ? Container()
        : Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: PlunesColors.WHITECOLOR),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Report",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18, color: PlunesColors.BLACKCOLOR)),
                ),
                InkWell(
                  onTap: () {
                    if (_userReport!.data!.reportUrl!.first.reportUrl != null &&
                        _userReport!.data!.reportUrl!.first.reportUrl!
                            .trim()
                            .isNotEmpty) {
                      LauncherUtil.launchUrl(
                          _userReport!.data!.reportUrl!.first!.reportUrl!);
                    }
                    return;
                  },
                  onDoubleTap: () {},
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: AppConfig.verticalBlockSize * 27,
                    child: Container(
                      child: ClipRRect(
                        child: Container(
                          color: Colors.grey.withOpacity(0.7),
                          child: Image.asset(
                            plunesImages.pdfIcon1,
                            fit: BoxFit.contain,
                          ),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: AppConfig.verticalBlockSize * 26,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          );
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
}
