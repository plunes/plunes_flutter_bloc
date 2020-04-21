import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/doc_hos_bloc/catalogue_service_bloc.dart';
import 'package:plunes/models/doc_hos_models/common_models/catalogue_service_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class CatalogueViewScreen extends BaseActivity {
  @override
  _CatalogueViewScreenState createState() => _CatalogueViewScreenState();
}

class _CatalogueViewScreenState extends BaseState<CatalogueViewScreen> {
  CatalogueServiceBloc _catalogueServiceBloc;
  CatalogueServiceModel _catalogueServiceData;
  String _errorMessage;
  String _selectedSpeciality;
  List<DocServiceCatalogue> _catalogueList;
  List<String> _variances = ["45", "35", "25", "0"];
  List<TextEditingController> _priceList;
  List<String> __varianceInputs;
  bool _isEditModeEnabled;

  @override
  void initState() {
    _isEditModeEnabled = false;
    _priceList = [];
    _catalogueList = [];
    __varianceInputs = [];
    _catalogueServiceBloc = CatalogueServiceBloc();
    _getServicesData();
    super.initState();
  }

  @override
  void dispose() {
    _catalogueServiceBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, plunesStrings.catalogue, true),
          body: Builder(builder: (context) {
            return Container(
              child: StreamBuilder<RequestState>(
                builder: (context, snapShot) {
                  if (snapShot.data is RequestSuccess) {
                    RequestSuccess _successObject = snapShot.data;
                    _catalogueServiceData = _successObject.response;
                    _catalogueServiceBloc.addIntoStream(null);
                  } else if (snapShot.data is RequestFailed) {
                    RequestFailed _failedObject = snapShot.data;
                    _errorMessage = _failedObject.failureCause;
                    _catalogueServiceBloc.addIntoStream(null);
                  }
                  if (snapShot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  return (_errorMessage != null && _errorMessage.isNotEmpty)
                      ? CustomWidgets().errorWidget(_errorMessage)
                      : _getBodyView();
                },
                initialData: _hasNoData() ? RequestInProgress() : null,
                stream: _catalogueServiceBloc.baseStream,
              ),
            );
          }),
        ));
  }

  void _getServicesData() {
    _catalogueServiceBloc.getServiceCatalogues();
  }

  bool _hasNoData() {
    return (_catalogueServiceData == null ||
        _catalogueServiceData.data == null ||
        _catalogueServiceData.data.isEmpty);
  }

  Widget _getBodyView() {
    return Column(
      children: <Widget>[
        Visibility(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 8),
            child: _getDropDown(),
          ),
          visible: !_hasNoData(),
        ),
        _hasNoData() ? Container() : _getTopRow(),
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 8),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    _hasNoData()
                        ? Center(
                            child: Text(
                              PlunesStrings.youHaveNotAddedAnyServicesYet,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.GREYCOLOR),
                            ),
                          )
                        : _catalogueList == null || _catalogueList.isEmpty
                            ? Center(
                                child: Text(
                                  "You haven't added any services in your $_selectedSpeciality catalogue yet.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: AppConfig.mediumFont,
                                      color: PlunesColors.GREYCOLOR),
                                ),
                              )
                            : _isEditModeEnabled
                                ? _renderServiceCatalogueEditableList()
                                : _renderServiceCatalogueList(),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                          margin: _hasNoData()
                              ? EdgeInsets.only(
                                  bottom: AppConfig.verticalBlockSize * 2.5)
                              : null,
                          child: FloatingActionButton(
                            backgroundColor: PlunesColors.WHITECOLOR,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConfig.horizontalBlockSize * 10),
                                side: BorderSide(
                                    color: PlunesColors.GREENCOLOR,
                                    width: 2.0)),
                            child: Icon(
                              Icons.add,
                              color: PlunesColors.GREENCOLOR,
                              size: AppConfig.verticalBlockSize * 4,
                            ),
                            onPressed: () {},
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        )),
        _hasNoData()
            ? Container()
            : Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 8,
                    vertical: AppConfig.verticalBlockSize * 3),
                padding: EdgeInsets.all(AppConfig.horizontalBlockSize * 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: PlunesColors.LIGHTGREYCOLOR,
                ),
                child: Text(
                  PlunesStrings.toChangePriceOrVarianceString,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
      ],
    );
  }

  Widget _getTopRow() {
    return Container(
      color: PlunesColors.LIGHTGREYCOLOR,
      padding: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 8,
          vertical: AppConfig.verticalBlockSize * .5),
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              PlunesStrings.testName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: AppConfig.mediumFont),
            ),
            flex: 4,
          ),
          Expanded(
            child: Text(
              PlunesStrings.price,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppConfig.mediumFont),
            ),
            flex: 2,
          ),
          Expanded(
            child: Text(
              PlunesStrings.editVariance,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppConfig.mediumFont),
            ),
            flex: 2,
          ),
          Container(
              padding: _isEditModeEnabled
                  ? null
                  : EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 3,
                      vertical: AppConfig.verticalBlockSize * 1.2),
              child: Icon(
                Icons.arrow_drop_down,
                color: Colors.transparent,
              ))
        ],
      ),
    );
  }

  String _getVarianceText(int innerItemIndex) {
    if (_catalogueList[innerItemIndex] != null &&
        _catalogueList[innerItemIndex].variance != null) {
      return _catalogueList[innerItemIndex].variance.toString() + "%";
    } else {
      return PlunesStrings.NA;
    }
  }

  String _getPriceText(int innerItemIndex) {
    if (_catalogueList[innerItemIndex] != null &&
        _catalogueList[innerItemIndex].price != null) {
      return "\u20B9 " + _catalogueList[innerItemIndex].price.toString();
    } else {
      return PlunesStrings.NA;
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getDropDown() {
    if (_selectedSpeciality == null) {
      _selectedSpeciality =
          _catalogueServiceData.data.first?.speciality ?? PlunesStrings.NA;
      _catalogueList =
          _catalogueServiceData.data.first.services ?? <DocServiceCatalogue>[];
    }
    return DropdownButton<String>(
        isExpanded: true,
        items: _catalogueServiceData.data.map((data) {
          return DropdownMenuItem(
            child: Text(data.speciality ?? PlunesStrings.NA),
            value: data.speciality ?? PlunesStrings.NA,
          );
        }).toList(),
        value: _selectedSpeciality,
        onChanged: (value) {
          _selectedSpeciality = value;
          _catalogueServiceData.data.forEach((object) {
            if (object.speciality.contains(_selectedSpeciality)) {
              _catalogueList = object.services ?? <DocServiceCatalogue>[];
            }
          });
          _setState();
        });
  }

  Widget _renderServiceCatalogueList() {
    return ListView.builder(
      itemBuilder: (context, itemIndex) {
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * .5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _catalogueList[itemIndex]?.service ?? PlunesStrings.NA,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: AppConfig.mediumFont),
                    ),
                    flex: 4,
                  ),
                  Expanded(
                    child: Text(
                      _getPriceText(itemIndex),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: AppConfig.mediumFont),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Text(
                      _getVarianceText(itemIndex),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: AppConfig.mediumFont),
                    ),
                    flex: 2,
                  ),
                  InkWell(
                    onTap: () {
                      _isEditModeEnabled = true;
                      _setState();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 3,
                          vertical: AppConfig.verticalBlockSize * 1.2),
                      child: Icon(Icons.edit),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              color: PlunesColors.LIGHTGREYCOLOR,
              thickness: 1,
            )
          ],
        );
      },
      itemCount: _catalogueList.length,
    );
  }

  Widget _renderServiceCatalogueEditableList() {
    List<DropdownMenuItem<String>> _varianceDropDownItems = new List();
    for (String variance in _variances) {
      _varianceDropDownItems.add(new DropdownMenuItem(
        value: variance,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: new Text(
            "±" + variance + "%",
            style: TextStyle(
              fontSize: AppConfig.mediumFont,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
    return ListView.builder(
      itemBuilder: (context, itemIndex) {
        _priceList.add(TextEditingController(
            text: _catalogueList[itemIndex]?.price?.toString() ?? ""));
        __varianceInputs.add(_variances.first);
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * .5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _catalogueList[itemIndex]?.service ?? PlunesStrings.NA,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: AppConfig.mediumFont),
                    ),
                    flex: 4,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _priceList[itemIndex],
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: AppConfig.mediumFont),
                      textAlign: TextAlign.center,
//                      maxLines: 2,
                      decoration: InputDecoration.collapsed(
                          hintText: "", border: InputBorder.none),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      items: _varianceDropDownItems,
                      onChanged: (value) {
                        __varianceInputs[itemIndex] = value;
                        _setState();
                      },
                      value: __varianceInputs[itemIndex],
                      decoration: InputDecoration.collapsed(
                          hintText: "", border: InputBorder.none),
                    ),
                    flex: 2,
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),
            Divider(
              color: PlunesColors.LIGHTGREYCOLOR,
              thickness: 1,
            )
          ],
        );
      },
      itemCount: _catalogueList.length,
    );
  }
}
