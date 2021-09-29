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
import 'package:beagle/src/after_beagle_initialization.dart';
import 'package:beagle/src/beagle_metadata_widget.dart';
import 'package:beagle/src/model/beagle_metadata.dart';
import 'package:flutter/widgets.dart';
import 'bridge_impl/beagle_view_js.dart';
import 'service_locator.dart';

typedef OnCreateViewListener = void Function(BeagleView view);

// TODO: THE UNIT TEST WILL BE WRITE AFTER RESOLVE DEPENDENCY INJECTION
/// A widget that displays content of beagle. Be aware that by using the BeagleWidget directly you won't be able
/// to control the navigation. Prefer using `RootNavigator` or `BeagleSdk.openScreen`.
class BeagleWidget extends StatefulWidget {
  BeagleWidget(this.onCreateView);

  final OnCreateViewListener onCreateView;

  @override
  _BeagleWidget createState() => _BeagleWidget();
}

class _BeagleWidget extends State<BeagleWidget> with AfterBeagleInitialization {
  bool _isViewCreated = false;

  @override
  Widget buildAfterBeagleInitialization(BuildContext context) {
    final unsafeBeagleWidget = UnsafeBeagleWidget(null);
    if (!_isViewCreated) {
      widget.onCreateView(unsafeBeagleWidget.view);
      _isViewCreated = true;
    }
    return unsafeBeagleWidget;
  }
}

/// The same as BeagleWidget, but it assumes the Beagle Service has already initialized. This is useful for components
/// like navigators, that are sure the Beagle Service has started and need direct access to the Beagle View. Prefer
/// using BeagleWidget for other cases.
class UnsafeBeagleWidget extends StatefulWidget {
  UnsafeBeagleWidget(this.navigator) : view = beagleServiceLocator<BeagleViewJS>(param1: navigator);

  final BeagleNavigator navigator;
  final BeagleView view;

  @override
  BeagleWidgetState createState() => BeagleWidgetState();
}

class BeagleWidgetState extends State<UnsafeBeagleWidget> {
  final _logger = beagleServiceLocator<BeagleLogger>();
  final _environment = beagleServiceLocator<BeagleEnvironment>();
  final _beagleService = beagleServiceLocator<BeagleService>();
  Widget _widgetState;

  Widget _buildViewFromTree(BeagleUIElement tree) {
    final widgetChildren = tree.getChildren().map(_buildViewFromTree).toList();
    final builder = _beagleService.components[tree.getType().toLowerCase()];
    if (builder == null) {
      _logger.error("Can't find builder for component ${tree.getType()}");
      return BeagleUndefinedWidget(environment: _environment);
    }
    try {
      return BeagleFlexWidget(children: [
        _createWidget(
            tree,
            builder(
              tree,
              widgetChildren,
              widget.view,
            ))
      ]);
    } catch (error) {
      _logger.error("Could not build component ${tree.getType()} with id ${tree.getId()} due to the following error:");
      _logger.error(error.toString());
      return BeagleUndefinedWidget(environment: _environment);
    }
  }

  Widget _createWidget(BeagleUIElement tree, Widget widget) {
    if (widget is BeagleRootFlexLayoutWidget) {
      return widget;
    } else {
      return BeagleMetadataWidget(
          child: widget,
          beagleMetadata: BeagleMetadata(beagleStyle: tree.getStyle()));
    }
  }

  void _updateCurrentUI(BeagleUIElement tree) {
    if (tree != null) {
      setState(() => _widgetState = _buildViewFromTree(tree));
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
      final handler = _beagleService.actions[action.getType().toLowerCase()];
      if (handler == null) {
        return _logger.error("Couldn't find action with name ${action.getType()}. It will be ignored.");
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

  BeagleView getView() {
    return widget.view;
  }

  @override
  Widget build(BuildContext context) {
    return _widgetState ?? const SizedBox.shrink();
  }
}
