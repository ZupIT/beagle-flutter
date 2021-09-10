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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:beagle_components/beagle_components.dart';

/// This component defines a submit handler for a form request.
class BeagleSimpleForm extends StatefulWidget with YogaWidget {
  const BeagleSimpleForm({
    Key key,
    this.onSubmit,
    this.children,
    this.onValidationError
  }) : super(key: key);

  /// Defines the actions you want to execute when action submit form
  final Function onSubmit;

  /// Defines the items on the simple form.
  final List<Widget> children;

  /// Defines the actions to be executed when the form has some field with validation error.
  final Function onValidationError;

  @override
  BeagleSimpleFormState createState() => BeagleSimpleFormState();

  static of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<BeagleSimpleFormState>()
      : context.findAncestorStateOfType<BeagleSimpleFormState>();

}

class BeagleSimpleFormState extends State<BeagleSimpleForm> {
  BeagleYogaFactory beagleYogaFactory = beagleServiceLocator();

  @override
  Widget build(BuildContext context) {
    return beagleYogaFactory.createYogaLayout(
      style: BeagleStyle(),
      children: widget.children,
    );
  }

  void submit() {
    final hasError = _searchErrorInHierarchy();
    if (hasError) {
      if (widget.onValidationError != null) {
        widget.onValidationError();
      }
    } else {
      widget.onSubmit();
    }
  }

  bool _searchErrorInHierarchy() {
    bool hasError = false;

    void visitor(Element element) {
      if (element.widget is BeagleTextInput) {
        final errorMsg = (element.widget as BeagleTextInput).error;
        if(errorMsg != null && errorMsg.isNotEmpty) {
         hasError = true;
        }
      } else {
        element.visitChildElements(visitor);
      }
    }

    context.visitChildElements(visitor);

    return hasError;
  }
}
