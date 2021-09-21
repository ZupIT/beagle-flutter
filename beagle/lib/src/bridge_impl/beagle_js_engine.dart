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
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import '../service_locator.dart';
import 'beagle_js_request_message.dart';
import 'beagle_view_js.dart';
import 'js_runtime_wrapper.dart';

typedef ActionListener = void Function({
  BeagleAction action,
  BeagleView view,
  BeagleUIElement element,
});

typedef HttpListener = void Function(String requestId, BeagleRequest request);

typedef OperationListener = void Function(
    String operationName, List<dynamic> args);

/// Provides an interface to run javascript code and listen to Beagle's core
/// events.
class BeagleJSEngine {
  BeagleJSEngine(JavascriptRuntimeWrapper jsRuntime) : assert(jsRuntime != null), _jsRuntime = jsRuntime;

  final JavascriptRuntimeWrapper _jsRuntime;
  BeagleJSEngineState _engineState = BeagleJSEngineState.CREATED;

  final _httpRequestChannelName = 'httpClient.request';
  final _actionChannelName = 'action';
  final _operationChannelName = 'operation';
  final _viewChangeChannelName = 'beagleView.update';
  final _loggerChannelName = 'logger';

  HttpListener _httpListener;
  final Map<String, List<ActionListener>> _viewActionListenerMap = {};
  OperationListener _operationListener;
  final Map<String, List<ViewChangeListener>> _viewChangeListenerMap = {};

  /// Runs javascript [code].
  /// It throws [BeagleJSEngineException] if [BeagleJSEngine] isn't started.
  JsEvalResult evaluateJavascriptCode(String code) {
    _checkEngineIsStarted();
    return _jsRuntime.evaluate(code);
  }

  void _checkEngineIsStarted() {
    if (!_isEngineStarted()) {
      throw BeagleJSEngineException(
          'BeagleJSEngine has not been started. Did you miss to call BeagleJSEngine.start()?');
    }
  }

  bool _isEngineStarted() {
    return _engineState == BeagleJSEngineState.STARTED;
  }

  BeagleJSEngineState get state => _engineState;

  dynamic _deserializeJsFunctions(dynamic value, [String viewId]) {
    if (value.runtimeType.toString() == 'String' &&
        value.toString().startsWith('__beagleFn:')) {
      return ([dynamic argument]) {
        final args = argument == null
            ? "'$value'"
            : "'$value', ${json.encode(argument)}";
        final jsMethod =
            viewId == null ? 'call(' : "callViewFunction('$viewId', ";
        _jsRuntime.evaluate('global.beagle.$jsMethod$args)');
      };
    }

    if (value.runtimeType.toString() == 'List<dynamic>') {
      // ignore: avoid_as
      return (value as List<dynamic>)
          .map((item) => _deserializeJsFunctions(item, viewId))
          .toList();
    }

    if (value.runtimeType.toString() ==
        '_InternalLinkedHashMap<String, dynamic>') {
      // ignore: avoid_as
      final map = value as Map<String, dynamic>;
      final result = <String, dynamic>{};
      final keys = map.keys;

      // ignore: cascade_invocations, avoid_function_literals_in_foreach_calls
      keys.forEach((key) {
        result[key] = _deserializeJsFunctions(map[key], viewId);
      });
      return result;
    }

    return value;
  }

  void _setupMessages() {
    _setupHttpMessages();
    _setupActionMessages();
    _setupBeagleViewMessages();
    _setupOperationMessages();
    _setupLoggerMessage();
  }

  void _setupHttpMessages() {
    _jsRuntime.onMessage(
      _httpRequestChannelName,
      _notifyHttpListener,
    );
  }

  void _notifyHttpListener(dynamic requestMessage) {
    if (_httpListener == null) {
      return;
    }

    final jsRequestMessage = BeagleJSRequestMessage.fromJson(requestMessage);
    final requestId = jsRequestMessage.requestId;
    final req = jsRequestMessage.toRequest();

    _httpListener(requestId, req);
  }

  void _setupLoggerMessage() {
    _jsRuntime.onMessage(
      _loggerChannelName,
      _notifyLoggerListener,
    );
  }

  void _notifyLoggerListener(dynamic loggerMessage) {
    final logger = beagleServiceLocator<BeagleLogger>();
    final message = loggerMessage['message'];
    final level = loggerMessage['level'];

    if (level == 'info') {
      logger.info(message);
    }
    if (level == 'warning') {
      logger.warning(message);
    }
    if (level == 'error') {
      logger.error(message);
    }
  }

  void _setupActionMessages() {
    _jsRuntime.onMessage(
      _actionChannelName,
      _notifyActionListener,
    );
  }

