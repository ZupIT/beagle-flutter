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
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'objects_fake/fake_theme.dart';

const text = 'Beagle Text';
const textColor = '#00FF00';
const alignment = TextAlignment.RIGHT;
const textKey = Key('TextKey');
const textStyle = TextStyle(
  color: Colors.black,
  backgroundColor: Colors.indigo,
);

Widget createWidget({
  Key key = textKey,
  String? text = text,
  String? textColor = textColor,
  TextAlignment? alignment = alignment,
  String? styleId,
}) {
  return BeagleThemeProvider(
    theme: FakeTheme(),
    child: MaterialApp(
      home: BeagleText(
        key: key,
        text: text,
        textColor: textColor,
        alignment: alignment ?? TextAlignment.LEFT,
        styleId: styleId ?? '',
      ),
    ),
  );
}

void main() {
  group('Given a BeagleText', () {
    group('When the widget is rendered', () {
      testWidgets('Then it should have the correct text', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        expect(find.text(text), findsOneWidget);
      });

      testWidgets('Then it should have the correct text color', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        expect(tester.widget<Text>(find.text(text)).style!.color, HexColor(textColor));
      });

      testWidgets('Then it should have the correct text alignment', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        expect(tester.widget<Text>(find.text(text)).textAlign, TextAlign.right);
      });
    });

    group('When a text color is not specified', () {
      testWidgets('Then it should not set text color', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(textColor: null));
        expect(tester.widget<Text>(find.text(text)).style!.color, null);
      });
    });

    group('When a text alignment is not specified', () {
      testWidgets('Then it should set the alignment as left', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(alignment: null));
        expect(tester.widget<Text>(find.text(text)).textAlign, TextAlign.left);
      });
    });

    group('When set style', () {
      testWidgets('Then it should have the correct style', (WidgetTester tester) async {
        // WHEN
        await tester.pumpWidget(createWidget(styleId: 'text-one', textColor: null));

        //THEN
        final textCreated = tester.widget<Text>(find.text(text));

        expect(find.text(text), findsOneWidget);
        expect(textCreated.style!.color, textStyle.color);
        expect(textCreated.style!.backgroundColor, textStyle.backgroundColor);
      });
    });
  });

  group('When set style with text color', () {
    testWidgets('Then it should have the correct style', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(createWidget(styleId: 'text-one'));

      //THEN
      final textCreated = tester.widget<Text>(find.text(text));

      expect(find.text(text), findsOneWidget);
      expect(textCreated.style!.color, HexColor(textColor));
      expect(textCreated.style!.backgroundColor, textStyle.backgroundColor);
    });
  });

  group('When set alignment to CENTER ', () {
    testWidgets('Then it should be a Center Widget with text aligned to center', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(createWidget(alignment: TextAlignment.CENTER));

      //THEN
      final centerFinder = find.byType(Center);
      final centerCreated = tester.widget<Center>(centerFinder);

      expect(centerFinder, findsOneWidget);
      expect(find.text(text), findsOneWidget);
      expect((centerCreated.child as Text).textAlign, TextAlign.center);
    });
  });
}
