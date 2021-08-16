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

import 'package:flutter/material.dart';

class BeagleNavigationBarStyle {
  BeagleNavigationBarStyle({
    this.leading,
    this.elevation,
    this.shadowColor,
    this.backgroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.centerTitle,
    this.titleSpacing,
    this.toolbarHeight,
    this.leadingWidth,
    this.toolbarTextStyle,
    this.titleTextStyle,
  });

  final Widget leading;
  final double elevation;
  final Color shadowColor;
  final Color backgroundColor;
  final IconThemeData iconTheme;
  final IconThemeData actionsIconTheme;
  final TextTheme textTheme;
  final bool centerTitle;
  final double titleSpacing;
  final double toolbarHeight;
  final double leadingWidth;
  final TextStyle toolbarTextStyle;
  final TextStyle titleTextStyle;
}
