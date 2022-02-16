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
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'bridge_impl/beagle_js.dart';
import 'bridge_impl/beagle_view_js.dart';

import 'package:beagle/src/default/default_actions.dart';

import 'bridge_impl/global_context_js.dart';

///TODO: NEEDS ADD DOCUMENTATION
typedef ActionHandler = void Function({
  required BeagleAction action,
  required BeagleView view,
  required BeagleUIElement element,
  required BuildContext context,
});

typedef Operation = dynamic Function(List<dynamic> args);

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
    required Map<String, ComponentBuilder Function()> components,

    /// todo documentation
    UrlBuilder? urlBuilder,

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

    /// Sets the environment: debug or production. Beagle will log more data and also enables hot reloading
    /// when the environment is BeagleEnvironment.debug. The hot reloading also depends on the property watchInterval,
    /// which by default, disables it.
    ///
    /// If not set, the environment is determined by Flutter's global constant kDebugMode.
    this.environment = kDebugMode ? BeagleEnvironment.debug : BeagleEnvironment.production,

    /// Enables or disables the automatic styling of all components according to the "style" property. Be aware that
    /// setting this to false will break most default Beagle components. Set this to false if you need to create your
    /// own layout engine.
    this.enableStyles = true,

    /// Allows Beagle's hot reloading. This setting is only valid when the environment is BeagleEnvironment.debug.
    ///
    /// This sets an interval for checking if there's a new version of the backend available. If there is, the current
    /// page is updated with the new content.
    ///
    /// This interval is given in milliseconds and must be greater than 0. When 0, Beagle understands that it should't
    /// hot reload. The default value is 0 (disabled). Any value lower than 100, but 0, is rounded to 100.
    ///
    /// Attention: this feature only works in conjunction with the backend-typescript for Beagle. It doesn't work
    /// for any other type of backend.
    this.watchInterval = 0,
  })  : urlBuilder = urlBuilder ?? UrlBuilder(baseUrl),
        components = _toLowercaseKeys(components),
        actions = _toLowercaseKeys({...defaultActions, ...(actions ?? {})}) {
    this.imageDownloader = imageDownloader ?? DefaultBeagleImageDownloader(httpClient: httpClient);
    this.viewClient =
        viewClient ?? DefaultViewClient(httpClient: httpClient, logger: logger, urlBuilder: this.urlBuilder);
    this.defaultNavigationController = defaultNavigationController ?? DefaultNavigationController(logger);
    js = BeagleJS(this);
    globalContext = GlobalContextJS(js.engine);
  }

  // services
  final UrlBuilder urlBuilder;
  late final GlobalContext globalContext;
  late final BeagleImageDownloader imageDownloader;
  final BeagleLogger logger;
  final AnalyticsProvider? analyticsProvider;
  final HttpClient httpClient;
  late final ViewClient viewClient;
  late final BeagleJS js;

  // other properties
  final String baseUrl;
  final Map<String, ComponentBuilder Function()> components;
  final Map<String, ActionHandler> actions;
  late final NavigationController defaultNavigationController;
  final Map<String, NavigationController> navigationControllers;
  final Map<String, Operation> operations;
  final BeagleEnvironment environment;
  final bool enableStyles;
  final int watchInterval;

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
