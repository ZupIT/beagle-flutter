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
import 'package:mockito/mockito.dart';

import 'expectations.dart';
import 'mock.dart';

void main() {
  group('Given a RootNavigator', () {
    Future<RootNavigatorExpectations> _setup(WidgetTester tester, [String customController]) async {
      final mocks = RootNavigatorMocks();
      final route = RemoteView('/test');
      final navigator = RootNavigator(
        initialRoute: route,
        screenBuilder: mocks.screenBuilder,
        stackNavigatorFactory: mocks.stackNavigatorFactory,
        navigatorObservers: [mocks.rootNavigatorObserver],
        initialController: customController == null
          ? null
          : mocks.beagleService.navigationControllers[customController],
      );
      await tester.pumpWidget(MaterialApp(
        home: Material(child: navigator),
      ));
      await beagleServiceLocator.allReady();
      await tester.pump();
      return RootNavigatorExpectations(mocks: mocks, route: route, tester: tester);
    }

    group("When it's created", () {
      testWidgets(
        'Then it should create a StackNavigator with the initial route and default controller',
        (WidgetTester tester) async {
          final expectations = await _setup(tester);
          expectations.shouldCreateStackNavigatorWithDefaultController();
          expectations.shouldUpdateHistoryByAddingStack();
          expectations.shouldPushNewRoute();
          expectations.shouldRenderNewStackNavigator();
        }
      );
    });

    group("When it's created with a custom controller", () {
      testWidgets(
        'Then it should create a StackNavigator with the initial route and custom controller',
        (WidgetTester tester) async {
          final expectations = await _setup(tester, CUSTOM_CONTROLLER_NAME);
          expectations.shouldCreateStackNavigatorWithCustomController(CUSTOM_CONTROLLER_NAME);
        }
      );
    });
  });
}
