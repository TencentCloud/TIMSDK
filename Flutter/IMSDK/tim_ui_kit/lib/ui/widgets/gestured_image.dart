import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

Map<Object?, GestureDetails?> _gestureDetailsCache =
    <Object?, GestureDetails?>{};

///clear the gesture details
void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}

/// scale idea from https://github.com/flutter/flutter/blob/master/examples/layers/widgets/gestures.dart
/// zoom image
class GesturedImage extends ExtendedImageGesture {
  const GesturedImage(ExtendedImageState extendedImageState,
      {ImageBuilderForGesture? imageBuilder,
      CanScaleImage? canScaleImage,
      Key? key})
      : super(extendedImageState,
            imageBuilder: imageBuilder, canScaleImage: canScaleImage, key: key);

  @override
  GesturedImageState createState() => GesturedImageState();
}

class GesturedImageState extends ExtendedImageGestureState {
  ///details for gesture
  GestureDetails? _gestureDetails;
  late Offset _normalizedOffset;
  double? _startingScale;
  late Offset _startingOffset;
  Offset? _pointerDownPosition;
  late GestureAnimation _gestureAnimation;
  GestureConfig? _gestureConfig;
  ExtendedImageGesturePageViewState? _pageViewState;
  @override
  ExtendedImageSlidePageState? get extendedImageSlidePageState =>
      widget.extendedImageState.slidePageState;

  @override
  GestureDetails? get gestureDetails => _gestureDetails;

  @override
  set gestureDetails(GestureDetails? value) {
    if (mounted) {
      setState(() {
        _gestureDetails = value;
        _gestureConfig?.gestureDetailsIsChanged?.call(_gestureDetails);
      });
    }
  }

  @override
  GestureConfig? get imageGestureConfig => _gestureConfig;

  @override
  Offset? get pointerDownPosition => _pointerDownPosition;

  @override
  Widget build(BuildContext context) {
    if (_gestureConfig!.cacheGesture) {
      _gestureDetailsCache[widget.extendedImageState.imageStreamKey] =
          _gestureDetails;
    }

    Widget image = ExtendedRawImage(
      image: widget.extendedImageState.extendedImageInfo?.image,
      width: widget.extendedImageState.imageWidget.width,
      height: widget.extendedImageState.imageWidget.height,
      scale: widget.extendedImageState.extendedImageInfo?.scale ?? 1.0,
      color: widget.extendedImageState.imageWidget.color,
      colorBlendMode: widget.extendedImageState.imageWidget.colorBlendMode,
      fit: widget.extendedImageState.imageWidget.fit,
      alignment: widget.extendedImageState.imageWidget.alignment,
      repeat: widget.extendedImageState.imageWidget.repeat,
      centerSlice: widget.extendedImageState.imageWidget.centerSlice,
      matchTextDirection:
          widget.extendedImageState.imageWidget.matchTextDirection,
      invertColors: widget.extendedImageState.invertColors,
      filterQuality: widget.extendedImageState.imageWidget.filterQuality,
      beforePaintImage: widget.extendedImageState.imageWidget.beforePaintImage,
      afterPaintImage: widget.extendedImageState.imageWidget.afterPaintImage,
      gestureDetails: _gestureDetails,
    );

    if (extendedImageSlidePageState != null) {
      image = widget.extendedImageState.imageWidget.heroBuilderForSlidingPage
              ?.call(image) ??
          image;
      if (extendedImageSlidePageState!.widget.slideType ==
          SlideType.onlyImage) {
        image = Transform.translate(
          offset: extendedImageSlidePageState!.offset,
          child: Transform.scale(
            scale: extendedImageSlidePageState!.scale,
            child: image,
          ),
        );
      }
    }

    image = widget.imageBuilder?.call(image) ?? image;

    image = GestureDetector(
      onScaleStart: handleScaleStart,
      onScaleUpdate: handleScaleUpdate,
      onScaleEnd: handleScaleEnd,
      onDoubleTap: _handleDoubleTap,
      child: image,
      behavior: _gestureConfig?.hitTestBehavior,
    );

    image = Listener(
      child: image,
      onPointerDown: _handlePointerDown,
      onPointerSignal: _handlePointerSignal,
      behavior: _gestureConfig!.hitTestBehavior,
    );

    return image;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageViewState = null;
    if (_gestureConfig!.inPageView) {
      _pageViewState =
          context.findAncestorStateOfType<ExtendedImageGesturePageViewState>();
      _pageViewState?.extendedImageGestureState = this;
    }
  }

