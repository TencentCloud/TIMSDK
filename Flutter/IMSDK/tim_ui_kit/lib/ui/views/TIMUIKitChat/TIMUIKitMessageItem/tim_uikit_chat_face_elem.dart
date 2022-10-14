import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_wrapper.dart';

class TIMUIKitFaceElem extends StatefulWidget {
  final String path;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final V2TimMessage message;
  final bool? isShowMessageReaction;
  final TUIChatSeparateViewModel model;

  const TIMUIKitFaceElem(
      {Key? key,
      required this.path,
      required this.isShowJump,
      this.clearJump,
      required this.message,
      this.isShowMessageReaction,
      required this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitTextElemState();
}

class _TIMUIKitTextElemState extends TIMUIKitState<TIMUIKitFaceElem> {
  @override
  void initState() {
    super.initState();
  }

  bool isFromNetwork() {
    return widget.path.startsWith('http');
  }

  createPathFromNative(String path) {
    String prefix = "";
    String suffix = "";
    if (widget.model.chatConfig.faceURIPrefix != null) {
      prefix = widget.model.chatConfig.faceURIPrefix!(path);
    }
    if (widget.model.chatConfig.faceURISuffix != null) {
      suffix = widget.model.chatConfig.faceURISuffix!(path);
    }
    return "$prefix$path$suffix";
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return TIMUIKitMessageReactionWrapper(
      chatModel: widget.model,
        isShowJump: widget.isShowJump,
        isFromSelf: widget.message.isSelf ?? true,
        clearJump: widget.clearJump,
        message: widget.message,
        isShowMessageReaction: widget.isShowMessageReaction ?? true,
        child: Container(
          padding: const EdgeInsets.all(10),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
          child: isFromNetwork()
              ? Image.network(widget.path)
              : Image.asset(createPathFromNative(widget.path)),
        ));
  }
}
