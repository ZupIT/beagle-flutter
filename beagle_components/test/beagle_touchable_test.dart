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

import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const touchableKey = Key('BeagleTouchable');

Widget createWidget({
  Key touchableKey = touchableKey,
  void Function()? touchableOnPress,
  required Widget touchableChild,
}) {
  return MaterialApp(
    home: BeagleTouchable(
      key: touchableKey,
      onPress: touchableOnPress,
      child: touchableChild,
    ),
  );
}

void main() {
  group('Given a BeagleTouchable', () {
    group('When I click on it', () {
      testWidgets('Then it should call onPress callback',
          (WidgetTester tester) async {
        final log = <int>[];
        void onPressed() {
          log.add(1);
        }

        await tester.pumpWidget(createWidget(
            touchableOnPress: onPressed,
            touchableChild: Container(
                padding: const EdgeInsets.all(12.0),
                child: const Text('My Text'))));
        await tester.tap(find.byType(BeagleTouchable));
        await tester.tap(find.byType(BeagleTouchable));
        await tester.tap(find.byType(BeagleTouchable));

        expect(log.length, 3);
      });
    });
  });
}
