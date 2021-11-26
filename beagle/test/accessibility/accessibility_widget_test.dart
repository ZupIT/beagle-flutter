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
import 'package:beagle/src/accessibility/accessibility_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const text = 'text';

class MockBeagleYogaFactory extends Mock implements BeagleYogaFactory {}

Widget createWidget({
  BeagleAccessibility? accessibility,
}) {
  return MaterialApp(
    home: applyAccessibility(Text(text), accessibility),
  );
}

void main() {
  group('Given a AccessibilityWidget', () {
    group('When set null accessibility', () {
      testWidgets(
          'Then it should not have semantics with excludeSemantics true',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          accessibility: null,
        ));

        final semanticsType = find.byType(Semantics);
        final textFinder = find.text(text);
        final semanticsFinder =
            find.ancestor(of: textFinder, matching: semanticsType);
        final semanticsWidget = tester.firstWidget<Semantics>(semanticsFinder);


        expect(textFinder, findsOneWidget);
        expect(semanticsWidget.child.runtimeType, Text);
        expect(semanticsWidget.excludeSemantics, false);
      });
    });

    group('When set false accessibility.accessible', () {
      testWidgets(
          'Then it should have ExcludeSemantics Widget',
              (WidgetTester tester) async {
            await tester.pumpWidget(createWidget(
              accessibility: BeagleAccessibility(accessible: false),
            ));

            final semanticsType = find.byType(ExcludeSemantics);
            final textFinder = find.text(text);
            final semanticsFinder = find.ancestor(of: textFinder, matching: semanticsType);
            final excludeSemanticsWidget = tester.firstWidget<ExcludeSemantics>(semanticsFinder);

            expect(textFinder, findsOneWidget);
            expect(excludeSemanticsWidget.excluding, true);
            expect(excludeSemanticsWidget.child.runtimeType, Text);
            expect(semanticsFinder, findsOneWidget);
          });
    });

    group('When set accessibility with accessible true', () {
      testWidgets('Then it should have semantics without label',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          accessibility: BeagleAccessibility(accessible: true),
        ));

        final semanticsType = find.byType(Semantics);
        final textFinder = find.text(text);
        final semanticsFinder =
            find.ancestor(of: textFinder, matching: semanticsType);
        final semanticsWidget = tester.firstWidget<Semantics>(semanticsFinder);

        expect(textFinder, findsOneWidget);
        expect(semanticsWidget.excludeSemantics, true);
        expect(semanticsWidget.child.runtimeType, Text);
        expect(semanticsWidget.properties.label, null);
      });
    });

    group('When set accessibility with label', () {
      testWidgets('Then it should have semantics with label',
          (WidgetTester tester) async {
        final expectedLabel = "DummyLabel";
        await tester.pumpWidget(createWidget(
          accessibility: BeagleAccessibility(accessibilityLabel: expectedLabel),
        ));

        final semanticsType = find.byType(Semantics);
        final textFinder = find.text(text);
        final semanticsFinder =
            find.ancestor(of: textFinder, matching: semanticsType);
        final semanticsWidget = tester.firstWidget<Semantics>(semanticsFinder);

        expect(textFinder, findsOneWidget);
        expect(semanticsWidget.child.runtimeType, Text);
        expect(semanticsWidget.excludeSemantics, true);
        expect(semanticsWidget.properties.label, expectedLabel);
      });
    });

    group('When set accessibility with header', () {
      testWidgets('Then it should have semantics with header',
          (WidgetTester tester) async {
        final expectedHeader = true;

        await tester.pumpWidget(createWidget(
          accessibility: BeagleAccessibility(isHeader: expectedHeader),
        ));

        final semanticsType = find.byType(Semantics);
        final textFinder = find.text(text);
        final semanticsFinder =
            find.ancestor(of: textFinder, matching: semanticsType);
        final semanticsWidget = tester.firstWidget<Semantics>(semanticsFinder);

        expect(textFinder, findsOneWidget);
        expect(semanticsWidget.child.runtimeType, Text);
        expect(semanticsWidget.excludeSemantics, true);
        expect(semanticsWidget.properties.label, null);
        expect(semanticsWidget.properties.header, expectedHeader);
      });
    });

    group('When set accessibility with header and label', () {
      testWidgets('Then it should have semantics with header and label',
          (WidgetTester tester) async {
        final expectedHeader = true;
        final expectedLabel = "DummyLabel";

        await tester.pumpWidget(createWidget(
          accessibility: BeagleAccessibility(
              isHeader: expectedHeader, accessibilityLabel: expectedLabel),
        ));

        final semanticsType = find.byType(Semantics);
        final textFinder = find.text(text);
        final semanticsFinder =
            find.ancestor(of: textFinder, matching: semanticsType);
        final semanticsWidget = tester.firstWidget<Semantics>(semanticsFinder);

        expect(textFinder, findsOneWidget);
        expect(semanticsWidget.child.runtimeType, Text);
        expect(semanticsWidget.excludeSemantics, true);
        expect(semanticsWidget.properties.label, expectedLabel);
        expect(semanticsWidget.properties.header, expectedHeader);
      });
    });
  });
}
