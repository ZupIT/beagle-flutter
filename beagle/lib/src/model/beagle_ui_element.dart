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

import 'dart:convert';

import 'package:beagle/beagle.dart';
import 'package:flutter/widgets.dart';

class DataContext {
  String id;
  dynamic value;

  DataContext(this.id, this.value);

  Map<String, dynamic> toJson() => {'id': id, 'value': jsonEncode(value)};
}

class BeagleUIElement {
  BeagleUIElement(this.properties);

  Map<String, dynamic> properties;

  String getId() {
    return properties['id'].toString();
  }

  Key getKey() {
    return ValueKey(properties['id'].toString());
  }

  String getType() {
    return properties['_beagleComponent_'].toString();
  }

  DataContext getContext() {
    if (!properties.containsKey('context')) {
      return null;
    }
    final Map<String, dynamic> contextMap = properties['context'];
    return DataContext(contextMap['id'], contextMap['value']);
  }

  bool hasChildren() {
    return properties.containsKey('children') &&
        // ignore: avoid_as
        (properties['children'] as List<dynamic>).isNotEmpty;
  }

  List<BeagleUIElement> getChildren() {
    if (!properties.containsKey('children')) {
      return [];
    }

    final list =
        (properties['children'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((child) => BeagleUIElement(child)).toList();
  }

  dynamic getAttributeValue(String attributeName, [dynamic defaultValue]) {
    return properties.containsKey(attributeName)
        ? properties[attributeName]
        : defaultValue;
  }

  BeagleStyle getStyle() {
    return properties.containsKey('style')
        ? BeagleStyle.fromMap(properties['style'])
        : null;
  }

  static bool isBeagleUIElement(Map<String, dynamic> json) {
    return json != null && json.containsKey("_beagleComponent_");
  }
}
