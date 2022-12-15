import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/services.dart';

// TODO: floating label with separator
// TODO: copy/paste
// TODO: fix kerning problem

const int _zwjUtf16 = 0x200d;
final String _zeroWidthCharacter = String.fromCharCode(_zwjUtf16);

List<TextSpan> separateTextByThousands({
  required String text,
  double spacerWidth = 0,
  String separator = '',
}) {
  if (text == '') {
    return [];
  }
  List<TextSpan> spans = [];
  final int remainder = (text.length - 1) % 3;
  spans.add(TextSpan(text: text[text.length - 1]));
  for (int i = text.length - 2; i > -1; i--) {
    if (i % 3 == remainder) {
      if (separator == '') {
        spans.add(TextSpan(
          text: text[i],
          style: TextStyle(letterSpacing: spacerWidth),
        ));
      } else {
        spans.add(TextSpan(text: separator));
        spans.add(TextSpan(text: text[i]));
      }
    } else {
      spans.add(TextSpan(text: text[i]));
    }
  }

  return spans.reversed.toList();
}

const NUMBERS = '0123456789';

List<String> _extractIntegerPart(String text) {
  final List<String> parts = [_zeroWidthCharacter,'',''];
  if (text.length < 2) {
    return parts;
  }
  int i = 1;
  if (text[1] == '-') {
    parts[1] += '-';
    i++;
  }
  for (; i < text.length; i++) {
    if (NUMBERS.contains(text[i])) {
      parts[1] += text[i];
    } else {
      break;
    }
  }
  if (i < text.length) {
    parts[2] = text.substring(i);
  }
  return parts;
}

TextSpan _buildTextSpan({
  required TextEditingValue value,
  required TextStyle textFieldStyle,
  TextStyle? style,
  bool withComposing = false,
  required String text,
  double spacerWidth = 0,
  String separator = '', // will insert separator instead of space
}) {
  final _style = textFieldStyle.merge(style);

  if (!value.isComposingRangeValid || !withComposing) {
    final parts = _extractIntegerPart(text);
    return TextSpan(style: _style, children: [
        TextSpan(text: parts[0]),
        ...separateTextByThousands(
          text: parts[1],
          spacerWidth: spacerWidth,
          separator: separator,
        ),
        if (parts[2] != '')
          TextSpan(text: parts[2]),
      ],
    );
  }

  final TextStyle composingStyle =
  _style.merge(const TextStyle(decoration: TextDecoration.underline));

  final parts = _extractIntegerPart(value.composing.textInside(value.text));

  return TextSpan(
    style: _style,
    children: <TextSpan>[
      TextSpan(text: value.composing.textBefore(value.text)),
      TextSpan(
        style: composingStyle,
        children: [
          TextSpan(text: parts[0]),
          ...separateTextByThousands(
            text: parts[1],
            spacerWidth: spacerWidth,
            separator: separator,
          ),
          if (parts[2] != '')
            TextSpan(text: parts[2]),
        ],
      ),
      TextSpan(text: value.composing.textAfter(value.text)),
    ],
  );
}

class TextEditingControllerEnhanced extends TextEditingController {
  final String separator;
  final TextStyle textFieldStyle;
  late final double spacerWidth;

  TextEditingControllerEnhanced({
    String? text,
    required this.textFieldStyle,
    required this.separator,
  }) : super(text: text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: separator, style: textFieldStyle), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    spacerWidth = textPainter.width;
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing, }) {
    assert(!value.composing.isValid ||
        !withComposing ||
        value.isComposingRangeValid);

    return _buildTextSpan(
      value: value,
      textFieldStyle: textFieldStyle,
      text: text,
      style: style,
      withComposing: withComposing,
      spacerWidth: spacerWidth,
    );
  }
}

class TextEditingControllerEnhancedMirror extends TextEditingController {
  final TextStyle textFieldStyle;
  final String separator;

  TextEditingControllerEnhancedMirror({
    required this.textFieldStyle,
    required this.separator,
    super.text,
  });

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
        TextStyle? style,
        required bool withComposing, }) {

    return _buildTextSpan(
      value: value,
      textFieldStyle: textFieldStyle,
      text: text,
      style: style,
      withComposing: withComposing,
      separator: separator,
    );
  }
}

