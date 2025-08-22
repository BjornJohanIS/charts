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

import 'dart:math' show Rectangle;
import 'package:charts_common/common.dart' as common
    show
        ChartBehavior,
        LayoutViewPaintOrder,
        RectSymbolRenderer,
        SelectionTrigger,
        Slider,
        SliderListenerCallback,
        SliderStyle,
        SymbolRenderer;
import 'package:flutter/widgets.dart' show hashValues;
import 'package:meta/meta.dart' show immutable;

import '../chart_behavior.dart' show ChartBehavior, GestureType;

/// Chart behavior that adds a slider widget to a chart.
///
/// When the slider is dropped after drag, it reports its domain position and
/// nearest datum value. Only supports charts with continuous scales.
@immutable
class Slider<D> extends ChartBehavior<D> {
  final Set<GestureType> desiredGestures;
  final common.SelectionTrigger eventTrigger;
  final int? layoutPaintOrder;
  final D? initialDomainValue;
  final common.SliderListenerCallback? onChangeCallback;
  final String? roleId;
  final bool snapToDatum;
  final common.SliderStyle? style;
  final common.SymbolRenderer? handleRenderer;

  Slider._internal({
    required this.eventTrigger,
    this.onChangeCallback,
    this.initialDomainValue,
    this.roleId,
    required this.snapToDatum,
    this.style,
    this.handleRenderer,
    required this.desiredGestures,
    this.layoutPaintOrder,
  });

  factory Slider({
    common.SelectionTrigger? eventTrigger,
    common.SymbolRenderer? handleRenderer,
    D? initialDomainValue,
    String? roleId,
    common.SliderListenerCallback? onChangeCallback,
    bool snapToDatum = false,
    common.SliderStyle? style,
    int layoutPaintOrder = common.LayoutViewPaintOrder.slider,
  }) {
    eventTrigger ??= common.SelectionTrigger.tapAndDrag;
    handleRenderer ??= common.RectSymbolRenderer();
    style ??= common.SliderStyle(handleSize: Rectangle<int>(0, 0, 20, 30));

    return Slider._internal(
      eventTrigger: eventTrigger,
      handleRenderer: handleRenderer,
      initialDomainValue: initialDomainValue,
      onChangeCallback: onChangeCallback,
      roleId: roleId,
      snapToDatum: snapToDatum,
      style: style,
      desiredGestures: _getDesiredGestures(eventTrigger),
      layoutPaintOrder: layoutPaintOrder,
    );
  }

  static Set<GestureType> _getDesiredGestures(
      common.SelectionTrigger eventTrigger) {
    final gestures = <GestureType>{};
    switch (eventTrigger) {
      case common.SelectionTrigger.tapAndDrag:
        gestures.addAll([GestureType.onTap, GestureType.onDrag]);
        break;
      case common.SelectionTrigger.pressHold:
      case common.SelectionTrigger.longPressHold:
        gestures.addAll([GestureType.onTap, GestureType.onLongPress, GestureType.onDrag]);
        break;
      default:
        throw ArgumentError('Slider does not support event trigger "$eventTrigger"');
    }
    return gestures;
  }

  @override
  common.Slider<D> createCommonBehavior() => common.Slider<D>(
        eventTrigger: eventTrigger,
        handleRenderer: handleRenderer,
        initialDomainValue: initialDomainValue,
        onChangeCallback: onChangeCallback,
        roleId: roleId,
        snapToDatum: snapToDatum,
        style: style,
      );

  @override
  void updateCommonBehavior(common.ChartBehavior<D> commonBehavior) {}

  @override
  String get role => 'Slider-${eventTrigger.toString()}';

  @override
  bool operator ==(Object o) {
    return o is Slider &&
        eventTrigger == o.eventTrigger &&
        handleRenderer == o.handleRenderer &&
        initialDomainValue == o.initialDomainValue &&
        onChangeCallback == o.onChangeCallback &&
        roleId == o.roleId &&
        snapToDatum == o.snapToDatum &&
        style == o.style &&
        layoutPaintOrder == o.layoutPaintOrder;
  }

  @override
  int get hashCode => hashValues(
        eventTrigger,
        handleRenderer,
        initialDomainValue,
        roleId,
        snapToDatum,
        style,
        layoutPaintOrder,
      );
}
