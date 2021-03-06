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

import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createWidget({
  ScrollAxis scrollDirection = ScrollAxis.VERTICAL,
  bool scrollBarEnabled = true,
}) {
  return MaterialApp(
    home: BeagleScrollView(
      key: Key('scrollKey'),
      scrollBarEnabled: scrollBarEnabled,
      scrollDirection: scrollDirection,
      children: [Text('Scrollable content')],
    ),
  );
}

void main() {
  group('Given a BeagleScrollView', () {
    group('When the widget is created', () {
      testWidgets(
        'Then there should be a vertical ListView with a visible ScrollBar and a Text as its content',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidget());

          final scrollbarFinder = find.byType(Scrollbar);

          expect(scrollbarFinder, findsOneWidget);
          expect(find.byType(ListView), findsOneWidget);
          expect(find.byType(Text), findsOneWidget);

          final scrollbar = tester.widget<Scrollbar>(scrollbarFinder);
          final ListView listView = scrollbar.child as ListView;
          expect(listView.scrollDirection, Axis.vertical);
          expect(listView.semanticChildCount, 1);
        },
      );
    });

    group('When the widget is created with a horizontal scroll', () {
      testWidgets('Then the list view orientation should be horizontal', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(scrollDirection: ScrollAxis.HORIZONTAL));
        final ListView listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.scrollDirection == Axis.horizontal, isTrue);
      });
    });

    group('When the widget is created with a hidden scroll bar', () {
      testWidgets('Then there should be a ListView, but no ScrollBar', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(scrollBarEnabled: false));
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(Scrollbar), findsNothing);
      });
    });
  });
}
