import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_at_text.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_emoji_panel.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_more_panel.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_send_sound_message.dart';

import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';

class InputTextField extends StatefulWidget {
  final ScrollController listViewController;
  final bool closeKeyboardPanel;

  /// 会话ID
  final String conversationID;

  /// 会话类型
  final int conversationType;

  final String? draftText;

  ///控制滚动条
  final AutoScrollController scrollController;

  final String? hintText;

  final MorePanelConfig? morePanelConfig;

  final Widget Function(
      {void Function() sendTextMessage,
      void Function(int index, String data) sendFaceMessage,
      void Function() deleteText,
      void Function(int unicode) addText})? customStickerPanel;

  const InputTextField(
      {Key? key,
      required this.listViewController,
      required this.closeKeyboardPanel,
      required this.conversationID,
      required this.conversationType,
      this.draftText,
      this.hintText,
      required this.scrollController,
      this.morePanelConfig,
      this.customStickerPanel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool showMore = false;
  bool showSendSoundText = false;
  bool showEmojiPanel = false;
  bool showKeyboard = false;
  late FocusNode focusNode;
  String zeroWidthSpace = '\u200b';
  String lastText = "";
  double lastkeyboardHeight = 0;

  Map<String, V2TimGroupMemberFullInfo> memberInfoMap = {};

  late TextEditingController textEditingController;
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUIConversationViewModel conversationModel =
      serviceLocator<TUIConversationViewModel>();

  listenKeyBoardStatus() {
    final currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // 键盘弹出
    if (currentKeyboardHeight - lastkeyboardHeight > 0) {
      // 保证弹出时showKeyboard为true
      setState(() {
        showKeyboard = true;
      });

      /// 键盘收回
    } else if (currentKeyboardHeight - lastkeyboardHeight < 0) {}

    lastkeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  }

  Widget _getBottomContainer() {
    if (showEmojiPanel) {
      return widget.customStickerPanel != null
          ? widget.customStickerPanel!(
              sendTextMessage: () {
                onEmojiSubmitted();
              },
              sendFaceMessage: onCustomEmojiFaceSubmitted,
              deleteText: () {
                backSpaceText();
              },
              addText: (int unicode) {
                final oldText = textEditingController.text;
                final newText = String.fromCharCode(unicode);
                textEditingController.text = "$oldText$newText";
                // handleSetDraftText();
              },
            )
          : EmojiPanel(onTapEmoji: (unicode) {
              final oldText = textEditingController.text;
              final newText = String.fromCharCode(unicode);
              textEditingController.text = "$oldText$newText";
              // handleSetDraftText();
            }, onSubmitted: () {
              onEmojiSubmitted();
            }, delete: () {
              backSpaceText();
            });
    }

    if (showMore) {
      return MorePanel(
          morePanelConfig: widget.morePanelConfig,
          conversationID: widget.conversationID,
          conversationType: widget.conversationType);
    }

    return Container();
  }

  double _getBottomHeight() {
    listenKeyBoardStatus();
    if (showKeyboard) {
      return MediaQuery.of(context).viewInsets.bottom;
    } else if (showMore || showEmojiPanel) {
      return 248.0;
    }
    // 在文本框多行拓展时增加保护区高度
    else if (textEditingController.text.length >= 46 && showKeyboard == false) {
      return 25;
    } else {
      return 0;
    }
  }

  // // 外部变量closeKeyboardPanel 是否传入
  // bool isCloseKeyboardPanelExist() {
  //   return widget.closeKeyboardPanel == null ? false : true;
  // }

  // // 优先哪外部传递的值
  // bool getKeyBoardShow() {
  //   bool? closeKeyboardPanel = widget.closeKeyboardPanel;
  //   if (closeKeyboardPanel != null) {
  //     if (closeKeyboardPanel == true) {
  //       focusNode.requestFocus();
  //     }
  //     return closeKeyboardPanel;
  //   }
  //   return showKeyboard;
  // }

  _openMore() {
    if (showMore) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }
    setState(() {
      showKeyboard = showMore;
      showEmojiPanel = false;
      showSendSoundText = false;
      showMore = !showMore;
    });
  }

  _openEmojiPanel() {
    if (showEmojiPanel) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }

    setState(() {
      showKeyboard = showEmojiPanel;
      showMore = false;
      showSendSoundText = false;
      showEmojiPanel = !showEmojiPanel;
    });
  }

