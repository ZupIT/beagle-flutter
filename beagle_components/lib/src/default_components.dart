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

final Map<String, ComponentBuilder Function()> defaultComponents = {
  'custom:loading': () => _LoadingBuilder(),
  'custom:error': () => _ErrorBuilder(),
  'beagle:text': () => _TextBuilder(),
  'beagle:container': () => _ContainerBuilder(),
  'beagle:textInput': () => _TextInputBuilder(),
  'beagle:button': () => _ButtonBuilder(),
  'beagle:lazycomponent': () => _LazyBuilder(),
  'beagle:tabbar': () => _TabBarBuilder(),
  'beagle:pageview': () => _PageViewBuilder(),
  'beagle:image': () => _ImageBuilder(),
  'beagle:pageIndicator': () => _PageIndicatorBuilder(),
  'beagle:touchable': () => _TouchableBuilder(),
  'beagle:webView': () => _WebViewBuilder(),
  'beagle:screenComponent': () => _ScreenBuilder(),
  'beagle:pullToRefresh': () => _PullToRefreshBuilder(),
  'beagle:scrollView': () => _ScrollViewBuilder(),
  'beagle:simpleForm': () => _SimpleFormBuilder(),
  'beagle:listView': () => _DynamicListBuilder(),
  'beagle:gridView': () => _DynamicListBuilder(),
};

class _LoadingBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(_, __, ___) => Text('Loading...');
}

class _ErrorBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(_, __, ___) => Text('Error!');
}

class _TextBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, _, __) => BeagleText(
    text: element.getAttributeValue('text'),
    textColor: element.getAttributeValue('textColor'),
    styleId: element.getAttributeValue('styleId'),
    alignment: EnumUtils.fromString(TextAlignment.values, element.getAttributeValue('alignment')) ?? TextAlignment.LEFT,
  );
}

class _ContainerBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, children, _) => BeagleContainer(
    onInit: element.getAttributeValue('onInit'),
    style: element.getStyle(),
    children: children,
  );
}

class _ScrollViewBuilder extends ComponentBuilder {
  @override
  StyleConfig getStyleConfig() => StyleConfig.disabled();

  @override
  Widget buildForBeagle(element, children, _) {
    final direction = EnumUtils.fromString(ScrollAxis.values, element.getAttributeValue('scrollDirection'));
    return BeagleScrollView(
      scrollDirection: direction,
      scrollBarEnabled: element.getAttributeValue('scrollBarEnabled'),
      /* Notice that from this point on, Beagle won't be able to render any flex factor greater than 0 before fixating
      a new height, this is because the scroll's height is unbounded. */
      children: [BeagleFlexWidget(
        children,
        direction: direction == ScrollAxis.HORIZONTAL ? Axis.horizontal : Axis.vertical,
      )],
    );
  }
}

class _DynamicListBuilder extends ComponentBuilder {
  @override
  StyleConfig getStyleConfig() => StyleConfig.disabled(shouldExpand: false);

  @override
  Widget buildForBeagle(element, children, view) {
    return BeagleDynamicList(
      onInit: element.getAttributeValue('onInit'),
      direction: EnumUtils.fromString(BeagleDynamicListDirection.values, element.getAttributeValue('direction')),
      dataSource: element.getAttributeValue('dataSource'),
      templates: TemplateManagerItem.fromJsonList(element.getAttributeValue('templates')),
      isScrollIndicatorVisible: element.getAttributeValue('isScrollIndicatorVisible'),
      scrollEndThreshold: element.getAttributeValue('scrollEndThreshold'),
      iteratorName: element.getAttributeValue('iteratorName'),
      identifierItem: element.getAttributeValue('key'),
      onScrollEnd: element.getAttributeValue('onScrollEnd'),
      children: children,
      spanCount: element.getAttributeValue('spanCount'),
      view: view,
      beagleId: element.getId(),
      suffix: element.getAttributeValue('__suffix__'),
      dataSourceKey: element.getAttributeValue('key'),
    );
  }
}

class _TextInputBuilder extends ComponentBuilder {
  @override
  StyleConfig? getStyleConfig() => StyleConfig.enabled(shouldDecorate: false);

  @override
  Widget buildForBeagle(element, _, __) => BeagleTextInput(
    onChange: element.getAttributeValue('onChange'),
    onFocus: element.getAttributeValue('onFocus'),
    onBlur: element.getAttributeValue('onBlur'),
    placeholder: element.getAttributeValue('placeholder'),
    value: element.getAttributeValue('value'),
    readOnly: element.getAttributeValue('readOnly'),
    enabled: element.getAttributeValue('enabled'),
    error: element.getAttributeValue('error'),
    showError: element.getAttributeValue('showError'),
    style: element.getStyle(),
    type: EnumUtils.fromString(BeagleTextInputType.values, element.getAttributeValue('type')) ??
        BeagleTextInputType.TEXT,
  );
}

