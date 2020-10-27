import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/consultations.dart';
import 'package:plunes/ui/afterLogin/solution_screens/manual_bidding.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/testNproceduresMainScreen.dart';

// ignore: must_be_immutable
class SolutionBiddingScreen extends BaseActivity {
  final String searchQuery;

  SolutionBiddingScreen({this.searchQuery});

  @override
  _SolutionBiddingScreenState createState() => _SolutionBiddingScreenState();
}

class _SolutionBiddingScreenState extends BaseState<SolutionBiddingScreen> {
  List<CatalogueData> _catalogues;
  Function onViewMoreTap;
  TextEditingController _searchController;
  Timer _debounce;
  SearchSolutionBloc _searchSolutionBloc;
  int pageIndex = SearchSolutionBloc.initialIndex;
  StreamController _streamController;
  bool _endReached;
  FocusNode _focusNode;

  @override
  void initState() {
    _catalogues = [];
    _endReached = false;
    _focusNode = FocusNode();
    _searchSolutionBloc = SearchSolutionBloc();
    _streamController = StreamController.broadcast();
    _searchController = TextEditingController()..addListener(_onSearch);
    if (widget.searchQuery != null && widget.searchQuery.trim().isNotEmpty) {
      _searchController.text = widget.searchQuery;
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearch);
    _searchController?.dispose();
    _debounce?.cancel();
    _searchSolutionBloc?.dispose();
    _streamController?.close();
    super.dispose();
  }

