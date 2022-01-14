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
import 'package:beagle/src/bridge_impl/local_context_js.dart';
import 'package:beagle/src/bridge_impl/local_contexts_manager_js.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBeagleJSEngine extends Mock implements BeagleJSEngine {}

class User {
  User(this.name, this.age);

  String name;
  int age;
}

void main() {
  final beagleJSEngineMock = MockBeagleJSEngine();
  final defaultLocalContextId = 'myLocalContext';
  final viewId = 'testViewId';

  group('Given a LocalContextsManagerJS object on a view', () {
    group('When I call setContext method passing an encodable value', () {
      test('Then it should set value in the context specified by id', () {
        final value = {
          'abc': 1,
          'def': false,
          'ghi': 'test',
          'jkl': [1, '2', true]
        };
        final valueEncoded = json.encode(value);

        LocalContextsManagerJS(beagleJSEngineMock, viewId).setContext(defaultLocalContextId, value);
        expect(verify(() => beagleJSEngineMock.evaluateJsCode(captureAny<String>())).captured.single,
            'global.beagle.getViewById("$viewId").getLocalContexts().setContext("$defaultLocalContextId", $valueEncoded, "")');
      });
    });

    group('When I call setContext method passing a value to a specific path', () {
      test('Then it should set value in the context specified by id', () {
        final value = 'test';
        final valueEncoded = json.encode(value);
        final path = 'order.cart.name';

        LocalContextsManagerJS(beagleJSEngineMock, viewId).setContext(defaultLocalContextId, value, path);
        expect(verify(() => beagleJSEngineMock.evaluateJsCode(captureAny<String>())).captured.single,
            'global.beagle.getViewById("$viewId").getLocalContexts().setContext("$defaultLocalContextId", $valueEncoded, "$path")');
      });
    });

    group('When I call setContext method passing a uncodable value', () {
      test('Then it should throw LocalContextsManagerSerializationError exception', () {
        final user = User('John Doe', 26);
        expect(() => LocalContextsManagerJS(beagleJSEngineMock, viewId).setContext(defaultLocalContextId, user, 'user'),
            throwsA(isInstanceOf<LocalContextsManagerSerializationError>()));
        verifyNever(() => beagleJSEngineMock.evaluateJsCode(captureAny<String>()));
      });
    });

    group('When I call get method', () {
      test('Then it should get global context value', () {
        final value = {
          'account': {'number': 1, 'name': 'Fulano', 'email': 'fulano@beagle.com'},
          'order': {
            'cart': {
              'name': 'Flutter test',
              'items': [
                {'name': 'keyboard', 'price': 39.9},
                {'name': 'mouse', 'price': 28.45}
              ]
            }
          }
        };

        when(() => beagleJSEngineMock.evaluateJsCode(
                'global.beagle.getViewById("$viewId").getLocalContexts().getContextAsDataContext("$defaultLocalContextId")'))
            .thenReturn(JsEvalResult(value.toString(), value));
        when(() => beagleJSEngineMock.evaluateJsCode(
                'global.beagle.getViewById("$viewId").getLocalContexts().getContext("$defaultLocalContextId").get()'))
            .thenReturn(JsEvalResult(value.toString(), value));

        final result = LocalContextsManagerJS(beagleJSEngineMock, viewId).getContext(defaultLocalContextId);
        expect(result, isA<LocalContextJS>());
        // ignore: inference_failure_on_function_invocation
        expect(result!.get(), value);
      });
    });

    group('When I call clear method', () {
      test('Then it should clear all the local contexts for the specified view', () {
        clearInteractions(beagleJSEngineMock);
        LocalContextsManagerJS(beagleJSEngineMock, viewId).clearAll();
        expect(verify(() => beagleJSEngineMock.evaluateJsCode(captureAny<String>())).captured.single,
            'global.beagle.getViewById("$viewId").getLocalContexts().clearAll()');
      });
    });

    group('When I want to remove an specific context', () {
      test('Then it should remove the context of the specified id for the specified view', () {
        LocalContextsManagerJS(beagleJSEngineMock, viewId).removeContext(defaultLocalContextId);
        expect(verify(() => beagleJSEngineMock.evaluateJsCode(captureAny<String>())).captured.single,
            'global.beagle.getViewById("$viewId").getLocalContexts().removeContext("$defaultLocalContextId")');
      });
    });
  });
}
