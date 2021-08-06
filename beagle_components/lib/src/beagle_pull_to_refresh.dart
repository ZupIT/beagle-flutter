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

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

