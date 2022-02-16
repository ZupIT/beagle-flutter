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
import 'package:beagle/src/bridge_impl/handlers/action.dart';
import 'package:beagle/src/bridge_impl/local_contexts_manager_js.dart';

import 'beagle_js_engine.dart';
import 'renderer_js.dart';

/// Creates a new Beagle View. If this view is created by a navigator, it must be specified in the constructor.
class BeagleViewJS implements BeagleView {
  BeagleViewJS(this._jsEngine, this._parentNavigator) {
    _id = _jsEngine.createBeagleView();
    BeagleViewJS.views[_id] = this;
    _renderer = RendererJS(_jsEngine, _id);
    _localContextsManager = LocalContextsManagerJS(_jsEngine, _id);
  }

  late String _id;
  late Renderer _renderer;
  late LocalContextsManager _localContextsManager;
  final BeagleNavigator _parentNavigator;
  final BeagleJSEngine _jsEngine;
  static Map<String, BeagleViewJS> views = {};

  @override
  void destroy() {
    _jsEngine.removeViewListeners(_id);
    views.remove(_id);
  }

  @override
  BeagleNavigator getNavigator() => _parentNavigator;

  @override
  LocalContextsManager getLocalContexts() => _localContextsManager;

  @override
  Renderer getRenderer() => _renderer;

  @override
  BeagleUIElement? getTree() {
    final result = _jsEngine.evaluateJsCode("global.beagle.getViewById('$_id').getTreeAsJson()")?.stringResult;

    if (result == null) return null;

    final parsed = json.decode(result);
    return BeagleUIElement.isBeagleUIElement(parsed) ? BeagleUIElement(parsed) : null;
  }

  @override
  void Function() onChange(ViewChangeListener listener) => _jsEngine.onViewUpdate(_id, listener);

  @override
  void Function() onAction(ActionListener listener) => _jsEngine.onAction(_id, listener);
}
