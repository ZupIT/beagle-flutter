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

class TemplateManagerItem {
  TemplateManagerItem({
    this.condition,
    required this.view,
  });

  String? condition;
  BeagleUIElement view;

  Map<String, dynamic> toJson() => {
        _jsonBeagleCase: condition,
        _jsonBeagleView: view.properties,
      };

  factory TemplateManagerItem.fromJson(Map<String, dynamic> json) {
    return TemplateManagerItem(
      condition: json[_jsonBeagleCase],
      view: BeagleUIElement(json[_jsonBeagleView]),
    );
  }

  static List<TemplateManagerItem> fromJsonList(List<dynamic> items) {
    return items.map((json) => TemplateManagerItem.fromJson(json)).toList();
  }

  static const _jsonBeagleCase = 'case';
  static const _jsonBeagleView = 'view';
}

class TemplateManager {
  TemplateManager({
    this.defaultTemplate,
    this.templates,
  });

  BeagleUIElement? defaultTemplate;
  List<TemplateManagerItem>? templates;

  Map<String, dynamic> toJson() => {
        'default': defaultTemplate?.properties,
        'templates': templates?.map((t) => t.toJson()).toList() ?? [],
      };
}
