/// Example of a stacked area chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
import 'package:plunes/ui/afterLogin/graphs/circle_rend.dart';

class StackedAreaLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  static num _userPrice;

  StackedAreaLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory StackedAreaLineChart.withSampleData(
      List<DataPoint> points, num userPrice) {
    _userPrice = userPrice;
    return new StackedAreaLineChart(
      _createSampleData(points),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: new charts.LineChart(
        seriesList,
        defaultRenderer:
            new charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: animate,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: new charts.BasicNumericTickProviderSpec(
              desiredTickCount: 3, zeroBound: false),
          showAxisLine: true,
          renderSpec: charts.SmallTickRendererSpec(
              labelRotation: 0,
              labelStyle: charts.TextStyleSpec(
                color: charts.Color.white,
              ),
              axisLineStyle: charts.LineStyleSpec(
                color: charts.Color.white,
                thickness: 1,
              )),
        ),
        domainAxis: charts.NumericAxisSpec(
            tickProviderSpec: charts.BasicNumericTickProviderSpec(
                desiredTickCount: 0, zeroBound: false),
            renderSpec: charts.SmallTickRendererSpec(
                labelRotation: 0,
                labelStyle: charts.TextStyleSpec(
                  color: charts.Color.white,
                ),
                axisLineStyle: charts.LineStyleSpec(
                  color: charts.Color.white,
                  thickness: 1,
                ))),
        selectionModels: [
          new charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: _changeCallBack)
        ],
        behaviors: [
          new charts.InitialSelection(selectedDataConfig: [
            new charts.SeriesDatumConfig<int>('Graph', _userPrice?.toInt() ?? 0)
          ]),
          new charts.LinePointHighlighter(
              symbolRenderer: CustomCircleSymbolRenderer()),
          charts.ChartTitle('user',
              behaviorPosition: charts.BehaviorPosition.start,
              innerPadding: 5,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea,
              titleStyleSpec: charts.TextStyleSpec(
                  color: charts.Color.white, fontSize: 14)),
          new charts.ChartTitle('price',
              behaviorPosition: charts.BehaviorPosition.bottom,
              innerPadding: 0,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea,
              titleStyleSpec: charts.TextStyleSpec(
                  color: charts.Color.white, fontSize: 14)),
        ],
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData(
      List<DataPoint> points) {
    points.sort((a, b) => a.x.compareTo(b.x));
    List<LinearSales> _dataSeries = [];
//    LinearSales(30,1),
//    LinearSales(46,2),
//    LinearSales(40,3),
//    LinearSales(68,4),
//    LinearSales(57,5)];
    points.forEach((element) {
      print("element.x ${element.x}");
      _dataSeries
          .add(LinearSales(element.x?.toInt() ?? 0, element.y?.toInt() ?? 0));
    });
    return [
      new charts.Series<LinearSales, int>(
          id: 'Graph',
          colorFn: (_, __) =>
              charts.ColorUtil.fromDartColor(Colors.white.withOpacity(0.6)),
          domainFn: (LinearSales sales, _) => sales.user?.toInt() ?? 0,
          measureFn: (LinearSales sales, _) => sales.price?.toInt() ?? 0,
          data: _dataSeries,
          displayName: "Display name",
          areaColorFn: (_, s) => charts.ColorUtil.fromDartColor(
              Color(CommonMethods.getColorHexFromStr("#FFFFF"))
                  .withOpacity(0.2))),
    ];
  }

  void _changeCallBack(charts.SelectionModel<num> model) {
    return;
  }
}

/// Sample linear data type.
class LinearSales {
  final num user;
  final num price;

  LinearSales(this.user, this.price);
}
