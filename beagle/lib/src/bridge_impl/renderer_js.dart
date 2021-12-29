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
import 'package:beagle/src/bridge_impl/beagle_js_engine.dart';
import 'package:beagle/src/utils/map_utils.dart';

class RendererJS implements Renderer {
  final globalBeagle = "global.beagle";
  final String _viewId;
  final BeagleJSEngine _jsEngine;

  RendererJS(this._jsEngine, this._viewId);

  String _getJsTreeUpdateModeName(TreeUpdateMode mode) {
    /* When calling toString in an enum, it returns EnumName.EnumValue, we just need the part after
    the ".", which will give us the strategy name. */
    return mode.toString().split('.')[1];
  }

  void _doRender(bool isFull, BeagleUIElement tree, [String? anchor, TreeUpdateMode? mode]) {
    final method = isFull ? 'doFullRender' : 'doPartialRender';
    final arguments = [jsonEncode(tree.properties)];
    if (anchor != null) arguments.add("'$anchor'");
    if (mode != null) arguments.add("'${_getJsTreeUpdateModeName(mode)}'");
    _jsEngine.evaluateJsCode("$globalBeagle.getViewById('$_viewId').getRenderer().$method(${arguments.join(", ")})");
  }

  @override
  void doFullRender(BeagleUIElement tree, [String? anchor, TreeUpdateMode? mode]) {
    _doRender(true, tree, anchor, mode);
  }

  @override
  void doPartialRender(BeagleUIElement tree, [String? anchor, TreeUpdateMode? mode]) {
    _doRender(false, tree, anchor, mode);
  }

  @override
  void doTemplateRender({
    required TemplateManager templateManager,
    required String anchor,
    required List<List<BeagleDataContext>> contexts,
    BeagleUIElement Function(BeagleUIElement, int)? componentManager,
    TreeUpdateMode? mode,
  }) {
    final globalRender = "$globalBeagle.render";
    final templatesJs = jsonEncode(templateManager.toJson());
    final modeJs = _getJsTreeUpdateModeName(mode ?? TreeUpdateMode.replace);

    // ignore: prefer_function_declarations_over_variables
    final evaluateRenderFn = (String functionName, String arguments) =>
        json.decode(_jsEngine.evaluateJsCode("$globalRender.$functionName($arguments)")?.stringResult ?? "null");

    // ignore: prefer_function_declarations_over_variables
    final encodeContexts = (List<BeagleDataContext> contexts) => contexts.map(((i) => i.toJson())).toList();

    if (componentManager != null) {
      final rawHierarchy = json
          .decode(_jsEngine.evaluateJsCode("$globalRender.getTreeContextHierarchy('$_viewId')")?.stringResult ?? '[]');
      final globalHierarchy = (rawHierarchy as List<dynamic>).map((raw) => BeagleDataContext.fromJson(raw)).toList();
      final contextTemplates = List<Map<String, dynamic>>.empty(growable: true);

      for (int i = 0; i < contexts.length; i++) {
        final context = contexts[i];
        final contextHierarchy = [...context, ...globalHierarchy];
        final templateArgs = ["'$_viewId'", json.encode(encodeContexts(contextHierarchy)), templatesJs];
        final Map<String, dynamic> template = evaluateRenderFn("getContextEvaluatedTemplate", templateArgs.join(', '));
        final adjusted = componentManager(BeagleUIElement(deepCloneMap(template)), i);
        adjusted.properties['_implicitContexts_'] = context;

        final preProcessedElement = evaluateRenderFn("preProcessTemplateTree", adjusted.toString());
        contextTemplates.add(preProcessedElement);
      }

      _jsEngine.evaluateJsCode(
          "$globalRender.doTreeFullRender('$_viewId', '$anchor', ${json.encode(contextTemplates)}, '$modeJs')");
    } else {
      final contextsJs = jsonEncode(contexts.map((c) => encodeContexts(c)).toList()).trim();
      final arguments = [templatesJs, "'$anchor'", contextsJs, "null", "'$modeJs'"];
      _jsEngine.evaluateJsCode(
          "$globalBeagle.getViewById('$_viewId').getRenderer().doTemplateRender(${arguments.join(", ")})");
    }
  }
}
