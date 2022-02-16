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

/// Encapsulates a Beagle javascript HTTP request message.
class BeagleJSRequestMessage {
  late String _requestId;
  late String _url;
  late BeagleHttpMethod _method;
  late Map<String, String> _headers;
  late String? _body;

  BeagleJSRequestMessage.fromJson(Map<String, dynamic> json) {
    _requestId = json['id'];
    _url = json['url'];
    _method = _getHttpMethod(json);
    _headers = _getHeaders(json);
    _body = json['body'];
  }

  BeagleHttpMethod _getHttpMethod(Map<String, dynamic> json) {
    final String httpMethodStr = json.containsKey('method') ? json['method'].toLowerCase() : 'get';
    final beagleHttpMethod = EnumUtils.fromString<BeagleHttpMethod>(BeagleHttpMethod.values, httpMethodStr);
    return beagleHttpMethod as BeagleHttpMethod;
  }

  Map<String, String> _getHeaders(Map<String, dynamic> json) =>
      json.containsKey('headers') ? (json['headers'] as Map<String, dynamic>).cast<String, String>() : {};

  String get requestId => _requestId;

  BeagleRequest toRequest() => BeagleRequest(_url, method: _method, headers: _headers, body: _body);
}
