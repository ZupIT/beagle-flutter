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
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'expectations.dart';
import 'mock.dart';
import 'package:flutter_test/flutter_test.dart';

typedef CompleteFn = Null Function();

const SERVER_DELAY_MS = 50;

void main() {
  group('Given a StackNavigator class', () {
    group("When a StackNavigator is created", () {
      final mocks = NavigationMocks();
      final route = RemoteView('/test');
      final screen = BeagleUIElement({ '_beagleComponent_': 'beagle:container' });
      final expectations = StackNavigatorExpectations(
        screen: screen,
        route: route,
        mocks: mocks,
        expectedCompleteFnType: CompleteFn,
      );

      Future<void> _setup(WidgetTester tester) {
        return tester.runAsync(() async {
          final navigator = createStackNavigator(route, mocks);
          when(mocks.viewClient.fetch(route)).thenAnswer(
            (_) => Future.delayed(Duration(milliseconds: SERVER_DELAY_MS), () => Future.value(screen)),
          );
          await tester.pumpWidget(MaterialApp(
            home: Material(child: navigator),
            // navigatorObservers: [mocks.navigationObserver],
          ));
          await navigator.progress.current;
        });
      }

      testWidgets('Then it should fetch and render the initial route', (WidgetTester tester) async {
        await _setup(tester);
        expectations.shouldFetchRoute();
        expectations.shouldCreateBeagleWidget();
        expectations.shouldHandleOnLoading();
        expectations.shouldNotHandleOnError();
        expectations.shouldHandleOnSuccess();
        // expectations.shouldPushView();
        expectations.shouldRenderScreen();
      });
    });
  });
}
