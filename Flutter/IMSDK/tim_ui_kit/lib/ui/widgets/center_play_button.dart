import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class CenterPlayButton extends TIMUIKitStatelessWidget {
  CenterPlayButton({
    Key? key,
    required this.show,
    required this.isPlaying,
    this.onPressed,
  }) : super(key: key);

  final bool show;
  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
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
