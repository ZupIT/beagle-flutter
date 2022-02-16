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
import 'package:beagle_components/src/protocol/input_validation.dart';
import 'package:flutter/material.dart';
import 'text_input_type.dart';

/// Defines a text field that lets the user enter text.
class BeagleTextInput extends StatefulWidget implements InputValidation {
  const BeagleTextInput({
    Key? key,
    this.value,
    this.placeholder,
    this.enabled,
    this.readOnly,
    this.type,
    this.error,
    this.showError,
    this.onChange,
    this.onBlur,
    this.onFocus,
    this.style,
  }) : super(key: key);

  /// Initial text displayed.
  final String? value;

  /// A label text that is shown when the text is empty.
  final String? placeholder;

  /// tells whether this field is enabled. Default is true.
  final bool? enabled;

  /// tells whether this field is readOnly. Default is false.
  final bool? readOnly;

  /// Type of data represented by the text input. This sets both the keyboard type and whether or not the content will
  /// be obscured. The content is obscured when the type is "PASSWORD". Note that Flutter can't change the keyboard
  /// type after the component is rendered, which means that, when this property is changed, only the effect to obscure
  /// the text content is updated.
  final BeagleTextInputType? type;

  /// An error string for validation.
  final String? error;

  /// Whether or not to show the error string. Default is false.
  final bool? showError;

  /// Action that will be performed when text change.
  final Function? onChange;

  /// Action that will be performed when the widget looses its focus.
  final Function? onBlur;

  /// Action that will be performed when the widget acquire focus.
  final Function? onFocus;

  final BeagleStyle? style;

  @override
  _BeagleTextInput createState() => _BeagleTextInput();

  @override
  bool hasError() {
    return error != null && error!.isNotEmpty;
  }
}

class _BeagleTextInput extends State<BeagleTextInput> {
  TextEditingController? _controller;
  FocusNode? _focus;

  @override
  void initState() {
    super.initState();
    addFieldListeners();
  }

  void addFieldListeners() {
    if (widget.onBlur != null || widget.onFocus != null) {
      _focus = FocusNode();
      _focus!.addListener(() {
        if (_focus!.hasFocus && widget.onFocus != null) {
          widget.onFocus!({'value': _controller?.text});
        }
        if (!_focus!.hasFocus && widget.onBlur != null) {
          widget.onBlur!({'value': _controller?.text});
        }
      });
    }

    _controller = TextEditingController();
    if (widget.onChange != null) {
      _controller?.addListener(() {
        if ((widget.value ?? '') != _controller?.text) {
          widget.onChange!({'value': _controller?.text});
        }
      });
    }
  }

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    if (_focus != null) _focus!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldExpandFlex = widget.style?.size?.height?.value != null;

    if (_controller != null &&
        widget.value != null &&
        widget.value != _controller?.text) {
      _controller?.text = widget.value ?? '';
    }

    InputBorder _getBorder(Color defaultColor) => OutlineInputBorder(
      borderRadius: StyleUtils.hasBorderRadius(widget.style)
          ? StyleUtils.getBorderRadius(widget.style)! : BorderRadius.all(Radius.circular(4.0)),
      borderSide: BorderSide(
        color: widget.style?.borderColor == null ? defaultColor : HexColor(widget.style!.borderColor!),
        width: widget.style?.borderWidth ?? 1,
      ),
    );

    final textField = TextField(
      controller: _controller,
      focusNode: _focus,
      enabled: widget.enabled != false,
      keyboardType:
          getMaterialInputType(widget.type ?? BeagleTextInputType.TEXT),
      obscureText: widget.type == BeagleTextInputType.PASSWORD,
      readOnly: widget.readOnly == true,
      maxLines: shouldExpandFlex ? null : 1,
      expands: shouldExpandFlex,
      decoration: InputDecoration(
        // we won't support percentage paddings in the TextInput for now
        contentPadding: StyleUtils.hasEdgeValue(widget.style?.padding)
            ? StyleUtils.getEdgeInsets(widget.style?.padding, BoxConstraints.tight(Size(100, 100))) : null,
        enabledBorder: _getBorder(Colors.black38),
        focusedBorder: _getBorder(Colors.blueAccent),
        errorBorder: _getBorder(Colors.redAccent),
        disabledBorder: _getBorder(Colors.grey),
        fillColor: widget.style?.backgroundColor == null ? null : HexColor(widget.style!.backgroundColor!),
        filled: widget.style?.backgroundColor != null,
        errorText: widget.showError == true ? widget.error : null,
        labelText: widget.placeholder ?? '',
      ),
    );

    return shouldExpandFlex ? Expanded(child: textField) : textField;
  }
}
