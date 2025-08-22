import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LineRangeAnnotationChart extends StatelessWidget {
  final List<charts.Series<dynamic, num>> seriesList;
  final bool animate;

  LineRangeAnnotationChart(this.seriesList, {this.animate = false});

  /// Creates a chart with sample data and range annotations.
  factory LineRangeAnnotationChart.withSampleData() {
    return LineRangeAnnotationChart(
      _createSampleData(),
      animate: false,
    );
  }

  /// Creates a chart with random data.
  factory LineRangeAnnotationChart.withRandomData() {
    return LineRangeAnnotationChart(_createRandomData());
  }

  /// Create random data for demonstration.
  static List<charts.Series<LinearSales, num>> _createRandomData() {
    final random = Random();
    final data = [
      LinearSales(0, random.nextInt(100)),
      LinearSales(1, random.nextInt(100)),
      LinearSales(2, random.nextInt(100)),
      LinearSales(3, 100), // fixed to consistently place annotation
    ];

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      seriesList,
      animate: animate,
      behaviors: [
        charts.RangeAnnotation([
          // Domain annotations
          charts.RangeAnnotationSegment(
            0.5, 1.0, charts.RangeAnnotationAxisType.domain,
            startLabel: 'Domain 1',
          ),
          charts.RangeAnnotationSegment(
            2, 4, charts.RangeAnnotationAxisType.domain,
            endLabel: 'Domain 2',
            color: charts.MaterialPalette.gray.shade200,
          ),
          // Measure annotations
          charts.RangeAnnotationSegment(
            15, 20, charts.RangeAnnotationAxisType.measure,
            startLabel: 'Measure 1 Start',
            endLabel: 'Measure 1 End',
            color: charts.MaterialPalette.gray.shade300,
          ),
          charts.RangeAnnotationSegment(
            35, 65, charts.RangeAnnotationAxisType.measure,
            startLabel: 'Measure 2 Start',
            endLabel: 'Measure 2 End',
            color: charts.MaterialPalette.gray.shade400,
          ),
        ]),
      ],
    );
  }

  /// Sample static data
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      LinearSales(0, 5),
      LinearSales(1, 25),
      LinearSales(2, 100),
      LinearSales(3, 75),
    ];

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Simple data type for demonstration
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
