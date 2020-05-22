import 'package:flutter/material.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_received_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/prev_missed_solution_bloc.dart';
import 'package:plunes/models/solution_models/previous_searched_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/Utils/app_config.dart';

// ignore: must_be_immutable
class PreviousActivity extends BaseActivity {
  @override
  _PreviousActivityState createState() => _PreviousActivityState();
}

class _PreviousActivityState extends BaseState<PreviousActivity> {
  PrevMissSolutionBloc _prevMissSolutionBloc;
  PrevSearchedSolution _prevSearchedSolution;
  List<CatalogueData> _prevSolutions = [], missedSolutions = [];

  @override
  void initState() {
    _prevSolutions = [];
    missedSolutions = [];
    _prevMissSolutionBloc = PrevMissSolutionBloc();
    _getPreviousSolutions();
    super.initState();
  }

  @override
  void dispose() {
    _prevMissSolutionBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.getAppBar(context, 'Previous Activities', true),
      body: _getWidgetBody(),
    );
  }

  Widget _getWidgetBody() {
    return Column(
      children: <Widget>[
        Container(
          child: _getPreviousView(),
        ),
        Container(
          child: _getMissedNegotiationView(),
        ),
      ],
    );
  }

  _getMissedNegotiationView() {
    return Expanded(child: StreamBuilder<Object>(builder: (context, snapshot) {
      return Card(
          margin: EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (_prevSearchedSolution == null ||
                      _prevSearchedSolution.data == null ||
                      _prevSearchedSolution.data.isEmpty ||
                      missedSolutions == null ||
                      missedSolutions.isEmpty)
                  ? Expanded(
                      child: Center(
                      child: Container(
                        child: Text(
                          "You don't have any missed negotiations",
                          style: TextStyle(fontSize: AppConfig.smallFont),
                        ),
                      ),
                    ))
                  : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        itemBuilder: (context, index) {
                          TapGestureRecognizer tapRecognizer =
                              TapGestureRecognizer()
                                ..onTap = () => _onViewMoreTap(index);
                          return Stack(
                            children: <Widget>[
                              CustomWidgets().getSolutionRow(
                                  missedSolutions, index,
                                  onButtonTap: () => _onSolutionItemTap(
                                      missedSolutions[index]),
                                  onViewMoreTap: tapRecognizer),
//                              Positioned.fill(
//                                child: Container(
//                                  decoration: BoxDecoration(
//                                      gradient: LinearGradient(
//                                          begin: FractionalOffset.topCenter,
//                                          end: FractionalOffset.bottomCenter,
//                                          colors: [
//                                        Colors.white10,
//                                        Colors.white70
//                                        // I don't know what Color this will be, so I can't use this
//                                      ])),
//                                  width: double.infinity,
//                                ),
//                              ),
                            ],
                          );
                        },
                        itemCount: missedSolutions?.length ?? 0,
                      ),
                    ),
              _reminderView(),
            ],
          ));
    }));
  }

  _getPreviousView() {
    return Expanded(
        child: Card(
            margin: EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (_prevSearchedSolution == null ||
                        _prevSearchedSolution.data == null ||
                        _prevSearchedSolution.data.isEmpty ||
                        _prevSolutions == null ||
                        _prevSolutions.isEmpty)
                    ? Expanded(
                        child: Center(
                        child: Container(
                          child: Text(
                            "You don't have any previous activities",
                            style: TextStyle(fontSize: AppConfig.smallFont),
                          ),
                        ),
                      ))
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0.0),
                          itemBuilder: (context, index) {
                            TapGestureRecognizer tapRecognizer =
                                TapGestureRecognizer()
                                  ..onTap = () => _onViewMoreTap(index);
                            return CustomWidgets().getSolutionRow(
                                _prevSolutions, index,
                                onButtonTap: () =>
                                    _onSolutionItemTap(_prevSolutions[index]),
                                onViewMoreTap: tapRecognizer);
                          },
                          itemCount: _prevSolutions?.length ?? 0,
                        ),
                      ),
                Container(
                    margin: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 2),
                    child: Text(
                      'Missed Negotiations',
                      style: TextStyle(
                          fontSize: AppConfig.mediumFont + 2,
                          fontWeight: FontWeight.w500),
                    ))
              ],
            )));
  }

  void _getPreviousSolutions() async {
    var requestState = await _prevMissSolutionBloc.getPreviousSolutions();
    if (requestState is RequestSuccess) {
      _prevSearchedSolution = requestState.response;
    }
    if (_prevSearchedSolution != null &&
        _prevSearchedSolution.data != null &&
        _prevSearchedSolution.data.isNotEmpty) {
      _prevSolutions = [];
      missedSolutions = [];
      _prevSearchedSolution.data.forEach((solution) {
        if (solution.isActive == false) {
          missedSolutions.add(solution);
        } else {
          _prevSolutions.add(solution);
        }
      });
    }
    _setState();
  }

  _onViewMoreTap(int index) {}

  _onSolutionItemTap(CatalogueData catalogueData) async {
    catalogueData.isFromNotification = true;
    if (catalogueData.createdAt != null &&
        catalogueData.createdAt != 0 &&
        DateTime.fromMillisecondsSinceEpoch(catalogueData.createdAt)
                .difference(DateTime.now())
                .inHours ==
            0) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SolutionReceivedScreen(catalogueData: catalogueData)));
    } else {
      catalogueData.isFromNotification = false;
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BiddingLoading(
                    catalogueData: catalogueData,
                  )));
    }
    _getPreviousSolutions();
  }

  void _setState() {
    if (mounted) setState(() {});
  }
}

Widget _reminderView() {
  return Card(
    color: Colors.white70,
    margin: EdgeInsets.all(15),
    child: Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
                'Please Make Sure You book within a short time, keeping in mind it is valid only for 1 hour',
                style: TextStyle(
                  fontSize: AppConfig.smallFont,
                )),
          ),
        ],
      ),
    ),
  );
}
