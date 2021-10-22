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
import 'setup.dart';

class _NavigationControllerMock extends Mock implements NavigationController {}

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _BeagleNavigatorMock extends Mock implements BeagleNavigator {}

class _ViewClientMock extends Mock implements ViewClient {}

class _RouteMock extends Mock implements Route<dynamic> {}

class _BeagleRouteMock extends Mock implements BeagleRoute {}

class _BuildContextMock extends Mock implements BuildContext {}

void main() {
  setUpAll(() async {
    registerFallbackValue<NavigationController>(_NavigationControllerMock());
    registerFallbackValue<BeagleLogger>(_BeagleLoggerMock());
    registerFallbackValue<BeagleNavigator>(_BeagleNavigatorMock());
    registerFallbackValue<ViewClient>(_ViewClientMock());
    registerFallbackValue<Route<dynamic>>(_RouteMock());
    registerFallbackValue<BeagleRoute>(_BeagleRouteMock());
    registerFallbackValue<BuildContext>(_BuildContextMock());
  });

  group('Given a RootNavigator', () {
    late RootNavigatorState navigator;

    Future<RootNavigatorExpectations> _setup(WidgetTester tester, int numberOfInitialStacks) async {
      final result = await setupRootNavigatorTests(tester: tester, numberOfInitialStacks: numberOfInitialStacks);
      navigator = result.navigator;
      return result.expectations;
    }

    group("When we pop a stack from a navigator with 3 stacks", () {
      testWidgets('Then it should remove the third stack and navigate to the second', (WidgetTester tester) async {
        final expectations = await _setup(tester, 3);
        navigator.popStack();
        await tester.pump();
        expectations.shouldUpdateHistoryByRemovingStack();
        expectations.shouldPopRoute();
        expectations.shouldRenderPreviousStackNavigator();
      });
    });

    group("When we pop a stack from a navigator with a single stack", () {
      testWidgets('Then it should remove the RootNavigator', (WidgetTester tester) async {
        final expectations = await _setup(tester, 1);
        navigator.popStack();
        await tester.pump();
        expectations.shouldPopRootNavigator();
      });
    });

    group("When we pop a view", () {
      testWidgets('Then it should call the popView method of the current stack', (WidgetTester tester) async {
        final expectations = await _setup(tester, 1);
        navigator.popView();
        expectations.shouldPopViewFromCurrentStack();
      });
    });

    group("When we pop to a view", () {
      testWidgets('Then it should call the popToView method of the current stack', (WidgetTester tester) async {
        final expectations = await _setup(tester, 1);
        navigator.popToView('/test');
        expectations.shouldPopToViewOfCurrentStack('/test');
      });
    });
  });
}
