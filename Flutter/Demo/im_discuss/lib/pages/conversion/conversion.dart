import 'dart:async';

import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/common/message_viewer.dart';
import 'package:discuss/config.dart';
import 'package:discuss/models/emoji/emoji.dart';
import 'package:discuss/pages/conversationinfo/conversationinfo.dart';
import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/provider/keybooadshow.dart';
import 'package:discuss/utils/emojiData.dart';
import 'package:discuss/utils/imsdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/contact/choosecontact.dart';
import 'package:discuss/pages/conversion/component/conversationinner.dart';
import 'package:discuss/pages/conversion/component/msginput.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:discuss/pages/userProfile/userProfile.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:discuss/utils/toast.dart';

import 'component/addAdvanceMsg.dart';

class Conversion extends StatefulWidget {
  const Conversion(this.conversationID, {this.lastDraftText, Key? key})
      : super(key: key);
  final String conversationID;
  // 上一次的草稿消息
  final String? lastDraftText;
  @override
  State<StatefulWidget> createState() => ConversionState();
}

class ConversionState extends State<Conversion> with WidgetsBindingObserver {
  List<V2TimMessage> msgList = List.empty(growable: true);

  late Icon righTopIcon;
  bool isreverse = true;
  bool recordBackStatus = true; // 录音键按下时无法返回
  List<V2TimMessage> currentMessageList = List.empty(growable: true);
  bool isDisscuss = false;
  bool isTopic = false;
  late V2TimConversation conversation;
  bool hasConversation = false;
  List<V2TimMessage> topicAboutMessageList = [];
  V2TimUserFullInfo? creatorInfo;
  double faceContainerHeight = 180;
  double advanceContainerHeight = 56;
  double bottomContainerHeight = 0;
  // 触摸开始时的值
  double startDx = 0;
  // 触摸结束时的值
  double endDx = 0;
  // bool touchMoveFinish = false;

  @override
  void initState() {
    super.initState();
    getConversion();
    // Provider.of<KeyBoradModel>(context).setDraftText(widget.lastDraftText);
  }

