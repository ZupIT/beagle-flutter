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

import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';

class BeagleJsEngineJsHelpers {
  final globalBeagle = 'global.beagle';
  final JavascriptRuntimeWrapper _jsRuntime;

  BeagleJsEngineJsHelpers(JavascriptRuntimeWrapper jsRuntime) : _jsRuntime = jsRuntime;

  dynamic deserializeJsFunctions(dynamic value, [String? viewId]) {
    if (value.runtimeType.toString() == 'String' && value.toString().startsWith('__beagleFn:')) {
      return ([dynamic argument]) {
        final args = argument == null ? "'$value'" : "'$value', ${json.encode(argument)}";
        final jsMethod = viewId == null ? 'call(' : "callViewFunction('$viewId', ";
        _jsRuntime.evaluate('$globalBeagle.$jsMethod$args)');
      };
    }

    if (value.runtimeType.toString() == 'List<dynamic>') {
      return (value as List<dynamic>).map((item) => deserializeJsFunctions(item, viewId)).toList();
    }

    if (value.runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>') {
      final map = value as Map<String, dynamic>;
      final result = <String, dynamic>{};
      final keys = map.keys;

      // ignore: cascade_invocations, avoid_function_literals_in_foreach_calls
      keys.forEach((key) {
        result[key] = deserializeJsFunctions(map[key], viewId);
      });
      return result;
    }

    return value;
  }

  void callJsFunction(String functionId, [Map<String, dynamic>? argsMap]) {
    _jsRuntime.evaluate('$globalBeagle.call("$functionId"${argsMap != null ? ", ${json.encode(argsMap)}" : ""})');
  }
}
