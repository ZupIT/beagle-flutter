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
import 'package:flutter/widgets.dart';

class BeagleFlexWidget extends StatefulWidget {
  BeagleFlexWidget({
    Key? key,
    this.style,
    required this.children,
  }) : super(key: key);

  final BeagleStyle? style;
  final List<Widget> children;

  @override
  _BeagleFlexWidget createState() => _BeagleFlexWidget();
}

class _BeagleFlexWidget extends State<BeagleFlexWidget> with BeagleConsumer {
  @override
  Widget buildBeagleWidget(BuildContext context) {
    return beagle.yoga.createYogaLayout(
      style: widget.style,
      children: widget.children,
    );
  }
}
