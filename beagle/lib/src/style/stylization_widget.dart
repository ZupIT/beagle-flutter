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
import 'package:beagle/src/model/beagle_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StylizationWidget {
  Widget apply(Widget origin, BeagleStyle style) {
    if (style == null) {
      return origin;
    }

    return _applyStyle(origin, style);
  }

  Widget _applyStyle(Widget origin, BeagleStyle style) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _getBackgroundColor(style.backgroundColor),
        border: _getBorder(style.borderColor, style.borderWidth),
        borderRadius: style.cornerRadius?.getBorderRadius(),
      ),
      child: origin,
    );
  }

  Color _getBackgroundColor(String backgroundColor) {
    return backgroundColor != null ? HexColor(backgroundColor) : null;
  }

  Border _getBorder(String borderColor, double borderWidth) {
    return borderWidth != null
        ? Border.all(
            color: HexColor(borderColor),
            width: borderWidth,
          )
        : null;
  }
}