  _unFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: WillPopScope(
        onWillPop: () async {
          _unFocus();
          return true;
        },
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: PlunesColors.WHITECOLOR,
          appBar: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              brightness: Brightness.light,
              iconTheme: IconThemeData(color: Colors.black),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  _unFocus();
                  Future.delayed(Duration(milliseconds: 5)).then((value) {
                    Navigator.pop(context, false);
                  });
                },
              ),
              title: widget.createTextViews(PlunesStrings.solutionSearched, 18,
                  colorsFile.black, TextAlign.center, FontWeight.w500)),
          body: Builder(builder: (context) {
            return Container(
              color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
              padding: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 3),
              width: double.infinity,
              child: _showBody(),
            );
          }),
        ),
      ),
    );
  }

  Widget _showBody() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            StreamBuilder(
              builder: (context, snapShot) {
                return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 2),
                    child: CustomWidgets().searchBar(
                        hintText: plunesStrings.searchHint,
                        hasFocus: true,
                        searchController: _searchController));
              },
              stream: _streamController.stream,
            ),
            widget.getSpacer(AppConfig.verticalBlockSize * 1,
                AppConfig.verticalBlockSize * 1),
            Container(
              padding: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 3,
                  right: AppConfig.horizontalBlockSize * 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: CustomWidgets().rectangularButtonWithPadding(
                        buttonColor: PlunesColors.WHITECOLOR,
                        buttonText: PlunesStrings.consultations,
                        textColor: PlunesColors.GREYCOLOR,
                        borderColor: PlunesColors.LIGHTGREYCOLOR,
                        horizontalPadding: AppConfig.horizontalBlockSize * 4,
                        verticalPadding: AppConfig.verticalBlockSize * 1,
                        onTap: () => _onConsultationButtonClick()),
                  ),
                  Expanded(
                    child: CustomWidgets().rectangularButtonWithPadding(
                        buttonColor: PlunesColors.WHITECOLOR,
                        buttonText: PlunesStrings.tests,
                        textColor: PlunesColors.GREYCOLOR,
                        borderColor: PlunesColors.LIGHTGREYCOLOR,
                        horizontalPadding: AppConfig.horizontalBlockSize * 11,
                        verticalPadding: AppConfig.verticalBlockSize * 1,
                        onTap: () => _onTestAndProcedureButtonClick(
                            PlunesStrings.tests, false)),
                  ),
                  Expanded(
                    child: CustomWidgets().rectangularButtonWithPadding(
                        buttonColor: PlunesColors.WHITECOLOR,
                        buttonText: PlunesStrings.procedures,
                        textColor: PlunesColors.GREYCOLOR,
                        borderColor: PlunesColors.LIGHTGREYCOLOR,
                        horizontalPadding: AppConfig.horizontalBlockSize * 5,
                        verticalPadding: AppConfig.verticalBlockSize * 1,
                        onTap: () => _onTestAndProcedureButtonClick(
                            PlunesStrings.procedures, true)),
                  ),
                ],
              ),
            ),
            widget.getSpacer(AppConfig.verticalBlockSize * 1,
                AppConfig.verticalBlockSize * 1),
            Expanded(
                child: StreamBuilder<RequestState>(
              builder: (context, snapShot) {
                if (snapShot.data is RequestSuccess) {
                  RequestSuccess _requestSuccessObject = snapShot.data;
                  if (_requestSuccessObject.requestCode ==
                      SearchSolutionBloc.initialIndex) {
                    pageIndex = SearchSolutionBloc.initialIndex;
                    _catalogues = [];
                  }
                  if (_requestSuccessObject.requestCode !=
                          SearchSolutionBloc.initialIndex &&
                      _requestSuccessObject.response.isEmpty) {
                    _endReached = true;
                  } else {
                    _endReached = false;
                    Set _allItems = _catalogues.toSet();
                    _allItems.addAll(_requestSuccessObject.response);
                    _catalogues = _allItems.toList(growable: true);
                  }
                  pageIndex++;
                } else if (snapShot.data is RequestFailed) {
                  pageIndex = SearchSolutionBloc.initialIndex;
                }
                return _catalogues == null || _catalogues.isEmpty
                    ? _getDefaultWidget(snapShot)
                    : Column(
                        children: <Widget>[
                          Expanded(
                            child: _showSearchedItems(),
                            flex: 4,
                          ),
                          (snapShot.data is RequestInProgress &&
                                  (_catalogues != null &&
                                      _catalogues.isNotEmpty))
                              ? Expanded(
                                  child: CustomWidgets().getProgressIndicator(),
                                  flex: 1,
                                )
                              : Container()
                        ],
                      );
              },
              stream: _searchSolutionBloc.baseStream,
            ))
          ],
        ),
        Positioned(
          child: StreamBuilder<Object>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if ((_searchController != null &&
                    _searchController.text != null &&
                    _searchController.text.trim().isNotEmpty &&
                    _catalogues != null &&
                    _catalogues.isNotEmpty)) {
                  return _getManualBiddingWidget();
                }
                return Container();
              }),
          bottom: 0.0,
          right: 0,
          left: 0,
        )
      ],
    );
  }

  _onConsultationButtonClick() {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => ConsultationScreen()));
  }

  _onTestAndProcedureButtonClick(String title, bool isProcedure) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestAndProcedureScreen(
                  screenTitle: title,
                  isProcedure: isProcedure,
                )));
  }

  _onSolutionItemTap(int index) async {
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
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BiddingLoading(
                  catalogueData: _catalogues[index],
                  searchQuery: _searchController.text.trim(),
                )));
  }

  _onViewMoreTap(int solution) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
        catalogueData: _catalogues[solution],
      ),
    );
  }

  _onSearch() {
    _streamController.add(null);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController != null &&
          _searchController.text != null &&
          _searchController.text.trim().isNotEmpty) {
        _searchSolutionBloc.addIntoStream(RequestInProgress());
        _searchSolutionBloc.getSearchedSolution(
            searchedString: _searchController.text.trim().toString(), index: 0);
      } else {
        _catalogues = [];
        _searchSolutionBloc.addState(null);
      }
    });
  }

  Widget _showSearchedItems() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollState) {
        if (scrollState is ScrollEndNotification &&
            scrollState.metrics.extentAfter == 0 &&
            _searchController.text.trim().isNotEmpty &&
            !_endReached) {
          _searchSolutionBloc.addIntoStream(RequestInProgress());
          _searchSolutionBloc.getSearchedSolution(
              searchedString: _searchController.text.trim().toString(),
              index: pageIndex);
        }
        return;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
            ..onTap = () => _onViewMoreTap(index);
          return CustomWidgets().getSolutionRow(_catalogues, index,
              onButtonTap: () => _onSolutionItemTap(index),
              onViewMoreTap: tapRecognizer);
        },
        shrinkWrap: true,
        itemCount: _catalogues.length,
      ),
    );
  }

  Widget _getDefaultWidget(AsyncSnapshot<RequestState> snapshot) {
    return snapshot.data is RequestInProgress
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SpinKitThreeBounce(
                  color: Color(hexColorCode.defaultGreen), size: 30.0),
              Expanded(child: Container())
            ],
          )
        : ((_catalogues == null || _catalogues.isEmpty) &&
                _searchController.text.trim().isNotEmpty)
            ? _getManualBiddingWidget()
            : Text(PlunesStrings.searchSolutions);
  }

  Widget _getManualBiddingWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                PlunesStrings.couldNotFindText,
                style: TextStyle(
                    color: PlunesColors.BLACKCOLOR,
                    fontSize: 17.5,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ),
            color: Color(CommonMethods.getColorHexFromStr("#D8F1E2")),
            padding: EdgeInsets.all(10),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManualBidding()));
            },
            child: Container(
              child: Center(
                child: Text(
                  PlunesStrings.negotiateManually,
                  style: TextStyle(
                      color: PlunesColors.SPARKLINGGREEN,
                      fontSize: 17.5,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
              color: PlunesColors.WHITECOLOR,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 2),
            ),
          ),
        ],
      ),
    );
  }
}
