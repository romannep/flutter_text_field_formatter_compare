import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_text_field_formatter_compare/TextFieldEnhanced.dart';
import 'package:url_launcher/url_launcher.dart';

const marginWidget = SizedBox(height: 20);

// https://stackoverflow.com/questions/62821439/thousand-separator-in-flutter
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ','; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1)
          newString = separator + newString;
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}

Widget textWithLink(String text, String url) {
  return RichText(
    text: new TextSpan(
      children: [
        TextSpan(
          text: '$text ',
        ),
        TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse(url));
            },
        ),
      ],
    ),
  );
}

class TextFieldsSeparated extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TextfieldsSeparatedState();
}

class TextfieldsSeparatedState extends State<TextFieldsSeparated> {

  final controller = TextEditingController();

  @override
  void initState() {
    controller.addListener(() {
      print('text is: ${controller.text}');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          marginWidget,
          Text(
            'Thousand separator',
            style: TextStyle(fontSize: 25),
          ),
          marginWidget,
          textWithLink('Insert character through inputFormatter',
              'https://stackoverflow.com/questions/62821439/thousand-separator-in-flutter'),
          Text('Type numbers:'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
          ),
          marginWidget,
          Text('TextFieldEnhanced'),
          Text('Type numbers:'),
          TextFieldEnhanced(
            separateThousands: true,
            separator: '\'',
            controller: controller,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
