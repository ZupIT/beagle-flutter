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

import 'dart:convert';

import 'package:beagle/src/bridge_impl/beagle_js_engine.dart';
import 'package:beagle/src/bridge_impl/beagle_service_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBeagleJSEngine extends Mock implements BeagleJSEngine {}

void main() {
  final beagleJSEngineMock = MockBeagleJSEngine();
  const baseUrl = 'https://usebeagle.io';
  final actions = {'beagle:alert': (context, {action, view, element}) {}};
  final operations = {'operation': ([paramA, paramB]) {}};

  setUp(() {
    reset(beagleJSEngineMock);
  });

  group('Given a BeagleServiceJS', () {
    final beagleService = BeagleServiceJS(
      beagleJSEngineMock,
      baseUrl: baseUrl,
      actions: actions,
      operations: operations,
    );

    group('When start is called', () {
      test('Then should start BeagleJSEngine', () async {
        when(() => beagleJSEngineMock.start()).thenAnswer((_) async => {});
        await beagleService.start();

        verify(beagleJSEngineMock.start).called(1);
      });

      test('Then should start beagle javascript core', () async {
        when(() => beagleJSEngineMock.start()).thenAnswer((_) async => {});
        await beagleService.start();

        final expectedParams = {
          'baseUrl': baseUrl,
          'actionKeys': actions.keys.toList(),
          'customOperations': operations.keys.toList(),
        };

        verify(() => beagleJSEngineMock.evaluateJavascriptCode(
            'global.beagle.start(${json.encode(expectedParams)})')).called(1);
      });

      test('Then should register http request listener', () async {
        when(() => beagleJSEngineMock.start()).thenAnswer((_) async => {});
        await beagleService.start();

        verify(() => beagleJSEngineMock.onHttpRequest(any())).called(1);
      });
    });
  });
}
