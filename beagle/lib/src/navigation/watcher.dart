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

import 'dart:async';
import 'dart:convert';

import '../../beagle.dart';

const WATCH_PATH = '/__watch';
const TIME_PROPERTY = 'time';
const MIN_INTERVAL_MS = 100;

/// This creates a timer that runs in an interval. Each time it runs, it checks if there's a new
/// version of the backend available. If there is, it runs the onUpdate function.
class Watcher {
  Watcher({
    required int intervalMS,
    required this.httpClient,
    required this.baseUrl,
    required this.onUpdate,
  }) : intervalMS = intervalMS < MIN_INTERVAL_MS ? MIN_INTERVAL_MS : intervalMS;

  final int intervalMS;
  final HttpClient httpClient;
  final String baseUrl;
  final void Function() onUpdate;

  int time = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  Timer? timer;

  void start() {
    if (timer != null && timer!.isActive) return;
    timer = Timer.periodic(Duration(milliseconds: intervalMS), (timer) async {
      try {
        final response = await httpClient.sendRequest(BeagleRequest('$baseUrl$WATCH_PATH'));
        final parsed = json.decode(response.body.toString());
        if ((parsed[TIME_PROPERTY] ?? 0) > time) {
          time = parsed[TIME_PROPERTY];
          onUpdate();
        }
      } catch (_) {}
    });
  }

  void stop() {
    timer?.cancel();
  }
}
