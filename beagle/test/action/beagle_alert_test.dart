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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const showAlertButtonText = 'Show Alert';

MaterialApp _buildApp({
  required String title,
  required String message,
  String? labelOk,
  Function? onPressOk,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              BeagleAlert.showAlertDialog(
                context,
                title: title,
                message: message,
                onPressOk: onPressOk,
                labelOk: labelOk,
              );
            },
            child: const Text(showAlertButtonText),
          ),
        );
      },
    ),
  );
}

void main() {
  group('Given a BeagleAlert', () {
    group('When I call showAlertDialog', () {
      testWidgets('Then it should show an AlertDialog widget', (WidgetTester tester) async {
        await tester.pumpWidget(_buildApp(
          title: 'Alert title',
          message: 'Alert message, describing the alert.',
        ));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      });

      testWidgets('Then it should show correct title and message', (WidgetTester tester) async {
        const expectedTitle = 'Title';
        const expectedMessage = 'This is a message.';

        await tester.pumpWidget(_buildApp(
          title: expectedTitle,
          message: expectedMessage,
        ));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        expect(find.text(expectedTitle), findsOneWidget);
        expect(find.text(expectedMessage), findsOneWidget);
      });

      testWidgets('Then it should have a button with OK text', (WidgetTester tester) async {
        const buttonText = 'OK';
        await tester.pumpWidget(_buildApp(
          title: 'Alert title',
          message: 'Alert message, describing the alert.',
        ));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        expect(find.text(buttonText), findsOneWidget);
      });

      testWidgets('Then it should have a button with Yes text', (WidgetTester tester) async {
        const buttonText = 'Yes';
        await tester.pumpWidget(_buildApp(
          title: 'Alert title',
          message: 'Alert message, describing the alert.',
          labelOk: buttonText,
        ));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        expect(find.text(buttonText), findsOneWidget);
      });
    });
    group('When I press the OK button', () {
      testWidgets('Then it should call onPress callback', (WidgetTester tester) async {
        const buttonText = 'OK';
        var didPressOk = false;
        void onPressOK() {
          didPressOk = true;
        }

        await tester.pumpWidget(_buildApp(
          title: 'Alert title',
          message: 'Alert message, describing the alert.',
          labelOk: buttonText,
          onPressOk: onPressOK,
        ));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        expect(didPressOk, false);

        await tester.tap(find.text(buttonText));

        expect(didPressOk, true);
      });
    });
  });
}