class TextFieldEnhanced extends StatelessWidget {

  final bool separateThousands;
  final String separator;
  final bool integer;
  final bool float;
  final bool fixedPoint;
  final int decimalDigits;
  final bool signed;
  final bool initialZero;

  TextFieldEnhanced({
    // TextFieldEnhanced properties
    this.textFieldKey,
    this.textFieldMirrorKey,
    this.separateThousands = false,
    this.separator = ' ',
    this.integer = false,
    this.float = false,
    this.fixedPoint = false,
    this.decimalDigits = 0,
    this.signed = false,
    this.initialZero = true,
    // TextField properties
    super.key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.toolbarOptions,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
  }) {
    assert(separator.length == 1, 'Separator should be a single character.');
    assert([integer, float, fixedPoint].where((element) => element).length < 2, 'Only one number type allowed');
  }

  final Key? textFieldMirrorKey;
  final Key? textFieldKey;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final ToolbarOptions? toolbarOptions;
  final bool? showCursor;
  static const int noMaxLength = -1;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final DragStartBehavior dragStartBehavior;
  final GestureTapCallback? onTap;
  final MouseCursor? mouseCursor;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final Iterable<String>? autofillHints;
  final Clip clipBehavior;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool enableIMEPersonalizedLearning;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle effectiveStyle = theme.textTheme.subtitle1!.merge(style);

    return _TextFieldEnhancedWidget(
      parent: this,
      style: effectiveStyle,
    );
  }
}

TextEditingValue addZeroIfNeed(TextEditingValue value, String delimiter) {
  if (value.text.indexOf(delimiter) == -1) {
    if ((value.text.startsWith('-') && value.text.length == 1)
    || (value.text.length == 0)) {
      return TextEditingValue(
        text: value.text + '0',
        selection: TextSelection(
          baseOffset: value.selection.baseOffset + 1,
          extentOffset: value.selection.baseOffset + 1,
        ),
      );
    }

    return value;
  }
  // assuming that selection offset is greater than delimiter position
  if (value.text.startsWith('-')) {
    if (value.text[1] == delimiter) {
      return TextEditingValue(
        text: '-0' + value.text.replaceAll('-', ''),
        selection: TextSelection(
          baseOffset: value.selection.baseOffset + 1,
          extentOffset: value.selection.baseOffset + 1,
        ),
      );
    } else {
      return value;
    }
  } else {
    if (value.text.startsWith(delimiter)) {
      return TextEditingValue(
        text: '0' + value.text,
        selection: TextSelection(
          baseOffset: value.selection.baseOffset + 1,
          extentOffset: value.selection.baseOffset + 1,
        ),
      );
    } else {
      return value;
    }
  }
}

TextEditingValue removeExtraLeadingZeros(TextEditingValue value, String delimiter) {
  // 1|000. -> |000. -> 0|.
  // 1|000 -> |000 -> 0|
  // 0 -> 00| -> 0|
  // 0.|001 -> 0|001 -> 1|
  // 1|001 -> |001 -> 1|  // |1 is logic, but in case 0 -> 01 we get weird result
  final text = value.text;
  int extraZerosStart = -1;
  int extraZerosCount = 0;
  int i = 0;
  for (; i < text.length; i++) {
    final character = text[i];
    if (character == '-') {
      continue;
    }
    if (character != '0') {
      break;
    }
    extraZerosCount++;
    if (extraZerosStart == -1) {
      extraZerosStart = i;
    }
  }

  if (i-1 == text.length - 1) {
    extraZerosCount--;
  } else if (text[i] == delimiter) {
      extraZerosCount--;
  }

  if (extraZerosCount > 0) {
    return TextEditingValue(
      text: text.substring(0, extraZerosStart) + text.substring(extraZerosStart + extraZerosCount),
      selection: TextSelection(
        baseOffset: extraZerosStart + 1,
        extentOffset: extraZerosStart + 1,
      ),
    );
  } else {
    return value;
  }
}

