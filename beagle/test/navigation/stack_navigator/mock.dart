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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const SERVER_DELAY_MS = 50;

String createPageName(int index) {
  return 'INITIAL_$index';
}

class _NavigationControllerMock extends Mock implements NavigationController {}

class _ViewClientMock extends Mock implements ViewClient {}

class _RootNavigatorMock extends Mock implements BeagleNavigator {}

class _LoggerMock extends Mock implements BeagleLogger {}

class LocalContextsManagerMock extends Mock implements LocalContextsManager {}

class MockFunction extends Mock {
  void fn();
}

class _BeagleViewMock extends Mock implements BeagleView {
  final manager = LocalContextsManagerMock();

  @override
  LocalContextsManager getLocalContexts() {
    return manager;
  }
}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final logger = _LoggerMock();
  @override
  final viewClient = _ViewClientMock();
}

class _NavigatorObserverMock extends Mock implements NavigatorObserver {}

class BeagleWidgetMock extends Mock implements BeagleWidget {
  @override
  final BeagleView view = _BeagleViewMock();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

abstract class _NavigationMocks {
  Widget screenBuilder(BeagleWidget beagleWidget, BuildContext context);
}

int _nextId = 0;

class _Ref<T> {
  late T current;
}

class NavigationMocks extends Mock implements _NavigationMocks {
  final beagle = _BeagleServiceMock();
  final controller = _NavigationControllerMock();
  final rootNavigator = _RootNavigatorMock();
  final navigatorObserver = _NavigatorObserverMock();
  final screenKey = Key('beagle_widget_${_nextId++}');
  final List<PageRoute<dynamic>> initialPages = [];
  final WidgetTester tester;
  late BuildContext lastBuildContext;
  late BeagleWidget lastWidget;

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
    when(() => screenBuilder(any(), any())).thenAnswer((_) => Builder(builder: (BuildContext context) {
          lastBuildContext = context;
          return Container(key: screenKey);
        }));

    when(() => beagle.createView(any())).thenAnswer((_) {
      lastWidget = BeagleWidgetMock();
      return BeagleViewWidget(lastWidget.view, lastWidget);
    });
  }

  void mockSuccessfulRequest(RemoteView route, BeagleUIElement result) {
    when(() => beagle.viewClient.fetch(route)).thenAnswer((_) async {
      await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: SERVER_DELAY_MS)));
      return result;
    });
  }

  void mockUnsuccessfulRequest(RemoteView route, dynamic error) {
    when(() => beagle.viewClient.fetch(route)).thenAnswer((_) async {
      await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: SERVER_DELAY_MS)));
      throw error;
    });
  }

  void mockCompletionOnLoading() {
    when(() => controller.onLoading(
          context: any(named: 'context'),
          view: any(named: 'view'),
          completeNavigation: any(named: 'completeNavigation'),
        )).thenAnswer((realInvocation) => realInvocation.namedArguments[Symbol('completeNavigation')]());
  }

  void mockCompletionOnError() {
    when(() => controller.onError(
          context: any(named: 'context'),
          view: any(named: 'view'),
          completeNavigation: any(named: 'completeNavigation'),
          stackTrace: any(named: 'stackTrace'),
          retry: any(named: 'retry'),
          error: any<dynamic>(named: 'error'),
        )).thenAnswer((realInvocation) {
      realInvocation.namedArguments[Symbol('completeNavigation')]();
    });
  }

  _Ref<Future<void> Function()> mockRetryOnError() {
    final retry = _Ref<Future<void> Function()>();
    when(() => controller.onError(
          context: any(named: 'context'),
          view: any(named: 'view'),
          completeNavigation: any(named: 'completeNavigation'),
          stackTrace: any(named: 'stackTrace'),
          retry: any(named: 'retry'),
          error: any<dynamic>(named: 'error'),
        )).thenAnswer((realInvocation) {
      retry.current = realInvocation.namedArguments[Symbol('retry')];
    });
    return retry;
  }
}

StackNavigator createStackNavigator({
  required NavigationMocks mocks,
  BeagleRoute? initialRoute,
  int initialNumberOfPages = 0,
}) {
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
    beagle: mocks.beagle,
    initialRoute: initialRoute ?? LocalView(BeagleUIElement({'_beagleComponent_': 'beagle:container'}), null),
    screenBuilder: mocks.screenBuilder,
    controller: mocks.controller,
    rootNavigator: mocks.rootNavigator,
    initialPages: initialNumberOfPages == 0 ? [] : pages,
  );
}

void mockHistoryLocalContextsManager(StackNavigator navigator) {
  navigator.getHistory().forEach((history) {
    history.viewLocalContextsManager = LocalContextsManagerMock();
    history.render = MockFunction().fn;
  });
}
