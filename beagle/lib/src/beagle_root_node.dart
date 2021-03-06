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
import 'package:flutter/cupertino.dart';

class BeagleNodeData {
  BeagleNodeData(this.element, this.children, this.view);
  final List<Widget> children;
  final BeagleUIElement element;
  final BeagleView view;
}

class BeagleRootNode extends InheritedWidget {
  BeagleRootNode({required this.componentToNodeData, required Widget child}): super(child: child);

  final Map<String, BeagleNodeData> componentToNodeData;

  @override
  bool updateShouldNotify(covariant BeagleRootNode oldWidget) =>
      oldWidget.componentToNodeData != componentToNodeData;

  static BeagleRootNode? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<BeagleRootNode>();
}
