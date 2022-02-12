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

import 'dart:async';

import 'package:beagle/beagle.dart';
import 'package:beagle/src/navigation/stack_navigator_history.dart';
import 'package:flutter/material.dart';
import 'history_observer.dart';

/// This Navigator is internally used by the RootNavigator. It should never be used outside a RootNavigator.
// ignore: must_be_immutable
class StackNavigator extends StatelessWidget {
  StackNavigator({
    required this.initialRoute,
    required this.screenBuilder,
    required this.controller,
    required this.beagle,
    required this.rootNavigator,
    this.initialPages = const [],
    this.navigatorObservers = const [],
  });

  final BeagleRoute initialRoute;
  final ScreenBuilder screenBuilder;
  final NavigationController controller;
  final BeagleNavigator rootNavigator;
  final BeagleService beagle;
  NavigationContext? _poppedNavigationContext;
  final List<StackNavigatorHistory> _history = [];
  late final _historyObserver = HistoryObserver(_history, _onPopLast);

  // The following attributes are only used for testing purposes
  final _firstLoadCompleter = Completer();
  final List<Route<dynamic>> initialPages;
  final List<NavigatorObserver> navigatorObservers;
  final GlobalKey<NavigatorState> _thisNavigatorKey = GlobalKey();

  Route<dynamic> _buildRoute(BeagleWidget beagleWidget, String routeName) {
    return MaterialPageRoute(
      builder: (context) => screenBuilder(beagleWidget, context),
      settings: RouteSettings(name: routeName),
    );
  }

  void _addHistory(String routeName, BeagleView view) {
    void render([BeagleUIElement? tree]) {
      if (tree == null) {
        final currentTree = view.getTree();
        if (currentTree != null) view.getRenderer().doPartialRender(currentTree);
      } else {
        view.getRenderer().doFullRender(tree);
      }
    }

    _history.add(StackNavigatorHistory(routeName, view.getLocalContexts(), render));
  }

