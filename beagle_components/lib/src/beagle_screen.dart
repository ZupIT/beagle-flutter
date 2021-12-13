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

class BeagleScreen extends StatefulWidget {
  const BeagleScreen({
    Key? key,
    this.identifier,
    this.safeArea,
    this.navigationBar,
    required this.child,
  }) : super(key: key);

  final String? identifier;
  final BeagleSafeArea? safeArea;
  final BeagleNavigationBar? navigationBar;
  final Widget child;

  @override
  _BeagleScreen createState() => _BeagleScreen();
}

class _BeagleScreen extends State<BeagleScreen> with BeagleConsumer {
  @override
  Widget buildBeagleWidget(BuildContext context) {
    final navigationBarStyle = widget.navigationBar?.styleId == null
        ? null
        : beagle.designSystem.navigationBarStyle(widget.navigationBar!.styleId!);
    final appBar = widget.navigationBar != null
        ? AppBar(
            leading: navigationBarStyle?.leading,
            automaticallyImplyLeading: widget.navigationBar?.showBackButton == true,
            title: Text(widget.navigationBar?.title ?? ''),
            actions: widget.navigationBar?.navigationBarItems?.map((e) => ItemComponent(item: e)).toList(growable: false) ?? [],
            elevation: navigationBarStyle?.elevation,
            shadowColor: navigationBarStyle?.shadowColor,
            backgroundColor: navigationBarStyle?.backgroundColor,
            iconTheme: navigationBarStyle?.iconTheme,
            actionsIconTheme: navigationBarStyle?.actionsIconTheme,
            centerTitle: navigationBarStyle?.centerTitle,
            titleSpacing: navigationBarStyle?.titleSpacing,
            toolbarHeight: navigationBarStyle?.toolbarHeight,
            leadingWidth: navigationBarStyle?.leadingWidth,
            toolbarTextStyle: navigationBarStyle?.toolbarTextStyle,
            titleTextStyle: navigationBarStyle?.titleTextStyle)
        : null;

    final body = widget.safeArea != null
        ? SafeArea(
            top: widget.safeArea!.top ?? true,
            left: widget.safeArea!.leading ?? true,
            bottom: widget.safeArea!.bottom ?? true,
            right: widget.safeArea!.trailing ?? true,
            child: widget.child,
          )
        : widget.child;

    return Scaffold(appBar: appBar, body: body);
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
      : top = json['top'],
        leading = json['leading'],
        bottom = json['bottom'],
        trailing = json['trailing'];
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
      text: json['text'] ?? '',
      image: json['image'] ?? '',
      action: json['action'],
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
    final List<dynamic> itemsJsonArray = json['navigationBarItems'] ?? [];
    final List<NavigationBarItem> items = itemsJsonArray.map((e) => NavigationBarItem.fromJson(e)).toList();
    return BeagleNavigationBar(
      title: json['title'] ?? '',
      showBackButton: json['showBackButton'] ?? true,
      styleId: json['styleId'],
      navigationBarItems: items,
    );
  }
}

class ItemComponent extends StatelessWidget {
  final NavigationBarItem item;

  ItemComponent({Key? key, required this.item}) : super(key: key);

  static final double size = 32;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: item.action as void Function()? ?? () {},
      icon: item.image.isEmpty
        ? SizedBox.shrink()
        : SizedBox.square(
            dimension: size,
            child: BeagleImage(path: ImagePath.local(item.image), mode: ImageContentMode.FIT_CENTER),
          ),
      tooltip: item.text,
    );
  }
}
