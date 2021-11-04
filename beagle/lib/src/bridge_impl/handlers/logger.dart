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
import 'package:beagle/src/bridge_impl/handlers/base.dart';

class BeagleJSEngineLoggerHandler implements BeagleJSEngineBaseHandler {
  @override
  String get channelName => 'logger';

  @override
  void notify(dynamic loggerMessage) {
    final logger = beagleServiceLocator<BeagleLogger>();
    final message = loggerMessage['message'];
    final level = loggerMessage['level'];

    if (level == 'info') {
      logger.info(message);
    } else if (level == 'warning') {
      logger.warning(message);
    } else if (level == 'error') {
      logger.error(message);
    }
  }
}
