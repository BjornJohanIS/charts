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
        AnnotationLabelAnchor,
        AnnotationLabelDirection,
        AnnotationLabelPosition,
        AnnotationSegment,
        ChartBehavior,
        Color,
        MaterialPalette,
        RangeAnnotation,
        TextStyleSpec;
import 'package:flutter/widgets.dart' show hashValues;
import 'package:meta/meta.dart' show immutable;

import 'chart_behavior.dart' show ChartBehavior, GestureType;

/// Chart behavior that annotates domain ranges with a solid fill color.
///
/// Annotations are drawn underneath series data and chart axes.
/// Typically used in line charts to highlight sections of the data range.
@immutable
class RangeAnnotation<D> extends ChartBehavior<D> {
  final Set<GestureType> desiredGestures = {};

  /// List of annotations to render on the chart.
  final List<common.AnnotationSegment<Object>> annotations;

  /// Default label anchor configuration.
  final common.AnnotationLabelAnchor? defaultLabelAnchor;

  /// Default direction of label text.
  final common.AnnotationLabelDirection? defaultLabelDirection;

  /// Default position for labels relative to the annotation.
  final common.AnnotationLabelPosition? defaultLabelPosition;

  /// Default text style for labels.
  final common.TextStyleSpec? defaultLabelStyleSpec;

  /// Default color for annotation fill.
  final common.Color? defaultColor;

  /// Whether to extend the axis range to include annotation bounds.
  final bool? extendAxis;

  /// Padding around the label text.
  final int? labelPadding;

  /// Paint order for this behavior relative to other chart behaviors.
  final int? layoutPaintOrder;

  RangeAnnotation(
    this.annotations, {
    common.Color? defaultColor,
    this.defaultLabelAnchor,
    this.defaultLabelDirection,
    this.defaultLabelPosition,
    this.defaultLabelStyleSpec,
    this.extendAxis,
    this.labelPadding,
    this.layoutPaintOrder,
  }) : defaultColor = defaultColor ?? common.MaterialPalette.gray.shade100;

  @override
  common.RangeAnnotation<D> createCommonBehavior() =>
      common.RangeAnnotation<D>(
        annotations,
        defaultColor: defaultColor,
        defaultLabelAnchor: defaultLabelAnchor,
        defaultLabelDirection: defaultLabelDirection,
        defaultLabelPosition: defaultLabelPosition,
        defaultLabelStyleSpec: defaultLabelStyleSpec,
        extendAxis: extendAxis,
        labelPadding: labelPadding,
        layoutPaintOrder: layoutPaintOrder,
      );

  @override
  void updateCommonBehavior(common.ChartBehavior commonBehavior) {}

  @override
  String get role => 'RangeAnnotation';

  @override
  bool operator ==(Object o) {
    return o is RangeAnnotation &&
        ListEquality().equals(annotations, o.annotations) &&
        defaultColor == o.defaultColor &&
        extendAxis == o.extendAxis &&
        defaultLabelAnchor == o.defaultLabelAnchor &&
        defaultLabelDirection == o.defaultLabelDirection &&
        defaultLabelPosition == o.defaultLabelPosition &&
        defaultLabelStyleSpec == o.defaultLabelStyleSpec &&
        labelPadding == o.labelPadding &&
        layoutPaintOrder == o.layoutPaintOrder;
  }

  @override
  int get hashCode => hashValues(
        annotations,
        defaultColor,
        extendAxis,
        defaultLabelAnchor,
        defaultLabelDirection,
        defaultLabelPosition,
        defaultLabelStyleSpec,
        labelPadding,
        layoutPaintOrder,
      );
}
