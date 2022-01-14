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
import 'package:mocktail/mocktail.dart';

import '../test-utils/mocktail.dart';

class _BeagleNavigatorMock extends Mock implements BeagleNavigator {}

class _LocalContextsManagerMock extends Mock implements LocalContextsManager {}

class _BeagleViewMock extends Mock implements BeagleView {
  final navigator = _BeagleNavigatorMock();
  final manager = _LocalContextsManagerMock();

  @override
  BeagleNavigator getNavigator() {
    return navigator;
  }

  @override
  LocalContextsManager getLocalContexts() {
    return manager;
  }
}

class _BeagleUIElementMock extends Mock implements BeagleUIElement {}

class _BuildContextMock extends Mock implements BuildContext {}

void main() {
  registerMocktailFallbacks();

  group("Given the action handlers for beagle navigation", () {
    Map<String, String> remoteViewMap = {"url": "/test"};
    Map<String, dynamic> localViewMap = {
      "screen": {
        "id": "local",
        "_beagleComponent_": "beagle:container",
      },
    };
    Map<String, dynamic> navigationContextMap = {
      "path": "nav-ctx-path",
      "value": {
        "obj-attr": "my navigation context value",
      },
    };
    final element = _BeagleUIElementMock();
    final context = _BuildContextMock();
    final _BeagleViewMock view = _BeagleViewMock();

    when(() => view.navigator.pushView(any(), any())).thenAnswer((_) async {});

    void _setup(BeagleAction action) {
      defaultActions[action.getType()]!(
        action: action,
        view: view,
        context: context,
        element: element,
      );
    }

    group("When pushView is called with a remote view", () {
      test("Then it should call the BeagleNavigator's pushView with the deserialized RemoteView", () {
        _setup(BeagleAction({
          "_beagleAction_": "beagle:pushView",
          "route": remoteViewMap,
        }));

        final verified = verify(() => view.navigator.pushView(captureAny(), any()));
        verified.called(1);

        final remoteView = verified.captured.first;
        expect(remoteView, isA<RemoteView>());
        expect((remoteView as RemoteView).url, "/test");
      });

      group("When it has a navigation context", () {
        test("Then it should call the BeagleNavigator's pushView with the deserialized RemoteView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:pushView",
            "route": remoteViewMap,
            "navigationContext": navigationContextMap,
          }));

          final verified = verify(() => view.navigator.pushView(captureAny(), any()));
          verified.called(1);

          final remoteView = verified.captured.first;
          expect(remoteView, isA<RemoteView>());
          expect((remoteView as RemoteView).url, "/test");
          expect(remoteView.navigationContext, isA<NavigationContext>());
          expect(remoteView.navigationContext!.path, navigationContextMap["path"]);
          expect(remoteView.navigationContext!.value, navigationContextMap["value"]);
        });
      });

      group("When it has a navigation context but is null", () {
        test("Then it should call the BeagleNavigator's pushView with the deserialized RemoteView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:pushView",
            "route": remoteViewMap,
            "navigationContext": null,
          }));

          final verified = verify(() => view.navigator.pushView(captureAny(), any()));
          verified.called(1);

          final remoteView = verified.captured.first;
          expect(remoteView, isA<RemoteView>());
          expect((remoteView as RemoteView).url, "/test");
          expect(remoteView.navigationContext, null);
        });
      });
    });

    group("When pushView is called with a local view", () {
      test("Then it should call the BeagleNavigator's pushView with the deserialized LocalView", () {
        _setup(BeagleAction({
          "_beagleAction_": "beagle:pushView",
          "route": localViewMap,
        }));

        final verified = verify(() => view.getNavigator().pushView(captureAny(), context));
        verified.called(1);

        final localView = verified.captured.first;
        expect(localView, isA<LocalView>());
        expect((localView as LocalView).screen.getId(), "local");
        expect(localView.screen.getType(), "beagle:container");
      });

      group("When it has a navigation context", () {
        test("Then it should call the BeagleNavigator's pushView with the deserialized LocalView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:pushView",
            "route": localViewMap,
            "navigationContext": navigationContextMap,
          }));

          final verified = verify(() => view.getNavigator().pushView(captureAny(), context));
          verified.called(1);

          final localView = verified.captured.first;
          expect(localView, isA<LocalView>());
          expect((localView as LocalView).screen.getId(), "local");
          expect(localView.screen.getType(), "beagle:container");
          expect(localView.navigationContext, isA<NavigationContext>());
          expect(localView.navigationContext!.path, navigationContextMap["path"]);
          expect(localView.navigationContext!.value, navigationContextMap["value"]);
        });
      });

      group("When it has a navigation context but is null", () {
        test("Then it should call the BeagleNavigator's pushView with the deserialized LocalView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:pushView",
            "route": localViewMap,
            "navigationContext": null,
          }));

          final verified = verify(() => view.getNavigator().pushView(captureAny(), context));
          verified.called(1);

          final localView = verified.captured.first;
          expect(localView, isA<LocalView>());
          expect((localView as LocalView).screen.getId(), "local");
          expect(localView.screen.getType(), "beagle:container");
          expect(localView.navigationContext, null);
        });
      });
    });

    group("When popView is called", () {
      test("Then it should call the BeagleNavigator's popView", () {
        _setup(BeagleAction({"_beagleAction_": "beagle:popView"}));

        verify(() => view.getNavigator().popView(any())).called(1);
      });

      group("When it has a navigation context", () {
        test("Then it should call the BeagleNavigator's popView with the navigation context as a parameter", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:popView",
            "navigationContext": navigationContextMap,
          }));

          final verified = verify(() => view.getNavigator().popView(captureAny()));
          verified.called(1);

          final popViewArg = verified.captured.first;
          expect(popViewArg, isA<NavigationContext>());
          expect(popViewArg!.path, navigationContextMap["path"]);
          expect(popViewArg!.value, navigationContextMap["value"]);
        });
      });
    });

    group("When popToView is called", () {
      test("Then it should call the BeagleNavigator's popToView with the route name as param", () {
        _setup(BeagleAction({
          "_beagleAction_": "beagle:popToView",
          "route": "/test",
        }));

        verify(() => view.getNavigator().popToView("/test", any())).called(1);
      });

      group("When it has a navigation context", () {
        test("Then it should call the BeagleNavigator's popToView with the navigation context as a parameter", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:popToView",
            "route": "/test",
            "navigationContext": navigationContextMap,
          }));

          final verified = verify(() => view.getNavigator().popToView("/test", captureAny()));
          verified.called(1);

          final popToViewArg = verified.captured.first;
          expect(popToViewArg, isA<NavigationContext>());
          expect(popToViewArg!.path, navigationContextMap["path"]);
          expect(popToViewArg!.value, navigationContextMap["value"]);
        });
      });
    });

    group("When popStack is called", () {
      test("Then it should call the BeagleNavigator's popStack", () {
        _setup(BeagleAction({"_beagleAction_": "beagle:popStack"}));
        verify(() => view.getNavigator().popStack(any())).called(1);
      });

      group("When it has a navigation context", () {
        test("Then it should call the BeagleNavigator's popToView with the navigation context as a parameter", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:popStack",
            "navigationContext": navigationContextMap,
          }));

          final verified = verify(() => view.getNavigator().popStack(captureAny()));
          verified.called(1);

          final popStackArg = verified.captured.first;
          expect(popStackArg, isA<NavigationContext>());
          expect(popStackArg!.path, navigationContextMap["path"]);
          expect(popStackArg!.value, navigationContextMap["value"]);
        });
      });
    });

    void createStackTestSuit(String type) {
      when(() => view.navigator.pushStack(any(), any())).thenAnswer((_) async {});
      when(() => view.navigator.resetStack(any(), any())).thenAnswer((_) async {});
      when(() => view.navigator.resetApplication(any(), any())).thenAnswer((_) async {});

      final Map<String, VerificationResult Function()> verificationMap = {
        "pushStack": () => verify(() => view.navigator.pushStack(captureAny(), captureAny())),
        "resetStack": () => verify(() => view.navigator.resetStack(captureAny(), captureAny())),
        "resetApplication": () => verify(() => view.navigator.resetApplication(captureAny(), captureAny())),
      };

      group("When $type is called with a remote view", () {
        test("Then it should call the BeagleNavigator's pushStack with the deserialized RemoteView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:$type",
            "controllerId": "myCustomController",
            "route": remoteViewMap,
          }));

          final verified = verificationMap[type]!();
          verified.called(1);

          expect(verified.captured[0], isA<RemoteView>());
          expect((verified.captured[0] as RemoteView).url, "/test");
        });
      });

      group("When $type is called with a local view", () {
        test("Then it should call the BeagleNavigator's pushStack with the deserialized LocalView", () {
          _setup(BeagleAction({
            "_beagleAction_": "beagle:$type",
            "controllerId": "myCustomController",
            "route": localViewMap,
          }));

          final verified = verificationMap[type]!();
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

          final verified = verificationMap[type]!();
          expect(verified.captured[1], "myCustomController");
        });
      });
    }

    createStackTestSuit("pushStack");
    createStackTestSuit("resetStack");
    createStackTestSuit("resetApplication");
  });
}
