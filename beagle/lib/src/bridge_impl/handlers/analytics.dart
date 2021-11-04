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
import 'package:beagle/src/bridge_impl/handlers/base.dart';
import 'package:beagle/src/bridge_impl/utils.dart';
import 'package:beagle/src/bridge_impl/js_runtime_wrapper.dart';

class BeagleJSEngineAnalyticsHandler implements BeagleJSEngineBaseHandler {
  final BeagleJsEngineJsHelpers _jsHelpers;

  BeagleJSEngineAnalyticsHandler(JavascriptRuntimeWrapper jsRuntime) : _jsHelpers = BeagleJsEngineJsHelpers(jsRuntime);

  @override
  String get channelName => 'analytics.createRecord';

  String get getConfigChannelName => 'analytics.getConfig';

  @override
  void notify(dynamic map) {
    if (beagleServiceLocator.isRegistered<AnalyticsProvider>()) {
      final analyticsProvider = beagleServiceLocator<AnalyticsProvider>();
      final record = AnalyticsRecord.fromMap(map);
      /*
       * TODO find a way to extract x,y of the component that triggered the event. Example:
       *  final componentId = analyticsRecord[analytics.component['id']];
       *  final position = findPositionByComponentId(componentId); // position.x, position.y
       */
      analyticsProvider.createRecord(record);
    }
  }

  void getConfig(dynamic map) {
    if (beagleServiceLocator.isRegistered<AnalyticsProvider>()) {
      final analyticsProvider = beagleServiceLocator<AnalyticsProvider>();
      _jsHelpers.callJsFunction(map["functionId"], analyticsProvider.getConfig().toMap());
    }
  }
}
