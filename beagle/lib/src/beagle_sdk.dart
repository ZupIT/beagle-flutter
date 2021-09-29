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
import 'package:beagle/src/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yoga_engine/yoga_engine.dart';
import 'package:beagle/src/default/default_actions.dart';

class BeagleSdk {
  /// Starts the BeagleService. Only a single instance of this service is allowed.
  /// The parameters are all the attributes of the class BeagleService. Please check its
  /// documentation for more details.
  static void init({
    /// Attribute responsible for informing Beagle about the current build status of the application.
    BeagleEnvironment environment,

    /// Informs the base URL used in Beagle in the application.
    String baseUrl,

    /// Interface that provides client to beagle make the requests.
    HttpClient httpClient,
    ViewClient viewClient,
    Map<String, ComponentBuilder> components,
    Map<String, ActionHandler> actions,
    NavigationController defaultNavigationController,
    Map<String, NavigationController> navigationControllers = const {},

    /// [BeagleDesignSystem] interface that provides design system to beagle components.
    BeagleDesignSystem designSystem,

    /// [BeagleImageDownloader] interface that provides image resource from network.
    BeagleImageDownloader imageDownloader,

    /// [BeagleLogger] interface that provides logger to beagle use in application.
    BeagleLogger logger,
    Map<String, Operation> operations,
    AnalyticsProvider analyticsProvider
  }) {
    Yoga.init();

    baseUrl = baseUrl ?? "";
    final urlBuilder = UrlBuilder(baseUrl);
    httpClient = httpClient ?? const DefaultHttpClient();
    logger = logger ?? DefaultEmptyLogger();
    viewClient = viewClient ?? DefaultViewClient(httpClient: httpClient, logger: logger, urlBuilder: urlBuilder);
    environment = environment ?? BeagleEnvironment.debug;
    designSystem = designSystem ?? DefaultEmptyDesignSystem();
    defaultNavigationController = defaultNavigationController ?? DefaultNavigationController(logger);
    imageDownloader =
        imageDownloader ?? DefaultBeagleImageDownloader(httpClient: httpClient);
    operations = operations ?? {};

    actions = actions == null ? defaultActions : {...defaultActions, ...actions};

    Map<String, ComponentBuilder> lowercaseComponents =
        components.map((key, value) => MapEntry(key.toLowerCase(), value));

    Map<String, ActionHandler> lowercaseActions =
        actions.map((key, value) => MapEntry(key.toLowerCase(), value));

    setupServiceLocator(
      baseUrl: baseUrl,
      httpClient: httpClient,
      viewClient: viewClient,
      environment: environment,
      components: lowercaseComponents,
      actions: lowercaseActions,
      defaultNavigationController: defaultNavigationController,
      navigationControllers: navigationControllers,
      designSystem: designSystem,
      imageDownloader: imageDownloader,
      logger: logger,
      operations: operations,
      analyticsProvider: analyticsProvider
    );
  }

  static void openScreen({
    @required BeagleRoute route,
    @required BuildContext context,
    ScreenBuilder screenBuilder,
    NavigationController initialController,
  }) async {
    await beagleServiceLocator.allReady();
    final navigator = RootNavigator(
      initialRoute: route,
      screenBuilder: screenBuilder ?? (widget, _) => widget,
      initialController: initialController,
    );
    final pageRoute = MaterialPageRoute<dynamic>(builder: (_) => navigator);
    Navigator.push(context, pageRoute);
  }
}
