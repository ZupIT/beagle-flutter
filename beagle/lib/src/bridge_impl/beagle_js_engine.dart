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
import 'package:meta/meta.dart';

import '../service_locator.dart';
import 'beagle_js_request_message.dart';
import 'beagle_navigator_js.dart';
import 'beagle_view_js.dart';
import 'js_runtime_wrapper.dart';

typedef ActionListener = void Function({
  BeagleAction? action,
  BeagleView? view,
  BeagleUIElement? element,
});

typedef HttpListener = void Function(String requestId, BeagleRequest request);

typedef OperationListener = void Function(
    String operationName, List<dynamic> args);

/// Provides an interface to run javascript code and listen to Beagle's core
/// events.
class BeagleJSEngine {
  BeagleJSEngine(JavascriptRuntimeWrapper jsRuntime) : _jsRuntime = jsRuntime;

  final JavascriptRuntimeWrapper _jsRuntime;
  BeagleJSEngineState _engineState = BeagleJSEngineState.CREATED;

  final _httpRequestChannelName = 'httpClient.request';
  final _actionChannelName = 'action';
  final _operationChannelName = 'operation';
  final _viewChangeChannelName = 'beagleView.update';
  final _loggerChannelName = 'logger';
  final _analyticsCreateRecordChannelName = 'analytics.createRecord';
  final _analyticsGetConfigChannelName = 'analytics.getConfig';

  HttpListener? _httpListener;
  final Map<String, List<ActionListener>> _viewActionListenerMap = {};
  OperationListener? _operationListener;
  final Map<String, List<NavigationListener>> _navigationListenerMap = {};
  final Map<String, List<ViewChangeListener>> _viewChangeListenerMap = {};

  /// Runs javascript [code].
  /// It throws [BeagleJSEngineException] if [BeagleJSEngine] isn't started.
  JsEvalResult? evaluateJavascriptCode(String code) {
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

  dynamic _deserializeJsFunctions(dynamic value, [String? viewId]) {
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
    _setupAnalyticsMessage();
  }

  void _setupHttpMessages() {
    _jsRuntime.onMessage(
      _httpRequestChannelName,
      notifyHttpListener,
    );
  }

  @visibleForTesting
  void notifyHttpListener(dynamic requestMessage) {
    if (_httpListener == null) {
      return;
    }

    final jsRequestMessage = BeagleJSRequestMessage.fromJson(requestMessage);
    final requestId = jsRequestMessage.requestId;
    final req = jsRequestMessage.toRequest();

    _httpListener!(requestId, req);
  }

  void _setupLoggerMessage() {
    _jsRuntime.onMessage(
      _loggerChannelName,
      notifyLoggerListener,
    );
  }

  void _setupAnalyticsMessage() {
    // Handles createRecord
    _jsRuntime.onMessage(
      _analyticsCreateRecordChannelName,
      _notifyAnalyticsCreateRecordListener,
    );

    // Handles getConfig
    _jsRuntime.onMessage(_analyticsGetConfigChannelName, (dynamic args) {
      final functionId = args["functionId"];
      _notifyAnalyticsGetConfigListener(functionId);
    });
  }

  void _notifyAnalyticsCreateRecordListener(dynamic analyticsRecordMap) {
    if (beagleServiceLocator.isRegistered<AnalyticsProvider>()) {
      final analyticsProvider = beagleServiceLocator<AnalyticsProvider>();
      final record = AnalyticsRecord().fromMap(analyticsRecordMap);
      /*
       * TODO find a way to extract x,y of the component that triggered the event. Example:
       *  final componentId = analyticsRecord[analytics.component['id']];
       *  final position = findPositionByComponentId(componentId); // position.x, position.y
       */
      analyticsProvider.createRecord(record);
    }
  }

  @visibleForTesting
  void notifyLoggerListener(dynamic loggerMessage) {
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
      notifyActionListener,
    );
  }

  @visibleForTesting
  void notifyActionListener(dynamic actionMessage) {
    final viewId = actionMessage['viewId'];
    if (!_hasActionListenerForView(viewId)) {
      return;
    }

    final action =
        BeagleAction(_deserializeJsFunctions(actionMessage['action']));

    final view = BeagleViewJS.views[viewId];
    final element = actionMessage['element'] != null
        ? BeagleUIElement(actionMessage['element'])
        : null;

    for (final listener in (_viewActionListenerMap[viewId] ?? [])) {
      listener(action: action, view: view, element: element);
    }
  }

  void _setupOperationMessages() {
    _jsRuntime.onMessage(
      _operationChannelName,
      notifyOperationListener,
    );
  }

