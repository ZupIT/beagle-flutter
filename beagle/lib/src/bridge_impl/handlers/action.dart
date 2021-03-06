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
  final BeagleJsEngineJsHelpers _jsHelpers;

  BeagleJSEngineActionHandler(JavascriptRuntimeWrapper jsRuntime) : _jsHelpers = BeagleJsEngineJsHelpers(jsRuntime);

  @override
  final Map<String, List<ActionListener>> listenersMap = {};

  @override
  String get channelName => 'action';

  @override
  void removeViewListener(String viewId) => listenersMap.remove(viewId);

  @override
  void notify(dynamic message) {
    /* actionMessage must be a map with of the type:
    { action: BeagleAction (map), viewId: string, element: BeagleUIElement (map) } */
    final viewId = message['viewId'];
    final action = BeagleAction(_jsHelpers.deserializeJsFunctions(message['action']));
    final view = BeagleViewJS.views[viewId]!;
    final element = BeagleUIElement(message['element'] ?? {});

    for (ActionListener listener in (listenersMap[viewId] ?? [])) {
      try {
        listener(action: action, view: view, element: element);
      } catch (err, st) {
        print(err);
        print(st);
      }
    }
  }
}
