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

import 'dart:async';

import 'package:beagle/beagle.dart';
import 'package:flutter/material.dart';

import 'history_observer.dart';

typedef _BeagleWidgetFactory = UnsafeBeagleWidget Function(BeagleNavigator rootNavigator);

UnsafeBeagleWidget _defaultBeagleWidgetFactory(BeagleNavigator navigator) {
  return UnsafeBeagleWidget(navigator);
}

/// This Navigator is internally used by the RootNavigator. It should never be used outside a RootNavigator.
class StackNavigator extends StatelessWidget {
  StackNavigator({
    required this.initialRoute,
    required this.screenBuilder,
    required this.controller,
    required this.viewClient,
    required this.rootNavigator,
    required this.logger,
    _BeagleWidgetFactory? beagleWidgetFactory,
    this.initialPages = const [],
    this.navigatorObservers = const [],
  }) : _beagleWidgetFactory = beagleWidgetFactory ?? _defaultBeagleWidgetFactory;

  final BeagleRoute initialRoute;
  final ScreenBuilder screenBuilder;
  final NavigationController controller;
  final ViewClient viewClient;
  final BeagleNavigator rootNavigator;
  final BeagleLogger logger;
  final List<String> _history = [];
  late final _historyObserver = HistoryObserver(_history, rootNavigator.popStack);

  // The following attributes are only used for testing purposes
  final _firstLoadCompleter = Completer();
  final _BeagleWidgetFactory _beagleWidgetFactory;
  final List<Route<dynamic>> initialPages;
  final List<NavigatorObserver> navigatorObservers;
  final GlobalKey<NavigatorState> _thisNavigatorKey = GlobalKey();

  Route<dynamic> _buildRoute(UnsafeBeagleWidget beagleWidget, String routeName) {
    return MaterialPageRoute(
      builder: (context) => screenBuilder(beagleWidget, context),
      settings: RouteSettings(name: routeName),
    );
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(NavigatorState state, String routeName) {
    // for testing purposes
    if (initialPages.isNotEmpty) {
      for (Route<dynamic> page in initialPages) {
        if (page.settings.name != null && page.settings.name!.isNotEmpty) _history.add(page.settings.name!);
      }
      _firstLoadCompleter.complete();
      return initialPages;
    }

    final beagleWidget = _beagleWidgetFactory(rootNavigator);

    if (initialRoute is LocalView) {
      controller.onSuccess(view: beagleWidget.view, context: state.context, screen: (initialRoute as LocalView).screen);
      _firstLoadCompleter.complete();
    } else {
      () async {
        await _fetchContentAndUpdateView(
          view: beagleWidget.view,
          context: state.context,
          completeNavigation: () => null,
          route: initialRoute,
        );
        _firstLoadCompleter.complete();
      }();
    }

    _history.add(routeName);
    return [_buildRoute(beagleWidget, routeName)];
  }

  String _getRouteId(BeagleRoute route) {
    return route is LocalView ? route.screen.getId() : (route as RemoteView).url;
  }

  Future<void> _fetchContentAndUpdateView({
    dynamic route,
    required BuildContext context,
    required BeagleView view,
    required Function completeNavigation,
  }) async {
    try {
      controller.onLoading(view: view, context: context, completeNavigation: completeNavigation);
      final screen = await viewClient.fetch(route);
      controller.onSuccess(view: view, context: context, screen: screen);
      completeNavigation();
    } catch (error, stackTrace) {
      Future<void> retry() {
        return _fetchContentAndUpdateView(
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

  Future<void> untilFirstLoadCompletes() {
    return _firstLoadCompleter.future;
  }

  void popToView(String routeIdentifier) {
    if (!_history.contains(routeIdentifier)) {
      return logger.error("Cannot pop to \"$routeIdentifier\" because it doesn't exist in the navigation history.");
    }
    _thisNavigatorKey.currentState!.popUntil((route) => route.settings.name == routeIdentifier);
    while (_history.last != routeIdentifier) {
      _history.removeLast();
    }
  }

  void popView() {
    /* We only call the default pop from the navigator because the popView operation can also be triggered by the back
    button of the navigation bar and the systems's back function. The full popView behavior can be found in the
    _historyObserver. */
    _thisNavigatorKey.currentState!.pop();
  }

  Future<void> pushView(BeagleRoute route, BuildContext context) async {
    final routeId = _getRouteId(route);
    final beagleWidget = _beagleWidgetFactory(rootNavigator);
    bool completed = false;

    void complete() {
      if (completed) return;
      final Route<dynamic> materialRoute = _buildRoute(beagleWidget, routeId);
      _thisNavigatorKey.currentState!.push(materialRoute);
      _history.add(routeId);
      completed = true;
    }

    if (route is LocalView) {
      controller.onSuccess(view: beagleWidget.view, context: context, screen: route.screen);
      complete();
    } else {
      await _fetchContentAndUpdateView(
        route: route,
        context: context,
        view: beagleWidget.view,
        completeNavigation: complete,
      );
    }
  }

  /// Returns a copy of the navigation history. Used for testing purposes.
  List<String> getHistory() {
    return [..._history];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        initialRoute: _getRouteId(initialRoute),
        onGenerateInitialRoutes: _onGenerateInitialRoutes,
        observers: [_historyObserver, ...navigatorObservers],
        key: _thisNavigatorKey,
      ),
    );
  }
}
