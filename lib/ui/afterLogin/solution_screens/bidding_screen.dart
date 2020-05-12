import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/consultations.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/testNproceduresMainScreen.dart';

// ignore: must_be_immutable
class SolutionBiddingScreen extends BaseActivity {
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
    Future.delayed(Duration(milliseconds: 450)).then((v) {
      if (mounted) FocusScope.of(context).requestFocus(_focusNode);
    });
    _searchSolutionBloc = SearchSolutionBloc();
    _streamController = StreamController();
    _searchController = TextEditingController()..addListener(_onSearch);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: PlunesColors.WHITECOLOR,
          appBar:
              widget.getAppBar(context, PlunesStrings.solutionSearched, true),
          body: Builder(builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize*3),
              width: double.infinity,
              child: _showBody(),
            );
          }),
        ));
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        StreamBuilder(
          builder: (context, snapShot) {
            return Container(
                margin: EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize*2),
                child:CustomWidgets().searchBar(
                hintText: plunesStrings.searchHint,
                hasFocus: true,
                searchController: _searchController));
          },
          stream: _streamController.stream,
        ),
        widget.getSpacer(
            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
        Container(
          padding: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 3,
              right: AppConfig.horizontalBlockSize * 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CustomWidgets().rectangularButtonWithPadding(
                  buttonColor: PlunesColors.WHITECOLOR,
                  buttonText: PlunesStrings.consultations,
                  textColor: PlunesColors.GREYCOLOR,
                  borderColor: PlunesColors.LIGHTGREYCOLOR,
                  horizontalPadding: AppConfig.horizontalBlockSize * 4,
                  verticalPadding: AppConfig.verticalBlockSize * 1,
                  onTap: () => _onConsultationButtonClick()),
              CustomWidgets().rectangularButtonWithPadding(
                  buttonColor: PlunesColors.WHITECOLOR,
                  buttonText: PlunesStrings.tests,
                  textColor: PlunesColors.GREYCOLOR,
                  borderColor: PlunesColors.LIGHTGREYCOLOR,
                  horizontalPadding: AppConfig.horizontalBlockSize * 11,
                  verticalPadding: AppConfig.verticalBlockSize * 1,
                  onTap: () => _onTestAndProcedureButtonClick(
                      PlunesStrings.tests, false)),
              CustomWidgets().rectangularButtonWithPadding(
                  buttonColor: PlunesColors.WHITECOLOR,
                  buttonText: PlunesStrings.procedures,
                  textColor: PlunesColors.GREYCOLOR,
                  borderColor: PlunesColors.LIGHTGREYCOLOR,
                  horizontalPadding: AppConfig.horizontalBlockSize * 5,
                  verticalPadding: AppConfig.verticalBlockSize * 1,
                  onTap: () => _onTestAndProcedureButtonClick(
                      PlunesStrings.procedures, true)),
            ],
          ),
        ),
        widget.getSpacer(
            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
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
                ? Text(PlunesStrings.noSolutionsAvailable)
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: _showSearchedItems(),
                        flex: 4,
                      ),
                      snapShot.data is RequestInProgress
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

  _onSolutionItemTap(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BiddingLoading(
                  catalogueData: _catalogues[index],
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
}
