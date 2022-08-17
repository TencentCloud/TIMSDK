import 'package:example/i18n/i18n_utils.dart';
import 'package:flutter/material.dart';
import 'package:example/provider/event.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class AddEventListener extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddEventListenerState();
}

class AddEventListenerState extends State<AddEventListener> {
  late V2TimSimpleMsgListener simpleMsgListener;
  late V2TimAdvancedMsgListener advancedMsgListener;
  late V2TimSignalingListener signalingListener;
  late V2TimConversationListener conversationListener;
  late V2TimFriendshipListener friendshipListener;
  late V2TimGroupListener groupListener;
  addEventListener() async {
    simpleMsgListener = new V2TimSimpleMsgListener(
      onRecvC2CCustomMessage:
          Provider.of<Event>(context, listen: false).onRecvC2CCustomMessage,
      onRecvC2CTextMessage:
          Provider.of<Event>(context, listen: false).onRecvC2CTextMessage,
      onRecvGroupCustomMessage:
          Provider.of<Event>(context, listen: false).onRecvGroupCustomMessage,
      onRecvGroupTextMessage:
          Provider.of<Event>(context, listen: false).onRecvGroupTextMessage,
    );

    groupListener = new V2TimGroupListener(
      onApplicationProcessed:
          Provider.of<Event>(context, listen: false).onApplicationProcessed,
      onGrantAdministrator:
          Provider.of<Event>(context, listen: false).onGrantAdministrator,
      onGroupAttributeChanged:
          Provider.of<Event>(context, listen: false).onGroupAttributeChanged,
      onGroupCreated: Provider.of<Event>(context, listen: false).onGroupCreated,
      onGroupDismissed:
          Provider.of<Event>(context, listen: false).onGroupDismissed,
      onGroupInfoChanged:
          Provider.of<Event>(context, listen: false).onGroupInfoChanged,
      onGroupRecycled:
          Provider.of<Event>(context, listen: false).onGroupRecycled,
      onMemberEnter: Provider.of<Event>(context, listen: false).onMemberEnter,
      onMemberInfoChanged:
          Provider.of<Event>(context, listen: false).onMemberInfoChanged,
      onMemberInvited:
          Provider.of<Event>(context, listen: false).onMemberInvited,
      onMemberKicked: Provider.of<Event>(context, listen: false).onMemberKicked,
      onMemberLeave: Provider.of<Event>(context, listen: false).onMemberLeave,
      onQuitFromGroup:
          Provider.of<Event>(context, listen: false).onQuitFromGroup,
      onReceiveJoinApplication:
          Provider.of<Event>(context, listen: false).onReceiveJoinApplication,
      onReceiveRESTCustomData:
          Provider.of<Event>(context, listen: false).onReceiveRESTCustomData,
      onRevokeAdministrator:
          Provider.of<Event>(context, listen: false).onRevokeAdministrator,
          onTopicCreated: Provider.of<Event>(context, listen: false).onTopicCreated,
          onTopicDeleted: Provider.of<Event>(context, listen: false).onTopicDeleted,
          onTopicInfoChanged: Provider.of<Event>(context, listen: false).onTopicInfoChanged,
    );
    advancedMsgListener = new V2TimAdvancedMsgListener(
      onRecvC2CReadReceipt:
          Provider.of<Event>(context, listen: false).onRecvC2CReadReceipt,
      onRecvMessageRevoked:
          Provider.of<Event>(context, listen: false).onRecvMessageRevoked,
      onRecvNewMessage:
          Provider.of<Event>(context, listen: false).onRecvNewMessage,
      onSendMessageProgress:
          Provider.of<Event>(context, listen: false).onSendMessageProgress,
      onRecvMessageReadReceipts: Provider.of<Event>(context, listen: false).onRecvMessageReadReceipts,
      onRecvMessageModified:  Provider.of<Event>(context, listen: false).onRecvMessageModified,
    );

    signalingListener = new V2TimSignalingListener(
      onInvitationCancelled:
          Provider.of<Event>(context, listen: false).onInvitationCancelled,
      onInvitationTimeout:
          Provider.of<Event>(context, listen: false).onInvitationTimeout,
      onInviteeAccepted:
          Provider.of<Event>(context, listen: false).onInviteeAccepted,
      onInviteeRejected:
          Provider.of<Event>(context, listen: false).onInviteeRejected,
      onReceiveNewInvitation:
          Provider.of<Event>(context, listen: false).onReceiveNewInvitation,
    );

    conversationListener = new V2TimConversationListener(
      onConversationChanged:
          Provider.of<Event>(context, listen: false).onConversationChanged,
      onNewConversation:
          Provider.of<Event>(context, listen: false).onNewConversation,
      onSyncServerFailed:
          Provider.of<Event>(context, listen: false).onSyncServerFailed,
      onSyncServerFinish:
          Provider.of<Event>(context, listen: false).onSyncServerFinish,
      onSyncServerStart:
          Provider.of<Event>(context, listen: false).onSyncServerStart,
          onConversationGroupCreated: Provider.of<Event>(context, listen: false).onConversationGroupCreated,
          onConversationGroupDeleted: Provider.of<Event>(context, listen: false).onConversationGroupDeleted,
          onConversationGroupNameChanged: Provider.of<Event>(context, listen: false).onConversationGroupNameChanged,
          onConversationsAddedToGroup: Provider.of<Event>(context, listen: false).onConversationsAddedToGroup,
          onConversationsDeletedFromGroup: Provider.of<Event>(context, listen: false).onConversationsDeletedFromGroup,
          
    );

    friendshipListener = new V2TimFriendshipListener(
      onFriendApplicationListAdded: Provider.of<Event>(context, listen: false)
          .onFriendApplicationListAdded,
      onFriendInfoChanged:
          Provider.of<Event>(context, listen: false).onFriendInfoChanged,
    );
    //注册简单消息监听器
    // ignore: deprecated_member_use
    await TencentImSDKPlugin.v2TIMManager.addSimpleMsgListener(
      listener: simpleMsgListener,
    );
    //注册群组消息监听器
    await TencentImSDKPlugin.v2TIMManager.addGroupListener(
      listener: groupListener,
    );
    //注册高级消息监听器
    await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .addAdvancedMsgListener(
          listener: advancedMsgListener,
        );
    //注册信令消息监听器
    await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .addSignalingListener(
          listener: signalingListener,
        );
    //注册会话监听器
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .addConversationListener(
          listener: conversationListener,
        );
    //注册关系链监听器
    await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .addFriendListener(
          listener: friendshipListener,
        );
  }

