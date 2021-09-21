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

import 'package:beagle/beagle.dart';

import 'beagle_js_engine.dart';
import 'renderer_js.dart';

/// Creates a new Beagle View. If this view is created by a navigator, it must be specified in the constructor.
class BeagleViewJS implements BeagleView {
  BeagleViewJS(this._beagleJSEngine, [this.parentNavigator]) {
    _id = _beagleJSEngine.createBeagleView();
    BeagleViewJS.views[_id] = this;
    _renderer = RendererJS(_beagleJSEngine, _id);
  }

  String _id;
  BeagleNavigator parentNavigator;
  Renderer _renderer;
  static Map<String, BeagleViewJS> views = {};
  final BeagleJSEngine _beagleJSEngine;

  @override
  void destroy() {
    _beagleJSEngine.removeViewListeners(_id);
    views.remove(_id);
  }

  @override
  BeagleNavigator getNavigator() {
    return parentNavigator;
  }

  @override
  Renderer getRenderer() {
    return _renderer;
  }

  @override
  BeagleUIElement getTree() {
    final result = _beagleJSEngine
        .evaluateJavascriptCode("global.beagle.getViewById('$_id').getTree()")
        .rawResult;
    return BeagleUIElement(result);
  }

  @override
  void Function() onChange(ViewChangeListener listener) {
    return _beagleJSEngine.onViewUpdate(_id, listener);
  }

  @override
  void Function() onAction(ActionListener listener) {
    return _beagleJSEngine.onAction(_id, listener);
  }
}
