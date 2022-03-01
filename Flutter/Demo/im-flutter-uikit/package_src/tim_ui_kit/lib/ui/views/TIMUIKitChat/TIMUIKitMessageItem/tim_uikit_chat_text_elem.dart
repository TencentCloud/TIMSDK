import 'package:flutter/material.dart';

class TIMUIKitTextElem extends StatefulWidget {
  final String text;
  final bool isFromSelf;

  const TIMUIKitTextElem(
      {Key? key, required this.text, required this.isFromSelf})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitTextElemState();
}

class _TIMUIKitTextElemState extends State<TIMUIKitTextElem> {
  @override
  Widget build(BuildContext context) {
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
    final backgroundColor = widget.isFromSelf
        ? const Color.fromRGBO(220, 234, 253, 1)
        : const Color.fromRGBO(236, 236, 236, 1);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      child: Text(
        widget.text,
        softWrap: true,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
