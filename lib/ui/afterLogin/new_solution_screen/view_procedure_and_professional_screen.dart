import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/new_solution_blocs/sol_home_screen_bloc.dart';
import 'package:plunes/models/new_solution_model/know_procedure_model.dart';
import 'package:plunes/models/new_solution_model/professional_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:readmore/readmore.dart';

// ignore: must_be_immutable
class ViewProcedureAndProfessional extends BaseActivity {
  ProcedureData procedureData;

  ViewProcedureAndProfessional({this.procedureData});

  @override
  _ViewProcedureAndProfessionalState createState() =>
      _ViewProcedureAndProfessionalState();
}

class _ViewProcedureAndProfessionalState
    extends BaseState<ViewProcedureAndProfessional> {
  HomeScreenMainBloc _homeScreenMainBloc;
  ProfessionDataModel _professionDataModel;

  String _mediaFailedMessage;

  @override
  void initState() {
    _homeScreenMainBloc = HomeScreenMainBloc();
    _getData();
    super.initState();
  }

  _getData() {
    _getProfessionals();
    _getVideos();
    _getReviews();
  }

  _getProfessionals() {
    _homeScreenMainBloc.getProfessionalsForService(widget.procedureData.sId);
  }

  _getVideos() {}

  _getReviews() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            key: scaffoldKey,
            body: _getBody(),
          ),
        ));
  }

  Widget _getBody() {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
      child: Column(
        children: [
          _getAppAndSearchBarWidget(),
          Expanded(
            child: SingleChildScrollView(child: _getWholeBodyWidget()),
          ),
        ],
      ),
    );
  }

  Widget _getAppAndSearchBarWidget() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.2,
      child: Container(
        padding: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 2.5,
            right: AppConfig.horizontalBlockSize * 2.5,
            top: AppConfig.verticalBlockSize * 0.6,
            bottom: AppConfig.horizontalBlockSize * 1.8),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(19, 184, 126, 0.19),
            Color.fromRGBO(255, 255, 255, 0),
          ],
        )),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                      return;
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: PlunesColors.BLACKCOLOR,
                    ),
                  )),
              title: Text(
                "Search Desired Service",
                textAlign: TextAlign.left,
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 20),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 0.8,
                  bottom: AppConfig.verticalBlockSize * 2.8),
              child: Card(
                elevation: 4.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24))),
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 6,
                      vertical: AppConfig.verticalBlockSize * 1.6),
                  child: Text(
                    "Search service",
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getWholeBodyWidget() {
    return Container(
      margin: EdgeInsets.only(
          left: AppConfig.horizontalBlockSize * 3,
          right: AppConfig.horizontalBlockSize * 3,
          bottom: AppConfig.horizontalBlockSize * 3),
      child: Column(
        children: [
          _getProcedureDetailWidget(),
          _getProfessionalListWidget(),
          _getVideoWidget(),
          _getReviewSection()
        ],
      ),
    );
  }

  Widget _getProcedureDetailWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: AppConfig.verticalBlockSize * 23,
            width: double.infinity,
            child: ClipRRect(
              child: CustomWidgets().getImageFromUrl(
                  widget.procedureData.familyImage,
                  boxFit: BoxFit.cover),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.5),
            child: Text(
              widget.procedureData?.familyName ?? "",
              style: TextStyle(
                  fontSize: 18,
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.normal),
            ),
          ),
          Container(
            margin:
                EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Color(CommonMethods.getColorHexFromStr("#ECF4F7")),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.procedureData?.duration ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "Duration",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#515151")),
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Color(CommonMethods.getColorHexFromStr("#ECF4F7")),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.procedureData?.sittings ?? "Depends on case",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "Session",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#515151")),
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
            child: Text(
              "Definition",
              style: TextStyle(
                  fontSize: 18,
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.normal),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.5),
                  child: ReadMoreText(
                    widget.procedureData?.details ?? "",
                    colorClickableText: PlunesColors.SPARKLINGGREEN,
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '  ...read more',
                    trimExpandedText: '  read less',
                    style: TextStyle(
                        fontSize: 16,
                        color:
                            Color(CommonMethods.getColorHexFromStr("#515151")),
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),
          Card(
            color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
            margin:
                EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 1.5,
                      vertical: AppConfig.verticalBlockSize * 1.2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      ),
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.only(
                            left: AppConfig.horizontalBlockSize * 2.5),
                        child: Text(
                          widget.procedureData.dnd[index] ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#4E4E4E"))),
                        ),
                      ))
                    ],
                  ),
                );
              },
              itemCount: widget.procedureData?.dnd?.length ?? 0,
            ),
          )
        ],
      ),
    );
  }

  Widget _getProfessionalListWidget() {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(
              top: AppConfig.verticalBlockSize * 1.5,
              bottom: AppConfig.verticalBlockSize * 0.01),
          child: Text(
            "Facility",
            style: TextStyle(
                fontSize: 18,
                color: PlunesColors.BLACKCOLOR,
                fontWeight: FontWeight.normal),
          ),
        ),
        StreamBuilder<RequestState>(
            stream: _homeScreenMainBloc.professionalForServiceStream,
            initialData:
                _professionDataModel == null ? RequestInProgress() : null,
            builder: (context, snapshot) {
              if (snapshot.data is RequestSuccess) {
                RequestSuccess successObject = snapshot.data;
                _professionDataModel = successObject.response;
                _homeScreenMainBloc
                    ?.addIntoGetProfessionalForServiceDataStream(null);
              } else if (snapshot.data is RequestFailed) {
                RequestFailed _failedObj = snapshot.data;
                _mediaFailedMessage = _failedObj?.failureCause;
                _homeScreenMainBloc
                    ?.addIntoGetProfessionalForServiceDataStream(null);
              } else if (snapshot.data is RequestInProgress) {
                return Container(
                  child: CustomWidgets().getProgressIndicator(),
                  height: AppConfig.verticalBlockSize * 28,
                );
              }
              return (_professionDataModel == null ||
                      _professionDataModel.data == null ||
                      _professionDataModel.data.isEmpty)
                  ? Container(
                      margin: EdgeInsets.all(AppConfig.horizontalBlockSize * 3),
                      child: CustomWidgets().errorWidget(_mediaFailedMessage,
                          onTap: () => _getProfessionals(), isSizeLess: true),
                    )
                  : Container(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return CommonWidgets()
                              .getProfessionalWidgetForSearchDesiredServiceScreen(
                                  index,
                                  _professionDataModel.data[index],
                                  widget.procedureData?.speciality);
                        },
                        shrinkWrap: true,
                        itemCount: 5,
                      ),
                    );
            }),
      ],
    );
  }

  Widget _getVideoWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 0.4,
                left: AppConfig.horizontalBlockSize * 4.3,
                right: AppConfig.horizontalBlockSize * 3),
            child: Text(
              "Video",
              maxLines: 1,
              style: TextStyle(
                fontSize: AppConfig.largeFont,
                color: Color(0xff000000),
              ),
            ),
          ),
          Container(
            height: AppConfig.verticalBlockSize * 33,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
            child: _getVideoList(),
          )
        ],
      ),
    );
  }

  Widget _getReviewSection() {
    return Container(
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Check what people are saying",
              style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
            ),
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2,
                horizontal: AppConfig.horizontalBlockSize * 2),
          ),
          Card(
              elevation: 10.0,
              margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                height: AppConfig.verticalBlockSize * 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        flex: 3,
                        child: Container(
                          height: AppConfig.verticalBlockSize * 18,
                          margin: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 0.2,
                              horizontal: AppConfig.horizontalBlockSize * 0.8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12)),
                            child: CustomWidgets().getImageFromUrl(
                                kDefaultImageUrl,
                                boxFit: BoxFit.fill),
                          ),
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 0.2),
                            child: Text(
                              CommonMethods.getStringInCamelCase(
                                  "Rahul Shukla"),
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                color: Color(0xff4E4E4E),
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Flexible(
                            child: Container(
                              child: Text(
                                "dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda dsdsads asdasdsa sdas dsdsad sadasdasd ada a  asaasdasda",
                                softWrap: true,
                                maxLines: 4,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xff4E4E4E),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String kDefaultImageUrl =
      'https://goqii.com/blog/wp-content/uploads/Doctor-Consultation.jpg';

  Widget _getVideoList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 3.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10))),
          child: Container(
            child: Column(
              children: [
                Container(
                  child: ClipRRect(
                    child: CustomWidgets().getImageFromUrl(kDefaultImageUrl),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  height: AppConfig.verticalBlockSize * 26,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppConfig.verticalBlockSize * 1.2),
                  width: AppConfig.horizontalBlockSize * 80,
                  child: Text(
                    "Video Name",
                    style:
                        TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        );
      },
      itemCount: 5,
    );
  }
}
