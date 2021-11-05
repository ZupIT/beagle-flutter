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
import 'package:flutter_js/flutter_js.dart';

import 'beagle_js_engine.dart';
import 'js_runtime_wrapper.dart';

class BeagleJS {
  BeagleJS(this._beagle) : engine = BeagleJSEngine(
    _beagle,
    JavascriptRuntimeWrapper(getJavascriptRuntime(forceJavascriptCoreOnAndroid: true, xhr: false)),
  );

  final BeagleService _beagle;
  bool _hasStarted = false;
  final BeagleJSEngine engine;

  void _registerBeagleService() {
    final params = {
      'baseUrl': _beagle.baseUrl,
      'actionKeys': _beagle.actions.keys.toList(),
      'customOperations': _beagle.operations.keys.toList(),
    };
    engine.evaluateJavascriptCode('global.beagle.start(${json.encode(params)})');
  }

  void _registerHttpListener() {
    engine.onHttpRequest((String id, BeagleRequest request) async {
      final response = await _beagle.httpClient.sendRequest(request);
      engine.respondHttpRequest(id, response);
    });
  }

  void _registerOperationListener() {
    engine.onOperation((operationName, params) {
      final handler = _beagle.operations[operationName];
      if (handler == null) {
        return;
      }
      handler(params);
    });
  }

  Future<void> start() async {
    if (_hasStarted) return;
    await engine.start();
    _registerBeagleService();
    _registerHttpListener();
    _registerOperationListener();
    _hasStarted = true;
  }
}
