// https://pub.dev/packages/mask_text_input_formatter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'numberTextFields.dart';


class TextFieldsMasked extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TextfieldsMaskedState();
}

class TextfieldsMaskedState extends State<TextFieldsMasked> {
  @override
  Widget build(BuildContext context) {
    final maskFormatter = new MaskTextInputFormatter(
        mask: '+# (###) ###-##-##',
        filter: { "#": RegExp(r'[0-9]') },
        type: MaskAutoCompletionType.lazy
    );

    return Container(
      constraints: BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          marginWidget,
          Text(
            'Masked field',
            style: TextStyle(fontSize: 25),
          ),
          marginWidget,
          Text('Type numbers:'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [maskFormatter],
          ),
        ],
      ),
    );
  }

}