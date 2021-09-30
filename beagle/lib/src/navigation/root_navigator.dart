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
  });

  final BeagleRoute initialRoute;
  final ScreenBuilder screenBuilder;
  final NavigationController initialController;

  @override
  _RootNavigator createState() => _RootNavigator();
}

class _RootNavigator extends State<RootNavigator> with AfterBeagleInitialization implements BeagleNavigator {
  final logger = beagleServiceLocator<BeagleLogger>();
  List<StackNavigator> _history = [];

  StackNavigator _createStackNavigator(BeagleRoute route, NavigationController controller) {
    return StackNavigator(
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

  List<Route<dynamic>> _onGenerateInitialRoutes(NavigatorState state, String routeName) {
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

  @override
  Widget buildAfterBeagleInitialization(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Navigator(
        initialRoute: "$_nextStackId",
        onGenerateInitialRoutes: _onGenerateInitialRoutes,
        ),
      ),
    );
  }

  @override
  void popStack(_) {
    Navigator.pop(context);
    _history.removeLast();
  }

  @override
  void popToView(String routeIdentifier, BuildContext context) {
    _history.last.popToView(routeIdentifier, context);
  }

  @override
  void popView(BuildContext context) {
    _history.last.popView(context);
  }

  @override
  Future<void> pushStack(BeagleRoute route, _, [String controllerId]) async {
    Navigator.push(context, _createNewRoute(route, _getControllerById(controllerId)));
  }

  @override
  Future<void> pushView(BeagleRoute route, BuildContext context) async {
    _history.last.pushView(route, context);
  }

  @override
  Future<void> resetApplication(BeagleRoute route, _, [String controllerId]) async {
    _history = [];
    Navigator.pushAndRemoveUntil(context, _createNewRoute(route, _getControllerById(controllerId)), (route) => false);
  }

  @override
  Future<void> resetStack(BeagleRoute route, _, [String controllerId]) async {
    _history.removeLast();
    Navigator.pushReplacement(context, _createNewRoute(route, _getControllerById(controllerId)));
  }
}
