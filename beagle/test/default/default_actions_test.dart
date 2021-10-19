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
import 'package:beagle/src/default/default_actions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _BeagleNavigatorMock extends Mock implements BeagleNavigator {}

class _BeagleViewMock extends Mock implements BeagleView {
  final navigator = _BeagleNavigatorMock();

  @override
  BeagleNavigator getNavigator() {
    return navigator;
  }
}

class _BeagleUIElementMock extends Mock implements BeagleUIElement {}

class _BuildContextMock extends Mock implements BuildContext {}

void main() {
  group("Given the action handlers for beagle navigation", () {
    Map<String, String> remoteViewMap = { "url": "/test" };
    Map<String, dynamic> localViewMap = {"screen": { "id": "local", "_beagleComponent_": "beagle:container"}};
    final element = _BeagleUIElementMock();
    final context = _BuildContextMock();
    BeagleView view;

    void _setup(BeagleAction action) {
      view = _BeagleViewMock();
      defaultActions[action.getType()](action: action, view: view, context: context, element: element);
    }

    group("When pushView is called with a remote view", () {
      test("Then it should call the BeagleNavigator's pushView with the deserialized RemoteView", () {
        _setup(BeagleAction({
          "_beagleAction_": "beagle:pushView",
          "route": remoteViewMap,
        }));

        final verified = verify(view.getNavigator().pushView(captureAny, context));
        verified.called(1);
        expect(verified.captured[0], isA<RemoteView>());
        expect((verified.captured[0] as RemoteView).url, "/test");
      });
    });

    group("When pushView is called with a local view", () {
      test("Then it should call the BeagleNavigator's pushView with the deserialized LocalView", () {
        _setup(BeagleAction({
          "_beagleAction_": "beagle:pushView",
          "route": localViewMap,
        }));

        final verified = verify(view.getNavigator().pushView(captureAny, context));
        verified.called(1);
        expect(verified.captured[0], isA<LocalView>());
        expect((verified.captured[0] as LocalView).screen.getId(), "local");
        expect((verified.captured[0] as LocalView).screen.getType(), "beagle:container");
      });
    });

    group("When popView is called", () {
      test("Then it should call the BeagleNavigator's popView", () {
        _setup(BeagleAction({"_beagleAction_": "beagle:popView"}));

        verify(view.getNavigator().popView()).called(1);
      });
    });

    group("When popToView is called", () {
      test("Then it should call the BeagleNavigator's popToView with the route name as param", () {
        _setup(BeagleAction({
          "_beagleAction_": "beagle:popToView",
          "route": "/test",
        }));

        verify(view.getNavigator().popToView("/test")).called(1);
      });
    });

    group("When popStack is called", () {
      test("Then it should call the BeagleNavigator's popStack", () {
        _setup(BeagleAction({"_beagleAction_": "beagle:popStack"}));

        verify(view.getNavigator().popStack()).called(1);
      });
    });

    void createStackTestSuit(String type) {
      final Map<String, VerificationResult Function()> verificationMap = {
        "pushStack": () => verify(view.getNavigator().pushStack(captureAny, captureAny)),
        "resetStack": () => verify(view.getNavigator().resetStack(captureAny, captureAny)),
        "resetApplication": () => verify(view.getNavigator().resetApplication(captureAny, captureAny)),
      };

      group("When $type is called with a remote view", () {
        test("Then it should call the BeagleNavigator's pushStack with the deserialized RemoteView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:$type",
            "route": remoteViewMap,
          }));

          final verified = verificationMap[type]();
          verified.called(1);
          expect(verified.captured[0], isA<RemoteView>());
          expect((verified.captured[0] as RemoteView).url, "/test");
        });
      });

      group("When $type is called with a local view", () {
        test("Then it should call the BeagleNavigator's pushStack with the deserialized LocalView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:$type",
            "route": localViewMap,
          }));

          final verified = verificationMap[type]();
          verified.called(1);
          expect(verified.captured[0], isA<LocalView>());
          expect((verified.captured[0] as LocalView).screen.getId(), "local");
          expect((verified.captured[0] as LocalView).screen.getType(), "beagle:container");
        });
      });

      group("When $type is called with a custom controller", () {
        test("Then it should call the BeagleNavigator's pushStack with the custom controller", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:$type",
            "route": remoteViewMap,
            "controllerId": "myCustomController",
          }));

          final verified = verificationMap[type]();
          expect(verified.captured[1], "myCustomController");
        });
      });
    }

    createStackTestSuit("pushStack");
    createStackTestSuit("resetStack");
    createStackTestSuit("resetApplication");
  });
}
