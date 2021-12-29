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

// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:convert';

import 'package:beagle/beagle.dart';
import 'package:beagle/src/bridge_impl/beagle_js_engine.dart';
import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';
import 'package:beagle/src/bridge_impl/renderer_js.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test-utils/mocktail.dart';

class MockBeagleJSEngine extends Mock implements BeagleJSEngine {}

class MockJavascriptRuntimeWrapper extends Mock implements JavascriptRuntimeWrapper {}

class JsCodeExpectedCall {
  String argument;
  JsEvalResult response;

  JsCodeExpectedCall(this.argument, this.response);
}

class ComponentManagerCall {
  Map<String, dynamic> component;
  int index;
  Map<String, dynamic> managedComponent;

  ComponentManagerCall(this.component, this.index, this.managedComponent);
}

void main() {
  group('Given a RendererJS object', () {
    final viewId = 'viewId';

    group('When doFullRender', () {
      final beagleJSEngine = MockBeagleJSEngine();
      final tree = BeagleUIElement({'_beagleComponent_': 'beagle:button', 'text': 'Click me!'});
      final renderer = RendererJS(beagleJSEngine, viewId);

      group('When doFullRender is called', () {
        test('Then it should do full render', () {
          renderer.doFullRender(tree);
          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.single,
              "global.beagle.getViewById('$viewId').getRenderer().doFullRender(${jsonEncode(tree.properties)})");
        });
      });

      group('When doFullRender is called passing an anchor', () {
        test('Then it should do full render by replacing a branch of the tree', () {
          renderer.doFullRender(tree, 'elementId');
          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.single,
              "global.beagle.getViewById('$viewId').getRenderer().doFullRender(${jsonEncode(tree.properties)}, 'elementId')");
        });
      });

      group('When doFullRender is called passing an anchor and append mode', () {
        test('Then it should do full render by appending an element to a branch of the tree', () {
          renderer.doFullRender(tree, 'elementId', TreeUpdateMode.append);
          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.single,
              "global.beagle.getViewById('$viewId').getRenderer().doFullRender(${jsonEncode(tree.properties)}, 'elementId', 'append')");
        });
      });

      group('When doPartialRender is called', () {
        test('Then it should do partial render', () {
          final tree = BeagleUIElement({'_beagleComponent_': 'beagle:button', 'id': 'beagle1', 'text': 'Click me!'});
          renderer.doPartialRender(tree);
          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.single,
              "global.beagle.getViewById('$viewId').getRenderer().doPartialRender(${jsonEncode(tree.properties)})");
        });
      });

      group('When doPartialRender is called passing an anchor', () {
        test('Then it should do partial render by replacing a branch of the tree', () {
          renderer.doPartialRender(tree, 'elementId');
          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.single,
              "global.beagle.getViewById('$viewId').getRenderer().doPartialRender(${jsonEncode(tree.properties)}, 'elementId')");
        });
      });

      group('Is called passing an anchor and prepend mode', () {
        test('Should do full partial by prepending an element to a branch of the tree', () {
          renderer.doPartialRender(tree, 'elementId', TreeUpdateMode.prepend);
          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.single,
              "global.beagle.getViewById('$viewId').getRenderer().doPartialRender(${jsonEncode(tree.properties)}, 'elementId', 'prepend')");
        });
      });
    });

    group('When doTemplateRender', () {
      final beagleJSEngine = MockBeagleJSEngine();
      final viewId = 'viewId';
      final templateRenderer = RendererJS(beagleJSEngine, viewId);
      final templatesContainerId = 'templatesContainerId';
      final defaultText = BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text': "This is @{item.name} which lives at @{item.address.street}, @{item.address.number}"
      });
      final maleText = BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text': "This is @{item.name} and HE lives at @{item.address.street}, @{item.address.number}"
      });
      final femaleText = BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text': "This is @{item.name} and SHE lives at @{item.address.street}, @{item.address.number}"
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
            value: 'undefined',
          ),
          BeagleDataContext(
            id: 'sex',
            value: 'U',
          ),
          BeagleDataContext(
            id: 'address',
            value: {'street': 'undefined', 'number': 'undefined'},
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

      final getJsTreeUpdateModeName = (TreeUpdateMode mode) => mode.toString().split('.')[1];

      final getDoTemplateJS = (List<String> arguments) =>
          "global.beagle.getViewById('$viewId').getRenderer().doTemplateRender(${arguments.join(", ")})";

      final callDoTemplateRender = (
        TemplateManager templateManager,
        String anchor,
        List<List<BeagleDataContext>> contexts, {
        BeagleUIElement Function(BeagleUIElement, int)? componentManager,
        TreeUpdateMode? mode,
      }) =>
          templateRenderer.doTemplateRender(
            templateManager: templateManager,
            anchor: templatesContainerId,
            contexts: dataSource,
            componentManager: componentManager,
            mode: mode,
          );

      final getDoTemplateRenderJsArguments = (
        TemplateManager templateManager,
        String anchor,
        List<List<BeagleDataContext>> contexts, {
        TreeUpdateMode? mode,
      }) =>
          [
            jsonEncode(templateManager.toJson()),
            "'$anchor'",
            jsonEncode(contexts),
            "null",
            "'${getJsTreeUpdateModeName(mode ?? TreeUpdateMode.replace)}'",
          ];

      group('Is called with only one template without case', () {
        reset(beagleJSEngine);

        test('Then it should render using this as default template without templates', () {
          final templateManager = TemplateManager(defaultTemplate: defaultText, templates: []);

          callDoTemplateRender(templateManager, templatesContainerId, dataSource);
          final arguments = getDoTemplateRenderJsArguments(templateManager, templatesContainerId, dataSource);

          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.last, getDoTemplateJS(arguments));
        });
      });

      group('Is called with more than one template', () {
        reset(beagleJSEngine);

        test('Then it should render a template using the templates that match the conditions', () {
          callDoTemplateRender(templateManagerWithCases, templatesContainerId, dataSource);
          final arguments = getDoTemplateRenderJsArguments(templateManagerWithCases, templatesContainerId, dataSource);

          expect(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured.last, getDoTemplateJS(arguments));
        });
      });

      group('Is called with a componentManager', () {
        reset(beagleJSEngine);
        registerMocktailFallbacks();

        int evaluateJsCodeCalledTimes = 0;
        final globalRender = "global.beagle.render";
        final globalContexts = [
          {
            "id": "global",
            "value": {
              "prop": "value of the prop",
            },
          },
          {
            "id": "anotherContext",
            "value": {
              "attr": "attr value",
            },
          },
        ];
        final evaluateJsCodeCaptures = List<dynamic>.empty(growable: true);
        final componentManagerCalls = List<ComponentManagerCall>.empty(growable: true);

        final getEvaluateRenderJsCode =
            (String functionName, String arguments) => "$globalRender.$functionName($arguments)";

        final getConditionalTemplate = (String gender) {
          switch (gender) {
            case 'M':
              return maleText;
            case 'F':
              return femaleText;
            default:
              return defaultText;
          }
        };

        final getTemplateArgs = (int index) => [
              "'$viewId'",
              json.encode([...dataSource[index], ...globalContexts]),
              json.encode(templateManagerWithCases.toJson()),
            ];

        final getClonedTemplateToPreProcess = (Map<String, dynamic> template, int index) => {
              ...template,
              "id": "_person:${dataSource[index][1].value}:${index + 1}_",
              "_implicitContexts_": dataSource[index],
            };

        final jsCodeList = List<JsCodeExpectedCall>.empty(growable: true);
        final contextTemplates = List<Map<String, dynamic>>.empty(growable: true);

        final addToJsCodeList = (String argument, JsEvalResult response) {
          jsCodeList.add(JsCodeExpectedCall(argument, response));
        };

        addToJsCodeList(
          "$globalRender.getTreeContextHierarchy('$viewId')",
          JsEvalResult(json.encode(globalContexts), ''),
        );

        final getEvaluatedTemplate = (String templateEncoded) => JsEvalResult(templateEncoded, '');

        final componentManager = (BeagleUIElement element, int index) {
          final componentManagerCall = ComponentManagerCall({...element.properties}, index, {});

          element.setId("_person:${dataSource[index][1].value}:${index + 1}_");

          componentManagerCall.managedComponent = {...element.properties};
          componentManagerCalls.add(componentManagerCall);

          return element;
        };

        for (int i = 0; i < dataSource.length; i++) {
          final templateArgs = getTemplateArgs(i);
          final template = getConditionalTemplate(dataSource[i][1].value).properties;
          final templateEncoded = json.encode(template);
          final clonedTemplateToPreProcess = getClonedTemplateToPreProcess(template, i);
          final clonedTemplateToPreProcessEncoded = json.encode(clonedTemplateToPreProcess);

          addToJsCodeList(
            getEvaluateRenderJsCode('getContextEvaluatedTemplate', templateArgs.join(', ')),
            getEvaluatedTemplate(templateEncoded),
          );

          addToJsCodeList(
            getEvaluateRenderJsCode('cloneTemplate', templateEncoded),
            getEvaluatedTemplate(templateEncoded),
          );

          addToJsCodeList(
            getEvaluateRenderJsCode('preProcessTemplateTree', clonedTemplateToPreProcessEncoded),
            JsEvalResult(clonedTemplateToPreProcessEncoded, ''),
          );

          contextTemplates.add(clonedTemplateToPreProcess);
        }

        final doTreeRenderArgs = [
          "'$viewId'",
          "'$templatesContainerId'",
          json.encode(contextTemplates),
          "'${getJsTreeUpdateModeName(TreeUpdateMode.replace)}'",
        ];
        addToJsCodeList(
          getEvaluateRenderJsCode('doTreeFullRender', doTreeRenderArgs.join(', ')),
          JsEvalResult('', ''),
        );

        when(() => beagleJSEngine.evaluateJsCode(any())).thenAnswer(
          (_) => (Invocation code) {
            evaluateJsCodeCalledTimes += 1;
            final jsCode = code.positionalArguments[0] as String;
            final jsEvalResult = jsCodeList.firstWhere((element) => element.argument == jsCode).response;
            return jsEvalResult;
          }(_),
        );

        callDoTemplateRender(
          templateManagerWithCases,
          templatesContainerId,
          dataSource,
          componentManager: componentManager,
        );

        evaluateJsCodeCaptures.addAll(verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured);

        test('Then it should have called beagleJSEngine.evaluateJsCode: 8 times', () {
          expect(evaluateJsCodeCalledTimes, 8);
        });

        test('Then it should have called the component manager: 3 times (one for each dataSource item)', () {
          expect(componentManagerCalls.length, 3);
        });

        test('Then it should have called to get the Global Contexts Hierarchy', () {
          expect(evaluateJsCodeCaptures.first, getEvaluateRenderJsCode('getTreeContextHierarchy', "'$viewId'"));
        });

        group('Is called on each item of dataSource', () {
          //FIRST
          test('Then it should get the right template, evaluated, for the first context', () {
            expect(
              evaluateJsCodeCaptures.elementAt(1),
              getEvaluateRenderJsCode('getContextEvaluatedTemplate', getTemplateArgs(0).join(', ')),
            );
          });

          test('Then it should call the componentManager for the first context', () {
            final template = getConditionalTemplate(dataSource[0][1].value).properties;
            expect(componentManagerCalls[0].index, 0);
            expect(componentManagerCalls[0].component, template);
            expect(componentManagerCalls[0].managedComponent, {
              ...template,
              "id": "_person:${dataSource[0][1].value}:${1}_",
            });
          });

          test('Then it should pre process the cloned template, for the first context', () {
            final template = getConditionalTemplate(dataSource[0][1].value).properties;
            final clonedTemplateToPreProcess = getClonedTemplateToPreProcess(template, 0);
            expect(
              evaluateJsCodeCaptures.elementAt(2),
              getEvaluateRenderJsCode('preProcessTemplateTree', json.encode(clonedTemplateToPreProcess)),
            );
          });

          //SECOND
          test('Then it should get the right template, evaluated, for the second context', () {
            expect(
              evaluateJsCodeCaptures.elementAt(3),
              getEvaluateRenderJsCode('getContextEvaluatedTemplate', getTemplateArgs(1).join(', ')),
            );
          });

          test('Then it should call the componentManager for the second context', () {
            final template = getConditionalTemplate(dataSource[1][1].value).properties;
            expect(componentManagerCalls[1].index, 1);
            expect(componentManagerCalls[1].component, template);
            expect(componentManagerCalls[1].managedComponent, {
              ...template,
              "id": "_person:${dataSource[1][1].value}:${2}_",
            });
          });

          test('Then it should pre process the cloned template, for the second context', () {
            final template = getConditionalTemplate(dataSource[1][1].value).properties;
            final clonedTemplateToPreProcess = getClonedTemplateToPreProcess(template, 1);
            expect(
              evaluateJsCodeCaptures.elementAt(4),
              getEvaluateRenderJsCode('preProcessTemplateTree', json.encode(clonedTemplateToPreProcess)),
            );
          });

          //THIRD
          test('Then it should get the right template, evaluated, for the third context', () {
            expect(
              evaluateJsCodeCaptures.elementAt(5),
              getEvaluateRenderJsCode('getContextEvaluatedTemplate', getTemplateArgs(2).join(', ')),
            );
          });

          test('Then it should call the componentManager for the third context', () {
            final template = getConditionalTemplate(dataSource[2][1].value).properties;
            expect(componentManagerCalls[2].index, 2);
            expect(componentManagerCalls[2].component, template);
            expect(componentManagerCalls[2].managedComponent, {
              ...template,
              "id": "_person:${dataSource[2][1].value}:${3}_",
            });
          });

          test('Then it should pre process the cloned template, for the third context', () {
            final template = getConditionalTemplate(dataSource[2][1].value).properties;
            final clonedTemplateToPreProcess = getClonedTemplateToPreProcess(template, 2);
            expect(
              evaluateJsCodeCaptures.elementAt(6),
              getEvaluateRenderJsCode('preProcessTemplateTree', json.encode(clonedTemplateToPreProcess)),
            );
          });
        });

        test('Then it should call the bridge helper, doTreeFullRender, with the pre processed templates', () {
          final contextTemplates = List<Map<String, dynamic>>.empty(growable: true);
          for (int i = 0; i < dataSource.length; i++) {
            final template = getConditionalTemplate(dataSource[i][1].value).properties;
            contextTemplates.add(getClonedTemplateToPreProcess(template, i));
          }

          final doTreeRenderArgs = [
            "'$viewId'",
            "'$templatesContainerId'",
            json.encode(contextTemplates),
            "'${getJsTreeUpdateModeName(TreeUpdateMode.replace)}'",
          ];
          expect(
            evaluateJsCodeCaptures.elementAt(7),
            getEvaluateRenderJsCode('doTreeFullRender', doTreeRenderArgs.join(', ')),
          );
        });
      });

      group('Is called without a componentManager and mode', () {
        reset(beagleJSEngine);

        test('Then it should render the tree using the templates that match the conditions', () async {
          callDoTemplateRender(templateManagerWithCases, templatesContainerId, dataSource, mode: TreeUpdateMode.append);
          final arguments = getDoTemplateRenderJsArguments(
            templateManagerWithCases,
            templatesContainerId,
            dataSource,
            mode: TreeUpdateMode.append,
          );

          final captured = verify(() => beagleJSEngine.evaluateJsCode(captureAny())).captured;
          expect(captured.single, getDoTemplateJS(arguments));
        });
      });
    });
  });
}
