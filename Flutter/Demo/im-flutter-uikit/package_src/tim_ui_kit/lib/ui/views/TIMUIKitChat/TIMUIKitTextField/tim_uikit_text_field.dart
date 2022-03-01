import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_emoji_pannel.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_more_pannel.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_send_sound_message.dart';

class InputTextField extends StatefulWidget {
  final ScrollController listViewController;
  final bool closeKeyboardPanel;

  /// 会话ID
  final String conversationID;

  /// 会话类型
  final int conversationType;

  const InputTextField(
      {Key? key,
      required this.listViewController,
      required this.closeKeyboardPanel,
      required this.conversationID,
      required this.conversationType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool showMore = false;
  bool showSendSoundText = false;
  bool showEmojiPanel = false;
  bool showKeyboard = false;
  FocusNode focusNode = FocusNode();

  TextEditingController textEditingController = TextEditingController();
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

  Widget _getBottomContainer() {
    if (showEmojiPanel) {
      return EmojiPanel(onTapEmoji: (unicode) {
        final oldText = textEditingController.text;
        final newText = String.fromCharCode(unicode);
        textEditingController.text = "$oldText$newText";
      }, onSubmitted: () {
        onEmojiSubmited();
      }, delete: () {
        backSpaceText();
      });
    }

    if (showMore) {
      return MorePanel(
          conversationID: widget.conversationID,
          conversationType: widget.conversationType);
    }

    return Container();
  }

  double _getBottomHeight() {
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

  getShowName(message) {
    return message.friendRemark == null || message.friendRemark == ''
        ? message.nickName == null || message.nickName == ''
            ? message.sender
            : message.nickName
        : message.friendRemark;
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

    if (originalText.isNotEmpty) {
      text = originalText.characters.skipLast(1);
      textEditingController.text = "$text";
    }
  }

// 和onSubmitted一样，只是保持焦点的不同
  onEmojiSubmited() {
    final text = textEditingController.text.trim();
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
    if (text != "") {
      if (model.repliedMessage != null) {
        model.sendReplyMessage(
            text: text, convID: widget.conversationID, convType: convType);
      } else {
        model.sendTextMessage(
            text: text, convID: widget.conversationID, convType: convType);
      }
      textEditingController.clear();
    }
  }

  onSubmitted(_) {
    final text = textEditingController.text.trim();
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
    if (text != "") {
      if (model.repliedMessage != null) {
        model.sendReplyMessage(
            text: text, convID: widget.conversationID, convType: convType);
      } else {
        model.sendTextMessage(
            text: text, convID: widget.conversationID, convType: convType);
      }
      textEditingController.clear();
      focusNode.requestFocus();
      setState(() {
        showKeyboard = true;
      });
    }
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

  @override
  void initState() {
    super.initState();
    model.addListener(() {
      if (model.repliedMessage != null) {
        focusNode.requestFocus();
        setState(() {
          showKeyboard = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRepliedMessage(),
        Container(
          color: hexToColor("EBF0F6"),
          constraints: const BoxConstraints(minHeight: 90),
          // height: 90,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                constraints: const BoxConstraints(minHeight: 50),
                child: Row(
                  children: [
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
                              conversationID: widget.conversationID,
                              conversationType: widget.conversationType)
                          : TextField(
                              maxLines: 4,
                              minLines: 1,
                              controller: textEditingController,
                              focusNode: focusNode,
                              onTap: () {
                                final _scrollController =
                                    widget.listViewController;
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                      _scrollController
                                          .position.minScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.ease);
                                }

                                setState(() {
                                  showKeyboard = true;
                                  showEmojiPanel = false;
                                  showMore = false;
                                });
                              },
                              textInputAction: TextInputAction.send,
                              onSubmitted: onSubmitted,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    // fontSize: 10,
                                    color: Color(0xffAEA4A3),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  isDense: true,
                                  hintText: ''),
                            ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        _openEmojiPanel();
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
                    InkWell(
                      onTap: () {
                        _openMore();
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
                duration: const Duration(milliseconds: 230),
                height: _getBottomHeight(),
                // TODO: AnimatedOpacity 和其他动画组件混用会导致显示问题
                child: _getBottomContainer(),
              )
            ],
          ),
        )
      ],
    );
  }
}
