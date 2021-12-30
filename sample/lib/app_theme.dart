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
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';

class AppTheme extends BeagleTheme {
  Map<String, String> imageMap = {
    'bus': 'images/bus.png',
    'car': 'images/car.png',
    'person': 'images/person.png',
    'beagle': 'images/beagle.png',
    'delete': 'images/delete.png',
    'informationImage': 'images/info.png',
    'imageBeagle': 'images/beagle.png',
  };

  final Map<String, ButtonStyle> buttonStyles = {
    'DesignSystem.Stylish.Button': ButtonStyle(
      backgroundColor: MaterialStateProperty.all(HexColor("#FFFFFFFF")),
      foregroundColor: MaterialStateProperty.all(HexColor("#6F6F6F")),
    ),
  };

  @override
  String image(String id) {
    return imageMap[id] ?? '';
  }

  @override
  ButtonStyle buttonStyle(String id) {
    return buttonStyles[id] ?? ButtonStyle();
  }

  @override
  TextStyle textStyle(String id) {
    return TextStyle();
  }

  @override
  BeagleNavigationBarStyle navigationBarStyle(String id) {
    return BeagleNavigationBarStyle();
  }
}
