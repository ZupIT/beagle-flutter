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
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'expectations.dart';
import 'mock.dart';
import 'setup.dart';

class _NavigationControllerMock extends Mock implements NavigationController {}

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _BeagleNavigatorMock extends Mock implements BeagleNavigator {}

class _ViewClientMock extends Mock implements ViewClient {}

class _BeagleRouteMock extends Mock implements BeagleRoute {}

class _BuildContextMock extends Mock implements BuildContext {}

class _RouteDynamicMock extends Mock implements Route<dynamic> {}

void main() {
  setUpAll(() async {
    registerFallbackValue<NavigationController>(_NavigationControllerMock());
    registerFallbackValue<BeagleLogger>(_BeagleLoggerMock());
    registerFallbackValue<BeagleNavigator>(_BeagleNavigatorMock());
    registerFallbackValue<ViewClient>(_ViewClientMock());
    registerFallbackValue<BeagleRoute>(_BeagleRouteMock());
    registerFallbackValue<BuildContext>(_BuildContextMock());
    registerFallbackValue<Route<dynamic>>(_RouteDynamicMock());
  });

  group('Given a RootNavigator', () {
    Future<RootNavigatorExpectations> _setup(WidgetTester tester, [String? initialController]) async {
      final route = RemoteView('/test');
      final result = await setupRootNavigatorTests(
        tester: tester,
        initialRoute: route,
        expectedRoute: route,
        initialController: initialController ?? '',
      );
      return result.expectations;
    }

    group("When it's created", () {
      testWidgets('Then it should create a StackNavigator with the initial route and default controller',
          (WidgetTester tester) async {
        final expectations = await _setup(tester);
        expectations.shouldCreateStackNavigatorWithDefaultController();
        expectations.shouldUpdateHistoryByAddingStack();
        expectations.shouldPushNewRoute();
        expectations.shouldRenderNewStackNavigator();
      });
    });

    group("When it's created with a custom controller", () {
      testWidgets('Then it should create a StackNavigator with the initial route and custom controller',
          (WidgetTester tester) async {
        final expectations = await _setup(tester, CUSTOM_CONTROLLER_NAME);
        expectations.shouldCreateStackNavigatorWithCustomController(CUSTOM_CONTROLLER_NAME);
      });
    });
  });
}
