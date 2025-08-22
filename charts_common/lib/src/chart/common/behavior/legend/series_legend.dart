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
// distributed under the License. See the License for the specific language governing permissions and
// limitations under the License.

import 'package:meta/meta.dart' show protected;

import '../../../cartesian/axis/spec/axis_spec.dart' show TextStyleSpec;
import '../../datum_details.dart' show MeasureFormatter;
import '../../processed_series.dart' show MutableSeries;
import '../../selection_model/selection_model.dart' show SelectionModelType;
import 'legend.dart';
import 'legend_entry_generator.dart';
import 'per_series_legend_entry_generator.dart';

/// Series legend behavior for charts.
///
/// By default this behavior creates a legend entry per series.
class SeriesLegend<D> extends Legend<D> {
  /// List of currently hidden series, by ID.
  final _hiddenSeriesList = <String>{};

  /// List of series IDs that should be hidden by default.
  List<String>? _defaultHiddenSeries;

  /// List of series IDs that should not be hideable.
  List<String>? _alwaysVisibleSeries;

  /// Whether or not the series legend should show measures on datum selection.
  late bool _showMeasures;

  SeriesLegend({
    SelectionModelType? selectionModelType,
    LegendEntryGenerator<D>? legendEntryGenerator,
    MeasureFormatter? measureFormatter,
    MeasureFormatter? secondaryMeasureFormatter,
    bool? showMeasures,
    LegendDefaultMeasure? legendDefaultMeasure,
    TextStyleSpec? entryTextStyle,
  }) : super(
            selectionModelType: selectionModelType ?? SelectionModelType.info,
            legendEntryGenerator:
                legendEntryGenerator ?? PerSeriesLegendEntryGenerator(),
            entryTextStyle: entryTextStyle) {
    this.showMeasures = showMeasures;
    this.legendDefaultMeasure = legendDefaultMeasure;
    this.measureFormatter = measureFormatter;
    this.secondaryMeasureFormatter = secondaryMeasureFormatter;
  }

  /// Sets a list of series IDs that should be hidden by default on first chart draw.
  set defaultHiddenSeries(List<String>? defaultHiddenSeries) {
    _defaultHiddenSeries = defaultHiddenSeries;

    _hiddenSeriesList.clear();
    _defaultHiddenSeries?.forEach(hideSeries);
  }

  List<String>? get defaultHiddenSeries => _defaultHiddenSeries;

  /// Sets a list of series IDs that should always be visible.
  set alwaysVisibleSeries(List<String>? alwaysVisibleSeries) {
    _alwaysVisibleSeries = alwaysVisibleSeries;
    _alwaysVisibleSeries?.forEach(showSeries);
  }

  List<String>? get alwaysVisibleSeries => _alwaysVisibleSeries;

  bool get showMeasures => _showMeasures;

  set showMeasures(bool? showMeasures) {
    _showMeasures = showMeasures ?? false;
  }

  LegendDefaultMeasure get legendDefaultMeasure =>
      legendEntryGenerator.legendDefaultMeasure;

  set legendDefaultMeasure(LegendDefaultMeasure? legendDefaultMeasure) {
    legendEntryGenerator.legendDefaultMeasure =
        legendDefaultMeasure ?? LegendDefaultMeasure.none;
  }

  set measureFormatter(MeasureFormatter? formatter) {
    legendEntryGenerator.measureFormatter =
        formatter ?? defaultLegendMeasureFormatter;
  }

  set secondaryMeasureFormatter(MeasureFormatter? formatter) {
    legendEntryGenerator.secondaryMeasureFormatter =
        formatter ?? defaultLegendMeasureFormatter;
  }

  @override
  void onData(List<MutableSeries<D>> seriesList) {
    // Remove hidden series that no longer exist in the data.
    final seriesIds = seriesList.map((MutableSeries<D> series) => series.id);
    _hiddenSeriesList.removeWhere((id) => !seriesIds.contains(id));
  }

  @override
  void preProcessSeriesList(List<MutableSeries<D>> seriesList) {
    seriesList.removeWhere((series) => _hiddenSeriesList.contains(series.id));
  }

  @protected
  void hideSeries(String seriesId) {
    if (!isSeriesAlwaysVisible(seriesId)) {
      _hiddenSeriesList.add(seriesId);
    }
  }

  @protected
  void showSeries(String seriesId) {
    _hiddenSeriesList.remove(seriesId);
  }

  bool isSeriesHidden(String seriesId) => _hiddenSeriesList.contains(seriesId);

  bool isSeriesAlwaysVisible(String seriesId) =>
      _alwaysVisibleSeries?.contains(seriesId) ?? false;
}
