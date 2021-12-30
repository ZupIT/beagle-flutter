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

import 'beagle_navigation_bar_style.dart';

/// Implements additional data to be used by the Beagle's default components, i.e. image identifiers (mobile ids) and
/// style ids.
abstract class BeagleTheme {
  /// Given a mobileId, from the BeagleImage component, returns a local resource identifier.
  String? image(String id);

  /// Given a styleId, from the styleId property of a button component, returns the Style object to be used by the
  /// button.
  ButtonStyle? buttonStyle(String id);

  /// Given a styleId, from the styleId property of a text component, returns the Style object to be used by the
  /// text.
  TextStyle? textStyle(String id);

  /// Given a styleId, from the styleId property of a screen component, returns the Style object to be used by the
  /// navigation bar of the screen.
  BeagleNavigationBarStyle? navigationBarStyle(String id);
}
