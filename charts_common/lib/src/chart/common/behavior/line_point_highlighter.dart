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
// distributed under the License. distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND.

import 'dart:collection' show LinkedHashMap;
import 'dart:math' show max, min, Point, Rectangle;

import 'package:meta/meta.dart';
import '../../../common/color.dart' show Color;
import '../../../common/graphics_factory.dart' show GraphicsFactory;
import '../../../common/math.dart' show NullablePoint;
import '../../../common/style/style_factory.dart' show StyleFactory;
import '../../../common/symbol_renderer.dart' show CircleSymbolRenderer, SymbolRenderer;
import '../../cartesian/axis/axis.dart' show ImmutableAxis, domainAxisKey, measureAxisKey;
import '../../cartesian/cartesian_chart.dart' show CartesianChart;
import '../../layout/layout_view.dart' show LayoutPosition, LayoutView, LayoutViewConfig, LayoutViewPaintOrder, ViewMeasuredSizes;
import '../base_chart.dart' show BaseChart, LifecycleListener;
import '../chart_canvas.dart' show ChartCanvas, getAnimatedColor;
import '../processed_series.dart' show ImmutableSeries;
import '../selection_model/selection_model.dart' show SelectionModel, SelectionModelType;
import 'chart_behavior.dart' show ChartBehavior;

/// Chart behavior that highlights selected points in line charts
/// with optional vertical/horizontal follow lines.
class LinePointHighlighter<D> implements ChartBehavior<D> {
  final SelectionModelType selectionModelType;
  final double defaultRadiusPx;
  final double radiusPaddingPx;
  final LinePointHighlighterFollowLineType showHorizontalFollowLine;
  final LinePointHighlighterFollowLineType showVerticalFollowLine;
  final List<int>? dashPattern;
  final bool drawFollowLinesAcrossChart;
  final SymbolRenderer symbolRenderer;

  late BaseChart<D> _chart;
  late _LinePointLayoutView<D> _view;
  late LifecycleListener<D> _lifecycleListener;

  /// Map of points currently rendered on the chart
  var _seriesPointMap = LinkedHashMap<String, _AnimatedPoint<D>>();
  final _currentKeys = <String>[];

  LinePointHighlighter({
    SelectionModelType? selectionModelType,
    double? defaultRadiusPx,
    double? radiusPaddingPx,
    LinePointHighlighterFollowLineType? showHorizontalFollowLine,
    LinePointHighlighterFollowLineType? showVerticalFollowLine,
    List<int>? dashPattern,
    bool? drawFollowLinesAcrossChart,
    SymbolRenderer? symbolRenderer,
  })  : selectionModelType = selectionModelType ?? SelectionModelType.info,
        defaultRadiusPx = defaultRadiusPx ?? 4.0,
        radiusPaddingPx = radiusPaddingPx ?? 2.0,
        showHorizontalFollowLine = showHorizontalFollowLine ?? LinePointHighlighterFollowLineType.none,
        showVerticalFollowLine = showVerticalFollowLine ?? LinePointHighlighterFollowLineType.nearest,
        dashPattern = dashPattern ?? [1, 3],
        drawFollowLinesAcrossChart = drawFollowLinesAcrossChart ?? true,
        symbolRenderer = symbolRenderer ?? CircleSymbolRenderer() {
    _lifecycleListener = LifecycleListener<D>(onAxisConfigured: _updateViewData);
  }

  @override
  void attachTo(BaseChart<D> chart) {
    _chart = chart;

    _view = _LinePointLayoutView<D>(
      chart: chart,
      layoutPaintOrder: LayoutViewPaintOrder.linePointHighlighter,
      showHorizontalFollowLine: showHorizontalFollowLine,
      showVerticalFollowLine: showVerticalFollowLine,
      dashPattern: dashPattern,
      drawFollowLinesAcrossChart: drawFollowLinesAcrossChart,
      symbolRenderer: symbolRenderer,
    );

    if (chart is CartesianChart) {
      assert(chart.vertical); // Only vertical charts supported
    }

    chart.addView(_view);
    chart.addLifecycleListener(_lifecycleListener);
    chart.getSelectionModel(selectionModelType).addSelectionChangedListener(_selectionChanged);
  }

  @override
  void removeFrom(BaseChart<D> chart) {
    chart.removeView(_view);
    chart.getSelectionModel(selectionModelType).removeSelectionChangedListener(_selectionChanged);
    chart.removeLifecycleListener(_lifecycleListener);
  }

  void _selectionChanged(SelectionModel<D> selectionModel) {
    _chart.redraw(skipLayout: true, skipAnimation: true);
  }

