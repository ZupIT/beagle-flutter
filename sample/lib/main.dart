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

import 'dart:io' show Platform;
import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sample/app_analytics_provider.dart';
import 'package:sample/app_design_system.dart';

Map<String, ComponentBuilder> myCustomComponents = {
  'custom:loading': (element, _, __) => Center(key: element.getKey(), child: Text('My custom loading.'))
};

Map<String, ActionHandler> myCustomActions = {
  'custom:log': ({required action, required view, required element, required context}) {
    debugPrint(action.getAttributeValue('message'));
  }
};

void main() {
  final localhost = Platform.isAndroid ? '10.0.2.2' : 'localhost';

  BeagleSdk.init(
    baseUrl: 'http://$localhost:8080',
    environment: kDebugMode ? BeagleEnvironment.debug : BeagleEnvironment.production,
    components: {...defaultComponents, ...myCustomComponents},
    actions: {...myCustomActions, ...defaultActions},
    analyticsProvider: AppAnalyticsProvider(),
    logger: DefaultLogger(),
    designSystem: AppDesignSystem(),
  );

  runApp(MaterialApp(home: BeagleSampleApp()));
}

class BeagleSampleApp extends StatelessWidget {
  const BeagleSampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beagle Sample',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        indicatorColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => BeagleSdk.openScreen(route: RemoteView('/components'), context: context),
            child: Text('Start beagle flow'),
          ),
        ),
      ),
    );
  }
}
