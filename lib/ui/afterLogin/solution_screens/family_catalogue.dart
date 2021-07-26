import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';

// ignore: must_be_immutable
class CatalogueListScreen extends BaseActivity {
  CatalogueData catalogueData;

  CatalogueListScreen(this.catalogueData);

  @override
  _CatalogueListScreenState createState() => _CatalogueListScreenState();
}

class _CatalogueListScreenState extends BaseState<CatalogueListScreen> {
  List<CatalogueData> _catalogues;
  SearchSolutionBloc _searchSolutionBloc;
  bool _isProcessing;
  String _failureCause;

  @override
  void initState() {
    _isProcessing = true;
    _searchSolutionBloc = SearchSolutionBloc();
    _getCatalogueUsingFamilyId();
    super.initState();
  }

  @override
  void dispose() {
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
          appBar: widget.getAppBar(
              context, widget.catalogueData.familyName ?? "", true),
          body: _isProcessing
              ? CustomWidgets().getProgressIndicator()
              : (_catalogues == null || _catalogues.isEmpty)
                  ? CustomWidgets().errorWidget(
                      _failureCause ?? "Catalogue not found!",
                      onTap: () => _getCatalogueUsingFamilyId())
                  : _getBody(),
        ));
  }

  Widget _getBody() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: _getCatalogueListWidget(),
    );
  }

  Widget _getCatalogueListWidget() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
          ..onTap = () => _onViewMoreTap(index);
        return CustomWidgets().getSolutionRow(_catalogues, index,
            onButtonTap: () => _onSolutionItemTap(index),
            onViewMoreTap: tapRecognizer);
      },
      itemCount: _catalogues.length ?? 0,
    );
  }

  _onViewMoreTap(int solution) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
        catalogueData: _catalogues[solution],
      ),
    );
  }

  _onSolutionItemTap(int index) async {
    var nowTime = DateTime.now();
    if (_catalogues[index].solutionExpiredAt != null &&
        _catalogues[index].solutionExpiredAt != 0) {
      var solExpireTime = DateTime.fromMillisecondsSinceEpoch(
          _catalogues[index].solutionExpiredAt);
      var diff = nowTime.difference(solExpireTime);
      if (diff.inSeconds < 5) {
        ///when price discovered and solution is active
        if (_catalogues[index].priceDiscovered != null &&
            _catalogues[index].priceDiscovered) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SolutionShowPriceScreen(
                      catalogueData: _catalogues[index], searchQuery: "")));
          return;
        } else {
          ///when price not discovered but solution is active
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewSolutionsScreen(
                      catalogueData: _catalogues[index], searchQuery: "")));
          return;
        }
      }
    }
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterAdditionalUserDetailScr(
                _catalogues[index], widget.catalogueData.familyName)));
  }

  _setState() {
    if (mounted) setState(() {});
  }

  void _getCatalogueUsingFamilyId() {
    if (_isProcessing == null || !(_isProcessing)) {
      _isProcessing = true;
      _setState();
    }
    _searchSolutionBloc
        .getCatalogueUsingFamilyId(widget.catalogueData.familyName)
        .then((value) {
      if (value is RequestSuccess) {
        _catalogues = value.response;
      } else if (value is RequestFailed) {
        _failureCause = value.failureCause;
      }
      _isProcessing = false;
      _setState();
    });
  }
}
