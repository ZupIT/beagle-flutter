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
import 'package:flutter_js/flutter_js.dart';
import 'package:get_it/get_it.dart';

import 'bridge_impl/beagle_js_engine.dart';
import 'bridge_impl/beagle_service_js.dart';
import 'bridge_impl/beagle_view_js.dart';
import 'bridge_impl/global_context_js.dart';
import 'bridge_impl/js_runtime_wrapper.dart';

final GetIt beagleServiceLocator = GetIt.instance;

void setupServiceLocator(
    {required String baseUrl,
    required BeagleEnvironment environment,
    required HttpClient httpClient,
    required ViewClient viewClient,
    required Map<String, ComponentBuilder> components,
    required bool useBeagleHeaders,
    required Map<String, ActionHandler> actions,
    required NavigationController defaultNavigationController,
    required Map<String, NavigationController> navigationControllers,
    required BeagleDesignSystem designSystem,
    required BeagleImageDownloader imageDownloader,
    required BeagleLogger logger,
    required Map<String, Operation> operations,
    required AnalyticsProvider? analyticsProvider}) {
  beagleServiceLocator
    ..registerSingleton<BeagleYogaFactory>(BeagleYogaFactory())
    ..registerSingleton<JavascriptRuntimeWrapper>(
      createJavascriptRuntimeWrapperInstance(),
    )
    ..registerSingleton<BeagleJSEngine>(
      createBeagleJSEngineInstance(),
    )
    ..registerSingleton<GlobalContext>(
      GlobalContextJS(beagleServiceLocator<BeagleJSEngine>()),
    )
    ..registerSingleton<BeagleDesignSystem>(designSystem)
    ..registerSingleton<BeagleImageDownloader>(imageDownloader)
    ..registerSingleton<BeagleLogger>(logger)
    ..registerSingleton<BeagleEnvironment>(environment)
    ..registerSingletonAsync<BeagleService>(() async {
      final configService = BeagleServiceJS(
        beagleServiceLocator<BeagleJSEngine>(),
        baseUrl: baseUrl,
        httpClient: httpClient,
        viewClient: viewClient,
        components: components,
        actions: actions,
        defaultNavigationController: defaultNavigationController,
        navigationControllers: navigationControllers,
        operations: operations,
      );

      await configService.start();
      return configService;
    })
    ..registerFactoryParam<BeagleViewJS, BeagleNavigator, void>(
      (BeagleNavigator parentNavigator, _) => BeagleViewJS(
        beagleServiceLocator<BeagleJSEngine>(),
        parentNavigator,
      ),
    )
    ..registerFactory<UrlBuilder>(() => UrlBuilder(baseUrl));

  if (analyticsProvider != null) {
    beagleServiceLocator
        .registerSingleton<AnalyticsProvider>(analyticsProvider);
  }
}

JavascriptRuntimeWrapper createJavascriptRuntimeWrapperInstance() =>
    JavascriptRuntimeWrapper(
        getJavascriptRuntime(forceJavascriptCoreOnAndroid: true, xhr: false));

BeagleJSEngine createBeagleJSEngineInstance() =>
    BeagleJSEngine(beagleServiceLocator<JavascriptRuntimeWrapper>());
