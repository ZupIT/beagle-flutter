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
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../service_locator/service_locator.dart';

Widget createWidget({
  final Function onInit,
  final BeagleDynamicListDirection direction,
  final List<dynamic> dataSource,
  final List<TemplateManagerItem> templates,
  final bool isScrollIndicatorVisible,
  final int scrollEndThreshold,
  final String iteratorName,
  final String identifierItem,
  final Function onScrollEnd,
  final int spanCount,
  final List<Widget> children,
  final BeagleWidgetStateProvider provider,
}) {
  return MaterialApp(
    key: Key('materialApp'),
    home: BeagleDynamicList(
      key: Key('dynamicList'),
      onInit: onInit,
      direction: direction,
      dataSource: dataSource,
      templates: templates,
      isScrollIndicatorVisible: isScrollIndicatorVisible,
      scrollEndThreshold: scrollEndThreshold,
      iteratorName: iteratorName,
      identifierItem: identifierItem,
      onScrollEnd: onScrollEnd,
      spanCount: spanCount,
      children: children,
      beagleWidgetStateProvider: provider,
    ),
  );
}

void main() {
  setUpAll(() async {
    await testSetupServiceLocator();
  });

  group('Given a BeagleDynamicList', () {
    group('When passing parameter spanCount with number one', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(spanCount: 1));

        assertHasListViewAndNotHasGridView();
      });
    });

    group('When passing parameter spanCount with number zero', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(spanCount: 0));

        assertHasListViewAndNotHasGridView();
      });
    });

    group('When passing parameter spanCount with null', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(spanCount: null));

        assertHasListViewAndNotHasGridView();
      });
    });

    group('When passing parameter spanCount with number two', () {
      testWidgets('Then it should have a GridView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(spanCount: 2));

        assertHasGridViewAndNotHasListView();
      });
    });

    group('When passing parameter onInit', () {
      testWidgets('Then it should call function onInit ',
          (WidgetTester tester) async {
        var runCount = 0;

        await tester.pumpWidget(createWidget(onInit: () {
          runCount++;
        }));

        expect(runCount, 1);
      });
    });

    group('When passing parameter direction with value horizontal', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          direction: BeagleDynamicListDirection.HORIZONTAL,
          spanCount: null,
        ));

        assertHasListViewAndNotHasGridView();
        assertCorrectDirection(tester, Axis.horizontal);
      });

      testWidgets('Then it should have a GridView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          direction: BeagleDynamicListDirection.HORIZONTAL,
          spanCount: 2,
        ));

        assertHasGridViewAndNotHasListView();
        assertCorrectDirection(tester, Axis.horizontal);
      });
    });

    group('When passing parameter direction with value vertical', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          direction: BeagleDynamicListDirection.VERTICAL,
        ));

        assertHasListViewAndNotHasGridView();
        assertCorrectDirection(tester, Axis.vertical);
      });

      testWidgets('Then it should have a GridView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          direction: BeagleDynamicListDirection.VERTICAL,
          spanCount: 2,
        ));

        assertHasGridViewAndNotHasListView();
        assertCorrectDirection(tester, Axis.vertical);
      });
    });

    group('When passing parameter children', () {
      testWidgets('Then it should have a ListView component with widgets',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          children: getChildren(),
        ));

        assertHasListViewAndNotHasGridView();
        assertHasChildren(tester);
      });

      testWidgets('Then it should have a GridView component with widgets',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          spanCount: 2,
          children: getChildren(),
        ));

        assertHasGridViewAndNotHasListView();
        assertHasChildren(tester);
      });
    });

    group(
        'When passing parameter onScrollEnd, scrollEndThreshold and call callback didUpdateWidget',
        () {
      testWidgets('Then it should have called onScrollEnd',
          (WidgetTester tester) async {
        var runCount = 0;

        await tester.pumpWidget(createWidget(
            children: getChildren(),
            scrollEndThreshold: 1,
            onScrollEnd: () {
              runCount++;
            }));

        await tester.pumpWidget(createWidget(
            children: [Text('text'), Text('text two')],
            scrollEndThreshold: 1,
            onScrollEnd: () {
              runCount++;
            }));

        expect(runCount, 1);
      });
    });

    group(
        'When passing parameter onScrollEnd, scrollEndThreshold and scroll screen',
        () {
      testWidgets('Then it should have called onScrollEnd',
          (WidgetTester tester) async {
        var runCount = 0;

        final widget = createWidget(
            children: getChildren(),
            scrollEndThreshold: 1,
            onScrollEnd: () {
              runCount++;
            });

        await tester.pumpWidget(widget);

        assertHasListViewAndNotHasGridView();
        scrollScreenToDown(tester);

        expect(runCount, 1);
      });

      testWidgets('Then it should have called onScrollEnd in GridView',
          (WidgetTester tester) async {
        var runCount = 0;

        final widget = createWidget(
            children: getChildren(),
            scrollEndThreshold: 1,
            spanCount: 2,
            onScrollEnd: () {
              runCount++;
            });

        await tester.pumpWidget(widget);

        assertHasGridViewAndNotHasListView();
        scrollScreenToDown(tester);

        expect(runCount, 1);
      });
    });

    group('When passing parameter isScrollIndicatorVisible with value true',
        () {
      testWidgets('Then it should have a Scrollbar component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(isScrollIndicatorVisible: true));

        final scrollbarFinder = find.byType(Scrollbar);
        expect(scrollbarFinder, findsOneWidget);
      });
    });

    group('When passing parameter isScrollIndicatorVisible with value null',
        () {
      testWidgets('Then it should not have a Scrollbar component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(isScrollIndicatorVisible: null));

        final scrollbarFinder = find.byType(Scrollbar);
        expect(scrollbarFinder, findsNothing);
      });
    });

    group('When passing dataSource', () {
      testWidgets('Then it should render items', (WidgetTester tester) async {
        final templates = [
          TemplateManagerItem(
              condition: null,
              view: BeagleUIElement({
                '_beagleComponent_': 'beagle:text',
                'text': "This is @{item.name}"
              }))
        ];

        final dataSource = [
          {
            "name": "text_1",
          },
          {
            "name": "text_2",
          },
          {
            "name": "text_3",
          }
        ];

        await tester.pumpWidget(createWidget(
          iteratorName: "name",
          templates: templates,
          dataSource: dataSource,
        ));
      });
    });
  });
}

