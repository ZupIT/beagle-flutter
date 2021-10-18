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
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

const SERVER_DELAY_MS = 50;

String createPageName(int index) {
  return 'INITIAL_$index';
}

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

abstract class _NavigationMocks {
  Widget screenBuilder(UnsafeBeagleWidget beagleWidget, BuildContext context);
  UnsafeBeagleWidget beagleWidgetFactory(BeagleNavigator navigator);
}

int _nextId = 0;

class _Ref<T> {
  T current;
}

class NavigationMocks extends Mock implements _NavigationMocks {
  final controller = _NavigationControllerMock();
  final viewClient = _ViewClientMock();
  final rootNavigator = _RootNavigatorMock();
  final logger = _LoggerMock();
  final navigationObserver = _MockNavigatorObserver();
  final screenKey = Key('beagle_widget_${_nextId++}');
  final List<PageRoute<dynamic>> initialPages = [];
  final WidgetTester tester;
  BuildContext lastBuildContext;
  UnsafeBeagleWidget lastWidget;

  NavigationMocks(this.tester, [int numberOfInitialPages = 0]) {
    for (int i = 0; i < numberOfInitialPages; i++) {
      initialPages.add(MaterialPageRoute<dynamic>(
        builder: (context) {
          lastBuildContext = context;
          return Container(key: Key(createPageName(i)));
        },
        settings: RouteSettings(name: createPageName(i)),
      ));
    }
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

  void mockSuccessfulRequest(RemoteView route, BeagleUIElement result) {
    when(viewClient.fetch(route)).thenAnswer((_) async {
      await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: SERVER_DELAY_MS)));
      return result;
    });
  }

  void mockUnsuccessfulRequest(RemoteView route, dynamic error) {
    when(viewClient.fetch(route)).thenAnswer((_) async {
      await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: SERVER_DELAY_MS)));
      throw error;
    });
  }

  void mockCompletionOnLoading() {
    when(controller.onLoading(
      context: anyNamed('context'),
      view: anyNamed('view'),
      completeNavigation: anyNamed('completeNavigation'),
    )).thenAnswer((realInvocation) => realInvocation.namedArguments[Symbol('completeNavigation')]());
  }

  void mockCompletionOnError() {
    when(controller.onError(
      context: anyNamed('context'),
      view: anyNamed('view'),
      completeNavigation: anyNamed('completeNavigation'),
      stackTrace: anyNamed('stackTrace'),
      retry: anyNamed('retry'),
      error: anyNamed('error'),
    )).thenAnswer((realInvocation) {
      realInvocation.namedArguments[Symbol('completeNavigation')]();
    });
  }

  _Ref<Future<void> Function()> mockRetryOnError() {
    final retry = _Ref<Future<void> Function()>();
    when(controller.onError(
      context: anyNamed('context'),
      view: anyNamed('view'),
      completeNavigation: anyNamed('completeNavigation'),
      stackTrace: anyNamed('stackTrace'),
      retry: anyNamed('retry'),
      error: anyNamed('error'),
    )).thenAnswer((realInvocation) {
      retry.current = realInvocation.namedArguments[Symbol('retry')];
    });
    return retry;
  }
}

StackNavigator createStackNavigator({NavigationMocks mocks, BeagleRoute initialRoute, int initialNumberOfPages = 0}) {
  final List<Route<dynamic>> pages = [];
  for (int i = 0; i < initialNumberOfPages; i++) {
    pages.add(MaterialPageRoute<dynamic>(
      builder: (context) {
        mocks.lastBuildContext = context;
        return Container(key: Key(createPageName(i)));
      },
      settings: RouteSettings(name: createPageName(i)),
    ));
  }

  return StackNavigator(
    initialRoute: initialRoute ?? LocalView(BeagleUIElement({ '_beagleComponent_': 'beagle:container' })),
    screenBuilder: mocks.screenBuilder,
    controller: mocks.controller,
    viewClient: mocks.viewClient,
    rootNavigator: mocks.rootNavigator,
    logger: mocks.logger,
    beagleWidgetFactory: mocks.beagleWidgetFactory,
    initialPages: initialNumberOfPages == 0 ? null : pages,
  );
}
