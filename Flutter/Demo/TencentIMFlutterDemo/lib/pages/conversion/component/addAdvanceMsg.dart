import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/hexToColor.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/advanceMsgItem.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/dataInterface/advanceMsgList.dart';
import 'package:tencent_im_sdk_plugin_example/provider/currentMessageList.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';
// import 'package:video_player/video_player.dart';

class AdvanceMsg extends StatelessWidget {
  AdvanceMsg(this.toUser, this.type);
  final String toUser;
  final int type;
  final picker = ImagePicker();
  // VideoPlayerController _controller;

  sendVideoMsg(context) async {
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
          snapshotPath: thumbnail == null ? "" : thumbnail,
          onlineUserOnly: false,
          duration: 10,
        );

    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      V2TimMessage? msg = res.data;
      // 添加新消息

      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addOneMessageIfNotExits(key, msg!);
      } catch (err) {
        print("发生错误");
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
      print(res.desc);
    }
  }

  sendImageMsg(context, checktype) async {
    final image = await picker.getImage(
        source: checktype == 0 ? ImageSource.camera : ImageSource.gallery);
    if (image == null) {
      return;
    }
    String path = image.path;
    print(path);
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendImageMessage(
          imagePath: path,
          receiver: type == 1 ? toUser : "",
          groupID: type == 2 ? toUser : "",
          onlineUserOnly: false,
        );

    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      V2TimMessage? msg = res.data;
      // 添加新消息
      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addOneMessageIfNotExits(key, msg!);
      } catch (err) {
        print("发生错误");
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendCustomData(context) async {
    print("herree $toUser");
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendCustomMessage(
          data: json.encode({
            "text": "欢迎加入腾讯·云通信大家庭！",
            "businessID": "text_link",
            "link": "https://cloud.tencent.com/document/product/269/3794",
            "version": 4
          }),
          receiver: type == 1 ? toUser : "",
          groupID: type == 2 ? toUser : "",
        );
    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      List<V2TimMessage> list = new List.empty(growable: true);
      V2TimMessage? msg = res.data;
      // 添加新消息

      list.add(msg!);

      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addMessage(key, list);
      } catch (err) {
        print("发生错误");
      }
    } else {
      print("发送失败 ${res.code} ${res.desc} herree");
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendFile(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      print("选择成功${result.files.single.path}");
      String? path = result.files.single.path;
      V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin
          .v2TIMManager
          .getMessageManager()
          .sendFileMessage(
            fileName: path!.split('/').last,
            filePath: path,
            receiver: type == 1 ? toUser : "",
            groupID: type == 2 ? toUser : "",
            onlineUserOnly: false,
          );
      if (res.code == 0) {
        String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
        List<V2TimMessage> list = new List.empty(growable: true);
        V2TimMessage? msg = res.data;
        // 添加新消息

        list.add(msg!);
        try {
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(key, list);
        } catch (err) {
          print("发生错误");
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
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
            ),
            children: [
              new AdvanceMsgList(
                name: '相册',
                icon: Icon(
                  Icons.insert_photo,
                  size: 30,
                ),
                onPressed: () async {
                  close();
                  sendImageMsg(context, 1);
                },
              ),
              new AdvanceMsgList(
                name: '拍摄',
                icon: Icon(
                  Icons.camera_alt,
                  size: 30,
                ),
                onPressed: () {
                  close();
                  sendImageMsg(context, 0);
                },
              ),
              new AdvanceMsgList(
                name: '视频',
                icon: Icon(
                  Icons.video_call,
                  size: 30,
                ),
                onPressed: () {
                  close();
                  sendVideoMsg(context);
                },
              ),
              new AdvanceMsgList(
                name: '文件',
                icon: Icon(
                  Icons.insert_drive_file,
                  size: 30,
                ),
                onPressed: () async {
                  close();
                  sendFile(context);
                },
              ),
              new AdvanceMsgList(
                name: '自定义',
                icon: Icon(Icons.topic),
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

  Widget build(BuildContext context) {
    print("toUser $toUser type $type herree");
    return Container(
      width: 56,
      height: 56,
      child: IconButton(
        icon: Icon(
          Icons.add,
          size: 28,
          color: Colors.black,
        ),
        onPressed: () async {
          await openPanel(context);
        },
      ),
    );
  }
}
