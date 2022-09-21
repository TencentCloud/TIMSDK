import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/merger_message_screen.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'TIMUIKitMessageReaction/tim_uikit_message_reaction_show_panel.dart';

class TIMUIKitMergerElem extends StatefulWidget {
  final V2TimMergerElem mergerElem;
  final String messageID;
  final bool isSelf;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final V2TimMessage message;
  final bool? isShowMessageReaction;
  final TUIChatSeparateViewModel model;

  const TIMUIKitMergerElem(
      {Key? key,
      required this.message,
      required this.model,
      required this.mergerElem,
      required this.isSelf,
      this.isShowMessageReaction,
      required this.messageID,
      required this.isShowJump,
      this.clearJump})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitMergerElemState();
}

class TIMUIKitMergerElemState extends TIMUIKitState<TIMUIKitMergerElem> {
  bool isShowJumpState = false;

  _showJumpColor() {
    int shineAmount = 6;
    setState(() {
      isShowJumpState = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.clearJump != null) {
        widget.clearJump!();
      }
    });
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        timer.cancel();
      }
      shineAmount--;
    });
  }

  _handleTap(BuildContext context, TUIChatSeparateViewModel model) async {
    try {
      if (widget.messageID != "") {
        final mergerMessageList =
            await model.downloadMergerMessage(widget.messageID);
        if (mergerMessageList != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MergerMessageScreen(
                    model: model, messageList: mergerMessageList),
              ));
        }
      }
    } catch (e) {
      onTIMCallback(TIMCallback(
          type: TIMCallbackType.INFO,
          infoRecommendText: TIM_t("无法定位到原消息"),
          infoCode: 6660401));
    }
  }

  List<String>? _getAbstractList() {
    final length = widget.mergerElem.abstractList!.length;
    if (length <= 4) {
      return widget.mergerElem.abstractList;
    }
    return widget.mergerElem.abstractList!.getRange(0, 4).toList();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    if (widget.isShowJump) {
      Future.delayed(Duration.zero, () {
        _showJumpColor();
      });
    }
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: widget.isSelf ? const Radius.circular(10) : Radius.zero,
          bottomLeft: const Radius.circular(10),
          topRight: widget.isSelf ? Radius.zero : const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
        border: Border.all(
          color: isShowJumpState
              ? const Color.fromRGBO(245, 166, 35, 1)
              : (theme.weakDividerColor ?? CommonColor.weakDividerColor),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _handleTap(context, widget.model);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.mergerElem.title!,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              // const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _getAbstractList()!
                    .map(
                      (e) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              e,
                              textAlign: TextAlign.left,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: theme.weakTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(
                height: 4,
              ),
              const Divider(),
              Text(
                TIM_t("聊天记录"),
                style: TextStyle(
                  color: theme.weakTextColor,
                  fontSize: 10,
                ),
              ),
              if (widget.isShowMessageReaction ?? true)
                TIMUIKitMessageReactionShowPanel(message: widget.message)
            ],
          ),
        ),
      ),
    );
  }
}
