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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:core';

import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:beagle_components/src/dynamic_list/flexible_list_view.dart';
import 'package:collection/collection.dart';

/// The component to generate GriView or ListView
class BeagleDynamicList extends StatefulWidget {
  const BeagleDynamicList({
    Key? key,
    this.onInit,
    this.direction,
    required this.dataSource,
    required this.templates,
    this.isScrollIndicatorVisible,
    this.scrollEndThreshold,
    this.iteratorName,
    this.identifierItem,
    this.onScrollEnd,
    this.children,
    this.spanCount,
    this.suffix,
    this.dataSourceKey,
    required this.view,
    required this.beagleId,
  }) : super(key: key);

  /// Optional function to run once the container is created
  final Function? onInit;

  /// Property responsible to customize all the flex attributes and general style configuration
  final BeagleDynamicListDirection? direction;

  /// dataSource it's an expression that points to a list of values used to populate the Widget.
  final List<dynamic> dataSource;

  /// dataSource it's an expression that points to a list of values used to populate the Widget.
  final List<TemplateManagerItem> templates;

  /// this attribute enables or disables the scroll bar.
  final bool? isScrollIndicatorVisible;

  /// sets the scrolled percentage of the list to trigger onScrollEnd.
  final int? scrollEndThreshold;

  /// is the context identifier of each cell.
  final String? iteratorName;

  /// Points to a unique value present in each item of the dataSource to be used as a suffix in the ids of the template components.
  final String? identifierItem;

  /// list of actions performed when the list is scrolled to the end.
  final Function? onScrollEnd;

  /// The number of columns or rows in the grid.
  final int? spanCount;

  /// Define a list of components to be displayed on this view.
  final List<Widget>? children;

  /// BeagleView that spawns this component
  final BeagleView view;

  /// id of the node that declares this component in Beagle
  final String beagleId;

  /// used for guaranteeing unique id's on multi leveled list/grid views
  final String? suffix;

  /// unique property in the data source to use as key for each element. The index will be used if not provided.
  final String? dataSourceKey;

  @override
  _BeagleDynamicList createState() => _BeagleDynamicList();
}

class _BeagleDynamicList extends State<BeagleDynamicList> with AfterLayoutMixin<BeagleDynamicList> {
  ScrollController? _scrollController;
  bool? _isExecutedActions;

  @override
  void didUpdateWidget(covariant BeagleDynamicList oldWidget) {
    _tryExecuteOnScrollEndActions();

    final oldDataSource = json.encode(oldWidget.dataSource);
    final newDataSource = json.encode(widget.dataSource);
    if (oldDataSource != newDataSource && mounted) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _doTemplateRender();
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.onInit != null) widget.onInit!();
    if (mounted) _doTemplateRender();
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
    return FlexibleListView(
      controller: _scrollController,
      useScrollbar: widget.isScrollIndicatorVisible ?? false,
      scrollDirection: _getScrollDirection(),
      itemBuilder: (buildContext, index) => widget.children![index],
      itemCount: widget.children?.length ?? 0,
      spanCount: widget.spanCount ?? 1,
    );
  }

  void _doTemplateRender() {
    if (_isDataSourceNullOrEmpty()) return;

    final templateManager = _getTemplateManager();
    final contexts = _getListBeagleDataContext();
    final renderer = widget.view.getRenderer();

    renderer.doTemplateRender(
      templateManager: templateManager,
      anchor: widget.beagleId,
      contexts: contexts,
      componentManager: _iterateComponent,
      mode: TreeUpdateMode.replace,
    );
  }

  TemplateManagerItem? _getDefaultTemplate() =>
      widget.templates.firstWhereOrNull((element) => element.condition == null || element.condition!.isEmpty);

  List<TemplateManagerItem> _getTemplatesWithoutDefault(TemplateManagerItem? templateDefault) {
    var templates = widget.templates;
    if (templateDefault != null) templates.remove(templateDefault);
    return templates;
  }

  TemplateManager _getTemplateManager() {
    final defaultTemplate = _getDefaultTemplate();
    final templates = _getTemplatesWithoutDefault(defaultTemplate);
    return TemplateManager(
      defaultTemplate: defaultTemplate?.view,
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

  String _getIterationKey(int index) =>
      widget.dataSourceKey == null ? '$index' : '${widget.dataSource[index][widget.dataSourceKey]}';

  String _getBaseId(String componentId, int componentIndex, String suffix) =>
      componentId.isNotEmpty ? "$componentId$suffix" : "${widget.beagleId}:$componentIndex";

  BeagleUIElement _iterateComponent(BeagleUIElement element, int indexElement) {
    element.forEach((node, indexComponent) => _changeIdAndAddSuffixIfNecessary(node, indexElement, indexComponent));
    return element;
  }

  bool _shouldAddSuffix(String beagleComponent) =>
      ['beagle:listview', 'beagle:gridview'].contains(beagleComponent.toLowerCase());

  void _changeIdAndAddSuffixIfNecessary(Map<String, dynamic> component, int indexElement, int indexComponent) {
    final iterationKey = _getIterationKey(indexElement);
    final suffix = widget.suffix ?? '';
    final baseId = _getBaseId(component['id'] ?? '', indexComponent, suffix);
    final shouldAddSuffix = _shouldAddSuffix(component['_beagleComponent_']);

    component['id'] = '$baseId:$iterationKey';

    if (shouldAddSuffix) {
      component['__suffix__'] = '$suffix:$iterationKey';
    }
  }

  bool _isChildrenNotNullAndNotEmpty() => widget.children != null && (widget.children?.isNotEmpty ?? false);

  bool _isDataSourceNullOrEmpty() => widget.dataSource.isEmpty;

  void _checkIfNeedToCallScrollEndActions() {
    if (!(_isExecutedActions ?? false) && _getPercentageScrolled() >= (widget.scrollEndThreshold ?? 0)) {
      _scrollController?.dispose();
      _isExecutedActions = true;
      if (widget.onScrollEnd != null) widget.onScrollEnd!();
    }
  }

  double _getPercentageScrolled() {
    double offset = _scrollController?.offset ?? 0;
    double maxScrollExtent = _scrollController?.position.maxScrollExtent ?? 0;

    if (maxScrollExtent == 0) return 100;

    return 100 * offset / maxScrollExtent;
  }

  void _addListenerToScrollController() {
    if (_hasScrollEnd()) _scrollController?.addListener(() => _checkIfNeedToCallScrollEndActions());
  }

  void _tryExecuteOnScrollEndActions() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (_hasScrollEnd() && _isChildrenNotNullAndNotEmpty()) _checkIfNeedToCallScrollEndActions();
    });
  }

  bool _hasScrollEnd() => widget.scrollEndThreshold != null && widget.onScrollEnd != null;

  Axis _getScrollDirection() => widget.direction?.axis ?? Axis.vertical;
}
