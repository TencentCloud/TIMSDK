import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/message_reaction_emoji.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_emoji_panel.dart';
import 'package:tim_ui_kit/ui/widgets/emoji.dart';
import 'package:tim_ui_kit/ui/widgets/extended_wrap/extended_wrap.dart';

enum SelectEmojiPanelPosition { up, down }

class TIMUIKitMessageReactionEmojiSelectPanel extends StatefulWidget {
  final ValueChanged<int> onSelect;
  final bool isShowMoreSticker;
  final ValueChanged<bool> onClickShowMore;

  const TIMUIKitMessageReactionEmojiSelectPanel(
      {Key? key,
      required this.onSelect,
      required this.isShowMoreSticker,
      required this.onClickShowMore})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      TIMUIKitMessageReactionEmojiSelectPanelState();
}

class TIMUIKitMessageReactionEmojiSelectPanelState
    extends TIMUIKitState<TIMUIKitMessageReactionEmojiSelectPanel> {
  bool isShowMore = false;

  _buildSimplePanel(TUITheme theme) {
    final List<Map<String, Object>> emojiData = messageReactionEmojiData;
    return ExtendedWrap(
      maxLines: widget.isShowMoreSticker ? 5 : 1,
      spacing: 18,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 24,
      children: [
        GestureDetector(
          onTap: () {
            widget.onClickShowMore(!widget.isShowMoreSticker);
          },
          child: SizedBox(
            height: 34,
            child: Icon(
                widget.isShowMoreSticker
                    ? Icons.cancel_outlined
                    : Icons.add_circle_outline_outlined,
                color: hexToColor("444444"),
                size: 26),
          ),
        ),
        ...emojiData.map(
          (e) {
            var item = Emoji.fromJson(e);
            return SizedBox(
              // width: 50,
              child: InkWell(
                onTap: () {
                  widget.onSelect(item.unicode);
                },
                child: EmojiItem(
                  name: item.name,
                  unicode: item.unicode,
                ),
              ),
            );
          },
        ).toList()
      ],
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Container(
      child: _buildSimplePanel(theme),
    );
  }
}
