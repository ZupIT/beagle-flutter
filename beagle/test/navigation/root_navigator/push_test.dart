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

void main() {
  group('Given a RootNavigator', () {
    final route = RemoteView('/test');
    RootNavigatorState navigator;

    Future<RootNavigatorExpectations> _setup(WidgetTester tester) {
      return tester.runAsync(() async {
        final mocks = RootNavigatorMocks(1);
        final rootNavigator = RootNavigator(
          initialRoute: RemoteView('https://it.doesnt-matter.com'),
          screenBuilder: mocks.screenBuilder,
          stackNavigatorFactory: mocks.stackNavigatorFactory,
          initialPages: mocks.initialPages,
          navigatorObservers: [mocks.rootNavigatorObserver],
        );
        await tester.pumpWidget(MaterialApp(home: Material(child: rootNavigator)));
        await beagleServiceLocator.allReady();
        await tester.pump();
        navigator = tester.state(find.byType(RootNavigator));
        return RootNavigatorExpectations(mocks: mocks, route: route, tester: tester);
      });
    }

    group("When we push a stack", () {
      testWidgets(
        'Then it should create a StackNavigator with the new route and default controller',
        (WidgetTester tester) async {
          final expectations = await _setup(tester);
          await navigator.pushStack(route, null);
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
          await navigator.pushStack(route, null, CUSTOM_CONTROLLER_NAME);
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
          await navigator.pushStack(route, null, 'fakeController');
          await tester.pump();
          expectations.shouldCreateStackNavigatorWithDefaultController();
        }
      );
    });

    group("When we push a view", () {
      testWidgets('Then it should call the pushView method of the current stack', (WidgetTester tester) async {
        final expectations = await _setup(tester);
        final route = RemoteView('/push-test');
        navigator.pushView(route, null);
        expectations.shouldPushViewToCurrentStack(route);
      });
    });
  });
}
