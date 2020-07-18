import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class MoreFacilityScreen extends BaseActivity {
  @override
  _MoreFacilityScreenState createState() => _MoreFacilityScreenState();
}

class _MoreFacilityScreenState extends BaseState<MoreFacilityScreen> {
  TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar:
                widget.getAppBar(context, PlunesStrings.moreFacilities, true),
            body: Builder(builder: (context) {
              return _getBody();
            })));
  }

  Widget _getBody() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 5),
      child: Column(
        children: <Widget>[
          _getUpperImageAndText(),
          _getSearchBar(),
          _showResultsFromBackend()
        ],
      ),
    );
  }

  Widget _getUpperImageAndText() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 3)),
          Text(
            PlunesStrings.congrats,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Padding(padding: EdgeInsets.only(top: 3)),
          Text(
            PlunesStrings.negotiateWithFiveMore,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.normal,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshot) {
          return CustomWidgets().searchBar(
              searchController: _searchController,
              hintText: PlunesStrings.searchFacilities);
        });
  }

  Widget _showResultsFromBackend() {
    return Expanded(
        child: Column(
      children: <Widget>[
        Text(PlunesStrings.chooseFacilities),
        ListView.builder(itemBuilder: (context, index) {
          return CustomWidgets().getMoreFacilityWidget();
        })
      ],
    ));
  }
}