  void _updateViewData() {
    _currentKeys.clear();
    final selectedDatumDetails = _chart.getSelectedDatumDetails(selectionModelType);
    final newSeriesMap = LinkedHashMap<String, _AnimatedPoint<D>>();

    for (final detail in selectedDatumDetails) {
      if (detail == null) continue;
      final series = detail.series!;
      final datum = detail.datum;
      final domainAxis = series.getAttr(domainAxisKey) as ImmutableAxis<D>;
      final measureAxis = series.getAttr(measureAxisKey) as ImmutableAxis<num>;

      final lineKey = series.id;
      final radiusPx = (detail.radiusPx != null) ? detail.radiusPx!.toDouble() + radiusPaddingPx : defaultRadiusPx;
      final pointKey = '$lineKey::${detail.domain}::${detail.measure}';

      _AnimatedPoint<D> animatingPoint;
      if (_seriesPointMap.containsKey(pointKey)) {
        animatingPoint = _seriesPointMap[pointKey]!;
      } else {
        final point = _DatumPoint<D>(
          datum: datum,
          domain: detail.domain,
          series: series,
          x: domainAxis.getLocation(detail.domain),
          y: measureAxis.getLocation(0.0),
        );
        animatingPoint = _AnimatedPoint<D>(key: pointKey, overlaySeries: series.overlaySeries)
          ..setNewTarget(_PointRendererElement<D>(
            point: point,
            color: detail.color,
            fillColor: detail.fillColor,
            radiusPx: radiusPx,
            measureAxisPosition: measureAxis.getLocation(0.0),
            strokeWidthPx: detail.strokeWidthPx,
            symbolRenderer: detail.symbolRenderer,
          ));
      }

      newSeriesMap[pointKey] = animatingPoint;

      final point = _DatumPoint<D>(
        datum: datum,
        domain: detail.domain,
        series: series,
        x: detail.chartPosition!.x,
        y: detail.chartPosition!.y,
      );

      _currentKeys.add(pointKey);

      final pointElement = _PointRendererElement<D>(
        point: point,
        color: detail.color,
        fillColor: detail.fillColor,
        radiusPx: radiusPx,
        measureAxisPosition: measureAxis.getLocation(0.0),
        strokeWidthPx: detail.strokeWidthPx,
        symbolRenderer: detail.symbolRenderer,
      );

      animatingPoint.setNewTarget(pointElement);
    }

    // Animate out points no longer present
    _seriesPointMap.forEach((key, point) {
      if (!_currentKeys.contains(point.key)) {
        point.animateOut();
        newSeriesMap[point.key] = point;
      }
    });

    _seriesPointMap = newSeriesMap;
    _view.seriesPointMap = _seriesPointMap;
  }

  @override
  String get role => 'LinePointHighlighter-$selectionModelType';
}

/// Layout view for drawing the highlight points and follow lines.
class _LinePointLayoutView<D> extends LayoutView {
  final LayoutViewConfig layoutConfig;
  final LinePointHighlighterFollowLineType showHorizontalFollowLine;
  final LinePointHighlighterFollowLineType showVerticalFollowLine;
  final BaseChart<D> chart;
  final List<int>? dashPattern;
  late Rectangle<int> _drawAreaBounds;
  final bool drawFollowLinesAcrossChart;
  final SymbolRenderer symbolRenderer;

  LinkedHashMap<String, _AnimatedPoint<D>>? _seriesPointMap;

  _LinePointLayoutView({
    required this.chart,
    required int layoutPaintOrder,
    required this.showHorizontalFollowLine,
    required this.showVerticalFollowLine,
    required this.symbolRenderer,
    required this.dashPattern,
    required this.drawFollowLinesAcrossChart,
  }) : layoutConfig = LayoutViewConfig(
          paintOrder: LayoutViewPaintOrder.linePointHighlighter,
          position: LayoutPosition.DrawArea,
          positionOrder: layoutPaintOrder,
        );

  set seriesPointMap(LinkedHashMap<String, _AnimatedPoint<D>>? value) => _seriesPointMap = value;

  @override
  ViewMeasuredSizes? measure(int maxWidth, int maxHeight) => null;

