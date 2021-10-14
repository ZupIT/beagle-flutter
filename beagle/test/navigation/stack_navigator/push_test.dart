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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

typedef CompleteFn = void Function();

const SERVER_DELAY_MS = 50;

void main() {
  group('Given a StackNavigator class', () {
    final remoteView = RemoteView('/test');
    final screen = BeagleUIElement({ 'id': 'test', '_beagleComponent_': 'beagle:container' });
    final localView = LocalView(screen);
    final error = Error();

    StackNavigatorExpectations _createTestSuit(NavigationMocks mocks, [BeagleRoute route]) {
      return StackNavigatorExpectations(
        screen: screen,
        route: route ?? remoteView,
        mocks: mocks,
        expectedCompleteFnType: CompleteFn,
        expectedError: error,
      );
    }

    void mockSuccessfulRequest(NavigationMocks mocks) {
      when(mocks.viewClient.fetch(remoteView)).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: SERVER_DELAY_MS), () => Future.value(screen)),
      );
    }

    void mockUnsuccessfulRequest(NavigationMocks mocks) {
      when(mocks.viewClient.fetch(remoteView)).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: SERVER_DELAY_MS), () => Future.error(error)),
      );
    }

    group("When a RemoteView is pushed to a StackNavigator", () {
      final mocks = NavigationMocks();
      final expectations = _createTestSuit(mocks);
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 1);

      Future<void> _setup(WidgetTester tester) {
        return tester.runAsync(() async {
          await tester.pumpWidget(MaterialApp(
            home: Material(child: navigator),
          ));
          mockSuccessfulRequest(mocks);
          await navigator.pushView(remoteView, mocks.lastBuildContext);
          await tester.pump();
        });
      }

      testWidgets('Then it should fetch and render the new route', (WidgetTester tester) async {
        await _setup(tester);
        expectations.shouldFetchRoute();
        expectations.shouldCreateBeagleWidget();
        expectations.shouldHandleOnLoading();
        expectations.shouldNotHandleOnError();
        expectations.shouldHandleOnSuccess();
        expectations.shouldUpdateHistory(navigator, 1);
        expectations.shouldRenderScreen();
      });
    });

    group("When a RemoteView is pushed and the navigation completes inside the onLoading handler", () {
      final mocks = NavigationMocks();
      final expectations = _createTestSuit(mocks);
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 1);

      Future<void> _setup(WidgetTester tester) {
        return tester.runAsync(() async {
          await tester.pumpWidget(MaterialApp(
            home: Material(child: navigator),
          ));
          mockSuccessfulRequest(mocks);
          // completes the navigation when the loading starts
          when(mocks.controller.onLoading(
            context: anyNamed('context'),
            view: anyNamed('view'),
            completeNavigation: anyNamed('completeNavigation'),
          )).thenAnswer((realInvocation) {
            realInvocation.namedArguments[Symbol('completeNavigation')]();
          });
          // It's important not to await the next line
          navigator.pushView(remoteView, mocks.lastBuildContext);
          await tester.pump();
        });
      }

      testWidgets('Then it should render the Beagle screen as soon as pushView is called', (WidgetTester tester) async {
        await _setup(tester);
        expectations.shouldHandleOnLoading();
        expectations.shouldUpdateHistory(navigator, 1);
        expectations.shouldRenderScreen();
      });
    });

    group("When a RemoteView is pushed, but the fetch fails", () {
      final mocks = NavigationMocks();
      final expectations = _createTestSuit(mocks);
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 1);

      Future<void> _setup(WidgetTester tester) {
        return tester.runAsync(() async {
          await tester.pumpWidget(MaterialApp(
            home: Material(child: navigator),
          ));
          mockUnsuccessfulRequest(mocks);
          await navigator.pushView(remoteView, mocks.lastBuildContext);
          await tester.pump();
        });
      }

      testWidgets('Then it should call error and not render anything', (WidgetTester tester) async {
        await _setup(tester);
        expectations.shouldHandleOnError();
        expectations.shouldNotHandleOnSuccess();
        expectations.shouldNotUpdateHistory(navigator, 1);
        expectations.shouldNotRenderScreen();
      });
    });

    group("When a RemoteView is pushed, the fetch fails and the onError handler completes the navigation", () {
      final mocks = NavigationMocks();
      final expectations = _createTestSuit(mocks);
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 1);

      Future<void> _setup(WidgetTester tester) {
        return tester.runAsync(() async {
          await tester.pumpWidget(MaterialApp(
            home: Material(child: navigator),
          ));
          mockUnsuccessfulRequest(mocks);
          // completes the navigation when the loading starts
          when(mocks.controller.onError(
            context: anyNamed('context'),
            view: anyNamed('view'),
            completeNavigation: anyNamed('completeNavigation'),
            stackTrace: anyNamed('stackTrace'),
            retry: anyNamed('retry'),
            error: anyNamed('error'),
          )).thenAnswer((realInvocation) {
            realInvocation.namedArguments[Symbol('completeNavigation')]();
          });
          await navigator.pushView(remoteView, mocks.lastBuildContext);
          await tester.pump();
        });
      }

      testWidgets('Then it should render even with an error', (WidgetTester tester) async {
        await _setup(tester);
        expectations.shouldUpdateHistory(navigator, 1);
        expectations.shouldRenderScreen();
      });
    });

    group("When a RemoteView is pushed, the fetch fails and a successful retrial is made", () {
      final mocks = NavigationMocks();
      final expectations = _createTestSuit(mocks);
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 1);

      Future<void> _setup(WidgetTester tester) {
        return tester.runAsync(() async {
          Future<void> Function() retry;
          await tester.pumpWidget(MaterialApp(
            home: Material(child: navigator),
          ));
          mockUnsuccessfulRequest(mocks);
          // completes the navigation when the loading starts
          when(mocks.controller.onError(
            context: anyNamed('context'),
            view: anyNamed('view'),
            completeNavigation: anyNamed('completeNavigation'),
            stackTrace: anyNamed('stackTrace'),
            retry: anyNamed('retry'),
            error: anyNamed('error'),
          )).thenAnswer((realInvocation) {
            retry = realInvocation.namedArguments[Symbol('retry')];
          });
          await navigator.pushView(remoteView, mocks.lastBuildContext);
          mockSuccessfulRequest(mocks);
          await retry();
          await tester.pump();
        });
      }

      testWidgets('Then it should render the resulting screen', (WidgetTester tester) async {
        await _setup(tester);
        expectations.shouldFetchRoute(2);
        expectations.shouldHandleOnLoading(2);
        expectations.shouldHandleOnSuccess();
        expectations.shouldUpdateHistory(navigator, 1);
        expectations.shouldRenderScreen();
      });
    });

    group("When a LocalView is pushed", () {
      final mocks = NavigationMocks();
      final expectations = _createTestSuit(mocks, localView);
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 1);

      Future<void> _setup(WidgetTester tester) {
        return tester.runAsync(() async {
          await tester.pumpWidget(MaterialApp(
            home: Material(child: navigator),
          ));
          // It's important not to await the next line
          navigator.pushView(localView, mocks.lastBuildContext);
          await tester.pump();
        });
      }

      testWidgets(
        'Then it should render the screen immediately, without contacting the backend',
        (WidgetTester tester) async {
          await _setup(tester);
          expectations.shouldNotFetchRoute();
          expectations.shouldCreateBeagleWidget();
          expectations.shouldNotHandleOnLoading();
          expectations.shouldNotHandleOnError();
          expectations.shouldHandleOnSuccess();
          expectations.shouldUpdateHistory(navigator, 1);
          expectations.shouldRenderScreen();
        },
      );
    });
  });
}
