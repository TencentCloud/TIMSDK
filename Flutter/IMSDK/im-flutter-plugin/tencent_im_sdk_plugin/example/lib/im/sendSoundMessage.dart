import 'dart:io';
import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:example/im/friendSelector.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SendSoundMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendSoundMessageState();
}

class SendSoundMessageState extends State<SendSoundMessage> {
  Map<String, dynamic>? resData;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  int duration = 0;
  bool isRecording = false;
  String soundPath = '';
  late DateTime startTime;
  late DateTime endTime;

  @override
  void dispose() {
    Record.stop();
    super.dispose();
  }

  @override
  void initState() {
    isRecording = false;
    Record.hasPermission().then((value) {
      print("hasPermission $value");
    });
    super.initState();
  }

  sendSoundMessage() async {
    int dura =
        (endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch) ~/
            1000;
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createSoundMessage(soundPath: soundPath, duration: dura);
    String id = createMessage.data!.id!;

    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessage(
            id: id,
            receiver: receiver.length > 0 ? receiver.first : "",
            groupID: groupID.length > 0 ? groupID.first : "",
            priority: priority,
            onlineUserOnly: onlineUserOnly,
            isExcludedFromUnreadCount: isExcludedFromUnreadCount,
            localCustomData: imt("自定义localCustomData(sendSoundMessage)"));

    setState(() {
      resData = res.toJson();
    });
    // 删除本地的录音文件
    File soundFile = new File(soundPath);
    soundFile.delete().then((value) {
      print(imt("删除文件成功"));
      setState(() {
        soundPath = '';
      });
    });
  }

  stop() async {
    await Record.stop();
    setState(() {
      isRecording = false;
      endTime = DateTime.now();
    });
  }

  start() async {
    String tempPath = (await getTemporaryDirectory()).path;
    int random = new Random().nextInt(10000);
    String path = "$tempPath/sendSoundMessage_$random.aac";
    File soundFile = new File(path);
    soundFile.createSync();
    try {
      await Record.start(path: path);
    } catch (err) {
      print(err);
    }
    setState(() {
      isRecording = true;
      soundPath = path;
      startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    isRecording ? stop() : start();
                  },
                  child: Text(isRecording ? imt("结束录音") : imt("开始录音"))),
              soundPath == ''
                  ? Container(
                      child: Text(imt("未录制")),
                      margin: EdgeInsets.only(left: 12),
                    )
                  : Container(
                      child: Text(soundPath.split('/').last),
                      margin: EdgeInsets.only(left: 12),
                    )
            ],
          ),
          Row(
            children: [
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    receiver = data;
                  });
                },
                switchSelectType: true,
                value: receiver,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      receiver.length > 0 ? receiver.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          Row(
            children: [
              GroupSelector(
                onSelect: (data) {
                  setState(() {
                    groupID = data;
                  });
                },
                switchSelectType: true,
                value: groupID,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      groupID.length > 0 ? groupID.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black45,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      showAdaptiveActionSheet(
                        context: context,
                        title: Text(imt("优先级")),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_DEFAULT'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_HIGH'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_HIGH;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_LOW'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_LOW;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_NORMAL'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_NORMAL;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        cancelAction: CancelAction(
                          title: const Text('Cancel'),
                        ), // onPressed parameter is optional by default will dismiss the ActionSheet
                      );
                    },
                    child: Text(imt("选择优先级")),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child:  Text("已选：$priority"),
                )
              ],
            ),
          ),
          Row(
            children: [
              Text(imt("是否仅在线用户接受到消息")),
              Switch(
                value: onlineUserOnly,
                onChanged: (res) {
                  setState(() {
                    onlineUserOnly = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("发送消息是否不计入未读数")),
              Switch(
                value: isExcludedFromUnreadCount,
                onChanged: (res) {
                  setState(() {
                    isExcludedFromUnreadCount = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendSoundMessage,
                  child: Text(imt("发送录音消息")),
                ),
              )
            ],
          ),
          SDKResponse(resData),
        ],
      ),
    );
  }
}
