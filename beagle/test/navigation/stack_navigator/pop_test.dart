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

void main() {
  group('Given a StackNavigator class', () {
    group('When a view is popped from a StackNavigator with 3 pages', () {
      final mocks = NavigationMocks();
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 3);

      Future<void> _setup(WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Material(child: navigator),
        ));
        navigator.popView(mocks.lastBuildContext);
        await tester.pump();
      }

      testWidgets('Then it should pop the last page and render the previous', (WidgetTester tester) async {
        await _setup(tester);
        expect(navigator.getHistory(), [createPageName(0), createPageName(1)]);
        expect(find.byKey(Key(createPageName(1))), findsOneWidget);
      });
    });

    group('When a view is popped from a StackNavigator with 1 page', () {
      final mocks = NavigationMocks();
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 1);

      Future<void> _setup(WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Material(child: navigator),
        ));
        navigator.popView(mocks.lastBuildContext);
        await tester.pump();
      }

      testWidgets("Then it should pop the rootNavigator's stack", (WidgetTester tester) async {
        await _setup(tester);
        verify(mocks.rootNavigator.popStack(mocks.lastBuildContext)).called(1);
      });
    });

    group('When a popToView is called for existing view', () {
      final mocks = NavigationMocks();
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 4);

      Future<void> _setup(WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Material(child: navigator),
        ));
        navigator.popToView(createPageName(1), mocks.lastBuildContext);
        await tester.pump();
      }

      testWidgets('Then it should pop the last page and render the previous', (WidgetTester tester) async {
        await _setup(tester);
        expect(navigator.getHistory(), [createPageName(0), createPageName(1)]);
        expect(find.byKey(Key(createPageName(1))), findsOneWidget);
      });
    });

    group("When a popToView is called for view that doesn't exist", () {
      final mocks = NavigationMocks();
      final navigator = createStackNavigator(mocks: mocks, initialNumberOfPages: 4);

      Future<void> _setup(WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Material(child: navigator),
        ));
        navigator.popToView('fake_view', mocks.lastBuildContext);
        await tester.pump();
      }

      testWidgets('Then it should not navigate and log error', (WidgetTester tester) async {
        await _setup(tester);
        verify(mocks.logger.error(any)).called(1);
        expect(navigator.getHistory(), [createPageName(0), createPageName(1), createPageName(2), createPageName(3)]);
        expect(find.byKey(Key(createPageName(3))), findsOneWidget);
      });
    });
  });
}
