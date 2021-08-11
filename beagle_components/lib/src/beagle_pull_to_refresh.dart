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
import 'dart:io';

import 'package:beagle/beagle.dart';
import 'package:beagle_components/src/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class PullToRefresh extends StatefulWidget {
  const PullToRefresh({
    Key key,
    this.onPull,
    this.isRefreshing,
    this.color,
    this.child,
  }) : super(key: key);

  final Function onPull;

  final bool isRefreshing;

  final String color;

  final Widget child;

  @override
  _BeaglePullToRefresh createState() => _BeaglePullToRefresh();

}

class _BeaglePullToRefresh extends State<PullToRefresh> {

  final GlobalKey<CustomRefreshIndicatorState> _refreshIndicatorKey = GlobalKey<CustomRefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {

    /*
      FIXME https://github.com/flutter/flutter/issues/40235
      The method show is calling the onRefresh callback
     */
    SchedulerBinding.instance.addPostFrameCallback((_){
      if(widget.isRefreshing) {
          _refreshIndicatorKey.currentState?.showProgress();
      } else {
        _refreshIndicatorKey.currentState?.hideProgress();
      }
    });

    return CustomRefreshIndicator(
      key: _refreshIndicatorKey,
      color: HexColor(widget.color),
      child: _buildScrollableContent(),
      onRefresh: _onRefreshHandler,
    );
  }

  Widget _buildScrollableContent() {
    return isScrollable(widget.child) ? widget.child : ListView(
        children: [widget.child],
        scrollDirection: Axis.vertical
    );
  }

  bool isScrollable(Widget widget) => widget is ScrollView || widget is SingleChildScrollView;

  Future<void> _onRefreshHandler() async {
      widget.onPull();
  }
}
