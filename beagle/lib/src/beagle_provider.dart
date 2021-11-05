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
import 'package:flutter/cupertino.dart';
import 'package:yoga_engine/yoga_engine.dart';

class BeagleProvider extends StatefulWidget {
  BeagleProvider({required this.beagle, required this.child, this.yogaInitializer = Yoga.init});

  final BeagleService beagle;
  final Widget child;
  /// used only for testing purposes
  final void Function() yogaInitializer;

  @override
  BeagleProviderState createState() => BeagleProviderState(beagle, yogaInitializer);
}

class BeagleProviderState extends State<BeagleProvider> {
  BeagleProviderState(this.beagle, [this.yogaInitializer = Yoga.init]);

  final BeagleService beagle;
  final void Function() yogaInitializer;
  bool _isReady = false;

  Future<void> _start() async {
    yogaInitializer();
    await beagle.js.start();
    setState(() {
      _isReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  Widget build(BuildContext context) {
    return _isReady ? widget.child : const SizedBox.shrink();
  }
}
