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

import 'package:beagle/beagle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'internal/beagle_refresh_indicator.dart';

/// Defines a pull down to refresh for its child
/// You can define a child content for this widget and
/// whenever the user scrolls down, calls the function "onPull" to update the child content
class PullToRefresh extends StatefulWidget {
  const PullToRefresh({
    Key key,
    @required this.onPull,
    this.isRefreshing,
    this.color,
    @required this.child,
  }) : super(key: key);

  /// Function called when the user scrolls down the content
  /// This is required
  final Function onPull;

  /// Defines if the the refresh indicator should be running
  final bool isRefreshing;

  /// The progress indicator's foreground color. The current theme's
  /// [ColorScheme.primary] by default.
  final String color;

  /// The content to be rendered
  final Widget child;

  @override
  _BeaglePullToRefresh createState() => _BeaglePullToRefresh();

}

class _BeaglePullToRefresh extends State<PullToRefresh> {

  @override
  Widget build(BuildContext context) {
    /*
      We had to implement the component below based on flutters´s RefreshIndicator widget.
      The reason is that Beagle needed the isRefreshing property below
      @see https://github.com/flutter/flutter/issues/40235
      FIXME change the component below once the mentioned issue is closed
     */
    return BeagleRefreshIndicator(
      color: HexColor(widget.color),
      child: _buildScrollableContent(),
      onRefresh: _onRefreshHandler,
      isRefreshing: widget.isRefreshing,
    );
  }

  Widget _buildScrollableContent() {
    return _isScrollable(widget.child) ? widget.child : ListView(
        children: [widget.child],
        scrollDirection: Axis.vertical
    );
  }

  bool _isScrollable(Widget widget) => widget is ScrollView || widget is SingleChildScrollView;

  Future<void> _onRefreshHandler() async {
      widget.onPull();
  }
}
