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
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test-utils/provider_mock.dart';

class _BeagleServiceMock extends Mock implements BeagleService {}

class _BeagleViewMock extends Mock implements BeagleView {}

class _BuildContextMock extends Mock implements BuildContext {}

class _BeagleWidgetMock extends Mock implements BeagleWidget {
  @override
  final view = _BeagleViewMock();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

void main() {
  group('Given a build context with a BeagleWidget', () {
    group('When findAncestorBeagleView is called', () {
      test('Then the BeagleView should be returned', () {
        final context = _BuildContextMock();
        final beagleWidget = _BeagleWidgetMock();
        when(context.findAncestorWidgetOfExactType).thenReturn(beagleWidget);
        expect(findAncestorBeagleView(context), beagleWidget.view);
      });
    });
  });

  group('Given a build context without a BeagleWidget', () {
    group('When findAncestorBeagleView is called', () {
      test('Then an exception should be thrown', () {
        final context = _BuildContextMock();
        dynamic error;
        when(context.findAncestorWidgetOfExactType).thenReturn(null);
        try {
          findAncestorBeagleView(context);
        } catch (err) {
          error = err;
        }
        expect(error == null, false);
      });
    });
  });

  group('Given a build context with a BeagleProvider', () {
    group('When findBeagleService is called', () {
      test('Then the beagle service should be returned', () {
        final context = _BuildContextMock();
        final beagle = _BeagleServiceMock();
        final providerState = BeagleProviderStateMock(beagle);
        when(context.findAncestorStateOfType).thenReturn(providerState);
        expect(findBeagleService(context), beagle);
      });
    });
  });

  group('Given a build context without a BeagleProvider', () {
    group('When findBeagleService is called', () {
      test('Then an exception should be thrown', () {
        final context = _BuildContextMock();
        dynamic error;
        when(context.findAncestorStateOfType).thenReturn(null);
        try {
          findBeagleService(context);
        } catch (err) {
          error = err;
        }
        expect(error == null, false);
      });
    });
  });
}
