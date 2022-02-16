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

import 'package:beagle/beagle.dart';
import 'package:beagle/src/bridge_impl/beagle_js.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _BeagleJSMock extends Mock implements BeagleJS {}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final js = _BeagleJSMock();
}

void main() {
  late BeagleService beagle;
  late Widget child;

  setup(WidgetTester tester) async {
    beagle = _BeagleServiceMock();
    child = Container();
    when(beagle.js.start).thenAnswer((_) => Future.value());
    await tester.pumpWidget(
      BeagleProvider(beagle: beagle, child: child),
    );
  }

  group('Given a Beagle Provider', () {
    group("When the it's started", () {
      testWidgets('Then it should initialize the js engine', (WidgetTester tester) async {
        await setup(tester);
        verify(beagle.js.start).called(1);
      });
    });

    group("When the it's waiting for BeagleJS to be ready", () {
      testWidgets('Then it should render an empty box instead of the child', (WidgetTester tester) async {
        await setup(tester);
        expect(find.byWidget(child), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      });
    });

    group("When BeagleJS is ready", () {
      testWidgets('Then it should render the child instead of an empty box', (WidgetTester tester) async {
        await setup(tester);
        await tester.pump();
        expect(find.byWidget(child), findsOneWidget);
        expect(find.byType(SizedBox), findsNothing);
      });
    });
  });
}
