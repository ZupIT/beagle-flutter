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

        _assertHasListViewAndNotHasGridView();
      });
    });

    group('When passing parameter spanCount with number zero', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(spanCount: 0));

        _assertHasListViewAndNotHasGridView();
      });
    });

    group('When passing parameter spanCount with null', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(spanCount: null));

        _assertHasListViewAndNotHasGridView();
      });
    });

    group('When passing parameter spanCount with number two', () {
      testWidgets('Then it should have a GridView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(spanCount: 2));

        _assertHasGridViewAndNotHasListView();
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

        _assertHasListViewAndNotHasGridView();
        _assertCorrectDirection(tester, Axis.horizontal);
      });

      testWidgets('Then it should have a GridView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          direction: BeagleDynamicListDirection.HORIZONTAL,
          spanCount: 2,
        ));

        _assertHasGridViewAndNotHasListView();
        _assertCorrectDirection(tester, Axis.horizontal);
      });
    });

    group('When passing parameter direction with value vertical', () {
      testWidgets('Then it should have a ListView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          direction: BeagleDynamicListDirection.VERTICAL,
        ));

        _assertHasListViewAndNotHasGridView();
        _assertCorrectDirection(tester, Axis.vertical);
      });

      testWidgets('Then it should have a GridView component',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          direction: BeagleDynamicListDirection.VERTICAL,
          spanCount: 2,
        ));

        _assertHasGridViewAndNotHasListView();
        _assertCorrectDirection(tester, Axis.vertical);
      });
    });

    group('When passing parameter children', () {
      testWidgets('Then it should have a ListView component with widgets',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          children: _getChildren(),
        ));

        _assertHasListViewAndNotHasGridView();
        _assertHasChildren(tester);
      });

      testWidgets('Then it should have a GridView component with widgets',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidget(
          spanCount: 2,
          children: _getChildren(),
        ));

        _assertHasGridViewAndNotHasListView();
        _assertHasChildren(tester);
      });
    });

    group(
        'When passing parameter onScrollEnd, scrollEndThreshold and call callback didUpdateWidget',
        () {
      testWidgets('Then it should have called onScrollEnd',
          (WidgetTester tester) async {
        var runCount = 0;

        await tester.pumpWidget(createWidget(
            children: _getChildren(),
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
            children: _getChildren(),
            scrollEndThreshold: 1,
            onScrollEnd: () {
              runCount++;
            });

        await tester.pumpWidget(widget);

        _assertHasListViewAndNotHasGridView();
        _scrollScreenToDown(tester);

        expect(runCount, 1);
      });

      testWidgets('Then it should have called onScrollEnd in GridView',
          (WidgetTester tester) async {
        var runCount = 0;

        final widget = createWidget(
            children: _getChildren(),
            scrollEndThreshold: 1,
            spanCount: 2,
            onScrollEnd: () {
              runCount++;
            });

        await tester.pumpWidget(widget);

        _assertHasGridViewAndNotHasListView();
        _scrollScreenToDown(tester);

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
      testWidgets('Then it should call doTemplateRender with correct parameter',
          (WidgetTester tester) async {
        final templates = _getTemplates();

        final dataSource = _getDataSource();

        final providerMock = BeagleWidgetStateProviderMock();
        final beagleWidgetStateMock = BeagleWidgetStateMock();
        final beagleViewMock = BeagleViewMock();
        final renderMock = RendererMock();

        when(providerMock.of(any)).thenReturn(beagleWidgetStateMock);
        when(beagleWidgetStateMock.getView()).thenReturn(beagleViewMock);
        when(beagleViewMock.getRenderer()).thenReturn(renderMock);

        await tester.pumpWidget(createWidget(
          iteratorName: 'name',
          templates: templates,
          dataSource: dataSource,
          provider: providerMock,
        ));

        final capturedValues = verify(renderMock.doTemplateRender(
                templateManager: captureAnyNamed('templateManager'),
                anchor: captureAnyNamed('anchor'),
                contexts: captureAnyNamed('contexts'),
                componentManager: captureAnyNamed('componentManager'),
                mode: captureAnyNamed('mode')))
            .captured;

        final templateManagerActual =
            (capturedValues[0] as TemplateManager).toJson();
        final templateManagerExpected = TemplateManager(
          defaultTemplate: _getTemplates().first.view,
          templates: [_getTemplates()[1]],
        ).toJson();

        expect(templateManagerActual, templateManagerExpected);

        final anchorCaptured = capturedValues[1];
        expect(anchorCaptured, 'dynamicList');
        final beagleDataContextListActual =
            capturedValues[2] as List<List<BeagleDataContext>>;
        final beagleDataContextActual =
            beagleDataContextListActual[0][0].toJson();
        final beagleDataContextExpected = BeagleDataContext(
          id: 'name',
          value: {
            'name': 'text_1',
          },
        ).toJson();
        expect(beagleDataContextActual, beagleDataContextExpected);
        expect(beagleDataContextListActual.length, 3);
        expect(capturedValues[3], isNotNull);
        final modeActual = capturedValues[4];
        expect(modeActual, TreeUpdateMode.replace);
      });
    });

    group('When doTemplateRender', () {
      testWidgets('Then it should generate id correct',
          (WidgetTester tester) async {
        final templates = _getTemplates();

        final dataSource = _getDataSource();

        final providerMock = BeagleWidgetStateProviderMock();
        final beagleWidgetStateMock = BeagleWidgetStateMock();
        final beagleViewMock = BeagleViewMock();
        final renderMock = RendererMock();

        when(providerMock.of(any)).thenReturn(beagleWidgetStateMock);
        when(beagleWidgetStateMock.getView()).thenReturn(beagleViewMock);
        when(beagleViewMock.getRenderer()).thenReturn(renderMock);

        await tester.pumpWidget(createWidget(
          iteratorName: 'name',
          templates: templates,
          dataSource: dataSource,
          provider: providerMock,
        ));

        final capturedValues = verify(renderMock.doTemplateRender(
                templateManager: captureAnyNamed('templateManager'),
                anchor: captureAnyNamed('anchor'),
                contexts: captureAnyNamed('contexts'),
                componentManager: captureAnyNamed('componentManager'),
                mode: captureAnyNamed('mode')))
            .captured;

        final componentManager =
            capturedValues[3] as BeagleUIElement Function(BeagleUIElement, int);

        final beagleUiElementActual =
            componentManager(_getBeagleUiElement(), 0);
        expect(beagleUiElementActual.properties, _getPropertiesExpected());
      });
    });
  });
}