void scrollScreenToDown(WidgetTester tester) {
  final scrollableFinder = find.byType(Scrollable);
  final scrollable = tester.widget<Scrollable>(scrollableFinder);
  final controller = scrollable.controller;
  controller.jumpTo(controller.offset + 300);
}

void assertCorrectDirection(WidgetTester tester, Axis axis) {
  final scrollableFinder = find.byType(Scrollable);
  final scrollable = tester.widget<Scrollable>(scrollableFinder);

  expect(scrollable.axis, axis);
}

void assertHasListViewAndNotHasGridView() {
  final listViewFinder = find.byType(ListView);

  final gridViewFinder = find.byType(GridView);

  expect(listViewFinder, findsOneWidget);
  expect(gridViewFinder, findsNothing);
}

void assertHasGridViewAndNotHasListView() {
  final listViewFinder = find.byType(ListView);

  final gridViewFinder = find.byType(GridView);

  expect(gridViewFinder, findsOneWidget);
  expect(listViewFinder, findsNothing);
}

void assertHasChildren(
  WidgetTester tester,
) {
  final textFinder = find.byType(Text);
  final scrollableFinder = find.byType(Scrollable);
  final scrollable = tester.widget<Scrollable>(scrollableFinder);

  expect(textFinder, findsOneWidget);
  expect(scrollable.semanticChildCount, 1);
}

List<Widget> getChildren() {
  return [Text('Simple Text', key: UniqueKey())];
}

class RendererMock extends Mock implements Renderer {
  @override
  void doTemplateRender(
      {TemplateManager templateManager,
      String anchor,
      List<List<BeagleDataContext>> contexts,
      BeagleUIElement Function(BeagleUIElement p1, int p2) componentManager,
      TreeUpdateMode mode}) {
    print("dddd");
  }
}

class BeagleViewMock extends Mock implements BeagleView {
  @override
  Renderer getRenderer() {
    return RendererMock();
  }
}

class BeagleWidgetStateMock extends Mock implements BeagleWidgetState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "";
  }
}

class MockBeagleWidgetStateProvider extends Mock
    implements BeagleWidgetStateProvider {
  @override
  BeagleWidgetState of(BuildContext context) {
    return BeagleWidgetStateMock();
  }
}
