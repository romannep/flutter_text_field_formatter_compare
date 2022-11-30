import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_text_field_formatter_compare/NumberInput.dart';
import 'package:flutter_text_field_formatter_compare/TextFieldEnhanced.dart';
import 'package:url_launcher/url_launcher.dart';

const marginWidget = SizedBox(height: 20, width: 20);

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

Widget textLink(String text, String url) {
  return RichText(
    text: TextSpan(
      text: text,
      style: TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Uri.parse(url));
        },
    ),
  );
}

Widget cell(Widget child) {
  return Container(
    padding: EdgeInsets.all(10),
    child: child,
  );
}

class NumberFields extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NumberFieldsState();
}

final headerStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

class NumberFieldsState extends State<NumberFields> {
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
    final table = Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(200),
        1: FixedColumnWidth(150),
        2: FlexColumnWidth(),
        3: FixedColumnWidth(350),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        TableRow(
          children: [
            cell(Text('Name', style: headerStyle)),
            cell(Text('Source', style: headerStyle)),
            cell(Text('Try', style: headerStyle)),
            cell(Text('Description', style: headerStyle)),
          ],
        ),
        TableRow(
          children: [
            cell(Text('NumberInput from www.flutterclutter.dev')),
            cell(textLink(
                'https://www.flutterclutter.dev/flutter/tutorials/how-to-create-a-number-input/2021/86522/',
                'https://www.flutterclutter.dev/flutter/tutorials/how-to-create-a-number-input/2021/86522/')),
            cell(NumberInput(
              allowDecimal: true,
            )),
            cell(Text('''No fixed decimals
No triad separator            
            ''')),
          ],
        ),
        TableRow(
          children: [
            cell(Text(
                'Fixed point number input as Currency Text Input Formatter')),
            cell(textLink(
                'https://pub.dev/packages/currency_text_input_formatter',
                'https://pub.dev/packages/currency_text_input_formatter')),
            TextField(
              inputFormatters: [CurrencyTextInputFormatter()],
            ),
            cell(Text('''Numbers moves from decimal to integer
Triad separator is a symbol in edit field            
Full selection copies non numeric data''')),
          ],
        ),
        TableRow(
          children: [
            cell(Text('TextFieldEnhanced')),
            cell(textLink('-', '-')),
            Row(
              children: [
                Expanded(
                  child: TextFieldEnhanced(
                    decoration: InputDecoration(
                      label: Text('float'),
                    ),
                  ),
                ),
                marginWidget,
                Expanded(
                  child: TextFieldEnhanced(
                    decoration: InputDecoration(
                      label: Text('fixed point'),
                    ),
                  ),
                ),
              ],
            ),
            cell(Text(''' ''')),
          ],
        ),
      ],
    );

    return Column(
      children: [
        Text('Number inputs',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Container(
          padding: EdgeInsets.all(20),
          child: table,
        ),
      ],
    );

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
          NumberInput(
            label: 'test',
            allowDecimal: true,
          ),
          TextField(
            inputFormatters: [CurrencyTextInputFormatter()],
          ),
          textWithLink('Insert character through inputFormatter',
              'https://stackoverflow.com/questions/62821439/thousand-separator-in-flutter'),
          marginWidget,
          Text('Type numbers:'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
          ),
          marginWidget,
          Text('TextFieldEnhanced'),
          marginWidget,
          Text('Type numbers:'),
          TextFieldEnhanced(
            textFieldKey: Key('separated_1'),
            textFieldMirrorKey: Key('separated_1_mirror'),
            separateThousands: true,
            separator: '\'',
            controller: controller,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: false,
              contentPadding: EdgeInsets.all(50),
            ),
          ),
        ],
      ),
    );
  }
}

// https://pub.dev/documentation/currency_text_input_formatter/latest/
// fixed point:
// |0.00 - placeholder
// 1|.00
// 1.1|0

// features
// '-' can be typed at any place
// '.' as first character adds leading zero
// placeholder check
// input align at right check
// copy/paste check