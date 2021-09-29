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

/// The component to generate GriView or ListView
class BeagleDynamicList extends StatefulWidget {
  const BeagleDynamicList({
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
    this.spanCount,
    this.suffix,
    this.beagleWidgetStateProvider,
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

  final String suffix;

  final BeagleWidgetStateProvider beagleWidgetStateProvider;

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

    _tryExecuteOnScrollEndActions();
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
    if (isScrollIndicatorEnabled()) {
      return _getScrollBar();
    }

    return _getDynamicList();
  }

  Widget _getScrollBar() {
    return Scrollbar(
      child: _getDynamicList(),
      isAlwaysShown: true,
      controller: _scrollController,
    );
  }

  Widget _getDynamicList() {
    return _isNotGridView() ? _getListView() : _getGridView();
  }

  Widget _getListView() {
    return ListView(
      controller: _scrollController,
      scrollDirection: _getScrollDirection(),
      children: widget.children ?? [],
    );
  }

  Widget _getGridView() {
    return GridView.count(
      controller: _scrollController,
      scrollDirection: _getScrollDirection(),
      crossAxisCount: widget.spanCount,
      children: widget.children ?? [],
    );
  }

  void _doTemplateRender() {
    if (_isChildrenNotNullAndNotEmpty() || _isDataSourceNullOrEmpty()) {
      return;
    }

    final templateManager = _getTemplateManager();
    final contexts = _getListBeagleDataContext();
    final anchor = _getAnchor();

    final beagleWidgetState = widget.beagleWidgetStateProvider.of(context);

    beagleWidgetState.getView().getRenderer().doTemplateRender(
          templateManager: templateManager,
          anchor: anchor,
          contexts: contexts,
          componentManager: _iterateComponent,
          mode: TreeUpdateMode.replace,
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
        .map((item) => [
              BeagleDataContext(
                id: widget.iteratorName ?? 'item',
                value: item,
              )
            ])
        .toList();
  }

  String _getAnchor() {
    final ValueKey<String> key =
        (widget.key is ValueKey<String>) ? context.widget.key : ValueKey('');
    return key.value;
  }


  String _getIterationKey(int index) {
    String valueInIteratorNameInDataSource;
    try {
      final value = widget.dataSource[index][widget.iteratorName];
      valueInIteratorNameInDataSource = value ? value : null;
    } catch (_) {}
    final hasKey =
        widget.iteratorName != null && widget.iteratorName.isNotEmpty;

    return hasKey && valueInIteratorNameInDataSource != null
        ? valueInIteratorNameInDataSource
        : index.toString();
  }

  String _getBaseId(String componentId, int componentIndex, String suffix) {
    return componentId.isNotEmpty
        ? "$componentId$suffix"
        : "${_getAnchor()}:$componentIndex";
  }

  BeagleUIElement _iterateComponent(BeagleUIElement element, int indexElement) {
    if (element.hasChildren()) {
      for (var indexComponent = 0;
          indexComponent < element.getChildren().length;
          indexComponent++) {
        final component = element.getChildren()[indexComponent];
        _changeIdAndAddSuffixIfNecessary(
            component, indexElement, indexComponent);

        _iterateComponent(component, indexElement);
      }
    }

    return element;
  }

  void _changeIdAndAddSuffixIfNecessary(
      BeagleUIElement component, int indexElement, int indexComponent) {
    final iterationKey = _getIterationKey(indexElement);

    final suffix = widget.suffix ?? '';
    final baseId = _getBaseId(
      component.getId() ?? '',
      indexComponent,
      suffix,
    );

    final hasSuffix = ['beagle:listview', 'beagle:gridview']
        .contains(component.getType().toLowerCase());

    component.setId("$baseId:$iterationKey");

    if (hasSuffix) {
      component.properties['__suffix__'] = "$suffix:$iterationKey";
    }
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

    return 100 * offset / maxScrollExtent;
  }

  void _addListenerToScrollController() {
    if (_hasScrollEnd()) {
      _scrollController.addListener(() {
        _checkIfNeedToCallScrollEndActions();
      });
    }
  }

  void _tryExecuteOnScrollEndActions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasScrollEnd() && _isChildrenNotNullAndNotEmpty()) {
        _checkIfNeedToCallScrollEndActions();
      }
    });
  }

  bool _hasScrollEnd() {
    return widget.scrollEndThreshold != null && widget.onScrollEnd != null;
  }

  bool _isNotGridView() {
    return widget.spanCount == null || widget.spanCount <= 1;
  }

  Axis _getScrollDirection() {
    return widget.direction.axis ?? Axis.vertical;
  }

  bool isScrollIndicatorEnabled() {
    return widget.isScrollIndicatorVisible != null &&
        widget.isScrollIndicatorVisible;
  }
}
