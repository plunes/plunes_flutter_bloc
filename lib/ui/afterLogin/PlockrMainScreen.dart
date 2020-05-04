import 'dart:convert';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/plockr_blocs/plockr_bloc.dart';
import 'package:plunes/models/plockr_model/plockr_response_model.dart';
import 'package:plunes/models/plockr_model/plockr_shareable_report_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/afterLogin/showPlockrFileDetails.dart';
import 'package:plunes/ui/commonView/UploadPrescriptionDialog.dart';
import 'package:share/share.dart';

/// New 28/02/2020 - 03:30PM
// ignore: must_be_immutable
class PlockrMainScreen extends BaseActivity {
  static const tag = '/plockrmainscreen';

  @override
  _PlockrMainScreenState createState() => _PlockrMainScreenState();
}

class _PlockrMainScreenState extends State<PlockrMainScreen>
    with TickerProviderStateMixin, ImagePickerListener
    implements DialogCallBack {
  bool cross = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _searchController = new TextEditingController();
  AnimationController _animationController;
  ImagePickerHandler imagePicker;
  var globalHeight, globalWidth;
  Preferences _preferences;
  PlockrBloc _plockrBloc;
  bool progress = false;
  PlockrResponseModel _plockrResponseModel;
  String _userType = '', failureMessage;
  File _image;
  bool _isSharing = false, _isDeleting = false;
  String _selectedReportId;
  List<dynamic> reportsList = new List();
  List<UploadedReports> _originalDataList, _searchedList;

  @override
  void initState() {
    _plockrBloc = PlockrBloc();
    _isSharing = false;
    _originalDataList = [];
    _searchedList = [];
    _isDeleting = false;
    _getPlockrData();
    super.initState();
    initialize();
  }

  _getPlockrData() {
    _plockrBloc.getFilesAndData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _plockrBloc.dispose();
    super.dispose();
  }

  initialize() {
    _preferences = Preferences();
    _userType = _preferences.getPreferenceString(Constants.PREF_USER_TYPE);
    initializeForImageFetching();
  }

  initializeForImageFetching() {
    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {});
    imagePicker = new ImagePickerHandler(this, _animationController, false);
    imagePicker.init();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: getBodyView(),
    );
  }

  Widget getBodyView() {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              getUploadReportRow(),
              getSearchRow(),
              getListItemRowView()
            ],
          ),
          _isDeleting
              ? Container(
                  color: Colors.transparent,
                  child: GestureDetector(
                    child: CustomWidgets().getProgressIndicator(),
                    onTap: () {},
                    onDoubleTap: () {},
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget getUploadReportRow() {
    return InkWell(
      onTap: () {
        imagePicker.showDialog(context);
      },
      child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 20),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: widget.createTextViews(
                        plunesStrings.uploadReports,
                        16,
                        colorsFile.darkGrey1,
                        TextAlign.start,
                        FontWeight.normal)),
                widget.getAssetIconWidget(
                    plunesImages.uploadIcon, 20, 20, BoxFit.cover)
              ],
            ),
            widget.getSpacer(0.0, 20),
            widget.getDividerRow(context, 0.0, 0.0, 0.0)
          ])),
    );
  }

  Widget getSearchRow() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Card(
          semanticContainer: true,
          elevation: 8,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            height: 55,
            child: Container(
              padding: EdgeInsets.only(left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      cursorColor: Color(CommonMethods.getColorHexFromStr(
                          colorsFile.defaultGreen)),
                      controller: _searchController,
                      decoration: InputDecoration.collapsed(
                          hintText: plunesStrings.search),
                      onChanged: (text) {
                        _fllterOriginalListItems(text);
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: cross
                          ? InkWell(
                              child: Icon(Icons.close, color: Colors.grey),
                              onTap: () {
                                cross = false;
                                _searchController.text = '';
                                _searchedList = [];
                                _setState();
                              },
                            )
                          : Icon(Icons.search, color: Colors.grey)),
                ],
              ),
            ),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Color(0xff01d35a)),
                borderRadius: BorderRadius.all(Radius.circular(12))),
          )),
    );
  }

  Widget getListItemRowView() {
    return StreamBuilder<RequestState>(
        stream: _plockrBloc.getPlockrFileStream,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data is RequestInProgress) {
            return CustomWidgets().getProgressIndicator();
          }
          if (snapshot.data != null && snapshot.data is RequestSuccess) {
            RequestSuccess requestSuccess = snapshot.data;
            _plockrResponseModel = requestSuccess.response;
            _originalDataList = _plockrResponseModel.uploadedReports;
            _plockrBloc.addStateInPlockerReportStream(null);
          }
          if (snapshot.data != null && snapshot.data is RequestFailed) {
            RequestFailed requestFailed = snapshot.data;
            failureMessage = requestFailed.failureCause;
            _plockrBloc.addStateInPlockerReportStream(null);
          }
          List<UploadedReports> listToRendered = _originalDataList;
          if (cross) {
            listToRendered = _searchedList;
          }
          return (listToRendered == null || listToRendered.isEmpty)
              ? Center(
                  child: Text(cross
                      ? PlunesStrings.noMatchReport
                      : failureMessage ??
                          PlunesStrings.noReportAvailabelMessage),
                )
              : Expanded(child: _renderedListItems(listToRendered));
        });
  }

  @override
  fetchImageCallBack(File _image) {
    if (_image != null) {
      // print("image==" + base64Encode(_image.readAsBytesSync()).toString());
      this._image = _image;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => UploadPrescriptionDialog(
                imageUrl: _image.path.toString(),
                plockrBloc: _plockrBloc,
              )).then((value) {
        if (value != null &&
            value.runtimeType is String &&
            value.toString().trim().isNotEmpty) {
          widget.showInSnackBar(value, PlunesColors.BLACKCOLOR, _scaffoldKey);
        }
      });
    }
  }

  Widget getItemImageView(UploadedReports uploadedReports) {
    return Container(
      width: AppConfig.horizontalBlockSize * 18,
      height: AppConfig.verticalBlockSize * 13,
      decoration: BoxDecoration(
        color: PlunesColors.GREENCOLOR,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: SizedBox.expand(
          child: CustomWidgets().getImageFromUrl(
              uploadedReports.reportThumbnail,
              boxFit: BoxFit.fill)),
      alignment: Alignment.center,
    );
  }

  Widget getMenuPopup(String reportId) {
    return Container(
      child: PopupMenuButton<String>(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 5, bottom: 10),
          child: Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
        ),
        padding: EdgeInsets.zero,
        onSelected: (value) {
          showMenuSelection(value, reportId);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Delete',
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                ),
                Text('Delete')
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Share',
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    Icons.share,
                    color: Colors.grey,
                  ),
                ),
                Text('Share')
              ],
            ),
          ),
        ],
      ),
    );
  }

  showMenuSelection(String value, String reportId) {
    if (value == 'Delete') {
      _selectedReportId = reportId;
      CommonMethods.confirmationDialog(
          context, plunesStrings.deleteReportMsg, this);
    } else if (value == "Share") {
      _getShareableLink(reportId);
    }
  }

  @override
  dialogCallBackFunction(String action) {
    if (action != null && action == 'DONE') deleteReport();
  }

  void deleteReport() async {
    if (_selectedReportId == null || _selectedReportId.isEmpty) {
      widget.showInSnackBar(
          PlunesStrings.dataNotFound, PlunesColors.BLACKCOLOR, _scaffoldKey);
      return;
    }
    _isDeleting = true;
    _setState();
    var result = await _plockrBloc.deleteFileAndData(_selectedReportId);
    _isDeleting = false;
    if (result is RequestSuccess) {
      if (_originalDataList.contains(UploadedReports(sId: _selectedReportId))) {
        _originalDataList.remove(UploadedReports(sId: _selectedReportId));
      }
      if (cross != null &&
          cross &&
          _searchedList != null &&
          _searchedList.isNotEmpty &&
          _searchedList.contains(UploadedReports(sId: _selectedReportId))) {
        _searchedList.remove(UploadedReports(sId: _selectedReportId));
      }
      widget.showInSnackBar(PlunesStrings.deleteSuccessfully,
          PlunesColors.BLACKCOLOR, _scaffoldKey);
    } else if (result is RequestFailed) {
      widget.showInSnackBar(
          PlunesStrings.unableToDelete, PlunesColors.BLACKCOLOR, _scaffoldKey);
    }
    _setState();
  }

  void _getShareableLink(String sId) async {
    if (sId == null || sId.isEmpty) {
      widget.showInSnackBar(
          PlunesStrings.dataNotFound, PlunesColors.BLACKCOLOR, _scaffoldKey);
      return;
    }
    if (_isSharing) {
      return;
    }
    _isSharing = true;
    var result = await _plockrBloc.getSharebleLink(sId);
    _isSharing = false;
    if (result is RequestSuccess) {
      ShareableReportModel shareableReportModel = result.response;
      if (shareableReportModel != null &&
          shareableReportModel.link != null &&
          shareableReportModel.link.reportUrl != null &&
          shareableReportModel.link.reportUrl.isNotEmpty) {
        CustomWidgets()
            .share("Report url :\n ${shareableReportModel.link.reportUrl}");
      } else {
        widget.showInSnackBar(
            PlunesStrings.dataNotFound, PlunesColors.BLACKCOLOR, _scaffoldKey);
      }
    } else if (result is RequestFailed) {
      widget.showInSnackBar(
          PlunesStrings.dataNotFound, PlunesColors.BLACKCOLOR, _scaffoldKey);
    }
  }

  _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _renderedListItems(List<UploadedReports> uploadedReports) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: uploadedReports?.length ?? 0,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 0),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        ShowImageDetails(uploadedReports[index]),
                  );
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      getItemImageView(uploadedReports[index]),
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              uploadedReports[index].reportDisplayName ??
                                  PlunesStrings.NA,
                              // 'X-ray FH001111',
                              maxLines: 3,
                              style: TextStyle(
                                  color: Color(0xff5D5D5D),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            Text(
                              DateUtil.getDuration(
                                  uploadedReports[index].createdTime),
                              //'2 days ago',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff5D5D5D)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                uploadedReports[index].userName ??
                                    PlunesStrings.NA,
                                style: TextStyle(
                                    color: Color(0xff5D5D5D), fontSize: 13)),
                            Text(
                                uploadedReports[index].remarks ??
                                    PlunesStrings.NA,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Color(0xff5D5D5D), fontSize: 13)),
                          ],
                        ),
                      )),
                      getMenuPopup(uploadedReports[index].sId),
                    ],
                  ),
                ),
              ),
              index != uploadedReports.length ?? 0
                  ? Container(
                      height: 0.3,
                      color: Colors.grey,
                      margin: EdgeInsets.only(top: 20, bottom: 20))
                  : Container(margin: EdgeInsets.only(bottom: 20))
            ],
          ),
        );
      },
    );
  }

  void _fllterOriginalListItems(String text) {
    if (_originalDataList != null &&
        _originalDataList.isNotEmpty &&
        text != null &&
        text.trim().isNotEmpty) {
      _searchedList = [];
      _originalDataList.forEach((item) {
        if (item.reportDisplayName
            .toLowerCase()
            .contains(text.trim().toLowerCase())) {
          _searchedList.add(item);
        }
      });
    }
    if (text.trim().length > 0) {
      cross = true;
    } else {
      _searchedList = [];
      cross = false;
    }
    _setState();
  }
}
