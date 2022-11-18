

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const marginWidget = SizedBox(height: 20);

class TextFields extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TextfieldsState();
}

class TextfieldsState extends State<TextFields> {
  @override
  Widget build(BuildContext context) {
    final unformattedTextfield = TextField();
    return Container(
      constraints: BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          marginWidget,
          Text('Unformatted text field'),
          unformattedTextfield,
          marginWidget,
          Text('Unformatted text field'),
          unformattedTextfield,
          marginWidget,
        ],
      ),
    );
  }

}