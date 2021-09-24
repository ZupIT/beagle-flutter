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
import 'package:flutter/widgets.dart';
import 'bridge_impl/beagle_view_js.dart';
import 'service_locator.dart';

// TODO: THE UNIT TEST WILL BE WRITE AFTER RESOLVE DEPENDENCY INJECTION
/// A widget that displays content of Beagle. Attention: This component assumes the dependency BeagleService is ready to
/// use. To make sure it's ready, call `await beagleServiceLocator.allReady()`.
class BeagleWidget extends StatefulWidget {
  BeagleWidget(this.navigator) : view = beagleServiceLocator<BeagleViewJS>(param1: navigator);

  final BeagleNavigator navigator;
  final BeagleView view;

  @override
  _BeagleWidget createState() => _BeagleWidget();
}

class _BeagleWidget extends State<BeagleWidget> {
  final logger = beagleServiceLocator<BeagleLogger>();
  final environment = beagleServiceLocator<BeagleEnvironment>();
  final beagleService = beagleServiceLocator<BeagleService>();
  Widget widgetState;

  Widget _buildViewFromTree(BeagleUIElement tree) {
    final widgetChildren = tree.getChildren().map(_buildViewFromTree).toList();
    final builder = beagleService.components[tree.getType().toLowerCase()];
    if (builder == null) {
      logger.error("Can't find builder for component ${tree.getType()}");
      return BeagleUndefinedWidget(environment: environment);
    }
    try {
      return builder(tree, widgetChildren, widget.view);
    } catch (error) {
      logger.error("Could not build component ${tree.getType()} with id ${tree.getId()} due to the following error:");
      logger.error(error.toString());
      return BeagleUndefinedWidget(environment: environment);
    }
  }

  void _updateCurrentUI(BeagleUIElement tree) {
    if (tree != null) {
      setState(() => widgetState = _buildViewFromTree(tree));
    }
  }

  @override
  void dispose() {
    widget.view.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // setup actions
    widget.view.onAction(({action, element, view}) {
      final handler = beagleService.actions[action.getType().toLowerCase()];
      if (handler == null) {
        return logger.error("Couldn't find action with name ${action.getType()}. It will be ignored.");
      }
      handler(
        action: action,
        view: view,
        element: element,
        context: context,
      );
    });

    // update the UI everytime the beagle view changes
    widget.view.onChange(_updateCurrentUI);

    // first render:
    _updateCurrentUI(widget.view.getTree());
  }

  @override
  Widget build(BuildContext context) {
    return widgetState ?? const SizedBox.shrink();
  }
}