  @visibleForTesting
  void notifyOperationListener(dynamic operationMessage) {
    if (_operationListener == null) {
      return;
    }
    _operationListener!(
        operationMessage['operation'], operationMessage['params']);
  }

  void _setupBeagleViewMessages() {
    _jsRuntime.onMessage(
      _viewChangeChannelName,
      notifyViewUpdateListeners,
    );
  }

  @visibleForTesting
  void notifyViewUpdateListeners(dynamic updateMessage) {
    final viewId = updateMessage['id'];

    if (!_hasUpdateListenerForView(viewId)) {
      return;
    }

    final deserialized = _deserializeJsFunctions(updateMessage['tree'], viewId);
    final uiElement = BeagleUIElement(deserialized);

    for (final listener in (_viewChangeListenerMap[viewId] ?? [])) {
      listener(uiElement);
    }
  }

  @visibleForTesting
  void notifyNavigationListeners(dynamic navigationMessage) {
    final viewId = navigationMessage['viewId'];

    if (!_hasNavigationListenerForView(viewId)) {
      return;
    }

    final route = BeagleNavigatorJS.mapToRoute(navigationMessage['route']);

    for (final listener in (_navigationListenerMap[viewId] ?? [])) {
      listener(route);
    }
  }

  bool _handleListenerForView(String viewId, dynamic map) {
    return map.containsKey(viewId) && (map[viewId]?.isNotEmpty ?? true);
  }

  bool _hasActionListenerForView(String viewId) {
    return _handleListenerForView(viewId, _viewActionListenerMap);
  }

  bool _hasUpdateListenerForView(String viewId) {
    return _handleListenerForView(viewId, _viewChangeListenerMap);
  }

  bool _hasNavigationListenerForView(String viewId) {
    return _handleListenerForView(viewId, _navigationListenerMap);
  }

  void evaluateOnJSRuntime(String promiseId, String? result) => _jsRuntime.evaluate(
      "global.beagle.promise.resolve('$promiseId'${result != null ? ", ${jsonEncode(result)}" : ""})");

  /// Handles a javascript promise.
  /// It throws [BeagleJSEngineException] if [BeagleJSEngine] isn't started.
  Future<JsEvalResult> promiseToFuture(JsEvalResult? result) {
    _checkEngineIsStarted();
    return _jsRuntime.handlePromise(result ?? JsEvalResult("null", null));
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
    return _jsRuntime.evaluate(script)?.stringResult ?? '';
  }

  // ignore: use_setters_to_change_properties
  void onHttpRequest(HttpListener listener) {
    _httpListener = listener;
  }

  // ignore: use_setters_to_change_properties
  void onOperation(OperationListener listener) {
    _operationListener = listener;
  }

  RemoveListener handleListenerRemoval<T>(
      String viewId, Map<String, List<T>> map, T listener) {
    map[viewId] = map[viewId] ?? [];
    map[viewId]?.add(listener);
    return () {
      map[viewId]?.remove(listener);
    };
  }

  RemoveListener onAction(String viewId, ActionListener listener) {
    return handleListenerRemoval<ActionListener>(
        viewId, _viewActionListenerMap, listener);
  }

  RemoveListener onNavigate(String viewId, NavigationListener listener) {
    return handleListenerRemoval<NavigationListener>(
        viewId, _navigationListenerMap, listener);
  }

  RemoveListener onViewUpdate(String viewId, ViewChangeListener listener) {
    return handleListenerRemoval<ViewChangeListener>(
        viewId, _viewChangeListenerMap, listener);
  }

  void removeViewListeners(String viewId) {
    _viewChangeListenerMap.remove(viewId);
    _viewActionListenerMap.remove(viewId);
  }

  void callJsFunction(String functionId, [Map<String, dynamic>? argumentsMap]) {
    _jsRuntime.evaluate(
        'global.beagle.call("$functionId"${argumentsMap != null ? ", ${json.encode(argumentsMap)}" : ""})');
  }

  void respondHttpRequest(String id, Response? response) {
    _jsRuntime.evaluate(
        'global.beagle.httpClient.respond($id, ${response?.toJson()})');
  }

  void _notifyAnalyticsGetConfigListener(String functionId) {
    if (beagleServiceLocator.isRegistered<AnalyticsProvider>()) {
      final analyticsProvider = beagleServiceLocator<AnalyticsProvider>();
      callJsFunction(functionId, analyticsProvider.getConfig().toMap());
    }
  }

  void addJsCallback(String callbackName, dynamic Function(dynamic) listener) {
    _jsRuntime.onMessage(callbackName, listener);
  }
}

class BeagleJSEngineException implements Exception {
  BeagleJSEngineException(this._message);

  final String _message;

  @override
  String toString() => _message;
}

enum BeagleJSEngineState { CREATED, STARTED }
