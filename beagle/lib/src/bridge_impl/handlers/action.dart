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
import 'package:beagle/src/bridge_impl/beagle_view_js.dart';
import 'package:beagle/src/bridge_impl/handlers/base.dart';
import 'package:beagle/src/bridge_impl/utils.dart';
import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';

typedef ActionListener = void Function({
  required BeagleAction action,
  required BeagleView view,
  required BeagleUIElement element,
});

class BeagleJSEngineActionHandler implements BeagleJSEngineBaseHandlerWithListenersMap {
  final BeagleViewJS _fallbackBeagleViewJs;
  final BeagleJsEngineJsHelpers _jsHelpers;

  BeagleJSEngineActionHandler(
    JavascriptRuntimeWrapper jsRuntime,
    BeagleViewJS fallbackBeagleViewJs,
  )   : _fallbackBeagleViewJs = fallbackBeagleViewJs,
        _jsHelpers = BeagleJsEngineJsHelpers(jsRuntime);

  @override
  final Map<String, List<ActionListener>> listenersMap = {};

  @override
  String get channelName => 'action';

  @override
  void removeViewListener(String viewId) => listenersMap.remove(viewId);

  @override
  void notify(dynamic message) {
    final viewId = message['viewId'];
    final action = BeagleAction(_jsHelpers.deserializeJsFunctions(message['action']));
    final view = BeagleViewJS.views[viewId] ?? _fallbackBeagleViewJs;
    final element = BeagleUIElement(message['element'] ?? {});

    for (final listener in (listenersMap[viewId] ?? [])) {
      listener(action: action, view: view, element: element);
    }
  }
}
