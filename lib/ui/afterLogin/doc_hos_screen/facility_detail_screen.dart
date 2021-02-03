import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/new_solution_model/service_detail_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';

// ignore: must_be_immutable
class FacilityDetailScreen extends BaseActivity {
  final String profId;
  final String specialityId, speciality;

  FacilityDetailScreen({this.profId, this.specialityId, this.speciality});

  @override
  _FacilityDetailScreenState createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends BaseState<FacilityDetailScreen> {
  UserBloc _userBloc;
  ServiceDetailModel _serviceDetailModel;

  String _failureCause;

  @override
  void initState() {
    _userBloc = UserBloc();
    _getSpecialityDetail();
    super.initState();
  }

  @override
  void dispose() {
    _userBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: widget.getAppBar(context, widget.speciality ?? "", true),
        body: StreamBuilder<RequestState>(
            stream: _userBloc.serviceRelatedToSpecialityStream,
            initialData:
                (_serviceDetailModel == null) ? RequestInProgress() : null,
            builder: (context, snapshot) {
              if (snapshot.data is RequestSuccess) {
                RequestSuccess successObject = snapshot.data;
                _serviceDetailModel = successObject.response;
                _userBloc?.addStateInServiceRelatedToSpecialityStream(null);
              } else if (snapshot.data is RequestFailed) {
                RequestFailed _failedObj = snapshot.data;
                _failureCause = _failedObj?.failureCause;
                _userBloc?.addStateInServiceRelatedToSpecialityStream(null);
              } else if (snapshot.data is RequestInProgress) {
                return Container(
                  child: CustomWidgets().getProgressIndicator(),
                );
              }
              return (_serviceDetailModel == null ||
                      (_serviceDetailModel.success != null &&
                          !_serviceDetailModel.success) ||
                      _serviceDetailModel.data == null ||
                      _serviceDetailModel.data.services == null ||
                      _serviceDetailModel.data.services.isEmpty)
                  ? Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: AppConfig.horizontalBlockSize * 3),
                      child: CustomWidgets().errorWidget(_failureCause,
                          onTap: () => _getSpecialityDetail(),
                          isSizeLess: true),
                    )
                  : _getBody();
            }),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget _getBody() {
    return Container(
      color: Color(CommonMethods.getColorHexFromStr("#FFFFFF")),
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 2.5,
          vertical: AppConfig.verticalBlockSize * 1.5),
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var serviceData = _serviceDetailModel?.data?.services[index];
          return Card(
            margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.5),
            color: Color(CommonMethods.getColorHexFromStr("#FCFCFC")),
            child: Container(
              color: Color(CommonMethods.getColorHexFromStr("#FCFCFC")),
              padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 1.5,
                  vertical: AppConfig.verticalBlockSize * 1.2),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      serviceData.isExpanded = !serviceData.isExpanded;
                      _setState();
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            serviceData?.service ?? "",
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontSize: 18,
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Icon(
                          (serviceData?.isExpanded ?? false)
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: PlunesColors.BLACKCOLOR,
                        )
                      ],
                    ),
                  ),
                  (serviceData.isExpanded)
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 1.4),
                          width: double.infinity,
                          height: 0.6,
                          color: PlunesColors.GREYCOLOR,
                        )
                      : Container(),
                  serviceData.isExpanded
                      ? Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          serviceData?.duration ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: PlunesColors.BLACKCOLOR,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "Duration",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          serviceData?.sittings ??
                                              "Depends on case",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: PlunesColors.BLACKCOLOR,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "Session",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2.5),
                                child: Text(
                                  "Definition",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: PlunesColors.BLACKCOLOR,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(
                                            top: AppConfig.verticalBlockSize *
                                                2.5),
                                        child: Text(
                                          serviceData?.definitions ?? "",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        )),
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 2.5),
                                child: Text(
                                  "Dos And Don'ts",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: PlunesColors.BLACKCOLOR,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(
                                            top: AppConfig.verticalBlockSize *
                                                2.5),
                                        child: Text(
                                          serviceData?.dnd ?? "",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(CommonMethods
                                                  .getColorHexFromStr(
                                                      "#515151")),
                                              fontWeight: FontWeight.normal),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          );
        },
        itemCount: _serviceDetailModel?.data?.services?.length ?? 0,
      ),
    );
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _getSpecialityDetail() {
    _userBloc.getServicesOfSpeciality(widget.specialityId, widget.profId);
  }
}
