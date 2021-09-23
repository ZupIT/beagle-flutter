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

typedef ScreenBuilder = Widget Function(BeagleWidget beagleWidget);

int _nextRootNavigatorId = 0;
int _nextStackId = 0;

Key _createNavigatorKey() {
  return Key("beagle-root-navigator-${++_nextRootNavigatorId}");
}

String _createRouteName() {
  return "${++_nextStackId}";
}

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

class _RootNavigator extends State<RootNavigator> implements BeagleNavigator {
  final _navigatorKey = _createNavigatorKey();
  final logger = beagleServiceLocator<BeagleLogger>();
  BeagleService _beagleService;
  final List<StackNavigator> _history = [];

  Future<void> _startNavigator() async {
    await beagleServiceLocator.allReady();
    setState(() {
      _beagleService = beagleServiceLocator<BeagleService>();
    });
  }

  StackNavigator _createStackNavigator(BeagleRoute route, NavigationController controller) {
    return StackNavigator(
      initialRoute: route,
      screenBuilder: widget.screenBuilder,
      rootNavigator: this,
      logger: logger,
      viewClient: _beagleService.viewClient,
      controller: controller,
    );
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(NavigatorState state, String routeName) {
    final controller = widget.initialController ?? _beagleService.defaultNavigationController;
    final stack = _createStackNavigator(widget.initialRoute, controller);
    _history.add(stack);
    return [
      MaterialPageRoute(
        builder: (_) => stack,
        settings: RouteSettings(name: _createRouteName()),
      ),
    ];
  }

  NavigationController getControllerById(String id) {
    final entry = _beagleService.navigationControllers.entries.firstWhere(
      (element) => element.key == id,
      orElse: () => null,
    );
    return entry?.value ?? _beagleService.defaultNavigationController;
  }

  @override
  void initState() {
    super.initState();
    _startNavigator();
  }

  @override
  Widget build(BuildContext context) {
    return _beagleService == null ? const SizedBox.shrink() :  WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          initialRoute: "$_nextStackId",
          onGenerateInitialRoutes: _onGenerateInitialRoutes,
        ),
      ),
    );
  }

  @override
  void popStack(_) {
    if (_history.length == 1) {
      return logger.error("Cannot pop stack because there's only a single stack in the Beagle Navigator.");
    }
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
    final newStack = _createStackNavigator(route, getControllerById(controllerId));
    final Route<dynamic> materialRoute = MaterialPageRoute(
      builder: (_) => newStack,
      settings: RouteSettings(name: _createRouteName()),
    );
    Navigator.push(context, materialRoute);
    _history.add(newStack);
  }

  @override
  Future<void> pushView(BeagleRoute route, BuildContext context) async {
    logger.info("ROOT NAVIGATOR: PUSH VIEW");
    _history.last.pushView(route, context);
  }

  @override
  Future<void> resetApplication(BeagleRoute route, BuildContext context, [String controllerId]) async {
    // TODO: implement resetApplication
  }

  @override
  Future<void> resetStack(BeagleRoute route, BuildContext context, [String controllerId]) async {
    // TODO: implement resetApplication
  }

}
