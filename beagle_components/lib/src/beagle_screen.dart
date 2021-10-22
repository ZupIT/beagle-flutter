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
    Key? key,
    required this.identifier,
    required this.safeArea,
    required this.navigationBar,
    required this.child,
  }) : super(key: key);

  final String identifier;
  final BeagleSafeArea safeArea;
  final BeagleNavigationBar navigationBar;
  final Widget child;

  BeagleNavigationBarStyle? get _navigationBarStyle =>
      beagleServiceLocator<BeagleDesignSystem>().navigationBarStyle(navigationBar.styleId ?? '');

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    final appBar = navigationBar != null
        ? AppBar(
            leading: _navigationBarStyle?.leading,
            automaticallyImplyLeading: navigationBar.showBackButton,
            title: Text(navigationBar.title),
            actions: navigationBar.navigationBarItems?.map((e) => ItemComponent(item: e)).toList(growable: false) ?? [],
            elevation: _navigationBarStyle?.elevation,
            shadowColor: _navigationBarStyle?.shadowColor,
            backgroundColor: _navigationBarStyle?.backgroundColor,
            iconTheme: _navigationBarStyle?.iconTheme,
            actionsIconTheme: _navigationBarStyle?.actionsIconTheme,
            centerTitle: _navigationBarStyle?.centerTitle,
            titleSpacing: _navigationBarStyle?.titleSpacing,
            toolbarHeight: _navigationBarStyle?.toolbarHeight,
            leadingWidth: _navigationBarStyle?.leadingWidth,
            toolbarTextStyle: _navigationBarStyle?.toolbarTextStyle,
            titleTextStyle: _navigationBarStyle?.titleTextStyle)
        : null;

    final yogaChild = BeagleFlexWidget(
      style: BeagleStyle(flex: BeagleFlex(grow: 1.0)),
      // ignore: unnecessary_null_comparison
      children: child != null ? [child] : [],
    );
    // ignore: unnecessary_null_comparison
    final body = safeArea != null
        ? SafeArea(
            top: safeArea.top ?? true,
            left: safeArea.leading ?? true,
            bottom: safeArea.bottom ?? true,
            right: safeArea.trailing ?? true,
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

  final bool? top;
  final bool? leading;
  final bool? bottom;
  final bool? trailing;

  BeagleSafeArea.fromJson(Map<String, dynamic> json)
      : top = BeagleCaster.castToBool(json['top']),
        leading = BeagleCaster.castToBool(json['leading']),
        bottom = BeagleCaster.castToBool(json['bottom']),
        trailing = BeagleCaster.castToBool(json['trailing']);
}

class NavigationBarItem {
  NavigationBarItem({
    required this.text,
    required this.image,
    this.action,
  });

  final String text;
  final String image;
  final Function? action;

  factory NavigationBarItem.fromJson(Map<String, dynamic> json) {
    return NavigationBarItem(
      text: BeagleCaster.castToString(json['text']),
      image: BeagleCaster.castToString(json['image']?['mobileId']),
      action: BeagleCaster.castToFunction(json['action']),
    );
  }
}

class BeagleNavigationBar {
  BeagleNavigationBar({
    required this.title,
    required this.showBackButton,
    this.styleId,
    this.navigationBarItems,
  });

  final String title;
  final bool showBackButton;
  final String? styleId;
  final List<NavigationBarItem>? navigationBarItems;

  factory BeagleNavigationBar.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJsonArray = BeagleCaster.castToList(json['navigationBarItems']);
    final List<NavigationBarItem> items = itemsJsonArray.map((e) => NavigationBarItem.fromJson(e)).toList();
    return BeagleNavigationBar(
        title: BeagleCaster.castToString(json['title']),
        showBackButton: BeagleCaster.castToBool(json['showBackButton']),
        styleId: BeagleCaster.castToString(json['styleId']),
        navigationBarItems: items);
  }
}

class ItemComponent extends StatelessWidget {
  final NavigationBarItem item;

  ItemComponent({Key? key, required this.item}) : super(key: key);

  static final style = BeagleStyle(
    size: BeagleSize(
      width: UnitValue(value: 32, type: UnitType.REAL),
      height: UnitValue(value: 32, type: UnitType.REAL),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: BeagleCaster.cast<void Function()?>(item.action, () {}),
      icon: BeagleFlexWidget(
        children: item.image.isNotEmpty ? [BeagleImage(path: ImagePath.local(item.image))] : [],
        style: style,
      ),
      tooltip: item.text,
    );
  }
}
