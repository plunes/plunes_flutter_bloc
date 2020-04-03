import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/consultation_tests_procedure_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
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
  List<CatalogueData> _catalouges;
  String _failureCause;

  @override
  void initState() {
    _catalouges = [];
    _consultationBloc = ConsultationTestProcedureBloc();
    _getConsultations();
    super.initState();
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
              padding: CustomWidgets().getDefaultPaddingForScreens(),
              child: StreamBuilder<RequestState>(
                builder: (context, snapshot) {
                  if (snapshot.data is RequestFailed) {
                    RequestFailed _requestFailedObject = snapshot.data;
                    _failureCause = _requestFailedObject.failureCause;
                  }
                  if (snapshot.data is RequestSuccess) {
                    _catalouges = [];
                    RequestSuccess _requestSuccess = snapshot.data;
                    _catalouges = _requestSuccess.response;
                    if (_catalouges.isEmpty) {
                      _failureCause = PlunesStrings.consultationNotAvailable;
                    }
                  }
                  if (snapshot.data is RequestInProgress) {
                    return CustomWidgets().getProgressIndicator();
                  }
                  return _catalouges == null || _catalouges.isEmpty
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
        return CustomWidgets().getSolutionRow(_catalouges, index,
            onButtonTap: () => _onSolutionItemTap(index),
            onViewMoreTap: tapRecognizer);
      },
      shrinkWrap: true,
      itemCount: _catalouges.length,
    );
  }

  _onViewMoreTap(int index) {}

  _onSolutionItemTap(int index) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BiddingLoading()));
  }
}