  @override
  void didUpdateWidget(GesturedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initGestureConfig();
    _pageViewState = null;
    if (_gestureConfig!.inPageView) {
      _pageViewState =
          context.findAncestorStateOfType<ExtendedImageGesturePageViewState>();
      _pageViewState?.extendedImageGestureState = this;
    }
  }

  @override
  void dispose() {
    _gestureAnimation.stop();
    _gestureAnimation.dispose();
    _pageViewState?.extendedImageGestureStates.remove(this);
    super.dispose();
  }

  @override
  void handleDoubleTap({double? scale, Offset? doubleTapPosition}) {
    doubleTapPosition ??= _pointerDownPosition;
    scale ??= _gestureConfig!.initialScale;
    //scale = scale.clamp(_gestureConfig.minScale, _gestureConfig.maxScale);
    handleScaleStart(ScaleStartDetails(focalPoint: doubleTapPosition!));
    handleScaleUpdate(ScaleUpdateDetails(
      focalPoint: doubleTapPosition,
      scale: scale / _startingScale!,
      focalPointDelta: Offset.zero,
    ));
    if (scale < _gestureConfig!.minScale || scale > _gestureConfig!.maxScale) {
      handleScaleEnd(ScaleEndDetails());
    }
  }

  @override
  void initState() {
    super.initState();
    _initGestureConfig();
  }

  @override
  void reset() {
    _gestureConfig = widget
            .extendedImageState.imageWidget.initGestureConfigHandler
            ?.call(widget.extendedImageState) ??
        GestureConfig();

    gestureDetails = GestureDetails(
      totalScale: _gestureConfig!.initialScale,
      offset: Offset.zero,
    )..initialAlignment = _gestureConfig!.initialAlignment;
  }

  @override
  void slide() {
    if (mounted) {
      setState(() {
        _gestureDetails!.slidePageOffset = extendedImageSlidePageState?.offset;
      });
    }
  }

  void _handleDoubleTap() {
    if (widget.extendedImageState.imageWidget.onDoubleTap != null) {
      widget.extendedImageState.imageWidget.onDoubleTap!(this);
      return;
    }

    if (!mounted) {
      return;
    }

    gestureDetails = GestureDetails(
      offset: Offset.zero,
      totalScale: _gestureConfig!.initialScale,
    );
  }

