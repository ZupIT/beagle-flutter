/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:beagle/beagle.dart';
import 'package:flutter/cupertino.dart';

class EdgeValues {
  EdgeValues({this.top, this.left, this.bottom, this.right});

  factory EdgeValues.zero() => EdgeValues(top: 0, left: 0, bottom: 0, right: 0);

  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
}

class StyleUtils {
  static double? getSize(UnitValue? unitValue, double space) {
    final real = unitValue?.type == UnitType.PERCENT ? null : unitValue?.value;
    final percent = unitValue?.type == UnitType.PERCENT ? unitValue?.value : null;

    if (real != null) return real.toDouble();
    if (percent != null) return (percent.toDouble() / 100) * space;
  }

  static BoxConstraints getSizeConstraints(BeagleStyle? style, BoxConstraints constraints, EdgeValues padding) {
    if (style?.display == FlexDisplay.NONE) return BoxConstraints.tight(Size.zero);

    final width = getSize(style?.size?.width, constraints.maxWidth);
    final height = getSize(style?.size?.height, constraints.maxHeight);
    final minWidth = width ?? getSize(style?.size?.minWidth, constraints.maxWidth);
    final minHeight = height ?? getSize(style?.size?.minHeight, constraints.maxHeight);
    final maxWidth = width ?? getSize(style?.size?.maxWidth, constraints.maxWidth);
    final maxHeight = height ?? getSize(style?.size?.maxHeight, constraints.maxHeight);

    return BoxConstraints(
      minWidth: (minWidth ?? 0) + (padding.left ?? 0) + (padding.right ?? 0),
      minHeight: (minHeight ?? 0) + (padding.top ?? 0) + (padding.bottom ?? 0),
      maxWidth: (maxWidth ?? double.infinity) + (padding.left ?? 0) + (padding.right ?? 0),
      maxHeight: (maxHeight ?? double.infinity) + (padding.top ?? 0) + (padding.bottom ?? 0),
    );
  }

  static EdgeValues getEdgeValues(EdgeValue? edgeValue, BoxConstraints constraints) {
    final top = getSize(edgeValue?.top ?? edgeValue?.vertical ?? edgeValue?.all, constraints.maxHeight);
    final bottom = getSize(edgeValue?.bottom ?? edgeValue?.vertical ?? edgeValue?.all, constraints.maxHeight);
    final left = getSize(edgeValue?.left ?? edgeValue?.horizontal ?? edgeValue?.all, constraints.maxWidth);
    final right = getSize(edgeValue?.right ?? edgeValue?.horizontal ?? edgeValue?.all, constraints.maxWidth);
    return EdgeValues(left: left, top: top, right: right, bottom: bottom);
  }

  static EdgeInsetsGeometry getEdgeInsets(EdgeValue? edgeValue, BoxConstraints constraints) {
    final values = getEdgeValues(edgeValue, constraints);
    return EdgeInsets.fromLTRB(values.left ?? 0, values.top ?? 0, values.right ?? 0, values.bottom ?? 0);
  }

  static bool _isPercent(UnitValue? unitValue) => unitValue?.type == UnitType.PERCENT;

  static bool _isPercentSize(BeagleStyle? style) => _isPercent(style?.size?.width) || _isPercent(style?.size?.height)
      || _isPercent(style?.size?.minWidth) || _isPercent(style?.size?.minHeight) || _isPercent(style?.size?.maxWidth)
      || _isPercent(style?.size?.maxHeight);

  static bool _isPercentEdge(EdgeValue? edge) => _isPercent(edge?.all) || _isPercent(edge?.vertical)
      || _isPercent(edge?.top) || _isPercent(edge?.horizontal) || _isPercent(edge?.left) || _isPercent(edge?.right)
      || _isPercent(edge?.bottom);

  static bool hasPercentDimensions(BeagleStyle? style) => _isPercentSize(style) || _isPercentEdge(style?.margin)
      || _isPercentEdge(style?.padding);

  static bool hasEdgeValue(EdgeValue? edge) => (edge?.all ?? edge?.vertical ?? edge?.horizontal ?? edge?.top ??
      edge?.left ?? edge?.bottom ?? edge?.right) != null;

  static bool hasBorderRadius(BeagleStyle? style) => (style?.cornerRadius?.topLeft ?? style?.cornerRadius?.topRight
      ?? style?.cornerRadius?.radius ?? style?.cornerRadius?.bottomLeft ?? style?.cornerRadius?.bottomLeft) != null;

  static BorderRadius? getBorderRadius(BeagleStyle? style) {
    if (style?.cornerRadius == null) return null;
    return BorderRadius.only(
      bottomLeft: Radius.circular(style?.cornerRadius?.bottomLeft ?? style?.cornerRadius?.radius ?? 0),
      bottomRight: Radius.circular(style?.cornerRadius?.bottomRight ?? style?.cornerRadius?.radius ?? 0),
      topLeft: Radius.circular(style?.cornerRadius?.topLeft ?? style?.cornerRadius?.radius ?? 0),
      topRight: Radius.circular(style?.cornerRadius?.topRight ?? style?.cornerRadius?.radius ?? 0),
    );
  }
}