  @override
  void layout(Rectangle<int> componentBounds, Rectangle<int> drawAreaBounds) {
    _drawAreaBounds = drawAreaBounds;
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    final seriesPointMap = _seriesPointMap;
    if (seriesPointMap == null) return;

    // Clean up points no longer in data
    if (animationPercent == 1.0) {
      final keysToRemove = <String>[];
      seriesPointMap.forEach((key, point) {
        if (point.animatingOut) keysToRemove.add(key);
      });
      keysToRemove.forEach(seriesPointMap.remove);
    }

    final points = <_PointRendererElement<D>>[];
    seriesPointMap.forEach((key, point) {
      points.add(point.getCurrentPoint(animationPercent));
    });

    // Follow lines calculations
    final endPointPerValueVertical = <int, int>{};
    final endPointPerValueHorizontal = <int, int>{};

    for (final pointElement in points) {
      if (pointElement.point.x == null || pointElement.point.y == null) continue;
      final point = pointElement.point.toPoint();
      final roundedX = point.x.round();
      final roundedY = point.y.round();

      if (endPointPerValueVertical[roundedX] == null) {
        endPointPerValueVertical[roundedX] = roundedY;
      } else if (showVerticalFollowLine != LinePointHighlighterFollowLineType.nearest) {
        endPointPerValueVertical[roundedX] = min(endPointPerValueVertical[roundedX]!, roundedY);
      }

      if (endPointPerValueHorizontal[roundedY] == null) {
        endPointPerValueHorizontal[roundedY] = roundedX;
      } else if (showHorizontalFollowLine != LinePointHighlighterFollowLineType.nearest) {
        endPointPerValueHorizontal[roundedY] = max(endPointPerValueHorizontal[roundedY]!, roundedX);
      }
    }

    var shouldShowHorizontalFollowLine = showHorizontalFollowLine == LinePointHighlighterFollowLineType.all ||
        showHorizontalFollowLine == LinePointHighlighterFollowLineType.nearest;
    var shouldShowVerticalFollowLine = showVerticalFollowLine == LinePointHighlighterFollowLineType.all ||
        showVerticalFollowLine == LinePointHighlighterFollowLineType.nearest;

    final paintedHorizontalLinePositions = <num>[];
    final paintedVerticalLinePositions = <num>[];

    final drawBounds = chart.drawableLayoutAreaBounds;
    final rtl = chart.context.isRtl;

    // Draw follow lines first
    for (final pointElement in points) {
      if (pointElement.point.x == null || pointElement.point.y == null) continue;
      final point = pointElement.point.toPoint();
      final roundedX = point.x.round();
      final roundedY = point.y.round();

      // Horizontal follow line
      if (shouldShowHorizontalFollowLine && !paintedHorizontalLinePositions.contains(roundedY)) {
        final leftBound = drawFollowLinesAcrossChart ? drawBounds.left : (rtl ? endPointPerValueHorizontal[roundedY]! : drawBounds.left);
        final rightBound = drawFollowLinesAcrossChart ? drawBounds.left + drawBounds.width : (rtl ? drawBounds.left + drawBounds.width : endPointPerValueHorizontal[roundedY]!);

        canvas.drawLine(
          points: [Point<num>(leftBound, point.y), Point<num>(rightBound, point.y)],
          stroke: StyleFactory.style.linePointHighlighterColor,
          strokeWidthPx: 1.0,
          dashPattern: dashPattern,
        );

        if (showHorizontalFollowLine == LinePointHighlighterFollowLineType.nearest) shouldShowHorizontalFollowLine = false;
        paintedHorizontalLinePositions.add(roundedY);
      }

      // Vertical follow line
      if (shouldShowVerticalFollowLine && !paintedVerticalLinePositions.contains(roundedX)) {
        final topBound = drawFollowLinesAcrossChart ? drawBounds.top : endPointPerValueVertical[roundedX]!;

        canvas.drawLine(
          points: [Point<num>(point.x, topBound), Point<num>(point.x, drawBounds.top + drawBounds.height)],
          stroke: StyleFactory.style.linePointHighlighterColor,
          strokeWidthPx: 1.0,
          dashPattern: dashPattern,
        );

        if (showVerticalFollowLine == LinePointHighlighterFollowLineType.nearest) shouldShowVerticalFollowLine = false;
        paintedVerticalLinePositions.add(roundedX);
      }

      if (!shouldShowHorizontalFollowLine && !shouldShowVerticalFollowLine) break;
    }

    // Draw highlight dots
    for (final pointElement in points) {
      if (pointElement.point.x == null || pointElement.point.y == null) continue;
      final point = pointElement.point.toPoint();
      final bounds = Rectangle<double>(
        point.x - pointElement.radiusPx,
        point.y - pointElement.radiusPx,
        pointElement.radiusPx * 2,
        pointElement.radiusPx * 2,
      );

      (pointElement.symbolRenderer ?? symbolRenderer).paint(canvas, bounds,
          fillColor: pointElement.fillColor, strokeColor: pointElement.color, strokeWidthPx: pointElement.strokeWidthPx);
    }
  }

