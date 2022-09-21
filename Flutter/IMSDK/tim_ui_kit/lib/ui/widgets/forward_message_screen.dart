import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/widgets/recent_conversation_list.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class ForwardMessageScreen extends StatefulWidget {
  final bool isMergerForward;
  final ConvType conversationType;
  final TUIChatSeparateViewModel model;

  const ForwardMessageScreen(
      {Key? key,
      this.isMergerForward = false,
      required this.conversationType,
      required this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends TIMUIKitState<ForwardMessageScreen> {
  final TUIChatGlobalModel model = serviceLocator<TUIChatGlobalModel>();
  final TUISelfInfoViewModel _selfInfoViewModel =
      serviceLocator<TUISelfInfoViewModel>();
  List<V2TimConversation> _conversationList = [];
  bool isMultiSelect = false;

  String _getMergerMessageTitle() {
    if (widget.conversationType == ConvType.c2c) {
      final option1 = (_selfInfoViewModel.loginInfo?.nickName != null &&
              _selfInfoViewModel.loginInfo!.nickName!.isNotEmpty)
          ? _selfInfoViewModel.loginInfo?.nickName
          : _selfInfoViewModel.loginInfo?.userID;
      // Chat History for xx
      return TIM_t_para("{{option1}}的聊天记录", "$option1的聊天记录")(option1: option1);
    } else {
      return TIM_t("群聊的聊天记录");
    }
  }

  List<String> _getAbstractList() {
    return widget.model.multiSelectedMessageList.map((e) {
      final sender = (e.nickName != null && e.nickName!.isNotEmpty)
          ? e.nickName
          : e.sender;
      return "$sender: ${model.abstractMessageBuilder != null ? model.abstractMessageBuilder!(e) : MessageUtils.getAbstractMessage(e)}";
    }).toList();
  }

  _handleForwardMessage() async {
    if (widget.isMergerForward) {
      await widget.model.sendMergerMessage(
        conversationList: _conversationList,
        title: _getMergerMessageTitle(),
        abstractList: _getAbstractList(),
        context: context,
      );
    } else {
      await widget.model
          .sendForwardMessage(conversationList: _conversationList);
    }
    widget.model.updateMultiSelectStatus(false);
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
              widget.model.updateMultiSelectStatus(false);
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