class NumberFormatter extends TextInputFormatter {
  final bool integer;
  final bool float;
  final bool fixedPoint;
  final int decimalDigits;
  final bool signed;
  final String delimiter;
  String allowedChars = NUMBERS;

  NumberFormatter({
    required this.integer,
    required this.float,
    required this.fixedPoint,
    required this.decimalDigits,
    required this.signed,
    this.delimiter = '.',
  }) {
    if (signed) {
      allowedChars += '-';
    }
    if (float || fixedPoint) {
      allowedChars += delimiter;
    }
  }
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If extra letter space added to first character it also
    // adds space before character - so mirror text does not match.
    // We need to add symbol as first.
    final needRemoveZWC = oldValue.text.isNotEmpty && oldValue.text[0] == _zeroWidthCharacter;
    final _oldValue = TextEditingValue(
      text: oldValue.text.replaceAll(_zeroWidthCharacter, ''),
      selection: TextSelection(
        baseOffset: oldValue.selection.baseOffset - (needRemoveZWC ? 1 : 0),
        extentOffset: oldValue.selection.extentOffset - (needRemoveZWC ? 1 : 0),
      ),
    );
    final _newValue = TextEditingValue(
      text: newValue.text.replaceAll(_zeroWidthCharacter, ''),
      selection: TextSelection(
        baseOffset: newValue.selection.baseOffset - (needRemoveZWC ? 1 : 0),
        extentOffset: newValue.selection.extentOffset - (needRemoveZWC ? 1 : 0),
      ),
    );


    final formattedValue = removeExtraLeadingZeros(addZeroIfNeed(_formatEditUpdateNumber(_oldValue, _newValue), delimiter), delimiter);
    return TextEditingValue(
      text: _zeroWidthCharacter + formattedValue.text,
      selection: TextSelection(
        baseOffset: formattedValue.selection.baseOffset + 1,
        extentOffset: formattedValue.selection.extentOffset + 1,
      ),
    );
  }

  TextEditingValue _formatEditUpdateNumber(TextEditingValue oldValue, TextEditingValue newValue) {

    if (oldValue.text.length - newValue.text.length == -1) {
      // 1 character inserted
      print('inserted ${newValue.text[newValue.selection.baseOffset - 1]}');
      final insertedChar = newValue.text[newValue.selection.baseOffset - 1];
      if (allowedChars.indexOf(insertedChar) == -1 ) {
        return oldValue;
      }

      if (insertedChar == '-') {
        if (oldValue.text.length > 0 && oldValue.text[0] == '-') {
          return TextEditingValue(
            text: oldValue.text.substring(1),
            selection: TextSelection(
              baseOffset: oldValue.selection.baseOffset - 1,
              extentOffset: oldValue.selection.baseOffset - 1,
            ),
          );
        } else {
          return TextEditingValue(
            text: '-' + oldValue.text,
            selection: TextSelection(
              baseOffset: oldValue.selection.baseOffset + 1,
              extentOffset: oldValue.selection.baseOffset + 1,
            ),
          );
        }
      }


      // trim leading zeros after move delimiter (also for in 1000001 - rm first)
      // add 0. if placind delimiter at start

      if (insertedChar == delimiter && float) {
        if (oldValue.text[0] == '-' && newValue.text[0] == delimiter) {
          return oldValue;
        }

        if (oldValue.text.indexOf(delimiter) == -1) {
          return newValue;
        }

        final bool newDelimiterPlacedAfterExisting = oldValue.selection.baseOffset >= oldValue.text.indexOf(delimiter);
        final fixedValue = oldValue.text.replaceAll(delimiter, '');
        final int newDelimiterPosition = newDelimiterPlacedAfterExisting ? oldValue.selection.baseOffset -1 : oldValue.selection.baseOffset;

        return TextEditingValue(
          text: fixedValue.substring(0, newDelimiterPosition) + delimiter + fixedValue.substring(newDelimiterPosition),
          selection: TextSelection(
            baseOffset: newDelimiterPosition + 1,
            extentOffset: newDelimiterPosition + 1,
          ),
        );
      } else if (insertedChar == delimiter && fixedPoint) {
        // todo: move to decimals

        return oldValue;
      }

      // here only numbers are possible

      return newValue; // TODO: remove me
    } else if (oldValue.text.length - newValue.text.length == 1) {
      // 1 character deleted
    } else {
      // copy/paste/bulk/selection change
    }

    return newValue;
  }
}

