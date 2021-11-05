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

BeagleView findAncestorBeagleView(BuildContext context) {
  final widget = context.findAncestorWidgetOfExactType<BeagleWidget>();
  if (widget == null) {
    throw ErrorDescription('Could not find any BeagleWidget in the current context.');
  }
  return widget.view;
}

BeagleService findBeagleService(BuildContext context) {
  final provider = context.findAncestorStateOfType<BeagleProviderState>();
  if (provider == null) {
    throw ErrorDescription(
        'A component that depends on Beagle has been used without a parent BeagleProvider. Please be sure to use a BeagleProvider to wrap your application code.');
  }
  /* provider.beagle can never be null. The provider guarantees this by not rendering any child until every async
  operation has completed. */
  return provider.beagle;
}
