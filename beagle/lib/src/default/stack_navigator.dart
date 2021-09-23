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

const INITIAL = "initial";

int _nextId = 0;

Key _createKey() {
  return Key("beagle-stack-navigator-${++_nextId}");
}

class StackNavigator extends StatelessWidget {
  StackNavigator({
    @required this.initialRoute,
    @required this.screenBuilder,
    @required this.controller,
    @required this.viewClient,
    @required this.rootNavigator,
    @required this.logger,
  });

  final BeagleRoute initialRoute;
  final ScreenBuilder screenBuilder;
  final NavigationController controller;
  final ViewClient viewClient;
  final BeagleNavigator rootNavigator;
  final BeagleLogger logger;
  final _navigatorKey = _createKey();
  final List<String> _history = [];

  Route<dynamic> _buildRoute(BeagleWidget beagleWidget, String routeName) {
    return MaterialPageRoute(
      builder: (context) => screenBuilder(beagleWidget),
      settings: RouteSettings(name: routeName),
    );
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(NavigatorState state, String routeName) {
    final beagleWidget = BeagleWidget(
      key: _createKey(),
      parentNavigator: rootNavigator,
      onCreateView: (view) {
        fetchContentAndUpdateView(
          view: view,
          context: state.context,
          completeNavigation: () => null,
          route: initialRoute,
        );
      },
    );

    _history.add(routeName);
    return [_buildRoute(beagleWidget, routeName)];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          initialRoute: getRouteId(initialRoute),
          onGenerateInitialRoutes: _onGenerateInitialRoutes,
        ),
      ),
    );
  }

  String getRouteId(BeagleRoute route) {
    return route is LocalView ? route.screen.getId() : (route as RemoteView).url;
  }

  Future<void> fetchContentAndUpdateView({
    RemoteView route,
    BuildContext context,
    BeagleView view,
    Function completeNavigation,
  }) async {
    try {
      controller.onLoading(view: view, context: context, completeNavigation: completeNavigation);
      final screen = await viewClient.fetch(route);
      controller.onSuccess(view: view, context: context, screen: screen);
      completeNavigation();
    } catch (error, stackTrace) {
      Future<void> retry() {
        return fetchContentAndUpdateView(
          route: route,
          context: context,
          view: view,
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

  void popToView(String routeIdentifier, BuildContext context) {
    if (!_history.contains(routeIdentifier)) {
      return logger.error("Cannot pop to \"$routeIdentifier\" because it doesn't exist in the navigation history.");
    }
    Navigator.popUntil(context, (route) => route.settings.name == routeIdentifier);
    while (_history.last != routeIdentifier) {
      _history.removeLast();
    }
  }

  void popView(BuildContext context) {
    if (_history.length == 1) {
      return rootNavigator.popStack(context);
    }
    Navigator.pop(context);
    _history.removeLast();
  }

  Future<void> pushView(BeagleRoute route, BuildContext context) async {
    final routeId = getRouteId(route);
    BeagleWidget beagleWidget;
    bool completed = false;

    void complete() {
      if (completed) return;
      final Route<dynamic> materialRoute = _buildRoute(beagleWidget, routeId);
      Navigator.push(context, materialRoute);
      _history.add(routeId);
      completed = true;
    }

    void onCreateView(BeagleView view) async {
      if (route is LocalView) {
        controller.onSuccess(
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
          completeNavigation: complete,
        );
      }
    }

    beagleWidget = BeagleWidget(key: _createKey(), parentNavigator: rootNavigator, onCreateView: onCreateView);
    /* FIXME: we should let the user decide when to complete the navigation. As of right now this is not possible
    because of the async nature of the BeagleWidget. Today the BeagleWidget is stateful and only initializes when it
    gets rendered. Because of this, we need to render it before controlling it =(. */
    complete();
  }
}