  void _notifyActionListener(dynamic actionMessage) {
    final viewId = actionMessage['viewId'];

    if (!_hasActionListenerForView(viewId)) {
      return;
    }

    final action =
        BeagleAction(_deserializeJsFunctions(actionMessage['action']));

    final view = BeagleViewJS.views[viewId];
    final element = BeagleUIElement(actionMessage['element']);

    for (final listener in _viewActionListenerMap[viewId]) {
      listener(action: action, view: view, element: element);
    }
  }

  bool _hasActionListenerForView(String viewId) {
    return _viewActionListenerMap.containsKey(viewId) &&
        _viewActionListenerMap[viewId].isNotEmpty;
  }

  void _setupOperationMessages() {
    _jsRuntime.onMessage(
      _operationChannelName,
      _notifyOperationListener,
    );
  }

  void _notifyOperationListener(dynamic operationMessage) {
    if (_operationListener == null) {
      return;
    }
    _operationListener(
        operationMessage['operation'], operationMessage['params']);
  }

  void _setupBeagleViewMessages() {
    _jsRuntime.onMessage(
      _viewChangeChannelName,
      _notifyViewUpdateListeners,
    );
  }

  void _notifyViewUpdateListeners(dynamic updateMessage) {
    final viewId = updateMessage['id'];

    if (!_hasUpdateListenerForView(viewId)) {
      return;
    }

    final deserialized = _deserializeJsFunctions(updateMessage['tree'], viewId);
    final uiElement = BeagleUIElement(deserialized);

    for (final listener in _viewChangeListenerMap[viewId]) {
      listener(uiElement);
    }
  }

  bool _hasUpdateListenerForView(String viewId) {
    return _viewChangeListenerMap.containsKey(viewId) &&
        _viewChangeListenerMap[viewId].isNotEmpty;
  }

  /// Handles a javascript promise.
  /// It throws [BeagleJSEngineException] if [BeagleJSEngine] isn't started.
  Future<JsEvalResult> promiseToFuture(JsEvalResult result) {
    _checkEngineIsStarted();
    return _jsRuntime.handlePromise(result);
  }

  /// Lazily starts the [BeagleJSEngine].
  /// This method must be called before any attempt to interact with Beagle's
  /// javascript core.
  Future<void> start() async {
    if (!_isEngineStarted()) {
      _engineState = BeagleJSEngineState.STARTED;
      _jsRuntime.enableHandlePromises();
      _setupMessages();
      final beagleJS =
          await rootBundle.loadString('packages/beagle/assets/js/beagle.js');
      _jsRuntime.evaluate('var window = global = globalThis;');
      await _jsRuntime.evaluateAsync(beagleJS);
    }
  }

  /// Creates a new BeagleView and returns the created view id.
  String createBeagleView() {
    final script = 'global.beagle.createBeagleView()';
    return _jsRuntime.evaluate(script).stringResult;
  }

  // ignore: use_setters_to_change_properties
  RemoveListener onAction(String viewId, ActionListener listener) {
    _viewActionListenerMap[viewId] = _viewActionListenerMap[viewId] ?? [];
    _viewActionListenerMap[viewId].add(listener);
    return () {
      _viewActionListenerMap[viewId].remove(listener);
    };
  }

  // ignore: use_setters_to_change_properties
  void onHttpRequest(HttpListener listener) {
    _httpListener = listener;
  }

  // ignore: use_setters_to_change_properties
  void onOperation(OperationListener listener) {
    _operationListener = listener;
  }

  RemoveListener onViewUpdate(String viewId, ViewChangeListener listener) {
    _viewChangeListenerMap[viewId] = _viewChangeListenerMap[viewId] ?? [];
    _viewChangeListenerMap[viewId].add(listener);
    return () {
      _viewChangeListenerMap[viewId].remove(listener);
    };
  }

  void removeViewListeners(String viewId) {
    _viewChangeListenerMap.remove(viewId);
    _viewActionListenerMap.remove(viewId);
  }

  void callJsFunction(String functionId, [Map<String, dynamic> argumentsMap]) {
    final args = argumentsMap == null
        ? "'$functionId'"
        : "'$functionId', ${json.encode(argumentsMap)}";
    _jsRuntime.evaluate('global.beagle.call($args)');
  }

  void respondHttpRequest(String id, Response response) {
    _jsRuntime.evaluate(
        'global.beagle.httpClient.respond($id, ${response.toJson()})');
  }
}

class BeagleJSEngineException implements Exception {
  BeagleJSEngineException(this._message);

  final String _message;

  @override
  String toString() => _message;
}

enum BeagleJSEngineState { CREATED, STARTED }
