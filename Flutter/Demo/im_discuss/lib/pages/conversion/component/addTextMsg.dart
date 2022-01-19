import 'dart:developer';
import 'dart:io';

import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/utils/permissions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/provider/keybooadshow.dart';
import 'package:discuss/utils/toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';

class TextMsg extends StatefulWidget {
  final String toUser;
  final int type;
  final bool recordBackStatus;
  final String? lastDraftText;

  const TextMsg(this.toUser, this.type, this.recordBackStatus,
      {this.lastDraftText, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TextMsgState();
}

class TextMsgState extends State<TextMsg> {
  bool isRecording = false;
  bool isSend = true;
  TextEditingController inputController = TextEditingController();
  TextEditingController replyController = TextEditingController();
  FlutterPluginRecord recordPlugin = FlutterPluginRecord();
  late FocusNode inputFieldNode; //解决失去焦点收起键盘的问题
  String soundPath = '';
  OverlayEntry? overlayEntry;
  String voiceIco = "images/voice_volume_1.png";
  late DateTime startTime;
  late DateTime endTime;
  String? filePath = '';
  bool isRecordInited = false;
  bool recordCanceled = false; // 辅助判断是否取消录音
  String soundTipsText = "手指上滑，取消发送";

  @override
  void dispose() {
    recordPlugin.dispose();
    inputController.dispose();
    replyController.dispose();
    inputFieldNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    inputFieldNode = FocusNode();
    inputFieldNode.addListener(() {
      if (inputFieldNode.hasFocus) {
        Provider.of<KeyBoradModel>(context, listen: false)
            .setBottomConToKeyBoard();
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Provider.of<KeyBoradModel>(context, listen: false)
          .setFocusNode(inputFieldNode);
      Provider.of<KeyBoradModel>(context, listen: false)
          .setInputController(inputController);
      Provider.of<KeyBoradModel>(context, listen: false)
          .setSubmitTextMessage(onSubmitted);
      // 初始化草稿
      inputController.text = widget.lastDraftText ?? "";
    });
  }

  initRecord() async {
    Utils.log("初始化");
    bool hasMicrophonePermission =
        await Permissions.checkPermission(context, Permission.microphone.value);
    bool hasStoragePermission = Platform.isIOS ||
        await Permissions.checkPermission(context, Permission.storage.value);
    if (!hasMicrophonePermission || !hasStoragePermission) {
      return;
    }
    recordPlugin.responseFromInit.listen((data) {
      if (data) {
        Utils.log("初始化成功");
        setState(() {
          isRecordInited = true;
        });
      } else {
        Utils.log("初始化失败");
      }
    });

    /// 开始录制或结束录制的监听
    recordPlugin.response.listen((data) {
      if (data.msg == "onStop") {
        ///结束录制时会返回录制文件的地址方便上传服务器
        Utils.log("onStop  文件路径 ${data.path}");
        filePath = data.path;
        Utils.log("onStop  时长 " + data.audioTimeLength.toString());

        !recordCanceled
            ? sendRecord(data.path, data.audioTimeLength)
            : recordCanceled = false;

        setState(() {
          isRecording = false;
        });
      } else if (data.msg == "onStart") {
        setState(() {
          isRecording = true;
        });
      } else {
        Utils.log("-- ${data.msg}");
      }
    });

    ///录制过程监听录制的声音的大小 方便做语音动画显示图片的样式
    recordPlugin.responseFromAmplitude.listen((data) {
      var voiceData = double.parse(data.msg!);
      setState(() {
        if (voiceData > 0 && voiceData < 0.1) {
          voiceIco = "images/voice_volume_2.png";
        } else if (voiceData > 0.2 && voiceData < 0.3) {
          voiceIco = "images/voice_volume_3.png";
        } else if (voiceData > 0.3 && voiceData < 0.4) {
          voiceIco = "images/voice_volume_4.png";
        } else if (voiceData > 0.4 && voiceData < 0.5) {
          voiceIco = "images/voice_volume_5.png";
        } else if (voiceData > 0.5 && voiceData < 0.6) {
          voiceIco = "images/voice_volume_6.png";
        } else if (voiceData > 0.6 && voiceData < 0.7) {
          voiceIco = "images/voice_volume_7.png";
        } else if (voiceData > 0.7 && voiceData < 1) {
          voiceIco = "images/voice_volume_7.png";
        } else {
          voiceIco = "images/voice_volume_1.png";
        }
        if (overlayEntry != null) {
          overlayEntry!.markNeedsBuild();
        }
      });
    });

    recordPlugin.init();
  }

  void start() async {
    if (isRecordInited) {
      recordPlugin.start();
      setState(() {
        isRecording = true;
      });
    } else {
      Utils.toast("录音功能未初始化");
    }
  }

  void stop() {
    recordPlugin.stop();
    setState(() {
      isRecording = false;
      soundTipsText = "手指上滑，取消发送";
    });
  }

  buildOverLayView(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(builder: (content) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.5,
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
                          voiceIco,
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

  void focusComeBack() {
    inputFieldNode.requestFocus();
  }

  void addTextMessageForHistoryMsgList(V2TimMessage mesg, String key) {
    List<V2TimMessage> list = List.empty(growable: true);
    list.add(mesg);
    Provider.of<HistoryMessageListProvider>(context, listen: false)
        .addMessage(key, list);
  }

  void updateTextMessageForHistoryMsgList(
      V2TimMessage msg, String msgId, String mcokId, String key) {
    Provider.of<HistoryMessageListProvider>(context, listen: false)
        .updateCreateMessage(key, msgId, mcokId, msg);
  }

  // 兼容C2C
  String getReciverId() {
    bool isUser = widget.type == 1;
    return !isUser ? "" : widget.toUser;
  }

// 兼容Group
  String getGroupId() {
    bool isUser = widget.type == 1;
    return isUser ? "" : widget.toUser;
  }

  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage({
    required String text,
    required String key, // 加工过的userId
  }) async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(text: text);
    String id = createResult.toJson()["data"]["id"];
    String mockKey = id;
    V2TimMessage createMessage = createResult.data!.messageInfo!;

    // msgID也要填充，部分组件需要
    createMessage.id = mockKey;
    createMessage.msgID = mockKey;
    createMessage.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;

    createMessage.userID = getReciverId();
    createMessage.groupID = getGroupId();

    addTextMessageForHistoryMsgList(createMessage, key);

    V2TimValueCallback<V2TimMessage> sendRes =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id,
              receiver: getReciverId(),
              groupID: getGroupId(),
            );
    V2TimMessage resultMessage = sendRes.data!;
    String msgId = resultMessage.msgID!;
    resultMessage.id = mockKey;
    updateTextMessageForHistoryMsgList(resultMessage, msgId, mockKey, key);

    return sendRes;
  }

  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage({
    required String text,
    required V2TimMessage replyMessage,
    required String key, // 加工过的userId
  }) async {
    // 回复消息只有文字
    V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(text: text);
    String id = createResult.toJson()["data"]["id"];
    V2TimMessage createMessage = createResult.data!.messageInfo!;
    String mockKey = id;

    // msgID也要填充，部分组件需要
    createMessage.id = mockKey;
    createMessage.msgID = mockKey;
    createMessage.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;

    createMessage.userID = getReciverId();
    createMessage.groupID = getGroupId();

    addTextMessageForHistoryMsgList(createMessage, key);
    V2TimValueCallback<V2TimMessage> sendRes = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .sendReplyMessage(
            id: id,
            receiver: getReciverId(),
            groupID: getGroupId(),
            replyMessage: replyMessage);
    // V2TimValueCallback<V2TimMessage> sendRes =
    //     await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
    //           id: id,
    //           receiver: getReciverId(),
    //           groupID: getGroupId(),
    //         );
    V2TimMessage resultMessage = sendRes.data!;
    String msgId = resultMessage.msgID!;

    resultMessage.id = mockKey;
    updateTextMessageForHistoryMsgList(resultMessage, msgId, mockKey, key);

    return sendRes;
  }

  // 判断是否是Group的Type
  bool isGroupType(int type) {
    return type == 1;
  }

  onSubmitted(
    String? s,
    V2TimMessage? replyMessage, {
    bool? needKeboardFocue,
  }) async {
    if (needKeboardFocue != null) {
      focusComeBack();
    }

    if (s == '' || s == null) {
      return;
    }
    inputController.clear();
    V2TimValueCallback<V2TimMessage> sendRes;

    String key =
        (widget.type == 1 ? "c2c_${widget.toUser}" : "group_${widget.toUser}");
    if (widget.type == 1) {
      if (replyMessage == null) {
        sendRes = await sendTextMessage(text: s, key: key);
      } else {
        sendRes = await sendCustomMessage(
            text: s, replyMessage: replyMessage, key: key);
      }

      inspect(widget);
    } else {
      if (replyMessage == null) {
        sendRes = await sendTextMessage(text: s, key: key);
      } else {
        sendRes = await sendCustomMessage(
            text: s, replyMessage: replyMessage, key: key);
      }
    }

    if (replyMessage != null) {
      Provider.of<KeyBoradModel>(context, listen: false).cleanReplyMessage();
    }

    if (sendRes.code == 0) {
      Utils.log('发送成功');
    } else {
      Utils.log(sendRes.desc);
      Utils.toast("发送失败 ${sendRes.code} ${sendRes.desc}");
    }
  }

  // 1 可以跳转， 0 禁止
  setGoBackForbid(status) {
    Provider.of<KeyBoradModel>(context, listen: false)
        .updateRecordBackStatus(status);
  }

  // 发送音频
  sendRecord(recordPath, _duration) async {
    if (_duration.ceil() > 0) {
      V2TimValueCallback<V2TimMessage> sendRes;

      String key = (widget.type == 1
          ? "c2c_${widget.toUser}"
          : "group_${widget.toUser}");

      V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
          await TencentImSDKPlugin.v2TIMManager
              .getMessageManager()
              .createSoundMessage(
                  soundPath: recordPath, duration: _duration.ceil());
      String id = createResult.toJson()["data"]["id"];
      V2TimMessage createMessage = createResult.data!.messageInfo!;
      String mockKey = id;

      createMessage.msgID = mockKey;
      createMessage.id = mockKey;
      createMessage.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;

      createMessage.groupID = getGroupId();
      createMessage.userID = getReciverId();

      addTextMessageForHistoryMsgList(createMessage, key);

      sendRes =
          await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
                id: id,
                receiver: getReciverId(),
                groupID: getGroupId(),
              );
      // if (sendRes.code == 0) {
      //   String key = (widget.type == 1
      //       ? "c2c_${widget.toUser}"
      //       : "group_${widget.toUser}");
      //   List<V2TimMessage> list = List.empty(growable: true);
      //   list.add(sendRes.data!);
      //   Provider.of<HistoryMessageListProvider>(context, listen: false)
      //       .addMessage(key, list);
      //   Utils.log('发送成功');
      // }
      if (sendRes.code == 0) {
        V2TimMessage resultMessage = sendRes.data!;
        String msgId = resultMessage.msgID!;
        resultMessage.id = mockKey;

        updateTextMessageForHistoryMsgList(resultMessage, msgId, mockKey, key);
        Utils.log('发送成功');
      }
    } else {
      Utils.toast("语音消息至少1秒才可发送");
    }
  }

  String displayreplyMessage(V2TimMessage message) {
    String res = '';
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        res = "【自定义消息】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        res = "【表情】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        res = "【文件】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        res = "【群提示】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        res = "【图片】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        res = "【位置信息】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        res = "【合并消息】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_NONE:
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        res = "【语音】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        res = message.textElem!.text!;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        res = "【视频】";
        break;
    }
    return res;
  }

  getShowName(message) {
    return message.friendRemark == null || message.friendRemark == ''
        ? message.nickName == null || message.nickName == ''
            ? message.sender
            : message.nickName
        : message.friendRemark;
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboradshow = Provider.of<KeyBoradModel>(context).show;
    V2TimMessage? replyMessage =
        Provider.of<KeyBoradModel>(context).replyMessage;
    if (replyMessage != null) {
      replyController.text =
          "${getShowName(replyMessage)}:${displayreplyMessage(replyMessage)}";
    }
    return Expanded(
      child: isKeyboradshow
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhysicalModel(
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
                      focusNode: inputFieldNode,
                      onSubmitted: (s) {
                        onSubmitted(s, replyMessage, needKeboardFocue: true);
                      },
                      onTap: () {
                        // 切换为键盘弹出，键盘弹出逻辑在convesation监听中,这里仅仅是变更参数
                        Provider.of<KeyBoradModel>(context, listen: false)
                            .jumpToScrollControllerBottom();
                        // 键盘的切换Fouce用来打开键盘 ContainerKey用来填充高度
                        Provider.of<KeyBoradModel>(context, listen: false)
                            .keyBoardFocus();
                        Provider.of<KeyBoradModel>(context, listen: false)
                            .setBottomConToKeyBoard(context: context);
                      },
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.send,
                      cursorColor: const Color(0xE5000000),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            top: 7, bottom: 0, left: 6, right: 6),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      minLines: 1,
                    ),
                  ),
                ),
                replyMessage != null
                    ? PhysicalModel(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          height: 34,
                          margin: const EdgeInsets.only(
                            top: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.black12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: replyController,
                                  onSubmitted: null,
                                  enabled: false,
                                  autocorrect: false,
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.send,
                                  cursorColor: CommonColors.getThemeColor(),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                      isDense: true,
                                      // contentPadding: EdgeInsets.all(4),
                                      contentPadding: EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                          left: 8,
                                          right: 4)),
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                  minLines: 1,
                                  maxLines: 2,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Provider.of<KeyBoradModel>(context,
                                          listen: false)
                                      .cleanReplyMessage();
                                },
                                child: const SizedBox(
                                  width: 30,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(
                        height: 0,
                      ),
              ],
            )
          : GestureDetector(
              onTapDown: (detail) {
                if (!isKeyboradshow && !isRecordInited) {
                  initRecord();
                }
              },
              onLongPressStart: (e) async {
                if (isRecordInited) {
                  // Either the permission was already granted before or the user just granted it.
                  buildOverLayView(context); //显示图标
                  start();
                }
              },
              onLongPressMoveUpdate: (e) {
                double height = MediaQuery.of(context).size.height * 0.5 - 240;
                double dy = e.localPosition.dy;

                if (dy.abs() > height) {
                  setState(() {
                    soundTipsText = "松开取消";
                  });
                } else {
                  soundTipsText = "手指上滑，取消发送";
                }
              },
              onLongPressEnd: (e) async {
                double dx = e.localPosition.dx;
                double dy = e.localPosition.dy;
                // if (e.localPosition.dx < 0 ||
                //     e.localPosition.dy < 0 ||
                //     e.localPosition.dy > 40) {
                //   // 取消了发送
                //   Utils.log("取消了");
                // }
                // 此高度为 160为录音取消组件距离顶部的预留距离
                double height = MediaQuery.of(context).size.height * 0.5 - 240;
                // double width = MediaQuery.of(context).size.width * 0.5 - 80;

                if (dy.abs() > height) {
                  setState(() {
                    recordCanceled = true;
                  });
                }
                try {
                  if (overlayEntry != null) {
                    overlayEntry!.remove();
                    overlayEntry = null;
                  }
                } catch (err) {
                  Utils.log(err);
                }

                stop();
                // sendRecord(soundPath);
              },
              onLongPressCancel: () {
                setState(() {
                  recordCanceled = true;
                });
                try {
                  if (overlayEntry != null) {
                    overlayEntry!.remove();
                    overlayEntry = null;
                  }
                } catch (err) {
                  Utils.log(err);
                }

                stop();
              },
              child: Container(
                height: 34,
                color: isRecording
                    ? CommonColors.getGapColor()
                    : CommonColors.getWitheColor(),
                child: Row(
                  children: const [
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
