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

import 'dart:convert';

import 'package:beagle/beagle.dart';
import 'package:beagle/src/bridge_impl/beagle_js_engine.dart';
import 'package:beagle/src/bridge_impl/beagle_view_js.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test-utils/mocktail.dart';

class BeagleJSEngineMock extends Mock implements BeagleJSEngine {}

class BuildContextMock extends Mock implements BuildContext {}

class _BeagleNavigatorMock extends Mock implements BeagleNavigator {}

void main() {
  registerMocktailFallbacks();
  const createdViewId = 'viewId';
  final jsEngineMock = BeagleJSEngineMock();

  when(() => jsEngineMock.createBeagleView()).thenReturn(createdViewId);

  setUp(() {
    reset(jsEngineMock);
  });

  group('Given a BeagleViewJS', () {
    final beagleView = BeagleViewJS(jsEngineMock, _BeagleNavigatorMock());

    group('When destroy is called', () {
      test('Then should remove all view listeners for this view id at BeagleJSEngine', () {
        beagleView.destroy();

        verify(() => jsEngineMock.removeViewListeners(createdViewId));
      });
    });

    group('When getTree is called', () {
      test('Then should return the BeagleUIElement', () {
        final properties = {
          '_beagleComponent_': 'beagle:button',
          'text': 'Beagle Button',
        };

        when(
          () => jsEngineMock.evaluateJsCode("global.beagle.getViewById('$createdViewId').getTreeAsJson()"),
        ).thenReturn(
          JsEvalResult(json.encode(properties), null),
        );

        final expectedBeagleUIElement = BeagleUIElement(properties);
        final result = beagleView.getTree();

        expect(result?.properties, properties);
        expect(result?.getType(), expectedBeagleUIElement.getType());
        expect(result?.getAttributeValue('text'), expectedBeagleUIElement.getAttributeValue('text'));
      });

      test('Then it should return null if no tree exists', () {
        when(
          () => jsEngineMock.evaluateJsCode("global.beagle.getViewById('$createdViewId').getTreeAsJson()"),
        ).thenReturn(
          JsEvalResult("null", null),
        );
        final result = beagleView.getTree();
        expect(result, null);
      });

      test('Then it should return null if tree is invalid', () {
        when(
          () => jsEngineMock.evaluateJsCode("global.beagle.getViewById('$createdViewId').getTreeAsJson()"),
        ).thenReturn(
          JsEvalResult("{}", null),
        );
        final result = beagleView.getTree();
        expect(result, null);
      });
    });

    group('When onChange is called', () {
      test('Then should register the view update listener at BeagleJSEngine', () {
        void onUpdateListener(uiElement) {}
        when(() => beagleView.onChange(any())).thenReturn(() {});
        beagleView.onChange(onUpdateListener);

        verify(() => jsEngineMock.onViewUpdate(createdViewId, onUpdateListener));
      });
    });

    group('When onAction is called', () {
      test('Then should register the view action listener at BeagleJSEngine', () {
        void onActionListener({BeagleAction? action, BeagleView? view, BeagleUIElement? element}) {}
        when(() => beagleView.onAction(any())).thenReturn(() {});
        beagleView.onAction(onActionListener);

        verify(() => jsEngineMock.onAction(createdViewId, onActionListener));
      });
    });
  });
}
