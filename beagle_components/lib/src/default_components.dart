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

ComponentBuilder beagleLoadingBuilder() {
  return (element, _, __) => Text('Loading...', key: element.getKey());
}

ComponentBuilder beagleErrorBuilder() {
  return (element, _, __) => Text('Error!', key: element.getKey());
}

ComponentBuilder beagleTextBuilder() {
  return (element, _, __) =>
      BeagleText(
          key: element.getKey(),
          text: BeagleCaster.castToString(element.getAttributeValue('text')),
          textColor: BeagleCaster.castToString(element.getAttributeValue('textColor'), defaultValue: null),
          styleId: BeagleCaster.castToString(element.getAttributeValue('styleId'), defaultValue: null),
          alignment: EnumUtils.fromString(
            TextAlignment.values,
            BeagleCaster.castToString(element.getAttributeValue('alignment'), defaultValue: null),
          ) ??
              TextAlignment.LEFT);
}

ComponentBuilder beagleContainerBuilder() {
  return (element, children, _) =>
      BeagleContainer(
          key: element.getKey(),
          onInit: BeagleCaster.castToNullableFunction(element.getAttributeValue('onInit')),
          style: BeagleCaster.cast<BeagleStyle?>(element.getStyle(), null),
          children: BeagleCaster.castToList<Widget>(children, defaultValue: []));
}

ComponentBuilder beagleScrollViewBuilder() {
  return (element, children, _) =>
      BeagleScrollView(
          key: element.getKey(),
          scrollDirection: EnumUtils.fromString(
            ScrollAxis.values,
            BeagleCaster.castToString(element.getAttributeValue('scrollDirection')),
          ),
          scrollBarEnabled: BeagleCaster.castToBool(element.getAttributeValue('scrollBarEnabled'), defaultValue: true),
          children: BeagleCaster.castToList<Widget>(children, defaultValue: []));
}

ComponentBuilder beagleListViewBuilder() {
  return (element, children, _) =>
      BeagleDynamicList(
          key: element.getKey(),
          onInit: BeagleCaster.castToNullableFunction(element.getAttributeValue('onInit')),
          direction: EnumUtils.fromString(
            BeagleDynamicListDirection.values,
            element.getAttributeValue('direction'),
          ),
          dataSource: BeagleCaster.castToList<dynamic>(element.getAttributeValue('dataSource')),
          templates: TemplateManagerItem.fromJsonList(element.getAttributeValue('templates')),
          isScrollIndicatorVisible:
          BeagleCaster.castToBool(element.getAttributeValue('isScrollIndicatorVisible'), defaultValue: null),
          scrollEndThreshold: BeagleCaster.castToInt(
              element.getAttributeValue('scrollEndThreshold'), defaultValue: null),
          iteratorName: BeagleCaster.castToString(element.getAttributeValue('iteratorName'), defaultValue: null),
          identifierItem: BeagleCaster.castToString(element.getAttributeValue('key'), defaultValue: null),
          onScrollEnd: BeagleCaster.castToNullableFunction(element.getAttributeValue('onScrollEnd')),
          children: BeagleCaster.castToList<Widget>(children),
          suffix: BeagleCaster.castToString(element.getAttributeValue('__suffix__'), defaultValue: null),
          beagleWidgetStateProvider: BeagleWidgetStateProvider());
}

ComponentBuilder beagleGridViewBuilder() {
  return (element, children, _) =>
      BeagleDynamicList(
          key: element.getKey(),
          onInit: BeagleCaster.castToNullableFunction(element.getAttributeValue('onInit')),
          direction: EnumUtils.fromString(
            BeagleDynamicListDirection.values,
            element.getAttributeValue('direction'),
          ),
          dataSource: BeagleCaster.castToList<dynamic>(element.getAttributeValue('dataSource')),
          templates: TemplateManagerItem.fromJsonList(element.getAttributeValue('templates')),
          isScrollIndicatorVisible:
          BeagleCaster.castToBool(element.getAttributeValue('isScrollIndicatorVisible'), defaultValue: null),
          scrollEndThreshold: BeagleCaster.castToInt(
              element.getAttributeValue('scrollEndThreshold'), defaultValue: null),
          iteratorName: BeagleCaster.castToString(element.getAttributeValue('iteratorName'), defaultValue: null),
          identifierItem: BeagleCaster.castToString(element.getAttributeValue('key'), defaultValue: null),
          onScrollEnd: BeagleCaster.castToNullableFunction(element.getAttributeValue('onScrollEnd')),
          children: BeagleCaster.castToList<Widget>(children),
          spanCount: BeagleCaster.castToInt(element.getAttributeValue('spanCount'), defaultValue: null),
          suffix: BeagleCaster.castToString(element.getAttributeValue('__suffix__'), defaultValue: null),
          beagleWidgetStateProvider: BeagleWidgetStateProvider());
}

ComponentBuilder beagleTextInputBuilder() {
  return (element, _, __) =>
      BeagleTextInput(
          key: element.getKey(),
          onChange: BeagleCaster.castToNullableFunction(element.getAttributeValue('onChange')),
          onFocus: BeagleCaster.castToNullableFunction(element.getAttributeValue('onFocus')),
          onBlur: BeagleCaster.castToNullableFunction(element.getAttributeValue('onBlur')),
          placeholder: BeagleCaster.castToString(element.getAttributeValue('placeholder'), defaultValue: null),
          value: BeagleCaster.castToString(element.getAttributeValue('value'), defaultValue: null),
          readOnly: BeagleCaster.castToBool(element.getAttributeValue('readOnly'), defaultValue: false),
          enabled: BeagleCaster.castToBool(element.getAttributeValue('enabled'), defaultValue: true),
          error: BeagleCaster.castToString(element.getAttributeValue('error'), defaultValue: null),
          showError: BeagleCaster.castToBool(element.getAttributeValue('showError'), defaultValue: null),
          type: EnumUtils.fromString(BeagleTextInputType.values, element.getAttributeValue('type')) ??
              BeagleTextInputType.TEXT);
}

