import 'dart:convert';
import 'dart:io';
import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/provider/keybooadshow.dart';
import 'package:discuss/utils/permissions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/pages/conversion/component/advancemsgitem.dart';
import 'package:discuss/pages/conversion/dataInterface/advancemsglist.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:discuss/utils/toast.dart';
// import 'package:video_player/video_player.dart';

class AdvanceMsg extends StatelessWidget {
  AdvanceMsg(this.toUser, this.type, {Key? key}) : super(key: key);
  final String toUser;
  final int type;
  final picker = ImagePicker();
  // VideoPlayerController _controller;
  // 判断是否是Group的Type
  bool isGroupType(int type) {
    return type == 1;
  }

  // 添加到历史列表
  void addMessageForHistoryMsgList(V2TimMessage mesg, String key, context) {
    List<V2TimMessage> list = List.empty(growable: true);
    list.add(mesg);
    Provider.of<HistoryMessageListProvider>(context, listen: false)
        .addMessage(key, list);
  }

  // 更新历史列表
  void updateMessageForHistoryMsgList(
      V2TimMessage msg, String msgId, String mcokId, String key, context) {
    Provider.of<HistoryMessageListProvider>(context, listen: false)
        .updateCreateMessage(key, msgId, mcokId, msg);
  }

  sendVideoMsg(context) async {
    // ignore: deprecated_member_use
    final video = await picker.getVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (video == null) {
      return;
    }
    String tempPath = (await getTemporaryDirectory()).path;

    String? thumbnail = await VideoThumbnail.thumbnailFile(
      video: video.path,
      thumbnailPath: tempPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    // 获取视频文件大小(默认为字节)
    var file = File(video.path);
    VideoPlayerController controller = VideoPlayerController.file(file);
    int size = await file.length();
    if (size >= 104857600) {
      Utils.toast("发送失败,视频不能大于100MB");
      return;
    }
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendVideoMessage(
          videoFilePath: video.path,
          receiver: type == 1 ? toUser : "",
          groupID: type == 2 ? toUser : "",
          type: 'mp4',
          snapshotPath: thumbnail ?? "",
          onlineUserOnly: false,
          duration: controller.value.duration.inSeconds,
        );

    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      V2TimMessage? msg = res.data;
      // 添加新消息

      try {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .addMessage(key, [msg!]);
      } catch (err) {
        Utils.log("发生错误");
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
      Utils.log(res.desc);
    }
  }

  sendImageMsg(context, checktype) async {
    bool hasPermission = checktype == 0
        ? await Permissions.checkPermission(context, Permission.camera.value)
        : await Permissions.checkPermission(context, Permission.photos.value);
    if (!hasPermission) {
      return;
    }
    // ignore: deprecated_member_use
    final image = await picker.getImage(
        source: checktype == 0 ? ImageSource.camera : ImageSource.gallery);
    if (image == null) {
      return;
    }
    String path = image.path;
    Utils.log(path);
    V2TimValueCallback<V2TimMessage> sendRes;

    String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
    Utils.log(path);
    V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createImageMessage(imagePath: path);

    String id = createResult.toJson()["data"]["id"];
    V2TimMessage createMessage = createResult.data!.messageInfo!;
    String mockKey = id;

    // msgID填充一下，部分组件会使用其做判断
    createMessage.id = mockKey;
    createMessage.msgID = mockKey;
    createMessage.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;
    createMessage.groupID = toUser;
    addMessageForHistoryMsgList(createMessage, key, context);

    sendRes = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessage(
            id: id,
            receiver: type == 1 ? toUser : "",
            groupID: type == 2 ? toUser : "",
            onlineUserOnly: false,
            isExcludedFromUnreadCount: toUser.contains('im_discuss_'));
    V2TimMessage resultMessage = sendRes.data!;
    String msgId = resultMessage.msgID!;
    resultMessage.id = mockKey;

    if (sendRes.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");

      // 添加新消息
      try {
        updateMessageForHistoryMsgList(
            resultMessage, msgId, mockKey, key, context);
      } catch (err) {
        Utils.log("发生错误");
      }
    } else {
      Utils.toast("发送失败 ${sendRes.code} ${sendRes.desc}");
    }
  }

  sendCustomData(context) async {
    Utils.log("herree $toUser");
    V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createCustomMessage(
                data: json.encode({
              "text": "欢迎加入腾讯·云通信大家庭！",
              "businessID": "text_link",
              "link": "https://cloud.tencent.com/document/product/269/3794",
              "version": 4
            }));
    String id = createResult.toJson()["data"]["id"];

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id,
              receiver: type == 1 ? toUser : "",
              groupID: type == 2 ? toUser : "",
              isExcludedFromUnreadCount: toUser.contains('im_discuss_'),
            );
    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      List<V2TimMessage> list = List.empty(growable: true);
      V2TimMessage? msg = res.data;
      // 添加新消息

      list.add(msg!);

      try {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .addMessage(key, list);
      } catch (err) {
        Utils.log("发生错误");
      }
    } else {
      Utils.log("发送失败 ${res.code} ${res.desc} herree");
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendFile(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Utils.log("选择成功${result.files.single.path}");
      String? path = result.files.single.path;
      File file = File(path ?? "");
      int size = file.lengthSync();

      String key = (isGroupType(type) ? "c2c_$toUser" : "group_$toUser");
      V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
          await TencentImSDKPlugin.v2TIMManager
              .getMessageManager()
              .createFileMessage(
                  fileName: path!.split('/').last, filePath: path);

      String id = createResult.toJson()["data"]["id"];
      V2TimMessage createMessage = createResult.data!.messageInfo!;

      // 填充一下msgID
      createMessage.id = id;
      createMessage.msgID = id;
      createMessage.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;
      createMessage.fileElem?.fileSize = size;
      //  不加tyoe某些情况下的某些组件下会报错
      isGroupType(type)
          ? createMessage.groupID = toUser
          : createMessage.userID = toUser;
      addMessageForHistoryMsgList(createMessage, key, context);

      V2TimValueCallback<V2TimMessage> res =
          await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
                id: id,
                receiver: type == 1 ? toUser : "",
                groupID: type == 2 ? toUser : "",
                onlineUserOnly: false,
              );

      V2TimMessage resultMessage = res.data!;
      String msgId = resultMessage.msgID!;
      resultMessage.id = id;
      if (res.code == 0) {
        try {
          updateMessageForHistoryMsgList(
              resultMessage, msgId, id, key, context);
        } catch (err) {
          Utils.log("发生错误");
        }
      } else {
        Utils.toast("发送失败 ${res.code} ${res.desc}");
      }
    } else {
      // User canceled the picker
    }
  }

  Future<int?> openPanel(context) {
    close() {
      Navigator.of(context).pop();
    }

    return showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext ctx) {
        return Container(
          height: 260,
          color: hexToColor('ededed'),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
            ),
            children: [
              AdvanceMsgList(
                name: '相册',
                icon: const Icon(
                  Icons.insert_photo,
                  size: 30,
                ),
                onPressed: () async {
                  close();
                  sendImageMsg(context, 1);
                },
              ),
              AdvanceMsgList(
                name: '拍摄',
                icon: const Icon(
                  Icons.camera_alt,
                  size: 30,
                ),
                onPressed: () {
                  close();
                  sendImageMsg(context, 0);
                },
              ),
              AdvanceMsgList(
                name: '视频',
                icon: const Icon(
                  Icons.video_call,
                  size: 30,
                ),
                onPressed: () {
                  close();
                  sendVideoMsg(context);
                },
              ),
              AdvanceMsgList(
                name: '文件',
                icon: const Icon(
                  Icons.insert_drive_file,
                  size: 30,
                ),
                onPressed: () async {
                  close();
                  sendFile(context);
                },
              ),
              AdvanceMsgList(
                name: '自定义',
                icon: const Icon(Icons.topic),
                onPressed: () {
                  close();
                  sendCustomData(context);
                },
              ),
            ].map((e) => AdvanceMsgItem(e)).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Utils.log("toUser $toUser type $type herree");
    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton(
        icon: Icon(
          Icons.add,
          size: 28,
          color: hexToColor("444444"),
        ),
        onPressed: () async {
          Provider.of<KeyBoradModel>(context, listen: false)
              .setBottomConToAdvMsg();
          Provider.of<KeyBoradModel>(context, listen: false).keyBoardUnfocus();
          Provider.of<KeyBoradModel>(context, listen: false)
              .jumpToScrollControllerBottom();
          // await openPanel(context);
        },
      ),
    );
  }
}