  @override
  void dispose() {
    //销毁
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  Future<void> _getMessageList([String? lastMsgID]) async {
    if (conversation.type == ConversationType.V2TIM_C2C) {
      await getC2CMessageList(conversation.userID!, lastMsgID);
    } else {
      await getGroupMessageList(conversation.groupID!, lastMsgID);
    }
  }

  openProfile(context) {
    int type = conversation.type!;
    String id = conversation.type == ConversationType.V2TIM_C2C
        ? conversation.userID!
        : conversation.groupID!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => type == ConversationType.V2TIM_C2C
            ? UserProfile(id)
            : ConversationInfo(id, type),
      ),
    );
  }

  getC2CMessageList(String userID, [String? lastMsgID]) async {
    V2TimValueCallback<List<V2TimMessage>> res = lastMsgID == null
        ? await IMSDK.getC2CHistoryMessageList(
            userID: userID,
            count: 20,
          )
        : await IMSDK.getC2CHistoryMessageList(
            userID: userID,
            count: 20,
            lastMsgID: lastMsgID,
          );
    if (res.code == 0) {
      if (res.data!.isNotEmpty) {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .addMessage('c2c_$userID', res.data!);
      } else {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .setMessageListFin('c2c_$userID');
      }
    }
  }

  getGroupMessageList(String groupID, [String? lastMsgID]) async {
    V2TimValueCallback<List<V2TimMessage>> res = lastMsgID == null
        ? await IMSDK.getGroupHistoryMessageList(groupID: groupID, count: 20)
        : await IMSDK.getGroupHistoryMessageList(
            groupID: groupID, count: 20, lastMsgID: lastMsgID);
    if (res.code == 0) {
      var data = res.data!;
      if (data.isNotEmpty) {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .addMessage('group_$groupID', data);
      } else {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .setMessageListFin('group_$groupID');
      }
    }
  }

  getConversion() async {
    if (widget.conversationID == '') {
      Utils.toast('参数错误：conversationID');
      return;
    }
    V2TimValueCallback<V2TimConversation> data = await IMSDK.getConversation(
      conversationID: widget.conversationID,
    );
    if (data.code == 0) {
      setState(() {
        hasConversation = true;
        conversation = data.data!;
        if (conversation.type == ConversationType.V2TIM_C2C) {
          righTopIcon = Icon(
            Icons.account_box,
            color: CommonColors.getWitheColor(),
          );
        } else {
          righTopIcon = Icon(
            Icons.supervisor_account,
            color: CommonColors.getWitheColor(),
          );
        }
      });
      if (conversation.type == ConversationType.V2TIM_C2C) {
        getC2CMessageList(conversation.userID!);
      } else {
        getGroupMessageList(conversation.groupID!);
      }
    } else {
      Utils.toast("获取会话信息失败");
      Navigator.pop(context);
    }
  }

  cancelMutilselector() {
    Provider.of<MultiSelect>(context, listen: false).exit();
  }

  deleteMessage() async {
    String selectedId;
    int type = conversation.type!;
    String key;
    if (type == ConversationType.V2TIM_C2C) {
      selectedId = conversation.userID!;
      key = 'c2c_$selectedId';
    } else {
      selectedId = conversation.groupID!;
      key = 'group_$selectedId';
    }
    List<String>? list = Provider.of<MultiSelect>(context, listen: false)
        .selectedIds[selectedId];
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessages(msgIDs: list!);
    if (res.code == 0) {
      Utils.toast("删除成功");
      cancelMutilselector();
      Provider.of<HistoryMessageListProvider>(context, listen: false)
          .deleteMessage(key, list);
    } else {
      Utils.toast("删除失败 ${res.code} ${res.desc}");
    }
  }

  forwardMessage() {
    String selectedId;
    if (conversation.type == ConversationType.V2TIM_GROUP) {
      selectedId = conversation.groupID!;
    } else {
      selectedId = conversation.userID!;
    }
    List<String>? list = Provider.of<MultiSelect>(context, listen: false)
        .selectedIds[selectedId];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseContact(7, list),
      ),
    );
  }

  bool hasSelectct() {
    String selectedId;
    if (conversation.type == ConversationType.V2TIM_GROUP) {
      selectedId = conversation.groupID!;
    } else {
      selectedId = conversation.userID!;
    }
    List<String>? list =
        Provider.of<MultiSelect>(context).selectedIds[selectedId];
    if (list == null) {
      return false;
    } else {
      return list.isNotEmpty;
    }
  }

  void keyboardHide() {
    Provider.of<KeyBoradModel>(context, listen: false).setBottomConToEmpty();

    Provider.of<KeyBoradModel>(context, listen: false).keyBoardUnfocus();
  }

  setBottomContainerHeight(double height) {
    setState(() {
      bottomContainerHeight = height;
    });
  }

  Widget getBottomContainer(
      String currStatus, String toUser, int type, BuildContext context) {
    switch (currStatus) {
      case "keyboardContainer":
        {
          return Container();
        }

      case "advanceMsgContainer":
        {
          return AdvanceMsgComp(toUser, conversation.type!);
        }

      case "faceContainner":
        {
          // SingleChildScrollView为了保证渲染时不报错
          // 表情区域下的发送小按钮在这里
          return SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              faceContainer(toUser, conversation.type!),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    child: Container(
                        margin: const EdgeInsets.only(right: 15, top: 5),
                        height: MediaQuery.of(context).padding.bottom,
                        child: ElevatedButton(
                          child: const Text("发送"),
                          onPressed: () {
                            try {
                              String text = Provider.of<KeyBoradModel>(context,
                                      listen: false)
                                  .inputController
                                  .text;
                              Provider.of<KeyBoradModel>(context, listen: false)
                                  .triggerSubmitTextMessage(text, null);
                            } catch (err) {
                              Utils.toast("Provider这里报错了$err");
                            }
                          },
                        )),
                  )
                ],
              )
            ],
          ));
        }

      case "empty":
        {
          return Container();
        }

      default:
        {
          return Container();
        }
    }
  }

  double getHeight(type) {
    if (type == "faceContainner") {
      return 240;
    } else if (type == "advanceMsgContainer") {
      return 220;
    } else if (type == "keyboardContainer") {
      // 获取键盘高度
      return MediaQuery.of(context).viewInsets.bottom;
    } else {
      return 0;
    }
  }

  void setDraftHandler() async {
    String? text =
        Provider.of<KeyBoradModel>(context, listen: false).inputController.text;
    // text设置为""，取消草稿
    String conversationID = widget.conversationID;
    await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationDraft(conversationID: conversationID, draftText: text);
  }

  // 表情组件
  Widget faceContainer(toUser, type) {
    close() {}

    return Container(
      height: 180,
      color: hexToColor('ededed'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
        ),
        children: emojiData.map(
          (e) {
            var item = Emoji.fromJson(e);

            return EmojiItem(
              name: item.name,
              unicode: item.unicode,
              toUser: toUser,
              type: type,
              close: close,
            );
          },
        ).toList(),
      ),
    );
  }

