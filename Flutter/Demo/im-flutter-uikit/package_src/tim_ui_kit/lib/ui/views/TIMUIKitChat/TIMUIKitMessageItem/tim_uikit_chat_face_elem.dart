import 'dart:async';
import 'package:flutter/material.dart';

class TIMUIKitFaceElem extends StatefulWidget {
  final String path;
  final bool? isShowJump;
  final VoidCallback? clearJump;

  const TIMUIKitFaceElem(
      {Key? key, required this.path, this.isShowJump = false, this.clearJump})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitTextElemState();
}

class _TIMUIKitTextElemState extends State<TIMUIKitFaceElem> {
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
      if (widget.clearJump != null) {
        widget.clearJump!();
      }
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

  bool isFromNetwork() {
    return widget.path.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isShowJump!) {
      _showJumpColor();
    }
    return Container(
      padding: const EdgeInsets.all(10),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
      child: isFromNetwork()
          ? Image.network(widget.path)
          : Image.asset(widget.path),
    );
  }
}
