import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:timuikit/src/group_profile.dart';
import 'package:timuikit/src/user_profile.dart';

class Chat extends StatefulWidget {
  final V2TimConversation selectedConversation;
  final int? initFindingTimestamp;

  const Chat(
      {Key? key, required this.selectedConversation, this.initFindingTimestamp})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TIMUIKitChatController _timuiKitChatController =
      TIMUIKitChatController();
  bool isDisscuss = false;
  bool isTopic = false;
  String? backRemark;

  String _getTitle() {
    return backRemark ?? widget.selectedConversation.showName ?? "";
  }

  String? _getDraftText() {
    return widget.selectedConversation.draftText;
  }

  String? _getConvID() {
    return widget.selectedConversation.type == 1
        ? widget.selectedConversation.userID
        : widget.selectedConversation.groupID;
  }

  _initListener() async {
    await _timuiKitChatController.removeMessageListener();
    await _timuiKitChatController.setMessageListener();
  }

  _onTapAvatar(String userID) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfile(userID: userID),
        ));
  }

  @override
  void initState() {
    super.initState();
    _initListener();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // _timuiKitChatController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TIMUIKitChat(
      conversationID: _getConvID() ?? '',
      conversationType: widget.selectedConversation.type ?? 0,
      onTapAvatar: _onTapAvatar,
      conversationShowName: _getTitle(),
      initFindingTimestamp: widget.initFindingTimestamp,
      draftText: _getDraftText(),
      // messageItemBuilder: (message) {
      //   if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      //     return const Text(imt("我是自定义文本消息"));
      //   }
      //   if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_VIDEO) {
      //     return const Text(imt("我是自定义视频消息"));
      //   }
      //   if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
      //     return const Text(imt("我是自定义群提示消息"));
      //   }
      //   if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE) {
      //     return const Text(imt("我是自定义图片消息"));
      //   }
      //   return null;
      // },
      appBarActions: [
        IconButton(
            onPressed: () async {
              final conversationType = widget.selectedConversation.type;
              if (conversationType == 1) {
                final userID = widget.selectedConversation.userID;
                // if had remark modifed its will back new remark
                String? newRemark = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(userID: userID!),
                    ));
                setState(() {
                  backRemark = newRemark;
                });
              } else {
                final groupID = widget.selectedConversation.groupID;
                if (groupID != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupProfilePage(
                          groupID: groupID,
                        ),
                      ));
                }
              }
            },
            icon: const Icon(Icons.more_horiz_outlined))
      ],
    );
  }
}
