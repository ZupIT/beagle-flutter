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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test-utils/provider_mock.dart';

// FIXME: these tests don't pass when run all at once.

class _BeagleThemeMock extends Mock implements BeagleTheme {}

class _BeagleServiceMock extends Mock implements BeagleService {}

void main() {
  final beagle = _BeagleServiceMock();
  final theme = _BeagleThemeMock();
  when(() => theme.image(any())).thenReturn('images/beagle.png');
  const tabBarKey = Key('BeagleTabBar');
  final tabBarItems = <TabBarItem>[
    TabBarItem('Tab 1', LocalImagePath('')),
    TabBarItem('Tab 2', LocalImagePath('')),
    TabBarItem('Tab 3', LocalImagePath('')),
  ];

  Widget createWidget({
    Key key = tabBarKey,
    List<TabBarItem> items = const [],
    int currentTab = 0,
    void Function(int)? onTabSelection,
  }) {
    return BeagleProviderMock(
      beagle: beagle,
      child: BeagleThemeProvider(
        theme: theme,
        child: MaterialApp(
          home: Scaffold(
            body: BeagleTabBar(
              // key: tabBarKey,
              items: items,
              currentTab: currentTab,
              onTabSelection: onTabSelection ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Given a BeagleTabBar', () {
    group('When the platform is android', () {
      testWidgets('Then it should have a TabBar child',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        expect(find.byType(TabBar), findsOneWidget);
      });

      testWidgets('Then it should have the correct number of Tabs',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(items: tabBarItems));
        expect(find.byType(Tab), findsNWidgets(tabBarItems.length));
      });

      testWidgets('Then it should have icons', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(items: tabBarItems));
        expect(find.byType(BeagleImage), findsNWidgets(tabBarItems.length));
      });
    });

    group('When the platform is iOS', () {
      testWidgets('Then it should have a TabBar child',
          (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await tester.pumpWidget(createWidget(items: tabBarItems));

        expect(find.byType(TabBar), findsOneWidget);
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('Then it should have correct number of tabs',
          (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await tester.pumpWidget(createWidget(items: tabBarItems));

        expect(find.byType(Tab), findsNWidgets(tabBarItems.length));

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('When it has tabs', () {
      testWidgets('Then it should show correct tabs text',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(items: tabBarItems));

        expect(find.text('Tab 1'), findsOneWidget);
        expect(find.text('Tab 2'), findsOneWidget);
        expect(find.text('Tab 3'), findsOneWidget);
      });
    });

    group('When a tab is tapped', () {
      testWidgets('Then it should call onTabSelection callback',
          (WidgetTester tester) async {
        final log = <int>[];
        void onTabSelection(int tabIndex) {
          log.add(0);
        }

        await tester.pumpWidget(createWidget(
          items: tabBarItems,
          onTabSelection: onTabSelection,
        ));

        await tester.tap(find.text('Tab 1'));
        await tester.pump();
        expect(log.length, 1);

        await tester.tap(find.text('Tab 2'));
        await tester.pump();
        expect(log.length, 2);

        await tester.tap(find.text('Tab 3'));
        await tester.pump();
        expect(log.length, 3);

        await tester.tap(find.text('Tab 1'));
        await tester.pump();
        expect(log.length, 4);
      });

      testWidgets('Then it should update currentTab',
          (WidgetTester tester) async {
        var currentTab = -1;
        void onTabSelection(int tabIndex) {
          currentTab = tabIndex;
        }

        final widget = createWidget(
          items: tabBarItems,
          onTabSelection: onTabSelection,
        );

        await tester.pumpWidget(widget);

        await tester.tap(find.text('Tab 1'));
        await tester.pump();
        expect(currentTab, 0);

        await tester.tap(find.text('Tab 2'));
        await tester.pumpAndSettle();
        expect(currentTab, 1);

        await tester.tap(find.text('Tab 3'));
        await tester.pump();
        expect(currentTab, 2);

        await tester.tap(find.text('Tab 1'));
        await tester.pump();
        expect(currentTab, 0);
      });
    });
  });
}
