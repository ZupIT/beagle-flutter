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
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final logger = _BeagleLoggerMock();
}

class _SimpleFormStateMock extends Mock implements BeagleSimpleFormState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class _BuildContextMock extends Mock implements BuildContext {}

class _BeagleUIElementMock extends Mock implements BeagleUIElement {
  _BeagleUIElementMock(this._id);

  final String _id;

  @override
  String getId() {
    return _id;
  }
}

class _ProviderStateMock extends Mock implements BeagleProviderState {
  _ProviderStateMock(this.beagle);

  @override
  final BeagleService beagle;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

void main() {
  late BeagleService beagle;
  final simpleFormState = _SimpleFormStateMock();
  final correctElementId = 'element';

  void setup(String elementId, bool hasSimpleForm) {
    beagle = _BeagleServiceMock();
    final elementContext = _BuildContextMock();
    final beagleWidgetContext = _BuildContextMock();
    final keyToContext = {correctElementId: elementContext};
    when(() => beagleWidgetContext.findAncestorStateOfType()).thenReturn(_ProviderStateMock(beagle));
    when(() => elementContext.findAncestorStateOfType()).thenReturn(hasSimpleForm ? simpleFormState : null);
    BeagleSubmitForm.submit(beagleWidgetContext, _BeagleUIElementMock(elementId), (String key) => keyToContext[key]);
  }

  group('Given the action to submit a form', () {
    group("When the correct element id is passed", () {
      group("And there's a simple form above", () {
        test("Then it should submit the form", () {
          setup(correctElementId, true);
          verify(() => simpleFormState.submit()).called(1);
        });
      });

      group("And there's no simple form above", () {
        test("Then it should not submit and should log an error", () {
          setup(correctElementId, false);
          verifyNever(() => simpleFormState.submit());
          verify(() => beagle.logger.error(any<String>())).called(1);
        });
      });
    });

    group("When the element id passed doesn't exist", () {
      test("Then it should not submit and should log an error", () {
        setup('wrong', false);
        verifyNever(() => simpleFormState.submit());
        verify(() => beagle.logger.error(any<String>())).called(1);
      });
    });
  });
}
