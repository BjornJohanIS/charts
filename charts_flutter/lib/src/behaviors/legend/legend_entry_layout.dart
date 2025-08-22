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

import 'package:charts_common/common.dart' as common;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../symbol_renderer.dart';
import 'legend.dart' show TappableLegend;

/// Strategy for building one widget from one [common.LegendEntry].
abstract class LegendEntryLayout {
  Widget build(BuildContext context, common.LegendEntry legendEntry,
      TappableLegend legend, bool isHidden,
      {bool showMeasures});
}

/// Builds one legend entry as a row with symbol and label.
class SimpleLegendEntryLayout implements LegendEntryLayout {
  const SimpleLegendEntryLayout();

  Widget createSymbol(BuildContext context, common.LegendEntry legendEntry,
      TappableLegend legend, bool isHidden) {
    final materialSymbolSize = Size(12.0, 12.0);

    final entryColor = legendEntry.color;
    final color = entryColor == null ? null : Color(entryColor!.hex);

    final SymbolRendererBuilder symbolRendererBuilder =
        legendEntry.symbolRenderer is SymbolRendererBuilder
            ? legendEntry.symbolRenderer as SymbolRendererBuilder
            : SymbolRendererCanvas(
                legendEntry.symbolRenderer!, legendEntry.dashPattern);

    return GestureDetector(
      child: symbolRendererBuilder.build(
        context,
        size: materialSymbolSize,
        color: color,
        enabled: !isHidden,
      ),
      onTapUp: makeTapUpCallback(context, legendEntry, legend),
    );
  }

  Widget createLabel(BuildContext context, common.LegendEntry legendEntry,
      TappableLegend legend, bool isHidden) {
    final style =
        _convertTextStyle(isHidden, context, legendEntry.textStyle);

    return GestureDetector(
      child: Text(legendEntry.label, style: style),
      onTapUp: makeTapUpCallback(context, legendEntry, legend),
    );
  }

  Widget createMeasureValue(BuildContext context,
      common.LegendEntry legendEntry, TappableLegend legend, bool isHidden) {
    return GestureDetector(
      child: Text(legendEntry.formattedValue ?? ''),
      onTapUp: makeTapUpCallback(context, legendEntry, legend),
    );
  }

  @override
  Widget build(BuildContext context, common.LegendEntry legendEntry,
      TappableLegend legend, bool isHidden,
      {bool showMeasures = false}) {
    final rowChildren = <Widget>[];
    final padding = EdgeInsets.only(right: 8.0);

    final symbol = createSymbol(context, legendEntry, legend, isHidden);
    final label = createLabel(context, legendEntry, legend, isHidden);

    final measure = showMeasures
        ? createMeasureValue(context, legendEntry, legend, isHidden)
        : null;

    rowChildren.add(symbol);
    rowChildren.add(Container(padding: padding));
    rowChildren.add(label);
    if (measure != null) {
      rowChildren.add(Container(padding: padding));
      rowChildren.add(measure);
    }

    return Row(children: rowChildren);
  }

  GestureTapUpCallback makeTapUpCallback(BuildContext context,
      common.LegendEntry legendEntry, TappableLegend legend) {
    return (TapUpDetails d) {
      legend.onLegendEntryTapUp(legendEntry);
    };
  }

  bool operator ==(Object other) => other is SimpleLegendEntryLayout;

  int get hashCode => runtimeType.hashCode;

  TextStyle _convertTextStyle(
      bool isHidden, BuildContext context, common.TextStyleSpec? textStyle) {
    Color? color = textStyle?.color != null
        ? Color(textStyle!.color!.hex)
        : null;
    if (isHidden) {
      color ??= Theme.of(context).textTheme.bodyMedium?.color;
      color = color?.withOpacity(0.26);
    }

    return TextStyle(
      inherit: true,
      fontFamily: textStyle?.fontFamily,
      fontSize: textStyle?.fontSize?.toDouble(),
      color: color,
    );
  }
}
