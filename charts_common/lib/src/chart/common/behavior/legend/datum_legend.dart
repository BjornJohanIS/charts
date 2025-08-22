// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// You may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import '../../../cartesian/axis/spec/axis_spec.dart' show TextStyleSpec;
import '../../datum_details.dart' show MeasureFormatter;
import '../../selection_model/selection_model.dart' show SelectionModelType;
import 'legend.dart';
import 'legend_entry_generator.dart';
import 'per_datum_legend_entry_generator.dart';

/// Datum legend behavior for charts.
///
/// By default this behavior creates one legend entry per datum in the first
/// series rendered on the chart.
class DatumLegend<D> extends Legend<D> {
  /// Whether or not the series legend should show measures on datum selection.
  late bool _showMeasures;

  DatumLegend({
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
              legendEntryGenerator ?? PerDatumLegendEntryGenerator<D>(),
          entryTextStyle: entryTextStyle,
        ) {
    // Calling the setters will automatically apply defaults.
    this.showMeasures = showMeasures;
    this.legendDefaultMeasure = legendDefaultMeasure;
    this.measureFormatter = measureFormatter;
    this.secondaryMeasureFormatter = secondaryMeasureFormatter;
  }

  /// Whether or not the legend should show measures.
  ///
  /// Defaults to false. Only shows measure if there is selected data.
  bool get showMeasures => _showMeasures;

  set showMeasures(bool? showMeasures) {
    _showMeasures = showMeasures ?? false;
  }

  /// Option to show measures when selection is null.
  LegendDefaultMeasure get legendDefaultMeasure =>
      legendEntryGenerator.legendDefaultMeasure;

  set legendDefaultMeasure(LegendDefaultMeasure? legendDefaultMeasure) {
    legendEntryGenerator.legendDefaultMeasure =
        legendDefaultMeasure ?? LegendDefaultMeasure.none;
  }

  /// Formatter for measure values.
  ///
  /// Defaults to `defaultLegendMeasureFormatter`.
  set measureFormatter(MeasureFormatter? formatter) {
    legendEntryGenerator.measureFormatter =
        formatter ?? defaultLegendMeasureFormatter;
  }

  /// Formatter for secondary axis measure values.
  set secondaryMeasureFormatter(MeasureFormatter? formatter) {
    legendEntryGenerator.secondaryMeasureFormatter =
        formatter ?? defaultLegendMeasureFormatter;
  }
}
