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
import 'package:beagle_components/beagle_components.dart';
import 'package:beagle_components/src/utils/build_context_utils.dart';
import 'package:flutter/widgets.dart';

class BeagleSubmitForm {
  static void submit(
    BuildContext buildContext,
    BeagleUIElement element,
    /// used for testing purposes only
    [BuildContext? Function(String)? findContextByWidgetKey]
  ) {
    findContextByWidgetKey = findContextByWidgetKey ?? buildContext.findBuildContextForWidgetKey;
    final beagle = findBeagleService(buildContext);
    final BuildContext? buildContextOrigin = findContextByWidgetKey(element.getId());
    if (buildContextOrigin != null) {
      final simpleFormState = buildContextOrigin.findAncestorStateOfType<BeagleSimpleFormState>();
      if (simpleFormState != null) {
        simpleFormState.submit();
      } else {
        beagle.logger.error('Could not find a parent SimpleForm to submit.');
      }
    } else {
      beagle.logger.error('Could find a component with the id ${element.getId()} in the current tree.');
    }
  }
}
