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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
class _BeagleButton extends State<BeagleButton> with BeagleConsumer {
  BeagleButtonStyle? _buttonStyle;

  @override
  Widget buildBeagleWidget(BuildContext context) {
    _buttonStyle = widget.styleId == null ? null : beagle.designSystem.buttonStyle(widget.styleId!);

    return ElevatedButton(
        onPressed: widget.enabled == false ? null : widget.onPress,
        child: _buildButtonChild(),
        style: _buttonStyle?.buttonStyle?.copyWith(
          shape: _getShape(),
          backgroundColor: _getBackgroundColor(),
          side: _getBorderSide(),
        ));
  }

  Widget _buildButtonChild() => Text(widget.text, style: _buttonStyle?.buttonTextStyle);

  MaterialStateProperty<Color>? _getBackgroundColor() {
    final color = widget.style?.backgroundColor != null
        ? HexColor(widget.style!.backgroundColor!)
        : null;
    return color != null ? MaterialStateProperty.all(color) : null;
  }

  MaterialStateProperty<BorderSide>? _getBorderSide() {
    return widget.style?.borderWidth != null && widget.style?.borderColor != null
        ? MaterialStateProperty.all(
            BorderSide(
              color: HexColor(widget.style!.borderColor!),
              width: widget.style!.borderWidth!,
            ),
          )
        : null;
  }

  MaterialStateProperty<OutlinedBorder>? _getShape() {
    final borderRadius = widget.style?.cornerRadius?.getBorderRadius();

    return borderRadius != null
        ? MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          )
        : null;
  }
}