class AdvanceMsgComp extends StatelessWidget {
  AdvanceMsgComp(this.toUser, this.type, {Key? key}) : super(key: key);
  final String toUser;
  final int type;
  final picker = ImagePicker();
  // VideoPlayerController _controller;
  // 判断是否是Group的Type
  bool isGroupType(int type) {
    return type == 1;
  }

  // 添加到历史列表
  void addMessageForHistoryMsgList(V2TimMessage mesg, String key, context) {
    List<V2TimMessage> list = List.empty(growable: true);
    list.add(mesg);
    Provider.of<HistoryMessageListProvider>(context, listen: false)
        .addMessage(key, list);
  }

  // 更新历史列表
  void updateMessageForHistoryMsgList(
      V2TimMessage msg, String msgId, String mcokId, String key, context) {
    Provider.of<HistoryMessageListProvider>(context, listen: false)
        .updateCreateMessage(key, msgId, mcokId, msg);
  }

  // 兼容C2C
  String getReciverId() {
    bool isUser = type == 1;
    return !isUser ? "" : toUser;
  }

// 兼容Group
  String getGroupId() {
    bool isUser = type == 1;
    return isUser ? "" : toUser;
  }

  //TOOD： sendVideoMessage暂时不做改动，视频发送依然存在问题
  sendVideoMsg(context) async {
    bool hasPermission =
        await Permissions.checkPermission(context, Permission.camera.value);
    if (!hasPermission) {
      return;
    }
    // ignore: deprecated_member_use
    final video = await picker.getVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (video == null) {
      return;
    }
    String tempPath = (await getTemporaryDirectory()).path;

    String? thumbnail = await VideoThumbnail.thumbnailFile(
      video: video.path,
      thumbnailPath: tempPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    // 获取视频文件大小(默认为字节)
    var file = File(video.path);
    VideoPlayerController controller = VideoPlayerController.file(file);
    int size = await file.length();
    if (size >= 104857600) {
      Utils.toast("发送失败,视频不能大于100MB");
      return;
    }

    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendVideoMessage(
          videoFilePath: video.path,
          receiver: getReciverId(),
          groupID: getGroupId(),
          type: 'mp4',
          snapshotPath: thumbnail ?? "",
          onlineUserOnly: false,
          duration: controller.value.duration.inSeconds,
        );

    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      V2TimMessage? msg = res.data;
      // 添加新消息

      try {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .addMessage(key, [msg!]);
      } catch (err) {
        Utils.log("发生错误");
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
      Utils.log(res.desc);
    }
  }

  sendImageMsg(context, checktype) async {
    bool hasPermission = checktype == 0
        ? await Permissions.checkPermission(context, Permission.camera.value)
        : await Permissions.checkPermission(context, Permission.photos.value);
    if (!hasPermission) {
      return;
    }
    // ignore: deprecated_member_use
    final image = await picker.getImage(
        source: checktype == 0 ? ImageSource.camera : ImageSource.gallery);
    if (image == null) {
      return;
    }

    V2TimValueCallback<V2TimMessage> sendRes;

    String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");

    String path = image.path;
    Utils.log(path);
    V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createImageMessage(imagePath: path);

    String id = createResult.toJson()["data"]["id"];
    V2TimMessage createMessage = createResult.data!.messageInfo!;
    String mockKey = id;

    // msgID填充一下，部分组件会使用其做判断
    createMessage.id = mockKey;
    createMessage.msgID = mockKey;
    createMessage.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;
    // 不加id某些情况会报错
    createMessage.groupID = getGroupId();
    createMessage.userID = getReciverId();
    addMessageForHistoryMsgList(createMessage, key, context);

    sendRes =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id,
              receiver: getReciverId(),
              groupID: getGroupId(),
              onlineUserOnly: false,
            );
    V2TimMessage resultMessage = sendRes.data!;
    String msgId = resultMessage.msgID!;
    resultMessage.id = mockKey;

    updateMessageForHistoryMsgList(resultMessage, msgId, mockKey, key, context);
  }

