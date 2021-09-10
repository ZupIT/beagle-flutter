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
import 'package:beagle_components/src/utils/build_context_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../beagle_image_test.dart';
import '../service_locator/service_locator.dart';
class ContextMock extends Mock implements BuildContext {}
class BeagleUiElementMock extends Mock implements BeagleUIElement {}

class SimpleFormStateMock extends BeagleSimpleFormState {
  @override
  void submit() {
    onSubmit();
  }
}
final mockElementId = 'submitKey';
final submitKey = Key(mockElementId);
var didPressSubmit = false;
void onSubmit() {
  didPressSubmit = true;
}
ContextMock _mockContext = ContextMock();
BeagleUIElement _mockElement = BeagleUiElementMock();
final elevatedButton = createElevatedButton();
final _labelSubmit = 'Submit';
BeagleSimpleForm simpleForm;
Widget createWidget({
  Function onValidationError,
  Function onSubmit,
}) {
  return MaterialApp(
    home: Scaffold(
      body: createBeagleSimpleForm(onValidationError: onValidationError, onSubmit: onSubmit),
    ),
  );
}

BeagleSimpleForm createBeagleSimpleForm({Function onValidationError, Function onSubmit}) {
  return BeagleSimpleForm(
      key: Key('scrollKey'),
      onValidationError: onValidationError,
      onSubmit: onSubmit,
      children: [BeagleTextInput(value: '', placeholder: 'Text',),
        // TextButton(
        //   onPressed: () {
        //     BeagleSubmitForm.submit(_mockContext, _mockElement);
        //   },
        //   child: Text(labelSubmit),
        // )
        elevatedButton
  ],
    );
}

ElevatedButton createElevatedButton() {
  return ElevatedButton(
          key: submitKey,
          onPressed: () =>
          {BeagleSubmitForm.submit(_mockContext, _mockElement)},
          child: Text(_labelSubmit),
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
      return children.last;
    });


    when(designSystemMock.navigationBarStyle(navigationBarStyleId))
        .thenReturn(navigationBarStyle);

    await testSetupServiceLocator(
      beagleYogaFactory: beagleYogaFactoryMock,
      designSystem: designSystemMock,
      logger: beagleLoggerMock,
    );

    when(_mockElement.getId()).thenReturn(mockElementId);
    when(_mockContext.widget).thenReturn(elevatedButton);

    final simpleForm = createBeagleSimpleForm(onSubmit: onSubmit);
    when(_mockContext.findAncestorWidgetOfExactType<BeagleSimpleForm>()).thenReturn(simpleForm);

    when(_mockContext.findAncestorStateOfType()).thenReturn(SimpleFormStateMock());
  });

  group('Given a BeagleSubmitForm', () {

    group('When I press the OK button', () {
      testWidgets('Then it should call onSubmit callback',
              (WidgetTester tester) async {

            await tester.pumpWidget(createWidget(onSubmit: onSubmit));
            await tester.pumpAndSettle();

            expect(didPressSubmit, false);
            await tester.tap(find.byType(ElevatedButton));
            await tester.pumpAndSettle();

            expect(didPressSubmit, true);
          });
    });

  });
}
