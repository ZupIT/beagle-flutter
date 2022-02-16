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
import 'package:beagle/src/navigation/watcher.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

typedef ScreenBuilder = Widget Function(BeagleWidget beagleWidget, BuildContext context);

int _nextStackId = 0;

String _createRouteName() {
  return "beagle-root-navigator-stack-${++_nextStackId}";
}

/// Main Beagle Navigator
class RootNavigator extends StatefulWidget {
  RootNavigator({
    required this.initialRoute,
    required this.screenBuilder,
    this.initialController,
    this.navigatorObservers = const [],
    this.initialPages = const [],
  });

  final BeagleRoute initialRoute;
  final ScreenBuilder screenBuilder;
  final NavigationController? initialController;
  final List<NavigatorObserver> navigatorObservers;

  final List<StackNavigator> initialPages;

  @override
  RootNavigatorState createState() => RootNavigatorState();
}

class RootNavigatorState extends State<RootNavigator> with BeagleConsumer implements BeagleNavigator {
  List<StackNavigator> _history = [];
  final GlobalKey<NavigatorState> _thisNavigatorKey = GlobalKey();
  Watcher? watcher;

  StackNavigator _createStackNavigator(BeagleRoute route, NavigationController controller) {
    return beagle.createStackNavigator(
      initialRoute: route,
      screenBuilder: widget.screenBuilder,
      rootNavigator: this,
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

    final controller = widget.initialController ?? beagle.defaultNavigationController;
    return [_createNewRoute(widget.initialRoute, controller)];
  }

  NavigationController _getControllerById(String? id) {
    final entry = beagle.navigationControllers.entries.firstWhereOrNull((element) => element.key == id);
    return entry?.value ?? beagle.defaultNavigationController;
  }

  /// Gets a copy of the navigation history. Useful for testing.
  List<StackNavigator> getHistory() {
    return [..._history];
  }

  /// Watches the backend for updates and hot-reloads the UI if the environment is BeagleEnvironment.debug
  void _startWatch() {
    if (beagle.environment != BeagleEnvironment.debug || beagle.watchInterval == 0) return;
    watcher = Watcher(
      intervalMS: beagle.watchInterval,
      httpClient: beagle.httpClient,
      baseUrl: beagle.baseUrl,
      onUpdate: () {
        if (_history.isNotEmpty) _history.last.reloadCurrentPage();
      },
    )..start();
  }

  @override
  void dispose() {
    watcher?.stop();
    super.dispose();
  }

  @override
  void initBeagleState() {
    _startWatch();
    super.initBeagleState();
  }

  @override
  Widget buildBeagleWidget(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        popView();
        return false;
      },
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
  void popStack([NavigationContext? navigationContext]) {
    if (_history.length == 1) {
      // pops the whole RootNavigator from its parent navigator
      return Navigator.of(context).pop();
    }
    _thisNavigatorKey.currentState!.pop();
    _history.removeLast();
    _history.last.setNavigationContext(navigationContext);
  }

  @override
  void popToView(String routeIdentifier, [NavigationContext? navigationContext]) {
    _history.last.popToView(routeIdentifier, navigationContext);
  }

  @override
  void popView([NavigationContext? navigationContext]) {
    _history.last.popView(navigationContext);
  }

  @override
  Future<void> pushStack(BeagleRoute route, [String? controllerId]) async {
    _thisNavigatorKey.currentState!.push(_createNewRoute(route, _getControllerById(controllerId)));
  }

  @override
  Future<void> pushView(BeagleRoute route, BuildContext context) async {
    _history.last.pushView(route, context);
  }

  @override
  Future<void> resetApplication(BeagleRoute route, [String? controllerId]) async {
    _history = [];
    _thisNavigatorKey.currentState!.pushAndRemoveUntil(
      _createNewRoute(route, _getControllerById(controllerId)),
      (route) => false,
    );
  }

  @override
  Future<void> resetStack(BeagleRoute route, [String? controllerId]) async {
    _history.removeLast();
    _thisNavigatorKey.currentState!.pushReplacement(_createNewRoute(route, _getControllerById(controllerId)));
  }
}
