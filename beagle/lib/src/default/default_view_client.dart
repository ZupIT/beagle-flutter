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
import 'package:beagle/src/interface/view_client.dart';
import 'package:beagle/src/model/beagle_ui_element.dart';
import 'package:beagle/src/model/route.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class DefaultViewClient implements ViewClient {
  DefaultViewClient({required this.httpClient, required this.logger, required this.urlBuilder});

  final HttpClient httpClient;
  final BeagleLogger logger;
  final UrlBuilder urlBuilder;
  final Map<String, BeagleUIElement> _preFetched = {};

  Future<BeagleUIElement> fetchView(RemoteView route) async {
    final response = await httpClient.sendRequest(BeagleRequest(
      urlBuilder.build(route.url),
      method: route.httpAdditionalData?.method,
      headers: route.httpAdditionalData?.headers,
      body: route.httpAdditionalData?.body,
    ));

    if (response.status >= 400) {
      throw ErrorDescription(
          "${route.httpAdditionalData?.method ?? "GET"} ${urlBuilder.build(route.url)}. Response status: ${response.status}");
    }

    return BeagleUIElement(json.decode(response.body));
  }

  @override
  Future<BeagleUIElement> fetch(RemoteView route) async {
    if (_preFetched[route.url] != null) {
      final result = _preFetched[route.url] as BeagleUIElement;
      _preFetched.remove(route.url);
      return result;
    }
    return await fetchView(route);
  }

  @override
  void preFetch(RemoteView route) async {
    try {
      _preFetched[route.url] = await fetchView(route);
    } catch (error) {
      logger.error("Error while pre-fetching view: ${route.url}\n$error");
    }
  }
}
