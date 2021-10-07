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

import 'package:beagle/src/action/beagle_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const showAlertButtonText = 'Show Confirm Alert';

MaterialApp _buildApp({
  String? title,
  String? message,
  String? labelOk,
  Function? onPressOk,
  String? labelCancel,
  Function? onPressCancel,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              BeagleConfirm.showAlertDialog(
                context,
                title: title,
                message: message,
                labelOk: labelOk,
                onPressOk: onPressOk,
                labelCancel: labelCancel,
                onPressCancel: onPressCancel,
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
  group('Given a BeagleConfirm', () {
    group('When I call showAlertDialog', () {
      testWidgets('Then it should show an AlertDialog widget',
          (WidgetTester tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        final alertDialogFinder = find.byType(AlertDialog);

        expect(alertDialogFinder, findsOneWidget);
      });

      testWidgets('Then it should show correct title and message',
          (WidgetTester tester) async {
        const expectedTitle = 'Title';
        const expectedMessage = 'This is a message.';

        await tester.pumpWidget(_buildApp(
          title: expectedTitle,
          message: expectedMessage,
        ));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        final titleFinder = find.text(expectedTitle);
        final messageFinder = find.text(expectedMessage);

        expect(titleFinder, findsOneWidget);
        expect(messageFinder, findsOneWidget);
      });

      testWidgets('Then it should have default buttons',
          (WidgetTester tester) async {
        const buttonTextOk = 'OK';
        const buttonTextCancel = 'Cancel';
        await tester.pumpWidget(_buildApp());
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        final textOkFinder = find.text(buttonTextOk);
        final textCancelFinder = find.text(buttonTextCancel);

        expect(textOkFinder, findsOneWidget);
        expect(textCancelFinder, findsOneWidget);
      });

      testWidgets('Then it should have default buttons with custom text',
          (WidgetTester tester) async {
        const buttonTextOk = 'OkTest';
        const buttonTextCancel = 'CancelTest';
        await tester.pumpWidget(
            _buildApp(labelOk: buttonTextOk, labelCancel: buttonTextCancel));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        final textOkFinder = find.text(buttonTextOk);
        final textCancelFinder = find.text(buttonTextCancel);

        expect(textOkFinder, findsOneWidget);
        expect(textCancelFinder, findsOneWidget);
      });
    });

    group('When I press the OK button', () {
      testWidgets('Then it should call onPress callback',
          (WidgetTester tester) async {
        const buttonText = 'OK';
        var didPressOk = false;
        void onPressOK() {
          didPressOk = true;
        }

        await tester.pumpWidget(_buildApp(onPressOk: onPressOK));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        expect(didPressOk, false);

        await tester.tap(find.text(buttonText));

        expect(didPressOk, true);
      });
    });

    group('When I press the Cancel button', () {
      testWidgets('Then it should call onPress callback',
          (WidgetTester tester) async {
        const buttonText = 'Cancel';
        var didPressCancel = false;
        void onPressCancel() {
          didPressCancel = true;
        }

        await tester.pumpWidget(_buildApp(onPressCancel: onPressCancel));
        await tester.tap(find.text(showAlertButtonText));
        await tester.pumpAndSettle();

        expect(didPressCancel, false);

        await tester.tap(find.text(buttonText));

        expect(didPressCancel, true);
      });
    });
  });
}
