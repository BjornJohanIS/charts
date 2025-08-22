import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Line chart with a slider behavior that allows moving along the domain axis.
class SliderLine extends StatefulWidget {
  final List<charts.Series<dynamic, num>> seriesList;
  final bool animate;

  SliderLine(this.seriesList, {this.animate = false});

  /// Creates a chart with sample data.
  factory SliderLine.withSampleData() {
    return SliderLine(
      _createSampleData(),
      animate: false,
    );
  }

  /// Creates a chart with random data.
  factory SliderLine.withRandomData() {
    return SliderLine(_createRandomData());
  }

  static List<charts.Series<LinearSales, num>> _createRandomData() {
    final random = Random();
    final data = [
      LinearSales(0, random.nextInt(100)),
      LinearSales(1, random.nextInt(100)),
      LinearSales(2, random.nextInt(100)),
      LinearSales(3, random.nextInt(100)),
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

  @override
  State<SliderLine> createState() => _SliderLineState();
}

class _SliderLineState extends State<SliderLine> {
  num? _sliderDomainValue;
  String? _sliderDragState;
  Point<int>? _sliderPosition;

  void _onSliderChange(
    Point<int> point,
    dynamic domain,
    String roleId,
    charts.SliderListenerDragState dragState,
  ) {
    // Schedule a rebuild after the frame is drawn
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _sliderDomainValue = (domain * 10).round() / 10;
        _sliderDragState = dragState.toString();
        _sliderPosition = point;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      SizedBox(
        height: 150,
        child: charts.LineChart(
          widget.seriesList,
          animate: widget.animate,
          behaviors: [
            charts.Slider(
              initialDomainValue: 1.0,
              onChangeCallback: _onSliderChange,
            ),
          ],
        ),
      ),
    ];

    if (_sliderDomainValue != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('Slider domain value: $_sliderDomainValue'),
      ));
    }

    if (_sliderPosition != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('Slider position: ${_sliderPosition!.x}, ${_sliderPosition!.y}'),
      ));
    }

    if (_sliderDragState != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('Slider drag state: $_sliderDragState'),
      ));
    }

    return Column(children: children);
  }
}

/// Sample linear data type
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
