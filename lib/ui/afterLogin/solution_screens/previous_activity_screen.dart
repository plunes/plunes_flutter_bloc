import 'package:flutter/material.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import '../../../Utils/app_config.dart';
import '../../../base/BaseActivity.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Activities'),
      ),
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
          child: _getMissedNagotiationView(),
        ),
      ],
    );
  }

  _getMissedNagotiationView() {
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
                        child: Text("You don't have any missed negotiations"),
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
                              missedSolutions, index,
                              onButtonTap: () => _onSolutionItemTap(index),
                              onViewMoreTap: tapRecognizer);
                        },
                        itemCount: missedSolutions.length,
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
                          child: Text("You don't have any previous activities"),
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
                                onButtonTap: () => _onSolutionItemTap(index),
                                onViewMoreTap: tapRecognizer);
                          },
                          itemCount: _prevSolutions.length,
                        ),
                      ),
                Container(
                    margin: EdgeInsets.symmetric(
                        vertical: AppConfig.verticalBlockSize * 2),
                    child: Text(
                      'Missed Negotiations',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
        _prevSearchedSolution.data.isNotEmpty)
      _prevSearchedSolution.data.forEach((solution) {
        if (solution.isActive == false) {
          missedSolutions.add(solution);
        } else {
          _prevSolutions.add(solution);
        }
      });
    _setState();
  }

  _onViewMoreTap(int index) {}

  _onSolutionItemTap(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BiddingLoading(
                  catalogueData: _prevSolutions[index],
                )));
  }

  void _setState() {
    if (mounted) setState(() {});
  }
}

Widget _reminderView() {
  return Card(
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
                  fontSize: 17,
                )),
          ),
        ],
      ),
    ),
  );
}

//class RowBlock extends StatelessWidget {
//  final String name;
//  final String btnName;
//  final bool isShow;
//
//  RowBlock(this.name, this.btnName, this.isShow);
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      margin: EdgeInsets.symmetric(horizontal: 20.0),
//      height: 100,
//      decoration: BoxDecoration(
//        border: Border(bottom: BorderSide(color: Colors.black)),
//      ),
//      child: Row(
//        children: <Widget>[
//          Container(
//              width: 50.0,
//              height: 50.0,
//              margin: EdgeInsets.all(10),
//              decoration: new BoxDecoration(
//                  shape: BoxShape.circle,
//                  image: new DecorationImage(
//                      fit: BoxFit.fill,
//                      image: new NetworkImage(
//                          "https://i.imgur.com/BoN9kdC.png")))),
//          Flexible(
//            child:
//                // 'Dentist Consultation and X-ray (Single Film)'
//                Text(name),
//          ),
//          FlatButton(
//            child: Text(btnName),
//            onPressed: () {
//              showDialog(
//                context: context,
//                builder: (BuildContext context) => DialogWidgets().buildAboutDialog(
//                    dialogTitle: '',
//                    dialogMsg:
//                        'Now you can have a multiple telephonic consltaoipn & one free vist'),
//              );
//            },
//            textColor: Theme.of(context).primaryColor,
//          ),
//        ],
//      ),
//    );
//  }
