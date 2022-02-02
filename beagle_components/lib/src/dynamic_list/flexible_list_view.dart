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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../after_layout.dart';

/// Creates a ListView/GridView, but it checks if it can expand into a Flex Layout. If it can, it wraps the ListView in
/// an Expanded widget. Otherwise, it shrinks the ListView to fit its content.
class FlexibleListView extends StatefulWidget {
  const FlexibleListView({
    required this.scrollDirection,
    this.controller,
    required this.itemBuilder,
    required this.itemCount,
    /// if spanCount is greater than 1, it renders a grid instead of a list
    this.spanCount = 1,
    this.useScrollbar = false,
    this.itemAspectRatio,
    Key? key
  }) : super(key: key);

  final ScrollController? controller;
  final Axis scrollDirection;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final bool useScrollbar;
  final int spanCount;
  final num? itemAspectRatio;

  @override
  _FlexibleListView createState() => _FlexibleListView();
}

class _FlexibleListView extends State<FlexibleListView> with AfterLayoutMixin {
  bool? isFlex;

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      isFlex = context.findRenderObject()?.parentData is FlexParentData;
    });
  }

  Widget _buildGridView() => GridView.builder(
    itemBuilder: widget.itemBuilder,
    controller: widget.controller,
    scrollDirection: widget.scrollDirection,
    itemCount: widget.itemCount,
    shrinkWrap: !isFlex!,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: widget.spanCount,
      childAspectRatio: widget.itemAspectRatio?.toDouble() ?? 1,
    ),
  );

  Widget _buildListView() => ListView.builder(
    itemBuilder: widget.itemBuilder,
    controller: widget.controller,
    scrollDirection: widget.scrollDirection,
    itemCount: widget.itemCount,
    shrinkWrap: !isFlex!,
  );

  @override
  Widget build(BuildContext context) {
    if (isFlex == null) return const SizedBox.shrink();

    Widget list = widget.spanCount > 1 ? _buildGridView() : _buildListView();

    if (widget.useScrollbar) {
      list = Scrollbar(
        child: list,
        isAlwaysShown: true,
        controller: widget.controller,
      );
    }

    return isFlex! ? Expanded(child: list) : list;
  }
}
