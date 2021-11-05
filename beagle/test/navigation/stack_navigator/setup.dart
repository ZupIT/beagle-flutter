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
import 'package:flutter_test/flutter_test.dart';

import 'expectations.dart';
import 'mock.dart';

class _SetupResult {
  _SetupResult(this.expectations, this.navigator);

  StackNavigatorExpectations expectations;
  StackNavigator navigator;
}

Future<_SetupResult> setupStackNavigatorTests({
  required WidgetTester tester,
  required NavigationMocks mocks,
  required dynamic expectedRoute,
  BeagleRoute? initialRoute,
  BeagleUIElement? expectedScreen,
  dynamic expectedError,
}) async {
  final navigator = StackNavigator(
    beagle: mocks.beagle,
    initialRoute: initialRoute ?? LocalView(BeagleUIElement({'_beagleComponent_': 'beagle:text'})),
    screenBuilder: mocks.screenBuilder,
    controller: mocks.controller,
    rootNavigator: mocks.rootNavigator,
    initialPages: mocks.initialPages,
    navigatorObservers: [mocks.navigatorObserver],
  );

  final expectations = StackNavigatorExpectations(
    screen: expectedScreen ?? BeagleUIElement({}),
    route: expectedRoute,
    mocks: mocks,
    expectedError: expectedError,
    navigator: navigator,
  );

  await tester.pumpWidget(MaterialApp(
    home: Material(child: navigator),
  ));
  await navigator.untilFirstLoadCompletes();
  return _SetupResult(expectations, navigator);
}