ComponentBuilder beagleButtonBuilder() {
  return (element, _, __) =>
      BeagleButton(
        key: element.getKey(),
        onPress: BeagleCaster.castToNullableFunction(element.getAttributeValue('onPress')),
        text: BeagleCaster.castToString(element.getAttributeValue('text'), defaultValue: null),
        enabled: BeagleCaster.castToBool(element.getAttributeValue('enabled'), defaultValue: true),
        styleId: BeagleCaster.castToString(element.getAttributeValue('styleId'), defaultValue: null),
        style: element.getStyle(),
      );
}

ComponentBuilder beagleLazyComponentBuilder() {
  return (element, children, view) {
    final initialState = element.getAttributeValue('initialState');
    return BeagleLazyComponent(
        key: element.getKey(),
        path: BeagleCaster.castToString(element.getAttributeValue('path'), defaultValue: null),
        initialState: initialState == null ? null : BeagleUIElement(initialState),
        beagleId: element.getId(),
        view: view,
        child: children.isEmpty ? Container() : children[0]);
  };
}

ComponentBuilder beagleTabBarBuilder() {
  return (element, _, __) {
    final List<dynamic> jsonItems = element.getAttributeValue('items') ?? [];
    return BeagleTabBar(
        key: element.getKey(),
        items: jsonItems.map((item) => TabBarItem.fromJson(item)).toList(),
        currentTab: BeagleCaster.castToInt(element.getAttributeValue('currentTab'), defaultValue: null),
        onTabSelection: BeagleCaster.cast<void Function(int)?>(element.getAttributeValue('onTabSelection'), null));
  };
}

ComponentBuilder beaglePageViewBuilder() {
  return (element, children, __) =>
      BeaglePageView(
        key: element.getKey(),
        currentPage: BeagleCaster.castToInt(element.getAttributeValue('currentPage'), defaultValue: null),
        onPageChange: BeagleCaster.cast<void Function(int)?>(element.getAttributeValue('onPageChange'), null),
        children: BeagleCaster.castToList<Widget>(children),
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
  return (element, _, __) =>
      BeaglePageIndicator(
          key: element.getKey(),
          selectedColor: BeagleCaster.castToString(element.getAttributeValue('selectedColor'), defaultValue: null),
          unselectedColor: BeagleCaster.castToString(element.getAttributeValue('unselectedColor'), defaultValue: null),
          numberOfPages: BeagleCaster.castToInt(element.getAttributeValue('numberOfPages'), defaultValue: null),
          currentPage: BeagleCaster.castToInt(element.getAttributeValue('currentPage'), defaultValue: null));
}

ComponentBuilder beagleTouchableBuilder() {
  return (element, children, __) =>
      BeagleTouchable(
          key: element.getKey(),
          onPress: BeagleCaster.cast<void Function()?>(element.getAttributeValue('onPress'), null),
          child: children.isNotEmpty ? children[0] : null);
}

ComponentBuilder beagleWebViewBuilder() {
  return (element, children, __) =>
      BeagleWebView(
        key: element.getKey(),
        url: BeagleCaster.castToString(element.getAttributeValue('url'), defaultValue: null),
      );
}

ComponentBuilder beagleScreenComponentBuilder() {
  return (element, children, _) {
    final Map<String, dynamic> safeArea =
    BeagleCaster.castToMap<String, dynamic>(element.getAttributeValue('safeArea'));
    final Map<String, dynamic> navigationBarMap =
    BeagleCaster.castToMap<String, dynamic>(element.getAttributeValue('navigationBar'), defaultValue: {});
    final BeagleNavigationBar navigationBar = BeagleNavigationBar.fromJson(navigationBarMap);

    return BeagleScreen(
      key: element.getKey(),
      identifier: BeagleCaster.castToString(element.getAttributeValue('identifier'), defaultValue: null),
      safeArea: BeagleSafeArea.fromJson(safeArea),
      navigationBar: navigationBar,
      child: children.isNotEmpty ? children[0] : Container(),
    );
  };
}

ComponentBuilder beaglePullToRefreshBuilder() {
  return (element, children, view) {
    return PullToRefresh(
      key: element.getKey(),
      onPull: BeagleCaster.castToNullableFunction(element.getAttributeValue('onPull')),
      isRefreshing: BeagleCaster.castToBool(element.getAttributeValue('isRefreshing'), defaultValue: false),
      color: BeagleCaster.castToString(element.getAttributeValue('color'), defaultValue: null),
      child: children.isNotEmpty ? children[0] : Container(),
    );
  };
}

ComponentBuilder beagleSimpleFormBuilder() {
  return (element, children, view) {
    return BeagleSimpleForm(
      key: element.getKey(),
      onSubmit: BeagleCaster.castToNullableFunction(element.getAttributeValue('onSubmit')),
      onValidationError: BeagleCaster.castToNullableFunction(element.getAttributeValue('onValidationError')),
      children: BeagleCaster.castToList<Widget>(children),
    );
  };
}
