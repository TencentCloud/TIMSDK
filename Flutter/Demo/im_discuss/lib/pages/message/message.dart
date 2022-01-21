import 'package:discuss/config.dart';
import 'package:discuss/provider/conversationlistprovider.dart';
import 'package:discuss/utils/commonUtils.dart';
import 'package:discuss/utils/imsdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/pages/conversion/conversion.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:discuss/utils/toast.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Message extends StatefulWidget {
  const Message({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MessageState();
}

class MessageState extends State<Message> {
  int count = 100;

  @override
  initState() {
    super.initState();
    getAllMessages();
  }

  getAllMessages() async {
    List<V2TimConversation> allMessages = [];
    String nextSeq = "0";
    bool isFinished = false;
    while (!isFinished) {
      try {
        V2TimValueCallback<V2TimConversationResult> data =
            await IMSDK.getConversationList(
          nextSeq: nextSeq,
          count: count,
        );
        if (data.code == 0) {
          V2TimConversationResult result = data.data!;
          if (result.conversationList!.isNotEmpty) {
            allMessages.addAll(List.castFrom(result.conversationList!));
          }
          nextSeq = result.nextSeq!;
          isFinished = result.isFinished!;
        }
      } catch (e) {
        Utils.log('getMessageError');
        isFinished = true;
      }
    }
    Provider.of<ConversationListProvider>(
      context,
      listen: false,
    ).replaceConversationList(allMessages);
  }

  // 筛选一下图片后缀不正确的图片
  String? checkFaceUrl(String? url) {
    String faceUrl = url ?? "";
    RegExp checkUrl =
        // ignore: unnecessary_string_escapes
        RegExp("\S{0,}.png|.jpg|.jpeg|.gif", caseSensitive: false);

    return checkUrl.hasMatch(faceUrl) ? faceUrl : "";
  }

  deleteConversation(V2TimConversation conversation) {
    IMSDK
        .deleteConversation(
      conversationID: conversation.conversationID,
    )
        .then((value) {
      if (value.code == 0) {
        Utils.toast("删除成功");
        Provider.of<ConversationListProvider>(context, listen: false)
            .deleteConversation([conversation]);
      } else {
        Utils.toast("删除失败 ${value.code} ${value.desc}");
      }
    });
  }

  togglePinConversation(V2TimConversation conversation) async {
    try {
      TencentImSDKPlugin.v2TIMManager.getConversationManager().pinConversation(
          conversationID: conversation.conversationID,
          isPinned: !(conversation.isPinned ?? false));
    } catch (e) {
      Utils.toast('设置置顶失败');
    }
    getAllMessages();
  }

  toggleDoNotDisturbConversation(V2TimConversation conversation) async {
    try {
      if (conversation.type == ConversationType.V2TIM_C2C) {
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .setC2CReceiveMessageOpt(
                userIDList: [conversation.userID!],
                opt: CommonUtils.isReceivingAndNotifingMessage(
                        conversation.recvOpt!)
                    ? ReceiveMsgOptEnum.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE
                    : ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE);
      } else {
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .setGroupReceiveMessageOpt(
                groupID: conversation.groupID!,
                opt: CommonUtils.isReceivingAndNotifingMessage(
                        conversation.recvOpt!)
                    ? ReceiveMsgOptEnum.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE
                    : ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE);
      }
    } catch (e) {
      Utils.toast('设置免打扰失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<V2TimConversation> conversionList =
        Provider.of<ConversationListProvider>(
      context,
      listen: true,
    ).conversationList;

    if (conversionList.isEmpty) {
      return Center(
        child: Text(
          "暂无会话",
          style: TextStyle(
            color: CommonColors.getTextWeakColor(),
          ),
        ),
      );
    }
    List<V2TimConversation> finalList = conversionList.where((item) {
      if (item.userID != null) {
        return true;
      }
      if (item.groupID != null) {
        return !item.groupID!.contains("im_discuss_");
      }
      return true;
    }).toList();
    return ListView(
      children: finalList.map((e) {
        return Container(
          height: CommonUtils.adaptHeight(145),
          color: e.isPinned ?? false ? const Color(0xFFF4F4F4) : Colors.white,
          child: Slidable(
            key: Key(e.conversationID),
            actionPane: const SlidableDrawerActionPane(),
            actionExtentRatio: 0.2,
            child: ConversionItem(
              conversation: e,
            ),
            secondaryActions: <Widget>[
              SlideAction(
                child: Text(
                    CommonUtils.isReceivingAndNotifingMessage(e.recvOpt!)
                        ? '免打扰'
                        : '取消免打扰',
                    style: const TextStyle(color: Colors.white)),
                color: const Color(0xFF006EFF),
                onTap: () {
                  toggleDoNotDisturbConversation(e);
                },
                closeOnTap: true,
              ),
              SlideAction(
                child: e.isPinned ?? false
                    ? const Text('取消置顶', style: TextStyle(color: Colors.white))
                    : const Text('置顶', style: TextStyle(color: Colors.white)),
                color: const Color(0xFFFF9C19),
                onTap: () {
                  togglePinConversation(e);
                },
                closeOnTap: true,
              ),
              SlideAction(
                child: const Text('删除', style: TextStyle(color: Colors.white)),
                color: const Color(0xFFFF584C),
                onTap: () {
                  deleteConversation(e);
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
  const ConversionItem({
    Key? key,
    required this.conversation,
  }) : super(key: key);
  final V2TimConversation conversation;
  // 跳转到Conversation内
  directToConversationPage(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Conversion(conversation.conversationID,
            lastDraftText: conversation.draftText),
      ),
    );
  }

  String formatTime() {
    if (conversation.lastMessage == null) {
      return "";
    }
    int timestamp = conversation.lastMessage!.timestamp! * 1000;
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    if (now.day == time.day) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
    } else {
      return "${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
    }
  }

  String checkFaceUrl(String? url) {
    String faceUrl = url ?? "";
    RegExp checkUrl =
        // ignore: unnecessary_string_escapes
        RegExp("\S{0,}.png|.jpg|.jpeg|.gif", caseSensitive: false);

    return checkUrl.hasMatch(faceUrl) ? faceUrl : "";
  }

  String? getFaceUrl() {
    return checkFaceUrl(conversation.faceUrl).isEmpty
        ? conversation.type == 1
            ? 'images/person.png'
            : 'images/logo.png'
        : conversation.faceUrl;
  }

  /*
   展示lastMessage
  */
  Widget disPlayLastMessage() {
    return conversation.draftText != null
        ? displayDraftMessage()
        : disPlayConversationLastMessage();
  }

  Widget displayDraftMessage() {
    return Row(children: [
      const Text(
        "[草稿] ",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
      ),
      Text(
        conversation.draftText ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: TextStyle(
          color: CommonColors.getTextWeakColor(),
          fontSize: 14,
        ),
      )
    ]);
  }

  Widget disPlayConversationLastMessage() {
    String res =
        !CommonUtils.isReceivingAndNotifingMessage(conversation.recvOpt!) &&
                conversation.unreadCount! > 0
            ? "[${conversation.unreadCount!}条]"
            : "";
    // 写为fail，为空时会出现问题
    int status = conversation.lastMessage?.status ?? -1;

    int elemType = conversation.lastMessage?.elemType ?? -1;
    switch (elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        res += "[自定义消息]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        res += "[表情]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        res += "[文件]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        res += "[群提示]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        res += "[图片]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        res += "[位置]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        res += "[合并消息]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_NONE:
        res += "[NONE]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        res += "[语音]";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        res += conversation.lastMessage!.textElem!.text!;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        res += "[视频]";
        break;
      default:
        res += "";
        break;
    }
    // 发送中
    if (status == MessageStatus.V2TIM_MSG_STATUS_SENDING) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.autorenew,
            color: Colors.grey,
            size: 16,
          ),
          Text(
            ' $res',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: TextStyle(
              color: CommonColors.getTextWeakColor(),
              fontSize: 14,
            ),
          )
        ],
      );
    } else if (status == MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL) {
      return Row(
        children: [
          Container(
            width: 14,
            height: 14,
            alignment: Alignment.center,
            child: const Text(
              "!",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
          Text(
            ' $res',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: TextStyle(
              color: CommonColors.getTextWeakColor(),
              fontSize: 14,
            ),
          )
        ],
      );
    } else {
      return Text(
        res,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: TextStyle(
          color: CommonColors.getTextWeakColor(),
          fontSize: 14,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {directToConversationPage(context)},
      child: SizedBox(
        height: 74,
        child: Row(
          children: [
            // 头像区域
            SizedBox(
              width: 70,
              height: 78,
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: PhysicalModel(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4.8),
                  clipBehavior: Clip.antiAlias,
                  child: Avatar(
                    width: CommonUtils.adaptWidth(96),
                    height: CommonUtils.adaptHeight(96),
                    radius: 0,
                    avtarUrl: getFaceUrl(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 74,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFEDEDED),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: CommonUtils.adaptHeight(46),
                      margin: const EdgeInsets.only(top: 11),
                      child: Row(
                        children: [
                          // 展示用户名区域
                          Expanded(
                            child: Text(
                              conversation.showName!,
                              style: TextStyle(
                                color: hexToColor("111111"),
                                fontSize: CommonUtils.adaptFontSize(30),
                                height: 1,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 消息时间区域
                          Container(
                            child: Text(
                              formatTime(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(int.parse('b0b0b0', radix: 16))
                                    .withAlpha(255),
                                fontSize: CommonUtils.adaptFontSize(28),
                              ),
                            ),
                            width: 105,
                            padding: const EdgeInsets.only(right: 16),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                      margin: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          // 展示lastMessage or draftMessage
                          Expanded(child: disPlayLastMessage()),
                          Container(
                            child: !CommonUtils.isReceivingAndNotifingMessage(
                                    conversation.recvOpt!)
                                ? Image.asset(
                                    'images/unmute_bell.png',
                                    width: 16,
                                    height: 16,
                                  )
                                : conversation.unreadCount! > 0
                                    ? PhysicalModel(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                          color: CommonColors.getReadColor(),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                conversation.unreadCount! > 99
                                                    ? '99+'
                                                    : conversation.unreadCount!
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                textWidthBasis:
                                                    TextWidthBasis.parent,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ],
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                              4, 0, 4, 0),
                                        ),
                                      )
                                    : null,
                            constraints: const BoxConstraints(
                                minWidth: 18, maxWidth: 32),
                            height: 18,
                            margin: const EdgeInsets.only(right: 16),
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
