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

import 'dart:async';
import 'dart:developer';

import 'package:beagle/beagle.dart';
import 'package:flutter/widgets.dart';
import 'bridge_impl/beagle_view_js.dart';
import 'service_locator.dart';

typedef OnCreateViewListener = void Function(BeagleView view);

/// TODO: THE UNIT TEST WILL BE WRITE AFTER RESOLVE DEPENDENCY INJECTION
/// A widget that displays content of beagle.
class BeagleWidget extends StatefulWidget {
  BeagleWidget({Key key, this.parentNavigator, this.onCreateView}) : super(key: key) {
    log("BEAGLE WIDGET: CONSTRUCTOR. Key: $key");
  }

  final BeagleNavigator parentNavigator; // optional
  final OnCreateViewListener onCreateView;

  @override
  _BeagleWidget createState() {
    log("BEAGLE WIDGET: CREATE STATE");
    return _BeagleWidget();
  }
}

class _BeagleWidget extends State<BeagleWidget> {
  Widget widgetState;
  BeagleView view;

  static BeagleService service;
  final logger = beagleServiceLocator<BeagleLogger>();
  final environment = beagleServiceLocator<BeagleEnvironment>();

  @override
  void initState() {
    super.initState();
    _startBeagleView();
  }

  @override
  void dispose() {
    view.destroy();
    super.dispose();
  }

  Future<void> _startBeagleView() async {
    log("BEAGLE WIDGET: STARTING VIEW");
    await beagleServiceLocator.allReady();
    log("BEAGLE WIDGET: BEAGLE SERVICE IS READY");
    service = beagleServiceLocator<BeagleService>();
    log("BEAGLE WIDGET: CREATING VIEW AND ASSIGNING LISTENERS");
    view = beagleServiceLocator<BeagleViewJS>(param1: widget.parentNavigator)
      ..onChange((tree) {
        final widgetLoaded = _buildViewFromTree(tree);
        setState(() {
          widgetState = widgetLoaded;
        });
      })
      ..onAction(({action, element, view}) {
        final handler = service.actions[action.getType().toLowerCase()];
        if (handler == null) {
          return logger.error(
              "Couldn't find action with name ${action.getType()}. It will be ignored.");
        }
        handler(
          action: action,
          view: view,
          element: element,
          context: context,
        );
      });
    log("BEAGLE WIDGET: VIEW IS CREATED, CALLING ONCREATEVIEW");
    if (widget.onCreateView != null) widget.onCreateView(view);
  }

  Widget _buildViewFromTree(BeagleUIElement tree) {
    final widgetChildren = tree.getChildren().map(_buildViewFromTree).toList();
    final builder = service.components[tree.getType().toLowerCase()];
    if (builder == null) {
      logger.error("Can't find builder for component ${tree.getType()}");
      return BeagleUndefinedWidget(environment: environment);
    }
    try {
      return builder(tree, widgetChildren, view);
    } catch (error) {
      logger.error(
          'Could not build component ${tree.getType()} with id ${tree.getId()} due to the following error:');
      logger.error(error.toString());
      return BeagleUndefinedWidget(environment: environment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widgetState ?? const SizedBox.shrink();
  }
}
