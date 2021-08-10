import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/common/hexToColor.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/conversion.dart';
import 'package:tencent_im_sdk_plugin_example/provider/conversion.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class Message extends StatefulWidget {
  State<StatefulWidget> createState() => MessageState();
}

class MessageState extends State<Message> {
  MessageState() {
    getMessage();
  }

  getMessage() async {
    V2TimValueCallback<V2TimConversationResult> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationList(count: 100, nextSeq: "0");
    List<V2TimConversation> newList = [];
    if (data.data != null)
      newList = data.data!.conversationList!.cast<V2TimConversation>();
    else
      newList = [];
    Provider.of<ConversionModel>(
      context,
      listen: false,
    ).setConversionList(newList);
  }

  // 筛选一下图片后缀不正确的图片
  String? checkFaceUrl(String? url) {
    String faceUrl = url != null ? url : "";
    RegExp checkUrl =
        new RegExp("\S{0,}.png|.jpg|.jpeg|.gif", caseSensitive: false);

    return checkUrl.hasMatch(faceUrl) ? faceUrl : "";
  }

  Widget build(BuildContext context) {
    List<V2TimConversation>? conversionList = Provider.of<ConversionModel>(
      context,
      listen: true,
    ).conversionList;
    if (conversionList == null || conversionList.isEmpty) {
      return Center(
        child: Text(
          "暂无会话",
          style: TextStyle(
            color: CommonColors.getTextWeakColor(),
          ),
        ),
      );
    }

    return ListView(
      children: conversionList.map((e) {
        if (e.lastMessage == null || e.lastMessage!.msgID == '') {
          return Container();
        }
        return Container(
          height: 70,
          child: Slidable(
            key: Key(e.conversationID),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ConversionItem(
              name: e.showName,
              faceUrl: checkFaceUrl(e.faceUrl),
              lastMessage: e.lastMessage,
              unreadCount: e.unreadCount,
              type: e.type,
              conversationID: e.conversationID,
              userID: e.userID,
            ),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '删除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  TencentImSDKPlugin.v2TIMManager
                      .getConversationManager()
                      .deleteConversation(
                        conversationID: e.conversationID,
                      )
                      .then((value) {
                    if (value.code == 0) {
                      Utils.toast("删除成功");
                      Provider.of<ConversionModel>(context, listen: false)
                          .removeConversionByConversationId(e.conversationID);
                    } else {
                      Utils.toast("删除失败 ${value.code} ${value.desc}");
                    }
                  });
                },
                closeOnTap: true,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ConversionItem extends StatelessWidget {
  ConversionItem({
    this.name,
    this.faceUrl,
    this.lastMessage,
    this.unreadCount,
    this.type,
    required this.conversationID,
    this.userID,
  });
  final String? name;
  final String? faceUrl;
  final V2TimMessage? lastMessage;
  final int? unreadCount;
  final int? type;
  final String conversationID;
  final String? userID;
  test1(context) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => Conversion(conversationID),
      ),
    );
  }

  String formatTime() {
    int timestamp = lastMessage!.timestamp! * 1000;
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    if (now.day == time.day) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
    } else {
      return "${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
    }
  }

  String? getFaceUrl() {
    return (faceUrl == null || faceUrl == '')
        ? type == 1
            ? 'images/person.png'
            : 'images/logo.png'
        : faceUrl;
  }

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {test1(context)},
      child: Container(
        height: 70,
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              child: Padding(
                padding: EdgeInsets.all(11),
                child: PhysicalModel(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4.8),
                  clipBehavior: Clip.antiAlias,
                  child: Avatar(
                    width: 48,
                    height: 48,
                    radius: 0,
                    avtarUrl: getFaceUrl(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: hexToColor("ededed"),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 24,
                      margin: EdgeInsets.only(top: 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name == null ? "xx" : name!,
                              style: TextStyle(
                                color: hexToColor("111111"),
                                fontSize: 18,
                                height: 1,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            child: Text(
                              formatTime(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: Color(int.parse('b0b0b0', radix: 16))
                                      .withAlpha(255),
                                  fontSize: 12),
                            ),
                            width: 105,
                            padding: EdgeInsets.only(right: 16),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                      margin: EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            lastMessage!.elemType ==
                                    MessageElemType.V2TIM_ELEM_TYPE_TEXT
                                ? lastMessage!.textElem!.text!
                                : lastMessage!.elemType ==
                                        MessageElemType
                                            .V2TIM_ELEM_TYPE_GROUP_TIPS
                                    ? '【系统消息】'
                                    : lastMessage!.elemType ==
                                            MessageElemType
                                                .V2TIM_ELEM_TYPE_SOUND
                                        ? '【语音消息】'
                                        : lastMessage!.elemType ==
                                                MessageElemType
                                                    .V2TIM_ELEM_TYPE_CUSTOM
                                            ? '【自定义消息】'
                                            : lastMessage!.elemType ==
                                                    MessageElemType
                                                        .V2TIM_ELEM_TYPE_IMAGE
                                                ? '【图片】'
                                                : lastMessage!.elemType ==
                                                        MessageElemType
                                                            .V2TIM_ELEM_TYPE_VIDEO
                                                    ? '【视频】'
                                                    : lastMessage!.elemType ==
                                                            MessageElemType
                                                                .V2TIM_ELEM_TYPE_FILE
                                                        ? '【文件】'
                                                        : lastMessage!
                                                                    .elemType ==
                                                                MessageElemType
                                                                    .V2TIM_ELEM_TYPE_FACE
                                                            ? '【表情】'
                                                            : '',
                            style: TextStyle(
                              color: CommonColors.getTextWeakColor(),
                              fontSize: 14,
                            ),
                          )),
                          Container(
                            child: unreadCount! > 0
                                ? PhysicalModel(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      color: CommonColors.getReadColor(),
                                      width: 18,
                                      height: 18,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            unreadCount! > 99
                                                ? '...'
                                                : unreadCount.toString(),
                                            textAlign: TextAlign.center,
                                            textWidthBasis:
                                                TextWidthBasis.parent,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : null,
                            width: 18,
                            height: 18,
                            margin: EdgeInsets.only(right: 16),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
