import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';

class TIMUIKitTextElem extends StatefulWidget {
  final String text;
  final bool isFromSelf;
  final bool isShowJump;
  final VoidCallback clearJump;
  final TextStyle? fontStyle;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? textPadding;

  const TIMUIKitTextElem(
      {Key? key,
      required this.text,
      required this.isFromSelf,
      required this.isShowJump,
      required this.clearJump,
      this.fontStyle,
      this.borderRadius,
      this.backgroundColor,
      this.textPadding})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitTextElemState();
}

class _TIMUIKitTextElemState extends State<TIMUIKitTextElem> {
  bool isShowJumpState = false;

  @override
  void initState() {
    super.initState();
  }

  _showJumpColor() {
    int shineAmount = 10;
    setState(() {
      isShowJumpState = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.clearJump();
    });
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        timer.cancel();
      }
      shineAmount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final borderRadius = widget.isFromSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10));
    if (widget.isShowJump) {
      _showJumpColor();
    }
    final defaultStyle = widget.isFromSelf
        ? theme.lightPrimaryMaterialColor.shade50
        : theme.weakBackgroundColor;
    final backgroundColor = isShowJumpState
        ? const Color.fromRGBO(245, 166, 35, 1)
        : (widget.backgroundColor ?? defaultStyle);
    return Container(
      padding: widget.textPadding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.borderRadius ?? borderRadius,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      child: Text(
        widget.text,
        softWrap: true,
        style: widget.fontStyle ?? const TextStyle(fontSize: 16),
      ),
    );
  }
}
