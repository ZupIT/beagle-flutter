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

class BeagleScreen extends StatelessWidget {
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
            actions: navigationBar.navigationBarItems.map((e) => ItemComponent(item: e)).toList(growable: false),
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

    final yogaChild = BeagleFlexWidget(
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

class NavigationBarItem {
  NavigationBarItem({
    this.text,
    this.image,
    this.action,
  });

  final String text;
  final String image;
  final Function action;

  factory NavigationBarItem.fromJson(Map<String, dynamic> json) {
    return NavigationBarItem(
      text: json['text'],
      image: json['image'],
      action: json['action'],
    );
  }
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
  final List<NavigationBarItem> navigationBarItems;

  factory BeagleNavigationBar.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJsonArray = json['navigationBarItems'];
    final List<NavigationBarItem> items = itemsJsonArray == null
      ? []
      : itemsJsonArray.map((e) => NavigationBarItem.fromJson(e)).toList();
    return BeagleNavigationBar(
      title: json['title'],
      showBackButton: json['showBackButton'],
      styleId: json['styleId'],
      navigationBarItems: items,
    );
  }
}

class ItemComponent extends StatelessWidget {
  const ItemComponent({Key key, this.item})
      : super(key: key);

  final NavigationBarItem item;

  static final style = BeagleStyle(
      size: BeagleSize(
          width: UnitValue(value: 32, type: UnitType.REAL),
          height: UnitValue(value: 32, type: UnitType.REAL),
      )
  );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: item.action,
        icon: BeagleFlexWidget(children: [BeagleImage(path: ImagePath.local(item.image))], style: style,),
      tooltip: item.text,
    );
  }
}
