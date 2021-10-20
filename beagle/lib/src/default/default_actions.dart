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
import 'package:beagle/src/action/beagle_confirm.dart';

BeagleRoute _getRoute(BeagleAction action) {
  final json = action.getAttributeValue("route");
  return RemoteView.isRemoteView(json) ? RemoteView.fromJson(json) : LocalView.fromJson(json);
}

final Map<String, ActionHandler> defaultActions = {
  'beagle:confirm': ({required action, required element, required view, required context}) {
    BeagleConfirm.showAlertDialog(
      context,
      title: action.getAttributeValue('title'),
      message: action.getAttributeValue('message'),
      labelOk: action.getAttributeValue('labelOk'),
      onPressOk: action.getAttributeValue('onPressOk'),
      labelCancel: action.getAttributeValue('labelCancel'),
      onPressCancel: action.getAttributeValue('onPressCancel'),
    );
  },
  'beagle:alert': ({required action, required element, required view, required context}) {
    BeagleAlert.showAlertDialog(
      context,
      message: action.getAttributeValue('message'),
      labelOk: action.getAttributeValue('labelOk'),
      onPressOk: action.getAttributeValue('onPressOk'),
      title: action.getAttributeValue('title', 'Alert'),
    );
  },
  // Native navigation
  'beagle:openNativeRoute': ({required action, required element, required view, required context}) {
    BeagleOpenNativeRoute().navigate(context, action.getAttributeValue('route'));
  },
  'beagle:openExternalURL': ({required action, required element, required view, required context}) {
    BeagleOpenExternalUrl.launchURL(action.getAttributeValue('url'));
  },
  // Beagle Navigation
  'beagle:pushView': ({required action, required element, required view, required context}) {
    view.getNavigator()?.pushView(_getRoute(action), context);
  },
  'beagle:popView': ({required action, required element, required view, required context}) {
    view.getNavigator()?.popView(context);
  },
  'beagle:popToView': ({required action, required element, required view, required context}) {
    view.getNavigator()?.popToView(action.getAttributeValue("route"), context);
  },
  'beagle:pushStack': ({required action, required element, required view, required context}) {
    view.getNavigator()?.pushStack(_getRoute(action), context);
  },
  'beagle:popStack': ({required action, required element, required view, required context}) {
    view.getNavigator()?.popStack(context);
  },
  'beagle:resetStack': ({required action, required element, required view, required context}) {
    view.getNavigator()?.resetStack(_getRoute(action), context);
  },
  'beagle:resetApplication': ({required action, required element, required view, required context}) {
    view.getNavigator()?.resetApplication(_getRoute(action), context);
  },
};
