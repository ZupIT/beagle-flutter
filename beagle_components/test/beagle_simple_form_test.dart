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
import 'package:mocktail/mocktail.dart';

import 'test-utils/provider_mock.dart';

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _BeagleYogaFactoryMock extends Mock implements BeagleYogaFactory {}

class _DesignSystemMock extends Mock implements BeagleDesignSystem {}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final logger = _BeagleLoggerMock();
  @override
  final yoga = _BeagleYogaFactoryMock();
  @override
  final designSystem = _DesignSystemMock();
}

Widget createWidget({
  required BeagleService beagle,
  Function? onValidationError,
  Function? onSubmit,
}) {
  return MaterialApp(
    home: BeagleProviderMock(
      beagle: beagle,
      child: Scaffold(
        body: BeagleSimpleForm(
          key: Key('scrollKey'),
          onValidationError: onValidationError,
          onSubmit: onSubmit,
          children: [BeagleTextInput(placeholder: 'Text input')],
        ),
      ),
    ),
  );
}

void main() {
  final beagle = _BeagleServiceMock();

  final navigationBarStyleId = 'navigationBarStyleId';
  final navigationBarStyle =
      BeagleNavigationBarStyle(backgroundColor: Colors.blue, centerTitle: true);

  setUpAll(() {
    when(() => beagle.yoga.createYogaLayout(
          style: any(named: 'style'),
          children: any(named: 'children'),
        )).thenAnswer((realInvocation) {
      final List<Widget> children = realInvocation.namedArguments.values.last;
      return children.first;
    });

    when(() => beagle.designSystem.navigationBarStyle(navigationBarStyleId))
        .thenReturn(navigationBarStyle);
  });

  group('Given a BeagleSimpleForm', () {
    group('When the widget is created', () {
      testWidgets(
        'Then there should be a TextField as its content',
        (WidgetTester tester) async {
          await tester.pumpWidget(createWidget(beagle: beagle));
          expect(find.byType(TextField), findsOneWidget);
        },
      );
    });
  });

  // TODO: test the form submission, including validation, with the real SimpleFormState.
}
