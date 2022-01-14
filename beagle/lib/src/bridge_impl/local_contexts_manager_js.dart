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
