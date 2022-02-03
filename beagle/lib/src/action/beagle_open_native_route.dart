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
import 'package:flutter/material.dart';

class BeagleOpenNativeRoute {
  factory BeagleOpenNativeRoute() {
    return _instance;
  }

  BeagleOpenNativeRoute._constructor();

  static final BeagleOpenNativeRoute _instance = BeagleOpenNativeRoute._constructor();

  void navigate(BuildContext buildContext, String routeName, Map<String, String> data) {
    try {
      // we need to add this route to the first navigator above the root Beagle navigator
      final rootNavigator = buildContext.findAncestorStateOfType<RootNavigatorState>();
      // if, for some reason, the root Beagle navigator is not available, use the first navigator in the context
      final targetNavigator = Navigator.of(rootNavigator == null ? buildContext : rootNavigator.context);
      targetNavigator.pushNamed(routeName, arguments: data);
    } catch (err) {
      final logger = findBeagleService(buildContext).logger;
      logger.error('Error: $err while trying to navigate to $routeName');
    }
  }
}
