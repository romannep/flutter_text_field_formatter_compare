import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/services.dart';

// TODO: take in account numbers after dot

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
    return TextSpan(style: _style, children: separateTextByThousands(
      text: text,
      spacerWidth: spacerWidth,
      separator: separator,
    ));
  }

  final TextStyle composingStyle =
  _style.merge(const TextStyle(decoration: TextDecoration.underline));

  return TextSpan(
    style: _style,
    children: <TextSpan>[
      TextSpan(text: value.composing.textBefore(value.text)),
      TextSpan(
        style: composingStyle,
        children: separateTextByThousands(
          text: value.composing.textInside(value.text),
          spacerWidth: spacerWidth,
          separator: separator,
        ),
      ),
      TextSpan(text: value.composing.textAfter(value.text)),
    ],
  );
}

class TextEditingControllerEnhanced extends TextEditingController {
  final bool separateThousands;
  final String separator;
  final TextStyle textFieldStyle;
  late final double spacerWidth;

  TextEditingControllerEnhanced({
    String? text,
    required this.textFieldStyle,
    required this.separateThousands,
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

  TextFieldEnhanced({
    // TextFieldEnhanced properties
    this.separateThousands = false,
    this.separator = ' ',
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
  }

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

  initState() {
    _controller = TextEditingControllerEnhanced(
      text: widget.parent.controller != null ? widget.parent.controller!.text : null,
      separateThousands: widget.parent.separateThousands,
      separator: widget.parent.separator,
      textFieldStyle: widget.style,
    );
    _controllerMirror = TextEditingControllerEnhancedMirror(
      textFieldStyle: widget.style,
      separator: widget.parent.separator,
    );
    _controller.addListener(() {
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

    if (widget.parent.separator == ' ') {
      return textField;
    }

    final textFieldMirror = TextField(
      controller: _controllerMirror,
      focusNode: widget.parent.focusNode,
      decoration: widget.parent.decoration,
      keyboardType: widget.parent.keyboardType,
      textInputAction: widget.parent.textInputAction,
      textCapitalization: widget.parent.textCapitalization,
      style: TextStyle(color: Colors.red),// widget.style,
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