class _ButtonBuilder extends ComponentBuilder {
  @override
  StyleConfig? getStyleConfig() => StyleConfig.enabled(shouldDecorate: false);

  @override
  Widget buildForBeagle(element, _, __) {
    return BeagleButton(
    onPress: element.getAttributeValue('onPress'),
    text: element.getAttributeValue('text'),
    enabled: element.getAttributeValue('enabled'),
    styleId: element.getAttributeValue('styleId'),
    style: element.getStyle(),
  );
}}

class _LazyBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, children, view) {
    final initialState = element.getAttributeValue('initialState');
    return BeagleLazyComponent(
      path: element.getAttributeValue('path'),
      initialState: initialState == null ? null : BeagleUIElement(initialState),
      beagleId: element.getId(),
      view: view,
      child: children.isEmpty ? Container() : children[0],
    );
  }
}

class _TabBarBuilder extends ComponentBuilder {
  @override
  StyleConfig getStyleConfig() => StyleConfig.disabled(shouldExpand: false);

  @override
  Widget buildForBeagle(element, _, __) {
    final List<dynamic> jsonItems = element.getAttributeValue('items') ?? [];
    return BeagleTabBar(
      items: jsonItems.map((item) => TabBarItem.fromJson(item)).toList(),
      currentTab: element.getAttributeValue('currentTab'),
      onTabSelection: element.getAttributeValue('onTabSelection'),
    );
  }
}

class _PageViewBuilder extends ComponentBuilder {
  @override
  StyleConfig getStyleConfig() => StyleConfig.disabled();

  @override
  Widget buildForBeagle(element, children, _) => BeaglePageView(
    currentPage: element.getAttributeValue('currentPage'),
    onPageChange: element.getAttributeValue('onPageChange'),
    children: children,
  );
}

class _ImageBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, _, __) {
    return BeagleImage(
      path: ImagePath.fromJson(element.getAttributeValue('path')),
      mode: EnumUtils.fromString(
        ImageContentMode.values,
        element.getAttributeValue('mode'),
      ) ??
          ImageContentMode.CENTER,
      style: element.getStyle(),
    );
  }
}

class _PageIndicatorBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, _, __) => BeaglePageIndicator(
    selectedColor: element.getAttributeValue('selectedColor'),
    unselectedColor: element.getAttributeValue('unselectedColor'),
    numberOfPages: element.getAttributeValue('numberOfPages'),
    currentPage: element.getAttributeValue('currentPage'),
  );
}

class _TouchableBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, children, __) => BeagleTouchable(
    onPress: element.getAttributeValue('onPress'),
    child: children.isNotEmpty ? children[0] : null,
  );
}

class _WebViewBuilder extends ComponentBuilder {
  @override
  StyleConfig getStyleConfig() => StyleConfig.disabled();

  @override
  Widget buildForBeagle(element, children, __) => BeagleWebView(
    url: element.getAttributeValue('url'),
  );
}

class _ScreenBuilder extends ComponentBuilder {
  @override
  StyleConfig getStyleConfig() => StyleConfig.disabled();

  @override
  Widget buildForBeagle(element, children, _) {
    final Map<String, dynamic>? safeArea = element.getAttributeValue('safeArea');
    final Map<String, dynamic>? navigationBarMap = element.getAttributeValue('navigationBar');
    final BeagleNavigationBar? navigationBar = navigationBarMap == null ? null : BeagleNavigationBar.fromJson(navigationBarMap);

    return BeagleScreen(
      identifier: element.getAttributeValue('identifier') ?? '',
      safeArea: safeArea != null ? BeagleSafeArea.fromJson(safeArea) : null,
      navigationBar: navigationBar,
      child: BeagleFlexWidget(children),
    );
  }
}

class _PullToRefreshBuilder extends ComponentBuilder {
  @override
  StyleConfig getStyleConfig() => StyleConfig.disabled();

  @override
  Widget buildForBeagle(element, children, view) {
    return PullToRefresh(
      onPull: element.getAttributeValue('onPull'),
      isRefreshing: element.getAttributeValue('isRefreshing'),
      color: element.getAttributeValue('color'),
      /* BeagleFlexWidget is not needed here because we don't need to control the direction and flex factors can't be
      used inside scrolls, they have infinite height. Notice that from this point on, Beagle won't be able to render
      any flex factor greater than 0 before fixating a new height, this is because the scroll's height is unbounded. */
      child: children[0],
    );
  }
}

class _SimpleFormBuilder extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, children, _) {
    return BeagleSimpleForm(
      onSubmit: element.getAttributeValue('onSubmit'),
      onValidationError: element.getAttributeValue('onValidationError'),
      children: children,
    );
  }
}
