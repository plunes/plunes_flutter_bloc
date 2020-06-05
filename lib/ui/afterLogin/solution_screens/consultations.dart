import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/consultation_tests_procedure_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';

// ignore: must_be_immutable
class ConsultationScreen extends BaseActivity {
  @override
  _ConsultationState createState() => _ConsultationState();
}

class _ConsultationState extends BaseState<ConsultationScreen> {
  ConsultationTestProcedureBloc _consultationBloc;
  List<CatalogueData> _catalogueList;
  String _failureCause;

  @override
  void initState() {
    _catalogueList = [];
    _consultationBloc = ConsultationTestProcedureBloc();
    _getConsultations();
    super.initState();
  }

  @override
  void dispose() {
    _consultationBloc?.dispose();
    super.dispose();
  }

  _getConsultations() {
    _consultationBloc.getConsultations();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, PlunesStrings.consultations, true),
          body: (Builder(builder: (context) {
            return Container(
              width: double.infinity,
              //padding: CustomWidgets().getDefaultPaddingForScreens(),
              child: StreamBuilder<RequestState>(
                builder: (context, snapshot) {
                  if (snapshot.data is RequestFailed) {
                    RequestFailed _requestFailedObject = snapshot.data;
                    _failureCause = _requestFailedObject.failureCause;
                  }
                  if (snapshot.data is RequestSuccess) {
                    _catalogueList = [];
                    RequestSuccess _requestSuccess = snapshot.data;
                    _catalogueList = _requestSuccess.response;
                    if (_catalogueList.isEmpty) {
                      _failureCause = PlunesStrings.consultationNotAvailable;
                    }
                  }
                  if (snapshot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  return _catalogueList == null || _catalogueList.isEmpty
                      ? CustomWidgets().errorWidget(_failureCause)
                      : _showConsultationList();
                },
                stream: _consultationBloc.baseStream,
                initialData: RequestInProgress(),
              ),
            );
          })),
        ));
  }

  Widget _showConsultationList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
          ..onTap = () => _onViewMoreTap(index);
        return CustomWidgets().getSolutionRow(_catalogueList, index,
            onButtonTap: () => _onSolutionItemTap(index),
            onViewMoreTap: tapRecognizer);
      },
      shrinkWrap: true,
      itemCount: _catalogueList.length,
    );
  }

  _onViewMoreTap(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
        catalogueData: _catalogueList[index],
      ),
    );
  }

  _onSolutionItemTap(int index) async {
    if (!UserManager().getIsUserInServiceLocation()) {
      await showDialog(
          context: context,
          builder: (context) {
            return CustomWidgets().fetchLocationPopUp(context);
          },
          barrierDismissible: false);
      if (!UserManager().getIsUserInServiceLocation()) {
        return;
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BiddingLoading(
                  catalogueData: _catalogueList[index],
                )));
  }
}
