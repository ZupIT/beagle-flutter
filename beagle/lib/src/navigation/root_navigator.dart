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
import 'package:beagle/src/after_beagle_initialization.dart';
import 'package:flutter/material.dart';

typedef ScreenBuilder = Widget Function(UnsafeBeagleWidget beagleWidget, BuildContext context);

typedef _StackNavigatorFactory = StackNavigator Function({
  BeagleRoute initialRoute,
  ScreenBuilder screenBuilder,
  BeagleNavigator rootNavigator,
  BeagleLogger logger,
  ViewClient viewClient,
  NavigationController controller,
});

StackNavigator _defaultStackNavigatorFactory({
  BeagleRoute initialRoute,
  ScreenBuilder screenBuilder,
  BeagleNavigator rootNavigator,
  BeagleLogger logger,
  ViewClient viewClient,
  NavigationController controller,
}) {
  return StackNavigator(
    initialRoute: initialRoute,
    screenBuilder: screenBuilder,
    rootNavigator: rootNavigator,
    viewClient: viewClient,
    logger: logger,
    controller: controller,
  );
}

int _nextStackId = 0;

String _createRouteName() {
  return "beagle-root-navigator-stack-${++_nextStackId}";
}

/// Main Beagle Navigator
class RootNavigator extends StatefulWidget {
  RootNavigator({
    @required this.initialRoute,
    @required this.screenBuilder,
    this.initialController,
    this.navigatorObservers = const [],
    _StackNavigatorFactory stackNavigatorFactory,
    this.initialPages = const [],
  }) : this.stackNavigatorFactory = stackNavigatorFactory ?? _defaultStackNavigatorFactory;

  final BeagleRoute initialRoute;
  final ScreenBuilder screenBuilder;
  final NavigationController initialController;
  final List<NavigatorObserver> navigatorObservers;

  /// the following properties are for testing purposes
  final _StackNavigatorFactory stackNavigatorFactory;
  final List<StackNavigator> initialPages;

  @override
  RootNavigatorState createState() => RootNavigatorState();
}

class RootNavigatorState extends State<RootNavigator> with AfterBeagleInitialization implements BeagleNavigator {
  final logger = beagleServiceLocator<BeagleLogger>();
  List<StackNavigator> _history = [];
  final GlobalKey<NavigatorState> _thisNavigatorKey = GlobalKey();

  StackNavigator _createStackNavigator(BeagleRoute route, NavigationController controller) {
    return widget.stackNavigatorFactory(
      initialRoute: route,
      screenBuilder: widget.screenBuilder,
      rootNavigator: this,
      logger: logger,
      viewClient: beagleService.viewClient,
      controller: controller,
    );
  }

  Route<dynamic> _createNewRoute(BeagleRoute route, NavigationController controller) {
    final newStack = _createStackNavigator(route, controller);
    _history.add(newStack);
    return MaterialPageRoute(
      builder: (_) => newStack,
      settings: RouteSettings(name: _createRouteName()),
    );
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(_, __) {
    // for testing purposes
    if (widget.initialPages.isNotEmpty) {
      final List<Route<dynamic>> pages = [];
      for (StackNavigator navigator in widget.initialPages) {
        pages.add(MaterialPageRoute(
          builder: (_) => navigator,
          settings: RouteSettings(name: _createRouteName()),
        ));
        _history.add(navigator);
      }
      return pages;
    }

    final controller = widget.initialController ?? beagleService.defaultNavigationController;
    return [_createNewRoute(widget.initialRoute, controller)];
  }

  NavigationController _getControllerById(String id) {
    final entry = beagleService.navigationControllers.entries.firstWhere(
      (element) => element.key == id,
      orElse: () => null,
    );
    return entry?.value ?? beagleService.defaultNavigationController;
  }

  /// Gets a copy of the navigation history. Useful for testing.
  List<StackNavigator> getHistory() {
    return [..._history];
  }

  @override
  Widget buildAfterBeagleInitialization(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Navigator(
          key: _thisNavigatorKey,
          initialRoute: "$_nextStackId",
          onGenerateInitialRoutes: _onGenerateInitialRoutes,
          observers: widget.navigatorObservers,
        ),
      ),
    );
  }

  @override
  void popStack() {
    if (_history.length == 1) {
      // pops the whole RootNavigator from its parent navigator
      return Navigator.of(context).pop();
    }
    _thisNavigatorKey.currentState.pop();
    _history.removeLast();
  }

  @override
  void popToView(String routeIdentifier) {
    _history.last.popToView(routeIdentifier);
  }

  @override
  void popView() {
    _history.last.popView();
  }

  @override
  Future<void> pushStack(BeagleRoute route, [String controllerId]) async {
    _thisNavigatorKey.currentState.push(_createNewRoute(route, _getControllerById(controllerId)));
  }

  @override
  Future<void> pushView(BeagleRoute route, BuildContext context) async {
    _history.last.pushView(route, context);
  }

  @override
  Future<void> resetApplication(BeagleRoute route, [String controllerId]) async {
    _history = [];
    _thisNavigatorKey.currentState.pushAndRemoveUntil(
      _createNewRoute(route, _getControllerById(controllerId)),
      (route) => false,
    );
  }

  @override
  Future<void> resetStack(BeagleRoute route, [String controllerId]) async {
    _history.removeLast();
    _thisNavigatorKey.currentState.pushReplacement(_createNewRoute(route, _getControllerById(controllerId)));
  }
}
