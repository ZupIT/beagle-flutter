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

import 'dart:async';
import 'package:beagle/beagle.dart';
import 'expectations.dart';
import 'mock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'setup.dart';

void main() {
  group('Given a StackNavigator class', () {
    NavigationMocks mocks;
    StackNavigator navigator;

    Future<StackNavigatorExpectations> _setup(
      WidgetTester tester,
      int numberOfInitialPages,
    ) async {
      mocks = NavigationMocks(tester, numberOfInitialPages);
      final result = await setupStackNavigatorTests(
        tester: tester,
        mocks: mocks,
      );
      navigator = result.navigator;
      return result.expectations;
    }

    group('When a view is popped from a StackNavigator with 3 pages', () {
      testWidgets('Then it should pop the last page and render the previous', (WidgetTester tester) async {
        final expectations = await _setup(tester, 3);
        navigator.popView(mocks.lastBuildContext);
        await tester.pump();

        expectations.shouldUpdateHistoryByRemovingRoute();
        expectations.shouldPopRoute();
        expectations.shouldRenderInitialPage(1);
      });
    });

    group('When a view is popped from a StackNavigator with 1 page', () {
      testWidgets("Then it should pop the rootNavigator's stack", (WidgetTester tester) async {
        final expectations = await _setup(tester, 1);
        navigator.popView(mocks.lastBuildContext);
        await tester.pump();

        expectations.shouldPopStack();
      });
    });

    group('When a popToView is called for existing view', () {
      testWidgets("Then it should pop pages until the one we're looking for is found", (WidgetTester tester) async {
        final expectations = await _setup(tester, 4);
        navigator.popToView(createPageName(1), mocks.lastBuildContext);
        await tester.pump();

        expectations.shouldUpdateHistoryByRemovingRoute(2);
        expectations.shouldPopRoute(2);
        expectations.shouldRenderInitialPage(1);
      });
    });

    group("When a popToView is called for view that doesn't exist", () {
      testWidgets('Then it should not navigate and log error', (WidgetTester tester) async {
        final expectations = await _setup(tester, 4);
        navigator.popToView('/fake_view', mocks.lastBuildContext);
        await tester.pump();

        expectations.shouldLogError();
        expectations.shouldNotUpdateHistory();
        expectations.shouldNotPopRoute();
        expectations.shouldNotChangeRenderedPage();
      });
    });
  });
}
