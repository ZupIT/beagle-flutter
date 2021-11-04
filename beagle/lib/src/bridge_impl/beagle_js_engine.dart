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
import 'package:beagle/src/bridge_impl/beagle_view_js.dart';
import 'package:beagle/src/bridge_impl/handlers/handlers.dart';
import 'package:beagle/src/bridge_impl/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import 'js_runtime_wrapper.dart';

/// Provides an interface to run javascript code and listen to Beagle's core
/// events.
class BeagleJSEngine {
  late BeagleJSEngineActionHandler _actionHandler;

  final JavascriptRuntimeWrapper _jsRuntime;
  final BeagleJsEngineJsHelpers _jsHelpers;
  final BeagleJSEngineAnalyticsHandler _analyticsHandler;
  final BeagleJSEngineHttpHandler _httpHandler;
  final BeagleJSEngineLoggerHandler _loggerHandler;
  final BeagleJSEngineOperationHandler _operationHandler;
  final BeagleJSEngineViewUpdateHandler _viewUpdateHandler;
  final Map<String, AwaitableNotification> _awaitingListenerMap = {};

  BeagleJSEngineState _engineState = BeagleJSEngineState.CREATED;

  BeagleJSEngine(JavascriptRuntimeWrapper jsRuntime)
      : _jsRuntime = jsRuntime,
        _jsHelpers = BeagleJsEngineJsHelpers(jsRuntime),
        _analyticsHandler = BeagleJSEngineAnalyticsHandler(jsRuntime),
        _httpHandler = BeagleJSEngineHttpHandler(),
        _loggerHandler = BeagleJSEngineLoggerHandler(),
        _operationHandler = BeagleJSEngineOperationHandler(),
        _viewUpdateHandler = BeagleJSEngineViewUpdateHandler(jsRuntime);

  BeagleJSEngineState get state => _engineState;

  void callJsFunction(String functionId, [Map<String, dynamic>? argsMap]) =>
      _jsHelpers.callJsFunction(functionId, argsMap);

  void addJsCallback(String name, dynamic Function(dynamic) listener) => _jsRuntime.onMessage(name, listener);

  void onHttpRequest(HttpListener listener) => _httpHandler.setListener(listener);

  void onOperation(OperationListener listener) => _operationHandler.setListener(listener);

  RemoveListener onAction(String viewId, ActionListener listener) =>
      _handleRemovableListener<ActionListener>(viewId, _actionHandler.listenersMap, listener);

  RemoveListener onViewUpdate(String viewId, ViewChangeListener listener) =>
      _handleRemovableListener<ViewChangeListener>(viewId, _viewUpdateHandler.listenersMap, listener);

  void evaluateOnJSRuntime(String promiseId, String? result) => _jsRuntime.evaluate(
      "${_jsHelpers.globalBeagle}.promise.resolve('$promiseId'${result != null ? ", ${jsonEncode(result)}" : ""})");

  void respondHttpRequest(String id, Response? response) =>
      _jsRuntime.evaluate('${_jsHelpers.globalBeagle}.httpClient.respond($id, ${response?.toJson()})');

  /// Creates a new BeagleView and returns the created view id.
  String createBeagleView() => _jsRuntime.evaluate('${_jsHelpers.globalBeagle}.createBeagleView()')?.stringResult ?? '';

  bool hasHandlerAwaitingForThisView(String viewId) => _awaitingListenerMap.containsKey(viewId);

  void removeViewListeners(String viewId) {
    _awaitingListenerMap.remove(viewId);
    _actionHandler.removeViewListener(viewId);
    _viewUpdateHandler.removeViewListener(viewId);
  }

  /// Handles a javascript promise.
  /// It throws [BeagleJSEngineException] if [BeagleJSEngine] isn't started.
  Future<JsEvalResult> promiseToFuture(JsEvalResult? result) {
    _checkEngineIsStarted();
    return _jsRuntime.handlePromise(result ?? JsEvalResult("null", null));
  }

  /// Runs javascript [code].
  /// It throws [BeagleJSEngineException] if [BeagleJSEngine] isn't started.
  JsEvalResult? evaluateJavascriptCode(String code) {
    _checkEngineIsStarted();
    return _jsRuntime.evaluate(code);
  }

  /// Lazily starts the [BeagleJSEngine].
  /// This method must be called before any attempt to interact with Beagle's
  /// javascript core.
  Future<void> start() async {
    if (!_isEngineStarted()) {
      _engineState = BeagleJSEngineState.STARTED;
      _jsRuntime.enableHandlePromises();
      _actionHandler = BeagleJSEngineActionHandler(_jsRuntime, BeagleViewJS(this));

      _setupMessages();

      final beagleJS = await rootBundle.loadString('packages/beagle/assets/js/beagle.js');
      _jsRuntime.evaluate('var window = global = globalThis;');

      await _jsRuntime.evaluateAsync(beagleJS);
    }
  }

  bool _isEngineStarted() => _engineState == BeagleJSEngineState.STARTED;

  void _checkEngineIsStarted() {
    if (!_isEngineStarted()) {
      throw BeagleJSEngineException(
          'BeagleJSEngine has not been started. Did you miss to call BeagleJSEngine.start()?');
    }
  }

  RemoveListener _handleRemovableListener<T>(String viewId, Map<String, List<T>> map, T listener) {
    map[viewId] = map[viewId] ?? [];
    map[viewId]!.add(listener);

    return () {
      map[viewId]?.remove(listener);
    };
  }

  void _setupMessages() {
    _jsRuntime.onMessage(_analyticsHandler.channelName, _analyticsHandler.notify);
    _jsRuntime.onMessage(_analyticsHandler.getConfigChannelName, _analyticsHandler.getConfig);
    _jsRuntime.onMessage(_httpHandler.channelName, _httpHandler.notify);
    _jsRuntime.onMessage(_loggerHandler.channelName, _loggerHandler.notify);
    _jsRuntime.onMessage(_operationHandler.channelName, _operationHandler.notify);
    _jsRuntime.onMessage(_actionHandler.channelName, _actionHandler.notify);
    _jsRuntime.onMessage(_viewUpdateHandler.channelName, _viewUpdateHandler.notify);
  }
}

class BeagleJSEngineException implements Exception {
  BeagleJSEngineException(this._message);

  final String _message;

  @override
  String toString() => _message;
}

enum BeagleJSEngineState { CREATED, STARTED }

class AwaitableNotification {
  final BeagleJSEngineBaseHandlerWithListenersMap handler;
  final dynamic message;

  AwaitableNotification(this.handler, this.message);
}