  @override
  Rectangle<int> get componentBounds => _drawAreaBounds;

  @override
  bool get isSeriesRenderer => false;
}

/// Highlighted point in the chart
class _DatumPoint<D> extends NullablePoint {
  final dynamic datum;
  final D? domain;
  final ImmutableSeries<D>? series;

  _DatumPoint({this.datum, this.domain, this.series, double? x, double? y}) : super(x, y);

  factory _DatumPoint.from(_DatumPoint<D> other, [double? x, double? y]) {
    return _DatumPoint<D>(datum: other.datum, domain: other.domain, series: other.series, x: x ?? other.x, y: y ?? other.y);
  }
}

class _PointRendererElement<D> {
  _DatumPoint<D> point;
  Color? color;
  Color? fillColor;
  double radiusPx;
  double? measureAxisPosition;
  double? strokeWidthPx;
  SymbolRenderer? symbolRenderer;

  _PointRendererElement({
    required this.point,
    required this.color,
    required this.fillColor,
    required this.radiusPx,
    required this.measureAxisPosition,
    required this.strokeWidthPx,
    required this.symbolRenderer,
  });

  _PointRendererElement<D> clone() {
    return _PointRendererElement<D>(
      point: point,
      color: color,
      fillColor: fillColor,
      measureAxisPosition: measureAxisPosition,
      radiusPx: radiusPx,
      strokeWidthPx: strokeWidthPx,
      symbolRenderer: symbolRenderer,
    );
  }

  void updateAnimationPercent(_PointRendererElement<D> previous, _PointRendererElement<D> target, double animationPercent) {
    final targetPoint = target.point;
    final previousPoint = previous.point;

    final x = _lerpDouble(previousPoint.x, targetPoint.x, animationPercent);
    final y = _lerpDouble(previousPoint.y, targetPoint.y, animationPercent);

    point = _DatumPoint<D>.from(targetPoint, x, y);

    color = getAnimatedColor(previous.color!, target.color!, animationPercent);
    fillColor = getAnimatedColor(previous.fillColor!, target.fillColor!, animationPercent);

    radiusPx = _lerpDouble(previous.radiusPx, target.radiusPx, animationPercent)!;

    if (target.strokeWidthPx != null && previous.strokeWidthPx != null) {
      strokeWidthPx = ((target.strokeWidthPx! - previous.strokeWidthPx!) * animationPercent) + previous.strokeWidthPx!;
    } else {
      strokeWidthPx = null;
    }
  }

  double? _lerpDouble(double? a, double? b, double t) {
    if (a == null || b == null) return null;
    return a + (b - a) * t;
  }
}

class _AnimatedPoint<D> {
  final String key;
  final bool overlaySeries;

  _PointRendererElement<D>? _previousPoint;
  late _PointRendererElement<D> _targetPoint;
  _PointRendererElement<D>? _currentPoint;

  bool animatingOut = false;

  _AnimatedPoint({required this.key, required this.overlaySeries});

  void animateOut() {
    final newTarget = _currentPoint!.clone();
    final targetPoint = newTarget.point;

    newTarget.point = _DatumPoint<D>.from(targetPoint, targetPoint.x, newTarget.measureAxisPosition!);
    newTarget.radiusPx = 0.0;

    setNewTarget(newTarget);
    animatingOut = true;
  }

  void setNewTarget(_PointRendererElement<D> newTarget) {
    animatingOut = false;
    _currentPoint ??= newTarget.clone();
    _previousPoint = _currentPoint!.clone();
    _targetPoint = newTarget;
  }

  _PointRendererElement<D> getCurrentPoint(double animationPercent) {
    if (animationPercent == 1.0 || _previousPoint == null) {
      _currentPoint = _targetPoint;
      _previousPoint = _targetPoint;
      return _currentPoint!;
    }

    _currentPoint!.updateAnimationPercent(_previousPoint!, _targetPoint, animationPercent);
    return _currentPoint!;
  }
}

/// Type of follow lines to draw
enum LinePointHighlighterFollowLineType { nearest, none, all }

/// Testing utility
@visibleForTesting
class LinePointHighlighterTester<D> {
  final LinePointHighlighter<D> behavior;
  LinePointHighlighterTester(this.behavior);

  int getSelectionLength() => behavior._seriesPointMap.length;
  bool isDatumSelected(D datum) => behavior._seriesPointMap.values.any((point) => point._currentPoint?.point.datum == datum);
}
