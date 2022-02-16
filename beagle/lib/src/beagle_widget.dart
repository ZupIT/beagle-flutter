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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// TODO: THE UNIT TESTS WILL BE WRITTEN AFTER RESOLVING THE DEPENDENCY INJECTION
/// A widget that displays content of beagle.
class BeagleWidget extends StatefulWidget {
  BeagleWidget(this.view);

  final BeagleView view;

  @override
  BeagleWidgetState createState() => BeagleWidgetState();
}

class BeagleWidgetState extends State<BeagleWidget> with BeagleConsumer {
  Widget? _widgetState;

  /* this builds the widget tree while also filling a map (componentToNodeData) that links each component (by id) to
  its NodeData.*/
  Widget _buildViewFromTree(BeagleUIElement tree, Map<String, BeagleNodeData> componentToNodeData) {
    final componentChildren = tree.getChildren().map((child) => _buildViewFromTree(child, componentToNodeData)).toList();
    final builder = beagle.components[tree.getType().toLowerCase()];
    if (builder == null) {
      beagle.logger.error("Can't find builder for component ${tree.getType()}");
      return BeagleUndefinedWidget(environment: beagle.environment);
    }
    try {
      if (componentToNodeData.containsKey(tree.getId())) {
        throw ErrorDescription('Error: found replicated id in the UI tree: ${tree.getId()}.');
      }
      componentToNodeData[tree.getId()] = BeagleNodeData(tree, componentChildren, widget.view);
      return BeagleNode(id: tree.getId(), child: builder());
    } catch (error) {
      beagle.logger.error("Could not build component ${tree.getType()} with id ${tree.getId()} due to the following error:");
      beagle.logger.error(error.toString());
      return BeagleUndefinedWidget(environment: beagle.environment);
    }
  }

  void _updateCurrentUI(BeagleUIElement? tree) {
    if (tree != null) {
      final componentToNodeData = <String, BeagleNodeData>{};
      final widgetTree = _buildViewFromTree(tree, componentToNodeData);
      final flutterTree = BeagleRootNode(child: widgetTree, componentToNodeData: componentToNodeData);
      setState(() => _widgetState = BeagleFlexWidget([flutterTree]));
    }
  }

  @override
  void dispose() {
    widget.view.destroy();
    super.dispose();
  }

  @override
  void initBeagleState() {
    // setup actions
    widget.view.onAction(({required action, required element, required view}) {
      final handler = beagle.actions[action.getType().toLowerCase()];
      if (handler == null) {
        return beagle.logger.error("Couldn't find action with name ${action.getType()}. It will be ignored.");
      }
      handler(action: action, view: view, element: element, context: context);
    });

    // update the UI everytime the beagle view changes
    widget.view.onChange(_updateCurrentUI);

    // first render:
    final tree = widget.view.getTree();
    if (tree != null) {
      widget.view.getRenderer().doFullRender(tree);
    }
  }

  @override
  Widget buildBeagleWidget(BuildContext context) {
    return _widgetState ?? const SizedBox.shrink();
  }
}
