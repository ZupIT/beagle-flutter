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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:beagle/beagle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test-utils/mocktail.dart';

class _HttpClientMock extends Mock implements HttpClient {}

class _BeagleLoggerMock extends Mock implements BeagleLogger {}

class _UrlBuilderMock extends Mock implements UrlBuilder {
  _UrlBuilderMock() {
    when(() => build(any())).thenAnswer((realInvocation) => realInvocation.positionalArguments[0]);
  }
}

void main() {
  registerMocktailFallbacks();
  dynamic payload;
   File('test/test-utils/payload.json').readAsString().then((contents) {
     payload = json.decode(contents);
  });

  group("Given the DefaultViewClient", () {
    late HttpClient httpClient;
    late UrlBuilder urlBuilder;
    late BeagleLogger logger;
    late DefaultViewClient viewClient;
    final url = 'https://test.com';
    final headers = {"myHeader": "test"};
    final body = {"requestBody": "body"};
    final data = HttpAdditionalData(method: BeagleHttpMethod.post, headers: headers, body: body);
    final route = RemoteView(url, httpAdditionalData: data);
    final routePrefetch = RemoteView(url, httpAdditionalData: data, shouldPrefetch: true);
    final responseBody = '{"_beagleComponent_": "beagle:container"}';
    final successfulResponse = Response(200, responseBody, {}, Uint8List.fromList([]));

    void setup() {
      httpClient = _HttpClientMock();
      urlBuilder = _UrlBuilderMock();
      logger = _BeagleLoggerMock();
      viewClient = DefaultViewClient(httpClient: httpClient, logger: logger, urlBuilder: urlBuilder);
    }

    group("When a RemoteView is fetched from a url that responds with success", () {
      late BeagleUIElement? result;

      setUpAll(() async {
        setup();
        when(() => httpClient.sendRequest(any())).thenAnswer((_) => Future.value(successfulResponse));
        result = await viewClient.fetch(route);
      });

      test("Then it should build the url", () {
        verify(() => urlBuilder.build(url)).called(1);
      });

      test("And it should make the request", () {
        final verified = verify(() => httpClient.sendRequest(captureAny()));
        verified.called(1);
        final request = verified.captured[0] as BeagleRequest;
        expect(request.url, url);
        expect(request.body, '{"requestBody":"body"}');
        expect(request.method, BeagleHttpMethod.post);
        expect(request.headers, headers);
      });

      test("And it should return the resulting screen", () {
        expect(result == null, false);
        expect(result?.getType(), "beagle:container");
      });
    });

    group("When a RemoteView is fetched from a url that responds with error", () {
      dynamic error;

      setUpAll(() {
        setup();
        when(() => httpClient.sendRequest(any()))
            .thenAnswer((_) => Future.value(Response(500, "", {}, Uint8List.fromList([]))));
      });

      test("Should fallback when a request failed", () async {
        final fallbackElement = BeagleUIElement({'_beagleComponent_': 'beagle:text', 'text': 'Fallback Page'});
        final response = await viewClient.fetch(RemoteView("/route", fallback: fallbackElement));

        expect(response, fallbackElement);
      });

      test("Then it should throw an error", () async {
        try {
          await viewClient.fetch(route);
        } catch (e) {
          error = e;
        }
        expect(error == null, false);
      });
    });

    group("When a RemoteView is fetched using only the url", () {
      setUpAll(() async {
        setup();
        when(() => httpClient.sendRequest(any())).thenAnswer((_) => Future.value(successfulResponse));
        await viewClient.fetch(RemoteView(url));
      });

      test("Then it should make the request using the HttpMethod GET", () {
        final verified = verify(() => httpClient.sendRequest(captureAny()));
        verified.called(1);
        final request = verified.captured[0] as BeagleRequest;
        expect(request.method, BeagleHttpMethod.get);
      });
    });

    group("When a RemoteView is prefetched from a url that responds with success", () {
      setUpAll(() async {
        setup();
        when(() => httpClient.sendRequest(any())).thenAnswer((_) => Future.value(successfulResponse));
        await viewClient.fetch(routePrefetch);
      });

      test("Then it should make the request", () {
        final verified = verify(() => httpClient.sendRequest(captureAny()));
        verified.called(1);
        final request = verified.captured[0] as BeagleRequest;
        expect(request.url, url);
        expect(request.body, '{"requestBody":"body"}');
        expect(request.method, BeagleHttpMethod.post);
        expect(request.headers, headers);
      });
    });

    group("When a fetch is called for the same URL as a previous prefetch", () {
      late BeagleUIElement? result;

      setUpAll(() async {
        setup();
        when(() => httpClient.sendRequest(any())).thenAnswer((_) => Future.value(successfulResponse));
        await viewClient.fetch(routePrefetch);
        result = await viewClient.fetch(RemoteView(url, shouldPrefetch: true));
      });

      test("Then it should not make a second request", () {
        verify(() => httpClient.sendRequest(captureAny())).called(2);
      });

      test("And it should return the result obtained by the prefetch", () {
        expect(result == null, false);
        expect(result?.getType(), "beagle:container");
      });
    });

    group("When a fetch is called twice for the same URL as a previous prefetch", () {
      late BeagleUIElement? result;

      setUpAll(() async {
        setup();
        when(() => httpClient.sendRequest(any())).thenAnswer((_) => Future.value(successfulResponse));
        await viewClient.fetch(routePrefetch);
        await viewClient.fetch(RemoteView(url));
        final newBody = '{"_beagleComponent_": "beagle:text"}';
        final newResponse = Response(200, newBody, {}, Uint8List.fromList([]));
        when(() => httpClient.sendRequest(any())).thenAnswer((_) => Future.value(newResponse));
        result = await viewClient.fetch(RemoteView(url,  shouldPrefetch: true));
      });

      test("Then it should have consumed the previous prefetch result and make another request", () {
        verify(() => httpClient.sendRequest(captureAny())).called(3);
      });

      test("And it should return the new result", () {
        expect(result == null, false);
        expect(result?.getType(), "beagle:text");
      });
    });

    group("When a RemoteView is prefetched from a url", () {
      dynamic error;
      setUpAll(() {
        setup();
        when(() => httpClient.sendRequest(any())).thenAnswer((_) {
          if ((_.positionalArguments[0] as BeagleRequest).url == "/payload") {
            return Future.value(Response(
                200, json.encode(payload), {}, Uint8List.fromList([])));
          } else if ((_.positionalArguments[0] as BeagleRequest).url ==
              "https://test.com") {
            return Future.value(Response(
                200, json.encode(payload), {}, Uint8List.fromList([])));
          }
          return Future.value(Response(500, "", {}, Uint8List.fromList([])));
        });
      });

      test("Then it should not throw error", () async {
        try {
          await viewClient.fetch(RemoteView("/payload"));
        } catch (e) {
          error = e;
        }
        expect(error == null, true);
      });

      test("Then the next fetch should make a request", () async {
        when(() => httpClient.sendRequest(any()))
            .thenAnswer((_) => Future.value(successfulResponse));
        await viewClient.fetch(route);
        verify(() => httpClient.sendRequest(any())).called(3);
      });
    });

    group("When a RemoteView is prefetched using only the url", () {
      setUpAll(() async {
        setup();
        when(() => httpClient.sendRequest(any())).thenAnswer((_) => Future.value(successfulResponse));
        await viewClient.fetch(RemoteView("/payload", shouldPrefetch: true));
      });

      test("Then it should make the request using the HttpMethod GET", () {
        final verified = verify(() => httpClient.sendRequest(captureAny()));
        verified.called(1);
        final request = verified.captured[0] as BeagleRequest;
        expect(request.method, BeagleHttpMethod.get);
      });
    });
  });
}