BeagleUIElement _getBeagleUiElement() {
  return BeagleUIElement({
    "_beagleComponent_": "beagle:container",
    "children": [
      {
        "_beagleComponent_": "beagle:text",
      },
      {
        "_beagleComponent_": "beagle:text",
      },
      {
        "_beagleComponent_": "beagle:listview",
      },
      {
        "_beagleComponent_": "beagle:gridview",
      },
      {
        "_beagleComponent_": "beagle:text",
      },
    ]
  });
}

Map<String, dynamic> _getPropertiesExpected() {
  return {
    "_beagleComponent_": "beagle:container",
    "children": [
      {"_beagleComponent_": "beagle:text", "id": "dynamicList:0:0"},
      {"_beagleComponent_": "beagle:text", "id": "dynamicList:1:0"},
      {
        "_beagleComponent_": "beagle:listview",
        "id": "dynamicList:2:0",
        "__suffix__": ":0"
      },
      {
        "_beagleComponent_": "beagle:gridview",
        "id": "dynamicList:3:0",
        "__suffix__": ":0"
      },
      {"_beagleComponent_": "beagle:text", "id": "dynamicList:4:0"}
    ]
  };
}

List<dynamic> _getDataSource() {
  return [
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
}

List<TemplateManagerItem> _getTemplates() {
  return [
    TemplateManagerItem(
      condition: null,
      view: BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text': "This is @{item.name}",
      }),
    ),
    TemplateManagerItem(
      condition: "@{item}",
      view: BeagleUIElement({
        '_beagleComponent_': 'beagle:text',
        'text': "This is @{item.name}",
      }),
    )
  ];
}

void _scrollScreenToDown(WidgetTester tester) {
  final scrollableFinder = find.byType(Scrollable);
  final scrollable = tester.widget<Scrollable>(scrollableFinder);
  final controller = scrollable.controller;
  controller.jumpTo(controller.offset + 300);
}

void _assertCorrectDirection(WidgetTester tester, Axis axis) {
  final scrollableFinder = find.byType(Scrollable);
  final scrollable = tester.widget<Scrollable>(scrollableFinder);

  expect(scrollable.axis, axis);
}

void _assertHasListViewAndNotHasGridView() {
  final listViewFinder = find.byType(ListView);

  final gridViewFinder = find.byType(GridView);

  expect(listViewFinder, findsOneWidget);
  expect(gridViewFinder, findsNothing);
}

void _assertHasGridViewAndNotHasListView() {
  final listViewFinder = find.byType(ListView);

  final gridViewFinder = find.byType(GridView);

  expect(gridViewFinder, findsOneWidget);
  expect(listViewFinder, findsNothing);
}

void _assertHasChildren(
  WidgetTester tester,
) {
  final textFinder = find.byType(Text);
  final scrollableFinder = find.byType(Scrollable);
  final scrollable = tester.widget<Scrollable>(scrollableFinder);

  expect(textFinder, findsOneWidget);
  expect(scrollable.semanticChildCount, 1);
}

List<Widget> _getChildren() {
  return [Text('Simple Text', key: UniqueKey())];
}

class RendererMock extends Mock implements Renderer {}

class BeagleViewMock extends Mock implements BeagleView {}

class BeagleWidgetStateMock extends Mock implements BeagleWidgetState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}

class BeagleWidgetStateProviderMock extends Mock
    implements BeagleWidgetStateProvider {}
