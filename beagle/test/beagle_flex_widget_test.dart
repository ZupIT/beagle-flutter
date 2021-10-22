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
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const text = 'Undefined Component';

class MockBeagleYogaFactory extends Mock implements BeagleYogaFactory {}

Widget createWidget({String text = text, BeagleEnvironment environment = BeagleEnvironment.debug}) {
  return MaterialApp(
      home: BeagleFlexWidget(children: [
    BeagleUndefinedWidget(
      environment: environment,
    )
  ]));
}

void main() {
  final beagleYogaFactoryMock = MockBeagleYogaFactory();

  setUpAll(() async {
    when(() => beagleYogaFactoryMock.createYogaLayout(
          style: any(named: 'style'),
          children: any(named: 'children'),
        )).thenAnswer((realInvocation) {
      final List<Widget> children = realInvocation.namedArguments.values.last;
      return children.first;
    });

    await beagleServiceLocator.reset();

    beagleServiceLocator.registerSingleton<BeagleYogaFactory>(beagleYogaFactoryMock);
  });
  group('Given a widget wrapped by a BeagleFlexWidget', () {
    group('When set debug environment', () {
      testWidgets('Then it should have the correct text', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        final textFinder = find.text(text);

        expect(textFinder, findsOneWidget);
      });
    });

    group('When set production environment', () {
      testWidgets('Then it should not have text widget', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(environment: BeagleEnvironment.production));

        final textFinder = find.text(text);

        expect(textFinder, findsNothing);
      });
    });
  });
}
