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

class BeagleCaster {
  static T cast<T>(dynamic value, T defaultValue) {
    if (value != null && value is T) return value;
    return defaultValue;
  }

  static bool castToBool(dynamic value, {bool? defaultValue}) {
    return cast<bool>(value, defaultValue ?? false);
  }

  static String castToString(dynamic value, {String? defaultValue}) {
    final defaultValueNullPrevented = defaultValue ?? '';

    if (value == null) return defaultValueNullPrevented;
    if (value is bool || value is double || value is num || value is int) {
      return value.toString();
    }

    return cast<String>(value, defaultValueNullPrevented);
  }

  static double castToDouble(dynamic value, {double? defaultValue}) {
    final defaultValueNullPrevented = defaultValue ?? 0.0;

    if (value == null) return defaultValueNullPrevented;
    if (value is num || value is int) return value.toDouble();

    return cast<double>(value, defaultValueNullPrevented);
  }

  static int castToInt(dynamic value, {int? defaultValue}) {
    final defaultValueNullPrevented = defaultValue ?? 0;

    if (value == null) return defaultValueNullPrevented;
    if (value is num || value is double) return value.toInt();

    return cast<int>(value, defaultValue ?? 0);
  }

  static Function castToFunction(dynamic value, {Function? defaultValue}) {
    return cast<Function>(value, defaultValue ?? () {});
  }

  static Function? castToNullableFunction(dynamic value,
      {Function? defaultValue}) {
    return cast<Function?>(value, defaultValue);
  }

  static Map<T, X> castToMap<T, X>(dynamic value, {Map<T, X>? defaultValue}) {
    return cast<Map<T, X>>(value, defaultValue ?? {});
  }

  static List<T> castToList<T>(dynamic value, {List<T>? defaultValue}) {
    return cast<List<T>>(value, defaultValue ?? []);
  }
}
