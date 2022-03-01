import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:im_api_example/i18n/i18n_utils.dart';

class SendVideoMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendVideoMessageState();
}

class SendVideoMessageState extends State<SendVideoMessage> {
  Map<String, dynamic>? resData;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  File? video;
  String type = '';
  String snapshotPath = '';
  int duration = 0;
  Uint8List? _fileContent;
  String? _fileName;
  final picker = ImagePicker();
  sendVideoMessage() async {
    print("${video!.path} $type $duration $snapshotPath");
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createVideoMessage(
              videoFilePath: kIsWeb ? '' : video!.path,
              type: type,
              snapshotPath: snapshotPath,
              duration: duration,
              fileContent: _fileContent,
              fileName: _fileName,
            );
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
            localCustomData: imt("自定义localCustomData(sendVideoMessage)"));
    setState(() {
      resData = res.toJson();
    });
  }

  void getVideoDetail(File file) async {
    // 获取snapshotPath，type，duration
    String tempPath = (await getTemporaryDirectory()).path;
    final fileName = await VideoThumbnail.thumbnailFile(
      video: file.path,
      thumbnailPath: tempPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    setState(() {
      video = file;
      snapshotPath = "$fileName";
      type = file.path.split('.').last;
      duration = 10; // 这里需要用其他服获取视频的时长
    });
  }

  Future getVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    final fileContent = await pickedFile!.readAsBytes();

    setState(() {
      if (kIsWeb) {
        _fileContent = fileContent;
        _fileName = pickedFile.name;
        video = new File(_fileName as String);
      } else {
        getVideoDetail(File(pickedFile.path));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: getVideo,
                  child: Text(imt("选择视频")),
                ),
                margin: EdgeInsets.only(right: 12),
              ),
              video == null ? Text(imt(imt("未选择"))) : Text(video!.path.split("/").last),
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
                      Text(receiver.length > 0 ? receiver.toString() : imt("未选择")),
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
                  child: Text(groupID.length > 0 ? groupID.toString() : imt("未选择")),
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
                  child: Text(imt_para("已选：{{priority}}", "已选：${priority}")(priority: priority)),
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
                  onPressed: sendVideoMessage,
                  child: Text(imt("发送视频消息")),
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