  String _filterU200b(String text) {
    return text.replaceAll(RegExp(r'\u200b'), "");
  }

  getShowName(message) {
    return message.friendRemark == null || message.friendRemark == ''
        ? message.nickName == null || message.nickName == ''
            ? message.sender
            : message.nickName
        : message.friendRemark;
  }

  handleSetDraftText() async {
    String convID = widget.conversationID;
    String conversationID =
        widget.conversationType == ConversationType.V2TIM_C2C
            ? "c2c_$convID"
            : "group_$convID";
    String text = textEditingController.text;
    String? draftText = _filterU200b(text);

    if (draftText.isEmpty) {
      draftText = null;
    }
    await conversationModel.setConversationDraft(
        conversationID: conversationID, draftText: draftText);
  }

  _buildRepliedMessage() {
    final haveRepliedMessage = model.repliedMessage != null;
    if (haveRepliedMessage) {
      final text =
          "${MessageUtils.getDisplayName(model.repliedMessage!)}: ${MessageUtils.getAbstractMessage(model.repliedMessage!, context)}";
      return Container(
        color: hexToColor("EBF0F6"),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(color: hexToColor("8F96A0"), fontSize: 14),
            ),
            InkWell(
              onTap: () {
                model.setRepliedMessage(null);
              },
              child: SizedBox(
                height: 18,
                width: 18,
                child: Image.asset(
                  'images/clear.png',
                  package: 'tim_ui_kit',
                ),
              ),
            )
          ],
        ),
      );
    }
    return Container();
  }

  backSpaceText() {
    String originalText = textEditingController.text;
    dynamic text;

    if (originalText == zeroWidthSpace) {
      _handleSoftKeyBoardDelete();
      _addDeleteTag();
    } else {
      text = originalText.characters.skipLast(1);
      textEditingController.text = "$text";
      // handleSetDraftText();
    }

    // if (originalText.isNotEmpty) {
    //   text = originalText.characters.skipLast(1);
    //   textEditingController.text = "$text";
    // }
  }

