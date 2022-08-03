import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_wrapper.dart';

class TIMUIKitFaceElem extends StatefulWidget {
  final String path;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final V2TimMessage message;
  final bool? isShowMessageReaction;

  const TIMUIKitFaceElem(
      {Key? key,
      required this.path,
      required this.isShowJump,
      this.clearJump,
      required this.message,
      this.isShowMessageReaction})
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

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return TIMUIKitMessageReactionWrapper(
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
              : Image.asset(widget.path),
        ));
  }
}
