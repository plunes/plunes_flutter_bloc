import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/consultation_tests_procedure_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/solution_show_price_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_solutions_screen.dart';

// ignore: must_be_immutable
class ConsultationScreen extends BaseActivity {
  @override
  _ConsultationState createState() => _ConsultationState();
}

// class _ConsultationState extends BaseState<ConsultationScreen> {
class _ConsultationState extends State<ConsultationScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  ConsultationTestProcedureBloc? _consultationBloc;
  List<CatalogueData>? _catalogueList;
  String? _failureCause;
  late bool _isProcessing;

  @override
  void initState() {
    _catalogueList = [];
    _failureCause="";
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
    _consultationBloc!.getConsultations().then((requestState) {
      if (requestState is RequestSuccess) {
        var _items = requestState.response;
        if (_items != null && _items!.isNotEmpty) {
          _catalogueList!.addAll(_items!);
        }
      } else if (requestState is RequestFailed) {
        _failureCause = requestState.failureCause ?? plunesStrings.somethingWentWrong;
      }
      _setState();
    });
  }
  void _setState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, PlunesStrings.consultations, true)
              as PreferredSizeWidget?,
          body: (Builder(builder: (context) {
            return Container(
                width: double.infinity,
                color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
                child: _showConsultationList()

                // StreamBuilder<RequestState>(
                //   builder: (context, snapshot) {
                //     if (snapshot.data is RequestFailed) {
                //       RequestFailed _requestFailedObject = snapshot.data as RequestFailed;
                //       _failureCause = _requestFailedObject.failureCause;
                //     }
                //     if (snapshot.data is RequestSuccess) {
                //       _catalogueList = [];
                //       RequestSuccess _requestSuccess = snapshot.data as RequestSuccess;
                //       _catalogueList = _requestSuccess.response;
                //       if (_catalogueList!.isEmpty) {
                //         _failureCause = PlunesStrings.consultationNotAvailable;
                //       }
                //     }
                //     if (snapshot.data is RequestInProgress) {
                //       return CustomWidgets().getProgressIndicator();
                //     }
                //     return _catalogueList == null || _catalogueList!.isEmpty
                //         ? CustomWidgets().errorWidget(_failureCause,
                //             onTap: () => _getConsultations())
                //         : _showConsultationList();
                //   },
                //   stream: _consultationBloc!.baseStream,
                //   initialData: RequestInProgress(),
                // ),
                );
          })),
        ));
  }

  Widget _showConsultationList() {
    if (_catalogueList!.isNotEmpty && _failureCause!.isEmpty) {
      return ListView.builder(
        itemBuilder: (context, index) {
          TapGestureRecognizer tapRecognizer = TapGestureRecognizer()
            ..onTap = () => _onViewMoreTap(index);
          return CustomWidgets().getSolutionRow(_catalogueList, index,
              onButtonTap: () => _onSolutionItemTap(index),
              onViewMoreTap: tapRecognizer);
        },
        shrinkWrap: true,
        itemCount: _catalogueList!.length,
      );
    } else if (_catalogueList!.isEmpty && _failureCause!.isNotEmpty) {
      return Center(
        child: Text(_failureCause.toString()),
      );
    } else {
      return CustomWidgets().getProgressIndicator();
    }
  }

  _onViewMoreTap(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomWidgets().buildViewMoreDialog(
        catalogueData: _catalogueList![index],
      ),
    );
  }

  _onSolutionItemTap(int index) async {
    var nowTime = DateTime.now();
    if (_catalogueList![index].solutionExpiredAt != null &&
        _catalogueList![index].solutionExpiredAt != 0) {
      var solExpireTime = DateTime.fromMillisecondsSinceEpoch(
          _catalogueList![index].solutionExpiredAt!);
      var diff = nowTime.difference(solExpireTime);
      if (diff.inSeconds < 5) {
        ///when price discovered and solution is active
        if (_catalogueList![index].priceDiscovered != null &&
            _catalogueList![index].priceDiscovered!) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SolutionShowPriceScreen(
                      catalogueData: _catalogueList![index], searchQuery: "")));
          return;
        } else {
          ///when price not discovered but solution is active
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewSolutionsScreen(
                      catalogueData: _catalogueList![index], searchQuery: "")));
          return;
        }
      }
    }
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
            builder: (context) => EnterAdditionalUserDetailScr(
                  _catalogueList![index],
                  "",
                  consultation: true,
                )));
  }
}
