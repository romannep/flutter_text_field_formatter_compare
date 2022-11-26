import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_text_field_formatter_compare/main.dart';


void main() {
  testWidgets('Mirror builds separated text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final BuildContext context = tester.element(find.byType(MyApp));
    await tester.enterText(find.byKey(Key('separated_1')), '1234');
    await tester.pump();
    final mirrorTextField = find.byKey(Key('separated_1_mirror')).evaluate().single.widget as TextField;
    final mirrorText = mirrorTextField.controller!.buildTextSpan(context: context, withComposing: false).toPlainText();
    expect(mirrorText, '1\'234');
  });
}