  /// Remakes the request to the current page and updates its content.
  /// It only works if the current page is a RemoteView, it does nothing for LocalViews.
  void reloadCurrentPage() async {
    final currentRoute = _history.last.routeName;
    if (!currentRoute.startsWith('/')) return;
    try {
      final tree = await beagle.viewClient.fetch(RemoteView(beagle.urlBuilder.build(currentRoute)));
      _history.last.render(tree);
    } catch(e) {
      beagle.logger.error('Could not reload the view. See the error below for more details.\n$e');
    }
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(NavigatorState state, String routeName) {
    // start testing purposes
    if (initialPages.isNotEmpty) {
      for (Route<dynamic> page in initialPages) {
        if (page.settings.name != null && page.settings.name!.isNotEmpty) {
          _history.add(StackNavigatorHistory(page.settings.name!, _TestPurposeLocalContextsManager(), ([_]) {}));
        }
      }
      _firstLoadCompleter.complete();
      return initialPages;
    }
    // end testing purposes

    final beagleViewWidget = beagle.createView(rootNavigator);
    if (initialRoute is LocalView) {
      setNavigationContext(initialRoute.navigationContext, beagleViewWidget.view.getLocalContexts(), false);
      controller.onSuccess(
        view: beagleViewWidget.view,
        context: state.context,
        screen: (initialRoute as LocalView).screen,
      );
      _firstLoadCompleter.complete();
    } else {
      () async {
        await _fetchContentAndUpdateView(
          view: beagleViewWidget.view,
          context: state.context,
          completeNavigation: () => null,
          route: initialRoute,
          navigationContext: initialRoute.navigationContext,
        );
        _firstLoadCompleter.complete();
      }();
    }

    _addHistory(routeName, beagleViewWidget.view);
    return [_buildRoute(beagleViewWidget.widget, routeName)];
  }

  String _getRouteId(BeagleRoute route) => route is LocalView ? route.screen.getId() : (route as RemoteView).url;

  Future<void> _fetchContentAndUpdateView({
    dynamic route,
    required BuildContext context,
    required BeagleView view,
    required Function completeNavigation,
    required NavigationContext? navigationContext,
  }) async {
    void setNavigationContextAndCompleteNavigation() {
      setNavigationContext(navigationContext, view.getLocalContexts(), false);
      completeNavigation();
    }

    try {
      controller.onLoading(view: view, context: context, completeNavigation: setNavigationContextAndCompleteNavigation);
      final screen = await beagle.viewClient.fetch(route);
      controller.onSuccess(view: view, context: context, screen: screen);
      setNavigationContextAndCompleteNavigation();
    } catch (error, stackTrace) {
      Future<void> retry() {
        return _fetchContentAndUpdateView(
          route: route,
          context: context,
          view: view,
          completeNavigation: completeNavigation,
          navigationContext: navigationContext,
        );
      }

      controller.onError(
        view: view,
        context: context,
        error: error,
        stackTrace: stackTrace,
        retry: retry,
        completeNavigation: setNavigationContextAndCompleteNavigation,
      );
    }
  }

  Future<void> untilFirstLoadCompletes() => _firstLoadCompleter.future;

  void setNavigationContext(NavigationContext? navigationContext, [LocalContextsManager? manager, bool render = true]) {
    if (navigationContext != null && (_history.isNotEmpty || manager != null)) {
      final localContextsManager = manager ?? _history.last.viewLocalContextsManager;
      localContextsManager.setContext('navigationContext', navigationContext.value, navigationContext.path);
      if (render) _history.last.render();
    }
  }

  void _onPopLast() {
    rootNavigator.popStack(_poppedNavigationContext);
  }

  void popToView(String routeIdentifier, [NavigationContext? navigationContext]) {
    _poppedNavigationContext = navigationContext;

    if (!_history.map((h) => h.routeName).contains(routeIdentifier)) {
      return beagle.logger
          .error("Cannot pop to \"$routeIdentifier\" because it doesn't exist in the navigation history.");
    }
    _thisNavigatorKey.currentState!.popUntil((route) => route.settings.name == routeIdentifier);
    while (_history.last.routeName != routeIdentifier) {
      _history.removeLast();
    }

    if (_history.isNotEmpty) {
      /* It has already popped at this time */
      setNavigationContext(navigationContext);
      _poppedNavigationContext = null;
    }
  }

  void popView([NavigationContext? navigationContext]) {
    _poppedNavigationContext = navigationContext;

    /* We only call the default pop from the navigator because the popView operation can also be triggered by the back
    button of the navigation bar and the systems's back function. The full popView behavior can be found in the
    _historyObserver. */
    _thisNavigatorKey.currentState!.pop();

    if (_history.isNotEmpty) {
      /* It has already popped at this time */
      setNavigationContext(navigationContext);
      _poppedNavigationContext = null;
    }
  }

  Future<void> pushView(BeagleRoute route, BuildContext context) async {
    final routeId = _getRouteId(route);
    final beagleViewWidget = beagle.createView(rootNavigator);
    bool completed = false;

    void complete() {
      if (completed) return;
      final Route<dynamic> materialRoute = _buildRoute(beagleViewWidget.widget, routeId);
      _thisNavigatorKey.currentState!.push(materialRoute);

      _addHistory(routeId, beagleViewWidget.view);

      completed = true;
    }

    if (route is LocalView) {
      setNavigationContext(route.navigationContext, beagleViewWidget.view.getLocalContexts(), false);
      controller.onSuccess(view: beagleViewWidget.view, context: context, screen: route.screen);
      complete();
    } else {
      await _fetchContentAndUpdateView(
        route: route,
        context: context,
        view: beagleViewWidget.view,
        completeNavigation: complete,
        navigationContext: route.navigationContext,
      );
    }
  }

  /// Returns a copy of the navigation history. Used for testing purposes.
  List<StackNavigatorHistory> getHistory() => [..._history];

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

class _TestPurposeLocalContextsManager implements LocalContextsManager {
  @override
  void clearAll() {}

  @override
  List<BeagleDataContext> getAllAsDataContext() {
    return [];
  }

  @override
  LocalContext? getContext(String id) {
    return null;
  }

  @override
  BeagleDataContext? getContextAsDataContext(String id) {}

  @override
  void removeContext(String id) {}

  @override
  void setContext(String id, value, [String? path]) {}
}
