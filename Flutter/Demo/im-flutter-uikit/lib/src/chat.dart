import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:timuikit/src/create_topic.dart';
import 'package:timuikit/src/group_profile.dart';
import 'package:timuikit/src/user_profile.dart';
import 'package:timuikit/utils/discuss.dart';
import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';

import 'topic.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class Chat extends StatefulWidget {
  final V2TimConversation selectedConversation;

  const Chat({Key? key, required this.selectedConversation}) : super(key: key);

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

  String? _getConvID() {
    return widget.selectedConversation.type == 1
        ? widget.selectedConversation.userID
        : widget.selectedConversation.groupID;
  }

  isValidateDisscuss(String _groupID) async {
    if (!_groupID.contains("im_discuss_")) {
      return;
    }
    Map<String, dynamic> data = await DisscussApi.isValidateDisscuss(
      imGroupId: _groupID,
    );
    setState(() {
      isDisscuss = data['data']['isDisscuss'];
      isTopic = data['data']['isTopic'];
    });
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

  _openTopicPage(String groupID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Topic(groupID),
      ),
    );
  }

  List<Map<String, dynamic>> handleTopicActionList = [
    {"name": imt("结束话题"), "type": "0"},
    {"name": imt("置顶话题"), "type": "1000"}
  ];

  handleTopic(BuildContext context, String type, String groupID) async {
    Map<String, dynamic> res = await DisscussApi.updateTopicStatus(
      imGroupId: groupID,
      status: type,
    );
    if (res['code'] == 0) {
      Toast.showToast(
          ToastType.success, type == '0' ? imt("结束成功") : imt("置顶成功"), context);
      Navigator.pop(context);
    } else {
      String errorMessage = res['message'];
      Toast.showToast(ToastType.fail, imt_para("发生错误 {{errorMessage}}", "发生错误 ${errorMessage}")(errorMessage: errorMessage), context);
    }
  }

  messagePopUpMenu(BuildContext context, String groupID) {
    return showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: null,
          actions: handleTopicActionList
              .map(
                (e) => CupertinoActionSheetAction(
                  onPressed: () {
                    handleTopic(context, e['type'], groupID);
                  },
                  child: Text(e['name']),
                  isDefaultAction: false,
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initListener();
    if (widget.selectedConversation.type != ConversationType.V2TIM_C2C) {
      isValidateDisscuss(widget.selectedConversation.groupID!);
    }
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
      exteraTipsActionItemBuilder: (message, tooltip) {
        return Row(
          children: [
            const SizedBox(width: 40),
            InkWell(
              onTap: () {
                tooltip?.close();
                String disscussId;
                if (message.groupID == null) {
                  disscussId = '';
                } else {
                  disscussId = message.groupID!;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTopic(
                        disscussId: disscussId,
                        message: message.textElem?.text ?? '',
                        messageIdList: [message.msgID!]),
                  ),
                );
              },
              child:
                  const TipsActionItem(label: "话题", icon: 'assets/topic.png'),
            )
          ],
        );
      },
      appBarActions: [
        if (isDisscuss)
          SizedBox(
            width: 34,
            child: TextButton(
              onPressed: () {
                _openTopicPage(widget.selectedConversation.groupID!);
              },
              child: const Image(
                width: 34,
                height: 34,
                image: AssetImage('assets/topic.png'),
              ),
            ),
          ),
        if (isTopic)
          IconButton(
            onPressed: () {
              messagePopUpMenu(context, widget.selectedConversation.groupID!);
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.black,
            ),
          ),
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
