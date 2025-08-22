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

import 'dart:math' show min;
import 'package:flutter/widgets.dart';

/// Strategy for building legend from legend entry widgets.
abstract class LegendLayout {
  Widget build(BuildContext context, List<Widget> legendEntryWidgets);
}

/// Layout legend entries in tabular format.
class TabularLegendLayout implements LegendLayout {
  static const _noLimit = -1;
  static const defaultCellPadding = EdgeInsets.all(8.0);

  final bool isHorizontalFirst;
  final int desiredMaxRows;
  final int desiredMaxColumns;
  final EdgeInsets? cellPadding;

  TabularLegendLayout._internal({
    required this.isHorizontalFirst,
    required this.desiredMaxRows,
    required this.desiredMaxColumns,
    this.cellPadding,
  });

  factory TabularLegendLayout.horizontalFirst({
    int? desiredMaxColumns,
    EdgeInsets? cellPadding,
  }) =>
      TabularLegendLayout._internal(
        isHorizontalFirst: true,
        desiredMaxRows: _noLimit,
        desiredMaxColumns: desiredMaxColumns ?? _noLimit,
        cellPadding: cellPadding,
      );

  factory TabularLegendLayout.verticalFirst({
    int? desiredMaxRows,
    EdgeInsets? cellPadding,
  }) =>
      TabularLegendLayout._internal(
        isHorizontalFirst: false,
        desiredMaxRows: desiredMaxRows ?? _noLimit,
        desiredMaxColumns: _noLimit,
        cellPadding: cellPadding,
      );

  @override
  Widget build(BuildContext context, List<Widget> legendEntries) {
    final paddedEntries = (cellPadding == null)
        ? legendEntries
        : legendEntries
            .map((e) => Padding(padding: cellPadding!, child: e))
            .toList();

    return isHorizontalFirst
        ? _buildHorizontalFirst(paddedEntries)
        : _buildVerticalFirst(paddedEntries);
  }

  Widget _buildHorizontalFirst(List<Widget> entries) {
    final maxColumns =
        desiredMaxColumns == _noLimit ? entries.length : min(entries.length, desiredMaxColumns);

    final rows = <TableRow>[];
    for (var i = 0; i < entries.length; i += maxColumns) {
      rows.add(TableRow(
        children: entries.sublist(i, min(i + maxColumns, entries.length)),
      ));
    }

    return _buildTableFromRows(rows);
  }

  Widget _buildVerticalFirst(List<Widget> entries) {
    final maxRows =
        desiredMaxRows == _noLimit ? entries.length : min(entries.length, desiredMaxRows);

    final rows = List.generate(maxRows, (_) => TableRow(children: <Widget>[]));
    for (var i = 0; i < entries.length; i++) {
      rows[i % maxRows].children!.add(entries[i]);
    }

    return _buildTableFromRows(rows);
  }

  Table _buildTableFromRows(List<TableRow> rows) {
    final padWidget = Padding(padding: cellPadding ?? defaultCellPadding);

    // Pad rows to the max column count.
    final columnCount =
        rows.map((r) => r.children!.length).fold<int>(0, (max, len) => len > max ? len : max);

    for (var row in rows) {
      final padCount = columnCount - row.children!.length;
      if (padCount > 0) {
        row.children!.addAll(List.generate(padCount, (_) => padWidget));
      }
    }

    return Table(
      children: rows,
      defaultColumnWidth: const IntrinsicColumnWidth(),
    );
  }

  @override
  bool operator ==(Object o) =>
      o is TabularLegendLayout &&
      desiredMaxRows == o.desiredMaxRows &&
      desiredMaxColumns == o.desiredMaxColumns &&
      isHorizontalFirst == o.isHorizontalFirst &&
      cellPadding == o.cellPadding;

  @override
  int get hashCode => Object.hash(desiredMaxRows, desiredMaxColumns, isHorizontalFirst, cellPadding);
}
