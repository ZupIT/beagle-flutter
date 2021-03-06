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

import 'dart:io';

import 'package:beagle/beagle.dart';
import 'package:flutter/material.dart';

class _MyCustomLoading extends ComponentBuilder {
  @override
  Widget buildForBeagle(element, _, __) {
    return Center(key: element.getKey(), child: Text('My custom loading.'));
  }
}

void main() {
  final localhost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  final beagleService = BeagleService(
    baseUrl: 'http://$localhost:8080',
    components: {'custom:loading': () => _MyCustomLoading()},
  );

  runApp(BeagleProvider(beagle: beagleService, child: BeagleExample()));
}

class BeagleExample extends StatelessWidget {
  const BeagleExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Beagle example'),
        ),
        body: ElevatedButton(
          onPressed: () => openBeagleScreen(route: RemoteView('/components'), context: context),
          child: Text("Start Beagle flow"),
        ),
      ),
    );
  }
}
