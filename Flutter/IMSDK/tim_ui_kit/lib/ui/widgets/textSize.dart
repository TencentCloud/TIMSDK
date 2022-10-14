import 'package:flutter/material.dart';

class TextSize {
  static Size boundingTextSize(String text, TextStyle style,
      {int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return const Size(0, 0);
    }
    final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: style),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }
}

class ExtendText extends StatefulWidget {
  const ExtendText(
    this.text, {
    Key? key,
    required this.width,
    this.offset,
    this.overflowtext,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : super(key: key);
  final String text;
  final double width;
  final String? overflowtext;
  final int? offset;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  @override
  State<ExtendText> createState() => _ExtendTextState();
}

class _ExtendTextState extends State<ExtendText> {
  String? text;
  countTextSize() {
    TextStyle style = widget.style ?? const TextStyle(fontSize: 14);
    double textwidth = TextSize.boundingTextSize(widget.text, style).width;
    int offset = widget.offset ?? 3;
    if (textwidth > widget.width) {
      int position = widget.text.lastIndexOf('.');
      String overflowtext = widget.overflowtext ?? '...';
      int overflowtextLength = overflowtext.length;
      double singTextSize = textwidth / widget.text.length;
      String newtext =
          '${widget.text.substring(0, position - offset)}$overflowtext${widget.text.substring(position - offset, widget.text.length)}';
      position += overflowtextLength;
      int number = ((textwidth - widget.width) / singTextSize).ceil();
      do {
        int a = position - offset - overflowtextLength - number;
        newtext = newtext.substring(0, a < 1 ? 1 : a) +
            newtext.substring(
                position - offset - overflowtextLength, newtext.length);
        position -= number;
        number =
            ((TextSize.boundingTextSize(newtext, style).width - widget.width) /
                    singTextSize)
                .ceil();
        if (a < 1 || number < 1) {
          break;
        }
      } while (
          TextSize.boundingTextSize(newtext, style).width > widget.width - 20);
      text = newtext;
    }
  }

  @override
  void initState() {
    super.initState();
    countTextSize();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? widget.text,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
    );
  }
}
