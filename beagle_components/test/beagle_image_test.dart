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

import 'dart:typed_data';
import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'image/image_mock_data.dart';
import 'test-utils/provider_mock.dart';

class _BeagleThemeMock extends Mock implements BeagleTheme {}

class _BeagleImageDownloaderMock extends Mock implements BeagleImageDownloader {}

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _UrlBuilderMock extends Mock implements UrlBuilder {}

class _BeagleServiceMock extends Mock implements BeagleService {
  @override
  final imageDownloader = _BeagleImageDownloaderMock();
  @override
  final logger = _BeagleLoggerMock();
  @override
  final urlBuilder = _UrlBuilderMock();
}

void main() {
  final beagle = _BeagleServiceMock();
  final theme = _BeagleThemeMock();

  const imageUrl = 'https://test.com/beagle.png';
  const imageNotFoundUrl = 'https://notfound.com/beagle.png';
  const defaultPlaceholder = 'mobileId';
  const invalidPlaceholder = 'asset_does_not_exist';
  const errorStatusCode = 404;
  const imageKey = Key('BeagleImage');

  when(() => theme.image(defaultPlaceholder)).thenReturn('images/beagle_dog.png');

  when(() => beagle.urlBuilder.build(imageUrl)).thenReturn(imageUrl);

  when(() => beagle.urlBuilder.build(imageNotFoundUrl)).thenReturn(imageNotFoundUrl);

  when(() => theme.image(invalidPlaceholder)).thenReturn('');

  when(() => beagle.imageDownloader.downloadImage(imageUrl)).thenAnswer((invocation) {
    return Future<Uint8List>.value(mockedBeagleImageData);
  });
  when(() => beagle.imageDownloader.downloadImage(imageNotFoundUrl)).thenAnswer((invocation) {
    throw BeagleImageDownloaderException(statusCode: errorStatusCode, url: imageNotFoundUrl);
  });

  Widget createWidget({
    Key key = imageKey,
    BeagleImageDownloader? imageDownloader,
    required ImagePath path,
    required ImageContentMode mode,
  }) {
    return BeagleProviderMock(
      beagle: beagle,
      child: BeagleThemeProvider(
        theme: theme,
        child: MaterialApp(
          home: BeagleImage(
            key: key,
            path: path,
            mode: mode,
          ),
        ),
      ),
    );
  }

  Widget createLocalWidget({
    String placeholder = defaultPlaceholder,
    ImageContentMode mode = ImageContentMode.FIT_CENTER,
  }) {
    return createWidget(
      path: ImagePath.local(placeholder),
      mode: mode,
    );
  }

  Widget createRemoteWidget({
    String url = imageUrl,
    String placeholder = defaultPlaceholder,
    ImageContentMode mode = ImageContentMode.FIT_CENTER,
  }) {
    return createWidget(
      imageDownloader: beagle.imageDownloader,
      path: ImagePath.remote(
        url,
        ImagePath.local(placeholder) as LocalImagePath,
      ),
      mode: mode,
    );
  }

  Future<dynamic> precacheImageForTest(WidgetTester tester) async {
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(Image));
    final Image widget = element.widget as Image;
    final image = widget.image;
    await precacheImage(image, element);
    await tester.pumpAndSettle();

    return null;
  }

  group('Given a BeagleImage with a LocalImagePath', () {
    final localImage = createLocalWidget();

    group('When I set a valid path', () {
      testWidgets('Then it should have a Image widget child', (WidgetTester tester) async {
        await tester.pumpWidget(localImage);
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('Then it should present the correct local image', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(localImage);
          await precacheImageForTest(tester);
        });

        await expectLater(
          find.byType(Image),
          matchesGoldenFile('goldens/beagle_image_local.png'),
        );
      });
    });

    group('When I set an invalid path', () {
      testWidgets('Then it should render an empty container', (WidgetTester tester) async {
        await tester.pumpWidget(createLocalWidget(placeholder: invalidPlaceholder));
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('When I set mode to ImageContentMode.CENTER', () {
      testWidgets('Then the widget should have BoxFit.none', (WidgetTester tester) async {
        await tester.pumpWidget(createLocalWidget(mode: ImageContentMode.CENTER));
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.none);
      });
    });

    group('When I set mode to ImageContentMode.CENTER_CROP', () {
      testWidgets('Then the widget should have BoxFit.cover', (WidgetTester tester) async {
        await tester.pumpWidget(createLocalWidget(
          mode: ImageContentMode.CENTER_CROP,
        ));
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
      });
    });

    group('When I set mode to ImageContentMode.FIT_CENTER', () {
      testWidgets('Then the widget should have BoxFit.contain', (WidgetTester tester) async {
        await tester.pumpWidget(createLocalWidget(
          mode: ImageContentMode.FIT_CENTER,
        ));
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
      });
    });

    group('When I set mode to ImageContentMode.FIT_XY', () {
      testWidgets('Then the widget should have BoxFit.fill', (WidgetTester tester) async {
        await tester.pumpWidget(createLocalWidget(
          mode: ImageContentMode.FIT_XY,
        ));
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.fill);
      });
    });

    group('When I do not set ImageContentMode', () {
      testWidgets('Then the widget should have BoxFit.contain', (WidgetTester tester) async {
        await tester.pumpWidget(createLocalWidget());
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
      });
    });
  });

  group('Given a BeagleImage with a RemoteImagePath', () {
    group('When the widget is rendered', () {
      testWidgets('Then it should have a Image widget child', (WidgetTester tester) async {
        await tester.pumpWidget(createRemoteWidget());
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('Then it should present the correct remote image', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createRemoteWidget());
          await precacheImageForTest(tester);
        });

        await expectLater(
          find.byType(Image),
          matchesGoldenFile('goldens/beagle_image_remote.png'),
        );
      });
    });

    group('When remote image url is not found', () {
      testWidgets('Then it should present image placeholder', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createRemoteWidget(url: imageNotFoundUrl));
          await precacheImageForTest(tester);
        });

        await expectLater(
          find.byType(Image),
          matchesGoldenFile('goldens/beagle_image_remote_not_found.png'),
        );
      });
    });

    group('When remote image url is not found and placeholder is invalid', () {
      testWidgets('Then it should render an empty container', (WidgetTester tester) async {
        await tester.pumpWidget(createRemoteWidget(url: imageNotFoundUrl, placeholder: invalidPlaceholder));
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('When I set mode to ImageContentMode.CENTER', () {
      testWidgets('Then the widget should have BoxFit.none', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(
            createRemoteWidget(mode: ImageContentMode.CENTER),
          );
          await precacheImageForTest(tester);
        });

        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.none);
      });
    });

    group('When I set mode to ImageContentMode.CENTER_CROP', () {
      testWidgets('Then the widget should have BoxFit.cover', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createRemoteWidget(
            mode: ImageContentMode.CENTER_CROP,
          ));
          await precacheImageForTest(tester);
        });
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
      });
    });

    group('When I set mode to ImageContentMode.FIT_CENTER', () {
      testWidgets('Then the widget should have BoxFit.contain', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createRemoteWidget(
            mode: ImageContentMode.FIT_CENTER,
          ));
          await precacheImageForTest(tester);
        });
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
      });
    });

    group('When I set mode to ImageContentMode.FIT_XY', () {
      testWidgets('Then the widget should have BoxFit.fill', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createRemoteWidget(
            mode: ImageContentMode.FIT_XY,
          ));
          await precacheImageForTest(tester);
        });
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.fill);
      });
    });

    group('When I do not set ImageContentMode', () {
      testWidgets('Then the widget should have BoxFit.contain', (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createRemoteWidget());
          await precacheImageForTest(tester);
        });
        expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
      });
    });
  });
}