  removeSimpleMsgListener() async {
    await TencentImSDKPlugin.v2TIMManager
        .removeSimpleMsgListener(listener: simpleMsgListener);
  }

  removeAllSimpleMsgListener() async {
    await TencentImSDKPlugin.v2TIMManager.removeSimpleMsgListener();
  }

  removeAdvanceMsgListener() async {
    await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .removeAdvancedMsgListener(listener: advancedMsgListener);
  }

  removeAllAdvanceMsgListener() async {
    await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .removeAdvancedMsgListener();
  }

  removeSignalingListener() async {
    await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .removeSignalingListener(listener: signalingListener);
  }

  removeAllSignalingListener() async {
    await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .removeSignalingListener();
  }

  removeGroupListener() async {
    await TencentImSDKPlugin.v2TIMManager.removeGroupListener();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          new ElevatedButton(
            onPressed: addEventListener,
            child: Text(imt("注册事件")),
          ),
          new ElevatedButton(
            onPressed: removeSimpleMsgListener,
            child: Text(imt("注销simpleMsgListener事件")),
          ),
          new ElevatedButton(
            onPressed: removeAllSimpleMsgListener,
            child: Text(imt("注销所有simpleMsgListener事件")),
          ),
          new ElevatedButton(
              onPressed: removeAdvanceMsgListener,
              child: Text(imt("注销advanceMsgListener"))),
          new ElevatedButton(
              onPressed: removeAllAdvanceMsgListener,
              child: Text(imt("注销所有advanceMsgListener"))),
          new ElevatedButton(
              onPressed: removeSignalingListener,
              child: Text(imt("注销signalingListener"))),
          new ElevatedButton(
            onPressed: removeAllSignalingListener,
            child: Text(
              imt("注销所有signalingListener"),
            ),
          ),
          new ElevatedButton(
            onPressed: removeGroupListener,
            child: Text(
              imt("注销gruopListener"),
            ),
          ),
        ],
      ),
    );
  }
}
