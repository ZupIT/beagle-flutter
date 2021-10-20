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
import 'beagle_js_engine.dart';

class BeagleServiceJS implements BeagleService {
  BeagleServiceJS(
    this._beagleJSEngine, {
    required this.baseUrl,
    required this.httpClient,
    required this.viewClient,
    required this.components,
    required this.actions,
    required this.defaultNavigationController,
    required this.navigationControllers,
    required this.operations,
  });

  @override
  String baseUrl;
  @override
  HttpClient httpClient;
  @override
  ViewClient viewClient;
  @override
  Map<String, ComponentBuilder> components;
  @override
  Map<String, ActionHandler> actions;
  @override
  NavigationController defaultNavigationController;
  @override
  Map<String, NavigationController> navigationControllers;
  @override
  Map<String, Operation> operations;

  final BeagleJSEngine _beagleJSEngine;

  @override
  Future<void> start() async {
    await _beagleJSEngine.start();
    _registerBeagleService();
    _registerHttpListener();
    _registerOperationListener();
  }

  void _registerBeagleService() {
    final params = {
      'baseUrl': baseUrl,
      'actionKeys': actions.keys.toList(),
      'customOperations': operations.keys.toList(),
    };
    _beagleJSEngine.evaluateJavascriptCode('global.beagle.start(${json.encode(params)})');
  }

  void _registerHttpListener() {
    _beagleJSEngine.onHttpRequest((String id, BeagleRequest request) async {
      final response = await httpClient.sendRequest(request);
      _beagleJSEngine.respondHttpRequest(id, response);
    });
  }

  void _registerOperationListener() {
    _beagleJSEngine.onOperation((operationName, params) {
      final handler = operations[operationName];
      if (handler == null) {
        return;
      }
      handler(params);
    });
  }
}