// 和onSubmitted一样，只是保持焦点的不同
  onEmojiSubmitted() {
    final text = textEditingController.text.trim();
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
    if (text != zeroWidthSpace) {
      if (model.repliedMessage != null) {
        MessageUtils.handleMessageError(
            model.sendReplyMessage(
                text: text, convID: widget.conversationID, convType: convType),
            context);
      } else {
        MessageUtils.handleMessageError(
            model.sendTextMessage(
                text: text, convID: widget.conversationID, convType: convType),
            context);
      }
      textEditingController.clear();
      // handleSetDraftText();
      _addDeleteTag();
      goDownBottom();
    }
  }

  onCustomEmojiFaceSubmitted(int index, String data) {
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
    if (model.repliedMessage != null) {
      MessageUtils.handleMessageError(
          model.sendFaceMessage(
              index: index,
              data: data,
              convID: widget.conversationID,
              convType: convType),
          context);
    } else {
      MessageUtils.handleMessageError(
          model.sendFaceMessage(
              index: index,
              data: data,
              convID: widget.conversationID,
              convType: convType),
          context);
    }
  }

  List<String> getUserIdFromMemberInfoMap() {
    List<String> userList = [];
    memberInfoMap.forEach((String key, V2TimGroupMemberFullInfo info) {
      userList.add(info.userID);
    });

    return userList;
  }

  onSubmitted() async {
    final text = textEditingController.text.trim();
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
    if (text != zeroWidthSpace) {
      if (model.repliedMessage != null) {
        MessageUtils.handleMessageError(
            model.sendReplyMessage(
                text: text, convID: widget.conversationID, convType: convType),
            context);
      } else if (memberInfoMap.isNotEmpty) {
        model.sendTextAtMessage(
            text: text,
            convID: widget.conversationID,
            atUserList: getUserIdFromMemberInfoMap());
      } else {
        MessageUtils.handleMessageError(
            model.sendTextMessage(
                text: text, convID: widget.conversationID, convType: convType),
            context);
      }
      textEditingController.clear();
      _addDeleteTag();
      focusNode.requestFocus();
      lastText = "";
      memberInfoMap = {};
      // handleSetDraftText();
      setState(() {
        showKeyboard = true;
      });
      goDownBottom();
    }
  }

  void goDownBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      widget.scrollController.animateTo(
        widget.scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    });
  }

  hideAllPanel() {
    focusNode.unfocus();
    setState(() {
      showKeyboard = false;
      showMore = false;
      showEmojiPanel = false;
    });
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   if (widget.closeKeyboardPanel) {
  //     setState(() {
  //       showKeyboard = false;
  //       showMore = false;
  //       showEmojiPanel = false;
  //     });
  //   }
  // }

  void onModelChanged() {
    if (model.repliedMessage != null) {
      focusNode.requestFocus();
      setState(() {
        showKeyboard = true;
      });
    }
    if (model.editRevokedMsg != "") {
      focusNode.requestFocus();
      setState(() {
        showKeyboard = true;
      });
      textEditingController.clear();
      textEditingController.text = model.editRevokedMsg;
      textEditingController.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: model.editRevokedMsg.length));
      model.editRevokedMsg = "";
    }
  }

  _addDeleteTag() {
    textEditingController.text = zeroWidthSpace;
    textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: textEditingController.text.length));
  }

  _handleSoftKeyBoardDelete() {
    if (model.repliedMessage != null) {
      model.setRepliedMessage(null);
    }
  }

  _getShowName(V2TimGroupMemberFullInfo? item) {
    final friendRemark = item?.friendRemark ?? "";
    final nameCard = item?.nameCard ?? "";
    final nickName = item?.nickName ?? "";
    final userID = item?.userID ?? "";
    return friendRemark.isNotEmpty
        ? friendRemark
        : nameCard.isNotEmpty
            ? nameCard
            : nickName.isNotEmpty
                ? nickName
                : userID;
  }

  longPressToAt(String? userID, String? nickName) {
    final memberInfo = V2TimGroupMemberFullInfo(
      userID: userID ?? "",
      nickName: nickName,
    );
    final showName = _getShowName(memberInfo);
    memberInfoMap["@$showName"] = memberInfo;
    String text = "$lastText@$showName ";
    //please do not delete space
    textEditingController.text = text;
    textEditingController.selection =
        TextSelection.fromPosition(TextPosition(offset: text.length));
    lastText = text;
  }

  _handleAtText(String text) async {
    String? groupID = widget.conversationType == ConversationType.V2TIM_GROUP
        ? widget.conversationID
        : null;

    if (groupID == null) {
      lastText = text;
      return;
    }

    RegExp atTextReg = RegExp(r'@([^@\s]*)');

    int textLength = text.length;
    // 删除的话
    if (lastText.length > textLength) {
      Map<String, V2TimGroupMemberFullInfo> map = {};
      Iterable<Match> matches = atTextReg.allMatches(text);
      List<String?> parseAtList = [];
      for (final item in matches) {
        final str = item.group(0);
        parseAtList.add(str);
      }
      for (String? key in parseAtList) {
        if (key != null && memberInfoMap[key] != null) {
          map[key] = memberInfoMap[key]!;
        }
      }
      memberInfoMap = map;
    }
    // 有@的情况并且是文本新增的时候
    if (text[textLength - 1] == "@" && lastText.length < textLength) {
      V2TimGroupMemberFullInfo? memberInfo = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AtText(
              groupID: groupID,
              groupType: conversationModel.selectedConversation?.groupType),
        ),
      );
      final showName = _getShowName(memberInfo);
      if (memberInfo != null) {
        memberInfoMap["@$showName"] = memberInfo;
        //please don not delete space
        textEditingController.text = "$text$showName ";
      }
    }
    lastText = text;
  }

  _debounce(
    Function(String text) fun, [
    Duration delay = const Duration(milliseconds: 100),
  ]) {
    Timer? timer;
    return (String text) {
      if (timer != null) {
        timer?.cancel();
      }

      timer = Timer(delay, () {
        fun(text);
      });
    };
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    textEditingController = TextEditingController();
    model.addListener(onModelChanged);
    if (widget.draftText != null) {
      textEditingController.text = zeroWidthSpace + widget.draftText!;
    } else {
      textEditingController.text = zeroWidthSpace;
    }
  }

  @override
  void dispose() {
    handleSetDraftText();
    model.removeListener(onModelChanged);
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debounceFunc = _debounce((value) {
      // handleSetDraftText();
      _handleAtText(value);
      final isEmpty = value.isEmpty;
      if (isEmpty) {
        _handleSoftKeyBoardDelete();
        _addDeleteTag();
      }
    }, const Duration(milliseconds: 80));
    final chatConfig = Provider.of<TIMUIKitChatConfig>(context);
    return Column(
      children: [
        _buildRepliedMessage(),
        Container(
          color: hexToColor("EBF0F6"),
          // constraints: const BoxConstraints(minHeight: 90),
          // height: 90,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Row(
                    children: [
                      if (chatConfig.isAllowSoundMessage)
                        InkWell(
                          onTap: () {
                            if (showSendSoundText) {
                              focusNode.requestFocus();
                              setState(() {
                                showKeyboard = true;
                              });
                            }
                            setState(() {
                              showEmojiPanel = false;
                              showMore = false;
                              showSendSoundText = !showSendSoundText;
                            });
                          },
                          child: SvgPicture.asset(
                            'images/voice.svg',
                            package: 'tim_ui_kit',
                            color: const Color.fromRGBO(68, 68, 68, 1),
                            height: 28,
                            width: 28,
                          ),
                        ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: showSendSoundText
                            ? SendSoundMessage(
                                onDownBottom: goDownBottom,
                                conversationID: widget.conversationID,
                                conversationType: widget.conversationType)
                            : TextField(
                                onChanged: debounceFunc,
                                maxLines: 4,
                                minLines: 1,
                                controller: textEditingController,
                                focusNode: focusNode,
                                onTap: () {
                                  goDownBottom();
                                  setState(() {
                                    showKeyboard = true;
                                    showEmojiPanel = false;
                                    showMore = false;
                                  });
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.send,
                                onEditingComplete: onSubmitted,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
                                      // fontSize: 10,
                                      color: Color(0xffAEA4A3),
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    isDense: true,
                                    hintText: widget.hintText ?? ''),
                              ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      if (chatConfig.isAllowEmojiPanel)
                        InkWell(
                          onTap: () {
                            _openEmojiPanel();
                            goDownBottom();
                          },
                          child: SvgPicture.asset(
                            'images/face.svg',
                            package: 'tim_ui_kit',
                            color: const Color.fromRGBO(68, 68, 68, 1),
                            height: 28,
                            width: 28,
                          ),
                        ),
                      const SizedBox(
                        width: 10,
                      ),
                      if (chatConfig.isAllowShowMorePanel)
                        InkWell(
                          onTap: () {
                            _openMore();
                            goDownBottom();
                          },
                          child: SvgPicture.asset(
                            'images/add.svg',
                            package: 'tim_ui_kit',
                            color: const Color.fromRGBO(68, 68, 68, 1),
                            height: 28,
                            width: 28,
                          ),
                        )
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: _getBottomHeight(),
                  // TODO: AnimatedOpacity 和其他动画组件混用会导致显示问题
                  child: _getBottomContainer(),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
