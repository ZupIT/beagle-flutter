/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:beagle/beagle.dart';

const FLEX_PRECISION = 1000;

Map<JustifyContent, MainAxisAlignment> _mainAxisAlignment = {
  JustifyContent.CENTER: MainAxisAlignment.center,
  JustifyContent.FLEX_END: MainAxisAlignment.end,
  JustifyContent.FLEX_START: MainAxisAlignment.start,
  JustifyContent.SPACE_AROUND: MainAxisAlignment.spaceAround,
  JustifyContent.SPACE_BETWEEN: MainAxisAlignment.spaceBetween,
  JustifyContent.SPACE_EVENLY: MainAxisAlignment.spaceEvenly,
};

Map<AlignItems, CrossAxisAlignment> _crossAxisAlignment = {
  AlignItems.FLEX_START: CrossAxisAlignment.start,
  AlignItems.CENTER: CrossAxisAlignment.center,
  AlignItems.FLEX_END: CrossAxisAlignment.end,
  AlignItems.BASELINE: CrossAxisAlignment.baseline,
  AlignItems.STRETCH: CrossAxisAlignment.stretch,
};

class _StyleCalculator {
  _StyleCalculator(this.style, this.children, this.styleConfig);

  List<Widget> children;
  BeagleStyle? style;
  StyleConfig? styleConfig;

  Widget _applyFlexFactor(Widget child) => style?.flex?.flex == null || style?.display == FlexDisplay.NONE
    ? child
    : Expanded(flex: (style!.flex!.flex! * FLEX_PRECISION).round(), child: child);

  BoxConstraints _findConstraints(BuildContext context, BoxConstraints thisConstraints) {
    // if there are no percentage values, we don't even need these constraints, let's just return thisConstraints
    if (!StyleUtils.hasPercentDimensions(style)) return thisConstraints;
    /* unless we are not under a flex layout, we need to know the constraints of the Flex widget itself to apply
    percentage size, marging and padding values. */
    final parentFlex = context.findAncestorRenderObjectOfType<RenderFlex>();
    return parentFlex == null ? thisConstraints : parentFlex.constraints;
  }

  Widget _applyPaddingAndDecoration(Widget child, EdgeValues padding) => styleConfig?.shouldDecorate == false || (
      style?.backgroundColor ?? style?.borderColor ?? style?.borderWidth ?? style?.padding ?? style?.cornerRadius
  ) == null ? child : Container(
    padding: EdgeInsets.fromLTRB(padding.left ?? 0, padding.top ?? 0, padding.right ?? 0, padding.bottom ?? 0),
    decoration: BoxDecoration(
      color: style?.backgroundColor == null ? null : HexColor(style!.backgroundColor!),
      border: style?.borderColor == null && style?.borderWidth == null ? null : Border.all(
        color: style?.borderColor == null ? Colors.black : HexColor(style!.borderColor!),
        width: style?.borderWidth ?? 1,
      ),
      borderRadius: StyleUtils.getBorderRadius(style),
    ),
    child: child,
  );

  Widget _applySizeSpacingAndDecoration(Widget child) => (
      style?.size ?? style?.display ?? style?.backgroundColor ?? style?.borderColor ?? style?.borderWidth
          ?? style?.margin ?? style?.padding ?? style?.cornerRadius
  ) == null ? child : LayoutBuilder(
    builder: (BuildContext context, BoxConstraints thisConstraints) {
      final constraints = _findConstraints(context, thisConstraints);
      final padding = children.isEmpty ? EdgeValues.zero() : StyleUtils.getEdgeValues(style?.padding, constraints);
      final size = StyleUtils.getSizeConstraints(style, constraints, padding);
      return Container(
        margin: style?.display == FlexDisplay.NONE ? EdgeInsets.zero : StyleUtils.getEdgeInsets(style?.margin, constraints),
        constraints: size,
        child: _applyPaddingAndDecoration(child, padding),
      );
    },
  );

  Widget _applyPosition(Widget child) {
    if (style?.positionType != FlexPosition.ABSOLUTE || style?.position == null) return child;
    // BoxContraints = 0 because we don't support percentage values in absolute positined widgets yet
    final offset = StyleUtils.getEdgeValues(style?.position, BoxConstraints.tight(Size.zero));
    return Positioned(
      top: offset.top,
      left: offset.left,
      bottom: offset.bottom,
      right: offset.right,
      child: child,
    );
  }

  Widget _buildFlexible() => Flex(
    direction: style?.flex?.flexDirection == FlexDirection.ROW ? Axis.horizontal : Axis.vertical,
    mainAxisAlignment: _mainAxisAlignment[style?.flex?.justifyContent ?? JustifyContent.FLEX_START]!,
    // should it be stretch like the other platforms? I tried and it clearly has a different bahavior than expected
    crossAxisAlignment: _crossAxisAlignment[style?.flex?.alignItems ?? AlignItems.FLEX_START]!,
    children: children,
    // mainAxisSize: MainAxisSize.min,
  );

  Widget _buildStack() => Stack(children: children);

  Widget buildStyled(BuildContext context) {
    BeagleRootNode.of(context);
    final content = style?.isStack == true ? _buildStack() : _buildFlexible();
    return _applyFlexFactor(_applyPosition(_applySizeSpacingAndDecoration(content)));
  }
}

abstract class StatefulStyled extends StatefulWidget {
  const StatefulStyled({
    Key? key,
    this.style,
    required this.children,
    this.styleConfig,
  }): super(key: key);

  final BeagleStyle? style;
  final List<Widget> children;
  final StyleConfig? styleConfig;
}

/// Builds the state for a widget that layout its children according to server side rules.
///
/// Attention 1: if your state overshadows the method "build" with a mixin, you can call the super class build by
/// explicitly calling "buildStyled(context)".
///
/// Attention 2: if your state overshadows the method "initState" with a mixin, you can access it by explicitly calling
/// "initStyled()"
///
/// Attention 3: if your state overshadows the method "didUpdateWidget" with a mixin, you can access it by explicitly
/// calling "updateStyled()"
class StyledState<T extends StatefulStyled> extends State<T> {
  late final _StyleCalculator _styleCalculator;

  @override
  void initState() {
    initStyled();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    updateStyled();
    super.didUpdateWidget(oldWidget);
  }

  void initStyled() {
    _styleCalculator = _StyleCalculator(widget.style, widget.children, widget.styleConfig);
  }

  void updateStyled() {
    _styleCalculator.style = widget.style;
    _styleCalculator.children = widget.children;
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) => buildStyled(context);

  Widget buildStyled(BuildContext context) => _styleCalculator.buildStyled(context);
}

class Styled extends StatelessWidget {
  Styled({List<Widget> children = const [], BeagleStyle? style, Key? key, StyleConfig? styleConfig})
      : _styleCalculator = _StyleCalculator(style, children, styleConfig), super(key: key);

  final _StyleCalculator _styleCalculator;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return _styleCalculator.buildStyled(context);
  }
}
