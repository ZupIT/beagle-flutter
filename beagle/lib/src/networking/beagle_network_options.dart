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

import 'dart:convert';
import 'package:beagle/beagle.dart';

class BeagleNetworkOptions {
  BeagleNetworkOptions({this.method, this.headers});

  BeagleHttpMethod? method;
  Map<String, String>? headers;

  static String toJsonEncode(BeagleNetworkOptions? networkOptions) {
    final params = <String, dynamic>{};

    if (networkOptions == null) {
      return jsonEncode(params);
    }

    if (networkOptions.method != null) {
      params['method'] = EnumUtils.getEnumValueName(networkOptions.method);
    }
    if (networkOptions.headers != null) {
      params['headers'] = networkOptions.headers;
    }

    return jsonEncode(params);
  }
}
