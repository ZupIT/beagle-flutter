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
  'beagle:confirm': ({action, view, element, context}) {
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
  'beagle:alert': ({action, view, element, context}) {
    BeagleAlert.showAlertDialog(
      context,
      message: action.getAttributeValue('message'),
      labelOk: action.getAttributeValue('labelOk'),
      onPressOk: action.getAttributeValue('onPressOk'),
      title: action.getAttributeValue('title', 'Alert'),
    );
  },
  // Native navigation
  'beagle:openNativeRoute': ({action, view, element, context}) {
    BeagleOpenNativeRoute()
        .navigate(context, action.getAttributeValue('route'));
  },
  'beagle:openExternalURL': ({action, view, element, context}) {
    BeagleOpenExternalUrl.launchURL(action.getAttributeValue('url'));
  },
  // Beagle Navigation
  'beagle:pushView': ({action, view, element, context}) {
    view.getNavigator().pushView(_getRoute(action), context);
  },
  'beagle:popView': ({action, view, element, context}) {
    view.getNavigator().popView();
  },
  'beagle:popToView': ({action, view, element, context}) {
    view.getNavigator().popToView(action.getAttributeValue("route"));
  },
  'beagle:pushStack': ({action, view, element, context}) {
    view.getNavigator().pushStack(_getRoute(action));
  },
  'beagle:popStack': ({action, view, element, context}) {
    view.getNavigator().popStack();
  },
  'beagle:resetStack': ({action, view, element, context}) {
    view.getNavigator().resetStack(_getRoute(action));
  },
  'beagle:resetApplication': ({action, view, element, context}) {
    view.getNavigator().resetApplication(_getRoute(action));
  },
};
