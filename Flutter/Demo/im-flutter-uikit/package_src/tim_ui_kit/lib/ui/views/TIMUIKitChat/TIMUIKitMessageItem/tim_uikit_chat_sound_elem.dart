import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/const/play_state.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_sound_elem.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/sound_record.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';

class TIMUIKitSoundElem extends StatefulWidget {
  final V2TimSoundElem soundElem;
  final String msgID;
  final bool isFromSelf;

  const TIMUIKitSoundElem(
      {Key? key,
      required this.soundElem,
      required this.msgID,
      required this.isFromSelf})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitSoundElemState();
}

class _TIMUIKitSoundElemState extends State<TIMUIKitSoundElem> {
  final int charLen = 8;
  bool isPlaying = false;
  StreamSubscription<Object>? subscription;
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  _playSound() {
    if (isPlaying) {
      SoundPlayer.stop();
      model.currentSelectedMsgId = "";
    } else {
      SoundPlayer.play(url: widget.soundElem.url!);
      model.currentSelectedMsgId = widget.msgID;
      // SoundPlayer.setSoundInterruptListener(() {
      //   // setState(() {
      //   isPlaying = false;
      //   // });
      // });
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      isPlaying = model.currentSelectedMsgId == widget.msgID;
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = SoundPlayer.playStateListener(listener: (PlayState data) {
      if (data.playState == 'complete') {
        model.currentSelectedMsgId = "";
        // SoundPlayer.removeSoundInterruptListener();
      }
    });
    SoundPlayer.initSoundPlayer();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  double _getSoundLen() {
    double soundLen = 32;
    if (widget.soundElem.duration != null) {
      final realSoundLen = widget.soundElem.duration!;
      int sdLen = 32;
      if (realSoundLen > 10) {
        sdLen = 12 * charLen + ((realSoundLen - 10) * charLen / 0.5).floor();
      } else if (realSoundLen > 2) {
        sdLen = 2 * charLen + realSoundLen * charLen;
      }
      sdLen = min(sdLen, 20 * charLen);
      soundLen = sdLen.toDouble();
    }

    return soundLen;
  }

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
    return InkWell(
      onTap: _playSound,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        constraints: const BoxConstraints(maxWidth: 240),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.isFromSelf
              ? [
                  Container(width: _getSoundLen()),
                  Text("''${widget.soundElem.duration} "),
                  isPlaying
                      ? Image.asset(
                          'images/play_voice_send.gif',
                          package: 'tim_ui_kit',
                          width: 16,
                          height: 16,
                        )
                      : Image.asset(
                          'images/voice_send.png',
                          package: 'tim_ui_kit',
                          width: 16,
                          height: 16,
                        ),
                ]
              : [
                  isPlaying
                      ? Image.asset(
                          'images/play_voice_receive.gif',
                          package: 'tim_ui_kit',
                          width: 16,
                          height: 16,
                        )
                      : Image.asset(
                          'images/voice_receive.png',
                          width: 16,
                          height: 16,
                          package: 'tim_ui_kit',
                        ),
                  Text(" ${widget.soundElem.duration}''"),
                  Container(width: _getSoundLen()),
                ],
        ),
      ),
    );
  }
}
