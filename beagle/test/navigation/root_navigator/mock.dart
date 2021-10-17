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
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

const String CUSTOM_CONTROLLER_NAME = 'myCustomController';

abstract class _RootNavigatorMocks {
  StackNavigator stackNavigatorFactory({
    BeagleRoute initialRoute,
    ScreenBuilder screenBuilder,
    BeagleNavigator rootNavigator,
    BeagleLogger logger,
    ViewClient viewClient,
    NavigationController controller,
  });

  Widget screenBuilder(UnsafeBeagleWidget beagleWidget, BuildContext context);
}

class _LoggerMock extends Mock implements BeagleLogger {}

class _ViewClientMock extends Mock implements ViewClient {}

class _NavigationControllerMock extends Mock implements NavigationController {}

class NavigatorObserverMock extends Mock implements NavigatorObserver {}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final ViewClient viewClient = _ViewClientMock();
  @override
  final NavigationController defaultNavigationController = _NavigationControllerMock();
  @override
  final Map<String, NavigationController> navigationControllers = {
    CUSTOM_CONTROLLER_NAME: _NavigationControllerMock(),
  };
}

class _StackNavigatorStructureMock extends Mock implements StackNavigator {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class StackNavigatorMock extends StatelessWidget implements StackNavigator {
  final navigator = _StackNavigatorStructureMock();

  @override
  NavigationController get controller => navigator.controller;

  @override
  List<String> getHistory() {
    return navigator.getHistory();
  }

  @override
  List<Route> get initialPages => navigator.initialPages;

  @override
  BeagleRoute get initialRoute => navigator.initialRoute;

  @override
  BeagleLogger get logger => navigator.logger;

  @override
  void popToView(String routeIdentifier, BuildContext context) {
    navigator.popToView(routeIdentifier, context);
  }

  @override
  void popView(BuildContext context) {
    navigator.popView(context);
  }

  @override
  get progress => navigator.progress;

  @override
  Future<void> pushView(BeagleRoute route, BuildContext context) {
    return navigator.pushView(route, context);
  }

  @override
  BeagleNavigator get rootNavigator => navigator.rootNavigator;

  @override
  ScreenBuilder get screenBuilder => navigator.screenBuilder;

  @override
  ViewClient get viewClient => navigator.viewClient;

  BuildContext buildContext;

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return Container();
  }
}

class RootNavigatorMocks extends Mock implements _RootNavigatorMocks {
  final logger = _LoggerMock();
  final beagleService = _BeagleServiceMock();
  final rootNavigatorObserver = NavigatorObserverMock();
  final topNavigatorObserver = NavigatorObserverMock();
  final List<StackNavigatorMock> initialPages = [];
  StackNavigatorMock lastStackNavigator;

  StackNavigator _newStackNavigator() {
    lastStackNavigator = StackNavigatorMock();
    return lastStackNavigator;
  }

  RootNavigatorMocks([int numberOfInitialPages = 0]) {
    when(stackNavigatorFactory(
      controller: anyNamed('controller'),
      initialRoute: anyNamed('initialRoute'),
      logger: anyNamed('logger'),
      rootNavigator: anyNamed('rootNavigator'),
      screenBuilder: anyNamed('screenBuilder'),
      viewClient: anyNamed('viewClient'),
    )).thenAnswer((_) => _newStackNavigator());

    for (int i = 0; i < numberOfInitialPages; i++) {
      initialPages.add(_newStackNavigator());
    }

    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<BeagleService>(beagleService);
    GetIt.instance.registerSingleton<BeagleLogger>(logger);
  }
}
