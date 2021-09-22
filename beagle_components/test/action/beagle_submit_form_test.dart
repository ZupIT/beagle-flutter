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

import '../service_locator/service_locator.dart';

class BeagleUiElementMock extends Mock implements BeagleUIElement {}
class MockBeagleYogaFactory extends Mock implements BeagleYogaFactory {}
class MockDesignSystem extends Mock implements BeagleDesignSystem {}
class MockBuildContext extends Mock implements BuildContext {}
final infoMessage = <String>[];
final warningMessage = <String>[];
class MockBeagleLogger extends BeagleLogger {
  @override
  void error(String message) {
  }

  @override
  void errorWithException(String message, Exception exception) {
  }

  @override
  void info(String message) {
    infoMessage.add(message);
  }

  @override
  void warning(String message) {
    warningMessage.add(message);
  }

}
final mockElementId = 'submitKey';
final submitKey = Key(mockElementId);
var didCallOnSubmit = false;
void onSubmit() {
  didCallOnSubmit = true;
}
var didCallOnValidationError = false;
void onValidationError() {
  didCallOnValidationError = true;
}
BeagleUIElement _mockElement = BeagleUiElementMock();
final _beagleYogaFactoryMock = MockBeagleYogaFactory();
final _designSystemMock = MockDesignSystem();
final _beagleLoggerMock = MockBeagleLogger();
final BuildContext _mockContext = MockBuildContext();
final _navigationBarStyleId = 'navigationBarStyleId';
final _labelSubmit = 'Submit';
final navigationBarStyle =
BeagleNavigationBarStyle(backgroundColor: Colors.blue, centerTitle: true);

ElevatedButton createElevatedButton() {
  return ElevatedButton(
    key: submitKey,
    onPressed: () =>
    {BeagleSubmitForm.submit(_mockContext, _mockElement)},
    child: Text(_labelSubmit),
  );
}

final elevatedButton = createElevatedButton();
final simpleForm = createBeagleSimpleForm(onValidationError: onValidationError, onSubmit: onSubmit);

BeagleSimpleForm createBeagleSimpleForm({Function onValidationError, Function onSubmit}) {
  return BeagleSimpleForm(
    key: Key('scrollKey'),
    onValidationError: onValidationError,
    onSubmit: onSubmit,
    children: [BeagleTextInput(value: '', placeholder: 'Text',),
      elevatedButton
    ],
  );
}

Widget createWidget({
  Function onValidationError,
  Function onSubmit,
}) {
  return MaterialApp(
    home: Scaffold(
      body: simpleForm,
    ),
  );
}

class SimpleFormStateSpy extends BeagleSimpleFormState {
  SimpleFormStateSpy({this.withInputErrors,this.simpleForm});
  final bool withInputErrors;
  final BeagleSimpleForm simpleForm;
  @override
  bool hasInputErrors() {
    return withInputErrors;
  }

  @override
  BeagleSimpleForm get widget => simpleForm;
}


void main() {

  setUpAll(() async {

    when(_beagleYogaFactoryMock.createYogaLayout(
      style: anyNamed('style'),
      children: anyNamed('children'),
    )).thenAnswer((realInvocation) {
      final List<Widget> children = realInvocation.namedArguments.values.last;
      return children.last;
    });

    when(_designSystemMock.navigationBarStyle(_navigationBarStyleId))
        .thenReturn(navigationBarStyle);

    await testSetupServiceLocator(
      beagleYogaFactory: _beagleYogaFactoryMock,
      designSystem: _designSystemMock,
      logger: _beagleLoggerMock,
    );

    when(_mockElement.getId()).thenReturn(mockElementId);
    when(_mockContext.widget).thenReturn(elevatedButton);

    when(_mockContext.findAncestorWidgetOfExactType<BeagleSimpleForm>()).thenReturn(simpleForm);

    when(_mockContext.findAncestorStateOfType()).thenReturn(SimpleFormStateSpy(withInputErrors: false, simpleForm: simpleForm));
  });

  group('Given a BeagleSubmitForm', () {

    group('When I press the OK button without any validation error', () {
      testWidgets('Then it should call onSubmit callback',
              (WidgetTester tester) async {

            //Defines that validation error will not occurs
            when(_mockContext.visitChildElements((element) { })).thenAnswer((realInvocation) {});
            when(_mockContext.searchInputErrors()).thenReturn(false);

            final expectedInfoMessage = 'BeagleSimpleForm: submitting form';

            //reset values
            didCallOnSubmit = false;
            didCallOnValidationError = false;

            await tester.pumpWidget(createWidget(onSubmit: onSubmit, onValidationError: onValidationError));
            await tester.pumpAndSettle();

            expect(didCallOnSubmit, false);
            await tester.tap(find.byType(ElevatedButton));
            await tester.pumpAndSettle();

            expect(didCallOnSubmit, true);
            expect(didCallOnValidationError, false);
            expect(infoMessage.last, expectedInfoMessage);
          });
    });


    group('When I press the OK button, and it has a validation error handled by me', () {
      testWidgets('Then it should call onSubmit callback',
              (WidgetTester tester) async {

            //Defines that validation error will not occurs
            when(_mockContext.findAncestorStateOfType()).thenReturn(SimpleFormStateSpy(withInputErrors: true, simpleForm: simpleForm));
            final expectedWarningMessage = 'BeagleSimpleForm: has a validation error';

            didCallOnSubmit = false;
            didCallOnValidationError = false;
            await tester.pumpWidget(createWidget(onSubmit: onSubmit, onValidationError: onValidationError));
            await tester.pumpAndSettle();

            expect(didCallOnSubmit, false);
            await tester.tap(find.byType(ElevatedButton));
            await tester.pumpAndSettle();

            expect(didCallOnSubmit, false);
            expect(didCallOnValidationError, true);
            expect(warningMessage.last, expectedWarningMessage);
          });
    });

    group('When I press the OK button, and it has a validation error not handled by me', () {
      testWidgets('Then it should call onSubmit callback',
              (WidgetTester tester) async {

            //Defines that validation error will not occurs
            final simpleFormSpy = createBeagleSimpleForm(onSubmit: onSubmit, onValidationError: null);
            when(_mockContext.findAncestorStateOfType()).thenReturn(SimpleFormStateSpy(withInputErrors: true, simpleForm: simpleFormSpy));
            when(_mockContext.findAncestorWidgetOfExactType<BeagleSimpleForm>()).thenReturn(simpleFormSpy);
            final expectedFirstWarningMessage = 'BeagleSimpleForm: has a validation error';
            final expectedLastWarningMessage = 'BeagleSimpleForm: you did not provided a validation function onValidationError';

            didCallOnSubmit = false;
            didCallOnValidationError = false;
            await tester.pumpWidget(createWidget(onSubmit: onSubmit, onValidationError: null));
            await tester.pumpAndSettle();

            expect(didCallOnSubmit, false);
            await tester.tap(find.byType(ElevatedButton));
            await tester.pumpAndSettle();

            expect(didCallOnSubmit, false);
            expect(didCallOnValidationError, false);
            expect(warningMessage.first, expectedFirstWarningMessage);
            expect(warningMessage.last, expectedLastWarningMessage);
          });
    });
  });


}
