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
import 'package:beagle/src/bridge_impl/beagle_js_engine.dart';
import 'package:beagle/src/bridge_impl/local_context_js.dart';

class LocalContextsManagerSerializationError implements Exception {
  LocalContextsManagerSerializationError(Type type, String contextId) {
    Exception(
        'Cannot set $contextId context value. The value passed as parameter is not encodable ($type). Please, use a value of the type Map, Array, String, num or bool.');
  }
}

class LocalContextsManagerJS implements LocalContextsManager {
  final String _viewId;
  final BeagleJSEngine _jsEngine;

  LocalContextsManagerJS(this._jsEngine, this._viewId);

  @override
  void clearAll() {
    _jsEngine.evaluateJsCode('global.beagle.getViewById("$_viewId").getLocalContexts().clearAll()');
  }

  @override
  List<BeagleDataContext> getAllAsDataContext() {
    final result = _jsEngine
        .evaluateJsCode('global.beagle.getViewById("$_viewId").getLocalContexts().getAllAsDataContext()')
        ?.stringResult;
    if (result != null && result.isNotEmpty) {
      final dataContexts = json.decode(result) as List<Map<String, dynamic>>;
      return dataContexts.map((context) => BeagleDataContext.fromJson(context)).toList();
    }
    return [];
  }

  @override
  LocalContext? getContext(String id) {
    final result = _jsEngine
        .evaluateJsCode('global.beagle.getViewById("$_viewId").getLocalContexts().getContextAsDataContext("$id")')
        ?.stringResult;
    if (result != null && result.isNotEmpty) {
      return LocalContextJS(_jsEngine, _viewId, id);
    }
    return null;
  }

  @override
  BeagleDataContext? getContextAsDataContext(String id) {
    final result = _jsEngine
        .evaluateJsCode('global.beagle.getViewById("$_viewId").getLocalContexts().getContextAsDataContext("$id")')
        ?.stringResult;
    if (result != null && result.isNotEmpty) {
      return BeagleDataContext.fromJson(json.decode(result));
    }
    return null;
  }

  @override
  void removeContext(String id) {
    _jsEngine.evaluateJsCode('global.beagle.getViewById("$_viewId").getLocalContexts().removeContext("$id")');
  }

  @override
  void setContext(String id, value, [String? path]) {
    if (!_isEncodable(value)) {
      throw LocalContextsManagerSerializationError(value.runtimeType, id);
    }

    final pathEncoded = path == null || path.isEmpty ? '' : path;
    final valueEncoded = json.encode(value);
    _jsEngine.evaluateJsCode(
        'global.beagle.getViewById("$_viewId").getLocalContexts().setContext("$id", $valueEncoded, "$pathEncoded")');
  }

  bool _isEncodable(dynamic value) => value is num || value is String || value is List || value is Map;
}
