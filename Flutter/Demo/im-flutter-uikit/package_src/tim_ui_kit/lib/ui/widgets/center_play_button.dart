import 'package:flutter/material.dart';

class CenterPlayButton extends StatelessWidget {
  const CenterPlayButton({
    Key? key,
    required this.show,
    required this.isPlaying,
    this.onPressed,
  }) : super(key: key);

  final bool show;
  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: AnimatedOpacity(
          opacity: show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            child: IconButton(
              iconSize: 86,
              icon: Image.asset('images/play.png', package: 'tim_ui_kit'),
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
