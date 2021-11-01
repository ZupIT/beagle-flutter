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

typedef NavigationListener = void Function(BeagleRoute route);

abstract class BeagleNavigator {
  /// Creates and navigates to a new navigation stack where the first route is the parameter
  /// [route].
  ///
  /// The [controllerId] is an optional parameter and it specifies the NavigationController to use
  /// for this specific stack.
  ///
  /// Returns a Future that resolves as soon as the navigation completes.
  Future<void> pushStack(BeagleRoute route, [String? controllerId]);

  /// Removes the entire current navigation stack and navigates back to the last route of the
  /// previous stack. Throws an error if there's only one navigation stack.
  ///
  /// Returns a Future that resolves as soon as the navigation completes.
  void popStack();

  /// Navigates to [route] by pushing it to the navigation history of the current navigation stack.
  ///
  /// Returns a Future that resolves as soon as the navigation completes.
  Future<void> pushView(BeagleRoute route, BuildContext context);

  /// Goes back one entry in the navigation history. If the current stack has only one view, this
  /// also pops the current stack. If only one stack and one view exist, it will throw an error.
  ///
  /// Returns a Future that resolves as soon as the navigation completes.
  void popView();

  /// Removes every navigation entry in the current stack until the route identified by
  /// [routeIdentifier] is found. A route is identified by a string if its url equals to the string
  /// (RemoteView) or if the screen id equals to the string (LocalView).
  ///
  /// When the desired route is found, a navigation will be performed to this route. Otherwise, if
  /// the route isn't found in the current stack, an error is thrown.
  ///
  /// Returns a Future that resolves as soon as the navigation completes.
  void popToView(String routeIdentifier);

  /// Removes the current navigation stack and navigates to the a new stack where the first [route]
  /// is the one passed as parameter.
  ///
  /// The parameter [controllerId] is optional and it specifies the NavigationController to use for
  /// this specific stack.
  ///
  /// Returns a Future that resolves as soon as the navigation completes.
  Future<void> resetStack(BeagleRoute route, [String controllerId]);

  /// Removes the entire navigation history and starts it over by navigating to a new initial
  /// [route] (passed as parameter).
  ///
  /// The parameter [controllerId] is optional and it specifies the NavigationController to use for
  /// this specific stack.
  ///
  /// Returns a Future that resolves as soon as the navigation completes.
  Future<void> resetApplication(BeagleRoute route, [String controllerId]);
}
