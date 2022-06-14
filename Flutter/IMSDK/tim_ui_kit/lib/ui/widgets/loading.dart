import 'package:flutter/widgets.dart';

class Loading extends StatefulWidget {
  final double width;
  final double height;

  const Loading({Key? key, this.width = 14, this.height = 14})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  initState() {
    // 初始化旋转动画
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        _animationController.forward();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: .0, end: .9).animate(_animationController),
      child: Image.asset(
        "images/message_sending.png",
        package: 'tim_ui_kit',
        height: widget.width,
        width: widget.height,
      ),
    );
  }
}
