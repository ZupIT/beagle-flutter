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
import '../../test-utils/mocktail.dart';
import 'setup.dart';
import 'expectations.dart';
import 'mock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  registerMocktailFallbacks();

  group('Given a StackNavigator class', () {
    final initialRemoteView = RemoteView('/test');
    final screen = BeagleUIElement({'id': 'test', '_beagleComponent_': 'beagle:container'});
    final error = Error();

    Future<StackNavigatorExpectations> _setup({
      required WidgetTester tester,
      required NavigationMocks mocks,
      dynamic initialRoute,
      dynamic expectedError,
    }) async {
      final result = await setupStackNavigatorTests(
        tester: tester,
        mocks: mocks,
        initialRoute: initialRoute ?? initialRemoteView,
        expectedRoute: initialRoute ?? initialRemoteView,
        expectedScreen: screen,
        expectedError: expectedError,
      );
      return result.expectations;
    }

    group("When a StackNavigator is created", () {
      testWidgets('Then it should fetch and render the initial remoteView', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester);
        mocks.mockSuccessfulRequest(initialRemoteView, screen);

        final expectations = await _setup(tester: tester, mocks: mocks);
        expectations.shouldFetchRoute();
        expectations.shouldCreateBeagleWidget();
        expectations.shouldHandleOnLoading();
        expectations.shouldNotHandleOnError();
        expectations.shouldHandleOnSuccess();
        expectations.shouldUpdateHistoryByAddingRoute();
        expectations.shouldPushNewRoute();
        expectations.shouldRenderScreen();
      });
    });

    group("When it's created with a RemoteView and the navigation completes inside the onLoading handler", () {
      testWidgets('Then it should render the Beagle screen as soon as the navigator is rendered',
          (WidgetTester tester) async {
        final mocks = NavigationMocks(tester);
        mocks.mockSuccessfulRequest(initialRemoteView, screen);
        mocks.mockCompletionOnLoading();

        final expectations = await _setup(tester: tester, mocks: mocks);
        expectations.shouldHandleOnLoading();
        expectations.shouldPushNewRoute();
        expectations.shouldRenderScreen();
      });
    });

    group("When it's created with a RemoteView, but the fetch fails", () {
      testWidgets('Then it should handle onError and render beagle screen', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester);
        mocks.mockUnsuccessfulRequest(initialRemoteView, error);

        final expectations = await _setup(tester: tester, mocks: mocks, expectedError: error);
        expectations.shouldHandleOnError();
        expectations.shouldNotHandleOnSuccess();
        /* The expectations below might be unwanted behavior, but it should indeed happen given the current
        implementation. The ideal would be the next lines to be `expectations.shouldNotPushNewRoute();`,
        `expectations.shouldNotRenderScreen();` and `expectations.shouldNotUpdateHistory(navigator)`.
        Issue: https://github.com/ZupIT/beagle/issues/1770 */
        expectations.shouldPushNewRoute();
        expectations.shouldRenderScreen();
        expectations.shouldUpdateHistoryByAddingRoute();
      });
    });

    group("When it's created with a RemoteView, the fetch fails and the onError handler completes the navigation", () {
      testWidgets('Then it should render even with an error', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester);
        mocks.mockUnsuccessfulRequest(initialRemoteView, error);
        mocks.mockCompletionOnError();

        final expectations = await _setup(tester: tester, mocks: mocks);
        expectations.shouldRenderScreen();
        expectations.shouldPushNewRoute();
        expectations.shouldUpdateHistoryByAddingRoute();
      });
    });

    group("When it's created with a RemoteView, the fetch fails and a successful retrial is made", () {
      testWidgets('Then it should render the resulting screen', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester);

        final retryRef = mocks.mockRetryOnError();
        mocks.mockUnsuccessfulRequest(initialRemoteView, error);

        final expectations = await _setup(tester: tester, mocks: mocks);

        mocks.mockSuccessfulRequest(initialRemoteView, screen);

        await retryRef.current();
        await tester.pump();

        expectations.shouldFetchRoute(2);
        expectations.shouldHandleOnLoading(2);
        expectations.shouldHandleOnSuccess();
        expectations.shouldUpdateHistoryByAddingRoute();
        expectations.shouldPushNewRoute();
        expectations.shouldRenderScreen();
      });
    });

    group("When it's created with a LocalView", () {
      testWidgets(
        'Then it should render the screen immediately, without contacting the backend',
        (WidgetTester tester) async {
          final mocks = NavigationMocks(tester);
          final initialLocalView = LocalView(screen, null);

          final expectations = await _setup(tester: tester, mocks: mocks, initialRoute: initialLocalView);
          expectations.shouldNotFetchRoute();
          expectations.shouldCreateBeagleWidget();
          expectations.shouldNotHandleOnLoading();
          expectations.shouldNotHandleOnError();
          expectations.shouldHandleOnSuccess();
          expectations.shouldUpdateHistoryByAddingRoute();
          expectations.shouldPushNewRoute();
          expectations.shouldRenderScreen();
        },
      );
    });
  });
}
