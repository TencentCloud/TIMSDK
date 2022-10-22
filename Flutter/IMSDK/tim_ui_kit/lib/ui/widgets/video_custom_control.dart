// ignore_for_file: implementation_imports, unused_element

import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:chewie/src/helpers/utils.dart';
import 'package:chewie/src/animated_play_pause.dart';
import 'package:chewie/src/material/material_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:video_player/video_player.dart';
import 'center_play_button.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class VideoCustomControls extends StatefulWidget {
  const VideoCustomControls({required this.downloadFn, Key? key})
      : super(key: key);
  final void Function() downloadFn;

  @override
  State<StatefulWidget> createState() {
    return _VideoCustomControlsState();
  }
}

class _VideoCustomControlsState extends TIMUIKitState<VideoCustomControls>
    with SingleTickerProviderStateMixin {
  late VideoPlayerValue _latestValue;
  bool _hideStuff = true;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  late VideoPlayerController controller;
  ChewieController? _chewieController;
  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    if (_latestValue.hasError) {
      return Container(
        color: Colors.transparent,
        child: chewieController.errorBuilder?.call(
              context,
              chewieController.videoPlayerController.value.errorDescription!,
            ) ??
            const Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            ),
      );
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (_latestValue.isBuffering)
                const Center(
                    child: CircularProgressIndicator(color: Colors.white))
              else
                _buildHitArea(),
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  _buildVideoControlBar(context),
                  _buildBottomBar()
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Widget _buildBottomBar() {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Image.asset(
                'images/close.png',
                package: 'tim_ui_kit',
              ),
              iconSize: 30,
              onPressed: () {
                if (_latestValue.isPlaying) {
                  _playPause();
                }
                Navigator.of(context).pop();
              },
            ),
            Expanded(child: Container()),
            IconButton(
              icon: Image.asset(
                'images/download.png',
                package: 'tim_ui_kit',
              ),
              iconSize: 30,
              onPressed: widget.downloadFn,
            )
          ],
        ),
      ),
    );
  }

  AnimatedOpacity _buildVideoControlBar(
    BuildContext context,
  ) {
    const iconColor = Colors.white;

    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        height: barHeight,
        child: Row(
          children: <Widget>[
            _buildPlayPause(controller, iconColor),
            if (chewieController.isLive)
              const Expanded(child: Text('LIVE'))
            else
              _buildPositionStart(iconColor),
            if (chewieController.isLive)
              const SizedBox()
            else
              _buildProgressBar(),
            if (!chewieController.isLive) _buildPositionEnd(iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    // final bool isFinished = _latestValue.position >= _latestValue.duration;

    return GestureDetector(
        onTap: () {
          if (_latestValue.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else {
              _cancelAndRestartTimer();
            }
          } else {
            _playPause();

            setState(() {
              _hideStuff = true;
            });
          }
        },
        child: CenterPlayButton(
          isPlaying: controller.value.isPlaying,
          show: !_latestValue.isPlaying && !_dragging,
          onPressed: _playPause,
        ));
  }

  GestureDetector _buildPlayPause(
      VideoPlayerController controller, Color color) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 8.0, right: 4.0),
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: AnimatedPlayPause(
          playing: controller.value.isPlaying,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPositionStart(Color? iconColor) {
    final position = _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(fontSize: 14.0, color: iconColor),
      ),
    );
  }

  Widget _buildPositionEnd(Color? iconColor) {
    final duration = _latestValue.duration;

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Text(
        formatDuration(duration),
        style: TextStyle(fontSize: 14.0, color: iconColor),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<void> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer =
          Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(const Duration());
          }
          Timer(const Duration(milliseconds: 100), () => controller.play());
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    if (!mounted) return;
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: MaterialVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.materialProgressColors ??
              ChewieProgressColors(
                  playedColor: Colors.white,
                  handleColor: Colors.white,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white24),
        ),
      ),
    );
  }
}

class _PlaybackSpeedDialog extends TIMUIKitStatelessWidget {
  _PlaybackSpeedDialog({
    Key? key,
    required List<double> speeds,
    required double selected,
  })  : _speeds = speeds,
        _selected = selected,
        super(key: key);

  final List<double> _speeds;
  final double _selected;

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final Color selectedColor =
        theme.primaryColor ?? Theme.of(context).primaryColor;

    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final _speed = _speeds[index];
        return ListTile(
          dense: true,
          title: Row(
            children: [
              if (_speed == _selected)
                Icon(
                  Icons.check,
                  size: 20.0,
                  color: selectedColor,
                )
              else
                Container(width: 20.0),
              const SizedBox(width: 16.0),
              Text(_speed.toString()),
            ],
          ),
          selected: _speed == _selected,
          onTap: () {
            Navigator.of(context).pop(_speed);
          },
        );
      },
      itemCount: _speeds.length,
    );
  }
}
