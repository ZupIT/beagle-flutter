/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
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
/// The accessibility will enable a textual information to explain the view content in case a screen reader is used.
class BeagleAccessibility {
  BeagleAccessibility({
    this.accessible = true,
    this.accessibilityLabel,
    this.isHeader = false,
  });

  /// Informs when the accessibilityLabel is available.
  /// By default is kept as true and it indicates that the view is an accessibility element.
  bool accessible = true;

  /// Provides a textual description of the widget.
  String? accessibilityLabel;

  /// Indicates that this subtree represents a header.
  /// By default is kept as false.
  bool isHeader = false;
  BeagleAccessibility.fromMap(Map<String, dynamic> map) {
    if(map.containsKey('accessible')) {
      accessible = map['accessible'];
    } else {
      accessible = true;
    }

    accessibilityLabel = map['accessibilityLabel'];

    if(map.containsKey('isHeader')) {
      isHeader = map['isHeader'];
    } else {
      isHeader = false;
    }

  }
}
