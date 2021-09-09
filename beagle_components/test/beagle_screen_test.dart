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
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'service_locator/service_locator.dart';

class MockBeagleYogaFactory extends Mock implements BeagleYogaFactory {}

class MockDesignSystem extends Mock implements BeagleDesignSystem {}

class MockBeagleLogger extends Mock implements BeagleLogger {}

Widget createWidget({
  String identifier,
  BeagleSafeArea safeArea,
  BeagleNavigationBar navigationBar,
}) {
  return MaterialApp(
    home: BeagleScreen(
      key: Key('screenKey'),
      identifier: identifier,
      safeArea: safeArea,
      navigationBar: navigationBar,
      child: Text('Screen content'),
    ),
  );
}

void main() {
  final beagleYogaFactoryMock = MockBeagleYogaFactory();
  final designSystemMock = MockDesignSystem();
  final beagleLoggerMock = MockBeagleLogger();

  final navigationBarStyleId = 'navigationBarStyleId';
  final navigationBarStyle =
      BeagleNavigationBarStyle(backgroundColor: Colors.blue, centerTitle: true);

  setUpAll(() async {
    when(beagleYogaFactoryMock.createYogaLayout(
      style: anyNamed('style'),
      children: anyNamed('children'),
    )).thenAnswer((realInvocation) {
      final List<Widget> children = realInvocation.namedArguments.values.last;
      return children.first;
    });

    when(designSystemMock.navigationBarStyle(navigationBarStyleId))
        .thenReturn(navigationBarStyle);

    await testSetupServiceLocator(
      beagleYogaFactory: beagleYogaFactoryMock,
      designSystem: designSystemMock,
      logger: beagleLoggerMock,
    );
  });

  group('Given a BeagleScreen', () {
    group('When it is created', () {
      testWidgets('Then it should render a scaffold',
          (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createWidget());

        // When
        final scaffoldFinder = find.byType(Scaffold);

        // Then
        expect(scaffoldFinder, findsOneWidget);
      });
    });

    group('When it is created with a navigationBar', () {
      testWidgets('Then it should render an appBar',
          (WidgetTester tester) async {
        // Given
        final navigationBar = BeagleNavigationBar(
          title: '',
          showBackButton: true,
          navigationBarItems: [],
        );

        // When
        await tester.pumpWidget(createWidget(navigationBar: navigationBar));
        final scaffoldFinder = find.byType(Scaffold);

        // Then
        expect(tester.widget<Scaffold>(scaffoldFinder).appBar != null, isTrue);
      });
    });

    group('When it is created with a title in navigationBar', () {
      testWidgets('Then it should render an appBar with the given title',
          (WidgetTester tester) async {
        // Given
        final navigationBar = BeagleNavigationBar(
          title: 'Title',
          showBackButton: true,
          navigationBarItems: [],
        );

        // When
        await tester.pumpWidget(createWidget(navigationBar: navigationBar));
        final titleFinder = find.text(navigationBar.title);

        // Then
        expect(titleFinder, findsOneWidget);
      });
    });

    group('When it is created with a style in navigationBar', () {
      testWidgets('Then it should render an appBar with the given style',
          (WidgetTester tester) async {
        // Given
        final navigationBar = BeagleNavigationBar(
          title: 'Title',
          showBackButton: true,
          styleId: navigationBarStyleId,
          navigationBarItems: [],
        );

        // When
        await tester.pumpWidget(createWidget(navigationBar: navigationBar));
        final scaffoldFinder = find.byType(Scaffold);
        final AppBar appBar = tester.widget<Scaffold>(scaffoldFinder).appBar;

        // Then
        expect(appBar.backgroundColor, navigationBarStyle.backgroundColor);
        expect(appBar.centerTitle, navigationBarStyle.centerTitle);
      });
    });

    group('When it is created with a item in navigationBar', () {
      testWidgets(
          'Then it should render an ItemComponent with the given properties',
          (WidgetTester tester) async {
        // Given
        final item = NavigationBarItem(
          text: 'Item',
        );
        final navigationBar = BeagleNavigationBar(
          title: 'Title',
          showBackButton: true,
          styleId: navigationBarStyleId,
          navigationBarItems: [item],
        );

        // When
        await tester.pumpWidget(createWidget(navigationBar: navigationBar));
        final scaffoldFinder = find.byType(Scaffold);
        final AppBar appBar = tester.widget<Scaffold>(scaffoldFinder).appBar;
        final ItemComponent itemComponent = appBar.actions.first;
        // Then
        expect(itemComponent.item, item);
      });
    });

    group('When it is created with a safeArea', () {
      testWidgets('Then it should render a safeArea widget',
          (WidgetTester tester) async {
        // Given
        final safeArea = BeagleSafeArea(
          top: true,
          leading: true,
          bottom: true,
          trailing: true,
        );

        // When
        await tester.pumpWidget(createWidget(safeArea: safeArea));
        final safeAreaFinder = find.byType(SafeArea);
        final safeAreaWidget = tester.widget<SafeArea>(safeAreaFinder);

        // Then
        expect(safeAreaFinder, findsOneWidget);
        expect(safeAreaWidget.top, safeArea.top);
        expect(safeAreaWidget.left, safeArea.leading);
        expect(safeAreaWidget.bottom, safeArea.bottom);
        expect(safeAreaWidget.right, safeArea.trailing);
      });
    });
  });
}
