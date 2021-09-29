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
import 'dart:convert';

import 'package:beagle/beagle.dart';
import 'package:beagle/src/beagle_metadata_widget.dart';
import 'package:beagle/src/model/beagle_metadata.dart';
import 'package:flutter/widgets.dart';
import 'bridge_impl/beagle_view_js.dart';
import 'service_locator.dart';

typedef OnCreateViewListener = void Function(BeagleView view);

/// TODO: THE UNIT TEST WILL BE WRITE AFTER RESOLVE DEPENDENCY INJECTION
/// A widget that displays content of beagle.
class BeagleWidget extends StatefulWidget {
  const BeagleWidget({
    Key key,
    this.onCreateView,
    this.screenJson,
    this.screenRequest,
  }) : super(key: key);

  /// that represents a local screen to be shown.
  final String screenJson;

  /// provides the url, method, headers and body to the request.
  final BeagleScreenRequest screenRequest;

  /// get a current BeagleView.
  final OnCreateViewListener onCreateView;

  @override
  _BeagleWidget createState() => _BeagleWidget();
}

class _BeagleWidget extends State<BeagleWidget> {
  BeagleView _view;
  Widget _widgetState;

  BeagleService _service;
  final _logger = beagleServiceLocator<BeagleLogger>();
  final _environment = beagleServiceLocator<BeagleEnvironment>();

  @override
  void initState() {
    super.initState();
    _startBeagleView();
  }

  @override
  void dispose() {
    _view.destroy();
    super.dispose();
  }

  Future<void> _startBeagleView() async {
    await beagleServiceLocator.allReady();
    _service = beagleServiceLocator<BeagleService>();
    _view = beagleServiceLocator<BeagleViewJS>(
      param1: widget.screenRequest,
    )
      ..subscribe((tree) {
        final widgetLoaded = _buildViewFromTree(tree);
        setState(() {
          _widgetState = widgetLoaded;
        });
      })
      ..onAction(({action, element, view}) {
        final handler = _service.actions[action.getType().toLowerCase()];
        if (handler == null) {
          return _logger.error(
              "Couldn't find action with name ${action.getType()}. It will be ignored.");
        }
        handler(
          action: action,
          view: view,
          element: element,
          context: context,
        );
      });

    if (widget.screenRequest != null) {
      await _view.getNavigator().pushView(RemoteView(widget.screenRequest.url));
    } else {
      await _view
          .getNavigator()
          .pushView(LocalView(BeagleUIElement(jsonDecode(widget.screenJson))));
    }
  }

  Widget _buildViewFromTree(BeagleUIElement tree) {
    final widgetChildren = tree.getChildren().map(_buildViewFromTree).toList();
    final builder = _service.components[tree.getType().toLowerCase()];
    if (builder == null) {
      _logger.error("Can't find builder for component ${tree.getType()}");
      return BeagleUndefinedWidget(environment: _environment);
    }
    try {
      return BeagleFlexWidget(children: [createWidget(tree, builder(tree, widgetChildren, _view))]);
    } catch (error) {
      _logger.error(
          'Could not build component ${tree.getType()} with id ${tree.getId()} due to the following error:');
      _logger.error(error.toString());
      return BeagleUndefinedWidget(environment: _environment);
    }
  }

  Widget createWidget(BeagleUIElement tree, Widget widget) {
      return BeagleMetadataWidget(child: widget, beagleMetadata: BeagleMetadata(beagleStyle: tree.getStyle()));
  }
  
  @override
  Widget build(BuildContext context) {
    return _widgetState ?? const SizedBox.shrink();
  }
}
