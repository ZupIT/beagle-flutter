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

import 'mock.dart';

typedef RetryFn = Future<void> Function();

class RootNavigatorExpectations {
  RootNavigatorExpectations({
    @required this.mocks,
    @required WidgetTester tester,
    this.route,
  }) : navigatorState = tester.state(find.byType(RootNavigator));

  final RootNavigatorMocks mocks;
  final BeagleRoute route;
  final RootNavigatorState navigatorState;

  void _shouldCreateStackNavigator([String customController]) {
    verify(mocks.stackNavigatorFactory(
      initialRoute: route,
      screenBuilder: mocks.screenBuilder,
      rootNavigator: navigatorState,
      logger: mocks.logger,
      viewClient: mocks.beagleService.viewClient,
      controller: customController == null
        ? mocks.beagleService.defaultNavigationController
        : mocks.beagleService.navigationControllers[customController],
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

  void shouldNotUpdateHistory() {
    expect(navigatorState.getHistory(), mocks.initialPages);
  }

  void shouldPushNewRoute() {
    verify(mocks.rootNavigatorObserver.didPush(any, any)).called(mocks.initialPages.length + 1);
  }

  void shouldPopRoute() {
    verify(mocks.rootNavigatorObserver.didPop(any, any)).called(1);
  }

  void shouldPopRootNavigator() {
    verify(mocks.topNavigatorObserver.didPop(any, any)).called(1);
  }

  void shouldRenderNewStackNavigator() {
    expect(find.byWidget(mocks.lastStackNavigator), findsOneWidget);
  }

  void shouldRenderPreviousStackNavigator() {
    expect(find.byWidget(mocks.initialPages.elementAt(mocks.initialPages.length - 2)), findsOneWidget);
  }

  void shouldPushViewToCurrentStack(BeagleRoute route) {
    verify(mocks.initialPages.last.pushView(route, any)).called(1);
  }

  void shouldPopViewFromCurrentStack() {
    verify(mocks.initialPages.last.popView(any)).called(1);
  }

  void shouldPopToViewOfCurrentStack(String viewName) {
    verify(mocks.initialPages.last.popToView(viewName, any)).called(1);
  }
}
