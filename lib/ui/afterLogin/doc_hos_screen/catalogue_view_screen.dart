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
                    _catalogueServiceData = _successObject.response;
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
                        : ListView.builder(
                            itemBuilder: (context, itemIndex) {
                              return (_catalogueServiceData
                                              ?.data[itemIndex].services ==
                                          null ||
                                      _catalogueServiceData
                                          ?.data[itemIndex].services.isEmpty)
                                  ? Container()
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: (_catalogueServiceData
                                              ?.data[itemIndex]
                                              ?.services
                                              ?.length) ??
                                          0,
                                      itemBuilder: (context, innerItemIndex) {
                                        return Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: AppConfig
                                                          .verticalBlockSize *
                                                      1.5),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      _catalogueServiceData
                                                              ?.data[itemIndex]
                                                              ?.services[
                                                                  innerItemIndex]
                                                              ?.service ??
                                                          PlunesStrings.NA,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: AppConfig
                                                              .mediumFont),
                                                    ),
                                                    flex: 4,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      _getPriceText(itemIndex,
                                                          innerItemIndex),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: AppConfig
                                                              .mediumFont),
                                                    ),
                                                    flex: 2,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      _getVarianceText(
                                                          itemIndex,
                                                          innerItemIndex),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: AppConfig
                                                              .mediumFont),
                                                    ),
                                                    flex: 2,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              color:
                                                  PlunesColors.LIGHTGREYCOLOR,
                                              thickness: 1,
                                            )
                                          ],
                                        );
                                      });
                            },
                            itemCount: _catalogueServiceData?.data?.length ?? 0,
                          ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
//                    padding: EdgeInsets.symmetric(
//                        horizontal: AppConfig.horizontalBlockSize * 8),
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
          vertical: AppConfig.verticalBlockSize * 1.5),
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
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: AppConfig.mediumFont),
            ),
            flex: 1,
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
          )
        ],
      ),
    );
  }

  String _getVarianceText(int itemIndex, int innerItemIndex) {
    if (_catalogueServiceData?.data[itemIndex]?.services[innerItemIndex] !=
            null &&
        _catalogueServiceData
                ?.data[itemIndex]?.services[innerItemIndex].variance !=
            null) {
      return _catalogueServiceData
              ?.data[itemIndex]?.services[innerItemIndex].variance
              .toString() +
          "%";
    } else {
      return PlunesStrings.NA;
    }
  }

  String _getPriceText(int itemIndex, int innerItemIndex) {
    if (_catalogueServiceData?.data[itemIndex]?.services[innerItemIndex] !=
            null &&
        _catalogueServiceData
                ?.data[itemIndex]?.services[innerItemIndex].price !=
            null) {
      return "\u20B9 " +
          _catalogueServiceData?.data[itemIndex]?.services[innerItemIndex].price
              .toString();
    } else {
      return PlunesStrings.NA;
    }
  }
}
