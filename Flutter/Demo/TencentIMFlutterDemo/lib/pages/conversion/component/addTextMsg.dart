import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/provider/currentMessageList.dart';
import 'package:tencent_im_sdk_plugin_example/provider/keybooadshow.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_sound/flutter_sound.dart'; // 为了解决安卓问题才引入的新插件

class TextMsg extends StatefulWidget {
  final String toUser;
  final int type;
  final bool recordBackStatus;
  final setRecordBackStatus;

  TextMsg(
      this.toUser, this.type, this.recordBackStatus, this.setRecordBackStatus);

  @override
  State<StatefulWidget> createState() => TextMsgState();
}

class TextMsgState extends State<TextMsg> {
  bool isRecording = false;
  bool isSend = true;
  int _count = 0;
  TextEditingController inputController = new TextEditingController();
  // FlutterPluginRecord recordPlugin = new FlutterPluginRecord();
  final _audioRecorder = Record();
  String soundPath = '';
  late Timer? _timer;
  // FlutterSoundRecorder flutterSoundRecord =
  //     new FlutterSoundRecorder(); // 为了解决安卓问题才引入的新插件
  OverlayEntry? overlayEntry;
  String voiceIco = "images/voice_volume_1.png";

  late DateTime startTime;
  late DateTime endTime;

  @override
  void dispose() {
    super.dispose();
    _audioRecorder.stop();
    // canceLoopAnimeTimer();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    print("widget.toUser${widget.toUser}");
    _audioRecorder.hasPermission().then((value) {
      print("hasPermission $value");
    });

    // recordPlugin.responseFromInit.listen((data) {
    //   if (data) {
    //   } else {
    //     Utils.toast("初始化失败");
    //   }
    // });
    // recordPlugin.response.listen((data) {
    //   print("data.path:$data.path");
    //   if (data.msg == "onStop") {
    //     ///结束录制时会返回录制文件的地址方便上传服务器
    //     if (isSend) {
    //       TencentImSDKPlugin.v2TIMManager
    //           .getMessageManager()
    //           .sendSoundMessage(
    //             soundPath: data.path!,
    //             receiver: (widget.type == 1 ? widget.toUser : ""),
    //             groupID: (widget.type == 2 ? widget.toUser : ""),
    //             duration: data.audioTimeLength!.toInt(),
    //           )
    //           .then((sendRes) {
    //         // 发送成功
    //         if (sendRes.code == 0) {
    //           String key = (widget.type == 1
    //               ? "c2c_${widget.toUser}"
    //               : "group_${widget.toUser}");
    //           List<V2TimMessage> list = new List.empty(growable: true);
    //           list.add(sendRes.data!);
    //           Provider.of<CurrentMessageListModel>(context, listen: false)
    //               .addMessage(key, list);
    //           print('发送成功');
    //         }
    //       });
    //     }
    //   } else if (data.msg == "onStart") {}
    // });
    // recordPlugin.responseFromAmplitude.listen((data) {
    //   var voiceData = double.parse(data.msg!);
    // setState(() {
    //   if (voiceData > 0 && voiceData < 0.1) {
    //     voiceIco = "images/voice_volume_2.png";
    //   } else if (voiceData > 0.2 && voiceData < 0.3) {
    //     voiceIco = "images/voice_volume_3.png";
    //   } else if (voiceData > 0.3 && voiceData < 0.4) {
    //     voiceIco = "images/voice_volume_4.png";
    //   } else if (voiceData > 0.4 && voiceData < 0.5) {
    //     voiceIco = "images/voice_volume_5.png";
    //   } else if (voiceData > 0.5 && voiceData < 0.6) {
    //     voiceIco = "images/voice_volume_6.png";
    //   } else if (voiceData > 0.6 && voiceData < 0.7) {
    //     voiceIco = "images/voice_volume_7.png";
    //   } else if (voiceData > 0.7 && voiceData < 1) {
    //     voiceIco = "images/voice_volume_7.png";
    //   } else {
    //     voiceIco = "images/voice_volume_1.png";
    //   }
    //   if (overlayEntry != null) {
    //     overlayEntry!.markNeedsBuild();
    //   }
    // });

    //   print("振幅大小   " + voiceData.toString() + "  " + voiceIco);
    // });
    // recordPlugin.initRecordMp3();
  }

// 动画循环（Demo使用的api因为兼容性问题无法监听音量因此直接使用循环动画）
  loopAnimeTimer() {
    List<String> list = [
      "images/voice_volume_1.png",
      "images/voice_volume_2.png",
      "images/voice_volume_3.png",
      "images/voice_volume_4.png",
      "images/voice_volume_5.png",
      "images/voice_volume_6.png",
      "images/voice_volume_7.png"
    ];
    // 定义一个函数，将定时器包裹起来
    _timer = Timer.periodic(Duration(milliseconds: 1200), (t) {
      if (_count > 6) _count = 0;

      setState(() {
        voiceIco = list[_count];
      });
      _count++;
      if (overlayEntry != null) {
        overlayEntry!.markNeedsBuild();
      }
    });
  }

  canceLoopAnimeTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  buildOverLayView(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = new OverlayEntry(builder: (content) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.5 - 80,
          left: MediaQuery.of(context).size.width * 0.5 - 80,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xff77797A),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: new Image.asset(
                          voiceIco,
                          width: 100,
                          height: 100,
                          package: 'flutter_plugin_record',
                        ),
                      ),
                      Container(
//                      padding: EdgeInsets.only(right: 20, left: 20, top: 0),
                        child: Text(
                          "手指上滑,取消发送",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
      Overlay.of(context)!.insert(overlayEntry!);
    }
  }

  onSubmitted(String? s, context) async {
    if (s == '' || s == null) {
      return;
    }
    V2TimValueCallback<V2TimMessage> sendRes;
    if (widget.type == 1) {
      sendRes = await TencentImSDKPlugin.v2TIMManager
          .sendC2CTextMessage(text: s, userID: widget.toUser);
      print("发送信息简介$sendRes");
      inspect(widget);
    } else {
      sendRes = await TencentImSDKPlugin.v2TIMManager
          .sendGroupTextMessage(text: s, groupID: widget.toUser, priority: 1);
    }

    if (sendRes.code == 0) {
      print('发送成功');
      String key = (widget.type == 1
          ? "c2c_${widget.toUser}"
          : "group_${widget.toUser}");
      List<V2TimMessage> list = List.empty(growable: true);
      list.add(sendRes.data!);
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, list);
      inputController.clear();
    } else {
      print(sendRes.desc);
      Utils.toast("发送失败 ${sendRes.code} ${sendRes.desc}");
    }
  }

  // 1 可以跳转， 0 禁止
  setGoBackForbid(status) {
    widget.setRecordBackStatus(status);
  }

  // 发送音频
  sendRecord(recordPath) async {
    var d = await flutterSoundHelper.duration(recordPath);
    double _duration = d != null ? d.inMilliseconds / 1000.0 : 0.00;
    if (isSend) {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .sendSoundMessage(
            soundPath: recordPath,
            receiver: (widget.type == 1 ? widget.toUser : ""),
            groupID: (widget.type == 2 ? widget.toUser : ""),
            duration: _duration.ceil(),
          )
          .then((sendRes) {
        // 发送成功
        if (sendRes.code == 0) {
          String key = (widget.type == 1
              ? "c2c_${widget.toUser}"
              : "group_${widget.toUser}");
          List<V2TimMessage> list = new List.empty(growable: true);
          list.add(sendRes.data!);
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(key, list);
          print('发送成功');
        }
      });
    }
  }

  // 开始录音
  start() async {
    String tempPath = (await getTemporaryDirectory()).path;
    int random = new Random().nextInt(1000);
    String path = "$tempPath/sendSoundMessage_$random.aac";
    File soundFile = new File(path);
    soundFile.createSync();
    setGoBackForbid(false);
    print("path: $path");
    try {
      await _audioRecorder.start(path: path);
    } catch (err) {
      print(err);
    }
    setState(() {
      isRecording = true;
      soundPath = path;
      startTime = DateTime.now();
    });
  }

  // 结束录音
  stop() async {
    final lastPath = await _audioRecorder.stop();

    setState(() {
      isRecording = false;
      endTime = DateTime.now();
    });
    canceLoopAnimeTimer();
    setGoBackForbid(true);
    //  print("让我看看finalPath,$lastPath");
    return soundPath;
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboradshow = Provider.of<KeyBoradModel>(context).show;
    return Expanded(
      child: isKeyboradshow
          ? PhysicalModel(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: inputController,
                  onSubmitted: (s) {
                    onSubmitted(s, context);
                  },
                  autocorrect: false,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  cursorColor: CommonColors.getThemeColor(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    isDense: true,
                    contentPadding: EdgeInsets.only(
                      top: 9,
                      bottom: 0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  minLines: 1,
                ),
              ),
            )
          : GestureDetector(
              onLongPressStart: (e) async {
                setState(() {
                  isRecording = true;
                  isSend = true;
                });
                buildOverLayView(context); //显示图标
                loopAnimeTimer();
                //await recordPlugin.start();
                await start();
                //file是文件名，比如 file = Platform.isIOS ? 'ios.m4a' : 'android.mp4'
                print("应该开啊了");
                // await flutterSoundRecord.startRecorder(toFile: "fool");
              },
              onLongPressEnd: (e) async {
                bool isSendLocal = true;
                // Utils.toast("${e.localPosition.dx} ${e.localPosition.dy}");
                if (e.localPosition.dx < 0 ||
                    e.localPosition.dy < 0 ||
                    e.localPosition.dy > 40) {
                  // 取消了发送
                  isSendLocal = false;
                  print("取消了");
                }
                try {
                  if (overlayEntry != null) {
                    overlayEntry!.remove();
                    overlayEntry = null;
                  }
                } catch (err) {}
                setState(() {
                  isRecording = false;
                  isSend = isSendLocal;
                });
                // await recordPlugin.stop();
                await stop();
                sendRecord(soundPath);
                print("结束");
                // String? anURL = await flutterSoundRecord.stopRecorder();
                // print("anURL:$anURL");
              },
              child: Container(
                height: 34,
                color: isRecording
                    ? CommonColors.getGapColor()
                    : CommonColors.getWitheColor(),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '按住说话',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
