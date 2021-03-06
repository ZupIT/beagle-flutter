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

import 'package:beagle/beagle.dart';

/// BeagleRequest is used to do requests.
class BeagleRequest {
  BeagleRequest(this.url, {BeagleHttpMethod? method, Map<String, String>? headers, String? body}) {
    this.method = method ?? BeagleHttpMethod.get;
    this.headers = headers ?? {};
    this.body = body ?? '';
  }

  /// Server URL
  late String url;

  /// HTTP method
  late BeagleHttpMethod method;

  /// Header items for the request.
  late Map<String, String> headers;

  /// Content that will be deliver with the request.
  late String? body;
}
