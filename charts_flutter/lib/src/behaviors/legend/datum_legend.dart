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
        DatumLegend,
        InsideJustification,
        LegendEntry,
        MeasureFormatter,
        LegendDefaultMeasure,
        OutsideJustification,
        SelectionModelType,
        TextStyleSpec;
import 'package:flutter/widgets.dart' show BuildContext, EdgeInsets, Widget;
import 'package:meta/meta.dart' show immutable;
import '../../chart_container.dart' show ChartContainerRenderObject;
import '../chart_behavior.dart' show BuildableBehavior, ChartBehavior, GestureType;
import 'legend.dart' show TappableLegend;
import 'legend_content_builder.dart' show LegendContentBuilder, TabularLegendContentBuilder;
import 'legend_layout.dart' show TabularLegendLayout;

/// Datum legend behavior for charts.
///
/// By default this behavior creates one legend entry per datum in the first
/// series rendered on the chart.
@immutable
class DatumLegend<D> extends ChartBehavior<D> {
  static const defaultBehaviorPosition = common.BehaviorPosition.top;
  static const defaultOutsideJustification =
      common.OutsideJustification.startDrawArea;
  static const defaultInsideJustification = common.InsideJustification.topStart;
  static const defaultCellPadding = EdgeInsets.all(8.0);

  final Set<GestureType> desiredGestures = {};

  final _DatumLegendConfig _config;

  /// Constructs a tabular legend with default layout.
  factory DatumLegend({
    common.BehaviorPosition? position,
    common.OutsideJustification? outsideJustification,
    common.InsideJustification? insideJustification,
    bool? horizontalFirst,
    int? desiredMaxRows,
    int? desiredMaxColumns,
    EdgeInsets? cellPadding,
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

    return DatumLegend._internal(
      config: _DatumLegendConfig(
        contentBuilder: TabularLegendContentBuilder(legendLayout: layoutBuilder),
        selectionModelType: common.SelectionModelType.info,
        position: position,
        outsideJustification: outsideJustification,
        insideJustification: insideJustification,
        showMeasures: showMeasures ?? false,
        legendDefaultMeasure:
            legendDefaultMeasure ?? common.LegendDefaultMeasure.none,
        measureFormatter: measureFormatter,
        secondaryMeasureFormatter: secondaryMeasureFormatter,
        entryTextStyle: entryTextStyle,
      ),
    );
  }

  /// Constructs a legend with custom layout builder.
  factory DatumLegend.customLayout(
    LegendContentBuilder contentBuilder, {
    common.BehaviorPosition? position,
    common.OutsideJustification? outsideJustification,
    common.InsideJustification? insideJustification,
    bool? showMeasures,
    common.LegendDefaultMeasure? legendDefaultMeasure,
    common.MeasureFormatter? measureFormatter,
    common.MeasureFormatter? secondaryMeasureFormatter,
    common.TextStyleSpec? entryTextStyle,
  }) {
    position ??= defaultBehaviorPosition;
    outsideJustification ??= defaultOutsideJustification;
    insideJustification ??= defaultInsideJustification;

    return DatumLegend._internal(
      config: _DatumLegendConfig(
        contentBuilder: contentBuilder,
        selectionModelType: common.SelectionModelType.info,
        position: position,
        outsideJustification: outsideJustification,
        insideJustification: insideJustification,
        showMeasures: showMeasures ?? false,
        legendDefaultMeasure:
            legendDefaultMeasure ?? common.LegendDefaultMeasure.none,
        measureFormatter: measureFormatter,
        secondaryMeasureFormatter: secondaryMeasureFormatter,
        entryTextStyle: entryTextStyle,
      ),
    );
  }

  DatumLegend._internal({required _DatumLegendConfig config}) : _config = config;

  @override
  common.DatumLegend<D> createCommonBehavior() => _FlutterDatumLegend<D>(this);

  @override
  void updateCommonBehavior(common.DatumLegend<D> commonBehavior) {
    (commonBehavior as _FlutterDatumLegend<D>).config = this;
  }

  @override
  String get role => 'legend';

  @override
  bool operator ==(Object o) {
    return o is DatumLegend && _config == o._config;
  }

  @override
  int get hashCode => _config.hashCode;

  // Expose config for internal use
  _DatumLegendConfig get config => _config;
}

/// Private configuration object for DatumLegend.
@immutable
class _DatumLegendConfig {
  final LegendContentBuilder contentBuilder;
  final common.SelectionModelType? selectionModelType;
  final common.BehaviorPosition position;
  final common.OutsideJustification outsideJustification;
  final common.InsideJustification insideJustification;
  final bool showMeasures;
  final common.LegendDefaultMeasure? legendDefaultMeasure;
  final common.MeasureFormatter? measureFormatter;
  final common.MeasureFormatter? secondaryMeasureFormatter;
  final common.TextStyleSpec? entryTextStyle;

  const _DatumLegendConfig({
    required this.contentBuilder,
    required this.selectionModelType,
    required this.position,
    required this.outsideJustification,
    required this.insideJustification,
    required this.showMeasures,
    required this.legendDefaultMeasure,
    required this.measureFormatter,
    required this.secondaryMeasureFormatter,
    required this.entryTextStyle,
  });

  @override
  bool operator ==(Object o) {
    return o is _DatumLegendConfig &&
        contentBuilder == o.contentBuilder &&
        selectionModelType == o.selectionModelType &&
        position == o.position &&
        outsideJustification == o.outsideJustification &&
        insideJustification == o.insideJustification &&
        showMeasures == o.showMeasures &&
        legendDefaultMeasure == o.legendDefaultMeasure &&
        measureFormatter == o.measureFormatter &&
        secondaryMeasureFormatter == o.secondaryMeasureFormatter &&
        entryTextStyle == o.entryTextStyle;
  }

  @override
  int get hashCode => Object.hash(
        contentBuilder,
        selectionModelType,
        position,
        outsideJustification,
        insideJustification,
        showMeasures,
        legendDefaultMeasure,
        measureFormatter,
        secondaryMeasureFormatter,
        entryTextStyle,
      );
}

/// Flutter-specific wrapper for DatumLegend.
class _FlutterDatumLegend<D> extends common.DatumLegend<D>
    implements BuildableBehavior, TappableLegend {
  DatumLegend<D> config;

  _FlutterDatumLegend(this.config)
      : super(
          selectionModelType: config.config.selectionModelType,
          measureFormatter: config.config.measureFormatter,
          secondaryMeasureFormatter: config.config.secondaryMeasureFormatter,
          legendDefaultMeasure: config.config.legendDefaultMeasure,
        ) {
    super.entryTextStyle = config.config.entryTextStyle;
  }

  @override
  void updateLegend() {
    (chartContext as ChartContainerRenderObject).requestRebuild();
  }

  @override
  common.BehaviorPosition get position => config.config.position;

  @override
  common.OutsideJustification get outsideJustification =>
      config.config.outsideJustification;

  @override
  common.InsideJustification get insideJustification =>
      config.config.insideJustification;

  @override
  Widget build(BuildContext context) {
    final hasSelection =
        legendState.legendEntries.any((entry) => entry.isSelected);

    final showMeasures = config.config.showMeasures &&
        (hasSelection ||
            legendDefaultMeasure != common.LegendDefaultMeasure.none);

    return config.config.contentBuilder
        .build(context, legendState, this, showMeasures: showMeasures);
  }

  @override
  onLegendEntryTapUp(common.LegendEntry detail) {}
}
