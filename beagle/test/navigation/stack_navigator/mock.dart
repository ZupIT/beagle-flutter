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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';

class _NavigationControllerMock extends Mock implements NavigationController {}

class _ViewClientMock extends Mock implements ViewClient {}

class _RootNavigatorMock extends Mock implements BeagleNavigator {}

class _LoggerMock extends Mock implements BeagleLogger {}

class _BeagleViewMock extends Mock implements BeagleView {}

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _BeagleWidgetMock extends Mock implements UnsafeBeagleWidget {
  @override
  final BeagleView view = _BeagleViewMock();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class _BeagleWidgetMockState extends Mock implements BeagleWidgetState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

abstract class _NavigationMocks {
  Widget screenBuilder(UnsafeBeagleWidget beagleWidget, BuildContext context);
  UnsafeBeagleWidget beagleWidgetFactory(BeagleNavigator navigator);
}

class NavigationMocks extends Mock implements _NavigationMocks {
  final controller = _NavigationControllerMock();
  final viewClient = _ViewClientMock();
  final rootNavigator = _RootNavigatorMock();
  final logger = _LoggerMock();
  final navigationObserver = _MockNavigatorObserver();
  final screenKey = Key('beagle_widget');
  BuildContext lastBuildContext;
  UnsafeBeagleWidget lastWidget;

  NavigationMocks() {
    _mockFunctions();
  }

  void _mockFunctions() {
    when(screenBuilder(any, any)).thenAnswer((_) => Builder(builder: (BuildContext context) {
      lastBuildContext = context;
      return Container(key: screenKey);
    }));

    when(beagleWidgetFactory(any)).thenAnswer((_) {
      lastWidget = _BeagleWidgetMock();
      return lastWidget;
    });
  }
}

StackNavigator createStackNavigator(BeagleRoute initialRoute, NavigationMocks mocks, [bool shouldMockInitial = false]) {
  final mockedPage = MaterialPageRoute<dynamic>(
    builder: (context) {
      mocks.lastBuildContext = context;
      return Container();
    },
    settings: RouteSettings(name: 'INITIAL'),
  );
  return StackNavigator(
    initialRoute: initialRoute,
    screenBuilder: mocks.screenBuilder,
    controller: mocks.controller,
    viewClient: mocks.viewClient,
    rootNavigator: mocks.rootNavigator,
    logger: mocks.logger,
    beagleWidgetFactory: mocks.beagleWidgetFactory,
    firstPage: shouldMockInitial ? mockedPage : null,
  );
}
