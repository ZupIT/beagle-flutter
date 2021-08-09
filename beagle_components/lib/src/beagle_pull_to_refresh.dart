import 'package:beagle/beagle.dart';
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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {


    final refresh = RefreshIndicator(
      key: _refreshIndicatorKey,
      color: HexColor(widget.color),
      child: _buildScrollableContent(),
      onRefresh: _onRefreshHandler,
    );

    //TODO test this scenario
    SchedulerBinding.instance.addPostFrameCallback((_){
      if(widget.isRefreshing) {
        _refreshIndicatorKey.currentState?.show();
      } else {
        _refreshIndicatorKey.currentState?.deactivate();
      }
    });

    return refresh;
  }

  Widget _buildScrollableContent() {
    return isScrollable(widget.child) ? widget.child : ListView(
        children: [widget.child],
        scrollDirection: Axis.vertical
    );
  }

  bool isScrollable(Widget widget) => widget is ScrollView || widget is SingleChildScrollView;

  Future<void> _onRefreshHandler() async {
    print("onPull");
    widget.onPull();
  }
}
