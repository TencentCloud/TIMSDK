import 'dart:async';

import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/provider/keybooadshow.dart';
import 'package:discuss/utils/const.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:discuss/pages/conversion/component/sendmsg.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

// ignore: must_be_immutable
class ConversationInner extends StatefulWidget {
  ConversationInner(
      {Key? key, required this.conversation, required this.getMessageList})
      : super(key: key);
  V2TimConversation conversation;
  Future<void> Function([String? lastMsgID]) getMessageList;
  @override
  State<StatefulWidget> createState() => ConversationInnerState();
}

class ConversationInnerState extends State<ConversationInner> {
  ScrollController scrollController = ScrollController();
  late V2TimConversation conversation;
  double fullListHeight = 500;
  double listHeight = 0;
  static final loadingTag =
      V2TimMessage(elemType: Const.V2TIM_ELEM_TYPE_REFRESH); //表尾标记
  @override
  void initState() {
    setState(() {
      conversation = widget.conversation;
    });
    getListFullHeight();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Provider.of<KeyBoradModel>(context, listen: false)
          .setScrollController(scrollController);
    });
    markMessageAsRead();
    super.initState();
  }

  // 选中的消息，当前正在播放
  String selectedMsgId = '';

  void setSelectedMsgId(String msgId) {
    setState(() => {selectedMsgId = msgId});
  }

  getListFullHeight() {
    try {
      double listHeight =
          context.findRenderObject()?.paintBounds.size.height ?? 500;
      setState(() {
        fullListHeight = listHeight;
      });
    } catch (err) {
      Utils.log("获取消息完整列表高度失败 err");
    }
  }

  @override
  didChangeDependencies() {
    conversation = widget.conversation;
    markMessageAsRead();
    super.didChangeDependencies();
  }

  markMessageAsRead() {
    if (conversation.type == ConversationType.V2TIM_C2C) {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .markC2CMessageAsRead(userID: conversation.userID!);
    } else {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .markGroupMessageAsRead(groupID: conversation.groupID!);
    }
  }

  changeReverse(listheight) {}

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return Container();
    }
    // 全部的MessageList
    List<V2TimMessage> currentMessageList =
        Provider.of<HistoryMessageListProvider>(context)
            .getMessageList(conversation.conversationID);
    if (currentMessageList.isEmpty ||
        currentMessageList[0].elemType != Const.V2TIM_ELEM_TYPE_END) {
      currentMessageList.add(loadingTag);
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
          addRepaintBoundaries: true,
          shrinkWrap: true, //如果你不设置
          controller: scrollController,
          reverse: true, //注意设置为反向
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          itemCount: currentMessageList.length,
          addAutomaticKeepAlives: true,
          cacheExtent: 400,
          itemBuilder: (context, index) {
            // 到房间底部了，之后再没数据
            if (currentMessageList[index].elemType ==
                Const.V2TIM_ELEM_TYPE_END) {
              return Container();
            }
            // 到末尾了，更新MsgList
            if (currentMessageList[index].elemType ==
                Const.V2TIM_ELEM_TYPE_REFRESH) {
              // 从接口获取数据
              if (index > 0) {
                if (currentMessageList[index - 1].elemType ==
                    Const.V2TIM_ELEM_TYPE_TIME) {
                  widget.getMessageList(currentMessageList[index - 2].msgID);
                } else {
                  widget.getMessageList(currentMessageList[index - 1].msgID);
                }
              }
              return Container();
            }
            return FrameSeparateWidget(
                index: index,
                placeHolder: Container(
                  color: Colors.white,
                  height: 60,
                ),
                child: SendMsg(
                    message: currentMessageList[index],
                    selectedMsgId: selectedMsgId,
                    setSelectedMsgId: setSelectedMsgId));
          }),
    );
  }
}

class MessageList extends StatefulWidget {
  final List<V2TimMessage> currentMessageList;
  const MessageList({
    Key? key,
    required this.currentMessageList,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => MessageListState();
}

class MessageListState extends State<MessageList> {
  // 选中的消息，当前正在播放
  String selectedMsgId = '';

  void setSelectedMsgId(String msgId) {
    setState(() => {selectedMsgId = msgId});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: (widget.currentMessageList.isEmpty)
            ? [
                Container(),
              ]
            : widget.currentMessageList
                .map(
                  (e) => SendMsg(
                      message: e,
                      selectedMsgId: selectedMsgId,
                      setSelectedMsgId: setSelectedMsgId),
                )
                .toList(),
      ),
    );
  }
}
