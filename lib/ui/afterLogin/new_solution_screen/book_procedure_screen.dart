import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/new_solution_model/hos_facility_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';

import '../../../models/new_solution_model/new_hos_facility_model.dart';

// ignore: must_be_immutable
class BookProcedureScreen extends BaseActivity {
  List<NewServiceCategory>? procedures;
  // List<ServiceCategory>? procedures;
  String? profId;
  bool? isAlreadyInBookingProcess;

  BookProcedureScreen(this.procedures, this.profId,
      {this.isAlreadyInBookingProcess});

  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

// class _TestBookingScreenState extends BaseState<BookProcedureScreen> {
class _TestBookingScreenState extends State<BookProcedureScreen> {
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController? _textController;
  int _totalCount = 0;

  _onTextClear() {
    _setState();
  }

  @override
  void initState() {
    _totalCount = 0;
    _textController = TextEditingController()
      ..addListener(() {
        _setState();
      });
    super.initState();
  }

  _setState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _totalCount = 0;
    return SafeArea(
      top: false,
      child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, "Book Procedure", true) as PreferredSizeWidget?,
          body: _getBodyWidget()),
    );
  }

  Widget _getBodyWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 1.5, horizontal: 20),
            child: CommonWidgets().getSearchBarForTestConsProcedureScreens(
                _textController, "Search procedure", () => _onTextClear()),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                if (_textController!.text.trim().isNotEmpty &&
                    widget.procedures![index].serviceName!
                        .toLowerCase()
                        .contains(_textController!.text.trim().toLowerCase())) {
                  return CommonWidgets().getBookProcedureWidgetNew(
                      widget.procedures!,
                      index,
                      () => _calcTestDataAndOpenAdditionalDetailScrNew(
                          widget.procedures![index]),
                      isFromIndividualScreen: true);
                } else if (_textController!.text.trim().isEmpty) {
                  return CommonWidgets().getBookProcedureWidgetNew(
                      widget.procedures!,
                      index,
                      () => _calcTestDataAndOpenAdditionalDetailScrNew(
                          widget.procedures![index]),
                      isFromIndividualScreen: true);
                } else {
                  _totalCount++;
                  return _totalCount == widget.procedures!.length
                      ? Container(
                          height: AppConfig.verticalBlockSize * 70,
                          child: Center(
                              child: CustomWidgets()
                                  .errorWidget("No match found!")))
                      : Container();
                }
              },
              itemCount: widget.procedures!.length,
            ),
          ),
        ],
      ),
    );
  }

  _calcTestDataAndOpenAdditionalDetailScr(ServiceCategory serviceCategory) {
    if (widget.isAlreadyInBookingProcess != null) {
      return;
    }
    num? servicePrice = 0;
    if (serviceCategory != null &&
        serviceCategory.price != null &&
        serviceCategory.price!.isNotEmpty &&
        serviceCategory.price!.first! > 0) {
      servicePrice = serviceCategory.price!.first;
    }
    var data = CatalogueData(
      category: serviceCategory.category,
      serviceId: serviceCategory.serviceId,
      service: serviceCategory.service,
      speciality: serviceCategory.speciality,
      specialityId: serviceCategory.specialityId,
      family: serviceCategory.service,
      isFromProfileScreen: true,
      profId: widget.profId,
      servicePrice: servicePrice,
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterAdditionalUserDetailScr(data, "")));
  }

  _calcTestDataAndOpenAdditionalDetailScrNew(NewServiceCategory serviceCategory) {
    if (widget.isAlreadyInBookingProcess != null) {
      return;
    }
    num? servicePrice = 0;
    if (serviceCategory != null &&
        serviceCategory.price != null &&
        serviceCategory.price!.isNotEmpty &&
        serviceCategory.price!.first! > 0) {
      servicePrice = serviceCategory.price!.first;
    }
    var data = CatalogueData(
      category: serviceCategory.category,
      serviceId: serviceCategory.serviceId,
      service: serviceCategory.service,
      speciality: serviceCategory.speciality,
      specialityId: serviceCategory.specialityId,
      family: serviceCategory.service,
      isFromProfileScreen: true,
      profId: widget.profId,
      servicePrice: servicePrice,
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterAdditionalUserDetailScr(data, "")));
  }
}
