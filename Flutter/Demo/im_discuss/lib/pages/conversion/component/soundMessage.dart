import 'dart:io';
import 'dart:math';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/utils/permissions.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class SoundMessage extends StatefulWidget {
  final V2TimMessage message;
  final String selectedMsgId;
  final void Function(String msgId) setSelectedMsgId;

  const SoundMessage(
      {Key? key,
      required this.message,
      required this.selectedMsgId,
      required this.setSelectedMsgId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SoundMessageState();
}

class SoundMessageState extends State<SoundMessage> {
  bool isPlay = false;
  //实例化对象
  FlutterPluginRecord recordPlugin = FlutterPluginRecord();
  bool isRecordInited = false;
  final int charLen = 8;
  double soundLen = 32;
  @override
  void initState() {
    super.initState();
    if (widget.message.soundElem!.duration != null) {
      final realSoundLen = widget.message.soundElem!.duration!;
      int sdLen = 32;
      if (realSoundLen > 10) {
        sdLen = 12 * charLen + ((realSoundLen - 10) * charLen / 0.5).floor();
      } else if (realSoundLen > 2) {
        sdLen = 2 * charLen + realSoundLen * charLen;
      }
      sdLen = min(sdLen, 20 * charLen);
      setState(() {
        soundLen = sdLen.toDouble();
      });
    }
    initRecord();
  }

  @override
  void didUpdateWidget(SoundMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      isPlay = widget.selectedMsgId == widget.message.msgID;
    });
  }

  initRecord() async {
    recordPlugin.responseFromInit.listen((data) {
      if (data) {
        setState(() {
          isRecordInited = true;
        });
      } else {}
    });
    recordPlugin.responsePlayStateController.listen((data) {
      if (data.playState == 'complete') {
        widget.setSelectedMsgId('');
      }
    });
    if (Platform.isIOS || await Permission.microphone.isGranted) {
      recordPlugin.init();
    }
  }

  @override
  void dispose() {
    recordPlugin.dispose();
    super.dispose();
  }

  void play() async {
    // 安卓首次init会触发microphone权限
    if (!Platform.isIOS && !isRecordInited) {
      if (await Permissions.checkPermission(
          context, Permission.microphone.value)) {
        recordPlugin.init();
      }
      return;
    }
    String? url = widget.message.soundElem!.url;
    if (url != null) {
      if (isRecordInited) {
        if (!isPlay) {
          widget.setSelectedMsgId(widget.message.msgID!);
          recordPlugin.playByPath(url, 'url');
        } else {
          widget.setSelectedMsgId("");
          recordPlugin.stopPlay();
        }
      } else {
        Utils.toast("播放功能未初始化");
      }
    }
  }

  isC2CMessage() {
    return widget.message.userID != null;
  }

  isSelf() {
    return widget.message.isSelf;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelf() ? hexToColor("DCEAFD") : hexToColor("ECECEC"),
        borderRadius: BorderRadius.only(
          topLeft: isSelf() ? const Radius.circular(10) : Radius.zero,
          bottomLeft: const Radius.circular(10),
          topRight: isSelf() ? Radius.zero : const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
      ),
      child: InkWell(
        onTap: play,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isSelf()
              ? [
                  Container(width: soundLen),
                  Text("''${widget.message.soundElem!.duration} "),
                  isPlay
                      ? Image.asset(
                          'images/play_voice_send.gif',
                          width: 16,
                          height: 16,
                        )
                      : Image.asset(
                          'images/voice_send.png',
                          width: 16,
                          height: 16,
                        ),
                ]
              : [
                  isPlay
                      ? Image.asset(
                          'images/play_voice_receive.gif',
                          width: 16,
                          height: 16,
                        )
                      : Image.asset(
                          'images/voice_receive.png',
                          width: 16,
                          height: 16,
                        ),
                  Text(" ${widget.message.soundElem!.duration}''"),
                  Container(width: soundLen),
                ],
        ),
      ),
    );
  }
}
