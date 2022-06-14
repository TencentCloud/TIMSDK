import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_at_text.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_emoji_panel.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_send_sound_message.dart';

import 'package:tim_ui_kit/ui/utils/permission.dart';

class TIMUIKitInputTextField extends StatefulWidget {
  /// conversation id
  final String conversationID;

  /// conversation type
  final int conversationType;

  /// init text, use for draft text re-view
  final String? initText;

  /// messageList widget scroll controller
  final AutoScrollController? scrollController;

  /// hint text for textField widget
  final String? hintText;

  /// config for more pannel
  final MorePanelConfig? morePanelConfig;

  /// show send audio icon
  final bool showSendAudio;

  /// show send emoji icon
  final bool showSendEmoji;

  /// show more pannel
  final bool showMorePannel;

  /// background color
  final Color? backgroundColor;

  /// controll input field behavior
  final TIMUIKitInputTextFieldController? controller;

  /// on text changed
  final void Function(String)? onChanged;

  /// sticker panel customiziation
  final Widget Function(
      {void Function() sendTextMessage,
      void Function(int index, String data) sendFaceMessage,
      void Function() deleteText,
      void Function(int unicode) addText})? customStickerPanel;

  const TIMUIKitInputTextField(
      {Key? key,
      required this.conversationID,
      required this.conversationType,
      this.initText,
      this.hintText,
      this.scrollController,
      this.morePanelConfig,
      this.customStickerPanel,
      this.showSendAudio = true,
      this.showSendEmoji = true,
      this.showMorePannel = true,
      this.backgroundColor,
      this.controller,
      this.onChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<TIMUIKitInputTextField> {
  bool showMore = false;
  bool showSendSoundText = false;
  bool showEmojiPanel = false;
  bool showKeyboard = false;
  late FocusNode focusNode;
  String zeroWidthSpace = '\ufeff';
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
    // if (showKeyboard) {
    //   // return MediaQuery.of(context).viewInsets.bottom;
    //   return 0;
    // } else
    if (showMore || showEmojiPanel) {
      return 248.0;
    }
    // 在文本框多行拓展时增加保护区高度
    else if (textEditingController.text.length >= 46 && showKeyboard == false) {
      return 25;
    } else {
      return 0;
    }
  }

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
    return text.replaceAll(RegExp(r'\ufeff'), "");
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
      draftText = "";
    }
    await conversationModel.setConversationDraft(
        conversationID: conversationID, draftText: draftText);
  }

