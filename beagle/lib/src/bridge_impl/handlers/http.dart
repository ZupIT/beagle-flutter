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

import 'package:beagle/src/bridge_impl/beagle_js_request_message.dart';
import 'package:beagle/src/bridge_impl/handlers/base.dart';
import 'package:beagle/src/networking/beagle_request.dart';

typedef HttpListener = void Function(String requestId, BeagleRequest request);

class BeagleJSEngineHttpHandler implements BeagleJSEngineBaseHandler {
  HttpListener? _listener;

  void setListener(HttpListener listener) => _listener = listener;

  @override
  String get channelName => 'httpClient.request';

  @override
  void notify(dynamic requestMessage) {
    if (_listener == null) {
      return;
    }

    final jsRequestMessage = BeagleJSRequestMessage.fromJson(requestMessage);
    _listener!(jsRequestMessage.requestId, jsRequestMessage.toRequest());
  }
}
