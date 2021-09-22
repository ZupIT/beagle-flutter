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
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'beagle_image_test.dart';
import 'service_locator/service_locator.dart';

Widget createWidget({
  Function onValidationError,
  Function onSubmit,
}) {
  return MaterialApp(
    home: Scaffold(
      body: BeagleSimpleForm(
        key: Key('scrollKey'),
        onValidationError: onValidationError,
        onSubmit: onSubmit,
        children: [BeagleTextInput(value: '', placeholder: 'Text input',)],
      ),
    ),
  );
}

void main() {
  final beagleYogaFactoryMock = MockBeagleYogaFactory();
  final designSystemMock = MockDesignSystem();
  final beagleLoggerMock = MockBeagleLogger();

  final navigationBarStyleId = 'navigationBarStyleId';
  final navigationBarStyle =
  BeagleNavigationBarStyle(backgroundColor: Colors.blue, centerTitle: true);

  setUpAll(() async {
    when(beagleYogaFactoryMock.createYogaLayout(
      style: anyNamed('style'),
      children: anyNamed('children'),
    )).thenAnswer((realInvocation) {
      final List<Widget> children = realInvocation.namedArguments.values.last;
      return children.first;
    });

    when(designSystemMock.navigationBarStyle(navigationBarStyleId))
        .thenReturn(navigationBarStyle);

    await testSetupServiceLocator(
      beagleYogaFactory: beagleYogaFactoryMock,
      designSystem: designSystemMock,
      logger: beagleLoggerMock,
    );
  });

  group('Given a BeagleSimpleForm', () {
    group('When the widget is created', () {
      testWidgets(
        'Then there should be a TextField as its content',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidget());

          final textFinder = find.byType(TextField);

          expect(textFinder, findsOneWidget);
          },
      );
    });
  });
}
