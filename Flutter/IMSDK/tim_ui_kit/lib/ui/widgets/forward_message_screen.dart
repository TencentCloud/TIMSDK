import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/widgets/recent_conversation_list.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class ForwardMessageScreen extends StatefulWidget {
  final bool isMergerForward;
  final int conversationType;

  const ForwardMessageScreen(
      {Key? key, this.isMergerForward = false, required this.conversationType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends TIMUIKitState<ForwardMessageScreen> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  List<V2TimConversation> _conversationList = [];
  bool isMultiSelect = false;

  String _getMergerMessageTitle() {
    if (widget.conversationType == 1) {
      final selectedMessage = model.multiSelectedMessageList.first;
      final sender = selectedMessage.sender;
      final option1 = selectedMessage.nickName ?? selectedMessage.userID;
      return sender! +
          TIM_t_para("与{{option1}}的聊天记录", "与$option1的聊天记录")(option1: option1);
    } else {
      return TIM_t("群聊的聊天记录");
    }
  }

  List<String> _getAbstractList() {
    return model.multiSelectedMessageList
        .map((e) =>
            "${e.sender}: ${model.abstractMessageBuilder != null ? model.abstractMessageBuilder!(e) : MessageUtils.getAbstractMessage(e)}")
        .toList();
  }

  _handleForwardMessage() async {
    if (widget.isMergerForward) {
      await model.sendMergerMessage(
        conversationList: _conversationList,
        title: _getMergerMessageTitle(),
        abstractList: _getAbstractList(),
        context: context,
      );
    } else {
      await model.sendForwardMessage(conversationList: _conversationList);
    }
    model.updateMultiSelectStatus(false);
    Navigator.pop(context);
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          TIM_t("选择"),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        shadowColor: theme.weakBackgroundColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            if (isMultiSelect) {
              setState(() {
                isMultiSelect = false;
                _conversationList = [];
              });
            } else {
              model.updateMultiSelectStatus(false);
              Navigator.pop(context);
            }
          },
          child: Text(
            TIM_t("取消"),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!isMultiSelect) {
                setState(() {
                  isMultiSelect = true;
                });
              } else {
                _handleForwardMessage();
              }
            },
            child: Text(
              !isMultiSelect ? TIM_t("多选") : TIM_t("完成"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: RecentForwardList(
        isMultiSelect: isMultiSelect,
        onChanged: (conversationList) {
          _conversationList = conversationList;

          if (!isMultiSelect) {
            _handleForwardMessage();
          }
        },
      ),
    );
  }
}
