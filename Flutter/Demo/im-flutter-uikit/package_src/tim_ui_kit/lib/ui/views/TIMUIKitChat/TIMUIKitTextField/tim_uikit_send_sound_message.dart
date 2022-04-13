import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/sound_record.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';

import '../../../../i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/utils/shared_theme.dart';

class SendSoundMessage extends StatefulWidget {
  /// 会话ID
  final String conversationID;

  ///控制滚动条到底
  final VoidCallback onDownBottom;

  /// 会话类型
  final int conversationType;

  const SendSoundMessage(
      {required this.conversationID,
      required this.conversationType,
      Key? key,
      required this.onDownBottom})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendSoundMessageState();
}

class _SendSoundMessageState extends State<SendSoundMessage> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  String soundTipsText = "";
  bool isRecording = false;
  bool isInit = false;
  bool isCancelSend = false;
  DateTime startTime = DateTime.now();
  List<StreamSubscription<Object>> subscriptions = [];

  OverlayEntry? overlayEntry;
  String voiceIcon = "images/voice_volume_1.png";

  buildOverLayView(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(builder: (content) {
        final I18nUtils ttBuild = I18nUtils(context);
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
                  decoration: const BoxDecoration(
                    color: Color(0xff77797A),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Image.asset(
                          voiceIcon,
                          width: 100,
                          height: 100,
                          package: 'flutter_plugin_record',
                        ),
                      ),
                      Text(
                        soundTipsText,
                        style: const TextStyle(
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 14,
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

  onLongPressStart(_) {
    if (isInit) {
      startTime = DateTime.now();
      SoundPlayer.startRecord();
      buildOverLayView(context);
    }
  }

  onLongPressUpdate(e) {
    final I18nUtils ttBuild = I18nUtils(context);
    double height = MediaQuery.of(context).size.height * 0.5 - 240;
    double dy = e.localPosition.dy;
    if (dy.abs() > height) {
      if (mounted && soundTipsText != ttBuild.imt("松开取消")) {
        setState(() {
          soundTipsText = ttBuild.imt("松开取消");
        });
      }
    } else {
      if (mounted && soundTipsText == ttBuild.imt("松开取消")) {
        setState(() {
          soundTipsText = ttBuild.imt("手指上滑，取消发送");
        });
      }
    }
  }

  onLongPressEnd(e) {
    double dy = e.localPosition.dy;
    final I18nUtils ttBuild = I18nUtils(context);
    // 此高度为 160为录音取消组件距离顶部的预留距离
    double height = MediaQuery.of(context).size.height * 0.5 - 240;
    if (dy.abs() > height) {
      isCancelSend = true;
    } else {
      isCancelSend = false;
    }
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    // Did not receive onStop from FlutterPluginRecord if the duration is too short.
    if (DateTime.now().difference(startTime).inSeconds < 1) {
      isCancelSend = true;
      Toast.showToast(ToastType.info, ttBuild.imt("说话时间太短!"), context);
    }
    stop();
  }

  onLonePressCancel() {
    if (isRecording) {
      isCancelSend = true;
      if (overlayEntry != null) {
        overlayEntry!.remove();
        overlayEntry = null;
      }
      stop();
    }
  }

  void stop() {
    final I18nUtils ttBuild = I18nUtils(context);
    setState(() {
      isRecording = false;
    });
    SoundPlayer.stopRecord();
    setState(() {
      soundTipsText = ttBuild.imt("手指上滑，取消发送");
    });
  }

  sendSound({required String path, required int duration}) {
    final I18nUtils ttBuild = I18nUtils(context);
    final convID = widget.conversationID;
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;

    if (duration > 0) {
      if (!isCancelSend) {
        MessageUtils.handleMessageError(
            model.sendSoundMessage(
                soundPath: path,
                duration: duration,
                convID: convID,
                convType: convType),
            context);
        widget.onDownBottom();
      } else {
        isCancelSend = false;
      }
    } else {
      Toast.showToast(ToastType.info, ttBuild.imt("说话时间太短!"), context);
    }
  }

  @override
  dispose() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  initRecordSound() {
    final responseSubscription = SoundPlayer.responseListener((recordResponse) {
      final status = recordResponse.msg;
      if (status == "onStop") {
        if (!isCancelSend) {
          final soundPath = recordResponse.path;
          final recordDuration = recordResponse.audioTimeLength;
          sendSound(path: soundPath!, duration: recordDuration!.ceil());
        }
      } else if (status == "onStart") {
        print("start record");
        setState(() {
          isRecording = true;
        });
      } else {
        print(status);
      }
    });
    final amplitutdeResponseSubscription =
        SoundPlayer.responseFromAmplitudeListener((recordResponse) {
      final voiceData = double.parse(recordResponse.msg!);
      setState(() {
        if (voiceData > 0 && voiceData < 0.1) {
          voiceIcon = "images/voice_volume_2.png";
        } else if (voiceData > 0.2 && voiceData < 0.3) {
          voiceIcon = "images/voice_volume_3.png";
        } else if (voiceData > 0.3 && voiceData < 0.4) {
          voiceIcon = "images/voice_volume_4.png";
        } else if (voiceData > 0.4 && voiceData < 0.5) {
          voiceIcon = "images/voice_volume_5.png";
        } else if (voiceData > 0.5 && voiceData < 0.6) {
          voiceIcon = "images/voice_volume_6.png";
        } else if (voiceData > 0.6 && voiceData < 0.7) {
          voiceIcon = "images/voice_volume_7.png";
        } else if (voiceData > 0.7 && voiceData < 1) {
          voiceIcon = "images/voice_volume_7.png";
        } else {
          voiceIcon = "images/voice_volume_1.png";
        }
        if (overlayEntry != null) {
          overlayEntry!.markNeedsBuild();
        }
      });
    });
    subscriptions = [responseSubscription, amplitutdeResponseSubscription];
    SoundPlayer.initSoundPlayer();
    isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;
    final I18nUtils ttBuild = I18nUtils(context);
    return GestureDetector(
      onTapDown: (detail) async {
        if (!isInit) {
          bool hasMicrophonePermission = await Permissions.checkPermission(
              context, Permission.microphone.value);
          bool hasStoragePermission = Platform.isIOS ||
              await Permissions.checkPermission(
                  context, Permission.storage.value);
          if (!hasMicrophonePermission || !hasStoragePermission) {
            return;
          }
          initRecordSound();
        }
      },
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressUpdate,
      onLongPressEnd: onLongPressEnd,
      onLongPressCancel: onLonePressCancel,
      child: Container(
        height: 35,
        color: isRecording ? theme?.weakBackgroundColor : Colors.white,
        alignment: Alignment.center,
        child: Text(
          ttBuild.imt("按住说话"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme?.darkTextColor,
          ),
        ),
      ),
    );
  }
}
