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
import 'package:beagle/src/default/utils/view_client.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class DefaultViewClient implements ViewClient {
  DefaultViewClient({required this.httpClient, required this.logger, required this.urlBuilder});

  final HttpClient httpClient;
  final BeagleLogger logger;
  final UrlBuilder urlBuilder;
  final _preFetched = <String, BeagleUIElement>{};
  final _defaultNavigateActions = ['beagle:pushView', 'beagle:pushStack', 'beagle:resetStack', 'beagle:resetApplication'];

  String? _convertBodyToString(dynamic body) {
    if (body is String) return body;
    if (body is Map) return json.encoder.convert(body);
    return null;
  }

  Future<BeagleUIElement> fetchView(RemoteView route) async {
    final response = await httpClient.sendRequest(BeagleRequest(
      urlBuilder.build(route.url),
      method: route.httpAdditionalData?.method,
      headers: route.httpAdditionalData?.headers,
      body: _convertBodyToString(route.httpAdditionalData?.body),
    ));

    if (response.status < 400) return BeagleUIElement(json.decode(response.body));
    if (route.fallback != null) return route.fallback!;
    throw ErrorDescription(
        "${route.httpAdditionalData?.method ?? "GET"} ${urlBuilder.build(route.url)}. Response status: ${response.status}");
  }

  @override
  Future<BeagleUIElement> fetch(RemoteView route) async {
    BeagleUIElement view;
    if (_preFetched[route.url] != null) {
      view = _preFetched[route.url]!;
      _preFetched.remove(route.url);
    } else {
      view = await fetchView(route);
    }
    _processPrefetches(view);
    return view;
  }

Future<void> _requestPrefetch(String url) async {
  final view = await fetchView(RemoteView(urlBuilder.build(url)));
  _preFetched.addAll({url: view});
}

void _processPrefetches(BeagleUIElement view) async {
    final actions = findActionsInView(view);
    for (var action in actions) {
      final isNavigationAction = _defaultNavigateActions.contains(action.values.first);
      if (!isNavigationAction) continue;
      final url = action['route']?['url'];
      final hasValidUrl = validateUrl(url, logger);
      final shouldPrefetch = action['route']?['shouldPrefetch'] == true;
      if (hasValidUrl && shouldPrefetch) {
        _requestPrefetch(url);
      }
    }
  }
}
