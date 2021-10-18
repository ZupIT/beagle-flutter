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

import 'dart:convert';
import 'package:beagle/beagle.dart';
import 'package:flutter/material.dart';
import 'beagle_js_engine.dart';

class BeagleNavigatorJS implements BeagleNavigator {
  BeagleNavigatorJS(this._beagleJSEngine, this._viewId);

  final String _viewId;
  final BeagleJSEngine _beagleJSEngine;

  static String routeToJson(dynamic route) {
    var map = <String, dynamic>{};

    if (route is LocalView) {
      map = {'screen': route.screen.properties};
    }

    if (route is RemoteView) {
      map = {
        'url': route.url,
        'fallback': route.fallback?.properties,
        'shouldPrefetch': route.shouldPrefetch
      };
    }

    return jsonEncode(map);
  }

  static dynamic mapToRoute(Map<String, dynamic> routeMap) {
    if (routeMap.containsKey('url')) {
      final fallback = routeMap.containsKey('fallback')
          ? BeagleUIElement(routeMap['fallback'])
          : null;
      final shouldPrefetch = routeMap.containsKey('shouldPrefetch')
          ? routeMap['shouldPrefetch']
          : false;
      return RemoteView(routeMap['url'],
          fallback: fallback, shouldPrefetch: shouldPrefetch);
    }

    if (routeMap.containsKey('screen')) {
      return LocalView(BeagleUIElement(routeMap['screen']));
    }

    return null;
  }

  T? getCurrentRoute<T extends dynamic>() {
    final result = _beagleJSEngine
        .evaluateJavascriptCode(
            "global.beagle.getViewById('$_viewId').getNavigator().getCurrentRoute()")
        ?.rawResult;

    if (result == null) {
      return null;
    }

    return mapToRoute(result) as T;
  }

  bool isEmpty() {
    return _beagleJSEngine
        .evaluateJavascriptCode(
            "global.beagle.getViewById('$_viewId').getNavigator().isEmpty()")
        ?.rawResult;
  }

  Future<void> navigate(String jsFunction, NavigateFunctionParam type,
      dynamic route, String routeIdentifier,
      [String? controllerId]) {
    final routeJson = route != null ? routeToJson(route) : '';
    final args = type == NavigateFunctionParam.args
        ? (controllerId == null ? routeJson : "$routeJson, '$controllerId'")
        : '';

    String functionParam = '';
    switch (type) {
      case NavigateFunctionParam.args:
        functionParam = args;
        break;
      case NavigateFunctionParam.routeJson:
        functionParam = routeJson;
        break;
      case NavigateFunctionParam.routeIdentifier:
        functionParam = routeIdentifier;
        break;
      case NavigateFunctionParam.empty:
        functionParam = '';
        break;
    }

    final result = _beagleJSEngine.evaluateJavascriptCode(
        "global.beagle.getViewById('$_viewId').getNavigator().$jsFunction($functionParam)");
    return _beagleJSEngine.promiseToFuture(result);
  }

  @override
  Future<void> popStack(BuildContext context) {
    return navigate("popStack", NavigateFunctionParam.empty, null, '');
  }

  @override
  Future<void> popToView(String routeIdentifier, BuildContext context) {
    return navigate("popToView", NavigateFunctionParam.routeIdentifier, null,
        routeIdentifier);
  }

  @override
  Future<void> popView(BuildContext context) {
    return navigate("popView", NavigateFunctionParam.empty, null, '');
  }

  @override
  Future<void> pushStack(dynamic route, BuildContext context,
      [String? controllerId]) {
    return navigate(
        "pushStack", NavigateFunctionParam.args, route, '', controllerId);
  }

  @override
  Future<void> pushView(dynamic route, BuildContext context) {
    return navigate("pushView", NavigateFunctionParam.routeJson, route, '');
  }

  @override
  Future<void> resetApplication(dynamic route, BuildContext context,
      [String? controllerId]) {
    return navigate("resetApplication", NavigateFunctionParam.args, route, '',
        controllerId);
  }

  @override
  Future<void> resetStack(dynamic route, BuildContext context,
      [String? controllerId]) {
    return navigate(
        "resetStack", NavigateFunctionParam.args, route, '', controllerId);
  }

  RemoveListener subscribe(NavigationListener listener) {
    return _beagleJSEngine.onNavigate(_viewId, listener);
  }
}

enum NavigateFunctionParam { args, routeJson, routeIdentifier, empty }