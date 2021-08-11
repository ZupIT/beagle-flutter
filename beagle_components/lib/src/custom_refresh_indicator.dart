// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The signature for a function that's called when the user has dragged a
/// [CustomRefreshIndicator] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [CustomRefreshIndicator.onRefresh].
// typedef RefreshCallback = Future<void> Function();

// The state machine moves through these modes only when the scrollable
// identified by scrollableKey has been scrolled to its min or max limit.
enum _RefreshIndicatorMode {
  drag,     // Pointer is down.
  armed,    // Dragged far enough that an up event will run the onRefresh callback.
  snap,     // Animating to the indicator's final "displacement".
  refresh,  // Running the refresh callback.
  done,     // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
}
// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

// The over-scroll distance that moves the indicator to its maximum
// displacement, as a percentage of the scrollable's container extent.
const double _kDragContainerExtentPercentage = 0.25;

// The duration of the ScaleTransition that starts when the refresh action
// has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

// When the scroll ends, the duration of the refresh indicator's animation
// to the RefreshIndicator's displacement.
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);

class CustomRefreshIndicator extends RefreshIndicator {
  const CustomRefreshIndicator({
    Key key,
    Widget child,
    RefreshCallback onRefresh,
    Color color,
  }) : super(key: key, child: child, onRefresh: onRefresh, color:  color);

  // @override
  // Future<void> show({ bool atTop = true }) {
  //   // if (_mode != _RefreshIndicatorMode.refresh &&
  //   //     _mode != _RefreshIndicatorMode.snap) {
  //   //   if (_mode == null)
  //   //     _start(atTop ? AxisDirection.down : AxisDirection.up);
  //   //   _show();
  //   // }
  //   return Future.delayed(Duration(seconds: 3));
  // }

  @override
  CustomRefreshIndicatorState createState() => CustomRefreshIndicatorState();
}

/// Contains the state for a [RefreshIndicator]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
class CustomRefreshIndicatorState extends RefreshIndicatorState {
  AnimationController _positionController;
  AnimationController _scaleController;
  Animation<double> _positionFactor;
  Animation<double> _scaleFactor;
  Animation<double> _value;
  Animation<Color> _valueColor;

  _RefreshIndicatorMode _mode;
  Future<void> _pendingRefreshFuture;
  bool _isIndicatorAtTop;
  double _dragOffset;

