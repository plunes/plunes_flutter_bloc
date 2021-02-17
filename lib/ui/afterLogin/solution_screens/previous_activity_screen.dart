import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/prev_missed_solution_bloc.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/Utils/app_config.dart';

// ignore: must_be_immutable
class PreviousActivity extends BaseActivity {
  @override
  _PreviousActivityState createState() => _PreviousActivityState();
}

class _PreviousActivityState extends BaseState<PreviousActivity> {
  PrevMissSolutionBloc _prevMissSolutionBloc;
  PrevSearchedSolution _prevSearchedSolution;
  List<CatalogueData> _prevSolutions = [], _missedSolutions = [];
  String _failureCause;
  bool _isProcessing;
  StreamController _streamController;
  Timer _timerForTimeUpdation;
  CartMainBloc _cartBloc;

  @override
  void initState() {
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
    super.initState();
  }

  void _getCartCount() {
    _cartBloc.getCartCount();
  }

  @override
  void dispose() {
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
      body: _isProcessing
          ? CustomWidgets().getProgressIndicator()
          : (_failureCause != null && _failureCause == PlunesStrings.noInternet)
              ? CustomWidgets().errorWidget(_failureCause,
                  buttonText: PlunesStrings.refresh,
                  onTap: () => _getPreviousSolutions())
              : _getWidgetBody(),
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
            margin: EdgeInsets.all(0.0),
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (_prevSearchedSolution == null ||
                          _prevSearchedSolution.data == null ||
                          _prevSearchedSolution.data.isEmpty ||
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
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0.0),
                            itemBuilder: (context, index) {
                              if ((_prevSolutions[index].topSearch != null &&
                                      _prevSolutions[index].topSearch) ||
                                  (_prevSolutions[index].toShowSearched !=
                                          null &&
                                      _prevSolutions[index].toShowSearched)) {
                                return Container();
                              }
                              return _getPreviousActivityCard(
                                  _prevSolutions[index]);
                            },
                            itemCount: _prevSolutions?.length ?? 0,
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
    _prevMissSolutionBloc.getPreviousSolutions().then((requestState) {
      if (requestState is RequestSuccess) {
        _prevSearchedSolution = requestState.response;
        if (_prevSearchedSolution != null &&
            _prevSearchedSolution.data != null &&
            _prevSearchedSolution.data.isNotEmpty) {
          _prevSolutions = [];
          _missedSolutions = [];
          _prevSearchedSolution.data.forEach((solution) {
            // if (solution.isActive == false) {
            //   _missedSolutions.add(solution);
            // } else {
            _prevSolutions.add(solution);
            // }
          });
        }
      } else if (requestState is RequestFailed) {
        _failureCause =
            requestState.failureCause ?? plunesStrings.somethingWentWrong;
      }
      _isProcessing = false;
      _setState();
    });
  }

