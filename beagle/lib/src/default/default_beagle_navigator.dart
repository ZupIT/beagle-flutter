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

import 'dart:developer';

import 'package:beagle/beagle.dart';
// should I use Material here?
import 'package:flutter/material.dart';

typedef ScreenBuilder = Widget Function(BeagleWidget beagleWidget);

const INITIAL = "initial";

int counter = 0;

class DefaultBeagleNavigator extends StatefulWidget {
  DefaultBeagleNavigator({
    this.initialRoute,
    this.screenBuilder,
  });

  final BeagleRoute initialRoute;
  final ScreenBuilder screenBuilder;

  @override
  _DefaultBeagleNavigator createState() => _DefaultBeagleNavigator();
}

class _DefaultBeagleNavigator extends State<DefaultBeagleNavigator> implements BeagleNavigator {
  final _navigatorKey = GlobalKey<NavigatorState>();
  BeagleService _beagleService;

  Future<void> _startNavigator() async {
    await beagleServiceLocator.allReady();
    setState(() {
      _beagleService = beagleServiceLocator<BeagleService>();
    });
  }

  Route<dynamic> _buildRoute(BeagleWidget beagleWidget, [RouteSettings settings]) {
    return MaterialPageRoute(builder: (context) => widget.screenBuilder(beagleWidget), settings: settings);
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(NavigatorState state, String routeName) {
    final beagleWidget = BeagleWidget(parentNavigator: this, onCreateView: (view) {
      fetchContentAndUpdateView(
        view: view,
        context: state.context,
        completeNavigation: () => null,
        controller: _beagleService.defaultNavigationController,
        route: widget.initialRoute,
      );
    });

    return [_buildRoute(beagleWidget, RouteSettings(name: routeName, arguments: _beagleService.defaultNavigationController))];
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
          initialRoute: getRouteId(widget.initialRoute),
          onGenerateInitialRoutes: _onGenerateInitialRoutes,
        ),
      ),
    );
  }

  NavigationController getCurrentController(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments;
    return args is NavigationController ? args : _beagleService.defaultNavigationController;
  }

  NavigationController getControllerById(String id) {
    final entry = _beagleService.navigationControllers.entries.firstWhere((element) => element.key == id);
    return entry?.value == null ? _beagleService.defaultNavigationController : entry.value;
  }

  String getRouteId(BeagleRoute route) {
    return route is LocalView ? route.screen.getId() : (route as RemoteView).url;
  }

  Future<void> fetchContentAndUpdateView({
    RemoteView route,
    BuildContext context,
    BeagleView view,
    NavigationController controller,
    Function completeNavigation,
  }) async {
    try {
      controller.onLoading(view: view, context: context, completeNavigation: completeNavigation);
      final screen = await _beagleService.viewClient.fetch(route);
      controller.onSuccess(view: view, context: context, screen: screen);
      completeNavigation();
    } catch (error, stackTrace) {
      Future<void> retry() {
        return fetchContentAndUpdateView(
          route: route,
          context: context,
          view: view,
          controller: controller,
          completeNavigation: completeNavigation,
        );
      }
      controller.onError(
        view: view,
        context: context,
        error: error,
        stackTrace: stackTrace,
        retry: retry,
        completeNavigation: completeNavigation,
      );
    }
  }

  Future<void> newNavigationItem(BuildContext context, BeagleRoute route, String type, [String controllerId]) async {
    BeagleWidget beagleWidget;

    void onCreateView(BeagleView view) async {
      final stackController = type == "pushView" ? getCurrentController(context) : getControllerById(controllerId);
      final routeId = getRouteId(route);
      bool completed = false;

      void complete() {
        if (completed) return;
        final Route<dynamic> materialRoute = _buildRoute(
          beagleWidget,
          RouteSettings(name: routeId, arguments: stackController),
        );
        Navigator.push(context, materialRoute);
        completed = true;
      }

      if (route is LocalView) {
        stackController.onSuccess(
          view: view,
          context: context,
          screen: route.screen,
        );
        complete();
      } else {
        await fetchContentAndUpdateView(
            route: route,
            context: context,
            view: view,
            controller: stackController,
            completeNavigation: complete,
        );
      }
    }

    beagleWidget = BeagleWidget(parentNavigator: this, onCreateView: onCreateView);
  }

  @override
  void popStack(BuildContext context) {
    // TODO: implement popStack
  }

  @override
  void popToView(String routeIdentifier, BuildContext context) {
    // TODO: implement popToView
  }

  @override
  void popView(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Future<void> pushStack(BeagleRoute route, BuildContext context, [String controllerId]) async {
    // TODO: implement pushStack
  }

  @override
  Future<void> pushView(BeagleRoute route, BuildContext context) {
    return newNavigationItem(context, route, "pushView");
  }

  @override
  Future<void> resetApplication(BeagleRoute route, BuildContext context, [String controllerId]) async {
    // TODO: implement resetApplication
  }

  @override
  Future<void> resetStack(BeagleRoute route, BuildContext context, [String controllerId]) async {
    // TODO: implement resetStack
  }

}
