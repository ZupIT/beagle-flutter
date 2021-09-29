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
import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';
import 'package:beagle/src/bridge_impl/renderer_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockBeagleJSEngine extends Mock implements BeagleJSEngine {}

class MockJavascriptRuntimeWrapper extends Mock
    implements JavascriptRuntimeWrapper {}

class MockStorage extends Mock implements Storage {}

void main() {
  group('Given a RendererJS object', () {
    group('When doFullRender', () {
      final beagleJSEngine = MockBeagleJSEngine();
      final tree = BeagleUIElement(
          {'_beagleComponent_': 'beagle:button', 'text': 'Click me!'});
      final renderer = RendererJS(beagleJSEngine, 'viewId');

      group('When doFullRender is called', () {
        test('Then it should do full render', () {
          renderer.doFullRender(tree);
          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .single,
              "global.beagle.getViewById('viewId').getRenderer().doFullRender(${jsonEncode(tree.properties)})");
        });
      });

      group('When doFullRender is called passing an anchor', () {
        test('Then it should do full render by replacing a branch of the tree',
            () {
          renderer.doFullRender(tree, 'elementId');
          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .single,
              "global.beagle.getViewById('viewId').getRenderer().doFullRender(${jsonEncode(tree.properties)}, 'elementId')");
        });
      });

      group('When doFullRender is called passing an anchor and append mode',
          () {
        test(
            'Then it should do full render by appending an element to a branch of the tree',
            () {
          renderer.doFullRender(tree, 'elementId', TreeUpdateMode.append);
          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .single,
              "global.beagle.getViewById('viewId').getRenderer().doFullRender(${jsonEncode(tree.properties)}, 'elementId', 'append')");
        });
      });

      group('When doPartialRender is called', () {
        test('Then it should do partial render', () {
          final tree = BeagleUIElement({
            '_beagleComponent_': 'beagle:button',
            'id': 'beagle1',
            'text': 'Click me!'
          });
          renderer.doPartialRender(tree);
          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .single,
              "global.beagle.getViewById('viewId').getRenderer().doPartialRender(${jsonEncode(tree.properties)})");
        });
      });

      group('When doPartialRender is called passing an anchor', () {
        test(
            'Then it should do partial render by replacing a branch of the tree',
            () {
          renderer.doPartialRender(tree, 'elementId');
          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .single,
              "global.beagle.getViewById('viewId').getRenderer().doPartialRender(${jsonEncode(tree.properties)}, 'elementId')");
        });
      });

      group('Is called passing an anchor and prepend mode', () {
        test(
            'Should do full partial by prepending an element to a branch of the tree',
            () {
          renderer.doPartialRender(tree, 'elementId', TreeUpdateMode.prepend);
          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .single,
              "global.beagle.getViewById('viewId').getRenderer().doPartialRender(${jsonEncode(tree.properties)}, 'elementId', 'prepend')");
        });
      });
    });

    group('When doTemplateRender', () {
      final beagleJSEngine = MockBeagleJSEngine();
      final templateRenderer = RendererJS(beagleJSEngine, 'viewId');
      final templatesContainerId = 'templatesContainerId';
      final defaultText = BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text':
            "This is @{item.name} which lives at @{item.address.street}, @{item.address.number}"
      });
      final maleText = BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text':
            "This is @{item.name} and HE lives at @{item.address.street}, @{item.address.number}"
      });
      final femaleText = BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text':
            "This is @{item.name} and SHE lives at @{item.address.street}, @{item.address.number}"
      });
      final templateManagerWithCases = TemplateManager(
        defaultTemplate: defaultText,
        templates: [
          TemplateManagerItem(
            condition: "@{eq(item.sex, 'M')}",
            view: maleText,
          ),
          TemplateManagerItem(
            condition: "@{eq(item.sex, 'F')}",
            view: femaleText,
          )
        ],
      );
      final dataSource = [
        [
          BeagleDataContext(
            id: 'name',
            value: 'John',
          ),
          BeagleDataContext(
            id: 'sex',
            value: 'M',
          ),
          BeagleDataContext(
            id: 'address',
            value: {'street': '42 Avenue TT', 'number': '256'},
          )
        ],
        [
          BeagleDataContext(
            id: 'name',
            value: 'Alex',
          ),
          BeagleDataContext(
            id: 'sex',
            value: 'F',
          ),
          BeagleDataContext(
            id: 'address',
            value: {'street': 'St Monica St', 'number': '852'},
          )
        ]
      ];

      group('Is called with only one template without case', () {
        test(
            'Then it should render using this as default template without templates',
            () {
          final templateManager = TemplateManager(
            defaultTemplate: defaultText,
            templates: [],
          );
          templateRenderer.doTemplateRender(
              templateManager: templateManager,
              anchor: templatesContainerId,
              contexts: dataSource);

          final arguments = [
            jsonEncode(templateManager.toJson())
                .replaceAll(RegExp(r'defaultTemplate:'), 'default:')
                .replaceAll(RegExp(r'condition:'), 'case:'),
            "'$templatesContainerId'",
            jsonEncode(dataSource)
          ];

          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .last,
              "global.beagle.getViewById('viewId').getRenderer().doTemplateRender(${arguments.join(", ")})");
        });
      });

      group('Is called with more than one template', () {
        test(
            'Then it should render a template using the templates that match the conditions',
            () {
          templateRenderer.doTemplateRender(
              templateManager: templateManagerWithCases,
              anchor: 'templatesContainerId',
              contexts: dataSource);

          final arguments = [
            jsonEncode(templateManagerWithCases.toJson())
                .replaceAll(RegExp(r'defaultTemplate:'), 'default:')
                .replaceAll(RegExp(r'condition:'), 'case:'),
            "'$templatesContainerId'",
            jsonEncode(dataSource)
          ];

          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .last,
              "global.beagle.getViewById('viewId').getRenderer().doTemplateRender(${arguments.join(", ")})");
        });
      });

      group('Is called with a componentManager', () {
        test(
            'Then it should render a template using the templates that match the conditions and should call the componentManager for each item of the dataSource',
            () async {
          final componentManagerCallbackId =
              'global.beagle.doTemplateRender.$templatesContainerId.componentManagerCallback';
          // ignore: prefer_function_declarations_over_variables
          final componentManager = (BeagleUIElement component, int index) {
            return component;
          };

          templateRenderer.doTemplateRender(
              templateManager: templateManagerWithCases,
              anchor: templatesContainerId,
              contexts: dataSource,
              componentManager: componentManager,
              mode: TreeUpdateMode.append);

          final arguments = [
            jsonEncode(templateManagerWithCases.toJson())
                .replaceAll(RegExp(r'defaultTemplate:'), 'default:')
                .replaceAll(RegExp(r'condition:'), 'case:'),
            "'$templatesContainerId'",
            jsonEncode(dataSource),
            """function _componentManagerJs(c, i) { return sendMessage("$componentManagerCallbackId", JSON.stringify({ "component": c, "index": i })); }""",
            "'${TreeUpdateMode.append.toString().split('.')[1]}'"
          ];

          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .last,
              "global.beagle.getViewById('viewId').getRenderer().doTemplateRender(${arguments.join(", ")})");
        });
      });

      group('Is called without a componentManager and mode', () {
        test(
            'Then it should render a template using the templates that match the conditions and should set the componentManager as null and set the mode',
            () async {
          templateRenderer.doTemplateRender(
              templateManager: templateManagerWithCases,
              anchor: templatesContainerId,
              contexts: dataSource,
              mode: TreeUpdateMode.append);

          final arguments = [
            jsonEncode(templateManagerWithCases.toJson())
                .replaceAll(RegExp(r'defaultTemplate:'), 'default:')
                .replaceAll(RegExp(r'condition:'), 'case:'),
            "'$templatesContainerId'",
            jsonEncode(dataSource),
            'null',
            "'${TreeUpdateMode.append.toString().split('.')[1]}'"
          ];

          expect(
              verify(beagleJSEngine.evaluateJavascriptCode(captureAny))
                  .captured
                  .last,
              "global.beagle.getViewById('viewId').getRenderer().doTemplateRender(${arguments.join(", ")})");
        });
      });
    });
  });
}
