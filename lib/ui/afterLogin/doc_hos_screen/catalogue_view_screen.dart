import 'package:flutter/material.dart';
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

  @override
  void initState() {
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
//                    _catalogueServiceData = _successObject.response;
                  } else if (snapShot.data is RequestFailed) {
                    RequestFailed _failedObject = snapShot.data;
                    _errorMessage = _failedObject.failureCause;
                  }
                  if (snapShot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  return (_errorMessage != null && _errorMessage.isNotEmpty)
                      ? CustomWidgets().errorWidget(_errorMessage)
                      : _getBodyView();
                },
                initialData: RequestInProgress(),
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
        _hasNoData() ? Container() : Text("dsd"),
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 8),
          child: _hasNoData()
              ? Center(
                  child: Text(
                    PlunesStrings.youHaveNotAddedAnyServicesYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: AppConfig.mediumFont,
                        color: PlunesColors.GREYCOLOR),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (context, itemIndex) {
                    return Text("sdasds $itemIndex");
                  },
                  itemCount: 130,
                ),
        )),
        Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 8),
            margin: _hasNoData()
                ? EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.5)
                : null,
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: PlunesColors.WHITECOLOR,
              ),
              onPressed: () {},
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
}
