// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:charts_common/common.dart' as common
    show
        BehaviorPosition,
        ChartBehavior,
        InsideJustification,
        LegendEntry,
        LegendTapHandling,
        MeasureFormatter,
        LegendDefaultMeasure,
        OutsideJustification,
        SeriesLegend,
        SelectionModelType,
        TextStyleSpec;
import 'package:collection/collection.dart' show ListEquality;
import 'package:flutter/widgets.dart' show BuildContext, EdgeInsets, Widget;
import 'package:meta/meta.dart' show immutable;

import '../../chart_container.dart' show ChartContainerRenderObject;
import '../chart_behavior.dart' show BuildableBehavior, ChartBehavior, GestureType;
import 'legend.dart' show TappableLegend;
import 'legend_content_builder.dart' show LegendContentBuilder, TabularLegendContentBuilder;
import 'legend_layout.dart' show TabularLegendLayout;

/// Series legend behavior for charts.
@immutable
class SeriesLegend<D> extends ChartBehavior<D> {
  static const defaultBehaviorPosition = common.BehaviorPosition.top;
  static const defaultOutsideJustification = common.OutsideJustification.startDrawArea;
  static const defaultInsideJustification = common.InsideJustification.topStart;

  final Set<GestureType> desiredGestures = {};

  final common.SelectionModelType? selectionModelType;
  final LegendContentBuilder contentBuilder;
  final common.BehaviorPosition position;
  final common.OutsideJustification outsideJustification;
  final common.InsideJustification insideJustification;
  final bool showMeasures;
  final common.LegendDefaultMeasure? legendDefaultMeasure;
  final common.MeasureFormatter? measureFormatter;
  final common.MeasureFormatter? secondaryMeasureFormatter;
  final common.TextStyleSpec? entryTextStyle;
  final List<String>? defaultHiddenSeries;

  static const defaultCellPadding = EdgeInsets.all(8.0);

  /// Default tabular layout legend.
  factory SeriesLegend({
    common.BehaviorPosition? position,
    common.OutsideJustification? outsideJustification,
    common.InsideJustification? insideJustification,
    bool? horizontalFirst,
    int? desiredMaxRows,
    int? desiredMaxColumns,
    EdgeInsets? cellPadding,
    List<String>? defaultHiddenSeries,
    bool? showMeasures,
    common.LegendDefaultMeasure? legendDefaultMeasure,
    common.MeasureFormatter? measureFormatter,
    common.MeasureFormatter? secondaryMeasureFormatter,
    common.TextStyleSpec? entryTextStyle,
  }) {
    position ??= defaultBehaviorPosition;
    outsideJustification ??= defaultOutsideJustification;
    insideJustification ??= defaultInsideJustification;
    cellPadding ??= defaultCellPadding;

    horizontalFirst ??= (position == common.BehaviorPosition.top ||
        position == common.BehaviorPosition.bottom ||
        position == common.BehaviorPosition.inside);

    final layoutBuilder = horizontalFirst
        ? TabularLegendLayout.horizontalFirst(
            desiredMaxColumns: desiredMaxColumns, cellPadding: cellPadding)
        : TabularLegendLayout.verticalFirst(
            desiredMaxRows: desiredMaxRows, cellPadding: cellPadding);

    return SeriesLegend._internal(
      contentBuilder: TabularLegendContentBuilder(legendLayout: layoutBuilder),
      selectionModelType: common.SelectionModelType.info,
      position: position,
      outsideJustification: outsideJustification,
      insideJustification: insideJustification,
      defaultHiddenSeries: defaultHiddenSeries,
      showMeasures: showMeasures ?? false,
      legendDefaultMeasure: legendDefaultMeasure ?? common.LegendDefaultMeasure.none,
      measureFormatter: measureFormatter,
      secondaryMeasureFormatter: secondaryMeasureFormatter,
      entryTextStyle: entryTextStyle,
    );
  }

