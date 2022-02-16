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

abstract class BeagleRoute {
  NavigationContext? navigationContext;
}

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

class RemoteView implements BeagleRoute {
  RemoteView(this.url, {this.fallback, this.shouldPrefetch, this.httpAdditionalData, this.navigationContext});

  final String url;
  final BeagleUIElement? fallback;
  final bool? shouldPrefetch;
  final HttpAdditionalData? httpAdditionalData;
  @override
  NavigationContext? navigationContext;

  static bool isRemoteView(Map<String, dynamic> json) {
    return json.containsKey("url");
  }

  factory RemoteView.fromJson(Map<String, dynamic> elementJson, Map<String, dynamic>? navigationContextJson) {
    return RemoteView(
      elementJson["url"],
      fallback: elementJson.containsKey("fallback") ? BeagleUIElement(elementJson["fallback"]) : null,
      httpAdditionalData: elementJson.containsKey("httpAdditionalData")
          ? HttpAdditionalData.fromJson(elementJson["httpAdditionalData"])
          : null,
      navigationContext: navigationContextJson != null ? NavigationContext.fromJson(navigationContextJson) : null,
    );
  }
}

class LocalView implements BeagleRoute {
  LocalView(this.screen, [this.navigationContext]);

  static bool isLocalView(Map<String, dynamic> json) {
    return json.containsKey("screen");
  }

  factory LocalView.fromJson(Map<String, dynamic> elementJson, Map<String, dynamic>? navigationContextJson) {
    return LocalView(
      BeagleUIElement(elementJson["screen"]),
      navigationContextJson != null ? NavigationContext.fromJson(navigationContextJson) : null,
    );
  }

  final BeagleUIElement screen;
  @override
  NavigationContext? navigationContext;
}
