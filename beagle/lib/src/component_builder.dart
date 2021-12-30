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
import 'package:flutter/cupertino.dart';
import 'package:beagle/src/accessibility/accessibility_helper.dart';

abstract class ComponentBuilder extends StatelessWidget {
  Widget _applyStyles(Widget widget, BeagleNodeData data) {
    if (widget is Styled || widget is StatefulStyled) return widget;
    if (getStyleConfig()?.shouldExpand == true) return Expanded(child: widget);
    if (getStyleConfig()?.enabled == false) return widget;
    return Styled(children: [widget], style: data.element.getStyle(), styleConfig: getStyleConfig());
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    final beagleRootNode = BeagleRootNode.of(context);
    final beagleNode = BeagleNode.of(context);
    final beagleService = findBeagleService(context);
    if (beagleRootNode == null || beagleNode == null) {
      throw ErrorDescription('Cannot find InheritedWidget for component. This is probably a problem within the Beagle library. Please contact support.');
    }

    final data = beagleRootNode.componentToNodeData[beagleNode.id];
    if (data == null) {
      throw ErrorDescription('Cannot find data for component with id "${beagleNode.id}". This is probably a problem within the Beagle library itself. Please contact support.');
    }

    Widget widget = buildForBeagle(data.element, data.children, data.view);
    if (beagleService.enableStyles) {
      widget = _applyStyles(widget, data);
    }

    return applyAccessibility(widget, data.element.getAccessibility());
  }

  /// Return a StyleConfig to change the default behavior of the styling algorithm. This makes no difference if, in the
  /// Beagle configuration, `enableStyles` is false.
  StyleConfig? getStyleConfig() => null;

  Widget buildForBeagle(BeagleUIElement tree, List<Widget> componentChildren, BeagleView view);
}
