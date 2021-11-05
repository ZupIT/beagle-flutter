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
import 'package:flutter/widgets.dart';

class BeagleProviderMock extends BeagleProvider {
  BeagleProviderMock({required BeagleService beagle, required Widget child}) : super(beagle: beagle, child: child);

  @override
  BeagleProviderState createState() => BeagleProviderStateMock(beagle);
}

class BeagleProviderStateMock extends BeagleProviderState {
  BeagleProviderStateMock(BeagleService beagle) : super(beagle);

  @override
  // ignore: must_call_super
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
