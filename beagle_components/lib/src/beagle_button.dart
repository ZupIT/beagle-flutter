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

import 'package:beagle/beagle.dart';
import 'package:flutter/material.dart';

import '../beagle_components.dart';
import 'theme/beagle_theme_provider.dart';

class BeagleButton extends StatefulWidget {
  const BeagleButton({
    Key? key,
    required this.text,
    this.onPress,
    this.enabled,
    this.styleId,
    this.style,
  }) : super(key: key);

  /// Define the button text content.
  final String text;

  /// References a [BeagleButtonStyle] declared natively and locally in [BeagleDesignSystem]
  /// to be applied to this widget.
  final String? styleId;

  /// Defines the actions that will be performed when this component is pressed.
  final void Function()? onPress;

  /// Whether button will be enabled.
  final bool? enabled;

  /// Property responsible to customize all the flex attributes and general style configuration
  final BeagleStyle? style;

  @override
  _BeagleButton createState() => _BeagleButton();
}

/// Defines a button widget that will be rendered according to the style of the
/// running platform.
class _BeagleButton extends State<BeagleButton> {
  bool _hasStyle() => (widget.style?.backgroundColor ?? widget.style?.cornerRadius ?? widget.style?.borderWidth
      ?? widget.style?.borderColor ?? widget.style?.padding) != null;

  ButtonStyle? _getStyleFromId(BuildContext context) {
    if (widget.styleId == null) return null;
    final themeProvider = BeagleThemeProvider.of(context);
    return themeProvider?.theme.buttonStyle(widget.styleId!);
  }

  ButtonStyle? _getStyleFromProperties() =>  _hasStyle() ? ButtonStyle(
    shape: _getShape(),
    backgroundColor: _getBackgroundColor(),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    side: _getBorderSide(),
    padding: StyleUtils.hasEdgeValue(widget.style?.padding) ? MaterialStateProperty.all(
      StyleUtils.getEdgeInsets(widget.style?.padding, BoxConstraints.tight(Size(100, 100))),
    ) : null,
  ) : null;

  ButtonStyle? _getStyle(BuildContext context) {
    final fromId = _getStyleFromId(context);
    final fromProperties = _getStyleFromProperties();
    if (fromId == null) return fromProperties;
    if (fromProperties == null) return fromId;
    return fromId.merge(fromProperties);
  }

  @override
  Widget build(BuildContext context) {
    final shouldExpandFlex = widget.style?.size?.height?.value != null;
    final shouldExpandBox = widget.style?.size?.width?.value != null;
    Widget button = ElevatedButton(
      onPressed: widget.enabled == false ? null : widget.onPress,
      child: _buildButtonChild(),
      style: _getStyle(context),
    );
    if (shouldExpandBox) {
      button = ConstrainedBox(
        constraints: BoxConstraints(minWidth: double.infinity, maxWidth: double.infinity),
        child: button,
      );
    }
    if (shouldExpandFlex) button = Expanded(child: button);
    return button;

  }

  Widget _buildButtonChild() => Text(widget.text);

  MaterialStateProperty<Color>? _getBackgroundColor() {
    final color = widget.style?.backgroundColor != null
        ? HexColor(widget.style!.backgroundColor!)
        : null;
    return color != null ? MaterialStateProperty.all(color) : null;
  }

  MaterialStateProperty<BorderSide>? _getBorderSide() =>
      (widget.style?.borderWidth ?? widget.style?.borderColor) == null ? null : MaterialStateProperty.all(
        BorderSide(
          color: HexColor(widget.style?.borderColor ?? "#000000"),
          width: widget.style?.borderWidth ?? 1,
        )
      );

  MaterialStateProperty<OutlinedBorder>? _getShape() {
    return StyleUtils.hasBorderRadius(widget.style)
        ? MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: StyleUtils.getBorderRadius(widget.style)!,
            ),
          )
        : null;
  }
}
