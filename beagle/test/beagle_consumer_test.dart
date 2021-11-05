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
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _BeagleServiceMock extends Mock implements BeagleService {}

class _BeagleProviderStateMock extends Mock implements BeagleProviderState {
  @override
  final beagle = _BeagleServiceMock();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class _MyWidget extends Mock implements StatefulWidget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class _MockedState<T extends StatefulWidget> extends Mock implements State<T> {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class _BuildContextMock extends Mock implements BuildContext {}

class _MyWidgetState extends _MockedState<_MyWidget> with BeagleConsumer {
  int buildCalledTimes = 0;
  int initCalledTimes = 0;
  bool wasBeagleAccessibleOnBuild = false;
  bool wasBeagleAccessibleOnInit = false;

  @override
  Widget buildBeagleWidget(BuildContext context) {
    buildCalledTimes++;
    try {
      beagle;
      wasBeagleAccessibleOnBuild = true;
    // ignore: empty_catches
    } catch (err) {}
    return Container();
  }

  @override
  void initBeagleState() {
    initCalledTimes++;
    try {
      beagle;
      wasBeagleAccessibleOnInit = true;
      // ignore: empty_catches
    } catch (err) {}
  }
}

void main() {
  group('Given a state with a BeagleConsumer', () {
    group("When the build hasn't happened yet", () {
      final state = _MyWidgetState();
      test('Then accesing beagle should throw an exception', () {
        dynamic error;
        try {
          state.beagle;
        } catch (err) {
          error = err;
        }
        expect(error == null, false);
      });
    });

    group("When the build happens", () {
      final providerState = _BeagleProviderStateMock();
      final state = _MyWidgetState();
      final context = _BuildContextMock();
      when(context.findAncestorStateOfType).thenReturn(providerState);
      state.build(context);

      test('Then buildBuildBeagleWidget should be called', () {
        expect(state.buildCalledTimes, 1);
      });

      test('And initBeagleState should be called', () {
        expect(state.initCalledTimes, 1);
      });

      test('And beagle should be accessible during build', () {
        expect(state.wasBeagleAccessibleOnBuild, true);
      });

      test('And beagle should be accessible during init', () {
        expect(state.wasBeagleAccessibleOnInit, true);
      });

      test('And beagle should be accessible after the build', () {
        expect(state.beagle, providerState.beagle);
      });

      group("When the build happens a second time", () {
        test('Then init should not be called again', () {
          state.build(context);
          expect(state.initCalledTimes, 1);
        });
      });
    });
  });
}
