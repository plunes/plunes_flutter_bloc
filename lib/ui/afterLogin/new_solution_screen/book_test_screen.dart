import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/new_solution_model/hos_facility_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';

// ignore: must_be_immutable
class BookTestScreen extends BaseActivity {
  List<ServiceCategory> test;

  BookTestScreen(this.test);

  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

class _TestBookingScreenState extends BaseState<BookTestScreen> {
  TextEditingController _textController;
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
          appBar: widget.getAppBar(context, "Book Test", true),
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
                _textController, "Search test", () => _onTextClear()),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                if (_textController.text.trim().isNotEmpty &&
                    widget.test[index].serviceName
                        .toLowerCase()
                        .contains(_textController.text.trim().toLowerCase())) {
                  return CommonWidgets().getBookTestWidget(
                      widget.test,
                      index,
                      () => _calcTestDataAndOpenAdditionalDetailScr(
                          widget.test[index]),
                      isFromIndividualScreen: true);
                } else if (_textController.text.trim().isEmpty) {
                  return CommonWidgets().getBookTestWidget(
                      widget.test,
                      index,
                      () => _calcTestDataAndOpenAdditionalDetailScr(
                          widget.test[index]),
                      isFromIndividualScreen: true);
                } else {
                  _totalCount++;
                  return _totalCount == widget.test.length
                      ? Container(
                          height: AppConfig.verticalBlockSize * 70,
                          child: Center(
                              child: CustomWidgets()
                                  .errorWidget("No match found!")))
                      : Container();
                }
              },
              itemCount: widget.test.length,
            ),
          ),
        ],
      ),
    );
  }

  _calcTestDataAndOpenAdditionalDetailScr(ServiceCategory test) {
    var data = CatalogueData(
        category: test.category,
        serviceId: test.serviceId,
        service: test.service,
        speciality: test.speciality,
        specialityId: test.specialityId);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterAdditionalUserDetailScr(data, "")));
  }
}
