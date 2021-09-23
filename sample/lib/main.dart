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
import 'package:sample/app_design_system.dart';

Map<String, ComponentBuilder> myCustomComponents = {
  'custom:loading': (element, _, __) {
    return Center(
      key: element.getKey(),
      child: const Text('My custom loading.'),
    );
  }
};
Map<String, ActionHandler> myCustomActions = {
  'custom:log': ({action, view, element, context}) {
    debugPrint(action.getAttributeValue('message'));
  }
};

void main() {
  final localhost = Platform.isAndroid ? '10.0.2.2' : 'localhost';

  BeagleSdk.init(
    baseUrl: "https://gist.githubusercontent.com/Tiagoperes/59e831129f7d5519f06777f975cc8dd2/raw/ed2e702823c973f42bcd6170e83f85a2a4235dcd",
    environment: kDebugMode ? BeagleEnvironment.debug : BeagleEnvironment.production,
    components: {...defaultComponents, ...myCustomComponents},
    actions: myCustomActions,
    logger: DefaultLogger(),
    designSystem: AppDesignSystem(),
  );

  runApp(const MaterialApp(home: BeagleSampleApp()));
}

class BeagleSampleApp extends StatelessWidget {
  const BeagleSampleApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Beagle sample",
      theme: Theme.of(context).copyWith(
        indicatorColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
      ),
      home: Scaffold(
        // body: Text("Hello World"),
        body: RootNavigator(
          initialRoute: RemoteView("/stack1page1.json"),
          screenBuilder: (beagleWidget) => Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: beagleWidget,
          ),
        ),
      ),
    );
  }
}