  sendCustomData(context) async {
    Utils.log("herree $toUser");
    V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createCustomMessage(
                data: json.encode({
              "text": "欢迎加入腾讯·云通信大家庭！",
              "businessID": "text_link",
              "link": "https://cloud.tencent.com/document/product/269/3794",
              "version": 4
            }));
    String id = createResult.toJson()["data"]["id"];

    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
              id: id,
              receiver: getReciverId(),
              groupID: getGroupId(),
              isExcludedFromUnreadCount: toUser.contains('im_discuss_'),
            );
    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      List<V2TimMessage> list = List.empty(growable: true);
      V2TimMessage? msg = res.data;
      // 添加新消息

      list.add(msg!);

      try {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .addMessage(key, list);
      } catch (err) {
        Utils.log("发生错误");
      }
    } else {
      Utils.log("发送失败 ${res.code} ${res.desc} herree");
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendFile(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Utils.log("选择成功${result.files.single.path}");
      String? path = result.files.single.path;
      File file = File(path ?? "");
      int size = file.lengthSync();

      String key = (isGroupType(type) ? "c2c_$toUser" : "group_$toUser");
      V2TimValueCallback<V2TimMsgCreateInfoResult> createResult =
          await TencentImSDKPlugin.v2TIMManager
              .getMessageManager()
              .createFileMessage(
                  fileName: path!.split('/').last, filePath: path);

      String id = createResult.toJson()["data"]["id"];
      V2TimMessage createMessage = createResult.data!.messageInfo!;

      // 填充一下msgID
      createMessage.id = id;
      createMessage.msgID = id;
      createMessage.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;
      createMessage.fileElem?.fileSize = size;
      //  不加id某些情况下的某些组件下会报错

      createMessage.groupID = getGroupId();
      createMessage.userID = getReciverId();
      addMessageForHistoryMsgList(createMessage, key, context);

      V2TimValueCallback<V2TimMessage> res =
          await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
                id: id,
                receiver: getReciverId(),
                groupID: getGroupId(),
                onlineUserOnly: false,
              );

      V2TimMessage resultMessage = res.data!;
      String msgId = resultMessage.msgID!;
      resultMessage.id = id;

      if (res.code == 0) {
        try {
          updateMessageForHistoryMsgList(
              resultMessage, msgId, id, key, context);
        } catch (err) {
          Utils.log("更新historyList失败,$err");
        }
      } else {
        Utils.toast("发送失败 ${res.code} ${res.desc}");
      }
    } else {
      // User canceled the picker
    }
  }

  // Future<int?> openPanel(context) {

  //   return showModalBottomSheet<int>(
  //     context: context,
  //     builder: );
  // }
  close() {
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Utils.log("toUser $toUser type $type herree");

    return Container(
      height: 260,
      color: hexToColor('ededed'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
        ),
        children: [
          AdvanceMsgList(
            name: '相册',
            icon: const Icon(
              Icons.insert_photo,
              size: 30,
            ),
            onPressed: () async {
              close();
              sendImageMsg(context, 1);
            },
          ),
          AdvanceMsgList(
            name: '拍摄',
            icon: const Icon(
              Icons.camera_alt,
              size: 30,
            ),
            onPressed: () {
              close();
              sendImageMsg(context, 0);
            },
          ),
          AdvanceMsgList(
            name: '视频',
            icon: const Icon(
              Icons.video_call,
              size: 30,
            ),
            onPressed: () {
              close();
              sendVideoMsg(context);
            },
          ),
          AdvanceMsgList(
            name: '文件',
            icon: const Icon(
              Icons.insert_drive_file,
              size: 30,
            ),
            onPressed: () async {
              close();
              sendFile(context);
            },
          ),
          AdvanceMsgList(
            name: '自定义',
            icon: const Icon(Icons.topic),
            onPressed: () {
              close();
              sendCustomData(context);
            },
          ),
        ].map((e) => AdvanceMsgItem(e)).toList(),
      ),
    );
  }
}
