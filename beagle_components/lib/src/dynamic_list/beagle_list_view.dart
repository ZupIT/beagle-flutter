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

import 'dart:core';

import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The ListView component is responsible for defining a list
class BeagleListView extends StatelessWidget {
  const BeagleListView({
    Key key,
    this.onInit,
    this.direction,
    this.dataSource,
    this.templates,
    this.isScrollIndicatorVisible,
    this.scrollEndThreshold,
    this.iteratorName,
    this.identifierItem,
    this.onScrollEnd,
    this.children,
    this.suffix,
  }) : super(key: key);

  /// Optional function to run once the container is created
  final Function onInit;

  /// Property responsible to customize all the flex attributes and general style configuration
  final BeagleDynamicListDirection direction;

  /// dataSource it's an expression that points to a list of values used to populate the Widget.
  final List<dynamic> dataSource;

  /// dataSource it's an expression that points to a list of values used to populate the Widget.
  final List<TemplateManagerItem> templates;

  /// this attribute enables or disables the scroll bar.
  final bool isScrollIndicatorVisible;

  /// sets the scrolled percentage of the list to trigger onScrollEnd.
  final int scrollEndThreshold;

  /// is the context identifier of each cell.
  final String iteratorName;

  /// Points to a unique value present in each item of the dataSource to be used as a suffix in the ids of the template components.
  final String identifierItem;

  /// list of actions performed when the list is scrolled to the end.
  final Function onScrollEnd;

  /// Define a list of components to be displayed on this view.
  final List<Widget> children;

  /// TODO
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return BeagleDynamicList(
      key,
      onInit: onInit,
      direction: direction,
      dataSource: dataSource,
      templates: templates,
      isScrollIndicatorVisible: isScrollIndicatorVisible,
      scrollEndThreshold: scrollEndThreshold,
      iteratorName: iteratorName,
      identifierItem: identifierItem,
      onScrollEnd: onScrollEnd,
      children: children,
      suffix: suffix,
    );
  }
}
