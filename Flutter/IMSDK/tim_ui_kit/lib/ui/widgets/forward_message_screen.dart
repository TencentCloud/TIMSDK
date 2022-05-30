import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/widgets/recent_conversation_list.dart';

class ForwardMessageScreen extends StatefulWidget {
  final bool isMergerForward;
  final String conversationShowName;
  final int conversationType;

  const ForwardMessageScreen(
      {Key? key,
      this.isMergerForward = false,
      required this.conversationShowName,
      required this.conversationType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  List<V2TimConversation> _conversationList = [];
  bool isMultiSelect = false;

  String _getMergerMessageTitle() {
    final I18nUtils ttBuild = I18nUtils(context);
    if (widget.conversationType == 1) {
      final selectedMessage = model.multiSelectedMessageList.first;
      final sender = selectedMessage.sender;
      final option1 = selectedMessage.nickName ?? selectedMessage.userID;
      return sender! +
          ttBuild.imt_para("与{{option1}}的聊天记录", "与$option1的聊天记录")(
              option1: option1);
    } else {
      return ttBuild.imt("群聊的聊天记录");
    }
  }

  List<String> _getAbstractList() {
    return model.multiSelectedMessageList
        .map((e) =>
            "${e.sender}: ${MessageUtils.getAbstractMessage(e, context)}")
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
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(
            builder: (context, value, child) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      ttBuild.imt("选择"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    shadowColor: value.theme.weakBackgroundColor,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          value.theme.lightPrimaryColor ??
                              CommonColor.lightPrimaryColor,
                          value.theme.primaryColor ?? CommonColor.primaryColor
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
                        ttBuild.imt("取消"),
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
                          !isMultiSelect
                              ? ttBuild.imt("多选")
                              : ttBuild.imt("完成"),
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
                )));
  }
}
