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

final Map<String, ComponentBuilder> defaultComponents = {
  'custom:loading': beagleLoadingBuilder(),
  'custom:error': beagleErrorBuilder(),
  'beagle:text': beagleTextBuilder(),
  'beagle:container': beagleContainerBuilder(),
  'beagle:textInput': beagleTextInputBuilder(),
  'beagle:button': beagleButtonBuilder(),
  'beagle:lazycomponent': beagleLazyComponentBuilder(),
  'beagle:tabbar': beagleTabBarBuilder(),
  'beagle:pageview': beaglePageViewBuilder(),
  'beagle:image': beagleImageBuilder(),
  'beagle:pageIndicator': beaglePageIndicatorBuilder(),
  'beagle:touchable': beagleTouchableBuilder(),
  'beagle:webView': beagleWebViewBuilder(),
  'beagle:screenComponent': beagleScreenComponentBuilder(),
  'beagle:pullToRefresh': beaglePullToRefreshBuilder(),
  'beagle:scrollView': beagleScrollViewBuilder(),
  'beagle:simpleForm': beagleSimpleFormBuilder(),
  'beagle:listView': beagleListViewBuilder(),
  'beagle:gridView': beagleGridViewBuilder(),
};

ComponentBuilder beagleLoadingBuilder() => (element, _, __) => Text('Loading...', key: element.getKey());

ComponentBuilder beagleErrorBuilder() => (element, _, __) => Text('Error!', key: element.getKey());

ComponentBuilder beagleTextBuilder() {
  return (element, _, __) => BeagleText(
        key: element.getKey(),
        text: element.getAttributeValue('text'),
        textColor: element.getAttributeValue('textColor'),
        styleId: element.getAttributeValue('styleId'),
        alignment:
            EnumUtils.fromString(TextAlignment.values, element.getAttributeValue('alignment')) ?? TextAlignment.LEFT,
      );
}

ComponentBuilder beagleContainerBuilder() {
  return (element, children, _) => BeagleContainer(
        key: element.getKey(),
        onInit: element.getAttributeValue('onInit'),
        style: element.getStyle(),
        children: children,
      );
}

ComponentBuilder beagleScrollViewBuilder() {
  return (element, children, _) => BeagleScrollView(
        key: element.getKey(),
        scrollDirection: EnumUtils.fromString(ScrollAxis.values, element.getAttributeValue('scrollDirection')),
        scrollBarEnabled: element.getAttributeValue('scrollBarEnabled'),
        children: children,
      );
}

ComponentBuilder beagleListViewBuilder() {
  return (element, children, _) => BeagleDynamicList(
        key: element.getKey(),
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
        suffix: element.getAttributeValue('__suffix__'),
        beagleWidgetStateProvider: BeagleWidgetStateProvider(),
      );
}

ComponentBuilder beagleGridViewBuilder() {
  return (element, children, _) => BeagleDynamicList(
        key: element.getKey(),
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
        suffix: element.getAttributeValue('__suffix__'),
        beagleWidgetStateProvider: BeagleWidgetStateProvider(),
      );
}

ComponentBuilder beagleTextInputBuilder() {
  return (element, _, __) => BeagleTextInput(
        key: element.getKey(),
        onChange: element.getAttributeValue('onChange'),
        onFocus: element.getAttributeValue('onFocus'),
        onBlur: element.getAttributeValue('onBlur'),
        placeholder: element.getAttributeValue('placeholder'),
        value: element.getAttributeValue('value'),
        readOnly: element.getAttributeValue('readOnly'),
        enabled: element.getAttributeValue('enabled'),
        error: element.getAttributeValue('error'),
        showError: element.getAttributeValue('showError'),
        type: EnumUtils.fromString(BeagleTextInputType.values, element.getAttributeValue('type')) ??
            BeagleTextInputType.TEXT,
      );
}

ComponentBuilder beagleButtonBuilder() {
  return (element, _, __) => BeagleButton(
        key: element.getKey(),
        onPress: element.getAttributeValue('onPress'),
        text: element.getAttributeValue('text'),
        enabled: element.getAttributeValue('enabled'),
        styleId: element.getAttributeValue('styleId'),
        style: element.getStyle(),
      );
}

