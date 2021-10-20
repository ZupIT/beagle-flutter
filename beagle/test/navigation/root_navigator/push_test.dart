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
import 'package:flutter_test/flutter_test.dart';

import 'expectations.dart';
import 'mock.dart';
import 'setup.dart';

void main() {
  group('Given a RootNavigator', () {
    final route = RemoteView('/test');
    RootNavigatorState navigator;

    Future<RootNavigatorExpectations> _setup(WidgetTester tester, [RootNavigatorMocks mocks]) async {
      final result = await setupRootNavigatorTests(
        tester: tester,
        expectedRoute: route,
        numberOfInitialStacks: 1,
        mocks: mocks,
      );
      navigator = result.navigator;
      return result.expectations;
    }

    group("When we push a stack", () {
      testWidgets(
        'Then it should create a StackNavigator with the new route and default controller',
        (WidgetTester tester) async {
          final expectations = await _setup(tester);
          await navigator.pushStack(route);
          await tester.pump();
          expectations.shouldCreateStackNavigatorWithDefaultController();
          expectations.shouldUpdateHistoryByAddingStack();
          expectations.shouldPushNewRoute();
          expectations.shouldRenderNewStackNavigator();
        }
      );
    });

    group("When we push a stack with a custom controller", () {
      testWidgets(
        'Then it should create a StackNavigator with the new route and the custom controller',
        (WidgetTester tester) async {
          final expectations = await _setup(tester);
          await navigator.pushStack(route, CUSTOM_CONTROLLER_NAME);
          await tester.pump();
          expectations.shouldCreateStackNavigatorWithCustomController(CUSTOM_CONTROLLER_NAME);
        }
      );
    });

    group("When we push a stack with a custom controller that doesn't exist", () {
      testWidgets(
        'Then it should create a StackNavigator with the new route and the default controller',
        (WidgetTester tester) async {
          final expectations = await _setup(tester);
          await navigator.pushStack(route, 'fakeController');
          await tester.pump();
          expectations.shouldCreateStackNavigatorWithDefaultController();
        }
      );
    });

    group("When we push multiple stacks", () {
      testWidgets('Then it should create the new pages with the correct names', (WidgetTester tester) async {
        final expectations = await _setup(tester);
        await navigator.pushStack(route);
        await tester.pump();
        await navigator.pushStack(route);
        await tester.pump();
        await navigator.pushStack(route);
        await tester.pump();
        expectations.shouldPushNewRoutesWithCorrectNames(3);
      });
    });

    group("When we push a view", () {
      testWidgets('Then it should call the pushView method of the current stack', (WidgetTester tester) async {
        final mocks = RootNavigatorMocks(1);
        final expectations = await _setup(tester, mocks);
        final route = RemoteView('/push-test');
        navigator.pushView(route, mocks.lastStackNavigator.buildContext);
        expectations.shouldPushViewToCurrentStack(route);
      });
    });
  });
}
