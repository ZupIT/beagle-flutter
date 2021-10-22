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
import 'package:mocktail/mocktail.dart';

import 'mock.dart';

typedef RetryFn = Future<void> Function();

class StackNavigatorExpectations {
  StackNavigatorExpectations({
    required this.mocks,
    required this.screen,
    required this.navigator,
    required this.route,
    this.expectedError,
  });

  final NavigationMocks mocks;
  final dynamic route;
  final BeagleUIElement screen;
  final Error? expectedError;
  final StackNavigator navigator;

  void shouldFetchRoute([int times = 1]) {
    verify(() => mocks.viewClient.fetch(route)).called(times);
  }

  void shouldNotFetchRoute([int times = 1]) {
    verifyNever(() => mocks.viewClient.fetch(any()));
  }

  void shouldCreateBeagleWidget() {
    verify(() => mocks.beagleWidgetFactory(mocks.rootNavigator)).called(1);
    // ignore: unnecessary_null_comparison
    expect(mocks.lastWidget == null, false);
  }

  void shouldHandleOnLoading([int times = 1]) {
    final result = verify(() => mocks.controller.onLoading(
          view: mocks.lastWidget.view,
          context: captureAny(named: 'context'),
          completeNavigation: captureAny(named: 'completeNavigation'),
        ));
    result.called(times);
    expect(result.captured[0], isA<BuildContext>());
    expect(result.captured[1], isA<Function>());
  }

  void shouldNotHandleOnLoading() {
    verifyNever(() => mocks.controller.onLoading(
          view: any(named: 'view'),
          completeNavigation: any(named: 'completeNavigation'),
          context: any(named: 'context'),
        ));
  }

  void shouldHandleOnError() {
    final result = verify(() => mocks.controller.onError(
          view: mocks.lastWidget.view,
          error: expectedError,
          context: captureAny(named: 'context'),
          stackTrace: captureAny(named: 'stackTrace'),
          retry: captureAny(named: 'retry'),
          completeNavigation: captureAny(named: 'completeNavigation'),
        ));
    result.called(1);

    expect(result.captured[0], isA<BuildContext>());
    expect(result.captured[1], isA<StackTrace>());
    expect(result.captured[2], isA<RetryFn>());
    expect(result.captured[3], isA<Function>());
  }

  void shouldNotHandleOnError() {
    verifyNever(() => mocks.controller.onError(
          context: any(named: 'context'),
          completeNavigation: any(named: 'completeNavigation'),
          stackTrace: any(named: 'stackTrace'),
          view: any(named: 'view'),
          retry: any(named: 'retry'),
          error: any(named: 'error'),
        ));
  }

  void shouldHandleOnSuccess() {
    final result = verify(() => mocks.controller.onSuccess(
          view: mocks.lastWidget.view,
          screen: screen,
          context: captureAny(named: 'context'),
        ));
    result.called(1);
    expect(result.captured[0], isA<BuildContext>());
  }

  void shouldNotHandleOnSuccess() {
    verifyNever(() => mocks.controller.onSuccess(
          view: any(named: 'view'),
          screen: any(named: 'screen'),
          context: any(named: 'context'),
        ));
  }

  void shouldNotUpdateHistory() {
    final List<String> initialPageNames = [];
    for (int i = 0; i < mocks.initialPages.length; i++) {
      initialPageNames.add(createPageName(i));
    }
    expect(navigator.getHistory(), initialPageNames);
  }

  void shouldUpdateHistoryByAddingRoute() {
    final routeId = route is LocalView ? (route as LocalView).screen.getId() : (route as RemoteView).url;
    final List<String> initialPageNames = [];
    for (int i = 0; i < mocks.initialPages.length; i++) {
      initialPageNames.add(createPageName(i));
    }
    expect(navigator.getHistory(), [...initialPageNames, routeId]);
  }

  void shouldUpdateHistoryByRemovingRoute([int numberOfRoutes = 1]) {
    final List<String> initialPageNames = [];
    for (int i = 0; i < mocks.initialPages.length - numberOfRoutes; i++) {
      initialPageNames.add(createPageName(i));
    }
    expect(navigator.getHistory(), [...initialPageNames]);
  }

  void shouldRenderScreen() {
    final result = verify(() => mocks.screenBuilder(any(), captureAny()));
    result.called(1);
    expect(result.captured[0], isA<BuildContext>());
    expect(find.byKey(mocks.screenKey), findsOneWidget);
  }

  void shouldRenderInitialPage(int index) {
    expect(find.byKey(Key(createPageName(index))), findsOneWidget);
  }

  void shouldNotRenderScreen() {
    verifyNever(() => mocks.screenBuilder(any(), any()));
    expect(find.byKey(mocks.screenKey), findsNothing);
  }

  void shouldPopStack() {
    verify(() => mocks.rootNavigator.popStack()).called(1);
  }

  void shouldPushNewRoute() {
    verify(() => mocks.navigatorObserver.didPush(any(), any())).called(mocks.initialPages.length + 1);
  }

  void shouldNotPushNewRoute() {
    if (mocks.initialPages.isEmpty) {
      verifyNever(() => mocks.navigatorObserver.didPush(any(), any()));
    } else {
      verify(() => mocks.navigatorObserver.didPush(any(), any())).called(mocks.initialPages.length);
    }
  }

  void shouldPopRoute([int times = 1]) {
    verify(() => mocks.navigatorObserver.didPop(any(), any())).called(times);
  }

  void shouldNotPopRoute() {
    verifyNever(() => mocks.navigatorObserver.didPop(any(), any()));
  }

  void shouldLogError() {
    verify(() => mocks.logger.error(any())).called(1);
  }

  void shouldNotChangeRenderedPage() {
    expect(find.byKey(Key(createPageName(mocks.initialPages.length - 1))), findsOneWidget);
  }
}