  /// Custom layout legend.
  factory SeriesLegend.customLayout(
    LegendContentBuilder contentBuilder, {
    common.BehaviorPosition? position,
    common.OutsideJustification? outsideJustification,
    common.InsideJustification? insideJustification,
    List<String>? defaultHiddenSeries,
    bool? showMeasures,
    common.LegendDefaultMeasure? legendDefaultMeasure,
    common.MeasureFormatter? measureFormatter,
    common.MeasureFormatter? secondaryMeasureFormatter,
    common.TextStyleSpec? entryTextStyle,
  }) {
    position ??= defaultBehaviorPosition;
    outsideJustification ??= defaultOutsideJustification;
    insideJustification ??= defaultInsideJustification;

    return SeriesLegend._internal(
      contentBuilder: contentBuilder,
      selectionModelType: common.SelectionModelType.info,
      position: position,
      outsideJustification: outsideJustification,
      insideJustification: insideJustification,
      defaultHiddenSeries: defaultHiddenSeries,
      showMeasures: showMeasures ?? false,
      legendDefaultMeasure: legendDefaultMeasure ?? common.LegendDefaultMeasure.none,
      measureFormatter: measureFormatter,
      secondaryMeasureFormatter: secondaryMeasureFormatter,
      entryTextStyle: entryTextStyle,
    );
  }

  SeriesLegend._internal({
    required this.contentBuilder,
    this.selectionModelType,
    required this.position,
    required this.outsideJustification,
    required this.insideJustification,
    this.defaultHiddenSeries,
    required this.showMeasures,
    this.legendDefaultMeasure,
    this.measureFormatter,
    this.secondaryMeasureFormatter,
    this.entryTextStyle,
  });

  @override
  common.SeriesLegend<D> createCommonBehavior() => _FlutterSeriesLegend<D>(this);

  @override
  void updateCommonBehavior(common.ChartBehavior commonBehavior) {
    (commonBehavior as _FlutterSeriesLegend).config = this;
  }

  @override
  String get role => 'legend';

  @override
  bool operator ==(Object o) =>
      o is SeriesLegend &&
      selectionModelType == o.selectionModelType &&
      contentBuilder == o.contentBuilder &&
      position == o.position &&
      outsideJustification == o.outsideJustification &&
      insideJustification == o.insideJustification &&
      ListEquality().equals(defaultHiddenSeries, o.defaultHiddenSeries) &&
      showMeasures == o.showMeasures &&
      legendDefaultMeasure == o.legendDefaultMeasure &&
      measureFormatter == o.measureFormatter &&
      secondaryMeasureFormatter == o.secondaryMeasureFormatter &&
      entryTextStyle == o.entryTextStyle;

  @override
  int get hashCode => Object.hash(
        selectionModelType,
        contentBuilder,
        position,
        outsideJustification,
        insideJustification,
        defaultHiddenSeries == null ? null : Object.hashAll(defaultHiddenSeries!),
        showMeasures,
        legendDefaultMeasure,
        measureFormatter,
        secondaryMeasureFormatter,
        entryTextStyle,
      );
}

/// Flutter-specific wrapper for building the series legend widget.
class _FlutterSeriesLegend<D> extends common.SeriesLegend<D>
    implements BuildableBehavior, TappableLegend {
  SeriesLegend config;

  _FlutterSeriesLegend(this.config)
      : super(
          selectionModelType: config.selectionModelType,
          measureFormatter: config.measureFormatter,
          secondaryMeasureFormatter: config.secondaryMeasureFormatter,
          legendDefaultMeasure: config.legendDefaultMeasure,
        ) {
    super.defaultHiddenSeries = config.defaultHiddenSeries;
    super.entryTextStyle = config.entryTextStyle;
  }

  @override
  void updateLegend() => (chartContext as ChartContainerRenderObject).requestRebuild();

  @override
  common.BehaviorPosition get position => config.position;

  @override
  common.OutsideJustification get outsideJustification => config.outsideJustification;

  @override
  common.InsideJustification get insideJustification => config.insideJustification;

  @override
  Widget build(BuildContext context) {
    final hasSelection = legendState.legendEntries.any((e) => e.isSelected);

    final showMeasures = config.showMeasures &&
        (hasSelection || legendDefaultMeasure != common.LegendDefaultMeasure.none);

    return config.contentBuilder.build(context, legendState, this, showMeasures: showMeasures);
  }

  @override
  void onLegendEntryTapUp(common.LegendEntry detail) {
    switch (legendTapHandling) {
      case common.LegendTapHandling.hide:
        _toggleSeriesVisibility(detail);
        break;
      case common.LegendTapHandling.none:
      default:
        break;
    }
  }

  void _toggleSeriesVisibility(common.LegendEntry detail) {
    final seriesId = detail.series.id;

    if (isSeriesHidden(seriesId)) {
      showSeries(seriesId);
    } else {
      hideSeries(seriesId);
    }

    chart.redraw(skipLayout: true, skipAnimation: false);
  }
}