  _onSolutionItemTap(CatalogueData catalogueData) async {
    catalogueData.isFromNotification = true;
    var nowTime = DateTime.now();
    if (catalogueData.solutionExpiredAt != null &&
        catalogueData.solutionExpiredAt != 0) {
      var solExpireTime =
          DateTime.fromMillisecondsSinceEpoch(catalogueData.solutionExpiredAt);
      var diff = nowTime.difference(solExpireTime);
      if (diff.inSeconds < 5) {
        ///when price discovered and solution is active
        if (catalogueData.priceDiscovered != null &&
            catalogueData.priceDiscovered) {
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
              builder: (context) => ViewSolutionsScreen(
                  catalogueData: catalogueData, searchQuery: "")));
      _getPreviousSolutions();
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getPreviousActivityCard(CatalogueData catalogueData) {
    return Card(
        elevation: 5.0,
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 4,
            vertical: AppConfig.verticalBlockSize * 1),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: InkWell(
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
                          catalogueData.speciality.isEmpty)
                      ? Image.asset(PlunesImages.basicImage,
                          fit: BoxFit.contain)
                      : CustomWidgets().getImageFromUrl(
                          "https://specialities.s3.ap-south-1.amazonaws.com/${catalogueData.speciality}.png",
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
                        // Container(
                        //   alignment: Alignment.topLeft,
                        //   child: (catalogueData.createdAt == null ||
                        //           catalogueData.createdAt == 0)
                        //       ? Container()
                        //       : Text(
                        //           DateUtil.getDuration(catalogueData.createdAt),
                        //           style: TextStyle(
                        //               fontSize: 14,
                        //               color: PlunesColors.GREYCOLOR)),
                        // ),
                        StreamBuilder<Object>(
                            stream: _streamController?.stream,
                            builder: (context, snapshot) {
                              return Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 1),
                                child: Text(
                                  _getRemainingTimeOfSolutionExpiration(
                                      catalogueData),
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          (_getRemainingTimeOfSolutionExpiration(
                                                          catalogueData) ==
                                                      catalogueData
                                                          ?.expirationMessage ??
                                                  _expirationMessage)
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
                        Container(
                          alignment: Alignment.topLeft,
                          child: (!(catalogueData.isActive) &&
                                      catalogueData.maxDiscount != null &&
                                      catalogueData.maxDiscount != 0 &&
                                      (catalogueData.booked == null ||
                                          !(catalogueData.booked))) &&
                                  ((_getRemainingTimeOfSolutionExpiration(
                                              catalogueData) ==
                                          catalogueData?.expirationMessage ??
                                      _expirationMessage))
                              ? Container(
                                  padding: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 2),
                                  child: Text(
                                    "You have missed ${catalogueData.maxDiscount.toStringAsFixed(0)}% on your ${catalogueData.service ?? PlunesStrings.NA} Previously",
                                    maxLines: 4,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ))
                              : Container(),
                        ),
                        InkWell(
                          onTap: () {
                            if (catalogueData != null &&
                                catalogueData.userReportId != null &&
                                catalogueData.userReportId.trim().isNotEmpty)
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PreviousActivityReport(
                                              catalogueData.userReportId)));
                          },
                          onDoubleTap: () {},
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(
                                top: AppConfig.verticalBlockSize * 1,
                                bottom: AppConfig.verticalBlockSize * 1,
                                right: AppConfig.verticalBlockSize * 1),
                            child: Text(
                              "View Details",
                              style: TextStyle(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#01D35A")),
                                  fontSize: 16),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  final String _expirationMessage = "Your card is expired";

  String _getRemainingTimeOfSolutionExpiration(CatalogueData solution) {
    String timeRemaining = "";
    if (solution.solutionExpiredAt == null) {
      return solution.expirationMessage ?? _expirationMessage;
    }
    var now = DateTime.now();
    String priceExpireText = "Your prices will expire in ";
    var expireTime =
        DateTime.fromMillisecondsSinceEpoch(solution?.solutionExpiredAt ?? 0);
    var duration = expireTime.difference(now);
    if (duration.inDays > 1) {
      timeRemaining = "$priceExpireText${duration.inDays} days";
    } else if (duration.inHours > 1) {
      timeRemaining = "$priceExpireText${duration.inHours} hours";
    } else if (duration.inMinutes > 1) {
      timeRemaining = "$priceExpireText${duration.inMinutes} minutes";
    } else if (duration.inSeconds > 1) {
      timeRemaining = "$priceExpireText${duration.inSeconds} seconds";
    } else {
      timeRemaining = solution.expirationMessage ?? _expirationMessage;
    }
    return timeRemaining;
  }
}

// ignore: must_be_immutable
class PreviousActivityReport extends BaseActivity {
  String userReportId;

  PreviousActivityReport(this.userReportId);

  @override
  _PreviousActivityReportState createState() => _PreviousActivityReportState();
}

class _PreviousActivityReportState extends BaseState<PreviousActivityReport> {
  PrevMissSolutionBloc _prevMissSolutionBloc;
  bool _isProcessing;
  UserReportOuterModel _userReport;

  String _failureCause;

  @override
  void initState() {
    _isProcessing = true;
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
    return Scaffold(
      appBar: widget.getAppBar(context, PlunesStrings.previousActivities, true),
      body: _isProcessing
          ? CustomWidgets().getProgressIndicator()
          : (_userReport == null ||
                  _userReport.success == null ||
                  !(_userReport.success) ||
                  _userReport.data == null ||
                  _userReport.data.additionalDetails == null ||
                  _userReport.data.additionalDetails.isEmpty)
              ? CustomWidgets().errorWidget(
                  _userReport?.message ?? _failureCause,
                  buttonText: PlunesStrings.refresh,
                  onTap: () => _getReport())
              : _getWidgetBody(),
    );
  }

  void _getReport() {
    _failureCause = null;
    if (!_isProcessing) {
      _isProcessing = true;
      _setState();
    }
    _prevMissSolutionBloc
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
    return Container();
  }
}
