// ignore_for_file: inference_failure_on_generic_invocation

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
import 'dart:typed_data';

import 'package:beagle/beagle.dart';
import 'package:beagle/src/bridge_impl/beagle_js_engine.dart';
import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJavascriptRuntimeWrapper extends Mock
    implements JavascriptRuntimeWrapper {}

class AnalyticsProviderMock extends Mock implements AnalyticsProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final jsRuntimeMock = MockJavascriptRuntimeWrapper();
  final analyticsProviderMock = AnalyticsProviderMock();

  setUp(() {
    beagleServiceLocator.reset();
    registerFallbackValue<JsEvalResult>(JsEvalResult('null', null));
    reset(jsRuntimeMock);
  });

  group('Given a not started BeagleJSEngine', () {
    group('When evaluateJavascriptCode is called', () {
      test('Then should throw BeagleJSEngineException', () {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        expect(() => beagleJSEngine.evaluateJavascriptCode('code'),
            throwsA(isInstanceOf<BeagleJSEngineException>()));

        verifyNever(() => jsRuntimeMock.evaluate('code'));
      });
    });

    group('When promiseToFuture is called', () {
      test('Then should throw BeagleJSEngineException', () {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        expect(
            () => beagleJSEngine
                .promiseToFuture(JsEvalResult('stringResult', 'rawResult')),
            throwsA(isInstanceOf<BeagleJSEngineException>()));

        verifyNever(() => jsRuntimeMock.evaluate(''));
      });
    });

    group('When start was NOT called yet', () {
      test('Then engine state should be BeagleJSEngineState.CREATED', () {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        expect(beagleJSEngine.state, BeagleJSEngineState.CREATED);
      });
    });

    group('When start is called', () {
      test('Then should change engine state to BeagleJSEngineState.STARTED',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        expect(beagleJSEngine.state, BeagleJSEngineState.STARTED);
      });

      test('Then should initialize the JavascriptRuntime', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        verifyInOrder([
          () => jsRuntimeMock.enableHandlePromises(),
          () => jsRuntimeMock.evaluate('var window = global = globalThis;'),
          () => jsRuntimeMock.evaluateAsync(any())
        ]);
      });

      test('Then should register for javascript httpClient.request messages',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        verify(() => jsRuntimeMock.onMessage(
            'httpClient.request', beagleJSEngine.notifyHttpListener));
      });

      test('Then should register for javascript action messages', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        const expectedChannelName = 'action';
        verify(() => jsRuntimeMock.onMessage(
            expectedChannelName, beagleJSEngine.notifyActionListener));
      });

      test('Then should register for javascript operation messages', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        const expectedChannelName = 'operation';
        verify(() => jsRuntimeMock.onMessage(
            expectedChannelName, beagleJSEngine.notifyOperationListener));
      });

      test('Then should register for javascript beagleView.update messages',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        const expectedChannelName = 'beagleView.update';
        verify(() => jsRuntimeMock.onMessage(
            expectedChannelName, beagleJSEngine.notifyViewUpdateListeners));
      });

      test(
          'Then should register for javascript analytics.createRecord messages',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        const expectedChannelName = 'analytics.createRecord';
        verify(() => jsRuntimeMock.onMessage(expectedChannelName, any()));
      });

      test('Then should register for javascript analytics.getConfig messages',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();

        const expectedChannelName = 'analytics.getConfig';
        verify(() => jsRuntimeMock.onMessage(expectedChannelName, any()));
      });
    });
  });

  group('Given a started BeagleJSEngine', () {
    group('When evaluateJavascriptCode is called', () {
      test('Then should NOT throw BeagleJSEngineException', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        beagleJSEngine.evaluateJavascriptCode('code');
      });

      test('Then should execute code in javascriptRuntime', () async {
        const jsCode = 'code';
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        beagleJSEngine.evaluateJavascriptCode(jsCode);

        verify(() => jsRuntimeMock.evaluate(jsCode)).called(1);
      });
    });

    group('When promiseToFuture is called', () {
      test('Then should call handlePromise in javascriptRuntime', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        final result = JsEvalResult('stringResult', 'rawResult');

        when(() => jsRuntimeMock.handlePromise(any()))
            .thenAnswer((invocation) async => JsEvalResult('null', null));

        await beagleJSEngine.start();
        await beagleJSEngine.promiseToFuture(result);

        verify(() => jsRuntimeMock.handlePromise(result)).called(1);
      });
    });

    group('When start is called more than one time', () {
      test('Then should initialize the JavascriptRuntime only one time',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        await beagleJSEngine.start();
        reset(jsRuntimeMock);
        await beagleJSEngine.start();

        verifyZeroInteractions(jsRuntimeMock);
      });
    });

    group('When an httpClient.request message is received', () {
      test('Then should call registered http listener', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        final httpMessage = {
          'id': '1',
          'url': 'https://usebeagle.io/',
          'method': 'get',
          'headers': <String, String>{},
          'body': ''
        };

        var httpListenerCalled = false;

        beagleJSEngine.onHttpRequest((requestId, request) {
          httpListenerCalled = true;
          expect(requestId, '1');
          expect(request.method, BeagleHttpMethod.get);
        });

        verify(() => jsRuntimeMock.onMessage('httpClient.request',
                captureAny<void Function(dynamic)>(that: isNotNull)))
            .captured
            .single(httpMessage);

        expect(httpListenerCalled, true);
      });
    });

    group('When an action message is received', () {
      test('Then should call all registered action listeners', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        const viewId = '1';
        final actionMessage = {
          '_beagleAction_': 'beagle:setContext',
          'contextId': 'address',
          'path': 'complement',
          'value': '@{onChange.value}'
        };

        var firstActionListenerCalled = false;
        var secondActionListenerCalled = false;
        var nonRegisteredActionListenerCalled = false;

        beagleJSEngine
          ..onAction(viewId, ({action, element, view}) {
            firstActionListenerCalled = true;
            expect(action?.getType(), 'beagle:setContext');
            expect(action?.getAttributeValue('contextId'), 'address');
            expect(action?.getAttributeValue('path'), 'complement');
            expect(action?.getAttributeValue('value'), '@{onChange.value}');
          })
          ..onAction(viewId, ({action, element, view}) {
            secondActionListenerCalled = true;
          })
          ..onAction('2', ({action, element, view}) {
            nonRegisteredActionListenerCalled = true;
          });

        verify(() => jsRuntimeMock.onMessage(
                'action', captureAny<void Function(dynamic)>(that: isNotNull)))
            .captured
            .single({'viewId': viewId, 'action': actionMessage});

        expect(firstActionListenerCalled, true);
        expect(secondActionListenerCalled, true);
        expect(nonRegisteredActionListenerCalled, false);
      });
    });

    group('When an operation message is received', () {
      test('Then should call registered operation listener', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        final operationMessage = {
          'operation': 'mockOperation',
          'params': ['paramA', 'paramB'],
        };

        var operationListener = false;

        beagleJSEngine.onOperation((operation, params) {
          operationListener = true;
          expect(operation, 'mockOperation');
          expect(params, ['paramA', 'paramB']);
        });

        verify(() => jsRuntimeMock.onMessage('operation',
                captureAny<void Function(dynamic)>(that: isNotNull)))
            .captured
            .single(operationMessage);

        expect(operationListener, true);
      });
    });

    group('When a beagleView.update message is received', () {
      test('Then should call all registered view update listeners', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        final viewUpdateMessage = {
          'id': '1',
          'tree': {
            '_beagleComponent_': 'beagle:container',
            'id': '_beagle_7',
          },
        };

        var firstViewUpdateListenerCalled = false;
        var secondViewUpdateListenerCalled = false;
        var nonRegisteredViewUpdateListenerCalled = false;

        beagleJSEngine
          ..onViewUpdate('1', (tree) {
            firstViewUpdateListenerCalled = true;
          })
          ..onViewUpdate('1', (tree) {
            secondViewUpdateListenerCalled = true;
          })
          ..onViewUpdate('2', (tree) {
            nonRegisteredViewUpdateListenerCalled = true;
          });

        verify(() => jsRuntimeMock.onMessage('beagleView.update',
                captureAny<void Function(dynamic)>(that: isNotNull)))
            .captured
            .single(viewUpdateMessage);

        expect(firstViewUpdateListenerCalled, true);
        expect(secondViewUpdateListenerCalled, true);
        expect(nonRegisteredViewUpdateListenerCalled, false);
      });
    });

    group('When a analytics.getConfig message is received', () {
      test('Then should call callJsFunction on beagle_js_engine', () async {
        const functionId = 'functionId';
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        //Expected values
        final expectedEnableScreenAnalytics = true;
        final expectedActions = {
          "beagle:setContext": ["contextId", "path", "value"]
        };

        //Configures mocks
        final analyticsConfig = AnalyticsConfig(
            enableScreenAnalytics: expectedEnableScreenAnalytics,
            actions: expectedActions);

        when(() => analyticsProviderMock.getConfig())
            .thenReturn(analyticsConfig);

        beagleServiceLocator
            .registerSingleton<AnalyticsProvider>(analyticsProviderMock);

        final message = {
          'functionId': functionId,
        };

        await verify(() =>
                jsRuntimeMock.onMessage('analytics.getConfig', captureAny()))
            .captured
            .single(message);

        verify(() => beagleJSEngine.callJsFunction(functionId, {
              "enableScreenAnalytics": expectedEnableScreenAnalytics,
              "actions": expectedActions
            }));
      });
    });

    group('When a analytics.createRecord message is received', () {
      test('Then should call createRecord on analyticsProvider', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();

        beagleServiceLocator
            .registerSingleton<AnalyticsProvider>(analyticsProviderMock);

        final message = {
          "type": "action",
          "platform": "Flutter",
          "event": "onPress",
          "component": {"type": "beagle:button", "id": "_beagle_37"},
          "beagleAction": "beagle:setContext",
          "attributes": {"contextId": "refreshContext", "value": true},
          "timestamp": 1629854771847,
          "screen": "/pull-to-refresh-simple"
        };

        await verify(() =>
                jsRuntimeMock.onMessage('analytics.createRecord', captureAny()))
            .captured
            .single(message);

        verify(() => analyticsProviderMock
            .createRecord(AnalyticsRecord().fromMap(message)));
      });
    });

    group('When createBeagleView is called', () {
      test('Then should return correct view id', () async {
        final result = JsEvalResult('10', 'rawResult');
        when(() => jsRuntimeMock.evaluate(any())).thenReturn(result);
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);

        when(() => jsRuntimeMock.evaluate('global.beagle.createBeagleView({})'))
            .thenReturn(result);

        await beagleJSEngine.start();

        expect(beagleJSEngine.createBeagleView(), result.stringResult);
      });
    });

    group('When removeViewListeners is called by passing a view id', () {
      test('Then should remove the listeners bound to view id', () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();
        const viewId = '1';

        final viewUpdateMessage = {
          'id': viewId,
          'tree': {
            '_beagleComponent_': 'beagle:container',
            'id': '_beagle_7',
          },
        };

        var firstViewUpdateListenerCalled = false;
        var secondViewUpdateListenerCalled = false;
        var viewActionListenerCalled = false;

        beagleJSEngine
          ..onViewUpdate(viewId, (tree) {
            firstViewUpdateListenerCalled = true;
          })
          ..onViewUpdate(viewId, (tree) {
            secondViewUpdateListenerCalled = true;
          })
          ..onAction(viewId, ({action, element, view}) {
            viewActionListenerCalled = true;
          })
          ..removeViewListeners(viewId);

        verify(() => jsRuntimeMock.onMessage('beagleView.update',
                captureAny<void Function(dynamic)>(that: isNotNull)))
            .captured
            .single(viewUpdateMessage);

        expect(firstViewUpdateListenerCalled, false);
        expect(secondViewUpdateListenerCalled, false);
        expect(viewActionListenerCalled, false);
      });
    });

    group('When callJsFunction is called', () {
      test(
          'Then should call JavascriptRuntime evaluate passing correct argument',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();
        const functionId = '1';
        const argumentsMap = {'arg': 'argument'};

        beagleJSEngine.callJsFunction(functionId, argumentsMap);

        final expectedJavaScriptCode =
            'global.beagle.call("$functionId", ${json.encode(argumentsMap)})';

        verify(() => jsRuntimeMock.evaluate(expectedJavaScriptCode)).called(1);
      });
    });

    group('When respondHttpRequest is called', () {
      test(
          'Then should call JavascriptRuntime evaluate passing correct argument',
          () async {
        final beagleJSEngine = BeagleJSEngine(jsRuntimeMock);
        await beagleJSEngine.start();
        const requestId = '1';
        final response = Response(200, '{}', {}, Uint8List(0));

        beagleJSEngine.respondHttpRequest(requestId, response);

        final expectedJavaScriptCode =
            'global.beagle.httpClient.respond($requestId, ${response.toJson()})';

        verify(() => jsRuntimeMock.evaluate(expectedJavaScriptCode)).called(1);
      });
    });
  });
}
