import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/ui/widgets/center_loading.dart';
import 'package:tim_ui_kit/ui/widgets/gestured_image.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/widgets/image_hero.dart';

typedef DoubleClickAnimationListener = void Function();

class ImageScreen extends StatefulWidget {
  const ImageScreen(
      {required this.imageProvider,
      required this.heroTag,
      required this.downloadFn,
      required this.messageID,
      Key? key})
      : super(key: key);

  final ImageProvider imageProvider;
  final String heroTag;
  final String? messageID;
  final void Function() downloadFn;

  @override
  State<StatefulWidget> createState() {
    return _ImageScreenState();
  }
}

class _ImageScreenState extends TIMUIKitState<ImageScreen>
    with TickerProviderStateMixin {
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  late AnimationController _doubleClickAnimationController;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  double currentScale = 1.0;
  double fittedScale = 1.0;
  double initialScale = 1.0;
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();

  GlobalKey<ExtendedImageGestureState> extendedImageGestureKey =
      GlobalKey<ExtendedImageGestureState>();

  void close() {
    slidePagekey.currentState!.popPage();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    // 允许横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _doubleClickAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return OrientationBuilder(builder: ((context, orientation) {
      return Container(
          color: Colors.transparent,
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(children: [
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: ExtendedImageSlidePage(
                key: slidePagekey,
                slideAxis: SlideAxis.both,
                slidePageBackgroundHandler: (Offset offset, Size size) {
                  if (orientation == Orientation.landscape) {
                    return Colors.black;
                  }
                  double opacity = 0.0;
                  opacity = offset.distance /
                      (Offset(size.width, size.height).distance / 2.0);
                  return Colors.black
                      .withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
                },
                slideType: SlideType.onlyImage,
                slideEndHandler: (
                  Offset offset, {
                  ExtendedImageSlidePageState? state,
                  ScaleEndDetails? details,
                }) {
                  final vy = details?.velocity.pixelsPerSecond.dy ?? 0;
                  final oy = offset.dy;
                  if (vy > 300 || oy > 100) {
                    return true;
                  }
                  return null;
                },
                child: GestureDetector(
                  onTap: close,
                  child: ExtendedImageGesturePageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: ExtendedPageController(
                        initialPage: 0,
                        pageSpacing: 0,
                        shouldIgnorePointerWhenScrolling: false,
                      ),
                      itemCount: 1,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return HeroWidget(
                            tag: widget.heroTag,
                            slidePagekey: slidePagekey,
                            child: ExtendedImage(
                              image: widget.imageProvider,
                              extendedImageGestureKey: extendedImageGestureKey,
                              enableSlideOutPage: true,
                              fit: BoxFit.contain,
                              initGestureConfigHandler: (state) {
                                return GestureConfig(
                                  minScale: 0.8,
                                  animationMinScale: 0.6,
                                  maxScale: 2 * fittedScale,
                                  animationMaxScale: 2.5 * fittedScale,
                                  speed: 1.0,
                                  inertialSpeed: 100.0,
                                  initialScale: initialScale,
                                  initialAlignment: InitialAlignment.topCenter,
                                  hitTestBehavior: HitTestBehavior.opaque,
                                );
                              },
                              loadStateChanged: (ExtendedImageState state) {
                                switch (state.extendedImageLoadState) {
                                  case LoadState.loading:
                                    return Container(
                                        color: Colors.black,
                                        child: const Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.white)));
                                  case LoadState.completed:
                                    final screenHeight =
                                        MediaQuery.of(context).size.height;
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final imgHeight =
                                        state.extendedImageInfo?.image.height ??
                                            1;
                                    final imgWidth =
                                        state.extendedImageInfo?.image.width ??
                                            0;
                                    final imgRatio = imgWidth / imgHeight;
                                    final screenRatio =
                                        screenWidth / screenHeight;
                                    final fitWidthScale =
                                        screenRatio / imgRatio;
                                    if (screenRatio > imgRatio) {
                                      // Long Image
                                      initialScale = fitWidthScale;
                                      fittedScale = fitWidthScale;
                                      doubleTapScales[1] = fitWidthScale;
                                    } else {
                                      fittedScale =
                                          1 / fitWidthScale; // fittedHeight
                                      doubleTapScales[1] = 1 / fitWidthScale;
                                    }
                                    return GesturedImage(state,
                                        key: extendedImageGestureKey);
                                  case LoadState.failed:
                                    break;
                                }
                                return null;
                              },
                              onDoubleTap: (ExtendedImageGestureState state) {
                                ///you can use define pointerDownPosition as you can,
                                ///default value is double tap pointer down postion.
                                final Offset? pointerDownPosition =
                                    state.pointerDownPosition;
                                final double? begin =
                                    state.gestureDetails!.totalScale;
                                double end;

                                //remove old
                                _doubleClickAnimation?.removeListener(
                                    _doubleClickAnimationListener);

                                //stop pre
                                _doubleClickAnimationController.stop();

                                //reset to use
                                _doubleClickAnimationController.reset();

                                if (begin == doubleTapScales[0]) {
                                  end = doubleTapScales[1];
                                } else {
                                  end = doubleTapScales[0];
                                }

                                _doubleClickAnimationListener = () {
                                  //print(_animation.value);
                                  state.handleDoubleTap(
                                      scale: _doubleClickAnimation!.value,
                                      doubleTapPosition: pointerDownPosition);
                                };
                                _doubleClickAnimation =
                                    _doubleClickAnimationController.drive(
                                        Tween<double>(begin: begin, end: end));

                                _doubleClickAnimation!
                                    .addListener(_doubleClickAnimationListener);

                                _doubleClickAnimationController.forward();
                              },
                              mode: ExtendedImageMode.gesture,
                            ));
                      }),
                ),
              ),
            ),
            Positioned(
                left: 10,
                bottom: 50,
                child: IconButton(
                  icon: Image.asset(
                    'images/close.png',
                    package: 'tim_ui_kit',
                  ),
                  iconSize: 30,
                  onPressed: close,
                )),
            Positioned(
              right: 10,
              bottom: 50,
              child: IconButton(
                icon: Image.asset(
                  'images/download.png',
                  package: 'tim_ui_kit',
                ),
                iconSize: 30,
                onPressed: widget.downloadFn,
              ),
            ),
            CenterLoading(messageID: widget.messageID),
          ]));
    }));
  }
}
