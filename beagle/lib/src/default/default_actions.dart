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
  return RemoteView.isRemoteView(json)
      ? RemoteView.fromJson(json)
      : LocalView.fromJson(json);
}

final Map<String, ActionHandler> defaultActions = {
  'beagle:confirm': (context, {action, view, element}) {
    BeagleConfirm.showAlertDialog(
      context,
      title: action?.getAttributeValue('title'),
      message: action?.getAttributeValue('message'),
      labelOk: action?.getAttributeValue('labelOk'),
      onPressOk: action?.getAttributeValue('onPressOk'),
      labelCancel: action?.getAttributeValue('labelCancel'),
      onPressCancel: action?.getAttributeValue('onPressCancel'),
    );
  },
  'beagle:alert': (context, {action, view, element}) {
    BeagleAlert.showAlertDialog(
      context,
      message: action?.getAttributeValue('message'),
      labelOk: action?.getAttributeValue('labelOk'),
      onPressOk: action?.getAttributeValue('onPressOk'),
      title: action?.getAttributeValue('title', 'Alert'),
    );
  },
  // Native navigation
  'beagle:openNativeRoute': (context, {action, view, element}) {
    BeagleOpenNativeRoute()
        .navigate(context, action?.getAttributeValue('route'));
  },
  'beagle:openExternalURL': (context, {action, view, element}) {
    BeagleOpenExternalUrl.launchURL(action?.getAttributeValue('url'));
  },
  // Beagle Navigation
  'beagle:pushView': (context, {action, view, element}) {
    view?.getNavigator()?.pushView(_getRoute(action!), context);
  },
  'beagle:popView': (context, {action, view, element}) {
    view?.getNavigator()?.popView(context);
  },
  'beagle:popToView': (context, {action, view, element}) {
    view
        ?.getNavigator()
        ?.popToView(action?.getAttributeValue("route"), context);
  },
  'beagle:pushStack': (context, {action, view, element}) {
    view?.getNavigator()?.pushStack(_getRoute(action!), context);
  },
  'beagle:popStack': (context, {action, view, element}) {
    view?.getNavigator()?.popStack(context);
  },
  'beagle:resetStack': (context, {action, view, element}) {
    view?.getNavigator()?.resetStack(_getRoute(action!), context);
  },
  'beagle:resetApplication': (context, {action, view, element}) {
    view?.getNavigator()?.resetApplication(_getRoute(action!), context);
  },
};
