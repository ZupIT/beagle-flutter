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

import '../../test-utils/mocktail.dart';
import 'expectations.dart';
import 'mock.dart';
import 'setup.dart';

void main() {
  registerMocktailFallbacks();

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