ComponentBuilder beagleLazyComponentBuilder() {
  return (element, children, view) {
    final initialState = element.getAttributeValue('initialState');
    return BeagleLazyComponent(
      key: element.getKey(),
      path: element.getAttributeValue('path'),
      initialState: initialState == null ? null : BeagleUIElement(initialState),
      beagleId: element.getId(),
      view: view,
      child: children.isEmpty ? Container() : children[0],
    );
  };
}

ComponentBuilder beagleTabBarBuilder() {
  return (element, _, __) {
    final List<dynamic> jsonItems = element.getAttributeValue('items') ?? [];
    return BeagleTabBar(
      key: element.getKey(),
      items: jsonItems.map((item) => TabBarItem.fromJson(item)).toList(),
      currentTab: element.getAttributeValue('currentTab'),
      onTabSelection: element.getAttributeValue('onTabSelection'),
    );
  };
}

ComponentBuilder beaglePageViewBuilder() {
  return (element, children, __) => BeaglePageView(
        key: element.getKey(),
        currentPage: element.getAttributeValue('currentPage'),
        onPageChange: element.getAttributeValue('onPageChange'),
        children: children,
      );
}

ComponentBuilder beagleImageBuilder() {
  return (element, _, __) {
    return BeagleImage(
      key: element.getKey(),
      path: ImagePath.fromJson(element.getAttributeValue('path')),
      mode: EnumUtils.fromString(
            ImageContentMode.values,
            element.getAttributeValue('mode'),
          ) ??
          ImageContentMode.CENTER,
      style: element.getStyle(),
    );
  };
}

ComponentBuilder beaglePageIndicatorBuilder() {
  return (element, _, __) => BeaglePageIndicator(
        key: element.getKey(),
        selectedColor: element.getAttributeValue('selectedColor'),
        unselectedColor: element.getAttributeValue('unselectedColor'),
        numberOfPages: element.getAttributeValue('numberOfPages'),
        currentPage: element.getAttributeValue('currentPage'),
      );
}

ComponentBuilder beagleTouchableBuilder() {
  return (element, children, __) => BeagleTouchable(
        key: element.getKey(),
        onPress: element.getAttributeValue('onPress'),
        child: children.isNotEmpty ? children[0] : null,
      );
}

ComponentBuilder beagleWebViewBuilder() {
  return (element, children, __) => BeagleWebView(
        key: element.getKey(),
        url: element.getAttributeValue('url'),
      );
}

ComponentBuilder beagleScreenComponentBuilder() {
  return (element, children, _) {
    final Map<String, dynamic>? safeArea = element.getAttributeValue('safeArea');
    final Map<String, dynamic> navigationBarMap = element.getAttributeValue('navigationBar');
    final BeagleNavigationBar navigationBar = BeagleNavigationBar.fromJson(navigationBarMap);

    return BeagleScreen(
      key: element.getKey(),
      identifier: element.getAttributeValue('identifier') ?? '',
      safeArea: safeArea != null ? BeagleSafeArea.fromJson(safeArea) : null,
      navigationBar: navigationBar,
      child: children.isNotEmpty ? children[0] : Container(),
    );
  };
}

ComponentBuilder beaglePullToRefreshBuilder() {
  return (element, children, view) {
    return PullToRefresh(
      key: element.getKey(),
      onPull: element.getAttributeValue('onPull'),
      isRefreshing: element.getAttributeValue('isRefreshing'),
      color: element.getAttributeValue('color'),
      child: children.isNotEmpty ? children[0] : Container(),
    );
  };
}

ComponentBuilder beagleSimpleFormBuilder() {
  return (element, children, view) {
    return BeagleSimpleForm(
      key: element.getKey(),
      onSubmit: element.getAttributeValue('onSubmit'),
      onValidationError: element.getAttributeValue('onValidationError'),
      children: children,
    );
  };
}
