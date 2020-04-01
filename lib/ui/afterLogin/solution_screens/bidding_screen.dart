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

// ignore: must_be_immutable
class SolutionBiddingScreen extends BaseActivity {
  @override
  _SolutionBiddingScreenState createState() => _SolutionBiddingScreenState();
}

class _SolutionBiddingScreenState extends BaseState<SolutionBiddingScreen> {
  List<SolutionDummyModel> _solutions = [SolutionDummyModel()];
  List<CatalougeData> _catlouges;
  Function onViewMoreTap;
  TextEditingController _searchController;
  Timer _debounce;
  SearchSolutionBloc _searchSolutionBloc;

  @override
  void initState() {
    _catlouges = [];
    _searchSolutionBloc = SearchSolutionBloc();
    _searchController = TextEditingController()..addListener(_onSearch);
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearch);
    _searchController?.dispose();
    _debounce?.cancel();
    _searchSolutionBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar:
              widget.getAppBar(context, PlunesStrings.solutionSearched, true),
          body: Builder(builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 6,
                  vertical: AppConfig.verticalBlockSize * 3),
              width: double.infinity,
              child: _showBody(),
            );
          }),
        ));
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        CustomWidgets().searchBar(
            hintText: plunesStrings.searchHint,
            hasFocus: true,
            searchController: _searchController),
        widget.getSpacer(
            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
        Container(
          padding: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 0.2,
              right: AppConfig.horizontalBlockSize * 0.2),
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
                  horizontalPadding: AppConfig.horizontalBlockSize * 4,
                  verticalPadding: AppConfig.verticalBlockSize * 1,
                  onTap: () => _onTestButtonClick()),
              CustomWidgets().rectangularButtonWithPadding(
                  buttonColor: PlunesColors.WHITECOLOR,
                  buttonText: PlunesStrings.procedures,
                  textColor: PlunesColors.GREYCOLOR,
                  borderColor: PlunesColors.LIGHTGREYCOLOR,
                  horizontalPadding: AppConfig.horizontalBlockSize * 4,
                  verticalPadding: AppConfig.verticalBlockSize * 1,
                  onTap: () => _onProcedureButtonClick()),
            ],
          ),
        ),
        widget.getSpacer(
            AppConfig.verticalBlockSize * 1, AppConfig.verticalBlockSize * 1),
        Expanded(
            child: StreamBuilder<RequestState>(
          builder: (context, snapShot) {
            print("hello ${snapShot.runtimeType}");
            if (snapShot.data is RequestSuccess) {
              RequestSuccess _requestSuccessObject = snapShot.data;
              if (_requestSuccessObject.requestCode ==
                  SearchSolutionBloc.initialIndex) {
                _catlouges = [];
              }
              Set _allItems = _catlouges.toSet();
              _allItems.addAll(_requestSuccessObject.response);
              _catlouges = _allItems.toList(growable: true);
              print("success occurred ${_catlouges.length}");
            } else if (snapShot.data is RequestFailed) {
              print("request failed occur ${snapShot.data.toString()}");
            }
            print("snap shot occr ${_catlouges.length}");
            return _catlouges == null || _catlouges.isEmpty
                ? Text("null")
                : _showSearchedItems();
          },
          stream: _searchSolutionBloc.baseStream,
        ))
      ],
    );
  }

  _onConsultationButtonClick() {
    print("sdsdssdsds");
  }

  _onTestButtonClick() {}

  _onProcedureButtonClick() {}

  _onSolutionItemTap(int index) {
    print("whole button tapped");
  }

  _onViewMoreTap(int solution) {
    print("index is $solution");
  }

  _onSearch() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_searchController != null &&
          _searchController.text != null &&
          _searchController.text.isNotEmpty) {
        print("Text is ${_searchController.text}");
        _searchSolutionBloc.getSearchedSolution(
            searchedString: _searchController.text.toString(), index: 0);
      } else {
        print("text is empty");
      }
    });
  }

  Widget _showSearchedItems() {
    return ListView.builder(
      itemBuilder: (context, index) {
        TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
          ..onTap = () => _onViewMoreTap(index);
        return CustomWidgets().getSolutionRow(_catlouges, index,
            onButtonTap: () => _onSolutionItemTap(index),
            onViewMoreTap: tapRecognizer);
      },
      itemCount: _catlouges.length,
    );
  }
}

class SolutionDummyModel {
  String fileUrl =
      "https://plunes.co/v4/data/5e6cda3106e6765a2d08ce24_1584192397080.jpg";
  String heading = "Dentist Consultation";
  String procedure = "Procedure";
  String subTitleText = "Do tests under plunes ,lorem ispum ";
}
