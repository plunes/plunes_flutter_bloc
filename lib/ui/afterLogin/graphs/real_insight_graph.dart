/// Example of a stacked area chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/ui/afterLogin/graphs/circle_rend.dart';

class StackedAreaLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedAreaLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory StackedAreaLineChart.withSampleData() {
    return new StackedAreaLineChart(
      _createSampleData(),
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
            new charts.SeriesDatumConfig<int>('Graph', 2)
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
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    var myFakeMobileData = [
      new LinearSales(0, 15),
      new LinearSales(1, 75),
      new LinearSales(2, 300),
      new LinearSales(3, 225),
    ];

    return [
      new charts.Series<LinearSales, int>(
          id: 'Graph',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(
              Color(CommonMethods.getColorHexFromStr("#002448"))),
          domainFn: (LinearSales sales, _) => sales.user,
          measureFn: (LinearSales sales, _) => sales.price,
          data: myFakeMobileData,
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
  final int user;
  final int price;

  LinearSales(this.user, this.price);
}
