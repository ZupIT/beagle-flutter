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

import 'package:beagle_components/src/beagle_pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const keyPullToRefresh = Key('PullToRefresh');
const keyContent = Key('Text');
const color = "#123456";
var childContent = ListView(children: [Text("Hello", key: keyContent)]);

Widget createWidget({
  Key key = keyPullToRefresh,
  Function onPull,
  bool isRefreshing,
  String color,
  Widget child,
}) {
  return MaterialApp(
    home: PullToRefresh(
      key: key,
      onPull: onPull,
      isRefreshing: isRefreshing,
      color: color,
      child: child,
    ),
  );
}

void main() {
  group('Given a PullToRefresh', () {
    group('When I scroll on it', () {
      testWidgets('Then it should call onPull callback presenting the RefreshProgressIndicator',
          (WidgetTester tester) async {
        var tapCount = 0;
        void onPull() {
          //it should be presenting the indicator when executing the onPull method
          expect(find.byType(RefreshProgressIndicator), findsOneWidget);
          tapCount++;
        }

        await tester.pumpWidget(createWidget(onPull: onPull,
            child: childContent, color: color));

        await tester.drag(find.byKey(keyContent), const Offset(0.0, 300));
        await tester.pumpAndSettle();

        const expectedTapCount = 1;
        expect(tapCount, expectedTapCount);
      });
    });

    group('When isRefreshing is set to true', () {
      testWidgets('Then it should present the RefreshProgressIndicator without pulling down',
              (WidgetTester tester) async {
            final isRefreshing = true;
            var tapCount = 0;
            void onPull() {
              tapCount++;
            }
            await tester.pumpWidget(createWidget(onPull: onPull, isRefreshing: isRefreshing,
                child: childContent, color: color));

            const expectedTapCount = 0;
            expect(tapCount, expectedTapCount);
            expect(find.byType(RefreshProgressIndicator), findsOneWidget);
          });
    });

    group('When isRefreshing is set to false', () {
      testWidgets('Then it should not present the RefreshProgressIndicator without pulling down',
              (WidgetTester tester) async {
            final isRefreshing = false;
            var tapCount = 0;
            void onPull() {
              tapCount++;
            }
            await tester.pumpWidget(createWidget(onPull: onPull, isRefreshing: isRefreshing,
                child: childContent, color: color));

            const expectedTapCount = 0;
            expect(tapCount, expectedTapCount);
            expect(find.byType(RefreshProgressIndicator), findsNothing);
          });
    });
  });
}
