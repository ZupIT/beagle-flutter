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
  RootNavigatorExpectations expectations;
  RootNavigatorState navigator;
}

Future<_SetupResult> setupRootNavigatorTests({
  required WidgetTester tester,
  String? initialController,
  int numberOfInitialStacks = 0,
  BeagleRoute? initialRoute,
  BeagleRoute? expectedRoute,
  RootNavigatorMocks? mocks,
}) async {
  mocks = mocks ?? RootNavigatorMocks(numberOfInitialStacks);
  final rootNavigator = RootNavigator(
    initialRoute: initialRoute ?? RemoteView('https://it.doesnt-matter.com'),
    screenBuilder: mocks.screenBuilder,
    stackNavigatorFactory: mocks.stackNavigatorFactory,
    navigatorObservers: [mocks.rootNavigatorObserver],
    initialPages: mocks.initialPages,
    initialController: initialController == null ? null : mocks.beagleService.navigationControllers[initialController],
  );
  await tester.pumpWidget(MaterialApp(
    home: Material(child: rootNavigator),
    navigatorObservers: [mocks.topNavigatorObserver],
  ));
  await beagleServiceLocator.allReady();
  await tester.pump();
  final navigator = tester.state<RootNavigatorState>(find.byType(RootNavigator));
  return _SetupResult(RootNavigatorExpectations(mocks: mocks, route: expectedRoute, tester: tester), navigator);
}
