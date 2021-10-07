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

const LOADING_COMPONENT_NAME = "custom:loading";
const ERROR_COMPONENT_NAME = "custom:error";

class DefaultNavigationController implements NavigationController {
  const DefaultNavigationController(this._logger);

  final BeagleLogger _logger;

  @override
  void onError({
    BeagleView? view,
    BuildContext? context,
    dynamic error,
    StackTrace? stackTrace,
    RetryFunction? retry,
    Function? completeNavigation,
  }) {
    _logger.error(
        "The following error was encountered while trying to navigate: ${error.toString()}");
    _logger.error(stackTrace.toString());
    BeagleUIElement component =
        BeagleUIElement({"_beagleComponent_": ERROR_COMPONENT_NAME});
    view?.getRenderer().doFullRender(component);
  }

  @override
  void onLoading(
      {BeagleView? view, BuildContext? context, Function? completeNavigation}) {
    if (completeNavigation != null) completeNavigation();
    BeagleUIElement component =
        BeagleUIElement({"_beagleComponent_": LOADING_COMPONENT_NAME});
    view?.getRenderer().doFullRender(component);
  }

  @override
  void onSuccess(
      {BeagleView? view, BuildContext? context, BeagleUIElement? screen}) {
    if (screen != null) view?.getRenderer().doFullRender(screen);
  }
}
