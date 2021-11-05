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
import 'package:flutter_js/js_eval_result.dart';
import 'package:mocktail/mocktail.dart';

class _BeagleNavigatorMock extends Mock implements BeagleNavigator {}

class _BuildContextMock extends Mock implements BuildContext {}

class _BeagleViewMock extends Mock implements BeagleView {}

class _StackTraceMock extends Mock implements StackTrace {}

class _RouteMock extends Mock implements Route<dynamic> {}

class _BeagleWidgetMock extends Mock implements BeagleWidget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class _LocalViewMock extends Mock implements LocalView {}

class _RemoteViewMock extends Mock implements RemoteView {}

class _BeagleUIElementMock extends Mock implements BeagleUIElement {}

class _NavigationControllerMock extends Mock implements NavigationController {}

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _ViewClientMock extends Mock implements ViewClient {}

class _JSEvalResultMock extends Mock implements JsEvalResult {}

class _BeagleRequestFake extends Fake implements BeagleRequest {}

void registerMocktailFallbacks() {
  registerFallbackValue<BeagleView>(_BeagleViewMock());
  registerFallbackValue<BeagleWidget>(_BeagleWidgetMock());
  registerFallbackValue<BuildContext>(_BuildContextMock());
  registerFallbackValue<BeagleNavigator>(_BeagleNavigatorMock());
  registerFallbackValue<StackTrace>(_StackTraceMock());
  registerFallbackValue<Route<dynamic>>(_RouteMock());
  registerFallbackValue<BeagleUIElement>(_BeagleUIElementMock());
  registerFallbackValue<LocalView>(_LocalViewMock());
  registerFallbackValue<RemoteView>(_RemoteViewMock());
  registerFallbackValue<NavigationController>(_NavigationControllerMock());
  registerFallbackValue<BeagleLogger>(_BeagleLoggerMock());
  registerFallbackValue<ViewClient>(_ViewClientMock());
  registerFallbackValue<JsEvalResult>(_JSEvalResultMock());
  registerFallbackValue(_BeagleRequestFake());

  // beagle action listeners
  registerFallbackValue<
    void Function({BeagleAction? action, BeagleUIElement? element, BeagleView? view})
  >(({BeagleAction? action, BeagleUIElement? element, BeagleView? view}) => {});
}
