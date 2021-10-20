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

abstract class BeagleRoute {}

class HttpAdditionalData {
  const HttpAdditionalData({
    this.method,
    this.headers,
    this.body,
  });

  factory HttpAdditionalData.fromJson(Map<String, dynamic> json) {
    return HttpAdditionalData(method: json["method"], headers: json["headers"], body: json["body"]);
  }

  final BeagleHttpMethod? method;
  final Map<String, String>? headers;
  final dynamic body;
}

class RemoteView extends BeagleRoute {
  RemoteView(this.url, {this.fallback, this.shouldPrefetch, this.httpAdditionalData});

  final String url;
  final BeagleUIElement? fallback;
  final bool? shouldPrefetch;
  final HttpAdditionalData? httpAdditionalData;

  static bool isRemoteView(Map<String, dynamic> json) {
    return json.containsKey("url");
  }

  factory RemoteView.fromJson(Map<String, dynamic> json) {
    return RemoteView(
      json["url"],
      fallback: json.containsKey("fallback") ? BeagleUIElement(json["fallback"]) : null,
      httpAdditionalData:
          json.containsKey("httpAdditionalData") ? HttpAdditionalData.fromJson(json["httpAdditionalData"]) : null,
    );
  }
}

class LocalView extends BeagleRoute {
  LocalView(this.screen);

  static bool isLocalView(Map<String, dynamic> json) {
    return json.containsKey("screen");
  }

  factory LocalView.fromJson(Map<String, dynamic> json) {
    return LocalView(BeagleUIElement(json["screen"]));
  }

  final BeagleUIElement screen;
}
