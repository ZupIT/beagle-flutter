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

///TODO: NEEDS ADD DOCUMENTATION
typedef ComponentBuilder = Widget Function(
    BeagleUIElement element, List<Widget> children, BeagleView view);

///TODO: NEEDS ADD DOCUMENTATION
typedef ActionHandler = void Function(BuildContext context,
    {BeagleAction? action, BeagleView? view, BeagleUIElement? element});

typedef Operation = void Function(List<dynamic> args);

abstract class BeagleService {
  /// URL to the backend providing the views (JSON) for Beagle.
  String? baseUrl;

  /// Custom client to make HTTP requests. You can use this to implement your own HTTP client,
  /// calculating your own headers, cookies, response transformation, etc. The client provided
  /// here must implement the HttpClient interface. By default, the DefaultHttpClient will be
  /// used.
  HttpClient? httpClient;

  ViewClient? viewClient;

  /// The map of components to be used when rendering a view. The key must be the
  /// `_beagleComponent_` identifier and the value must be a ComponentBuilder, which is a function
  /// that transforms a BeagleUIElement into a Widget. The key must always start with `beagle:` or
  /// `custom:`.
  Map<String, ComponentBuilder>? components;

  /// The map of custom actions. The key must be the `_beagleAction_` identifier and the value
  /// must be the action handler. The key must always start with `beagle:` or `custom:`.
  Map<String, ActionHandler>? actions;

  /// Sets the default navigation controller.
  NavigationController? defaultNavigationController;

  /// Controls the behavior of the navigator when handling events like loading, error and success.
  Map<String, NavigationController>? navigationControllers;

  /*
   * The map of custom operations that can be used to extend the capability of the Beagle expressions and are called like functions, 
   * e.g. `@{sum(1, 2)}`.
   * The keys of this object represent the operation name and the values must be the functions themselves. 
   * An operation name must contain only letters, numbers and the character _, 
   * it also must contain at least one letter or _.
   * Note: If you create custom operations using the same name of a default from Beagle, the default will be overwritten by the custom one
   */
  Map<String, Operation>? operations;

  // todo:
  /*Analytics analytics;
  LifecycleHandler lifecycles,
  AnalyticsProvider analyticsProvider,
  Map<String, Operation> customOperations,*/

  // todo: add support for the ViewContentManager

  /// Starts the Beagle Service.
  Future<void> start();
}
