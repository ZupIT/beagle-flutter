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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'objects_fake/fake_theme.dart';

const buttonText = 'Beagle Button';
const buttonKey = Key('BeagleButton');

void buttonOnPress() {}

Widget createWidget({
  Key buttonKey = buttonKey,
  String buttonText = buttonText,
  void Function() buttonOnPress = buttonOnPress,
  bool buttonEnabled = true,
  String? styleId,
}) {
  return BeagleThemeProvider(
    theme: FakeTheme(),
    child: MaterialApp(
      home: BeagleButton(
        key: buttonKey,
        text: buttonText,
        onPress: buttonOnPress,
        enabled: buttonEnabled,
        styleId: styleId,
      ),
    ),
  );
}

void main() {
  group('Given a BeagleButton', () {
    group('When the widget is created', () {
      testWidgets('Then it should have a ElevatedButton child', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('When it has a text', () {
      testWidgets('Then it should have a Text widget with specified text', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        expect(find.text(buttonText), findsOneWidget);
      });
    });

    group('When it is enabled', () {
      testWidgets('Then the button widget should be enabled', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, isTrue);
      });

      testWidgets('Then should fire onPress callback', (WidgetTester tester) async {
        final log = <int>[];
        void onPressed() {
          log.add(0);
        }

        await tester.pumpWidget(createWidget(buttonOnPress: onPressed));
        await tester.tap(find.byType(BeagleButton));

        expect(log.length, 1);
      });
    });

    group('When it is disabled', () {
      testWidgets('Then the button widget should be disabled', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(buttonEnabled: false));
        expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, isFalse);
      });

      testWidgets("Then shouldn't fire onPress callback", (WidgetTester tester) async {
        final log = <int>[];
        void onPressed() {
          log.add(0);
        }

        final widget = createWidget(
          buttonOnPress: onPressed,
          buttonEnabled: false,
        );

        await tester.pumpWidget(widget);
        await tester.tap(find.byType(BeagleButton));

        expect(log.length, 0);
      });
    });

    group('When not set style', () {
      testWidgets('Then it should not have a style', (WidgetTester tester) async {
        // WHEN
        await tester.pumpWidget(createWidget());

        // THEN
        final buttonFinder = find.byType(ElevatedButton);
        final buttonCreated = tester.widget<ElevatedButton>(buttonFinder);
        final textCreated = tester.widget<Text>(find.text(buttonText));

        expect(buttonFinder, findsOneWidget);
        expect(buttonCreated.style, null);
        expect(textCreated.style, null);

        debugDefaultTargetPlatformOverride = null;
      });
    });
  });
}
