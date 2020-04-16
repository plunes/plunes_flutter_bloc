import 'package:flutter/material.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/consultation_tests_procedure_bloc.dart';
import 'package:plunes/models/solution_models/test_and_procedure_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/solution_screens/test_procedure_sub_screen.dart';

// ignore: must_be_immutable
class TestAndProcedureScreen extends BaseActivity {
  final String screenTitle;
  final bool isProcedure;

  TestAndProcedureScreen({this.screenTitle, this.isProcedure});

  @override
  _TestAndProcedureScreenState createState() => _TestAndProcedureScreenState();
}

class _TestAndProcedureScreenState extends BaseState<TestAndProcedureScreen> {
  ConsultationTestProcedureBloc _consultationTestProcedureBloc;
  List<TestAndProcedureResponseModel> _testAndProcedures;
  String _failureCause;

  @override
  void dispose() {
    _consultationTestProcedureBloc?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _testAndProcedures = [];
    _consultationTestProcedureBloc = ConsultationTestProcedureBloc();
    _getDetails();
    super.initState();
  }

  _getDetails() {
    _consultationTestProcedureBloc.getDetails(widget.isProcedure);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar: widget.getAppBar(
              context, widget.screenTitle ?? PlunesStrings.NA, true),
          body: Builder(builder: (context) {
            return Container(
                padding: CustomWidgets().getDefaultPaddingForScreens(),
                child: _renderTestAndProcedures());
          }),
        ));
  }

  Widget _renderTestAndProcedures() {
    return StreamBuilder<RequestState>(
      builder: (context, snapShot) {
        if (snapShot.data is RequestInProgress) {
          return CustomWidgets().getProgressIndicator();
        }
        if (snapShot.data is RequestSuccess) {
          RequestSuccess _requestSuccessObject = snapShot.data;
          _testAndProcedures = [];
          _testAndProcedures = _requestSuccessObject.response;
          if (_testAndProcedures.isEmpty) {
            if (widget.isProcedure) {
              _failureCause = PlunesStrings.proceduresNotAvailable;
            } else {
              _failureCause = PlunesStrings.testsNotAvailable;
            }
          }
        } else if (snapShot.data is RequestFailed) {
          RequestFailed _requestFailed = snapShot.data;
          _failureCause = _requestFailed.failureCause;
        }
        return _testAndProcedures == null || _testAndProcedures.isEmpty
            ? CustomWidgets().errorWidget(_failureCause)
            : _showItems();
      },
      stream: _consultationTestProcedureBloc.baseStream,
      initialData: RequestInProgress(),
    );
  }

  Widget _showItems() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CustomWidgets().getTestAndProcedureWidget(
            _testAndProcedures, index, () => onTap(_testAndProcedures[index]));
      },
      itemCount: _testAndProcedures.length,
    );
  }

  void onTap(TestAndProcedureResponseModel testAndProcedure) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestProcedureCatalogueScreen(
                  isProcedure: widget.isProcedure,
                  specialityId: testAndProcedure.specialityId,
                  title: testAndProcedure.sId,
                )));
  }
}
