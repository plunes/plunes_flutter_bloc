/// Example of a stacked area chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

// import 'package:intl/intl.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
// import 'package:plunes/ui/afterLogin/graphs/circle_rend.dart';

// class StackedAreaLineChart extends StatelessWidget {
//   final List<charts.Series> seriesList;
//   final bool animate;
//   static num _userPrice;
//
//   StackedAreaLineChart(this.seriesList, {this.animate});
//
//   /// Creates a [LineChart] with sample data and no transition.
//   factory StackedAreaLineChart.withSampleData(
//       List<DataPoint> points, num userPrice) {
//     _userPrice = userPrice;
//     return new StackedAreaLineChart(
//       _createSampleData(points),
//       // Disable animations for image tests.
//       animate: false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       ignoring: true,
//       child: new charts.LineChart(
//         seriesList,
//         defaultRenderer: new charts.LineRendererConfig(
//           includeArea: true,
//           stacked: true,
//           includeLine: true,
//           includePoints: true,
//           roundEndCaps: true,
//         ),
//         animate: animate,
//         primaryMeasureAxis: new charts.NumericAxisSpec(
//           tickProviderSpec: new charts.BasicNumericTickProviderSpec(
//               desiredTickCount: 4, zeroBound: false),
//           showAxisLine: true,
//           renderSpec: charts.SmallTickRendererSpec(
//               labelRotation: 0,
//               labelStyle: charts.TextStyleSpec(
//                 color: charts.Color.fromHex(code: "#9AA1A9"),
//               ),
//               axisLineStyle: charts.LineStyleSpec(
//                 color: charts.Color.white,
//                 thickness: 1,
//               )),
//         ),
//         domainAxis: charts.NumericAxisSpec(
//             tickProviderSpec: charts.BasicNumericTickProviderSpec(
//                 desiredTickCount: 4, zeroBound: false),
//             renderSpec: charts.SmallTickRendererSpec(
//                 labelRotation: 0,
//                 labelStyle: charts.TextStyleSpec(
//                   color: charts.Color.fromHex(code: "#9AA1A9"),
//                 ),
//                 axisLineStyle: charts.LineStyleSpec(
//                   color: charts.Color.white,
//                   thickness: 1,
//                 ))),
//         selectionModels: [
//           new charts.SelectionModelConfig(
//               type: charts.SelectionModelType.info,
//               changedListener: _changeCallBack)
//         ],
//         behaviors: [
//           new charts.InitialSelection(selectedDataConfig: [
//             new charts.SeriesDatumConfig<int>('Graph', _userPrice?.toInt() ?? 0)
//           ]),
//           new charts.LinePointHighlighter(
//               symbolRenderer: CustomCircleSymbolRenderer()),
//           charts.ChartTitle('Facility',
//               behaviorPosition: charts.BehaviorPosition.start,
//               innerPadding: 5,
//               titleOutsideJustification:
//                   charts.OutsideJustification.middleDrawArea,
//               titleStyleSpec: charts.TextStyleSpec(
//                   color: charts.Color.white, fontSize: 16)),
//           new charts.ChartTitle('Price',
//               behaviorPosition: charts.BehaviorPosition.bottom,
//               innerPadding: 5,
//               titleOutsideJustification:
//                   charts.OutsideJustification.middleDrawArea,
//               titleStyleSpec: charts.TextStyleSpec(
//                   color: charts.Color.white, fontSize: 16)),
//         ],
//       ),
//     );
//   }
//
//   /// Create one series with sample hard coded data.
//   static List<charts.Series<LinearSales, int>> _createSampleData(
//       List<DataPoint> points) {
//     points.sort((a, b) => a.x.compareTo(b.x));
//     List<LinearSales> _dataSeries = [];
// //    LinearSales(30,1),
// //    LinearSales(46,2),
// //    LinearSales(40,3),
// //    LinearSales(68,4),
// //    LinearSales(57,5)];
//     points.forEach((element) {
//       // print("element.x ${element.x}");
//       _dataSeries
//           .add(LinearSales(element.x?.toInt() ?? 0, element.y?.toInt() ?? 0));
//     });
//     return [
//       new charts.Series<LinearSales, int>(
//           id: 'Graph',
//           colorFn: (_, __) => charts.ColorUtil.fromDartColor(
//               Color(CommonMethods.getColorHexFromStr("#FF6C40"))
//                   .withOpacity(1)),
//           domainFn: (LinearSales sales, _) => sales.user?.toInt() ?? 0,
//           measureFn: (LinearSales sales, _) => sales.price?.toInt() ?? 0,
//           data: _dataSeries,
//           displayName: "Display name",
//           areaColorFn: (_, s) => charts.ColorUtil.fromDartColor(
//               Color(CommonMethods.getColorHexFromStr("#FF6C40"))
//                   .withOpacity(0.25))),
//     ];
//   }
//
//   void _changeCallBack(charts.SelectionModel<num> model) {
//     return;
//   }
// }

/// Sample linear data type.
class LinearSales {
  final num user;
  final num price;

  LinearSales(this.user, this.price);
}

