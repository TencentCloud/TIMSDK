import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/sendMsg.dart';
import 'package:tencent_im_sdk_plugin_example/provider/currentMessageList.dart';

class ConversationInner extends StatefulWidget {
  ConversationInner(this.conversationID, this.type, this.userID, this.groupID);
  String conversationID;
  int type;
  String? userID;
  String? groupID;
  @override
  State<StatefulWidget> createState() => ConversationInnerState();
}

class ConversationInnerState extends State<ConversationInner> {
  List<V2TimMessage>? currentMessageList = List.empty(growable: true);
  ScrollController scrollController =
      new ScrollController(initialScrollOffset: 0.0);
  void initState() {
    super.initState();
  }

  getHistroyList(currentMessageMap, messageList) {
    if (currentMessageMap != null) {
      messageList = currentMessageMap[widget.conversationID];
    }
    if (messageList == null) {
      return Center(
        child: LoadingIndicator(
          indicatorType: Indicator.lineSpinFadeLoader,
          color: Colors.black26,
        ),
      );
    }

    bool hasNoRead = messageList.any((element) {
      return !element.isSelf && !element.isRead;
    });
    setState(() {
      currentMessageList = messageList;
    });
    if (widget.type == 2) {
      // 如果有未读，设置成已读，否者会触发
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .markGroupMessageAsRead(groupID: widget.groupID!)
          .then((res) {
        if (res.code == 0) {
          print("设置群组会话已读 成功");
        } else {
          print("设置群组会话已读 失败");
        }
      });
    }
    if (hasNoRead) {
      if (widget.type == 1) {
        print("设置个人会话已读");
        print(
            "设置个人会话已读设置个人会话已读设置个人会话已读设置个人会话已读设置个人会话已读设置个人会话已读设置个人会话已读设置个人会话已读设置个人会话已读设置个人会话已读");
        TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .markC2CMessageAsRead(userID: widget.userID!)
            .then((res) {
          if (res.code == 0) {
            print("设置个人会话已读 成功");
          } else {
            print("设置个人会话已读 失败");
          }
        });
      }
    } else {
      print("没有未读");
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<V2TimMessage>> currentMessageMap =
        Provider.of<CurrentMessageListModel>(context).messageMap;
    List<V2TimMessage> messageList = List.empty(growable: true);
    getHistroyList(currentMessageMap, messageList);
    print("添加了一条发送中的消息 刷新聊天列表");
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: scrollController,
        reverse: currentMessageList!.length > 6, //注意设置为反向
        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          children:
              (currentMessageList == null || currentMessageList!.length == 0)
                  ? [Container()]
                  : currentMessageList!.map(
                      (e) {
                        return SendMsg(e, Key(e.msgID ?? ""));
                      },
                    ).toList(),
        ),
      ),
    );
  }
}
