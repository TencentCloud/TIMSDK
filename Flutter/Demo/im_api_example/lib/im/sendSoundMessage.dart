import 'dart:io';
import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class SendSoundMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendSoundMessageState();
}

class SendSoundMessageState extends State<SendSoundMessage> {
  Map<String, dynamic>? resData;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
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
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendSoundMessage(
          soundPath: soundPath,
          duration: dura,
          receiver: receiver.length > 0 ? receiver.first : "",
          groupID: groupID.length > 0 ? groupID.first : "",
          priority: priority,
          onlineUserOnly: onlineUserOnly,
          isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        );
    setState(() {
      resData = res.toJson();
    });
    // 删除本地的录音文件
    File soundFile = new File(soundPath);
    soundFile.delete().then((value) {
      print("删除文件成功");
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
    String path = "$tempPath/sendSoundMessage_$random.acc";
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
                  child: Text(isRecording ? "结束录音" : "开始录音")),
              soundPath == ''
                  ? Container(
                      child: Text("未录制"),
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
                  child:
                      Text(receiver.length > 0 ? receiver.toString() : "未选择"),
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
                  child: Text(groupID.length > 0 ? groupID.toString() : "未选择"),
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
                        title: const Text('优先级'),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('0'),
                            onPressed: () {
                              setState(() {
                                priority = 0;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('1'),
                            onPressed: () {
                              setState(() {
                                priority = 1;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('2'),
                            onPressed: () {
                              setState(() {
                                priority = 2;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('3'),
                            onPressed: () {
                              setState(() {
                                priority = 3;
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
                    child: Text("选择优先级"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text('已选：$priority'),
                )
              ],
            ),
          ),
          Row(
            children: [
              Text("是否仅在线用户接受到消息"),
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
              Text("发送消息是否不计入未读数"),
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
                  child: Text("发送录音消息"),
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
