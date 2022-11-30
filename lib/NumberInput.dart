// https://www.flutterclutter.dev/flutter/tutorials/how-to-create-a-number-input/2021/86522/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatelessWidget {
  NumberInput({
    this.label,
    this.controller,
    this.value,
    this.onChanged,
    this.error,
    this.icon,
    this.allowDecimal = false,
  });

  final TextEditingController? controller;
  final String? value;
  final String? label;
  final Function? onChanged;
  final String? error;
  final Widget? icon;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: value,
      onChanged: onChanged as void Function(String)?,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal, signed: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(_getRegexString())),
        TextInputFormatter.withFunction(
              (oldValue, newValue) => newValue.copyWith(
            text: newValue.text.replaceAll('.', ','),
          ),
        ),
      ],
      decoration: InputDecoration(
        label: label != null ? Text(label!) : null,
        errorText: error,
        icon: icon,
      ),
    );
  }

  String _getRegexString() =>
      allowDecimal ? r'-?[0-9]+[,.]{0,1}[0-9]*' : r'-?[0-9]';
}