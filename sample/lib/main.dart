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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sample/beagle.dart';

void main() {
  runApp(BeagleProvider(
    beagle: beagleService,
    child: MaterialApp(
      title: 'Beagle Sample',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        indicatorColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0,
        ),
      ),
      home: BeagleSampleApp()
    )
  ));
}

class BeagleSampleApp extends StatelessWidget {
  const BeagleSampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => openBeagleScreen(route: RemoteView('/components'), context: context),
          child: Text('Start beagle flow'),
        ),
      ),
    );
  }
}
