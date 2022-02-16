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

import 'dart:convert';
import 'package:beagle/beagle.dart';
import 'beagle_js_engine.dart';

class LocalContextSerializationError implements Exception {
  LocalContextSerializationError(Type type, String contextId) {
    Exception(
        'Cannot set $contextId context value. The value passed as parameter is not encodable ($type). Please, use a value of the type Map, Array, String, num or bool.');
  }
}

/// Access to the Local Context API, of an specific Beagle View. Use it to set persistent values that can be retrieved and
/// manipulated by the widgets of this Beagle View.
class LocalContextJS implements LocalContext {
  LocalContextJS(this._jsEngine, this._viewId, this._contextId);

  final BeagleJSEngine _jsEngine;
  final String _viewId;
  final String _contextId;

  @override
  void clear([String? path]) {
    final args = path == null || path.isEmpty ? '' : '"$path"';
    _jsEngine.evaluateJsCode(
        'global.beagle.getViewById("$_viewId").getLocalContexts().getContext("$_contextId").clear($args)');
  }

  @override
  T get<T>([String? path]) {
    final args = path == null || path.isEmpty ? '' : '"$path"';
    return _jsEngine
        .evaluateJsCode('global.beagle.getViewById("$_viewId").getLocalContexts().getContext("$_contextId").get($args)')
        ?.rawResult;
  }

  @override
  void set<T>(T value, [String? path]) {
    if (!_isEncodable(value)) {
      throw LocalContextSerializationError(value.runtimeType, _contextId);
    }

    final jsonString = json.encode(value);
    final args = path == null || path.isEmpty ? jsonString : '$jsonString, "$path"';
    _jsEngine.evaluateJsCode(
        'global.beagle.getViewById("$_viewId").getLocalContexts().getContext("$_contextId").set($args)');
  }

  bool _isEncodable(dynamic value) => value is num || value is String || value is List || value is Map;
}
