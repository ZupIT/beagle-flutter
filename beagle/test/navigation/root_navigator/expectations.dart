/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
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

class RootNavigatorExpectations {
  RootNavigatorExpectations({
    required this.mocks,
    required WidgetTester tester,
    this.route,
  }) : navigatorState = tester.state(find.byType(RootNavigator));

  final RootNavigatorMocks mocks;
  final BeagleRoute? route;
  final RootNavigatorState navigatorState;

  void _shouldCreateStackNavigator([String? customController]) {
    verify(() => mocks.beagle.createStackNavigator(
          initialRoute: route!,
          screenBuilder: mocks.screenBuilder,
          rootNavigator: navigatorState,
          controller: customController == null
              ? mocks.beagle.defaultNavigationController
              : mocks.beagle.navigationControllers[customController] as NavigationController,
        )).called(1);
  }

  void shouldCreateStackNavigatorWithDefaultController() {
    _shouldCreateStackNavigator();
  }

  void shouldCreateStackNavigatorWithCustomController(String customController) {
    _shouldCreateStackNavigator(customController);
  }

  void shouldUpdateHistoryByAddingStack() {
    expect(navigatorState.getHistory(), [...mocks.initialPages, mocks.lastStackNavigator]);
  }

  void shouldUpdateHistoryByRemovingStack() {
    final expectedHistory = [...mocks.initialPages];
    expectedHistory.removeLast();
    expect(navigatorState.getHistory(), expectedHistory);
  }

  void shouldUpdateHistoryByReplacingStack() {
    final expectedHistory = [...mocks.initialPages];
    expectedHistory.removeLast();
    expectedHistory.add(mocks.lastStackNavigator);
    expect(navigatorState.getHistory(), expectedHistory);
  }

  void shouldUpdateHistoryByResettingStacks() {
    expect(navigatorState.getHistory(), [mocks.lastStackNavigator]);
  }

  void shouldPushNewRoute() {
    verify(() => mocks.rootNavigatorObserver.didPush(any(), any())).called(mocks.initialPages.length + 1);
  }

  void shouldPushNewRoutesWithCorrectNames(int times) {
    final verified = verify(() => mocks.rootNavigatorObserver.didPush(captureAny(), any()));
    verified.called(mocks.initialPages.length + times);
    final indexes = verified.captured.map((route) {
      final exp = RegExp(r"beagle-root-navigator-stack-(\d+)");
      final routeName = (route as Route<dynamic>).settings.name as String;
      final match = exp.firstMatch(routeName);
      expect(match == null, false);
      return int.parse(match?.group(1) as String);
    }).toList();
    // should be sequential
    for (int i = 0; i < indexes.length; i++) {
      expect(indexes[i], indexes[0] + i);
    }
  }

  void shouldReplaceLastRouteWithNew() {
    verify(() => mocks.rootNavigatorObserver.didReplace(
          newRoute: any(named: 'newRoute'),
          oldRoute: any(named: 'oldRoute'),
        )).called(1);
  }

  void shouldRemoveEveryRoute() {
    verify(() => mocks.rootNavigatorObserver.didRemove(any(), any())).called(mocks.initialPages.length);
  }

  void shouldPopRoute() {
    verify(() => mocks.rootNavigatorObserver.didPop(any(), any())).called(1);
  }

  void shouldPopRootNavigator() {
    verify(() => mocks.topNavigatorObserver.didPop(any(), any())).called(1);
  }

  void shouldRenderNewStackNavigator() {
    expect(find.byWidget(mocks.lastStackNavigator), findsOneWidget);
  }

  void shouldRenderPreviousStackNavigator() {
    expect(find.byWidget(mocks.initialPages.elementAt(mocks.initialPages.length - 2)), findsOneWidget);
  }

  void shouldRenderPreviousStackNavigatorAndSetNavigationContextOnTheLastItem(NavigationContext navigationContext) {
    final widgetAtPosition = mocks.initialPages.elementAt(mocks.initialPages.length - 2);
    expect(find.byWidget(widgetAtPosition), findsOneWidget);
    verify(() => widgetAtPosition.setNavigationContext(navigationContext)).called(1);
  }

  void shouldPushViewToCurrentStack(BeagleRoute route) {
    verify(() => mocks.initialPages.last.pushView(route, mocks.lastStackNavigator.buildContext)).called(1);
  }

  void shouldPopViewFromCurrentStack([NavigationContext? navigationContext]) {
    verify(() => mocks.initialPages.last.popView(navigationContext)).called(1);
  }

  void shouldPopToViewOfCurrentStack(String viewName, [NavigationContext? navigationContext]) {
    verify(() => mocks.initialPages.last.popToView(viewName, navigationContext)).called(1);
  }
}
