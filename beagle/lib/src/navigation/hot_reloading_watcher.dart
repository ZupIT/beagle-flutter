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

import 'package:web_socket_channel/web_socket_channel.dart';

const _RELOAD_MESSAGE = 'reload';
const _STARTUP_MESSAGE = '{"platform":"Flutter"}';

/// This creates a websocket connection to the hot reloading server. Everytime a new version of the backend becomes
/// available, it runs the onUpdate function.
class HotReloadingWatcher {
  static final HotReloadingWatcher _singleton = HotReloadingWatcher._internal();

  factory HotReloadingWatcher() {
    return _singleton;
  }

  HotReloadingWatcher._internal();

  bool _hasStarted = false;
  final List<void Function()> _listeners = [];

  void _runListeners() {
    for(var listener in _listeners) {
      listener();
    }
  }

  void start(String url) {
    if (_hasStarted) return;
    final channel = WebSocketChannel.connect(Uri.parse(url));
    channel.sink.add(_STARTUP_MESSAGE);
    channel.stream.listen(
      (data) {
        if (data == _RELOAD_MESSAGE) _runListeners();
      },
      onError: (_) => print('[Beagle Hot Reloading] Can\'t connect to the hot reloading server.'),
    );
    _hasStarted = true;
  }

  void Function() addListener(void Function() listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }
}