class _TextFieldEnhancedWidget extends StatefulWidget {
  final TextFieldEnhanced parent;
  final TextStyle style;

  _TextFieldEnhancedWidget({
    required this.parent,
    required this.style,
  });

  @override
  State<StatefulWidget> createState() => _TextFieldEnhancedState();
}

class _TextFieldEnhancedState extends State<_TextFieldEnhancedWidget> {
  late final TextEditingController _controller;
  late final TextEditingController _controllerMirror;
  final List<TextInputFormatter> _inputFormatters = [];

  initState() {
    final initialText = widget.parent.controller != null ? widget.parent.controller!.text :
      (widget.parent.initialZero ? _zeroWidthCharacter + '0' : '');

    _controller = widget.parent.separateThousands ? TextEditingControllerEnhanced(
      text: initialText,
      separator: widget.parent.separator,
      textFieldStyle: widget.style,
    ) : TextEditingController();

    _inputFormatters.addAll(widget.parent.inputFormatters ?? []);
    
    _inputFormatters.add(TextInputFormatter.withFunction(
          (oldValue, newValue) => newValue.copyWith(
        text: newValue.text.replaceAll(' ', ''),
      ),
    ));
    if (widget.parent.integer || widget.parent.float || widget.parent.fixedPoint) {
      _inputFormatters.add(NumberFormatter(
        integer: widget.parent.integer,
        float: widget.parent.float,
        fixedPoint: widget.parent.fixedPoint,
        decimalDigits: widget.parent.decimalDigits,
        signed: widget.parent.signed,
      ));
    }

    _controllerMirror = TextEditingControllerEnhancedMirror(
      text: initialText,
      textFieldStyle: widget.style,
      separator: widget.parent.separator,
    );
    _controller.addListener(() {
      print('val text ${_controller.text}');
      if (_controller.value.selection.baseOffset == 0) {
        _controller.selection = _controller.value.selection.copyWith(baseOffset: 1);
      }
      if (widget.parent.controller != null) {
        widget.parent.controller!.value = _controller.value;
      }
      _controllerMirror.value = _controller.value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      key: widget.parent.textFieldKey,
      controller: _controller,
      focusNode: widget.parent.focusNode,
      decoration: widget.parent.decoration,
      keyboardType: widget.parent.keyboardType,
      textInputAction: widget.parent.textInputAction,
      textCapitalization: widget.parent.textCapitalization,
      style: widget.style,
      strutStyle: widget.parent.strutStyle,
      textAlign: widget.parent.textAlign,
      textAlignVertical: widget.parent.textAlignVertical,
      textDirection: widget.parent.textDirection,
      readOnly: widget.parent.readOnly,
      toolbarOptions: widget.parent.toolbarOptions,
      showCursor: widget.parent.showCursor,
      autofocus: widget.parent.autofocus,
      obscuringCharacter: widget.parent.obscuringCharacter,
      obscureText: widget.parent.obscureText,
      autocorrect: widget.parent.autocorrect,
      smartDashesType: widget.parent.smartDashesType,
      smartQuotesType: widget.parent.smartQuotesType,
      enableSuggestions: widget.parent.enableSuggestions,
      maxLines: widget.parent.maxLines,
      minLines: widget.parent.minLines,
      expands: widget.parent.expands,
      maxLength: widget.parent.maxLength,
      maxLengthEnforcement: widget.parent.maxLengthEnforcement,
      onChanged: widget.parent.onChanged,
      onEditingComplete: widget.parent.onEditingComplete,
      onSubmitted: widget.parent.onSubmitted,
      onAppPrivateCommand: widget.parent.onAppPrivateCommand,
      inputFormatters: _inputFormatters,
      enabled: widget.parent.enabled,
      cursorWidth: widget.parent.cursorWidth,
      cursorHeight: widget.parent.cursorHeight,
      cursorRadius: widget.parent.cursorRadius,
      cursorColor: widget.parent.cursorColor,
      selectionHeightStyle: widget.parent.selectionHeightStyle,
      selectionWidthStyle: widget.parent.selectionWidthStyle,
      keyboardAppearance: widget.parent.keyboardAppearance,
      scrollPadding: widget.parent.scrollPadding,
      dragStartBehavior: widget.parent.dragStartBehavior,
      enableInteractiveSelection: widget.parent.enableInteractiveSelection,
      selectionControls: widget.parent.selectionControls,
      onTap: widget.parent.onTap,
      mouseCursor: widget.parent.mouseCursor,
      buildCounter: widget.parent.buildCounter,
      scrollController: widget.parent.scrollController,
      scrollPhysics: widget.parent.scrollPhysics,
      autofillHints: widget.parent.autofillHints,
      clipBehavior: widget.parent.clipBehavior,
      restorationId: widget.parent.restorationId,
      scribbleEnabled: widget.parent.scribbleEnabled,
      enableIMEPersonalizedLearning: widget.parent.enableIMEPersonalizedLearning,
    );

    if (widget.parent.separator == ' ') {
      return textField;
    }

    final textFieldMirror = TextField(
      key: widget.parent.textFieldMirrorKey,
      controller: _controllerMirror,
      focusNode: widget.parent.focusNode,
      decoration: widget.parent.decoration,
      keyboardType: widget.parent.keyboardType,
      textInputAction: widget.parent.textInputAction,
      textCapitalization: widget.parent.textCapitalization,
      style: widget.style,
      strutStyle: widget.parent.strutStyle,
      textAlign: widget.parent.textAlign,
      textAlignVertical: widget.parent.textAlignVertical,
      textDirection: widget.parent.textDirection,
      readOnly: widget.parent.readOnly,
      toolbarOptions: widget.parent.toolbarOptions,
      showCursor: widget.parent.showCursor,
      autofocus: widget.parent.autofocus,
      obscuringCharacter: widget.parent.obscuringCharacter,
      obscureText: widget.parent.obscureText,
      autocorrect: widget.parent.autocorrect,
      smartDashesType: widget.parent.smartDashesType,
      smartQuotesType: widget.parent.smartQuotesType,
      enableSuggestions: widget.parent.enableSuggestions,
      maxLines: widget.parent.maxLines,
      minLines: widget.parent.minLines,
      expands: widget.parent.expands,
      maxLength: widget.parent.maxLength,
      maxLengthEnforcement: widget.parent.maxLengthEnforcement,
      onChanged: widget.parent.onChanged,
      onEditingComplete: widget.parent.onEditingComplete,
      onSubmitted: widget.parent.onSubmitted,
      onAppPrivateCommand: widget.parent.onAppPrivateCommand,
      inputFormatters: widget.parent.inputFormatters,
      enabled: widget.parent.enabled,
      cursorWidth: widget.parent.cursorWidth,
      cursorHeight: widget.parent.cursorHeight,
      cursorRadius: widget.parent.cursorRadius,
      cursorColor: widget.parent.cursorColor,
      selectionHeightStyle: widget.parent.selectionHeightStyle,
      selectionWidthStyle: widget.parent.selectionWidthStyle,
      keyboardAppearance: widget.parent.keyboardAppearance,
      scrollPadding: widget.parent.scrollPadding,
      dragStartBehavior: widget.parent.dragStartBehavior,
      enableInteractiveSelection: widget.parent.enableInteractiveSelection,
      selectionControls: widget.parent.selectionControls,
      onTap: widget.parent.onTap,
      mouseCursor: widget.parent.mouseCursor,
      buildCounter: widget.parent.buildCounter,
      scrollController: widget.parent.scrollController,
      scrollPhysics: widget.parent.scrollPhysics,
      autofillHints: widget.parent.autofillHints,
      clipBehavior: widget.parent.clipBehavior,
      restorationId: widget.parent.restorationId,
      scribbleEnabled: widget.parent.scribbleEnabled,
      enableIMEPersonalizedLearning: widget.parent.enableIMEPersonalizedLearning,
    );

    return Stack(
      children: [
        textFieldMirror,
        textField,
      ],
    );
  }
}
