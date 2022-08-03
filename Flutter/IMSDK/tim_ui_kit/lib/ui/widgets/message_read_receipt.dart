import 'package:flutter/material.dart';

// ignore: unused_import
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/time_ago.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_face_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_file_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_image_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_sound_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_video_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_merger_message_elem.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class MessageReadReceipt extends StatefulWidget {
  final V2TimMessage messageItem;
  final int unreadCount;
  final int readCount;
  final void Function(String userID)? onTapAvatar;

  const MessageReadReceipt(
      {Key? key,
      required this.messageItem,
      required this.unreadCount,
      required this.readCount,
      this.onTapAvatar})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessageReadReceiptState();
}

class _MessageReadReceiptState extends TIMUIKitState<MessageReadReceipt> {
  final TUIChatViewModel _model = serviceLocator<TUIChatViewModel>();
  bool readMemberIsFinished = false;
  bool unreadMemberIsFinished = false;
  int readMemberListNextSeq = 0;
  int unreadMemberListNextSeq = 0;
  List<V2TimGroupMemberInfo> readMemberList = [];
  List<V2TimGroupMemberInfo> unreadMemberList = [];
  int currentIndex = 0;

  _getUnreadMemberList() async {
    final unReadMemberRes = await _model.getGroupMessageReadMemberList(
        widget.messageItem.msgID!,
        GetGroupMessageReadMemberListFilter
            .V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD,
        unreadMemberListNextSeq);
    if (unReadMemberRes.code == 0) {
      final res = unReadMemberRes.data;
      if (res != null) {
        unreadMemberList = [...unreadMemberList, ...res.memberInfoList];
        unreadMemberIsFinished = res.isFinished;
        unreadMemberListNextSeq = res.nextSeq;
      }
    }
    setState(() {});
  }

  _getReadMemberList() async {
    final readMemberRes = await _model.getGroupMessageReadMemberList(
      widget.messageItem.msgID!,
      GetGroupMessageReadMemberListFilter
          .V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ,
      readMemberListNextSeq,
    );
    if (readMemberRes.code == 0) {
      final res = readMemberRes.data;
      if (res != null) {
        readMemberList = [...readMemberList, ...res.memberInfoList];
        readMemberIsFinished = res.isFinished;
        readMemberListNextSeq = res.nextSeq;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getReadMemberList();
    _getUnreadMemberList();
  }

  Widget _getMsgItem(V2TimMessage message) {
    final type = message.elemType;
    final isFromSelf = message.isSelf ?? false;

    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return Text(TIM_t("[自定义]"));
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return TIMUIKitSoundElem(
            message: message,
            soundElem: message.soundElem!,
            msgID: message.msgID ?? "",
            isFromSelf: isFromSelf,
            localCustomInt: message.localCustomInt);
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return Text(
          message.textElem!.text!,
          softWrap: true,
          style: const TextStyle(fontSize: 16),
        );
      // return Text(message.textElem!.text!);
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return TIMUIKitFaceElem(
            isShowJump: false,
            path: message.faceElem?.data ?? "",
            message: message);
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return TIMUIKitFileElem(
          message: message,
          messageID: message.msgID,
          fileElem: message.fileElem,
          isSelf: isFromSelf,
          isShowJump: false,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIMUIKitImageElem(
          message: message,
          isFrom: "merger",
          key: Key("${message.seq}_${message.timestamp}"),
        );
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIMUIKitVideoElem(message, isFrom: "merger");
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return Text(TIM_t("[位置]"));
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIMUIKitMergerElem(
            isShowJump: false,
            message: message,
            mergerElem: message.mergerElem!,
            isSelf: isFromSelf,
            messageID: message.msgID!);
      default:
        return Text(TIM_t("未知消息"));
    }
  }

  _getShowName(V2TimGroupMemberInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  Widget _memberItemBuilder(V2TimGroupMemberInfo item, TUITheme theme) {
    final faceUrl = item.faceUrl ?? '';
    final showName = _getShowName(item);
    return InkWell(
      onTap: () {
        if (widget.onTapAvatar != null) {
          widget.onTapAvatar!(item.userID!);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 12),
              child: Avatar(faceUrl: faceUrl, showName: showName),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 10, bottom: 19, right: 28),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.weakDividerColor ??
                              CommonColor.weakDividerColor))),
              child: Text(
                showName,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final option1 = widget.readCount;
    final option2 = widget.unreadCount;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              TIM_t("消息详情"),
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            shadowColor: theme.weakDividerColor,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                  theme.primaryColor ?? CommonColor.primaryColor
                ]),
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            )),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(MessageUtils.getDisplayName(widget.messageItem)),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          TimeAgo().getTimeForMessage(
                              widget.messageItem.timestamp ?? 0),
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 12, color: theme.weakTextColor),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    _getMsgItem(widget.messageItem)
                  ],
                ),
              ),
              Container(
                height: 8,
                color: theme.weakBackgroundColor,
              ),
              Row(
                // direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        currentIndex = 0;
                        setState(() {});
                      },
                      child: Container(
                        height: 50.0,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 2,
                                    color: currentIndex == 0
                                        ? theme.primaryColor!
                                        : Colors.white))),
                        child: Text(
                          TIM_t_para("{{option1}}人已读", "$option1人已读")(
                              option1: option1),
                          style: TextStyle(
                            color: currentIndex != 0
                                ? theme.weakTextColor
                                : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        currentIndex = 1;
                        setState(() {});
                      },
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 50.0,
                        padding: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 2,
                                    color: currentIndex == 1
                                        ? theme.primaryColor!
                                        : Colors.white))),
                        child: Text(
                          TIM_t_para("{{option2}}人未读", "$option2人未读")(
                              option2: option2),
                          style: TextStyle(
                            color: currentIndex != 1
                                ? theme.weakTextColor
                                : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 1,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.weakDividerColor ??
                                CommonColor.weakDividerColor))),
              ),
              Expanded(
                  child: IndexedStack(
                index: currentIndex,
                children: [
                  ListView.builder(
                      itemCount: readMemberList.length,
                      itemBuilder: (context, index) {
                        if (!readMemberIsFinished &&
                            index == readMemberList.length - 5) {
                          _getReadMemberList();
                        }
                        return _memberItemBuilder(readMemberList[index], theme);
                      }),
                  ListView.builder(
                      itemCount: unreadMemberList.length,
                      itemBuilder: (context, index) {
                        if (!unreadMemberIsFinished &&
                            index == unreadMemberList.length - 5) {
                          _getUnreadMemberList();
                        }
                        return _memberItemBuilder(
                            unreadMemberList[index], theme);
                      }),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
