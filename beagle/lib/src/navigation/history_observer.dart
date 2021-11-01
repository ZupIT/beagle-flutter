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

import 'package:flutter/widgets.dart';

class HistoryObserver<T> extends NavigatorObserver {
  HistoryObserver(this._history, this._onPopLast);

  final List<T> _history;
  final void Function() _onPopLast;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _history.removeLast();
    if (_history.isEmpty) _onPopLast();
    super.didPop(route, previousRoute);
  }
}
