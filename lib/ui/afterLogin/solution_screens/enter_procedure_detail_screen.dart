import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/solution_models/more_facilities_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class EnterProcedureDetailScreen extends BaseActivity {
  final SearchSolutionBloc searchSolutionBloc;
  final List<MoreFacility> selectedItemList;

  EnterProcedureDetailScreen({this.searchSolutionBloc, this.selectedItemList});

  @override
  _EnterProcedureDetailScreenState createState() =>
      _EnterProcedureDetailScreenState();
}

class _EnterProcedureDetailScreenState
    extends BaseState<EnterProcedureDetailScreen> {
  TextEditingController _testDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar:
              widget.getAppBar(context, PlunesStrings.negotiateManually, true),
          body: Builder(builder: (context) {
            return StreamBuilder<RequestState>(
                stream:
                    widget.searchSolutionBloc.getManualBiddingAdditionStream(),
                builder: (context, snapshot) {
                  if (snapshot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  if (snapshot.data is RequestFailed) {
                    RequestFailed requestFailed = snapshot.data;
                    String errorMessage = requestFailed?.failureCause;
                    Future.delayed(Duration(milliseconds: 50)).then((value) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CustomWidgets().getInformativePopup(
                                globalKey: scaffoldKey, message: errorMessage);
                          });
                    });
                    widget.searchSolutionBloc
                        .addStateInManualBiddingAdditionStream(null);
                  } else if (snapshot.data is RequestSuccess) {
                    Future.delayed(Duration(milliseconds: 50)).then((value) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CustomWidgets()
                                .getManualBiddingEnterDetailsPopup(
                                    globalKey: scaffoldKey);
                          }).then((value) {
                        Navigator.pop(context, true);
                      });
                    });
                    widget.searchSolutionBloc
                        .addStateInManualBiddingAdditionStream(null);
                  }
                  return SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 10,
                              left: AppConfig.horizontalBlockSize * 5,
                              right: AppConfig.horizontalBlockSize * 5,
                              bottom: AppConfig.verticalBlockSize * 3.5),
                          child: Image.asset(
                            PlunesImages.enterTestAndProcedureDetailsImage,
                            width: AppConfig.horizontalBlockSize * 42,
                            height: AppConfig.verticalBlockSize * 12,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: AppConfig.horizontalBlockSize * 5),
                          child: Text(
                            PlunesStrings.makeSureTheDetailsText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                        "#575757"))
                                    .withOpacity(1),
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 5,
                              right: AppConfig.horizontalBlockSize * 5,
                              top: AppConfig.verticalBlockSize * 3.5,
                              bottom: AppConfig.verticalBlockSize * 2),
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                  child: TextField(
                                controller: _testDetailsController,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: PlunesColors.BLACKCOLOR),
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.red),
                                    ),
                                    disabledBorder: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: PlunesColors.GREENCOLOR),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.green),
                                    ),
                                    border: UnderlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                          width: 1,
                                        )),
                                    errorBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.black)),
                                    focusedErrorBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: PlunesColors.GREENCOLOR)),
                                    counterText: "",
                                    hintText: PlunesStrings
                                        .enterProcedureAndTestDetails,
                                    hintStyle: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.normal,
                                      color: Color(
                                              CommonMethods.getColorHexFromStr(
                                                  "#333333"))
                                          .withOpacity(0.5),
                                    )),
                                maxLines: null,
                                maxLength: 400,
                              ))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: AppConfig.verticalBlockSize * 1.5),
                          margin: EdgeInsets.symmetric(
                              horizontal: AppConfig.horizontalBlockSize * 32),
                          child: InkWell(
                            onTap: () {
                              if (_testDetailsController.text.trim().isEmpty) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CustomWidgets().getInformativePopup(
                                          globalKey: scaffoldKey,
                                          message: PlunesStrings
                                              .enterProcedureAndTestDetailsToReceiveBids);
                                    });
                                return;
                              }
                              widget.searchSolutionBloc.saveManualBiddingData(
                                  _testDetailsController.text.trim(),
                                  widget.selectedItemList);
                            },
                            child: CustomWidgets().getRoundedButton(
                              plunesStrings.submit,
                              AppConfig.horizontalBlockSize * 5,
                              PlunesColors.GREENCOLOR,
                              AppConfig.horizontalBlockSize * 10,
                              AppConfig.verticalBlockSize * 1,
                              PlunesColors.WHITECOLOR,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                });
          }),
        ));
  }
}
