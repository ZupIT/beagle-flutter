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
import 'package:beagle/src/navigation/stack_navigator_history.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

const String CUSTOM_CONTROLLER_NAME = 'myCustomController';

abstract class _RootNavigatorMocks {
  Widget screenBuilder(BeagleWidget beagleWidget, BuildContext context);
}

class _LoggerMock extends Mock implements BeagleLogger {}

class _ViewClientMock extends Mock implements ViewClient {}

class _NavigationControllerMock extends Mock implements NavigationController {}

class _NavigatorObserverMock extends Mock implements NavigatorObserver {}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final ViewClient viewClient = _ViewClientMock();
  @override
  final NavigationController defaultNavigationController = _NavigationControllerMock();
  @override
  final Map<String, NavigationController> navigationControllers = {
    CUSTOM_CONTROLLER_NAME: _NavigationControllerMock(),
  };
  @override
  final logger = _LoggerMock();
  @override
  BeagleEnvironment get environment => BeagleEnvironment.debug;
  @override
  bool get enableHotReloading => false;
}

class _StackNavigatorStructureMock extends Mock implements StackNavigator {
  _StackNavigatorStructureMock() {
    when(() => pushView(any(), any())).thenAnswer((_) async {});
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

// ignore: must_be_immutable
class StackNavigatorMock extends StatelessWidget implements StackNavigator {
  final navigator = _StackNavigatorStructureMock();

  @override
  NavigationController get controller => navigator.controller;

  @override
  List<StackNavigatorHistory> getHistory() {
    return navigator.getHistory();
  }

  @override
  List<Route<dynamic>> get initialPages => navigator.initialPages;

  @override
  BeagleRoute get initialRoute => navigator.initialRoute;

  @override
  void popToView(String routeIdentifier, [NavigationContext? navigationContext]) {
    navigator.popToView(routeIdentifier, navigationContext);
  }

  @override
  void popView([NavigationContext? navigationContext]) {
    navigator.popView(navigationContext);
  }

  @override
  Future<void> pushView(BeagleRoute route, BuildContext context) {
    return navigator.pushView(route, context);
  }

  @override
  BeagleNavigator get rootNavigator => navigator.rootNavigator;

  @override
  ScreenBuilder get screenBuilder => navigator.screenBuilder;

  late BuildContext buildContext;

  @override
  Widget build(_) {
    // It's important to render a dummy navigator so we can simulate the dynamic of having multiple navigators
    return Navigator(
      onGenerateInitialRoutes: (NavigatorState state, String routeName) {
        return [
          MaterialPageRoute(
            builder: (BuildContext context) {
              buildContext = context;
              return Container();
            },
            settings: RouteSettings(name: 'test'),
          )
        ];
      },
    );
  }

  @override
  List<NavigatorObserver> get navigatorObservers => navigator.navigatorObservers;

  @override
  Future<void> untilFirstLoadCompletes() {
    return navigator.untilFirstLoadCompletes();
  }

  @override
  BeagleService get beagle => navigator.beagle;

  @override
  void setNavigationContext(NavigationContext? navigationContext,
      [LocalContextsManager? manager, bool render = true]) {}

  @override
  void reloadCurrentPage() {}
}

class RootNavigatorMocks extends Mock implements _RootNavigatorMocks {
  final beagle = _BeagleServiceMock();
  final rootNavigatorObserver = _NavigatorObserverMock();
  final topNavigatorObserver = _NavigatorObserverMock();
  final List<StackNavigatorMock> initialPages = [];
  late StackNavigatorMock lastStackNavigator;

  StackNavigatorMock _newStackNavigator() {
    lastStackNavigator = StackNavigatorMock();
    return lastStackNavigator;
  }

  RootNavigatorMocks([int numberOfInitialPages = 0]) {
    when(() => beagle.createStackNavigator(
          controller: any(named: 'controller'),
          initialRoute: any(named: 'initialRoute'),
          rootNavigator: any(named: 'rootNavigator'),
          screenBuilder: any(named: 'screenBuilder'),
        )).thenAnswer((_) => _newStackNavigator());

    for (int i = 0; i < numberOfInitialPages; i++) {
      initialPages.add(_newStackNavigator());
    }
  }
}
