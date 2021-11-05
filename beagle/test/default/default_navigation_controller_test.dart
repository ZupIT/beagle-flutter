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
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test-utils/mocktail.dart';

class _RendererMock extends Mock implements Renderer {}

class _BeagleViewMock extends Mock implements BeagleView {
  final _renderer = _RendererMock();

  @override
  Renderer getRenderer() {
    return _renderer;
  }
}

class _BuildContextMock extends Mock implements BuildContext {}

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

void main() {
  registerMocktailFallbacks();

  group("Given the DefaultNavigationController", () {
    final logger = _BeagleLoggerMock();
    final controller = DefaultNavigationController(logger);
    late BeagleView view;

    group("When onLoading is called", () {
      bool completed = false;

      setUpAll(() {
        view = _BeagleViewMock();
        controller.onLoading(view: view, context: _BuildContextMock(), completeNavigation: () => completed = true);
      });

      test('Then it should render the loading component', () {
        final verified = verify(() => view.getRenderer().doFullRender(captureAny()));
        verified.called(1);
        expect(verified.captured[0], isA<BeagleUIElement>());
        expect((verified.captured[0] as BeagleUIElement).getType(), "custom:loading");
      });

      test('And it should complete the navigation', () {
        expect(completed, true);
      });
    });

    group("When onError is called", () {
      setUpAll(() {
        view = _BeagleViewMock();
        controller.onError(
          view: view,
          context: _BuildContextMock(),
          completeNavigation: () {},
          error: Error(),
          stackTrace: StackTrace.empty,
          retry: () async {},
        );
      });

      test('Then it should render the error component', () {
        final verified = verify(() => view.getRenderer().doFullRender(captureAny()));
        verified.called(1);
        expect(verified.captured[0], isA<BeagleUIElement>());
        expect((verified.captured[0] as BeagleUIElement).getType(), "custom:error");
      });

      test('And it should log the error and stack trace', () {
        verify(() => logger.error(any())).called(2);
      });
    });

    group("When onSuccess is called", () {
      final screen = BeagleUIElement({"_beagleComponent_": "beagle:container"});

      setUpAll(() {
        view = _BeagleViewMock();
        controller.onSuccess(
          view: view,
          context: _BuildContextMock(),
          screen: screen,
        );
      });

      test('Then it should render the screen', () {
        final verified = verify(() => view.getRenderer().doFullRender(captureAny()));
        verified.called(1);
        expect(verified.captured[0], screen);
      });
    });
  });
}