  static final Animatable<double> _threeQuarterTween = Tween<double>(begin: 0.0, end: 0.75);
  static final Animatable<double> _kDragSizeFactorLimitTween = Tween<double>(begin: 0.0, end: _kDragSizeFactorLimit);
  static final Animatable<double> _oneToZeroTween = Tween<double>(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
    _value = _positionController.drive(_threeQuarterTween); // The "value" of the circular progress indicator during a drag.

    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _valueColor = _positionController.drive(
      ColorTween(
        begin: (widget.color ?? theme.colorScheme.primary).withOpacity(0.0),
        end: (widget.color ?? theme.colorScheme.primary).withOpacity(1.0),
      ).chain(CurveTween(
        curve: Interval(0.0, 1.0 / _kDragSizeFactorLimit),
      )),
    );
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant RefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      final ThemeData theme = Theme.of(context);
      _valueColor = _positionController.drive(
        ColorTween(
          begin: (widget.color ?? theme.colorScheme.primary).withOpacity(0.0),
          end: (widget.color ?? theme.colorScheme.primary).withOpacity(1.0),
        ).chain(CurveTween(
          curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit),
        )),
      );
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  bool _shouldStart(ScrollNotification notification) {
    // If the notification.dragDetails is null, this scroll is not triggered by
    // user dragging. It may be a result of ScrollController.jumpTo or ballistic scroll.
    // In this case, we don't want to trigger the refresh indicator.
    return ((notification is ScrollStartNotification && notification.dragDetails != null)
        || (notification is ScrollUpdateNotification && notification.dragDetails != null && widget.triggerMode == RefreshIndicatorTriggerMode.anywhere))
        && notification.metrics.extentBefore == 0.0
        && _mode == null
        && _start(notification.metrics.axisDirection);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification))
      return false;
    if (_shouldStart(notification)) {
      setState(() {
        _mode = _RefreshIndicatorMode.drag;
      });
      return false;
    }
    bool indicatorAtTopNow;
    switch (notification.metrics.axisDirection) {
      case AxisDirection.down:
        indicatorAtTopNow = true;
        break;
      case AxisDirection.up:
        indicatorAtTopNow = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        indicatorAtTopNow = null;
        break;
    }
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed)
        _dismiss(_RefreshIndicatorMode.canceled);
    } else if (notification is ScrollUpdateNotification) {
      if (_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed) {
        if (notification.metrics.extentBefore > 0.0) {
          _dismiss(_RefreshIndicatorMode.canceled);
        } else {
          _dragOffset = _dragOffset - notification.scrollDelta;
          _checkDragOffset(notification.metrics.viewportDimension);
        }
      }
      if (_mode == _RefreshIndicatorMode.armed && notification.dragDetails == null) {
        // On iOS start the refresh when the Scrollable bounces back from the
        // overscroll (ScrollNotification indicating this don't have dragDetails
        // because the scroll activity is not directly triggered by a drag).
        _show(shouldStopLoading: false);
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed) {
        _dragOffset = _dragOffset - notification.overscroll;
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_mode) {
        case _RefreshIndicatorMode.armed:
          _show(shouldStopLoading: false);
          break;
        case _RefreshIndicatorMode.drag:
          _dismiss(_RefreshIndicatorMode.canceled);
          break;
        default:
        // do nothing
          break;
      }
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading)
      return false;
    if (_mode == _RefreshIndicatorMode.drag) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_mode == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
        _isIndicatorAtTop = true;
        break;
      case AxisDirection.up:
        _isIndicatorAtTop = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        // we do not support horizontal scroll views.
        return false;
    }
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(_mode == _RefreshIndicatorMode.drag || _mode == _RefreshIndicatorMode.armed);
    double newValue = _dragOffset / (containerExtent * _kDragContainerExtentPercentage);
    if (_mode == _RefreshIndicatorMode.armed)
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    _positionController.value = newValue.clamp(0.0, 1.0); // this triggers various rebuilds
    if (_mode == _RefreshIndicatorMode.drag && _valueColor.value.alpha == 0xFF)
      _mode = _RefreshIndicatorMode.armed;
  }

  // Stop showing the refresh indicator.
  Future<void> _dismiss(_RefreshIndicatorMode newMode) async {
    await Future<void>.value();
    // This can only be called from _show() when refreshing and
    // _handleScrollNotification in response to a ScrollEndNotification or
    // direction change.
    assert(newMode == _RefreshIndicatorMode.canceled || newMode == _RefreshIndicatorMode.done);
    setState(() {
      _mode = newMode;
    });
    switch (_mode) {
      case _RefreshIndicatorMode.done:
        await _scaleController.animateTo(1.0, duration: _kIndicatorScaleDuration);
        break;
      case _RefreshIndicatorMode.canceled:
        await _positionController.animateTo(0.0, duration: _kIndicatorScaleDuration);
        break;
      default:
        assert(false);
    }
    if (mounted && _mode == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _mode = null;
      });
    }
  }

  Future<void> showProgress({ bool atTop = true }) {
    if (_mode != _RefreshIndicatorMode.refresh &&
        _mode != _RefreshIndicatorMode.snap) {
      if (_mode == null) {
        _start(atTop ? AxisDirection.down : AxisDirection.up);
      }
      _show(shouldCallOnRefresh: false);
    }
    return _pendingRefreshFuture;
  }

  void hideProgress() {
    deactivate();
    _dismiss(_RefreshIndicatorMode.done);
  }

  void _show({bool shouldCallOnRefresh = true, bool shouldStopLoading: true}) {
    assert(_mode != _RefreshIndicatorMode.refresh);
    assert(_mode != _RefreshIndicatorMode.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _mode = _RefreshIndicatorMode.snap;
    _positionController
        .animateTo(1.0 / _kDragSizeFactorLimit, duration: _kIndicatorSnapDuration)
        .then<void>((void value) {
      if (mounted && _mode == _RefreshIndicatorMode.snap) {
        assert(widget.onRefresh != null);
        setState(() {
          // Show the indeterminate progress indicator.
          _mode = _RefreshIndicatorMode.refresh;
        });


        if(shouldCallOnRefresh) {
          final Future<void> refreshResult = widget.onRefresh();
          assert(() {
            if (refreshResult == null) {
              FlutterError.reportError(FlutterErrorDetails(
                exception: FlutterError(
                  'The onRefresh callback returned null.\n'
                      'The RefreshIndicator onRefresh callback must return a Future.',
                ),
                context: ErrorDescription('when calling onRefresh'),
                library: 'material library',
              ));
            }
            return true;
          }());
          if (refreshResult == null) {
            return;
          }
          refreshResult.whenComplete(() {
            if (mounted && _mode == _RefreshIndicatorMode.refresh) {
              completer.complete();
              if(shouldStopLoading)
                _dismiss(_RefreshIndicatorMode.done);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );

    final bool showIndeterminateIndicator =
        _mode == _RefreshIndicatorMode.refresh || _mode == _RefreshIndicatorMode.done;

    return Stack(
      children: <Widget>[
        child,
        if (_mode != null) Positioned(
          top: _isIndicatorAtTop != null && _isIndicatorAtTop ? widget.edgeOffset : null,
          bottom: !(_isIndicatorAtTop != null && _isIndicatorAtTop) ? widget.edgeOffset : null,
          left: 0.0,
          right: 0.0,
          child: SizeTransition(
            axisAlignment: _isIndicatorAtTop != null && _isIndicatorAtTop ? 1.0 : -1.0,
            sizeFactor: _positionFactor, // this is what brings it down
            child: Container(
              padding: _isIndicatorAtTop != null && _isIndicatorAtTop
                  ? EdgeInsets.only(top: widget.displacement)
                  : EdgeInsets.only(bottom: widget.displacement),
              alignment: _isIndicatorAtTop != null && _isIndicatorAtTop
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: ScaleTransition(
                scale: _scaleFactor,
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (BuildContext context, Widget child) {
                    return RefreshProgressIndicator(
                      semanticsLabel: widget.semanticsLabel ?? MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
                      semanticsValue: widget.semanticsValue,
                      value: showIndeterminateIndicator ? null : _value.value,
                      valueColor: _valueColor,
                      backgroundColor: widget.backgroundColor,
                      strokeWidth: widget.strokeWidth,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
