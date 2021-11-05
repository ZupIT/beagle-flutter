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
import 'bridge_impl/beagle_js.dart';
import 'bridge_impl/beagle_view_js.dart';

import 'package:beagle/src/default/default_actions.dart';

import 'bridge_impl/global_context_js.dart';

///TODO: NEEDS ADD DOCUMENTATION
typedef ComponentBuilder = Widget Function(
  BeagleUIElement element,
  List<Widget> children,
  BeagleView view,
);

///TODO: NEEDS ADD DOCUMENTATION
typedef ActionHandler = void Function({
  required BeagleAction action,
  required BeagleView view,
  required BeagleUIElement element,
  required BuildContext context,
});

typedef Operation = void Function(List<dynamic> args);

Map<String, T> _toLowercaseKeys<T>(Map<String, T> dictionary) {
  return dictionary.map((key, value) => MapEntry(key.toLowerCase(), value));
}

class BeagleViewWidget {
  BeagleViewWidget(this.view, this.widget);
  final BeagleView view;
  final BeagleWidget widget;
}

class BeagleService {
  BeagleService({
    /// URL to the backend providing the views (JSON) for Beagle.
    required this.baseUrl,
    /// The map of components to be used when rendering a view. The key must be the
    /// `_beagleComponent_` identifier and the value must be a ComponentBuilder, which is a function
    /// that transforms a BeagleUIElement into a Widget. The key must always start with `beagle:` or
    /// `custom:`.
    required Map<String, ComponentBuilder> components,
    /// todo documentation
    UrlBuilder? urlBuilder,
    /// todo documentation
    BeagleDesignSystem? designSystem,
    /// todo documentation
    BeagleImageDownloader? imageDownloader,
    /// todo documentation
    this.logger = const DefaultLogger(),
    /// todo documentation
    this.analyticsProvider,
    /// Custom client to make HTTP requests. You can use this to implement your own HTTP client,
    /// calculating your own headers, cookies, response transformation, etc. The client provided
    /// here must implement the HttpClient interface. By default, the DefaultHttpClient will be
    /// used.
    this.httpClient = const DefaultHttpClient(),
    /// todo documentation
    ViewClient? viewClient,
    /// The map of custom actions. The key must be the `_beagleAction_` identifier and the value
    /// must be the action handler. The key must always start with `beagle:` or `custom:`.
    Map<String, ActionHandler>? actions,
    /// Sets the default navigation controller.
    NavigationController? defaultNavigationController,
    /// Controls the behavior of the navigator when handling events like loading, error and success.
    this.navigationControllers = const {},
    /// todo documentation
    this.operations = const {},
    /// todo documentation
    this.environment = BeagleEnvironment.debug,
}) :
    urlBuilder = urlBuilder ?? UrlBuilder(baseUrl),
    components = _toLowercaseKeys(components),
    actions = _toLowercaseKeys({...defaultActions, ...(actions ?? {})}),
    designSystem = designSystem ?? DefaultEmptyDesignSystem()
  {
    this.imageDownloader = imageDownloader ?? DefaultBeagleImageDownloader(httpClient: httpClient);
    this.viewClient = viewClient ?? DefaultViewClient(httpClient: httpClient, logger: logger, urlBuilder: this.urlBuilder);
    this.defaultNavigationController = defaultNavigationController ?? DefaultNavigationController(logger);
    js = BeagleJS(this);
    globalContext = GlobalContextJS(js.engine);
  }

  // services
  final UrlBuilder urlBuilder;
  late final GlobalContext globalContext;
  final BeagleDesignSystem designSystem;
  late final BeagleImageDownloader imageDownloader;
  final BeagleLogger logger;
  final AnalyticsProvider? analyticsProvider;
  final HttpClient httpClient;
  late final ViewClient viewClient;
  final yoga = BeagleYogaFactory();
  late final BeagleJS js;

  // other properties
  final String baseUrl;
  final Map<String, ComponentBuilder> components;
  final Map<String, ActionHandler> actions;
  late final NavigationController defaultNavigationController;
  final Map<String, NavigationController> navigationControllers;
  final Map<String, Operation> operations;
  final BeagleEnvironment environment;

  // factory methods
  BeagleViewWidget createView(BeagleNavigator navigator) {
    final view = BeagleViewJS(js.engine, navigator);
    final widget = BeagleWidget(view);
    return BeagleViewWidget(view, widget);
  }

  StackNavigator createStackNavigator({
    required BeagleRoute initialRoute,
    required ScreenBuilder screenBuilder,
    required NavigationController controller,
    required BeagleNavigator rootNavigator,
  }) {
    return StackNavigator(
      initialRoute: initialRoute,
      screenBuilder: screenBuilder,
      rootNavigator: rootNavigator,
      beagle: this,
      controller: controller,
    );
  }
}
