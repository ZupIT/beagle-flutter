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
import 'package:mocktail/mocktail.dart';

import 'test-utils/provider_mock.dart';

class _BeagleThemeMock extends Mock implements BeagleTheme {}

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final logger = _BeagleLoggerMock();
}

Widget createWidget({
  required BeagleService beagle,
  required String identifier,
  required BeagleSafeArea safeArea,
  required BeagleNavigationBar navigationBar,
  required BeagleTheme theme,
}) {
  return BeagleProviderMock(
    beagle: beagle,
    child: BeagleThemeProvider(
      theme: theme,
      child: MaterialApp(
        home: BeagleScreen(
          key: Key('screenKey'),
          identifier: identifier,
          safeArea: safeArea,
          navigationBar: navigationBar,
          child: Text('Screen content'),
        ),
      )
    ),
  );
}

void main() {
  final beagle = _BeagleServiceMock();
  final theme = _BeagleThemeMock();
  final navigationBarStyleId = 'navigationBarStyleId';
  final navigationBarStyle = BeagleNavigationBarStyle(backgroundColor: Colors.blue, centerTitle: true);
  final identifierDefault = 'widgetIdentifier';
  final safeAreaDefault = BeagleSafeArea(
    top: true,
    leading: true,
    bottom: true,
    trailing: true,
  );
  final navigationBarDefault = BeagleNavigationBar(
    title: 'Title',
    showBackButton: true,
    navigationBarItems: [],
  );

  setUpAll(() {
    when(() => theme.navigationBarStyle(navigationBarStyleId)).thenReturn(navigationBarStyle);
  });

  group('Given a BeagleScreen', () {
    group('When it is created', () {
      testWidgets('Then it should render a scaffold', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          beagle: beagle,
          theme: theme,
          identifier: identifierDefault,
          safeArea: safeAreaDefault,
          navigationBar: navigationBarDefault,
        ));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('When it is created with a navigationBar', () {
      testWidgets('Then it should render an appBar', (WidgetTester tester) async {
        final navigationBar = BeagleNavigationBar(
          title: '',
          showBackButton: true,
          navigationBarItems: [],
        );
        await tester.pumpWidget(createWidget(
          beagle: beagle,
          theme: theme,
          identifier: identifierDefault,
          safeArea: safeAreaDefault,
          navigationBar: navigationBar,
        ));
        expect(tester.widget<Scaffold>(find.byType(Scaffold)).appBar != null, isTrue);
      });
    });

    group('When it is created with a title in navigationBar', () {
      testWidgets('Then it should render an appBar with the given title', (WidgetTester tester) async {
        final navigationBar = BeagleNavigationBar(
          title: 'Title',
          showBackButton: true,
          navigationBarItems: [],
        );
        await tester.pumpWidget(createWidget(
          beagle: beagle,
          theme: theme,
          identifier: identifierDefault,
          safeArea: safeAreaDefault,
          navigationBar: navigationBar,
        ));
        expect(find.text(navigationBar.title), findsOneWidget);
      });
    });

    group('When it is created with a style in navigationBar', () {
      testWidgets('Then it should render an appBar with the given style', (WidgetTester tester) async {
        final navigationBar = BeagleNavigationBar(
          title: 'Title',
          showBackButton: true,
          styleId: navigationBarStyleId,
          navigationBarItems: [],
        );

        await tester.pumpWidget(createWidget(
          beagle: beagle,
          theme: theme,
          identifier: identifierDefault,
          safeArea: safeAreaDefault,
          navigationBar: navigationBar,
        ));

        final AppBar appBar = tester.widget<Scaffold>(find.byType(Scaffold)).appBar as AppBar;
        expect(appBar.backgroundColor, navigationBarStyle.backgroundColor);
        expect(appBar.centerTitle, navigationBarStyle.centerTitle);
      });
    });

    group('When it is created with a item in navigationBar', () {
      testWidgets('Then it should render an ItemComponent with the given properties', (WidgetTester tester) async {
        final item = NavigationBarItem(text: 'Item', image: 'images/beagle_dog.png', onPress: () {});
        final navigationBar = BeagleNavigationBar(
          title: 'Title',
          showBackButton: true,
          styleId: navigationBarStyleId,
          navigationBarItems: [item],
        );

        await tester.pumpWidget(createWidget(
          beagle: beagle,
          theme: theme,
          identifier: identifierDefault,
          safeArea: safeAreaDefault,
          navigationBar: navigationBar,
        ));
        final AppBar appBar = tester.widget<Scaffold>(find.byType(Scaffold)).appBar as AppBar;
        expect((appBar.actions!.first as ItemComponent).item, item);
      });
    });

    group('When it is created with a safeArea', () {
      testWidgets('Then it should render a safeArea widget', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          beagle: beagle,
          theme: theme,
          identifier: identifierDefault,
          safeArea: safeAreaDefault,
          navigationBar: navigationBarDefault,
        ));

        final safeAreaFinder = find.byType(SafeArea).first;
        final safeAreaWidget = tester.widget<SafeArea>(safeAreaFinder);

        expect(safeAreaFinder, findsOneWidget);
        expect(safeAreaWidget.top, safeAreaDefault.top);
        expect(safeAreaWidget.left, safeAreaDefault.leading);
        expect(safeAreaWidget.bottom, safeAreaDefault.bottom);
        expect(safeAreaWidget.right, safeAreaDefault.trailing);
      });
    });
  });
}