  _buildRepliedMessage(V2TimMessage? repliedMessage) {
    final haveRepliedMessage = repliedMessage != null;
    if (haveRepliedMessage) {
      final text =
          "${MessageUtils.getDisplayName(model.repliedMessage!)}:${MessageUtils.getAbstractMessage(model.repliedMessage!, context)}";
      return Container(
        color: hexToColor("EBF0F6"),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: hexToColor("8F96A0"), fontSize: 14),
              ),
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
      // _addDeleteTag();
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
    if (text.isNotEmpty && text != zeroWidthSpace) {
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
    if (text.isNotEmpty && text != zeroWidthSpace) {
      if (model.repliedMessage != null) {
        MessageUtils.handleMessageError(
            model.sendReplyMessage(
                text: text, convID: widget.conversationID, convType: convType),
            context);
      } else if (memberInfoMap.isNotEmpty) {
        model.sendTextAtMessage(
            text: text,
            convType:
                widget.conversationType == 1 ? ConvType.c2c : ConvType.group,
            convID: widget.conversationID,
            atUserList: getUserIdFromMemberInfoMap());
      } else {
        MessageUtils.handleMessageError(
            model.sendTextMessage(
                text: text, convID: widget.conversationID, convType: convType),
            context);
      }
      textEditingController.clear();
      focusNode.requestFocus();
      lastText = "";
      memberInfoMap = {};
      setState(() {
        showKeyboard = true;
      });
      goDownBottom();
    }
  }

  void goDownBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (widget.scrollController != null) {
        widget.scrollController!.animateTo(
          widget.scrollController!.position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      }
    });
  }

  _hideAllPanel() {
    focusNode.unfocus();
    setState(() {
      showKeyboard = false;
      showMore = false;
      showEmojiPanel = false;
    });
  }

  void onModelChanged() {
    if (model.repliedMessage != null) {
      focusNode.requestFocus();
      _addDeleteTag();
      setState(() {
        showKeyboard = true;
      });
    } else {}
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
    final originalText = textEditingController.text;
    textEditingController.text = zeroWidthSpace + originalText;
    textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: textEditingController.text.length));
  }

  _handleSoftKeyBoardDelete() {
    if (model.repliedMessage != null) {
      model.setRepliedMessage(null);
    }
  }

  _getShowName(V2TimGroupMemberFullInfo? item) {
    final nameCard = item?.nameCard ?? "";
    final nickName = item?.nickName ?? "";
    final userID = item?.userID ?? "";
    return nameCard.isNotEmpty
        ? nameCard
        : nickName.isNotEmpty
            ? nickName
            : userID;
  }

  _longPressToAt(String? userID, String? nickName) {
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
    if (lastText.length > textLength && text != "@") {
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
    if (text[textLength - 1] == "@" &&
        (lastText.length < textLength || text == "@")) {
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
    textEditingController =
        widget.controller?.textEditingController ?? TextEditingController();
    if (widget.controller != null) {
      widget.controller?.addListener(() {
        final actionType = widget.controller?.actionType;
        if (actionType == ActionType.hideAllPanel) {
          _hideAllPanel();
        }
        if (actionType == ActionType.longPressToAt) {
          _longPressToAt(
              widget.controller?.atUserID, widget.controller?.atUserName);
        }
      });
    }
    model.addListener(onModelChanged);
    if (widget.initText != null) {
      textEditingController.text = widget.initText!;
    }
  }

  @override
  void dispose() {
    handleSetDraftText();
    model.removeListener(onModelChanged);
    focusNode.dispose();
    // textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debounceFunc = _debounce((value) {
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
      _handleAtText(value);
      final isEmpty = value.isEmpty;
      if (isEmpty) {
        _handleSoftKeyBoardDelete();
      }
    }, const Duration(milliseconds: 80));
    return Selector<TUIChatViewModel, V2TimMessage?>(
        builder: ((context, value, child) {
          return Column(
            children: [
              _buildRepliedMessage(value),
              Container(
                color: widget.backgroundColor ?? hexToColor("EBF0F6"),
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Row(
                          children: [
                            if (widget.showSendAudio)
                              InkWell(
                                onTap: () async {
                                  if (showSendSoundText) {
                                    focusNode.requestFocus();
                                    setState(() {
                                      showKeyboard = true;
                                    });
                                  }
                                  if (await Permissions.checkPermission(
                                      context, Permission.microphone.value)) {
                                    setState(() {
                                      showEmojiPanel = false;
                                      showMore = false;
                                      showSendSoundText = !showSendSoundText;
                                    });
                                  }
                                },
                                child: SvgPicture.asset(
                                  showSendSoundText
                                      ? 'images/keyboard.svg'
                                      : 'images/voice.svg',
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
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
                            if (widget.showSendEmoji)
                              InkWell(
                                onTap: () {
                                  _openEmojiPanel();
                                  goDownBottom();
                                },
                                child: SvgPicture.asset(
                                  showEmojiPanel
                                      ? 'images/keyboard.svg'
                                      : 'images/face.svg',
                                  package: 'tim_ui_kit',
                                  color: const Color.fromRGBO(68, 68, 68, 1),
                                  height: 28,
                                  width: 28,
                                ),
                              ),
                            const SizedBox(
                              width: 10,
                            ),
                            if (widget.showMorePannel)
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
                        child: _getBottomContainer(),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        }),
        selector: (c, model) => model.repliedMessage);
  }
}
