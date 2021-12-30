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

import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';

final buttonOneStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.black),
  textStyle: MaterialStateProperty.all(TextStyle(color: Colors.amber)),
);

class FakeTheme extends BeagleTheme {
  @override
  ButtonStyle? buttonStyle(String id) {
    final map = {
      'button-one': buttonOneStyle,
    };

    return map[id];
  }

  @override
  String? image(String id) {
    return null;
  }

  @override
  TextStyle? textStyle(String id) {
    final map = {
      'text-one': const TextStyle(
        color: Colors.black,
        backgroundColor: Colors.indigo,
      ),
    };

    return map[id];
  }

  @override
  BeagleNavigationBarStyle? navigationBarStyle(String id) {
    return null;
  }
}