// 节流
  throttle(Function func, int milliseconds) {
    bool enable = true;
    return (val) {
      if (enable == true) {
        enable = false;
        Future.delayed(Duration(milliseconds: milliseconds), () {
          enable = true;
          func();
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!hasConversation) {
      return Scaffold(
        appBar: AppBar(),
        body: Container(),
      );
    }
    String toUser = conversation.type == ConversationType.V2TIM_C2C
        ? conversation.userID!
        : conversation.groupID!;
    bool isopen = Provider.of<MultiSelect>(context).isopen;
    bool recordBackStatus =
        Provider.of<KeyBoradModel>(context).recordBackStatus;

    bool hasSelect = hasSelectct();
    return WillPopScope(
        onWillPop: () async => recordBackStatus,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            shadowColor: hexToColor("ececec"),
            elevation: 1,
            toolbarHeight: 44,
            iconTheme: const IconThemeData(
              color: Colors.black,
              size: 24,
            ),
            leading: isopen
                ?
                // 多选发送消息时的取消
                TextButton(
                    onPressed: cancelMutilselector,
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                :
                // 返回图标
                IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                    ),
                    // 返回Home事件
                    onPressed: () => {
                      setDraftHandler(),
                      keyboardHide(),
                      Navigator.pop(context)
                    },
                  ),
            title: Text(
              conversation.showName!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: IMDiscussConfig.appBarTitleFontSize,
              ),
            ),
            backgroundColor: CommonColors.getThemeColor(),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.more_horiz_outlined,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () {
                  recordBackStatus ? openProfile(context) : () {}();
                },
              )
            ],
          ),
          body: Container(
              color: hexToColor("EBF0F6"),
              child: SafeArea(
                bottom: true,
                child: Column(
                  children: [
                    if (isTopic && topicAboutMessageList.isNotEmpty)
                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              "---- ${creatorInfo != null ? creatorInfo!.nickName ?? creatorInfo!.userID : ''}创建的话题 ----",
                              style: TextStyle(
                                  color: CommonColors.getTextWeakColor()),
                            ),
                            MessageViewer(
                              messageList: topicAboutMessageList,
                            )
                          ],
                        ),
                      ),

                    Expanded(
                      child: GestureDetector(
                          onTap: () => {
                                keyboardHide(),
                              },
                          onHorizontalDragStart: (DragStartDetails e) {
                            startDx = e.localPosition.dx;
                          },
                          onHorizontalDragUpdate: (DragUpdateDetails e) {
                            endDx = e.localPosition.dx;
                          },
                          // debounce((DragUpdateDetails e) {}),
                          onHorizontalDragEnd: (DragEndDetails e) {
                            if ((startDx - endDx).abs() > 60) {
                              Navigator.pop(context);
                            }
                            startDx = 0;
                            endDx = 0;
                            // print("结束");
                            // print(e.velocity.pixelsPerSecond);
                            // touchMoveFinish = true;
                          },
                          // GestureDetector的垂直手势监听冲突，采用监听实现滑动监听
                          child: Listener(
                            onPointerDown: throttle(keyboardHide, 50),
                            child: Container(
                              color: Colors.white,
                              child: ConversationInner(
                                conversation: conversation,
                                getMessageList: _getMessageList,
                              ),
                            ),
                          )),
                    ),

                    if (isopen)
                      // 聊天消息多选时，消息的操作栏
                      Container(
                        height: 75,
                        decoration: BoxDecoration(
                          color: hexToColor("EBF0F6"),
                          border: const Border(
                            top: BorderSide(
                              width: 1,
                              color: Colors.black12,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  onPressed: hasSelect ? deleteMessage : null,
                                  icon: const Icon(
                                    Icons.delete_forever_outlined,
                                    color: Colors.red,
                                  ),
                                  tooltip: "删除",
                                ),
                                const Text(
                                  "删除",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: hasSelect ? forwardMessage : null,
                                  icon: const Icon(
                                    Icons.shortcut_outlined,
                                    color: Colors.green,
                                  ),
                                  tooltip: "转发",
                                ),
                                const Text(
                                  "转发",
                                  style: TextStyle(
                                    color: Colors.green,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      MsgInput(toUser, conversation.type!, recordBackStatus,
                          lastDraftText: widget.lastDraftText),
                    // 表情/高级消息的切换区域
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      color: hexToColor("EBF0F6"),
                      // height的改变和下方组件的渲染需要分开写（setState和组件返回不能同时进行）
                      height: getHeight(
                          Provider.of<KeyBoradModel>(context).bottomContainer),
                      child: getBottomContainer(
                        Provider.of<KeyBoradModel>(context).bottomContainer,
                        toUser,
                        conversation.type!,
                        context,
                      ),
                    )
                  ],
                ),
              )),
        ));
  }
}
