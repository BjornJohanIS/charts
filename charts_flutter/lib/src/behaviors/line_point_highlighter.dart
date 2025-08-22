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

import 'package:collection/collection.dart' show ListEquality;
import 'package:charts_common/common.dart' as common
    show
        ChartBehavior,
        LinePointHighlighter,
        LinePointHighlighterFollowLineType,
        SelectionModelType,
        SymbolRenderer;
import 'package:flutter/widgets.dart' show hashValues;
import 'package:meta/meta.dart' show immutable;

import 'chart_behavior.dart' show ChartBehavior, GestureType;

/// Chart behavior that monitors the specified [SelectionModel] and highlights
/// selected data points.
///
/// Typically used with bars, pies, and line charts, often in combination with
/// SelectNearest.
@immutable
class LinePointHighlighter<D> extends ChartBehavior<D> {
  final Set<GestureType> desiredGestures = {};

  final common.SelectionModelType? selectionModelType;
  final double? defaultRadiusPx;
  final double? radiusPaddingPx;
  final common.LinePointHighlighterFollowLineType? showHorizontalFollowLine;
  final common.LinePointHighlighterFollowLineType? showVerticalFollowLine;
  final List<int>? dashPattern;
  final bool? drawFollowLinesAcrossChart;
  final common.SymbolRenderer? symbolRenderer;

  LinePointHighlighter({
    this.selectionModelType,
    this.defaultRadiusPx,
    this.radiusPaddingPx,
    this.showHorizontalFollowLine,
    this.showVerticalFollowLine,
    this.dashPattern,
    this.drawFollowLinesAcrossChart,
    this.symbolRenderer,
  });

  @override
  common.LinePointHighlighter<D> createCommonBehavior() =>
      common.LinePointHighlighter<D>(
        selectionModelType: selectionModelType,
        defaultRadiusPx: defaultRadiusPx,
        radiusPaddingPx: radiusPaddingPx,
        showHorizontalFollowLine: showHorizontalFollowLine,
        showVerticalFollowLine: showVerticalFollowLine,
        dashPattern: dashPattern,
        drawFollowLinesAcrossChart: drawFollowLinesAcrossChart,
        symbolRenderer: symbolRenderer,
      );

  @override
  void updateCommonBehavior(common.ChartBehavior<D> commonBehavior) {}

  @override
  String get role => 'LinePointHighlighter-${selectionModelType.toString()}';

  @override
  bool operator ==(Object o) {
    return o is LinePointHighlighter &&
        defaultRadiusPx == o.defaultRadiusPx &&
        radiusPaddingPx == o.radiusPaddingPx &&
        showHorizontalFollowLine == o.showHorizontalFollowLine &&
        showVerticalFollowLine == o.showVerticalFollowLine &&
        selectionModelType == o.selectionModelType &&
        ListEquality().equals(dashPattern, o.dashPattern) &&
        drawFollowLinesAcrossChart == o.drawFollowLinesAcrossChart;
  }

  @override
  int get hashCode => hashValues(
        selectionModelType,
        defaultRadiusPx,
        radiusPaddingPx,
        showHorizontalFollowLine,
        showVerticalFollowLine,
        dashPattern,
        drawFollowLinesAcrossChart,
      );
}
