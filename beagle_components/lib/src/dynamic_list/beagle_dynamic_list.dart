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

/// A simple Wrapper to GriView or ListView
class BeagleDynamicList extends StatefulWidget {
  const BeagleDynamicList(
    Key key, {
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
    this.spanCount,
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

  /// The number of columns or rows in the grid.
  final int spanCount;

  /// Define a list of components to be displayed on this view.
  final List<Widget> children;

  @override
  _BeagleDynamicList createState() => _BeagleDynamicList();
}

class _BeagleDynamicList extends State<BeagleDynamicList>
    with AfterLayoutMixin<BeagleDynamicList> {
  ScrollController _scrollController;
  bool _isExecutedActions;

  @override
  void didUpdateWidget(covariant BeagleDynamicList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _doTemplateRender();

    tryExecuteOnScrollEndActions();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.onInit != null) widget.onInit();

    _doTemplateRender();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _isExecutedActions = false;

    _addListenerToScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isScrollIndicatorVisible != null &&
        widget.isScrollIndicatorVisible) {
      return getScrollBar();
    }

    return getDynamicList();
  }

  Widget getScrollBar() {
    return Scrollbar(
      child: getDynamicList(),
      isAlwaysShown: true,
    );
  }

  Widget getDynamicList() {
    return widget.spanCount != null ? _getGridView() : _getListView();
  }

  Widget _getListView() {
    return ListView(
      controller: _scrollController,
      scrollDirection: widget.direction.axis ?? Axis.vertical,
      children: widget.children ?? [],
    );
  }

  Widget _getGridView() {
    return GridView.count(
      controller: _scrollController,
      scrollDirection: widget.direction.axis ?? Axis.vertical,
      crossAxisCount: widget.spanCount ?? 1,
      children: widget.children,
    );
  }

  void _doTemplateRender() {
    if (_isChildrenNotNullAndNotEmpty() || _isDataSourceNullOrEmpty()) {
      return;
    }

    final templateManager = _getTemplateManager();
    final contexts = _getListBeagleDataContext();
    final anchor = _getAnchor();

    final beagleWidget = BeagleWidget.of(context);
    beagleWidget.view.getRenderer().doTemplateRender(
          templateManager: templateManager,
          anchor: anchor,
          contexts: contexts,
          componentManager: handleComponentManager,
          mode: null,
        );
  }

  TemplateManagerItem _getDefaultTemplate() {
    return widget.templates.firstWhere((element) => element.condition == null);
  }

  List<TemplateManagerItem> _getTemplatesWithoutDefault(
      TemplateManagerItem templateDefault) {
    var templates = widget.templates;
    templates.remove(templateDefault);
    return templates;
  }

  TemplateManager _getTemplateManager() {
    final defaultTemplate = _getDefaultTemplate();

    var templates = _getTemplatesWithoutDefault(defaultTemplate);
    return TemplateManager(
      defaultTemplate: defaultTemplate.view,
      templates: templates,
    );
  }

  List<List<BeagleDataContext>> _getListBeagleDataContext() {
    return widget.dataSource
        .map((item) =>
            [BeagleDataContext(id: widget.iteratorName ?? 'item', value: item)])
        .toList();
  }

  String _getAnchor() {
    final ValueKey<String> key =
        (widget.key is ValueKey<String>) ? context.widget.key : ValueKey('');
    return key.value;
  }

  BeagleUIElement handleComponentManager(BeagleUIElement component, int index) {
    final test = {'component': component, index: index};
    // BeagleUIElement innerHandleComponentManager(
    //   BeagleUIElement component,
    //   int index,
    // ) {
    //   /// TODO IMPLEMENT
    //   return component;
    // }

    return test['component'];
  }

  bool _isChildrenNotNullAndNotEmpty() {
    return widget.children != null && widget.children.isNotEmpty;
  }

  bool _isDataSourceNullOrEmpty() {
    return widget.dataSource == null || widget.dataSource.isEmpty;
  }

  void _checkIfNeedToCallScrollEndActions() {
    if (!_isExecutedActions &&
        _getPercentageScrolled() >= widget.scrollEndThreshold) {
      _scrollController.dispose();
      _isExecutedActions = true;
      widget.onScrollEnd();
    }
  }

  double _getPercentageScrolled() {
    double offset = _scrollController.offset;
    double maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (maxScrollExtent == 0) return 100;

    final percentage = 100 * offset / maxScrollExtent;
    beagleServiceLocator.get<BeagleLogger>().info("percentage: $percentage");

    return percentage;
  }

  void _addListenerToScrollController() {
    if (_hasScrollEnd()) {
      _scrollController.addListener(() {
        _checkIfNeedToCallScrollEndActions();
      });
    }
  }

  void tryExecuteOnScrollEndActions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasScrollEnd() && _isChildrenNotNullAndNotEmpty()) {
        _checkIfNeedToCallScrollEndActions();
      }
    });
  }

  bool _hasScrollEnd() {
    return widget.scrollEndThreshold != null && widget.onScrollEnd != null;
  }
}
