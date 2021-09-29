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
import 'package:beagle_components/src/utils/build_context_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// This component defines a submit handler for a form request.
class BeagleSimpleForm extends StatefulWidget {
  const BeagleSimpleForm({
    Key key,
    this.onSubmit,
    this.children,
    this.style,
    this.onValidationError
  }) : super(key: key);

  /// Defines the actions you want to execute when action submit form
  final Function onSubmit;

  /// Defines the items on the simple form.
  final List<Widget> children;

  /// Property responsible to customize all the flex attributes and general style configuration
  final BeagleStyle style;

  /// Defines the actions to be executed when the form has some field with validation error.
  final Function onValidationError;

  @override
  BeagleSimpleFormState createState() => BeagleSimpleFormState();

  static BeagleSimpleFormState of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<BeagleSimpleFormState>()
      : context.findAncestorStateOfType<BeagleSimpleFormState>();

}

class BeagleSimpleFormState extends State<BeagleSimpleForm> {
  BeagleLogger logger = beagleServiceLocator<BeagleLogger>();
  @override
  Widget build(BuildContext context) {
    return BeagleFlexWidget(
      style: widget.style,
      children: widget.children,
    );
  }

  void submit() {
    final hasError = hasInputErrors();
    if (hasError) {
      logger.warning('BeagleSimpleForm: has a validation error');
      if (widget.onValidationError != null) {
        widget.onValidationError();
      } else {
        logger.warning('BeagleSimpleForm: you did not provided a validation function onValidationError');
      }
    } else {
      logger.info('BeagleSimpleForm: submitting form');
      widget.onSubmit();
    }
  }

  bool hasInputErrors() {
    return context.searchInputErrors();
  }
}