  void _handlePointerDown(PointerDownEvent pointerDownEvent) {
    _pointerDownPosition = pointerDownEvent.position;
    _gestureAnimation.stop();

    _pageViewState?.extendedImageGestureState = this;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && event.kind == PointerDeviceKind.mouse) {
      handleScaleStart(ScaleStartDetails(focalPoint: event.position));
      final double dy = event.scrollDelta.dy;
      final double dx = event.scrollDelta.dx;
      handleScaleUpdate(ScaleUpdateDetails(
          focalPoint: event.position,
          scale: 1.0 +
              _reverseIf((dy.abs() > dx.abs() ? dy : dx) *
                  _gestureConfig!.speed /
                  1000.0),
          focalPointDelta: Offset.zero));
      handleScaleEnd(ScaleEndDetails());
    }
  }

  @override
  void handleScaleEnd(ScaleEndDetails details) {
    if (extendedImageSlidePageState != null &&
        extendedImageSlidePageState!.isSliding) {
      extendedImageSlidePageState!.endSlide(details);
      return;
    }

    if (_pageViewState != null && _pageViewState!.isDraging) {
      _pageViewState!.onDragEnd(DragEndDetails(
        velocity: details.velocity,
        primaryVelocity:
            _pageViewState!.widget.scrollDirection == Axis.horizontal
                ? details.velocity.pixelsPerSecond.dx
                : details.velocity.pixelsPerSecond.dy,
      ));
      return;
    }

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_gestureDetails!.totalScale!.greaterThan(_gestureConfig!.maxScale)) {
      final double velocity =
          (_gestureDetails!.totalScale! - _gestureConfig!.maxScale) /
              _gestureConfig!.maxScale;

      _gestureAnimation.animationScale(
          _gestureDetails!.totalScale, _gestureConfig!.maxScale, velocity);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_gestureDetails!.totalScale!.lessThan(_gestureConfig!.minScale)) {
      final double velocity =
          (_gestureConfig!.minScale - _gestureDetails!.totalScale!) /
              _gestureConfig!.minScale;

      _gestureAnimation.animationScale(
          _gestureDetails!.totalScale, _gestureConfig!.minScale, velocity);
      return;
    }

    if (_gestureDetails!.actionType == ActionType.pan) {
      // get magnitude from gesture velocity
      final double magnitude = details.velocity.pixelsPerSecond.distance;

      // do a significant magnitude
      if (magnitude.greaterThanOrEqualTo(minMagnitude)) {
        final Offset direction = details.velocity.pixelsPerSecond /
            magnitude *
            _gestureConfig!.inertialSpeed;

        _gestureAnimation.animationOffset(
            _gestureDetails!.offset, _gestureDetails!.offset! + direction);
      }
    }
  }

  @override
  void handleScaleStart(ScaleStartDetails details) {
    _gestureAnimation.stop();
    _normalizedOffset = (details.focalPoint - _gestureDetails!.offset!) /
        _gestureDetails!.totalScale!;
    _startingScale = _gestureDetails!.totalScale;
    _startingOffset = details.focalPoint;
  }

  @override
  void handleScaleUpdate(ScaleUpdateDetails details) {
    // 取消原组件对totalScale的判断。这样scale大于1也能执行slidePage的slide方法
    if (extendedImageSlidePageState != null &&
        _gestureDetails!.userOffset &&
        _gestureDetails!.actionType == ActionType.pan) {
      final Offset totalDelta = details.focalPointDelta;
      bool updateGesture = false;
      if (!extendedImageSlidePageState!.isSliding) {
        if (totalDelta.dx != 0 &&
            totalDelta.dx.abs().greaterThan(totalDelta.dy.abs())) {
          if (_gestureDetails!.computeHorizontalBoundary) {
            if (totalDelta.dx > 0) {
              updateGesture = _gestureDetails!.boundary.left;
            } else {
              updateGesture = _gestureDetails!.boundary.right;
            }
          } else {
            updateGesture = true;
          }
        }
        if (totalDelta.dy != 0 &&
            totalDelta.dy.abs().greaterThan(totalDelta.dx.abs())) {
          if (_gestureDetails!.computeVerticalBoundary) {
            if (totalDelta.dy < 0) {
              updateGesture = _gestureDetails!.boundary.bottom;
            } else {
              updateGesture = _gestureDetails!.boundary.top;
            }
          } else {
            updateGesture = true;
          }
        }
      } else {
        updateGesture = true;
      }

      if (details.focalPointDelta.distance.greaterThan(minGesturePageDelta) &&
          updateGesture) {
        extendedImageSlidePageState!.slide(
          details.focalPointDelta,
          extendedImageGestureState: this,
        );
      }
    }

    if (extendedImageSlidePageState != null &&
        extendedImageSlidePageState!.isSliding) {
      return;
    }

    // totalScale > 1 and page view is starting to move
    if (_pageViewState != null) {
      final ExtendedImageGesturePageViewState pageViewState = _pageViewState!;

      final Axis axis = pageViewState.widget.scrollDirection;
      final bool movePage = _pageViewState!.isDraging ||
          (details.pointerCount == 1 &&
              details.scale == 1 &&
              _gestureDetails!.movePage(details.focalPointDelta, axis));

      if (movePage) {
        if (!pageViewState.isDraging) {
          pageViewState
              .onDragDown(DragDownDetails(globalPosition: details.focalPoint));
          pageViewState.onDragStart(
              DragStartDetails(globalPosition: details.focalPoint));
          //assert(!pageViewState.isDraging);
        }
        Offset delta = details.focalPointDelta;
        delta =
            axis == Axis.horizontal ? Offset(delta.dx, 0) : Offset(0, delta.dy);

        pageViewState.onDragUpdate(DragUpdateDetails(
          globalPosition: details.focalPoint,
          delta: delta,
          primaryDelta: axis == Axis.horizontal ? delta.dx : delta.dy,
        ));

        return;
      }
    }
    final double? scale = widget.canScaleImage(_gestureDetails)
        ? clampScale(
            _startingScale! * details.scale * _gestureConfig!.speed,
            _gestureConfig!.animationMinScale,
            _gestureConfig!.animationMaxScale)
        : _gestureDetails!.totalScale;

    //Round the scale to three points after comma to prevent shaking
    //scale = roundAfter(scale, 3);
    //no more zoom
    if (details.scale != 1.0 &&
        ((_gestureDetails!.totalScale!
                    .equalTo(_gestureConfig!.animationMinScale) &&
                scale!.lessThanOrEqualTo(_gestureDetails!.totalScale!)) ||
            (_gestureDetails!.totalScale!
                    .equalTo(_gestureConfig!.animationMaxScale) &&
                scale!.greaterThanOrEqualTo(_gestureDetails!.totalScale!)))) {
      return;
    }

    final Offset offset = (details.scale == 1.0
            ? details.focalPoint * _gestureConfig!.speed
            : _startingOffset) -
        _normalizedOffset * scale!;

    if (mounted &&
        (offset != _gestureDetails!.offset ||
            scale != _gestureDetails!.totalScale)) {
      gestureDetails = GestureDetails(
          offset: offset,
          totalScale: scale,
          gestureDetails: _gestureDetails,
          actionType: details.scale != 1.0 ? ActionType.zoom : ActionType.pan);
    }
  }

  void _initGestureConfig() {
    final double? initialScale = _gestureConfig?.initialScale;
    final InitialAlignment? initialAlignment = _gestureConfig?.initialAlignment;
    _gestureConfig = widget
            .extendedImageState.imageWidget.initGestureConfigHandler
            ?.call(widget.extendedImageState) ??
        GestureConfig();

    if (_gestureDetails == null ||
        initialScale != _gestureConfig!.initialScale ||
        initialAlignment != _gestureConfig!.initialAlignment) {
      _gestureDetails = GestureDetails(
        totalScale: _gestureConfig!.initialScale,
        offset: Offset.zero,
      )..initialAlignment = _gestureConfig!.initialAlignment;
    }

    if (_gestureConfig!.cacheGesture) {
      final GestureDetails? cache =
          _gestureDetailsCache[widget.extendedImageState.imageStreamKey];
      if (cache != null) {
        _gestureDetails = cache;
      }
    }
    _gestureDetails ??= GestureDetails(
      totalScale: _gestureConfig!.initialScale,
      offset: Offset.zero,
    );

    _gestureAnimation = GestureAnimation(this, offsetCallBack: (Offset value) {
      gestureDetails = GestureDetails(
          offset: value,
          totalScale: _gestureDetails!.totalScale,
          gestureDetails: _gestureDetails);
    }, scaleCallBack: (double scale) {
      gestureDetails = GestureDetails(
          offset: _gestureDetails!.offset,
          totalScale: scale,
          gestureDetails: _gestureDetails,
          actionType: ActionType.zoom,
          userOffset: false);
    });
  }

  double _reverseIf(double scaleDetal) {
    if (_gestureConfig?.reverseMousePointerScrollDirection ?? false) {
      return -scaleDetal;
    } else {
      return scaleDetal;
    }
  }
}
