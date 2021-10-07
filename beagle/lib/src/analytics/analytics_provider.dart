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

import 'package:beagle/src/analytics/analytics_config.dart';
import 'analytics_record.dart';

/// This interface is used to start the configuration of analytics, without this the analytics will not be reported.
abstract class AnalyticsProvider {
  /// This function is called to record the reports.
  /// @param record is an [AnalyticsRecord] generated when a screen is loaded or a action is executed
  /// according the config passing on getConfig function.
  void createRecord(AnalyticsRecord record);

  /// This function is called to get the AnalyticsConfig.
  /// @return is an AnalyticsConfig
  AnalyticsConfig getConfig();
}
