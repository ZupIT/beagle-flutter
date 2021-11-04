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
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const text = 'text';

class MockBeagleYogaFactory extends Mock implements BeagleYogaFactory {}

Widget createWidget({
  BeagleStyle? style,
}) {
  return MaterialApp(
    home: StylizationWidget().apply(Text('text'), style),
  );
}

void main() {
  group('Given a StylizationWidget', () {
    group('When set null style', () {
      testWidgets('Then it should not have decorated box',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          style: null,
        ));

        final decoratedBoxFinder = find.byType(DecoratedBox);
        final textFinder = find.text(text);

        expect(textFinder, findsOneWidget);
        expect(decoratedBoxFinder, findsNothing);
      });
    });

    group('When set style with null properties', () {
      testWidgets('Then it should not have decorated box',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          style: BeagleStyle(),
        ));

        final decoratedBoxFinder = find.byType(DecoratedBox);
        final textFinder = find.text(text);

        expect(textFinder, findsOneWidget);
        expect(decoratedBoxFinder, findsNothing);
      });
    });

    group('When set style with background', () {
      testWidgets('Then it should have decorated box with background',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          style: BeagleStyle(
            backgroundColor: '#f1f1f1',
          ),
        ));

        final decoratedBoxFinder = find.byType(DecoratedBox);
        final decoratedBox = tester.widget<DecoratedBox>(decoratedBoxFinder);
        final boxDecoration = decoratedBox.decoration as BoxDecoration;

        final textFinder = find.text(text);

        expect(textFinder, findsOneWidget);
        expect(decoratedBoxFinder, findsOneWidget);
        expect(boxDecoration.color, HexColor('#f1f1f1'));
      });
    });

    group('When set style with border', () {
      testWidgets('Then it should have decorated box with border',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          style: BeagleStyle(borderWidth: 1, borderColor: '#f1f1f1'),
        ));

        final decoratedBoxFinder = find.byType(DecoratedBox);
        final decoratedBox = tester.widget<DecoratedBox>(decoratedBoxFinder);
        final boxDecoration = decoratedBox.decoration as BoxDecoration;

        final textFinder = find.text(text);

        expect(textFinder, findsOneWidget);
        expect(decoratedBoxFinder, findsOneWidget);
        expect(
            boxDecoration.border,
            Border.all(
              color: HexColor('#f1f1f1'),
              width: 1,
            ));
      });
    });

    group('When set style with corner radius', () {
      testWidgets('Then it should have decorated box with corner radius',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          style: BeagleStyle(
            cornerRadius: CornerRadius(
              radius: 1,
            ),
          ),
        ));

        final decoratedBoxFinder = find.byType(DecoratedBox);
        final decoratedBox = tester.widget<DecoratedBox>(decoratedBoxFinder);
        final boxDecoration = decoratedBox.decoration as BoxDecoration;

        final textFinder = find.text(text);

        expect(textFinder, findsOneWidget);
        expect(decoratedBoxFinder, findsOneWidget);
        final radius = Radius.circular(1);
        expect(
          boxDecoration.borderRadius,
          BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius,
          ),
        );
      });
    });
  });
}