/// Example of specifying a custom set of ticks to be used on the domain axis.
///
/// Specifying custom set of ticks allows specifying exactly what ticks are
/// used in the axis. Each tick is also allowed to have a different style set.
///
/// For an ordinal axis, the [StaticOrdinalTickProviderSpec] is shown in this
/// example defining ticks to be used with [TickSpec] of String.
///
/// For numeric axis, the [StaticNumericTickProviderSpec] can be used by passing
/// in a list of ticks defined with [TickSpec] of num.
///
/// For datetime axis, the [StaticDateTimeTickProviderSpec] can be used by
/// passing in a list of ticks defined with [TickSpec] of datetime.
class StaticallyProvidedTicks extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  static num _userPrice;
  static List<DataPoint> _dataPoints;

  StaticallyProvidedTicks(this.seriesList, {this.animate});

  factory StaticallyProvidedTicks.withSampleData(
      List<DataPoint> points, num userPrice) {
    _userPrice = userPrice;
    _dataPoints = points;
    return new StaticallyProvidedTicks(
      _createSampleData(points),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var _ticksOnxAxis = <charts.TickSpec<String>>[];
    if (_dataPoints != null && _dataPoints.isNotEmpty) {
      _dataPoints.forEach((element) {
        if (element != null && element.x != null && element.x == _userPrice) {
          _ticksOnxAxis.add(charts.TickSpec('$_userPrice',
              label: '$_userPrice',
              style: charts.TextStyleSpec(
                  color: charts.Color.fromHex(code: "#25B281"))));
        } else if (element != null && element.x != null) {
          _ticksOnxAxis.add(charts.TickSpec('${element.x}',
              style: charts.TextStyleSpec(color: charts.Color.white)));
        }
      });
    }
    return IgnorePointer(
      ignoring: true,
      child: charts.BarChart(
        seriesList,
        animate: animate,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: new charts.BasicNumericTickProviderSpec(
            desiredTickCount: 4,
            zeroBound: false,
          ),
          showAxisLine: true,
          renderSpec: charts.GridlineRendererSpec(
              labelRotation: 0,
              labelAnchor: charts.TickLabelAnchor.after,
              labelStyle: charts.TextStyleSpec(
                color: charts.Color.fromHex(code: "#9AA1A9"),
              ),
              axisLineStyle: charts.LineStyleSpec(
                color: charts.Color.white,
                thickness: 1,
              )),
        ),
        domainAxis: new charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
                labelRotation: 0,
                labelStyle: charts.TextStyleSpec(
                  color: charts.Color.fromHex(code: "#9AA1A9"),
                ),
                axisLineStyle: charts.LineStyleSpec(
                  color: charts.Color.white,
                  thickness: 1,
                )),
            tickProviderSpec:
                new charts.StaticOrdinalTickProviderSpec(_ticksOnxAxis)),
        behaviors: [
          new charts.InitialSelection(selectedDataConfig: [
            new charts.SeriesDatumConfig<String>('Graph', '$_userPrice')
          ]),
          charts.ChartTitle('Facility',
              behaviorPosition: charts.BehaviorPosition.start,
              innerPadding: 5,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea,
              titleStyleSpec: charts.TextStyleSpec(
                  color: charts.Color.white, fontSize: 16)),
          new charts.ChartTitle('Price',
              behaviorPosition: charts.BehaviorPosition.bottom,
              innerPadding: 5,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea,
              titleStyleSpec: charts.TextStyleSpec(
                  color: charts.Color.white, fontSize: 16)),
        ],
      ),
    );
  }

  static List<charts.Series<LinearSales, String>> _createSampleData(
      List<DataPoint> points) {
    points.sort((a, b) => a.x.compareTo(b.x));
    List<LinearSales> _dataSeries = [];
    points.forEach((element) {
      _dataSeries
          .add(LinearSales(element.x?.toInt() ?? 0, element.y?.toInt() ?? 0));
    });
    return [
      new charts.Series<LinearSales, String>(
        id: 'Graph',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
            Color(CommonMethods.getColorHexFromStr("#FF6C40")).withOpacity(1)),
        domainFn: (LinearSales sales, _) => sales.user?.toString() ?? "0",
        measureFn: (LinearSales sales, _) => sales.price?.toInt() ?? 0,
        data: _dataSeries,
        displayName: "Display name",
        areaColorFn: (_, s) => charts.ColorUtil.fromDartColor(
            Color(CommonMethods.getColorHexFromStr("#FF6C40"))
                .withOpacity(0.25)),
      ),
    ];
  }

// /// Create series list with single series
// static List<charts.Series<OrdinalSales, String>> _createSampleData() {
//   final globalSalesData = [
//     new OrdinalSales('2014', 5000),
//     new OrdinalSales('2015', 25000),
//     new OrdinalSales('2016', 100000),
//     new OrdinalSales('2017', 750000),
//   ];
//
//   return [
//     new charts.Series<OrdinalSales, String>(
//       id: 'Global Revenue',
//       domainFn: (OrdinalSales sales, _) => sales.year,
//       measureFn: (OrdinalSales sales, _) => sales.sales,
//       data: globalSalesData,
//     ),
//   ];
// }
}
