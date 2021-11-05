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

import 'dart:io';

import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_analytics_provider.dart';
import 'app_design_system.dart';

final localhost = Platform.isAndroid ? '10.0.2.2' : 'localhost';

Map<String, ComponentBuilder> myCustomComponents = {
  'custom:loading': (element, _, __) {
    return Center(key: element.getKey(), child: Text('My custom loading.'));
  }
};
Map<String, ActionHandler> myCustomActions = {
  'custom:log': ({required action, required view, required element, required context}) {
    debugPrint(action.getAttributeValue('message'));
  }
};

final beagleService = BeagleService(
  baseUrl: 'http://$localhost:8080',
  environment: kDebugMode ? BeagleEnvironment.debug : BeagleEnvironment.production,
  components: {...defaultComponents, ...myCustomComponents},
  actions: {...myCustomActions, ...defaultActions},
  analyticsProvider: AppAnalyticsProvider(),
  logger: DefaultLogger(),
  designSystem: AppDesignSystem(),
);
