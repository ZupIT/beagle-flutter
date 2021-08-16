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

import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BeagleScreen extends StatelessWidget with YogaWidget {
  const BeagleScreen({
    Key key,
    this.identifier,
    this.safeArea,
    this.navigationBar,
    this.child,
  }) : super(key: key);

  final String identifier;
  final BeagleSafeArea safeArea;
  final BeagleNavigationBar navigationBar;
  final Widget child;

  BeagleYogaFactory get _beagleYogaFactory => beagleServiceLocator();

  BeagleNavigationBarStyle get _navigationBarStyle =>
      beagleServiceLocator<BeagleDesignSystem>()
          ?.navigationBarStyle(navigationBar.styleId);

  @override
  Widget build(BuildContext context) {
    final appBar = navigationBar != null
        ? AppBar(
            leading: _navigationBarStyle?.leading,
            automaticallyImplyLeading: navigationBar.showBackButton,
            title: Text(navigationBar.title),
            actions: navigationBar.navigationBarItems,
            elevation: _navigationBarStyle?.elevation,
            shadowColor: _navigationBarStyle?.shadowColor,
            backgroundColor: _navigationBarStyle?.backgroundColor,
            iconTheme: _navigationBarStyle?.iconTheme,
            actionsIconTheme: _navigationBarStyle?.actionsIconTheme,
            textTheme: _navigationBarStyle?.textTheme,
            centerTitle: _navigationBarStyle?.centerTitle,
            titleSpacing: _navigationBarStyle?.titleSpacing,
            toolbarHeight: _navigationBarStyle?.toolbarHeight,
            leadingWidth: _navigationBarStyle?.leadingWidth,
            toolbarTextStyle: _navigationBarStyle?.toolbarTextStyle,
            titleTextStyle: _navigationBarStyle?.titleTextStyle,
          )
        : null;

    final yogaChild = _beagleYogaFactory.createYogaLayout(
      style: BeagleStyle(flex: BeagleFlex(grow: 1.0)),
      children: [child],
    );
    final body = safeArea != null
        ? SafeArea(
            top: safeArea.top,
            left: safeArea.leading,
            bottom: safeArea.bottom,
            right: safeArea.trailing,
            child: yogaChild,
          )
        : yogaChild;

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
}

class BeagleSafeArea {
  BeagleSafeArea({
    this.top,
    this.leading,
    this.bottom,
    this.trailing,
  });

  final bool top;
  final bool leading;
  final bool bottom;
  final bool trailing;

  BeagleSafeArea.fromJson(Map<String, dynamic> json)
      : top = json['top'] ?? false,
        leading = json['leading'] ?? false,
        bottom = json['bottom'] ?? false,
        trailing = json['trailing'] ?? false;
}

class BeagleNavigationBar {
  BeagleNavigationBar({
    this.title,
    this.showBackButton,
    this.styleId,
    this.navigationBarItems,
  });

  final String title;
  final bool showBackButton;
  final String styleId;
  final List<Widget> navigationBarItems;
}

class BeagleNavigationBarItem extends StatelessWidget {
  const BeagleNavigationBarItem({Key key, this.text, this.image, this.action})
      : super(key: key);

  final String text;
  final LocalImagePath image;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: action,
      icon: _getLocalImage(image.mobileId),
      tooltip: text,
    );
  }

  Image _getLocalImage(String mobileId) {
    final image = beagleServiceLocator<BeagleDesignSystem>()?.image(mobileId);
    if (image != null) {
      return Image.asset(image);
    }
    return Image.asset('images/beagle.png');
  }
}
