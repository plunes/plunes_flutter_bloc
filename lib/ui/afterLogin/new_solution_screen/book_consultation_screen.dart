import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';

// ignore: must_be_immutable
class BookConsultationScreen extends BaseActivity {
  List<DoctorsData>? docList;
  String? profId;
  bool? isAlreadyInBookingProcess;

  BookConsultationScreen(this.docList, this.profId,
      {this.isAlreadyInBookingProcess});

  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

// class _TestBookingScreenState extends BaseState<BookConsultationScreen> {
class _TestBookingScreenState extends State<BookConsultationScreen> {
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController? _textController;
  List<DocServiceData> _serviceNameList = [];
  String? _selectedService;
  StreamController? _streamConForDocTiming;
  int _totalCount = 0;
  Timer? _timerForEverySecond;

  _onTextClear() {
    if (mounted) {
      _setState();
    }
  }

  @override
  void initState() {
    _totalCount = 0;
    _serviceNameList = [];
    _textController = TextEditingController()
      ..addListener(() {
        _onSearch();
      });
    _initServiceList();
    _streamConForDocTiming = StreamController.broadcast();
    _startSecondTimer();
    super.initState();
  }

  void _startSecondTimer() {
    _timerForEverySecond = Timer.periodic(Duration(seconds: 10), (timer) {
      _timerForEverySecond = timer;
      if (mounted) {
        _streamConForDocTiming!.add(null);
      } else if (timer != null && timer.isActive) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _streamConForDocTiming?.close();
    _textController?.dispose();
    _timerForEverySecond?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, "Book Consultation", true) as PreferredSizeWidget?,
          body: _getBodyWidget()),
    );
  }

  Widget _getBodyWidget() {
    _totalCount = 0;
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
                _textController!.text.trim().isNotEmpty
                    ? Container()
                    : _getListOfNumberOfDoctorAvailableForSpecificService(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                if (_textController!.text.trim().isNotEmpty &&
                    widget.docList![index].department!
                        .trim()
                        .toLowerCase()
                        .contains(_textController!.text.trim().toLowerCase())) {
                  return _showConsWidget(index);
                }
                if (widget.docList![index].department!.trim().toLowerCase() ==
                        _selectedService &&
                    _textController!.text.trim().isEmpty) {
                  return _showConsWidget(index);
                }
                _totalCount++;
                return _totalCount == widget.docList!.length
                    ? Container(
                        height: AppConfig.verticalBlockSize * 70,
                        child: Center(
                            child:
                                CustomWidgets().errorWidget("No match found!")))
                    : Container();
              },
              itemCount: widget.docList!.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showConsWidget(int index) {
    return InkWell(
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onDoubleTap: () {},
      onTap: () {
        if (widget.docList![index].id != null &&
            widget.docList![index].id!.trim().isNotEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DoctorInfo(
                        widget.profId,
                        isDoc: true,
                        docId: widget.docList![index].id,
                        openEnterDetailScreen: () =>
                            _openConsScreen(widget.docList![index]),
                        isAlreadyInBookingProcess:
                            widget.isAlreadyInBookingProcess,
                      )));
        }
      },
      child: StreamBuilder<Object?>(
          stream: _streamConForDocTiming!.stream,
          builder: (context, snapshot) {
            return CommonWidgets().getConsultationWidget(widget.docList!, index,
                () => _openConsScreen(widget.docList![index]));
          }),
    );
  }

  _openConsScreen(DoctorsData doctorsData) {
    if (widget.isAlreadyInBookingProcess != null) {
      return;
    }
    num? servicePrice = 0;
    if (doctorsData != null &&
        doctorsData.specialities != null &&
        doctorsData.specialities!.isNotEmpty &&
        doctorsData.specialities!.first.services != null &&
        doctorsData.specialities!.first.services.isNotEmpty &&
        doctorsData.specialities!.first.services.first.price != null &&
        doctorsData.specialities!.first.services.first.price! > 0) {
      servicePrice = doctorsData.specialities!.first.services.first.price;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterAdditionalUserDetailScr(
                CatalogueData(
                  serviceId:
                      doctorsData.specialities?.first.services.first.id,
                  speciality: doctorsData.specialities?.first.speciality,
                  specialityId: doctorsData.specialities?.first.id,
                  service: doctorsData
                      .specialities?.first.services.first.service,
                  family: doctorsData
                      .specialities?.first.services.first.service,
                  category: doctorsData
                      .specialities?.first.services.first.category,
                  details: doctorsData
                      .specialities?.first.services.first.details,
                  isFromProfileScreen: true,
                  profId: widget.profId,
                  doctorId: doctorsData.id,
                  servicePrice: servicePrice,
                ),
                "")));
  }

  Widget _getListOfNumberOfDoctorAvailableForSpecificService() {
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
              _selectedService = _serviceNameList[index].serviceName;
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
                  color: _serviceNameList[index].isSelected!
                      ? Color(CommonMethods.getColorHexFromStr("#25B281"))
                      : Color(CommonMethods.getColorHexFromStr("#FAFBFD"))),
              child: Text(
                _serviceNameList[index].serviceName ?? "",
                style: TextStyle(
                    color: _serviceNameList[index].isSelected!
                        ? PlunesColors.WHITECOLOR
                        : Color(CommonMethods.getColorHexFromStr("#303030")),
                    fontSize: 12),
              ),
            ),
          );
        },
        itemCount: _serviceNameList.length ?? 0,
      ),
    );
  }

  void _initServiceList() {
    if (widget.docList == null || widget.docList!.isEmpty) {
      return;
    }
    _serviceNameList = [];
    widget.docList!.forEach((element) {
      if (element.designation != null &&
          element.designation!.trim().isNotEmpty) {
        DocServiceData _docInfo = DocServiceData(
            serviceName: element.department!.trim().toLowerCase(),
            numOfDocs: 1,
            isSelected: false);
        if (_serviceNameList.contains(_docInfo)) {
          _serviceNameList[_serviceNameList.indexOf(_docInfo)].numOfDocs!+1;
        } else {
          _serviceNameList.add(_docInfo);
        }
      }
    });
    _serviceNameList.first.isSelected = true;
    _selectedService = _serviceNameList.first.serviceName;
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  void _onSearch() {
    if (mounted) {
      _setState();
    }
  }
}

class DocServiceData {
  String? serviceName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocServiceData &&
          runtimeType == other.runtimeType &&
          serviceName == other.serviceName;

  @override
  int get hashCode => serviceName.hashCode;
  bool? isSelected;
  int? numOfDocs;

  DocServiceData({this.serviceName, this.isSelected, this.numOfDocs});
}
