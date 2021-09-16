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
import 'package:beagle_components/beagle_components.dart';
import 'package:beagle_components/src/utils/build_context_utils.dart';
import 'package:flutter/widgets.dart';

class BeagleSubmitForm {
  static void submit(BuildContext buildContext, BeagleUIElement element) {
      final BuildContext buildContextOrigin = buildContext.findBuildContextForWidgetKey(element.getId());
      if(buildContextOrigin != null) {
        final BeagleSimpleForm beagleSimpleForm = buildContextOrigin.findAncestorWidgetOfExactType();
        final beagleSimpleFormState = BeagleSimpleForm.of(buildContextOrigin);
        if (beagleSimpleForm != null && beagleSimpleFormState != null) {
          beagleSimpleFormState.submit();
        } else {
          beagleServiceLocator<BeagleLogger>()
              .error('Not found simple form in the parents');
        }
      } else {
        beagleServiceLocator<BeagleLogger>()
            .error('Not found buildContext for element with id ${element.getId()}');
      }
  }

}
