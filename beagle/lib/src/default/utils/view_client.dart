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

List<Map<String, dynamic>> findActionsInView(BeagleUIElement value) {
  List<Map<String, dynamic>> actions = [];
    value.properties.forEach((String key, dynamic data) {
      actions = [...actions, ...findActionsInStructure(data)];
    });
  return actions;
}

List<Map<String, dynamic>> findActionsInStructure(dynamic structure) {
  if (structure is Map<String, dynamic>) {
    return findActionsInMap(structure);
  }
  if (structure is List<dynamic>) {
    return findActionsInArray(structure);
  }
  return [];
}

List<Map<String, dynamic>> findActionsInMap(Map<String, dynamic> map) {
  if (map.containsKey("_beagleAction_")) return [map];
  List<Map<String, dynamic>> actions = [];
  map.forEach((key, value) {
      actions.addAll(findActionsInStructure(value));
  });
 return actions;
}

List<Map<String, dynamic>> findActionsInArray(List<dynamic> array) {
  List<Map<String, dynamic>> actions = [];
  for (var value in array) {
    actions.addAll(findActionsInStructure(value));
  }
  return actions;
}

bool validateUrl(String url, BeagleLogger logger) {
  if (url == '') return false;
  RegExp regExp = RegExp(
    r'/@\{.+\}/',
  );
  final isDynamic = regExp.hasMatch(url);
  if (isDynamic) logger.info('Dynamic URLs cannot be pre-fetched: $url');
  return !isDynamic;
}
