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
import 'package:beagle/src/bridge_impl/beagle_view_js.dart';
import 'package:mocktail/mocktail.dart';
import 'expectations.dart';
import 'mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'setup.dart';

class _BeagleNavigatorMock extends Mock implements BeagleNavigator {}

class _BeagleViewJSMock extends Mock implements BeagleViewJS {}

class _BuildContextMock extends Mock implements BuildContext {}

class _BeagleViewMock extends Mock implements BeagleView {}

class _StackTraceMock extends Mock implements StackTrace {}

class _RouteMock extends Mock implements Route<dynamic> {}

void main() {
  setUpAll(() async {
    await beagleServiceLocator.reset();

    beagleServiceLocator.registerSingleton<BeagleViewJS>(_BeagleViewJSMock());

    registerFallbackValue<BeagleView>(_BeagleViewMock());
    registerFallbackValue<UnsafeBeagleWidget>(UnsafeBeagleWidget(null));
    registerFallbackValue<BuildContext>(_BuildContextMock());
    registerFallbackValue<BeagleNavigator>(_BeagleNavigatorMock());
    registerFallbackValue<StackTrace>(_StackTraceMock());
    registerFallbackValue<Route<dynamic>>(_RouteMock());
    registerFallbackValue<BeagleUIElement>(BeagleUIElement({}));
    registerFallbackValue<RemoteView>(RemoteView(''));
  });

  group('Given a StackNavigator class', () {
    final remoteView = RemoteView('/test');
    final screen = BeagleUIElement({'id': 'test', '_beagleComponent_': 'beagle:container'});
    final error = Error();
    late StackNavigator navigator;

    Future<StackNavigatorExpectations> _setup({
      required WidgetTester tester,
      required NavigationMocks mocks,
      dynamic route,
      dynamic expectedError,
    }) async {
      final result = await setupStackNavigatorTests(
        tester: tester,
        mocks: mocks,
        expectedRoute: route ?? remoteView,
        expectedScreen: screen,
        expectedError: expectedError,
      );
      navigator = result.navigator;
      return result.expectations;
    }

    group("When a RemoteView is pushed to a StackNavigator", () {
      testWidgets('Then it should fetch and render the new route', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester, 1);
        final expectations = await _setup(tester: tester, mocks: mocks);
        mocks.mockSuccessfulRequest(remoteView, screen);
        await navigator.pushView(remoteView, mocks.lastBuildContext);
        await tester.pump();

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

    group("When a RemoteView is pushed and the navigation completes inside the onLoading handler", () {
      testWidgets('Then it should render the Beagle screen as soon as pushView is called', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester, 1);
        final expectations = await _setup(tester: tester, mocks: mocks);
        mocks.mockSuccessfulRequest(remoteView, screen);
        mocks.mockCompletionOnLoading();
        // It's important not to await the next line
        navigator.pushView(remoteView, mocks.lastBuildContext);
        await tester.pump();

        expectations.shouldHandleOnLoading();
        expectations.shouldUpdateHistoryByAddingRoute();
        expectations.shouldPushNewRoute();
        expectations.shouldRenderScreen();
      });
    });

    group("When a RemoteView is pushed, but the fetch fails", () {
      testWidgets('Then it should call error and not render anything', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester, 1);
        final expectations = await _setup(tester: tester, mocks: mocks, expectedError: error);
        mocks.mockUnsuccessfulRequest(remoteView, error);
        await navigator.pushView(remoteView, mocks.lastBuildContext);
        await tester.pump();

        expectations.shouldHandleOnError();
        expectations.shouldNotHandleOnSuccess();
        expectations.shouldNotUpdateHistory();
        expectations.shouldNotPushNewRoute();
        expectations.shouldNotRenderScreen();
      });
    });

    group("When a RemoteView is pushed, the fetch fails and the onError handler completes the navigation", () {
      testWidgets('Then it should render even with an error', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester, 1);
        final expectations = await _setup(tester: tester, mocks: mocks);
        mocks.mockUnsuccessfulRequest(remoteView, error);
        mocks.mockCompletionOnError();
        await navigator.pushView(remoteView, mocks.lastBuildContext);
        await tester.pump();

        expectations.shouldUpdateHistoryByAddingRoute();
        expectations.shouldPushNewRoute();
        expectations.shouldRenderScreen();
      });
    });

    group("When a RemoteView is pushed, the fetch fails and a successful retrial is made", () {
      testWidgets('Then it should render the resulting screen', (WidgetTester tester) async {
        final mocks = NavigationMocks(tester, 1);
        final expectations = await _setup(tester: tester, mocks: mocks);
        mocks.mockUnsuccessfulRequest(remoteView, error);
        final retryRef = mocks.mockRetryOnError();
        await navigator.pushView(remoteView, mocks.lastBuildContext);
        await tester.pump();
        mocks.mockSuccessfulRequest(remoteView, screen);
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

    group("When a LocalView is pushed", () {
      testWidgets(
        'Then it should render the screen immediately, without contacting the backend',
        (WidgetTester tester) async {
          final localView = LocalView(screen);
          final mocks = NavigationMocks(tester, 1);
          final expectations = await _setup(tester: tester, mocks: mocks, route: localView);
          // It's important not to await the next line
          navigator.pushView(localView, mocks.lastBuildContext);
          await tester.pump();

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

    /* This is an uncommon scenario where a custom Beagle component would create another navigator. This test ensures
    the correct navigator will be used no matter what. */
    group("When a view is pushed from a context where another navigator is the closest ancestor", () {
      late BuildContext buildContext;

      final initialPageOfAnotherNavigator = MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          buildContext = context;
          return Container();
        },
        settings: RouteSettings(name: 'test'),
      );

      final pageContainingAnotherNavigator = MaterialPageRoute<dynamic>(
        builder: (_) => Navigator(
          onGenerateInitialRoutes: (NavigatorState state, String routeName) => [initialPageOfAnotherNavigator],
        ),
      );

      testWidgets('Then it should push the view to the StackNavigator anyway', (WidgetTester tester) async {
        final localView = LocalView(screen);
        final mocks = NavigationMocks(tester);
        mocks.initialPages.add(pageContainingAnotherNavigator);
        final expectations = await _setup(tester: tester, mocks: mocks, route: localView);
        await navigator.pushView(localView, buildContext);
        await tester.pump();

        expectations.shouldPushNewRoute();
      });
    });
  });
}
