import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';

// ignore: must_be_immutable
class BookConsultationScreen extends BaseActivity {
  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

class _TestBookingScreenState extends BaseState<BookConsultationScreen> {
  TextEditingController _textController;
  List<DocServiceData> _serviceNameList = [];

  _onTextClear() {}

  @override
  void initState() {
    _serviceNameList = [];
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, "Book Consultation", true),
          body: _getBodyWidget()),
    );
  }

  Widget _getBodyWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 1.5),
                  child: CommonWidgets()
                      .getSearchBarForTestConsProcedureScreens(_textController,
                          "Search consultation", () => _onTextClear()),
                ),
                _getListOfNumberOfDoctorAvailableForSpecificService(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return CommonWidgets().getConsultationWidget(index);
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getListOfNumberOfDoctorAvailableForSpecificService() {
    _initServiceList();
    return Container(
      height: AppConfig.verticalBlockSize * 4.5,
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _serviceNameList.forEach((element) {
                element.isSelected = false;
              });
              _serviceNameList[index].isSelected = true;
              _setState();
            },
            onDoubleTap: () {},
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color:
                          Color(CommonMethods.getColorHexFromStr("#70707057"))),
                  color: _serviceNameList[index].isSelected
                      ? Color(CommonMethods.getColorHexFromStr("#25B281"))
                      : Color(CommonMethods.getColorHexFromStr("#FAFBFD"))),
              child: Text(
                _serviceNameList[index].serviceName ?? "",
                style: TextStyle(
                    color: _serviceNameList[index].isSelected
                        ? PlunesColors.WHITECOLOR
                        : Color(CommonMethods.getColorHexFromStr("#303030")),
                    fontSize: 12),
              ),
            ),
          );
        },
        itemCount: _serviceNameList?.length ?? 0,
      ),
    );
  }

  void _initServiceList() {
    if (_serviceNameList != null && _serviceNameList.isNotEmpty) {
      return;
    }
    _serviceNameList = [];
    _serviceNameList.add(DocServiceData(
        isSelected: true, serviceName: "Orthopedist (14)", numOfDocs: 4));
    _serviceNameList.add(DocServiceData(
        isSelected: false,
        serviceName: "General Physician (10)",
        numOfDocs: 4));
    _serviceNameList.add(DocServiceData(
        isSelected: false, serviceName: "Nephrologist (6)", numOfDocs: 4));
    _serviceNameList.add(DocServiceData(
        isSelected: false, serviceName: "Oncologist (6)", numOfDocs: 4));
    _serviceNameList.add(DocServiceData(
        isSelected: false, serviceName: "Orthopedist (14)", numOfDocs: 4));
    _serviceNameList.add(DocServiceData(
        isSelected: false, serviceName: "Orthopedist (14)", numOfDocs: 4));
  }

  void _setState() {
    if (mounted) setState(() {});
  }
}

class DocServiceData {
  String serviceName;
  bool isSelected;
  int numOfDocs;

  DocServiceData({this.serviceName, this.isSelected, this.numOfDocs});
}
